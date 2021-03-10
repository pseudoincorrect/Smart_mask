/*************************
 * Includes
 ************************/

// SDK 
#include "nordic_common.h"
#include "nrf.h"
#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"
#include "nrf_sdm.h"
#include "nrf_pwr_mgmt.h"
#include "app_error.h"
#include "app_button.h"
#include "app_timer.h"
#include "boards.h"
// Project
#include "sensor_sampling.h"
#include "sensor_def"
#include "app_ble.h"

/*************************
 * Defines
 ************************/

// Is on when device is advertising
#define ADVERTISING_LED BSP_BOARD_LED_0
// Is on when device has connected
#define CONNECTED_LED BSP_BOARD_LED_1
// LED to be toggled with the help of the LED Button Service
#define LEDBUTTON_LED BSP_BOARD_LED_2
// Button that will trigger the notification event with the LED Button Service */
#define CONNECT_BUTTON BSP_BUTTON_0
// Delay from a GPIOTE event until a button is reported as pushed (in number of timer ticks)
#define BUTTON_DETECTION_DELAY APP_TIMER_TICKS(50)
// Value used as error code on stack dump, can be used to identify stack location on stack unwind
#define DEAD_BEEF 0xDEADBEEF

/*************************
 * Static Variables
 ************************/

// Handler for the app bluetooth
static app_ble_conf_t m_app_ble_conf;
// Mock data for the sensors
static uint16_t mock_sensor_data = 0;
// sensors buffers
static sensors_t m_sensors;
static sensors_t m_sensors_previous;

// timer for the sensors
APP_TIMER_DEF(m_timer_sensors_id);

/*************************
 * Function Definitions
 ************************/

/**
 * @brief Handler for timer events.
 */
void timer_led_event_handler(nrf_timer_event_t event_type, void * p_context)
{
    static uint32_t i;
    uint32_t led_to_invert = ((i++) % LEDS_NUMBER);

    switch (event_type)
    {
        case NRF_TIMER_EVENT_COMPARE0:
            bsp_board_led_invert(led_to_invert);
            break;

        default:
            break;
    }
}


/**@brief Function for handling write events to the LED characteristic.
 * @param[in] p_lbs     Instance of LED Button Service to which the write applies.
 * @param[in] led_state Written/desired state of the LED.
 */
static void led_write_handler(uint16_t conn_handle, ble_lbs_t * p_lbs,
                              uint8_t led_state)
{
    if (led_state)
    {
        bsp_board_led_on(LEDBUTTON_LED);
        NRF_LOG_INFO("Received LED ON!");
    }
    else
    {
        bsp_board_led_off(LEDBUTTON_LED);
        NRF_LOG_INFO("Received LED OFF!");
    }
}


/** @brief Function for handling write event to the output characteristic
    @param[in] p_sms Instance of Sensor Measurement Service to which the write applies
    @param[in] output_state, Written/desired state of the outputs
*/
static void output_write_handler(uint16_t conn_handle, ble_sms_t * p_sms,
                                 uint8_t output_state)
{
    NRF_LOG_INFO("output State %d", output_state);
}


/**@brief Function for assert macro callback.
 * @details This function will be called in case of an assert in the SoftDevice.
 * @warning This handler is an example only and does not fit a final product.
 *          You need to analyze how your product is supposed to react in case of Assert.
 * @warning On assert from the SoftDevice, the system can only recover on reset.
 * @param[in] line_num    Line number of the failing ASSERT call.
 * @param[in] p_file_name File name of the failing ASSERT call.
 */
void assert_nrf_callback(uint16_t line_num, const uint8_t * p_file_name)
{
    app_error_handler(DEAD_BEEF, line_num, p_file_name);
}


/**@brief Function for the LEDs initialization.
 * @details Initializes all LEDs used by the application.
 */
static void leds_init(void)
{
    bsp_board_init(BSP_INIT_LEDS);
}


/**@brief Function for the Timer initialization.
 * @details Initializes the timer module.
 */
static void timers_init(void)
{
    // Initialize timer module, making it use the scheduler
    ret_code_t err_code = app_timer_init();
    APP_ERROR_CHECK(err_code);
}


/**@brief Function for handling events from the button handler module.
 * @param[in] pin_no        The pin that the event applies to.
 * @param[in] button_action The button action (press/release).
 */
static void button_event_handler(uint8_t pin_no, uint8_t button_action)
{
    ret_code_t err_code;

    switch (pin_no)
    {
        case CONNECT_BUTTON:
            NRF_LOG_INFO("Send button state change.");
            err_code = ble_lbs_on_button_change(
                           *m_app_ble_conf.ble_conn_handle,
                           m_app_ble_conf.ble_lbs,
                           button_action
                       );
            if (err_code != NRF_SUCCESS
                    && err_code != BLE_ERROR_INVALID_CONN_HANDLE
                    && err_code != NRF_ERROR_INVALID_STATE
                    && err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING
               )
            {
                APP_ERROR_CHECK(err_code);
            }
            break;
        default:
            APP_ERROR_HANDLER(pin_no);
            break;
    }
}


/**@brief Function for initializing the button handler module.
 */
static void buttons_init(void)
{
    ret_code_t err_code;

    // The array must be static because a pointer to it will be saved in the button handler module.
    static app_button_cfg_t buttons[] =
    {
        {CONNECT_BUTTON, false, BUTTON_PULL, button_event_handler}
    };

    err_code = app_button_init(buttons, ARRAY_SIZE(buttons),
                               BUTTON_DETECTION_DELAY);
    APP_ERROR_CHECK(err_code);
}


/**@brief Function for initializing the Log module, either RTT or UART.
 */
static void log_init(void)
{
    ret_code_t err_code = NRF_LOG_INIT(NULL);
    APP_ERROR_CHECK(err_code);

    NRF_LOG_DEFAULT_BACKENDS_INIT();
}


/**@brief Function for initializing power management.
 */
static void power_management_init(void)
{
    ret_code_t err_code;
    err_code = nrf_pwr_mgmt_init();
    APP_ERROR_CHECK(err_code);
}


/**@brief Function for handling the idle state (main loop).
 * @details If there is no pending log operation, then sleep until next the next event occurs.
 */
static void idle_state_handle(void)
{
    if (NRF_LOG_PROCESS() == false)
    {
        nrf_pwr_mgmt_run();
    }
}


/**@brief send sensor values over bluetooth if values updated
 */
void check_sensors_update(void)
{
    ret_code_t err_code;

    for (int i = 0; i < SENSORS_COUNT; i++)
    {
        if (m_sensors.values[i] != m_sensors_previous.values[i])
        {
            err_code = ble_sms_on_sensors_update(*m_app_ble_conf.ble_conn_handle,
                                                 m_app_ble_conf.ble_sms, m_sensors.values);
            if (err_code != NRF_SUCCESS && err_code != BLE_ERROR_INVALID_CONN_HANDLE &&
                    err_code != NRF_ERROR_INVALID_STATE
                    && err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING)
            {
                APP_ERROR_CHECK(err_code);
            }
            memcpy(m_sensors_previous.values, m_sensors.values,
                   sizeof(sensors_value_t) * SENSORS_COUNT);
        }
    }
}

/**@brief App Error handler (override the weak one)
 */
void app_error_fault_handler(uint32_t id, uint32_t pc, uint32_t info)
{
    __disable_irq();
    NRF_LOG_FINAL_FLUSH();

#ifdef DEBUG
    switch (id)
    {
        case NRF_FAULT_ID_SD_ASSERT:
            NRF_LOG_ERROR("SOFTDEVICE: ASSERTION FAILED");
            break;
        case NRF_FAULT_ID_APP_MEMACC:
            NRF_LOG_ERROR("SOFTDEVICE: INVALID MEMORY ACCESS");
            break;
        case NRF_FAULT_ID_SDK_ASSERT:
        {
            assert_info_t * p_info = (assert_info_t *)info;
            NRF_LOG_ERROR("ASSERTION FAILED at %s:%u", p_info->p_file_name,
                          p_info->line_num);
            break;
        }
        case NRF_FAULT_ID_SDK_ERROR:
        {
            error_info_t * p_info = (error_info_t *)info;
            NRF_LOG_ERROR("ERROR %u [%s] at %s:%u\r\nPC at: 0x%08x", p_info->err_code,
                          nrf_strerror_get(p_info->err_code), p_info->p_file_name, p_info->line_num, pc);
            NRF_LOG_ERROR("End of error report");
            break;
        }
        default:
            NRF_LOG_ERROR("UNKNOWN FAULT at 0x%08X", pc);
            break;
    }
    app_error_save_and_stop(id, pc, info);
    NRF_BREAKPOINT_COND;

#else
    NRF_LOG_WARNING("Fatal error, System reset");
    NRF_BREAKPOINT_COND;
    NVIC_SystemReset();
#endif // DEBUG
}

/**@brief Function for application main entry.
 */
int main(void)
{
    m_app_ble_conf.led_write_handler = led_write_handler;
    m_app_ble_conf.output_write_handler = output_write_handler;

    log_init();
    NRF_LOG_INFO("Initialization");
    leds_init();
    timers_init();
    buttons_init();
    power_management_init();
    sensors_init(&m_sensors);
    app_ble_init(&m_app_ble_conf);
    // sensors_init_buffer(&m_sensors_previous);

    NRF_LOG_INFO("Starting main process");

    for (;;)
    {
        idle_state_handle();
        check_sensors_update();
    }
}


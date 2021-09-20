/**
 * @file
 * @brief main: Top level module
 */

/*************************
 * Includes
 ************************/

// SDK
#include "app_button.h"
#include "app_error.h"
#include "app_timer.h"
#include "boards.h"
#include "nordic_common.h"
#include "nrf.h"
#include "nrf_delay.h"
#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"
#include "nrf_pwr_mgmt.h"
#include "nrf_sdm.h"
#include "nrf_delay.h"
// Project
#include "app_ble.h"
#include "sensor_handle.h"
#include "sensor_sampling.h"
//#include "sensors.h"

/*************************
 * Defines
 ************************/

// Is on when device is advertising
#define ADVERTISING_LED BSP_BOARD_LED_0
// Is on when device has connected
#define CONNECTED_LED BSP_BOARD_LED_1
// LED to be toggled with the help of the LED Button Service
#define LEDBUTTON_LED BSP_BOARD_LED_2
// Button that will trigger the notification event with the LED Button Service
// */
#define CONNECT_BUTTON BSP_BUTTON_0
// Delay from a GPIOTE event until a button is reported as pushed (in number of
// timer ticks)
#define BUTTON_DETECTION_DELAY APP_TIMER_TICKS(50)
// Value used as error code on stack dump, can be used to identify stack
// location on stack unwind
#define DEAD_BEEF 0xDEADBEEF

/*************************
 * Static Variables
 ************************/

// Handler for the app bluetooth
static app_ble_conf_t m_app_ble_conf;

// timer for the sensors
APP_TIMER_DEF(m_timer_sensors_id);

/*************************
 * Static Functions
 ************************/

static void blink(void)
{
 for (int i = 0; i < 2; i++)
    {
        nrf_gpio_pin_write(LED_BLUE_PIN, 0);
        nrf_delay_ms(40);
        nrf_gpio_pin_write(LED_BLUE_PIN, 1);
        nrf_delay_ms(40);
        nrf_gpio_pin_write(LED_RED_PIN, 0);
        nrf_delay_ms(40);
        nrf_gpio_pin_write(LED_RED_PIN, 1);
        nrf_delay_ms(40);
        nrf_gpio_pin_write(LED_GREEN_PIN, 0);
        nrf_delay_ms(40);
        nrf_gpio_pin_write(LED_GREEN_PIN, 1);
        nrf_delay_ms(40);
    }
}

/**
 * @brief    Handler for timer events.
 * @param[in] event_type Timer event (compare)
 * @param[in] p_context  Can be used to pass extra arguments to the handler
 */
static void timer_led_event_handler(
    nrf_timer_event_t event_type, void * p_context)
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


/**@brief     Function for handling write events to the LED characteristic.
 * @param[in] p_lbs     Instance of LED Button Service to which the write
 *                      applies.
 * @param[in] led_state Written/desired state of the LED.
 */
static void led_write_handler(
    uint16_t conn_handle, ble_lbs_t * p_lbs, uint8_t led_state)
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

/**
 * @brief function to handler sensor control changer (from BLE char)
 *
 * @param[in] sensor      selected sensor
 * @param[in] sensor_ctrl sensor control handler with new value
 */
static void sensor_ctrl_update(sensor_t sensor, sensor_ctrl_t * ctrl)
{
    ret_code_t err;
    NRF_LOG_INFO("sensor %d sample period ms %d, gain %d, enable %d",
                 sensor + 1, ctrl->sample_period_ms, ctrl->gain, ctrl->enable);
    err = sensor_sampling_update_sensor_control(sensor, ctrl);
    if (err == NRF_ERROR_INVALID_DATA)
        NRF_LOG_INFO("invalid sensor_ctrl_t data");
}


/**@brief   Function for the LEDs initialization.
 *          Initializes all LEDs used by the application.
 */
static void leds_init(void)
{
    bsp_board_init(BSP_INIT_LEDS);
}


/**@brief   Function for the Timer initialization.
 *          Initializes the timer module.
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
            NRF_LOG_INFO("button state change.");
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

    // The array must be static because a pointer to it will be saved in the
    // button handler module.
    static app_button_cfg_t buttons[] =
    {
        {CONNECT_BUTTON, false, BUTTON_PULL, button_event_handler}
    };

    err_code =
        app_button_init(buttons, ARRAY_SIZE(buttons), BUTTON_DETECTION_DELAY);
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
 * @details If there is no pending log operation, then sleep until next the next
 * event occurs.
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
static void check_sensors_update(void)
{
    if (!app_ble_is_connected()) return;

    ret_code_t err_code;
    for (sensor_t s_i = SENSOR_FIRST; s_i <= SENSOR_LAST; s_i++)
    {
        if (sensor_handle_available_data(s_i) >= SENSOR_VAL_AMOUNT_NOTIF)
        {
            err_code = ble_sms_on_sensors_update(
                           *m_app_ble_conf.ble_conn_handle, m_app_ble_conf.ble_sms, s_i);

            if (err_code != NRF_SUCCESS &&
                    err_code != BLE_ERROR_INVALID_CONN_HANDLE &&
                    err_code != NRF_ERROR_INVALID_STATE &&
                    err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING)
            {
                //APP_ERROR_CHECK(err_code);
            }
        }
    }
}

/**@brief App Error handler (override the weak one)
 *
 * @param[in] id    id of the group of error(soft dev error, sdk error, etc..)
 * @param[in] pc    program counter
 * @param[in] info  address that point to a error info type
 *                  (type depending on the id)
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
            NRF_LOG_ERROR("ERROR %u [%s] at %s:%u\r\nPC at: 0x%08x",
                          p_info->err_code, nrf_strerror_get(p_info->err_code),
                          p_info->p_file_name, p_info->line_num, pc);
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

/*************************
 * Public Functions
 ************************/

/**@brief Function for assert macro callback.
 * @details This function will be called in case of an assert in the SoftDevice.
 * @warning This handler is an example only and does not fit a final product.
 *          You need to analyze how your product is supposed to react in case of
 * Assert.
 * @warning On assert from the SoftDevice, the system can only recover on reset.
 * @param[in] line_num    Line number of the failing ASSERT call.
 * @param[in] p_file_name File name of the failing ASSERT call.
 */
void assert_nrf_callback(uint16_t line_num, const uint8_t * p_file_name)
{
    app_error_handler(DEAD_BEEF, line_num, p_file_name);
}


/*************************
 * Main Function
 ************************/

/**@brief Function for application main entry.
 */
int main(void)
{
    m_app_ble_conf.sensor_ctrl_write = sensor_ctrl_update;

    log_init();
    NRF_LOG_INFO("Initialization");
    leds_init();
    timers_init();
    buttons_init();
    power_management_init();

    blink();

    sensor_sampling_init();
    app_ble_init(&m_app_ble_conf);

    NRF_LOG_INFO("Starting main process");

    for (;;)
    {
        idle_state_handle();
        check_sensors_update();
    }
}
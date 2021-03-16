#include "sensor_sampling.h"

#include "app_error.h"
#include "boards.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"
#include "nrf_log.h"
#include "nrfx_ppi.h"
#include "nrfx_rng.h"
#include "nrfx_saadc.h"
#include "nrfx_timer.h"
#include "sensor_handle.h"


#if (MOCK_ADC)
#include "nrf_drv_rng.h"
#endif

#define SAMPLES_IN_BUFFER SENSORS_COUNT
#define SAMPLE_RATE_MS 1000

static const nrfx_timer_t saadc_timer_instance = NRFX_TIMER_INSTANCE(2);

static int mock_adc;

void saadc_callback(nrfx_saadc_evt_t const * p_event)
{
    NRF_LOG_INFO("saadc_callback, p_event->type = %d", p_event->type);
}

ret_code_t saadc_config_channel(sensor_t sensor, sensor_ctrl_t * ctrl)
{
    sensor_hardware_t * hardware;
    nrf_saadc_channel_config_t conf =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NULL);
    hardware = get_sensor_hardware(sensor);
    conf.pin_p = hardware->analog_input;
    conf.gain = SAADC_CH_CONFIG_GAIN_Gain1_6;
    conf.reference = NRF_SAADC_REFERENCE_INTERNAL;
    return nrfx_saadc_channel_init(hardware->adc_chanel, &conf);
}

ret_code_t saadc_init(void)
{
    ret_code_t err;

    static nrfx_saadc_config_t default_config = NRFX_SAADC_DEFAULT_CONFIG;
    default_config.resolution = NRF_SAADC_RESOLUTION_12BIT;

    err = nrfx_saadc_init(&default_config, saadc_callback);
    APP_ERROR_CHECK(err);

    sensor_hardware_t * hardware;
    nrf_saadc_channel_config_t conf =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NULL);

    for (sensor_t s_i = SENSOR_FIRST; s_i <= SENSOR_LAST; s_i++)
    {
        sensor_ctrl_t * ctrl = get_sensor_ctrl(s_i);
        hardware = get_sensor_hardware(s_i);
        err = saadc_config_channel(s_i, ctrl);
        APP_ERROR_CHECK(err);
        NRF_LOG_INFO("sensor %d pwr_pin %d", s_i + 1, hardware->pwr_pin);
        nrf_gpio_cfg_output(hardware->pwr_pin);
    }

    return NRF_SUCCESS;
}

ret_code_t saadc_change_gain(void) { return NRF_SUCCESS; }

ret_code_t update_sensor_control(
    sensor_t sensor, sensor_ctrl_t * new_sensor_ctrl)
{
    ret_code_t err;
    sensor_hardware_t * hardware = get_sensor_hardware(sensor);
    err = nrfx_saadc_channel_uninit(hardware->adc_chanel);
    APP_ERROR_CHECK(err);
    err = saadc_config_channel(sensor, new_sensor_ctrl);
    APP_ERROR_CHECK(err);
    return NRF_SUCCESS;
}

void sample_one_sensor(sensor_t sensor)
{
    ret_code_t err;
    nrf_saadc_value_t adc_val;
    sensor_hardware_t * hardware = get_sensor_hardware(sensor);
    nrf_gpio_pin_set(hardware->pwr_pin);
    nrf_delay_ms(1);
    err = nrfx_saadc_sample_convert(hardware->adc_chanel, &adc_val);
    APP_ERROR_CHECK(err);
    err = add_sensor_value(sensor, adc_val);
    APP_ERROR_CHECK(err);
    nrf_gpio_pin_clear(hardware->pwr_pin);
}

void sample_all_sensors(void)
{
    ret_code_t err;

    sample_one_sensor(SENSOR_1);

    // err = nrfx_saadc_sample_convert(SENSOR_2_ADC_CHANNEL, &adc_val);
    err = add_sensor_value(SENSOR_2, mock_adc++);
    APP_ERROR_CHECK(err);

    // err = nrfx_saadc_sample_convert(SENSOR_3_ADC_CHANNEL, &adc_val);
    err = add_sensor_value(SENSOR_3, 0);
    APP_ERROR_CHECK(err);

    // err = nrfx_saadc_sample_convert(SENSOR_4_ADC_CHANNEL, &adc_val);
    err = add_sensor_value(SENSOR_4, 0);
    APP_ERROR_CHECK(err);
}


void saadc_timer_handler(nrf_timer_event_t event_type, void * p_context)
{
    switch (event_type)
    {
        case NRF_TIMER_EVENT_COMPARE0:
            sample_all_sensors();
            break;

        default:
            break;
    }
}


ret_code_t saadc_timer_init(void)
{
    ret_code_t err_code;
    nrfx_timer_config_t timer_conf = NRFX_TIMER_DEFAULT_CONFIG;
    timer_conf.bit_width = NRF_TIMER_BIT_WIDTH_32;
    err_code = nrfx_timer_init(
        &saadc_timer_instance, &timer_conf, saadc_timer_handler);
    APP_ERROR_CHECK(err_code);

    uint32_t time_ticks =
        nrfx_timer_ms_to_ticks(&saadc_timer_instance, SAMPLE_RATE_MS);

    nrfx_timer_extended_compare(&saadc_timer_instance, NRF_TIMER_CC_CHANNEL0,
        time_ticks, NRF_TIMER_SHORT_COMPARE0_CLEAR_MASK, true);

    nrfx_timer_enable(&saadc_timer_instance);
}


ret_code_t sensor_sampling_init(void)
{
#if (MOCK_ADC)
    random_vector_generate_init();
#else

    mock_adc = 0;
    init_sensor_handles();
    // init_sensor_buffer();
    saadc_init();
    saadc_timer_init();
#endif
    return NRF_SUCCESS;
}


#if (MOCK_ADC)
static uint8_t random_vector_generate(uint8_t * p_buff, uint8_t size)
{
    uint32_t err_code;
    uint8_t available;
    nrf_drv_rng_bytes_available(&available);
    uint8_t length = MIN(size, available);
    err_code = nrf_drv_rng_rand(p_buff, length);
    APP_ERROR_CHECK(err_code);
    return length;
}


void random_vector_generate_init(void)
{
    uint32_t err_code;
    err_code = nrf_drv_rng_init(NULL);
    APP_ERROR_CHECK(err_code);
}

void mock_sensor_values(sensors_t * sensors)
{
    uint8_t randoms[SENSORS_COUNT];
    random_vector_generate(randoms, SENSORS_COUNT);
    for (int i = 0; i < SENSORS_COUNT; i++)
        sensors->values[i] = randoms[i];
}
#endif
#include "sensor_sampling.h"

#include "boards.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"
#include "nrf_log.h"
#include "nrfx_ppi.h"
#include "nrfx_rng.h"
#include "nrfx_saadc.h"
#include "nrfx_timer.h"


#include "app_error.h"

#if (MOCK_ADC)
#include "nrf_drv_rng.h"
#endif

#define SAMPLES_IN_BUFFER SENSORS_COUNT
#define SAMPLE_RATE_MS 200

static sensors_t * m_sensors;
static const nrfx_timer_t saadc_timer_instance = NRFX_TIMER_INSTANCE(2);


void saadc_callback(nrfx_saadc_evt_t const * p_event)
{
    NRF_LOG_INFO("saadc_callback, p_event->type = %d", p_event->type);
}


ret_code_t saadc_init(void)
{
    ret_code_t err_code;

    static nrfx_saadc_config_t default_config = NRFX_SAADC_DEFAULT_CONFIG;
    default_config.resolution = NRF_SAADC_RESOLUTION_12BIT;

    err_code = nrfx_saadc_init(&default_config, saadc_callback);
    APP_ERROR_CHECK(err_code);

    // nrf_saadc_channel_config_t channel_2_config =
    //    NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN2);
    // err_code = nrfx_saadc_channel_init(2, &channel_2_config);
    // APP_ERROR_CHECK(err_code);

    // nrf_saadc_channel_config_t channel_3_config =
    //    NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN3);
    // err_code = nrfx_saadc_channel_init(3, &channel_3_config);
    // APP_ERROR_CHECK(err_code);

    // nrf_saadc_channel_config_t channel_4_config =
    //    NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN4);
    // err_code = nrfx_saadc_channel_init(4, &channel_4_config);


    nrf_saadc_channel_config_t channel_6_config =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN6);

    channel_6_config.gain = SAADC_CH_CONFIG_GAIN_Gain1_6;
    // channel_6_config.reference = NRF_SAADC_REFERENCE_VDD4;
    channel_6_config.reference = NRF_SAADC_REFERENCE_INTERNAL;
    err_code = nrfx_saadc_channel_init(6, &channel_6_config);

    APP_ERROR_CHECK(err_code);

    nrf_gpio_cfg_output(SENSOR_1_PWR_PIN);

    return err_code;
}

static int temp_i = 0;

void make_a_conversion(void)
{
    ret_code_t err_code;
    nrf_saadc_value_t adc_val;


    err_code = nrfx_saadc_sample_convert(NRF_SAADC_INPUT_AIN2, &adc_val);
    //NRF_LOG_INFO("ADC 2 val = %d ", adc_val);
    m_sensors->values[1] = 0;

    err_code = nrfx_saadc_sample_convert(NRF_SAADC_INPUT_AIN3, &adc_val);
    //NRF_LOG_INFO("ADC 3 val = %d ", adc_val);
    m_sensors->values[2] = 0;

    err_code = nrfx_saadc_sample_convert(NRF_SAADC_INPUT_AIN4, &adc_val);
    //NRF_LOG_INFO("ADC 4 val = %d ", adc_val);
    m_sensors->values[3] = 0;

    nrf_gpio_pin_set(SENSOR_1_PWR_PIN);
    nrf_delay_ms(10);

    err_code = nrfx_saadc_sample_convert(NRF_SAADC_INPUT_AIN6, &adc_val);
    //NRF_LOG_INFO("ADC 6 val = %d ", adc_val);

    m_sensors->values[0] = adc_val;

    nrf_gpio_pin_clear(SENSOR_1_PWR_PIN);
}


void saadc_timer_handler(nrf_timer_event_t event_type, void * p_context)
{
    switch (event_type)
    {
        case NRF_TIMER_EVENT_COMPARE0:
            make_a_conversion();
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
    err_code = nrfx_timer_init(&saadc_timer_instance, &timer_conf, saadc_timer_handler);
    APP_ERROR_CHECK(err_code);

    uint32_t time_ticks = nrfx_timer_ms_to_ticks(&saadc_timer_instance, SAMPLE_RATE_MS);

    nrfx_timer_extended_compare(&saadc_timer_instance, NRF_TIMER_CC_CHANNEL0, time_ticks,
        NRF_TIMER_SHORT_COMPARE0_CLEAR_MASK, true);

    nrfx_timer_enable(&saadc_timer_instance);
}


ret_code_t sensors_init(sensors_t * p_sensors)
{
#if (MOCK_ADC)
    random_vector_generate_init();
#else
    m_sensors = p_sensors;
    saadc_init();
    saadc_timer_init();
#endif
    return NRF_SUCCESS;
}


#if (0)

static const nrfx_timer_t m_timer = NRFX_TIMER_INSTANCE(2);
static nrf_saadc_value_t m_buffer_pool[2][SENSORS_COUNT];
static nrf_ppi_channel_t m_ppi_channel;
static sensors_t * m_sensors;


void sensors_init_buffer(sensors_t * p_sensors)
{
    p_sensors->names = sensors_string;
    memset(p_sensors->values, 0, sizeof(sensors_value_t) * SENSORS_COUNT);
}


ret_code_t sensors_init(sensors_t * p_sensors)
{
    m_sensors = p_sensors;
    sensors_init_buffer(m_sensors);

    saadc_init();
    saadc_sampling_event_init();
    saadc_sampling_event_enable();

#if (MOCK_ADC)
    random_vector_generate_init();
#endif

    return NRF_SUCCESS;
}


void timer_handler(nrf_timer_event_t event_type, void * p_context)
{
    NRF_LOG_INFO("timer_handler");
}


void saadc_sampling_event_init(void)
{
    ret_code_t err_code;

    nrfx_timer_config_t timer_cfg = NRFX_TIMER_DEFAULT_CONFIG;
    timer_cfg.bit_width = NRF_TIMER_BIT_WIDTH_32;
    err_code = nrfx_timer_init(&m_timer, &timer_cfg, timer_handler);
    APP_ERROR_CHECK(err_code);

    /* setup m_timer for compare event every SAMPLE_RATE_MS ms */
    uint32_t ticks = nrfx_timer_ms_to_ticks(&m_timer, SAMPLE_RATE_MS);
    nrfx_timer_extended_compare(
        &m_timer, NRF_TIMER_CC_CHANNEL0, ticks, NRF_TIMER_SHORT_COMPARE0_CLEAR_MASK, false);
    nrfx_timer_enable(&m_timer);

    uint32_t timer_compare_event_addr =
        nrfx_timer_compare_event_address_get(&m_timer, NRF_TIMER_CC_CHANNEL0);
    uint32_t saadc_sample_task_addr = nrfx_saadc_sample_task_get();

    /* setup ppi channel so that timer compare event is triggering sample task in SAADC */
    err_code = nrfx_ppi_channel_alloc(&m_ppi_channel);
    APP_ERROR_CHECK(err_code);

    err_code =
        nrfx_ppi_channel_assign(m_ppi_channel, timer_compare_event_addr, saadc_sample_task_addr);
    APP_ERROR_CHECK(err_code);
}


void saadc_sampling_event_enable(void)
{
    ret_code_t err_code = nrfx_ppi_channel_enable(m_ppi_channel);
    APP_ERROR_CHECK(err_code);
}


void saadc_callback(nrfx_saadc_evt_t const * p_event)
{
    NRF_LOG_INFO("saadc_callback");

    if (p_event->type == NRFX_SAADC_EVT_DONE)
    {
        ret_code_t err_code;
        err_code = nrfx_saadc_buffer_convert(p_event->data.done.p_buffer, SAMPLES_IN_BUFFER);
        APP_ERROR_CHECK(err_code);
#if (!MOCK_ADC)
        for (int i = 0; i < SAMPLES_IN_BUFFER; i++)
        {
            m_sensors->values[i] = (sensors_value_t)p_event->data.done.p_buffer[i];
            NRF_LOG_INFO("m_sensors->values[%d] %d", i, m_sensors->values[i]);
        }
#else
        mock_sensor_values(m_sensors);
        // for (int i = 0; i < SAMPLES_IN_BUFFER; i++)
        // NRF_LOG_INFO("m_sensors->values[%d] %d", i, m_sensors->values[i]);
#endif
    }
}


void saadc_init(void)
{
    ret_code_t err_code;

    static const nrfx_saadc_config_t default_config = NRFX_SAADC_DEFAULT_CONFIG;
    err_code = nrfx_saadc_init(&default_config, saadc_callback);
    APP_ERROR_CHECK(err_code);

    nrf_saadc_channel_config_t channel_0_config =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN0);
    err_code = nrfx_saadc_channel_init(0, &channel_0_config);
    APP_ERROR_CHECK(err_code);

    nrf_saadc_channel_config_t channel_1_config =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN1);
    err_code = nrfx_saadc_channel_init(1, &channel_1_config);
    APP_ERROR_CHECK(err_code);

    nrf_saadc_channel_config_t channel_2_config =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN2);
    err_code = nrfx_saadc_channel_init(2, &channel_2_config);
    APP_ERROR_CHECK(err_code);

    nrf_saadc_channel_config_t channel_3_config =
        NRFX_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN3);
    err_code = nrfx_saadc_channel_init(3, &channel_3_config);
    APP_ERROR_CHECK(err_code);

    err_code = nrfx_saadc_buffer_convert(m_buffer_pool[0], SAMPLES_IN_BUFFER);
    APP_ERROR_CHECK(err_code);

    err_code = nrfx_saadc_buffer_convert(m_buffer_pool[1], SAMPLES_IN_BUFFER);
    APP_ERROR_CHECK(err_code);
}
#endif

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
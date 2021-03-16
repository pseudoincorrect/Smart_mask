#include "sensor_handle.h"
#include "nrf_log.h"
#include "nrf_ringbuf.h"
#include "nrf_saadc.h"
#include "boards.h"
#include <string.h>

#define SENSOR_BUFF_SIZE 256 // needs to be a power of 2

static sensor_handle_t s_h_1, s_h_2, s_h_3, s_h_4;

NRF_RINGBUF_DEF(s_1_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_2_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_3_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_4_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));

static sensor_handle_t * get_sensor_handle(sensor_t sensor)
{
    switch (sensor)
    {
        case (SENSOR_1):
            return &s_h_1;
        case (SENSOR_2):
            return &s_h_2;
        case (SENSOR_3):
            return &s_h_3;
        case (SENSOR_4):
            return &s_h_4;
    }
}

static int buf_available_data(const nrf_ringbuf_t * buf)
{
    return buf->p_cb->wr_idx - buf->p_cb->rd_idx;
}

static const nrf_ringbuf_t * get_sensor_buffer(sensor_t sensor)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    return s_h->buffer;
}

void init_sensor_handles(void)
{
    s_h_1.buffer = &s_1_data;
    s_h_2.buffer = &s_2_data;
    s_h_3.buffer = &s_3_data;
    s_h_4.buffer = &s_4_data;

    nrf_ringbuf_init(s_h_1.buffer);
    nrf_ringbuf_init(s_h_2.buffer);
    nrf_ringbuf_init(s_h_3.buffer);
    nrf_ringbuf_init(s_h_4.buffer);

    sensor_ctrl_t * ctrl;
    for (sensor_t s_i = SENSOR_FIRST; s_i <= SENSOR_LAST; s_i++)
    {
        ctrl = get_sensor_ctrl(s_i);
        ctrl->gain = SAADC_CH_CONFIG_GAIN_Gain1_6;
        ctrl->enable = true;
        ctrl->frequency = 100; // ms
    }

    s_h_1.hardware.pwr_pin      = SENSOR_1_PWR_PIN;
    s_h_1.hardware.adc_pin      = SENSOR_1_ADC_PIN;
    s_h_1.hardware.adc_chanel   = SENSOR_1_ADC_CHANNEL;
    s_h_1.hardware.analog_input = SENSOR_1_ANALOG_INPUT;
    
    s_h_2.hardware.pwr_pin      = SENSOR_2_PWR_PIN;
    s_h_2.hardware.adc_pin      = SENSOR_2_ADC_PIN;
    s_h_2.hardware.adc_chanel   = SENSOR_2_ADC_CHANNEL;
    s_h_2.hardware.analog_input = SENSOR_2_ANALOG_INPUT;

    s_h_3.hardware.pwr_pin      = SENSOR_3_PWR_PIN;
    s_h_3.hardware.adc_pin      = SENSOR_3_ADC_PIN;
    s_h_3.hardware.adc_chanel   = SENSOR_3_ADC_CHANNEL;
    s_h_3.hardware.analog_input = SENSOR_3_ANALOG_INPUT;

    s_h_4.hardware.pwr_pin      = SENSOR_4_PWR_PIN;
    s_h_4.hardware.adc_pin      = SENSOR_4_ADC_PIN;
    s_h_4.hardware.adc_chanel   = SENSOR_4_ADC_CHANNEL;
    s_h_4.hardware.analog_input = SENSOR_4_ANALOG_INPUT;
}

sensor_hardware_t * get_sensor_hardware(sensor_t sensor)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    return &s_h->hardware;
}

sensor_ctrl_t * get_sensor_ctrl(sensor_t sensor)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    return &s_h->control;
}

ret_code_t set_sensor_ctrl(sensor_t sensor, sensor_ctrl_t * sensor_ctrl)
{
    uint32_t freq = sensor_ctrl->frequency;
    if (freq < 10 || freq > 1000)
        return NRF_ERROR_INVALID_DATA;

    uint8_t gain = sensor_ctrl->gain;
    if (gain < NRF_SAADC_GAIN1_6 || gain > NRF_SAADC_GAIN4)
        return NRF_ERROR_INVALID_DATA;

    sensor_ctrl_t * sensor_ctrl_dest = get_sensor_ctrl(sensor);
    memcpy(sensor_ctrl_dest, sensor_ctrl, sizeof(sensor_ctrl_t));
    return NRF_SUCCESS;
}

int available_sensor_data(sensor_t sensor)
{
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    return buf_available_data(buf) / sizeof(sensor_val_t);
}

ret_code_t add_sensor_value(sensor_t sensor, sensor_val_t val)
{
    ret_code_t err;
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    size_t len = sizeof(sensor_val_t);

    uint8_t * data_p;
    uint8_t ** data_pp = &data_p;

    err = nrf_ringbuf_alloc(buf, data_pp, &len, false);
    if (err != NRF_SUCCESS || len != sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;

    err = nrf_ringbuf_cpy_put(buf, (uint8_t *)&val, &len);
    if (err != NRF_SUCCESS || len != sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;

    return NRF_SUCCESS;
}

ret_code_t get_sensor_values(sensor_t sensor, sensor_val_t * vals, uint8_t amount)
{
    ret_code_t err;
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    size_t len = amount * sizeof(sensor_val_t);

    if (buf_available_data(buf) < len)
        return NRF_ERROR_DATA_SIZE;
    
    err = nrf_ringbuf_cpy_get(buf, (uint8_t *)vals, &len);
    if (len != amount * sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;
    
    return err;
}
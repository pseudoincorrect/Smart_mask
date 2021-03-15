#include "sensor_handle.h"
#include <string.h>
#include "nrf_saadc.h"
#include "nrf_ringbuf.h"

static sensor_handle_t s_h_1, s_h_2, s_h_3, s_h_4;

static sensor_buffer_t s_b_1, s_b_2, s_b_3, s_b_4;

//NRF_RINGBUF_DEF(s_1_buff, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
//NRF_RINGBUF_DEF(s_2_buff, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
//NRF_RINGBUF_DEF(s_3_buff, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
//NRF_RINGBUF_DEF(s_4_buff, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));

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

void init_sensor_handles(void)
{
    s_h_1.sensor_buffer = &s_b_1;
    s_h_2.sensor_buffer = &s_b_2;
    s_h_3.sensor_buffer = &s_b_3;
    s_h_4.sensor_buffer = &s_b_4;
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

sensor_buffer_t * get_sensor_buffer(sensor_t sensor)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    return s_h->sensor_buffer;
}


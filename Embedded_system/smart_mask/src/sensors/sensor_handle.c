#include <string.h>
#include "sensor_handle.h"
#include "nrf_saadc.h"

static sensor_handles_arr_t s_h;
static sensor_handle_t s_h_1, s_h_2, s_h_3, s_h_4;

static sensor_handle_t * get_sensor_handle(sensor_t sensor)
{
    switch (sensor)
    {
        case (SENSOR_1):
            return s_h.s1;

        case (SENSOR_2):
            return s_h.s2;

        case (SENSOR_3):
            return s_h.s3;

        case (SENSOR_4):
            return s_h.s4;
    }
}

void init_sensor_handles(void)
{
    s_h.s1 = &s_h_1;
    s_h.s2 = &s_h_2;
    s_h.s3 = &s_h_3;
    s_h.s4 = &s_h_4;
}

void get_sensor_ctrl(sensor_t sensor, sensor_ctrl_t * sensor_ctrl)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    sensor_ctrl = &s_h->control;
}

ret_code_t set_sensor_ctrl(sensor_t sensor, sensor_ctrl_t * sensor_ctrl)
{
    sensor_ctrl_t * sensor_ctrl_dest;
    uint32_t freq = sensor_ctrl->frequency;
    if (freq < 10 || freq > 1000)
        return NRF_ERROR_INVALID_DATA;

    uint8_t gain = sensor_ctrl->gain;
    if (gain < NRF_SAADC_GAIN1_6 || gain > NRF_SAADC_GAIN4)
        return NRF_ERROR_INVALID_DATA;


    get_sensor_ctrl(sensor, sensor_ctrl_dest);
    memcpy(sensor_ctrl_dest, sensor_ctrl, sizeof(sensor_ctrl_t));
    return NRF_SUCCESS;
}

void get_sensor_buffer(sensor_t sensor, sensor_buffer_t * sensor_buffer)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    sensor_buffer = s_h->sensor_buffer;
}
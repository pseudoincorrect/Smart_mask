#include "sensor_handle.h"
#include <string.h>
#include "nrf_saadc.h"
#include "nrf_ringbuf.h"
#include "nrf_log.h"

#define SENSOR_BUFF_SIZE 8 // needs to be a power of 2

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

static const nrf_ringbuf_t * get_sensor_buffer(sensor_t sensor)
{
    sensor_handle_t * s_h = get_sensor_handle(sensor);
    return s_h->buffer;
}

int available_data(sensor_t sensor)
{
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    int avail =  buf->bufsize_mask + 1 - (buf->p_cb->wr_idx - buf->p_cb->rd_idx);
    return avail * sizeof(sensor_val_t);
}

static int buf_available_data(const nrf_ringbuf_t * buf)
{
    return buf->bufsize_mask + 1 - (buf->p_cb->wr_idx - buf->p_cb->rd_idx);
}

ret_code_t add_value(sensor_t sensor, sensor_val_t val)
{
    ret_code_t ret;
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    size_t len = sizeof(sensor_val_t);

    uint8_t * data_p;
    uint8_t ** data_pp;
    data_pp = &data_p;
    
    //NRF_LOG_INFO("nrf_ringbuf_alloc");
    ret = nrf_ringbuf_alloc(buf, data_pp, &len, false);
    if (ret != NRF_SUCCESS || len != sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;

    //NRF_LOG_INFO("nrf_ringbuf_cpy_put");
    ret = nrf_ringbuf_cpy_put(buf, (uint8_t*) &val, &len);
    //NRF_LOG_INFO("ret = %d", ret);
    if (ret != NRF_SUCCESS || len != sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;

    //NRF_LOG_INFO("add_value success");
    return NRF_SUCCESS;
}

ret_code_t get_values(sensor_t sensor, sensor_val_t * vals, uint8_t amount)
{
    ret_code_t ret;
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    if (buf_available_data(buf) < amount * sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;
    
    size_t len;
    ret = nrf_ringbuf_cpy_get(buf, (uint8_t*) vals, &len);
    if (ret != NRF_SUCCESS || len != amount)
        return NRF_ERROR_DATA_SIZE; 

    ret = nrf_ringbuf_free(buf, len);
    return ret;
}
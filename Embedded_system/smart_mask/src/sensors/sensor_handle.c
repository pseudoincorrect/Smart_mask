/**
 * @file
 * @brief sensor_handle: Module that manage the sensors and simplify their
 * access throughout other module (ble, adc, etc..). It takes care of the
 * sensor hardware config, the adc config and the buffer access.
 */

#include "sensor_handle.h"
#include "boards.h"
#include "nrf_log.h"
#include "nrf_ringbuf.h"
#include "nrf_saadc.h"
#include <string.h>

/*************************
 * Defines
 ************************/

#define SENSOR_BUFF_SIZE 256 // needs to be a power of 2

/*************************
 * Static Variables
 ************************/

static sensor_handle_t s_h_1, s_h_2, s_h_3, s_h_4;

NRF_RINGBUF_DEF(s_1_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_2_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_3_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));
NRF_RINGBUF_DEF(s_4_data, SENSOR_BUFF_SIZE * sizeof(sensor_val_t));

/*************************
 * Static Functions
 ************************/

/**
 * @brief   Get the handle for a particuliar sensr
 *
 * @param[in] sensor    Selected sensor
 *
 * @retval Pointer to a sensor handle
 */
static sensor_handle_t * sensor_handle_get(sensor_t sensor)
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

/**
 * @brief Check how many bytes a ring buffer has available
 *
 * @param[in] buf   Pointer to a ring buffer
 *
 * @retval The amount of available bytes of data
 */
static int sensor_handle_available_data_buf(const nrf_ringbuf_t * buf)
{
    return buf->p_cb->wr_idx - buf->p_cb->rd_idx;
}

/**
 * @brief Get the ring buffer for a particuliar sensor
 *
 * @param[in] sensor    Selected sensor
 *
 * @retval Pointer to the ring buffer for the selected sensor
 */
static const nrf_ringbuf_t * get_sensor_buffer(sensor_t sensor)
{
    sensor_handle_t * s_h = sensor_handle_get(sensor);
    return s_h->buffer;
}

/*************************
 * Public Functions
 ************************/

/**
 * @brief Link all the sensor handle to there control and buffer
 *  initialise the buffer and add the hardware config for each sensor
 */
void sensor_handles_init(void)
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
        ctrl = sensor_handle_get_control(s_i);
        //ctrl->gain = SAADC_CH_CONFIG_GAIN_Gain1_6;
        ctrl->gain = SAADC_CH_CONFIG_GAIN_Gain1_6;
        ctrl->enable = true;
        ctrl->sample_period_ms = 100; // ms
    }

    s_h_1.hardware.pwr_pin = SENSOR_1_PWR_PIN;
    s_h_1.hardware.adc_pin = SENSOR_1_ADC_PIN;
    s_h_1.hardware.adc_chanel = SENSOR_1_ADC_CHANNEL;
    s_h_1.hardware.analog_input = SENSOR_1_ANALOG_INPUT;

    s_h_2.hardware.pwr_pin = SENSOR_2_PWR_PIN;
    s_h_2.hardware.adc_pin = SENSOR_2_ADC_PIN;
    s_h_2.hardware.adc_chanel = SENSOR_2_ADC_CHANNEL;
    s_h_2.hardware.analog_input = SENSOR_2_ANALOG_INPUT;

    s_h_3.hardware.pwr_pin = SENSOR_3_PWR_PIN;
    s_h_3.hardware.adc_pin = SENSOR_3_ADC_PIN;
    s_h_3.hardware.adc_chanel = SENSOR_3_ADC_CHANNEL;
    s_h_3.hardware.analog_input = SENSOR_3_ANALOG_INPUT;

    s_h_4.hardware.pwr_pin = SENSOR_4_PWR_PIN;
    s_h_4.hardware.adc_pin = SENSOR_4_ADC_PIN;
    s_h_4.hardware.adc_chanel = SENSOR_4_ADC_CHANNEL;
    s_h_4.hardware.analog_input = SENSOR_4_ANALOG_INPUT;
}

/**
 * @brief Get the hardware handle for a particuliar sensor
 *
 * @param[in] sensor    Selected sensor
 *
 * @retval Pointer to the hardware handle for the selected sensor
 */
sensor_hardware_t * sensor_handle_get_hardware(sensor_t sensor)
{
    sensor_handle_t * s_h = sensor_handle_get(sensor);
    return &s_h->hardware;
}

/**
 * @brief Get the control handle for a particuliar sensor
 *
 * @param[in] sensor    Selected sensor
 *
 * @retval Pointer to the control handle for the selected sensor
 */
sensor_ctrl_t * sensor_handle_get_control(sensor_t sensor)
{
    sensor_handle_t * s_h = sensor_handle_get(sensor);
    return &s_h->control;
}

/**
 * @brief Set the control handle for a particuliar sensor
 *
 * @param[in] sensor      Selected sensor
 * @param[in] sensor_ctrl Pointer a new control handle to update the
 *                          old one
 *
 * @retval Pointer to the control handle for the selected sensor
 */
ret_code_t sensor_handle_set_control(
    sensor_t sensor, sensor_ctrl_t * sensor_ctrl)
{
    if (!is_sensor_ctrl_valid(sensor_ctrl))
        return NRF_ERROR_INVALID_DATA;

    sensor_ctrl_t * sensor_ctrl_dest = sensor_handle_get_control(sensor);
    memcpy(sensor_ctrl_dest, sensor_ctrl, sizeof(sensor_ctrl_t));
    return NRF_SUCCESS;
}

/**
 * @brief Check how many bytes a ring buffer has available for a particuliar
 * sensor
 *
 * @param[in] sensor    Selected sensor
 *
 * @retval The amount of available bytes of data
 */
int sensor_handle_available_data(sensor_t sensor)
{
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    return sensor_handle_available_data_buf(buf) / sizeof(sensor_val_t);
}

/**
 * @brief Add a value for a sensor into its ring buffer
 *
 * @param[in] sensor    Selected sensor
 * @param[in] val       sensor ADC value
 *
 * @retval NRF_SUCCESS on success, otherwise an error code is returned
 */
ret_code_t sensor_handle_add_value(sensor_t sensor, sensor_val_t val)
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

/**
 * @brief Get [amount] values (if available) from a particuliar sensor
 *
 * @param[in] sensor    Selected sensor
 * @param[out] vals     Pointer to a sensor value to be copied into
 * @param[in] amount    amount of value to be copied into vals
 *
 * @retval NRF_SUCCESS on success, otherwise an error code is returned
 */
ret_code_t sensor_handle_get_values(
    sensor_t sensor, sensor_val_t * vals, uint8_t amount)
{
    ret_code_t err;
    const nrf_ringbuf_t * buf = get_sensor_buffer(sensor);
    size_t len = amount * sizeof(sensor_val_t);

    if (sensor_handle_available_data_buf(buf) < len)
        return NRF_ERROR_DATA_SIZE;

    err = nrf_ringbuf_cpy_get(buf, (uint8_t *)vals, &len);
    if (len != amount * sizeof(sensor_val_t))
        return NRF_ERROR_DATA_SIZE;

    return err;
}

/**
 * @brief Validate a sensor control handle
 *
 * @param[in] ctrl  Pointer to a sensor control handle to be validated
 *
 * @retval true if valid, false otherwise
 */
bool is_sensor_ctrl_valid(sensor_ctrl_t * ctrl)
{
    if (ctrl->sample_period_ms < 200 || ctrl->sample_period_ms > 2000)
        return false;
    if (ctrl->gain < SAADC_CH_CONFIG_GAIN_Gain1_6 ||
        ctrl->gain > SAADC_CH_CONFIG_GAIN_Gain4)
        return false;
    return true;
}
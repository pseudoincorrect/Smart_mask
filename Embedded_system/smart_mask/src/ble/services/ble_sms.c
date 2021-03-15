// BLE SENSORS MEASUREMENT SERVICE

#include "ble_sms.h"
#include "ble_srv_common.h"
#include "sdk_common.h"
#include "nrf_log.h"
#include "sensor_handle.h"

/**@brief Function for handling the Write event.
 *
 * @param[in] p_sms      LED Button Service structure.
 * @param[in] p_ble_evt  Event received from the BLE stack.
 */
static uint32_t on_write(ble_sms_t * p_sms, ble_evt_t const * p_ble_evt)
{

    ble_gatts_evt_write_t const * p_evt_write =
        &p_ble_evt->evt.gatts_evt.params.write;

    if (p_evt_write->len != sizeof(sensor_ctrl_t))
        return NRF_ERROR_INVALID_DATA;

    sensor_t sensor;
    int16_t handle;

    if (handle == p_sms->s1_ctrl_char.value_handle)
        sensor = SENSOR_1;
    else if (handle == p_sms->s2_ctrl_char.value_handle)
        sensor = SENSOR_3;
    else if (handle == p_sms->s3_ctrl_char.value_handle)
        sensor = SENSOR_2;
    else if (handle == p_sms->s4_ctrl_char.value_handle)
        sensor = SENSOR_4;

    ASSERT(p_sms->sensor_ctrl_write_cb != NULL);
    p_sms->sensor_ctrl_write_cb(sensor, (sensor_ctrl_t *)p_evt_write->data);

    return NRF_SUCCESS;
}


void ble_sms_on_ble_evt(ble_evt_t const * p_ble_evt, void * p_context)
{
    ble_sms_t * p_sms = (ble_sms_t *)p_context;

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GATTS_EVT_WRITE:
            on_write(p_sms, p_ble_evt);
            break;
        default:
            break;
    }
}

uint32_t ble_sms_on_sensors_update(
    uint16_t conn_handle, ble_sms_t * p_sms, sensor_t sensor)
{
    uint16_t len = sizeof(sensor_val_t);
    ble_gatts_hvx_params_t params;
    memset(&params, 0, sizeof(params));
    params.type = BLE_GATT_HVX_NOTIFICATION;
    params.p_len = &len;

    sensor_buffer_t * buffer;
    buffer = get_sensor_buffer(sensor);
    //NRF_LOG_INFO("sensor %d buffer[0] = %d", sensor + 1, buffer->buffer[0]);

    params.p_data = (uint8_t *) &buffer->buffer[0];
    //NRF_LOG_INFO("sensor %d data[0] = %d", sensor + 1, (int16_t) *params.p_data);

    switch (sensor)
    {
        case (SENSOR_1):
            params.handle = p_sms->s1_val_char.value_handle;
            break;
        case (SENSOR_2):
            params.handle = p_sms->s2_val_char.value_handle;
            break;
        case (SENSOR_3):
            params.handle = p_sms->s3_val_char.value_handle;
            break;
        case (SENSOR_4):
            params.handle = p_sms->s4_val_char.value_handle;
            break;
    }


    //return NRF_SUCCESS;
    return sd_ble_gatts_hvx(conn_handle, &params);
}


static uint32_t add_sensor_vals_char(
    ble_sms_t * p_sms, uint16_t uuid, ble_gatts_char_handles_t * p_char_handle)
{
    uint32_t err_code;
    ble_add_char_params_t params;

    sensor_val_t sensors_init_values[SENSOR_BUFF_SIZE];
    memset(sensors_init_values, 0, sizeof(sensors_init_values));

    memset(&params, 0, sizeof(params));
    params.uuid = uuid;
    params.uuid_type = p_sms->uuid_type;
    params.max_len = sizeof(sensor_val_t) * SENSOR_BUFF_SIZE;
    params.init_len = sizeof(sensor_val_t) * SENSOR_BUFF_SIZE;
    params.char_props.read = 1;
    params.char_props.notify = 1;
    params.p_init_value = (uint8_t *)sensors_init_values;
    params.read_access = SEC_OPEN;
    params.cccd_write_access = SEC_OPEN;

    err_code =
        characteristic_add(p_sms->service_handle, &params, p_char_handle);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}


static uint32_t add_sensor_ctrl_char(ble_sms_t * p_sms, uint8_t uuid,
    ble_gatts_char_handles_t * p_char_handle, sensor_ctrl_t * sensor_ctrl)
{
    uint32_t err_code;
    ble_add_char_params_t params;

    memset(&params, 0, sizeof(params));
    params.uuid = uuid;
    params.uuid_type = p_sms->uuid_type;
    params.max_len = sizeof(sensor_ctrl_t);
    params.init_len = sizeof(sensor_ctrl_t);
    params.char_props.read = 1;
    params.char_props.write = 1;
    params.p_init_value = (uint8_t *)sensor_ctrl;
    params.read_access = SEC_OPEN;
    params.cccd_write_access = SEC_OPEN;

    err_code =
        characteristic_add(p_sms->service_handle, &params, p_char_handle);
    VERIFY_SUCCESS(err_code);

    return err_code;
}


uint32_t ble_sms_init(ble_sms_t * p_sms, const ble_sms_init_t * p_sms_init)
{
    uint32_t err_code;
    ble_uuid_t ble_uuid;
    ble_add_char_params_t params;

    // Initialize service struct
    p_sms->sensor_ctrl_write_cb = p_sms_init->sensor_ctrl_write_cb;

    // Add service
    ble_uuid128_t base_uuid = {SMS_UUID_BASE};

    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_sms->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_sms->uuid_type;
    ble_uuid.uuid = SMS_UUID_SERVICE;

    err_code = sd_ble_gatts_service_add(
        BLE_GATTS_SRVC_TYPE_PRIMARY, &ble_uuid, &p_sms->service_handle);
    VERIFY_SUCCESS(err_code);

    add_sensor_vals_char(
        p_sms, SMS_UUID_SENSOR_1_VALS_CHAR, &p_sms->s1_val_char);
    add_sensor_vals_char(
        p_sms, SMS_UUID_SENSOR_2_VALS_CHAR, &p_sms->s2_val_char);
    add_sensor_vals_char(
        p_sms, SMS_UUID_SENSOR_3_VALS_CHAR, &p_sms->s3_val_char);
    add_sensor_vals_char(
        p_sms, SMS_UUID_SENSOR_4_VALS_CHAR, &p_sms->s4_val_char);

    sensor_ctrl_t sensor_ctrl = {0};

    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_1_CTRL_CHAR,
        &p_sms->s1_ctrl_char, &sensor_ctrl);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_2_CTRL_CHAR,
        &p_sms->s2_ctrl_char, &sensor_ctrl);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_3_CTRL_CHAR,
        &p_sms->s3_ctrl_char, &sensor_ctrl);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_4_CTRL_CHAR,
        &p_sms->s4_ctrl_char, &sensor_ctrl);

    return err_code;
}
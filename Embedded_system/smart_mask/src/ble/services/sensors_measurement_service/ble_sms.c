// BLE SENSORS MEASUREMENT SERVICE

#include "ble_sms.h"

///**@brief Function for handling the Write event.
// *
// * @param[in] p_sms      LED Button Service structure.
// * @param[in] p_ble_evt  Event received from the BLE stack.
// */
//static void on_write(ble_sms_t * p_sms, ble_evt_t const * p_ble_evt)
//{
//    ble_gatts_evt_write_t const * p_evt_write =
//        &p_ble_evt->evt.gatts_evt.params.write;

//    if ((p_evt_write->handle == p_sms->output_char_handles.value_handle)
//            && (p_evt_write->len == 1)
//            && (p_sms->output_write_handler != NULL)
//       )
//    {
//        p_sms->output_write_handler(
//            p_ble_evt->evt.gap_evt.conn_handle, p_sms, p_evt_write->data[0]);
//    }
//}

/**@brief Function for handling the Write event.
 *
 * @param[in] p_sms      LED Button Service structure.
 * @param[in] p_ble_evt  Event received from the BLE stack.
 */
static void on_write(ble_sms_t * p_sms, ble_evt_t const * p_ble_evt)
{
    ble_gatts_evt_write_t const * p_evt_write =
        &p_ble_evt->evt.gatts_evt.params.write;

    switch(p_evt_write->handle)
    {
        case (p_sms->sensor_1_ctrl_char_handle.value_handle):
            
            break;
         
        case (p_sms->sensor_1_ctrl_char_handle.value_handle):
            
            break;
            
        case (p_sms->sensor_1_ctrl_char_handle.value_handle):
            
            break;
            
        case (p_sms->sensor_1_ctrl_char_handle.value_handle):
            
            break;

    }

    if ((p_evt_write->handle == p_sms->output_char_handles.value_handle)
            && (p_evt_write->len == 1)
            && (p_sms->output_write_handler != NULL)
       )
    {
        p_sms->output_write_handler(
            p_ble_evt->evt.gap_evt.conn_handle, p_sms, p_evt_write->data[0]);
    }
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


// uint32_t ble_sms_on_sensors_update(
//    uint16_t conn_handle, ble_sms_t * p_sms, sensors_value_t * values)
//{
//    ble_gatts_hvx_params_t params;
//    uint16_t len = sizeof(sensors_value_t) * SENSORS_COUNT;

//    memset(&params, 0, sizeof(params));
//    params.type = BLE_GATT_HVX_NOTIFICATION;
//    params.handle = p_sms->sensors_char_handles.value_handle;
//    params.p_data = (uint8_t *)values;
//    params.p_len = &len;

//    return sd_ble_gatts_hvx(conn_handle, &params);
//}


uint32_t ble_sms_on_sensors_update(
    uint16_t conn_handle, ble_sms_t * p_sms, sensor_handle_t * sensor)
{
    uint16_t len = sizeof(sensor_val_t) * SENSOR_BUFF_SIZE;
    ble_gatts_hvx_params_t params;
    memset(&params, 0, sizeof(params));
    params.type = BLE_GATT_HVX_NOTIFICATION;
    params.p_data = (uint8_t *)sensor->buffer;
    params.p_len = &len;

    switch (sensor->sensor)
    {
        case (SENSOR_1):
            params.handle = p_sms->sensor_1_val_char_handle.value_handle;
            break;

        case (SENSOR_2):
            params.handle = p_sms->sensor_2_val_char_handle.value_handle;
            break;

        case (SENSOR_3):
            params.handle = p_sms->sensor_3_val_char_handle.value_handle;
            break;

        case (SENSOR_4):
            params.handle = p_sms->sensor_4_val_char_handle.value_handle;
            break;
    }
    return sd_ble_gatts_hvx(conn_handle, &params);
}


static uint32_t add_sensor_vals_char(
    ble_sms_t * p_sms, uint16_t uuid, ble_gatts_char_handles_t * p_char_handle)
{
    uint32_t err_code;
    ble_add_char_params_t add_char_params;

    sensors_value_t sensors_init_values[SENSOR_BUFF_SIZE];
    memset(sensors_init_values, 0, sizeof(sensors_init_values));

    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid = uuid;
    add_char_params.uuid_type = p_sms->uuid_type;
    add_char_params.max_len = sizeof(sensors_value_t) * SENSOR_BUFF_SIZE;
    add_char_params.init_len = sizeof(sensors_value_t) * SENSOR_BUFF_SIZE;
    add_char_params.char_props.read = 1;
    add_char_params.char_props.notify = 1;
    add_char_params.p_init_value = (uint8_t *)sensors_init_values;
    add_char_params.read_access = SEC_OPEN;
    add_char_params.cccd_write_access = SEC_OPEN;

    err_code = characteristic_add(
                   p_sms->service_handle, &add_char_params, p_char_handle);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}


static uint32_t add_sensor_ctrl_char(ble_sms_t * p_sms, uint8_t uuid,
                                     ble_gatts_char_handles_t * p_char_handle, sensor_ctrl_t * sensor_ctrl)
{
    // uint32_t err_code;
    ble_add_char_params_t add_char_params;

    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid = uuid;
    add_char_params.uuid_type = p_sms->uuid_type;
    add_char_params.max_len = sizeof(sensor_ctrl_t);
    add_char_params.init_len = sizeof(sensor_ctrl_t);
    add_char_params.char_props.read = 1;
    add_char_params.char_props.write = 1;
    add_char_params.p_init_value = (uint8_t *)sensor_ctrl;
    add_char_params.read_access = SEC_OPEN;
    add_char_params.cccd_write_access = SEC_OPEN;

    err_code = characteristic_add(p_sms->service_handle, &add_char_params
                                  , p_char_handle);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}


uint32_t ble_sms_init(ble_sms_t * p_sms, const ble_sms_init_t * p_sms_init)
{
    uint32_t err_code;
    ble_uuid_t ble_uuid;
    ble_add_char_params_t add_char_params;

    // Initialize service struct
    p_sms->output_write_handler = p_sms_init->output_write_handler;

    // Add service
    ble_uuid128_t base_uuid = {SMS_UUID_BASE};

    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_sms->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_sms->uuid_type;
    ble_uuid.uuid = SMS_UUID_SERVICE;

    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY,
                                        &ble_uuid, &p_sms->service_handle);
    VERIFY_SUCCESS(err_code);

    add_sensor_vals_char(p_sms, SMS_UUID_SENSOR_1_VALS_CHAR,
                         &p_sms->sensor_1_val_char_handle);
    add_sensor_vals_char(p_sms, SMS_UUID_SENSOR_2_VALS_CHAR,
                         &p_sms->sensor_2_val_char_handle);
    add_sensor_vals_char(p_sms, SMS_UUID_SENSOR_3_VALS_CHAR,
                         &p_sms->sensor_3_val_char_handle);
    add_sensor_vals_char(p_sms, SMS_UUID_SENSOR_4_VALS_CHAR,
                         &p_sms->sensor_4_val_char_handle);

    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_1_CTRL_CHAR,
                         &p_sms->sensor_1_ctrl_char_handle);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_2_CTRL_CHAR,
                         &p_sms->sensor_2_ctrl_char_handle);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_3_CTRL_CHAR,
                         &p_sms->sensor_3_ctrl_char_handle);
    add_sensor_ctrl_char(p_sms, SMS_UUID_SENSOR_4_CTRL_CHAR,
                         &p_sms->sensor_4_ctrl_char_handle);

    return err_code;
}
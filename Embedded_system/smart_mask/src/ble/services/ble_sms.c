// BLE SENSORS MEASUREMENT SERVICE
/**
 * @file
 * @brief ble_sms (BLE SENSORS MEASUREMENT SERVICE): Module that manages
 * the sensor measurements bluetooth low energy service. take care of
 * the sensor data transfer and sensor control.
 */

/*************************
 * Includes
 ************************/

#include "ble_sms.h"
#include "app_error.h"
#include "ble_srv_common.h"
#include "nrf_log.h"
#include "sdk_common.h"
#include "sensor_handle.h"

/*************************
 * Static Functions
 ************************/

/**
 * @brief Add a sensor value characteristic
 *
 * @param[in] p_sms             pointer to sms service
 * @param[in] uuid              uuid to be used by the new characteristic
 * @param[in] p_char_handle     pointer to the function that will handle ble
 *                              characteristic event
 *
 * @retval NRF_SUCCESS on success, otherwise an error code is returned
 */
static uint32_t add_sensor_vals_char(
    ble_sms_t * p_sms, uint16_t uuid, ble_gatts_char_handles_t * p_char_handle)
{
    uint32_t err_code;
    ble_add_char_params_t params;

    sensor_val_t sensors_init_values[SENSOR_VAL_AMOUNT_NOTIF];
    memset(sensors_init_values, 0, sizeof(sensors_init_values));

    memset(&params, 0, sizeof(params));
    params.uuid = uuid;
    params.uuid_type = p_sms->uuid_type;
    params.max_len = sizeof(sensor_val_t) * SENSOR_VAL_AMOUNT_NOTIF;
    params.init_len = sizeof(sensor_val_t) * SENSOR_VAL_AMOUNT_NOTIF;
    // Characteristic Properties
    params.char_props.read = 1;
    params.char_props.notify = 1;
    // Attribute property
    // Yes, Characteristics and Attributes are redundant but the Bluetooth
    // specification oblige us to do so. Nordic devZone post:
    // Google: Devzone ble-characteristics-a-beginners-tutorial (long post)
    params.read_access = SEC_OPEN;
    params.cccd_write_access = SEC_OPEN;
    // Initial value
    params.p_init_value = (uint8_t *)sensors_init_values;

    err_code =
        characteristic_add(p_sms->service_handle, &params, p_char_handle);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}

/**
 * @brief Add a sensor control characteristic
 *
 * @param[in] p_sms             pointer to sms service
 * @param[in] uuid              uuid to be used by the new characteristic
 * @param[in] p_char_handle     pointer to the function that will handle ble
 *                              characteristic event
 *
 * @retval NRF_SUCCESS on success, otherwise an error code is returned
 */
static uint32_t add_sensor_ctrl_char(ble_sms_t * p_sms, uint8_t uuid,
    ble_gatts_char_handles_t * p_char_handle, sensor_t sensor)
{
    uint32_t err_code;
    ble_add_char_params_t params;

    sensor_ctrl_t ctrl;
    sensor_ctrl_t * sensor_ctrl_p = sensor_handle_get_control(sensor);
    memcpy(&ctrl, sensor_ctrl_p, sizeof(sensor_ctrl_t));

    memset(&params, 0, sizeof(params));
    params.uuid = uuid;
    params.uuid_type = p_sms->uuid_type;
    params.max_len = sizeof(sensor_ctrl_t);
    params.init_len = sizeof(sensor_ctrl_t);
    // Characteristic Properties
    params.char_props.read = 1;
    params.char_props.write = 1;
    // Attribute property
    // Yes, Characteristics and Attributes are redundant but the Bluetooth
    // specification oblige us to do so. Nordic devZone post:
    // Google: Devzone ble-characteristics-a-beginners-tutorial (long post)
    params.read_access = SEC_OPEN;
    params.write_access = SEC_OPEN;
    // Initial value
    params.p_init_value = (uint8_t *)&ctrl;

    err_code =
        characteristic_add(p_sms->service_handle, &params, p_char_handle);
    VERIFY_SUCCESS(err_code);

    return err_code;
}

/**
 * @brief Function for handling the Write event
 *
 * @param[in] p_sms      Sensor Measurement Service structure
 * @param[in] p_ble_evt  Event received from the BLE stack
 */
static uint32_t ble_sms_event_on_write(
    ble_sms_t * p_sms, ble_evt_t const * p_ble_evt)
{
    ble_gatts_evt_write_t const * p_evt_write =
        &p_ble_evt->evt.gatts_evt.params.write;

    if (p_evt_write->len != sizeof(sensor_ctrl_t)){
        NRF_LOG_INFO("ble_sms_event_on_write wrong length %d", p_evt_write->len);
        NRF_LOG_INFO("sizeof(sensor_ctrl_t) %d", sizeof(sensor_ctrl_t));
        return NRF_ERROR_INVALID_DATA;
    }

    sensor_t sensor;
    int16_t handle = p_evt_write->handle;

    if (handle == p_sms->s1_ctrl_char.value_handle)
        sensor = SENSOR_1;
    else if (handle == p_sms->s2_ctrl_char.value_handle)
        sensor = SENSOR_2;
    else if (handle == p_sms->s3_ctrl_char.value_handle)
        sensor = SENSOR_3;
    else if (handle == p_sms->s4_ctrl_char.value_handle)
        sensor = SENSOR_4;
    else
        return NRF_ERROR_INVALID_DATA;

    ASSERT(p_sms->sensor_ctrl_write_cb != NULL);
    p_sms->sensor_ctrl_write_cb(sensor, (sensor_ctrl_t *)p_evt_write->data);

    return NRF_SUCCESS;
}

/*************************
 * Public Functions
 ************************/

/**
 * @brief Function for handling the application's BLE stack events
 *
 * @details  This function handles all events from the BLE stack that are of
 * interest to the Sensor Measurement Service
 *
 * @param[in] p_ble_evt  Event received from the BLE stack.
 * @param[in] p_context  Sensor Measurement Service structure
 */
void ble_sms_on_ble_evt(ble_evt_t const * p_ble_evt, void * p_context)
{
    ble_sms_t * p_sms = (ble_sms_t *)p_context;

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GATTS_EVT_WRITE:
            ble_sms_event_on_write(p_sms, p_ble_evt);
            break;
        default:
            break;
    }
}

/**
 * @brief Get the (int16_t) value of a handle for a particular sensor
 *
 * @param[in] sensor  Selected sensor
 * @param[in] p_sms   Pointer to Sensor Measurement Service structure
 *
 * @retval the value of a handle or -1
 */
int16_t ble_sms_get_vals_char_handle(ble_sms_t * p_sms, sensor_t sensor)
{
    switch (sensor)
    {
        case (SENSOR_1):
            return p_sms->s1_val_char.value_handle;
            break;
        case (SENSOR_2):
            return p_sms->s2_val_char.value_handle;
            break;
        case (SENSOR_3):
            return p_sms->s3_val_char.value_handle;
            break;
        case (SENSOR_4):
            return p_sms->s4_val_char.value_handle;
            break;
    }
}

/**
 * @brief Function for sending a sensor notification.
 *
 * @param[in] conn_handle   Handle of the peripheral connection to which the
 *                          sensor state notification will be sent
 * @param[in] p_sms         Pointer to Sensor Measurement Service structure
 * @param[in] value         Pointer to sensor values
 *
 * @retval NRF_SUCCESS on success, otherwise an error code is returned
 */
uint32_t ble_sms_on_sensors_update(
    uint16_t conn_handle, ble_sms_t * p_sms, sensor_t sensor)
{
    static sensor_val_t vals[SENSOR_VAL_AMOUNT_NOTIF];
    ret_code_t ret;
    int16_t len = SENSOR_VAL_AMOUNT_NOTIF * sizeof(sensor_val_t);

    ble_gatts_hvx_params_t params;
    memset(&params, 0, sizeof(params));
    params.type = BLE_GATT_HVX_NOTIFICATION;
    params.p_len = &len;

    uint16_t amount = SENSOR_VAL_AMOUNT_NOTIF;
    ret = sensor_handle_get_values(sensor, vals, amount);
    APP_ERROR_CHECK(ret);

    params.p_data = (uint8_t *)vals;
    params.handle = ble_sms_get_vals_char_handle(p_sms, sensor);

    return sd_ble_gatts_hvx(conn_handle, &params);

    // if (sensor == SENSOR_2)
    //    NRF_LOG_INFO("sensor %d, first %d, last %d", sensor + 1,
    //        *(params.p_data + 1) << 8 | *(params.p_data + 0),
    //        *(params.p_data + 19) << 8 | *(params.p_data + 18));
}

/**
 * @brief Function for initializing the Sensor Measurement Service
 *
 * @param[out] p_sms      Sensor Measurement Service structure. This structure
 * must be supplied by the application. It is initialized by this function and
 * will later be used to identify this particular service instance
 * @param[in] p_sms_init  Information needed to initialize the service
 *
 * @retval NRF_SUCCESS If the service was initialized successfully. Otherwise,
 * an error code is returned
 */
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

    add_sensor_ctrl_char(
        p_sms, SMS_UUID_SENSOR_1_CTRL_CHAR, &p_sms->s1_ctrl_char, SENSOR_1);
    add_sensor_ctrl_char(
        p_sms, SMS_UUID_SENSOR_2_CTRL_CHAR, &p_sms->s2_ctrl_char, SENSOR_2);
    add_sensor_ctrl_char(
        p_sms, SMS_UUID_SENSOR_3_CTRL_CHAR, &p_sms->s3_ctrl_char, SENSOR_3);
    add_sensor_ctrl_char(
        p_sms, SMS_UUID_SENSOR_4_CTRL_CHAR, &p_sms->s4_ctrl_char, SENSOR_4);

    return err_code;
}
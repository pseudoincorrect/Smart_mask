// BLE SENSORS MEASUREMENT SERVICE

#ifndef BLE_SENSOR_MEAS_H__
#define BLE_SENSOR_MEAS_H__

#include <stdint.h>
#include <stdbool.h>
#include "ble.h"
#include "ble_srv_common.h"
#include "sdk_common.h"
#include "nrf_sdh_ble.h"
#include "app_error.h"
#include "sensor_def.h"

#define BLE_SMS_DEF(_name)          \
    static ble_sms_t _name;         \
    NRF_SDH_BLE_OBSERVER(           \
        _name##_obs,                \
        BLE_LBS_BLE_OBSERVER_PRIO,  \
        ble_sms_on_ble_evt,         \
        &_name)

#define SMS_UUID_BASE                                   \
    {                                                   \
        0x24, 0xD1, 0xBC, 0xEA, 0x5F, 0x78, 0x23, 0x15, \
        0xDE, 0xEF, 0x12, 0x12, 0x00, 0x00, 0x00, 0x00  \
    }

#define SMS_UUID_SERVICE      0x1600

//#define SMS_UUID_SENSORS_CHAR 0x1601
//#define SMS_UUID_OUTPUT_CHAR  0x1602

#define SMS_UUID_SENSOR_1_VALS_CHAR 0x1601
#define SMS_UUID_SENSOR_1_CTRL_CHAR 0x1602

#define SMS_UUID_SENSOR_2_VALS_CHAR 0x1603
#define SMS_UUID_SENSOR_2_CTRL_CHAR 0x1604

#define SMS_UUID_SENSOR_3_VALS_CHAR 0x1605
#define SMS_UUID_SENSOR_3_CTRL_CHAR 0x1606

#define SMS_UUID_SENSOR_4_VALS_CHAR 0x1607
#define SMS_UUID_SENSOR_4_CTRL_CHAR 0x1608


typedef struct ble_sms_s ble_sms_t;

//typedef void (*ble_sms_output_write_handler_t) (
//    uint16_t conn_handle, 
//    ble_sms_t * p_sms, 
//    uint8_t new_value );


typedef void (*ble_sms_sensor_ctrl_write_cb) (
    sensor_t sensor, 
    sensor_ctrl_t sensor_ctrl );


typedef struct 
{
    //ble_sms_output_write_handler_t output_write_handler;
    ble_sms_sensor_ctrl_write_cb sensor_ctrl_write_cb;
    sensor_ctrl_t sensor_ctrl[SENSORS_COUNT];
} 
ble_sms_init_t;

struct ble_sms_s
{
    // Handle of sensor measurements (as provided by the BLE stack)
    uint16_t service_handle;
    // UUID type for the SENSORS MEASUREMENT SERVICE
    uint8_t uuid_type;

    // Handles related to the Sensors value characteristic
    ble_gatts_char_handles_t sensor_1_val_char_handle;
    // Handles related to the Sensors value characteristic
    ble_gatts_char_handles_t sensor_2_val_char_handle;
    // Handles related to the Sensors value characteristic
    ble_gatts_char_handles_t sensor_3_val_char_handle;
    // Handles related to the Sensors value characteristic
    ble_gatts_char_handles_t sensor_4_val_char_handle;

    // Handles related to the Sensors control characteristic
    ble_gatts_char_handles_t sensor_1_ctrl_char_handle;
    // Handles related to the Sensors control characteristic
    ble_gatts_char_handles_t sensor_2_ctrl_char_handle;
    // Handles related to the Sensors control characteristic
    ble_gatts_char_handles_t sensor_3_ctrl_char_handle;
    // Handles related to the Sensors control characteristic
    ble_gatts_char_handles_t sensor_4_ctrl_char_handle;

    // Callback for sensor control characteristic write
    ble_sms_sensor_ctrl_write_cb sensor_ctrl_write_cb;

    //// Event handler to be called when the LED characteristic is written
    //ble_sms_output_write_handler_t output_write_handler; 
};

/**@brief Function for handling the application's BLE stack events.
 *
 * @details This function handles all events from the BLE stack that are of interest to the Sensor Measurement Service.
 *
 * @param[in] p_ble_evt  Event received from the BLE stack.
 * @param[in] p_context  Sensor Measurement Service structure.
 */
void ble_sms_on_ble_evt(ble_evt_t const * p_ble_evt, void * p_context);

/**@brief Function for sending a sensor notification.
 *
 ' @param[in] conn_handle   Handle of the peripheral connection to which the sensor state notification will be sent.
 * @param[in] p_sms         Sensor Measurement Service Button Service structure.
 * @param[in] value         Pointer to sensor values.
 *
 * @retval NRF_SUCCESS If the notification was sent successfully. Otherwise, an error code is returned.
 */
uint32_t ble_sms_on_sensors_update(uint16_t conn_handle, ble_sms_t * p_sms, sensors_value_t* values);

/**@brief Function for initializing the Sensor Measurement Service.
 *
 * @param[out] p_sms      Sensor Measurement Service structure. This structure must be supplied by
 *                        the application. It is initialized by this function and will later
 *                        be used to identify this particular service instance.
 * @param[in] p_sms_init  Information needed to initialize the service.
 *
 * @retval NRF_SUCCESS If the service was initialized successfully. Otherwise, an error code is returned.
 */
uint32_t ble_sms_init (ble_sms_t * p_sms, const ble_sms_init_t * p_sms_init);

#endif
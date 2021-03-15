#ifndef __app_ble_h__
#define __app_ble_h__

#include "ble_lbs.h"
#include "ble_sms.h"
#include "sdk_errors.h"

typedef struct
{
    // ble_lbs_led_write_handler_t led_write_handler;
    ble_sms_sensor_ctrl_write_cb sensor_ctrl_write;
    uint16_t * ble_conn_handle;
    ble_sms_t * ble_sms;
    ble_lbs_t * ble_lbs;
} app_ble_conf_t;

ret_code_t app_ble_init(app_ble_conf_t * app_ble_conf);

bool is_connected(void);

#endif
#ifndef __app_ble_h__
#define __app_ble_h__

/*************************
 * Includes
 ************************/

#include "ble_lbs.h"
#include "ble_sms.h"
#include "sdk_errors.h"

/*************************
 * Typedefs
 ************************/

typedef struct
{
    ble_sms_sensor_ctrl_write_cb sensor_ctrl_write;
    uint16_t * ble_conn_handle;
    ble_sms_t * ble_sms;
} app_ble_conf_t;

/*************************
 * Function Declarations
 ************************/

ret_code_t app_ble_init(app_ble_conf_t * app_ble_conf);

bool app_ble_is_connected(void);

#endif
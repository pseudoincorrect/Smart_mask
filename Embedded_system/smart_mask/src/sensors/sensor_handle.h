#ifndef __sensor_handle_h__
#define __sensor_handle_h__

/*************************
 * Includes
 ************************/

#include "sdk_errors.h"
#include "sensors.h"

/*************************
 * Function Declarations
 ************************/

void sensor_handles_init(void);

sensor_hardware_t * sensor_handle_get_hardware(sensor_t sensor);

sensor_ctrl_t * sensor_handle_get_control(sensor_t sensor);

ret_code_t sensor_handle_set_control(sensor_t sensor, sensor_ctrl_t * sensor_ctrl);

int sensor_handle_available_data(sensor_t sensor);

ret_code_t sensor_handle_add_value(sensor_t sensor, sensor_val_t val);

ret_code_t sensor_handle_get_values(sensor_t sensor, sensor_val_t * vals, uint8_t amount);

bool is_sensor_ctrl_valid(sensor_ctrl_t* ctrl);


#endif
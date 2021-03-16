#ifndef __sensor_handle_h__
#define __sensor_handle_h__

#include "sdk_errors.h"
#include "sensors.h"

void init_sensor_handles(void);

sensor_ctrl_t * get_sensor_ctrl(sensor_t sensor);

sensor_hardware_t * get_sensor_hardware(sensor_t sensor);

ret_code_t set_sensor_ctrl(sensor_t sensor, sensor_ctrl_t* sensor_ctrl);

int available_sensor_data(sensor_t sensor);

ret_code_t add_sensor_value(sensor_t sensor, sensor_val_t val);

ret_code_t get_sensor_values(sensor_t sensor, sensor_val_t * vals, uint8_t amount);

#endif
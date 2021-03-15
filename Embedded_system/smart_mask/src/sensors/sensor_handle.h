#ifndef __sensor_handle_h__
#define __sensor_handle_h__

#include "sdk_errors.h"
#include "sensors.h"

void init_sensor_handles(void);

sensor_ctrl_t * get_sensor_ctrl(sensor_t sensor);

ret_code_t set_sensor_ctrl(sensor_t sensor, sensor_ctrl_t* sensor_ctrl);

sensor_buffer_t * get_sensor_buffer(sensor_t sensor);

#endif
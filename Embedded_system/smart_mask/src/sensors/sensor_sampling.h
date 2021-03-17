#ifndef __SENSORS_H__
#define __SENSORS_H__

/*************************
 * Includes
 ************************/

#include "app_config.h"
#include "nrfx_saadc.h"
#include "nrfx_timer.h"
#include "sensors.h"

/*************************
 * Function Declarations
 ************************/

ret_code_t sensor_sampling_init(void);

ret_code_t sensor_sampling_update_sensor_control(
    sensor_t sensor, sensor_ctrl_t * new_sensor_ctrl);

#endif
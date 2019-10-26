#ifndef __SENSORS_H__
#define __SENSORS_H__

//Standard Libraries
#include <stdint.h>
// Common
#include "nrf.h"
// Log
#include "nrf_log.h"
// Error
#include "app_error.h"
// Drivers (nrf_drv_*, nrfx and others)
#include "nrf_drv_saadc.h"
#include "nrf_drv_ppi.h"
#include "nrf_drv_timer.h"

// SAADS 
#define SAMPLES_IN_BUFFER 5
// SENSORS
#define SENSORS_COUNT 4

#define FOREACH_SENSOR(SENSOR) \
    SENSOR(temperature) \
    SENSOR(humidity) \
    SENSOR(respiration) \
    SENSOR(acetone) 

#define  GENERATE_ENUM(ENUM) ENUM,

#define  GENERATE_STRING(STRING) #STRING,

typedef uint16_t sensors_values_t;
 
enum sensors_enum 
{
    FOREACH_SENSOR(GENERATE_ENUM)
};

static const char * sensors_string [] = 
{
    FOREACH_SENSOR(GENERATE_STRING)
};

typedef  struct 
{
    sensors_values_t values [SENSORS_COUNT];
    const char ** names;
} 
sensors_t;

ret_code_t sensors_init(sensors_t* p_sensors);
void sensors_saadc_callback(nrf_drv_saadc_evt_t const * p_event);
void sensors_timer_handler(nrf_timer_event_t event_type, void * p_context);
void sensors_sampling_event_init(void);
void sensors_sampling_event_enable(void);
void sensors_saadc_init(void);

#endif

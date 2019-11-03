#ifndef __SENSORS_H__
#define __SENSORS_H__

// app config
#include "app_config.h"
//Standard Libraries
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
// Log
#include "nrf_log.h"
// Error
#include "app_error.h"
// Drivers (nrf_drv_*, nrfx and others)
#include "nrf_drv_saadc.h"
#include "nrf_drv_ppi.h"
#include "nrf_drv_timer.h"
#if (MOCK_ADC)
#include "nrf_drv_rng.h"
#endif

// SENSORS
#define SENSORS_COUNT 4

#define FOREACH_SENSOR(SENSOR) \
    SENSOR(temperature) \
    SENSOR(humidity) \
    SENSOR(respiration) \
    SENSOR(acetone) 

#define  GENERATE_ENUM(ENUM) ENUM,

#define  GENERATE_STRING(STRING) #STRING,

typedef uint16_t sensors_value_t;
 
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
    sensors_value_t values [SENSORS_COUNT];
    const char ** names;
} 
sensors_t;

void sensors_init_buffer(sensors_t* p_sensors);
void saadc_callback(nrf_drv_saadc_evt_t const * p_event);
void saadc_init(void);
void saadc_sampling_event_enable(void);
void saadc_sampling_event_init(void);
ret_code_t sensors_init(sensors_t* p_sensors);
void timer_handler(nrf_timer_event_t event_type, void * p_context);
void update_sensor_values(sensors_t* sensors);
#if (MOCK_ADC)
static uint8_t random_vector_generate(uint8_t * p_buff, uint8_t size);
void random_vector_generate_init(void); 
void mock_sensor_values(sensors_t* sensors); 
#endif

#endif

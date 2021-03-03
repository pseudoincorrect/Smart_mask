#ifndef __SENSORS_H__
#define __SENSORS_H__

// app config
#include "app_config.h"
//Standard Libraries
#include "nrfx_saadc.h"
#include "nrfx_timer.h"

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
void saadc_callback(nrfx_saadc_evt_t const * p_event);
//void saadc_callback(nrf_drv_saadc_evt_t const * p_event);
ret_code_t saadc_init(void);
//void saadc_init(void);
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

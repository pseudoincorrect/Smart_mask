#ifndef __SENSORS_H__
#define __SENSORS_H__

#include "app_config.h"
#include "nrfx_saadc.h"
#include "nrfx_timer.h"
#include "sensors.h"

// void sensors_init_buffer(sensors_t* p_sensors);
void saadc_callback(nrfx_saadc_evt_t const * p_event);
// void saadc_callback(nrf_drv_saadc_evt_t const * p_event);
ret_code_t saadc_init(void);
// void saadc_init(void);
void saadc_sampling_event_enable(void);
void saadc_sampling_event_init(void);
ret_code_t sensor_sampling_init(void);
void timer_handler(nrf_timer_event_t event_type, void * p_context);
// void update_sensor_values(sensors_t* sensors);

#if (MOCK_ADC)
static uint8_t random_vector_generate(uint8_t * p_buff, uint8_t size);
void random_vector_generate_init(void);
void mock_sensor_values(sensors_t * sensors);
#endif

#endif
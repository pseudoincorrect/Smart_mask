#ifndef __sensors_h__
#define __sensors_h__

#include "stdint.h"
#include "nrf_ringbuf.h"

#define SENSORS_COUNT 4

typedef enum
{
    SENSOR_FIRST = 0,
    SENSOR_1 = 0,
    SENSOR_2 = 1,
    SENSOR_3 = 2,
    SENSOR_4 = 3,
    SENSOR_LAST = 3,
} sensor_t;

typedef int16_t sensor_val_t;

typedef struct
{
    uint32_t sample_period_ms;
    uint8_t gain;
    uint8_t enable;
} sensor_ctrl_t;

typedef struct
{
    uint32_t pwr_pin;
    uint8_t adc_pin;
    uint8_t adc_chanel;
    uint8_t analog_input;
} sensor_hardware_t;

typedef struct
{
    sensor_t sensor;
    const nrf_ringbuf_t* buffer;
    sensor_ctrl_t control;
    sensor_hardware_t hardware;
} sensor_handle_t;

#endif
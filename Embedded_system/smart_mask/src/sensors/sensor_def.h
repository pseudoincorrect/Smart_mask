#ifndef __sensor_def_h__
#define __sensor_def_h__

#define SENSORS_COUNT 4


typedef struct 
{
    sensor_val_t sensor_val;
    sensor_ctrl_t sensor_ctrl;
} 
sensor_t;


typedef int16_t sensor_val_t; 

typedef struct 
{
    uint16_t frequency;
    uint8_t gain;
    uint8_t enable;
} 
sensor_ctrl_t;


#endif
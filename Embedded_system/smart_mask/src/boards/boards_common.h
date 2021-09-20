
#ifndef __boards_common_h__
#define __boards_common_h__


typedef struct adc_in
{
    uint8_t pwr_pin;
    uint8_t adc_pin;
    uint8_t analog_input;
    uint8_t adc_channel;
} adc_in_t;


#endif
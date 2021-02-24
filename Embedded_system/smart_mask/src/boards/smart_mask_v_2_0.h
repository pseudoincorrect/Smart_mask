#ifndef __smart_mask_v_2_0_h__
#define __smart_mask_v_2_0_h__


#define RX_PIN_NUMBER   18
#define TX_PIN_NUMBER   20

#define LED_RED_PIN     14
#define LED_GREEN_PIN   12
#define LED_BLUE_PIN    15

#define USR_BUTTON_PIN  16

#define SENSOR_1_PWR_PIN    25
#define SENSOR_1_ADC_PIN    30

#define SENSOR_2_PWR_PIN    1
#define SENSOR_2_ADC_PIN    28

#define SENSOR_3_PWR_PIN    6
#define SENSOR_3_ADC_PIN    4

#define SENSOR_4_PWR_PIN    9
#define SENSOR_4_ADC_PIN    5

// BSP Leds (for compatibility with SDK)
#define LEDS_NUMBER    3
#define LED_START      LED_GREEN_PIN
#define LED_1          LED_GREEN_PIN
#define LED_2          LED_BLUE_PIN
#define LED_3          LED_RED_PIN
#define LED_STOP       LED_RED_PIN
#define LEDS_ACTIVE_STATE 0
#define LEDS_INV_MASK  LEDS_MASK
#define LEDS_LIST { LED_1, LED_2, LED_3}
#define BSP_LED_0      LED_1
#define BSP_LED_1      LED_2
#define BSP_LED_2      LED_3

// BSP Button (for compatibility with SDK)
#define BUTTONS_NUMBER 1
#define BUTTON_START   USR_BUTTON_PIN
#define BUTTON_1       USR_BUTTON_PIN
#define BUTTON_STOP    USR_BUTTON_PIN
#define BUTTON_PULL    NRF_GPIO_PIN_PULLUP
#define BUTTONS_ACTIVE_STATE 0
#define BUTTONS_LIST { BUTTON_1}
#define BSP_BUTTON_0   BUTTON_1


#endif
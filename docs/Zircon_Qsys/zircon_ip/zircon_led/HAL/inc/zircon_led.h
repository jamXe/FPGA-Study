#ifndef __ZIRCON_LED_H__
#define __ZIRCON_LED_H__

#include "system.h"
#include "alt_types.h"
#include "zircon_led_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

void zircon_led_allclose();
void zircon_led_allopen();
void zircon_led_demo1();
void zircon_led_demo2(alt_u32 length ,alt_u32* led_data);

/* Macros used by alt_sys_init */
#define ZIRCON_LED_INSTANCE(name, dev) alt_u32 led_controller_addr = name##_BASE
#define ZIRCON_LED_INIT(name, dev) while(0)   


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_LED_H__ */

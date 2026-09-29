/*
 * appsw.c
 * -------
 * Main entry points of the App SW dynamic library: constructor,
 * destructor, doStep. See appsw.h for the full contract of each.
 */

#include "appsw.h"
#include "datatypes.h"
#include "interfaces.h"
#include "scheduler_events.h"
#include "scheduler_manager.h"

void constructor(void)
{

    int unusedValueGained = (int)0;
    int unusedCounter     = (int)0;

    resetScheduler();

    /* Same behavior as doStep(), but always forcing eventR (see appsw.h
     * and scheduler_events.h): guarantees SWC1's gain and SWC2's counter
     * start from a known, reset state. */
    doStep(EVENT_R_BIT, (int)0, (int)0, &unusedValueGained, &unusedCounter);


}

void destructor(void)
{
    resetScheduler();
}

void doStep(EventMaskType events,
            int R_SWC1_value,
            int R_SWC1_gain,
            int *P_SWC1_valueGained,
            int *PR_SWC2_counter)
{
    /* The environment (whatever sits outside the App SW - here, Modelica)
     * writes its inputs directly into the global interface: this boundary
     * code is not itself a Software Component, so - unlike SWC1/SWC2 - it
     * is not expected to go through Read_* / Write_*. */

    gSWC1_value = (int32)R_SWC1_value;
    gSWC1_gain  = (int32)R_SWC1_gain;

    /* Highest priority first: eventR > eventG > eventClockA. Runnables run
     * in the order they are pushed (see scheduler_manager.c), so calling
     * Mng_event* in priority order guarantees the correct execution order
     * even when several events fire at the very same instant. */
    
    if ((events & EVENT_R_BIT) != 0)
    {
        Mng_eventR();
    }
    if ((events & EVENT_G_BIT) != 0)
    {
        Mng_eventG();
    }
    if ((events & EVENT_CLOCKA_BIT) != 0)
    {
        Mng_eventClockA();
    }
    
    runRunnables();
    

    *P_SWC1_valueGained = (int)gSWC1_valueGained;
    *PR_SWC2_counter    = (int)gSWC2_counter;
}

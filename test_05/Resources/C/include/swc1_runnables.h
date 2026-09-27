#ifndef SWC1_RUNNABLES_H
#define SWC1_RUNNABLES_H

/*
 * swc1_runnables.h
 * ----------------
 * Runnable entities of Software Component SWC1.
 *
 * SWC1's internal ("Per-Instance Memory", in AUTOSAR terms) variables -
 * SWC1_value, SWC1_gain, SWC1_valueGained - are file-static in
 * swc1_runnables.c and are not exposed here: only the runnables
 * themselves are part of SWC1's public interface towards the scheduler.
 */

void SWC1_ComputeValueGained(void);
void SWC1_SaveGain(void);
void SWC1_ResetGain(void);

#endif /* SWC1_RUNNABLES_H */

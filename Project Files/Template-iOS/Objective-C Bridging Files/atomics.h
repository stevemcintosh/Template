#ifndef Atomics_h
#define Atomics_h

#import <stdatomic.h>

static atomic_int cnt = ATOMIC_VAR_INIT(0);
void __atomic_increment(void);
void __atomic_decrement(void);
void __atomic_reset(void);
int __get_atomic_count(void);

#endif /* Atomics_h */

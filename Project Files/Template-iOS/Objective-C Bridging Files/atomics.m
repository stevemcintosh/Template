#import "atomics.h"

void __atomic_increment() {
	atomic_fetch_add(&cnt, 1);
}
void __atomic_decrement() {
	atomic_fetch_add(&cnt, -1);
}
void __atomic_reset() {
	cnt = ATOMIC_VAR_INIT(0);
}
int __get_atomic_count() {
	return atomic_load(&cnt);
}

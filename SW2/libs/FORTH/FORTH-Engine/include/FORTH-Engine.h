#ifndef FORTH_ENGINE_H
#define FORTH_ENGINE_H
// ; === NEXT uses EIJMP to move
__attribute__((naked, noreturn)) void NEXT();
// void NEXT();
// NEXT() cannot be called in C, otherwise C will push return address there. use
// asm volatile("rjmp NEXT");
// and make the function itself naked, noreturn

// {{{ Example of NEXT by chatGPT
	/*
	
	#define FORTH_EXIT() \
	    asm volatile (   \
		"pop r31\n\t"\
		"pop r30\n\t"\
		"rjmp NEXT\n\t" \
	    ); \
	    __builtin_unreachable();
	
	// example function
	// 
	__attribute__((noreturn))
	void forth_compute(void)
	{
	    int a,b,c;
	
	    a = pop_data();
	    b = pop_data();
	    c = a + b;
	    push_data(c);
	
	    Serial.println("computed");
	
	    FORTH_EXIT();
	}
	
	*/
// }}}

__attribute__((naked, noreturn)) void DOCOL();
__attribute__((naked, noreturn)) void EXIT();

#endif

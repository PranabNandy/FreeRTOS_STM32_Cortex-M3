MEMORY
{
	MEM : ORIGIN = 0x0, LENGTH = 0x4000
	RAM : ORIGIN = 0x20000000, LENGTH = 0x800
}


SECTIONS
{
	/* Vector table & normal code in Flash */
	.text : {
		*(.vectors*)
		*(.text*)
		*(.new_section1)
		*(.new_section2)

	} > MEM
	/* Variables in RAM */
	.data : {
		*(.data*)
	} > RAM

/* ---------------------- My Special Code ----------------*/
     /* Zero-initialized variables in RAM */
    .bss :
    {
        *(.bss*)
        *(COMMON)
    } > RAM

    /* Special section: functions to run from RAM */
	.ramfunc :
	{
	    _sramfunc = .;         /* VMA start of .ramfunc in RAM */
	    *(.ramfunc)            /* Collect all functions marked __attribute__((section(".ramfunc"))) */
	    _eramfunc = .;         /* VMA end of .ramfunc in RAM */
	} > RAM AT > MEM

	/* Load address (LMA) in Flash for copying at startup */
	_si_ramfunc = LOADADDR(.ramfunc);
	_ei_ramfunc = _si_ramfunc + SIZEOF(.ramfunc);

}


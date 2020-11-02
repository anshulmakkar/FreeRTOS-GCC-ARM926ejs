ENTRY(Vector_Init);

MEMORY
{
	ram (rwx) : ORIGIN = 0x100000, LENGTH = 0x10000
}

PROVIDE(__stack = 0x200000);

SECTIONS
{
    .dynsym : { *(.dynsym) }
    .rel.dyn : { *(.rel.dyn) }
    .plt : { *(.plt) }
    .text :
    {
        _text = .;
        __isr_vector_start = .;
        *(.isr_vector)
        __isr_vector_end = .;
        *(.text*)
        *(.rodata*)
        _etext = .;
    } > ram 

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _data = .;
        *(vtable)
        *(.data*)
        _edata = .;
    } > ram
    .bss :
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > ram
}

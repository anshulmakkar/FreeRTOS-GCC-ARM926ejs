ENTRY(_start)

SECTIONS
{
    . = 0x00100000;
    start = .;
    .text : 
    {
        *(.text)
        . = ALIGN(4096);
    }

    .data :
    {
        *(.data)
        *(.rodata)
        . = ALIGN(4096);
    }

    .bss :
    {
        *(.bss)
        *(stack_bottom)
        *(stack_top)
        . = ALIGN(4096);
    }
    end = .;
}
ifdef(`simple_app',
_simple_elf_start = ALIGN(0x4);
. = _simple_elf_start;
INCLUDE "obj/app_image.ld";
_simple_elf_end = .;)

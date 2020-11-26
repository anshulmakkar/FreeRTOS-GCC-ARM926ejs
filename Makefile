# Copyright 2013, 2017, Jernej Kovacic
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software. If you wish to use our Amazon
# FreeRTOS name, please do so in a fair use way that does not cause confusion.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#
# Type "make help" for more details.
#


# Version "6-2017-q2-update" of the "GNU Arm Embedded Toolchain" is used
# as a build tool. See comments in "setenv.sh" for more details about
# downloading it and setting the appropriate environment variables.

TOOLCHAIN = arm-none-eabi-
CC = $(TOOLCHAIN)gcc
CXX = $(TOOLCHAIN)g++
AS = $(TOOLCHAIN)as
#LD = $(TOOLCHAIN)ld
#LINK = $(TOOLCHAIN)gcc
LD = $(TOOLCHAIN)gcc 
OBJCOPY = $(TOOLCHAIN)objcopy
AR = $(TOOLCHAIN)ar
M4 = m4
HXDMP = hexdump -v -e '"BYTE(0x" 1/1 "%02X" ")\n"' 

#dont use cpuflag as cortex-a9. program crashes during pic initializaiton.
# GCC flags
CFLAG = -c
DISASSFLAG = -s
OFLAG = -o
INCLUDEFLAG = -I
CPUFLAG = -mcpu=arm926ej-s
#CPUFLAG = -mcpu=cortex-a9
WFLAG = -Wall -Wextra -Werror
CFLAGS = $(CPUFLAG) $(WFLAG) -fPIC -g 
#M4FLAGS = -DARCH=arm9 -Dsimple_app
M4FLAGS = -DARCH=arm9 -Dsimple_app -mcpu=arm926ej-s
#LDFLAGS = -nostartfiles -fPIC -shared -mcpu=arm926ej-s
LDFLAGS = -nostartfiles -fPIC -shared -mcpu=arm926ej-s


# Additional C compiler flags to produce debugging symbols
DEB_FLAG = -g -DDEBUG


# Compiler/target path in FreeRTOS/Source/portable
PORT_COMP_TARG = GCC/ARM926EJ-S/

# Intermediate directory for all *.o and other files:
OBJDIR = obj/

# FreeRTOS source base directory
FREERTOS_SRC = FreeRTOS/Source/

#System source base directory
SYSTEM_SRC = System/

# Directory with memory management source files
FREERTOS_MEMMANG_SRC = $(FREERTOS_SRC)portable/MemMang/

# Directory with platform specific source files
FREERTOS_PORT_SRC = $(FREERTOS_SRC)portable/$(PORT_COMP_TARG)

# Directory with HW drivers' source files
DRIVERS_SRC = drivers/

# Directory with demo specific source (and header) files
APP_SRC = Demo/


# Object files to be linked into an application
# Due to a large number, the .o files are arranged into logical groups:

FREERTOS_OBJS = queue.o list.o tasks.o
# The following o. files are only necessary if
# certain options are enabled in FreeRTOSConfig.h
#FREERTOS_OBJS += timers.o
#FREERTOS_OBJS += croutine.o
#FREERTOS_OBJS += event_groups.o
#FREERTOS_OBJS += stream_buffer.o

# Only one memory management .o file must be uncommented!
FREERTOS_MEMMANG_OBJS = heap_1.o
#FREERTOS_MEMMANG_OBJS = heap_2.o
#FREERTOS_MEMMANG_OBJS = heap_3.o
#FREERTOS_MEMMANG_OBJS = heap_4.o
#FREERTOS_MEMMANG_OBJS = heap_5.o

FREERTOS_PORT_OBJS = port.o portISR.o
STARTUP_OBJ = startup.o
DRIVERS_OBJS = timer.o interrupt.o uart.o

HELPER_OBJS = print.o receive.o 
APP_OBJ = simple.o app_startup.o
# nostdlib.o must be commented out if standard lib is going to be linked!
HELPER_OBJS += nostdlib.o

SYSTEM_OBJS = init.o task_manager.o system.o 
#applications.ld

# All object files specified above are prefixed the intermediate directory
#OBJS = $(addprefix $(OBJDIR), $(STARTUP_OBJ) $(SYSTEM_OBJS) $(FREERTOS_OBJS) $(FREERTOS_MEMMANG_OBJS) $(FREERTOS_PORT_OBJS) $(DRIVERS_OBJS) $(APP_OBJS))

OBJS = $(addprefix $(OBJDIR), $(STARTUP_OBJ) $(FREERTOS_OBJS) $(FREERTOS_MEMMANG_OBJS) $(FREERTOS_PORT_OBJS) $(DRIVERS_OBJS) $(HELPER_OBJS) $(SYSTEM_OBJS))
APP_OBJS = $(addprefix $(OBJDIR), $(HELPER_OBJS) $(APP_OBJ))

# Definition of the linker script and final targets
LINKER_SCRIPT = $(addprefix $(APP_SRC), qemu.ld) #will just create path Demo/qemu.ld
ELF_IMAGE = image.elf
TARGET = image.bin

#Definition of linker script and app targets
LINKER_SCRIPT_APP = $(addprefix $(APP_SRC), app.ld)
#LINKER_SCRIPT_APP = $(addprefix $(APP_SRC), qemu.ld)
APP_ELF_IMAGE = app_image.elf
TARGET_APP = app_image.elf

#definition OBJDUMP file
TARGET_DMP = app_image.ld
APP_LINKER_FILE = app_image.ld

# Include paths to be passed to $(CC) where necessary
INC_FREERTOS = $(FREERTOS_SRC)include/
INC_DRIVERS = $(DRIVERS_SRC)include/

# Complete include flags to be passed to $(CC) where necessary
INC_FLAGS = $(INCLUDEFLAG)$(INC_FREERTOS) $(INCLUDEFLAG)$(APP_SRC) $(INCLUDEFLAG)$(FREERTOS_PORT_SRC) $(INCLUDEFLAG)$(SYSTEM_SRC)
INC_FLAG_DRIVERS = $(INCLUDEFLAG)$(INC_DRIVERS)

# Dependency on HW specific settings
DEP_BSP = $(INC_DRIVERS)bsp.h





# Startup code, implemented in assembler

$(OBJDIR)startup.o : $(APP_SRC)startup.s
	$(AS) $(CPUFLAG) $< $(OFLAG) $@


# FreeRTOS core

$(OBJDIR)queue.o : $(FREERTOS_SRC)queue.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)list.o : $(FREERTOS_SRC)list.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)tasks.o : $(FREERTOS_SRC)tasks.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)timers.o : $(FREERTOS_SRC)timers.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)croutine.o : $(FREERTOS_SRC)croutine.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)event_groups.o : $(FREERTOS_SRC)event_groups.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)stream_buffer.o : $(FREERTOS_SRC)stream_buffer.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

# System core
$(OBJDIR)system.o: $(SYSTEM_SRC)main.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)task_manager.o : $(SYSTEM_SRC)task_manager.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)applications.ld : $(SYSTEM_SRC)applications.ld.m4
	$(M4) $< $(OFLAG) $@
	
$(OBJDIR)init.o : $(APP_SRC)init.c $(DEP_BSP)
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

# HW specific part, in FreeRTOS/Source/portable/$(PORT_COMP_TARGET)

$(OBJDIR)port.o : $(FREERTOS_PORT_SRC)port.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

$(OBJDIR)portISR.o : $(FREERTOS_PORT_SRC)portISR.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@


# Rules for all MemMang implementations are provided
# Only one of these object files must be linked to the final target

$(OBJDIR)heap_1.o : $(FREERTOS_MEMMANG_SRC)heap_1.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)heap_2.o : $(FREERTOS_MEMMANG_SRC)heap_2.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)heap_3.o : $(FREERTOS_MEMMANG_SRC)heap_3.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)heap_4.o : $(FREERTOS_MEMMANG_SRC)heap_4.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)heap_5.o : $(FREERTOS_MEMMANG_SRC)heap_5.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@


# Drivers
$(OBJDIR)timer.o : $(DRIVERS_SRC)timer.c $(DEP_BSP)
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

$(OBJDIR)interrupt.o : $(DRIVERS_SRC)interrupt.c $(DEP_BSP)
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

$(OBJDIR)uart.o : $(DRIVERS_SRC)uart.c $(DEP_BSP)
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

# Demo application

$(OBJDIR)simple.o : $(APP_SRC)simple.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $< $(OFLAG) $@

$(OBJDIR)print.o : $(APP_SRC)print.c
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

$(OBJDIR)receive.o : $(APP_SRC)receive.c $(DEP_BSP)
	$(CC) $(CFLAG) $(CFLAGS) $(INC_FLAGS) $(INC_FLAG_DRIVERS) $< $(OFLAG) $@

$(OBJDIR)nostdlib.o : $(APP_SRC)nostdlib.c
	$(CC) $(CFLAG) $(CFLAGS) $< $(OFLAG) $@
	
$(OBJDIR)app_startup.o : $(APP_SRC)app_startup.S
	$(CC) $(CFLAG) $(CFLAGS) $< $(OFLAG) $@

#
# Make rules:
#

all : $(TARGET)
rebuild : clean all
$(warning 'cleaned up')
$(TARGET) : $(OBJDIR) $(ELF_IMAGE)
	$(OBJCOPY) -O binary $(word 2,$^) $@

$(OBJDIR) :
	mkdir -p $@
#-nodefaultlibs 
$(ELF_IMAGE) : $(OBJS) $(LINKER_SCRIPT)
	$(LD) -nostartfiles -L $(OBJDIR) -T$(LINKER_SCRIPT) $(OBJS) $(OFLAG) $@

app : $(TARGET_APP)
$(APP_ELF_IMAGE): $(APP_OBJS)
	#$(LD) $(LDFLAGS) $(APP_OBJS)  $(OFLAG)  $@
	#$(LD) $(LDFLAGS) -L $(OBJDIR) -T$(LINKER_SCRIPT_APP)  $(APP_OBJS)  $(OFLAG)  $@
	$(LD) $(LDFLAGS) -T$(LINKER_SCRIPT_APP)  $(APP_OBJS)  $(OFLAG)  $@

dmp: $(TARGET_DMP)
$(APP_LINKER_FILE) : app_image.elf
	$(HXDMP) $< > $@ 

debug : _debug_flags all

debug_rebuild : _debug_flags rebuild

_debug_flags :
	$(eval CFLAGS += $(DEB_FLAG))
	
# Cleanup directives:

clean_obj :
	$(RM) -r $(OBJDIR)

clean_intermediate : clean_obj
	$(RM) *.elf
	$(RM) *.img

clean : clean_intermediate
	$(RM) *.bin

# Short help instructions:

help :
	@echo
	@echo Valid targets:
	@echo - all: builds missing dependencies and creates the target image \'$(TARGET)\'.
	@echo - rebuild: rebuilds all dependencies and creates the target image \'$(TARGET)\'.
	@echo - debug: same as \'all\', also includes debugging symbols to \'$(ELF_IMAGE)\'.
	@echo - debug_rebuild: same as \'rebuild\', also includes debugging symbols to \'$(ELF_IMAGE)\'.
	@echo - clean_obj: deletes all object files, only keeps \'$(ELF_IMAGE)\' and \'$(TARGET)\'.
	@echo - clean_intermediate: deletes all intermediate binaries, only keeps the target image \'$(TARGET)\'.
	@echo - clean: deletes all intermediate binaries, incl. the target image \'$(TARGET)\'.
	@echo - help: displays these help instructions.
	@echo

.PHONY : all rebuild clean clean_obj clean_intermediate debug debug_rebuild _debug_flags help

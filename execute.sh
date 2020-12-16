#!/bin/bash
set -e
make clean
sleep 2
mkdir obj
m4 -d System/applications.ld.m4 > obj/applications.ld
sleep 2
#make --debug lib
#sleep 2
make --debug app
sleep 2
mv app_image.elf obj/

make dmp
mv app_image.ld obj/
mv app_image.elf obj/

make all
sleep 2 
#arm-none-eabi-ld -r -b -E -fPIC -shared arm9 -m arm926ej-s binary obj/app_image.elf -o obj/app_image.o
#arm-none-eabi-ld -fPIC -shared -A arm9 -m armelf -b binary obj/app_image.elf -o obj/app_image.o
#arm-none-eabi-ld -fPIC -shared -A arm9 -m armelf -b elf32-big obj/app_image.elf -o obj/app_image.o

sleep 1
echo "doing final linking"

#arm-none-eabi-gcc  -nodefaultlibs -nostartfiles -L/home/anshul/kispe/qemu-port_freertos/myfork-freertos-qemuport-arm9/FreeRTOS-GCC-ARM926ejs/ -L/home/anshul/kispe/qemu-port_freertos/myfork-freertos-qemuport-arm9/FreeRTOS-GCC-ARM926ejs/obj/  -TDemo/qemu.ld  obj/startup.o obj/task_manager.o obj/system.o obj/queue.o obj/list.o obj/tasks.o obj/heap_1.o obj/port.o obj/portISR.o obj/timer.o obj/interrupt.o obj/uart.o obj/init.o obj/print.o obj/receive.o obj/nostdlib.o obj/app_image.elf -o image.elf

#arm-none-eabi-gcc -nodefaultlibs -nostartfiles -L obj/ -TDemo/qemu.ld  obj/startup.o obj/task_manager.o obj/system.o obj/queue.o obj/list.o obj/tasks.o obj/heap_1.o obj/port.o obj/portISR.o obj/timer.o obj/interrupt.o obj/uart.o obj/init.o obj/print.o obj/receive.o obj/nostdlib.o obj/app_image.o -o image.elf


#echo "Executing arm-none-eabi-ld"
#sleep 3
#arm-none-eabi-ld -r -b binary obj/app_image.elf -o obj/app_image.o


#arm-none-eabi-ld -nodefaultlibs -nostartfiles -L obj/ -TDemo/qemu.ld  obj/startup.o obj/task_manager.o obj/system.o obj/queue.o obj/list.o obj/tasks.o obj/heap_1.o obj/port.o obj/portISR.o obj/timer.o obj/interrupt.o obj/uart.o obj/init.o obj/print.o obj/receive.o obj/nostdlib.o obj/app_image.o -o image.elf

#echo "linking done"


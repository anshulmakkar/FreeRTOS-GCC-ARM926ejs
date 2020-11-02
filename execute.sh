mkdir obj
make --debug app
sleep 2
mv app_image.elf obj/

make --debug dmp
mv app_image.ld obj/
mv app_image.elf obj/

sleep 2

m4 -d System/applications.ld.m4 > obj/applications.ld

make --debug
sleep 1
arm-none-eabi-ld -r -b binary obj/app_image.elf -o obj/app_image.o

sleep 1

arm-none-eabi-ld -nodefaultlibs -nostartfiles -L obj/ -TDemo/qemu.ld  obj/startup.o obj/task_manager.o obj/system.o obj/queue.o obj/list.o obj/tasks.o obj/heap_1.o obj/port.o obj/portISR.o obj/timer.o obj/interrupt.o obj/uart.o obj/init.o obj/print.o obj/receive.o obj/nostdlib.o obj/app_image.o -o image.elf


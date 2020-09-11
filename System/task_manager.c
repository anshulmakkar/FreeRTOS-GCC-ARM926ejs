#include <FreeRTOS.h>

#include <task.h>
#include <stdio.h>
#include <semphr.h>
#include <string.h>

#include "task_manager.h"
#include "system.h"
#include "print.h"

//task_register_tree task_register_tree_var =
//RB_INITIALIZER(task_register_tree);
//RB_GENERATE(task_register_tree_t, task_register_cons_t, tasks, task_register_cons_cmp)

int task_alloc(task_register_cons *trc)
{
    int i;
    /* e_shoff : section header table's file offset in bytes */
    Elf32_Shdr *s = (Elf32_Shdr *)((u_int32_t)trc->elfh + trc->elfh->e_shoff);
    u_int32_t alloc_size = 0;

    /* find ou thte size of hte continuous regions that has to be allocated.
     * e_shnum = no. of entries in section header table */
    
    for (i = 0; i < trc->elfh->e_shnum; i++) 
    {
        if (s[i].sh_flags & SHF_ALLOC) //if the section needs to be allocated
        {
            /* sh_addr = virtual address where the section should be mapped
             * sh_size : size of he section in process image in memory
             */
            u_int32_t s_req = s[i].sh_addr + s[i].sh_size;
            alloc_size = alloc_size > s_req ? alloc_size : s_req;
        }

    }
    //vDirectPrintMsg("Memory required for task %s :%lu\n", trc->name, alloc_size);
    vDirectPrintMsg("Memory required for task \n");
    
    Elf32_Shdr *section_hdr = (Elf32_Shdr *) ((u_int32_t)trc->elfh + trc->elfh->e_shoff);
    Elf32_Shdr *strtab_sect = &section_hdr[trc->elfh->e_shstrndx];
    if (strtab_sect == NULL)
    {
        //vDirectPrintMsg("found no.strtabe in elfh for task %s\n", trc->name);
        vDirectPrintMsg("found no.strtabe in elfh for task \n");
    }

    /* use TASKSECTION_MALLOC_CALL for allocating task memory)
     */
    u_int32_t cm_addr = (u_int32_t)TASKSECTION_MALLOC_CALL(alloc_size);
    if (cm_addr == 0)
    {
        //vDirectPrintMsg("could not allocate memory for task %s \n", trc->name);
        vDirectPrintMsg("could not allocate memory for task\n");
        return 0;
    }
    trc->cont_mem = (void *)cm_addr;
    trc->cont_mem_size = alloc_size;

    LIST_INIT(&trc->sections);

    for (i = 0; trc->elfh->e_shnum; i++)
    {
        if (s[i].sh_flags & SHF_ALLOC)
        {
            struct task_section_cons_t *tsc = (struct task_section_cons_t *)
                SYSTEM_MALLOC_CALL(sizeof(task_section_cons));
            if (tsc == NULL)
            {
                //vDirectPrintMsg("could not allocate memory for section while allocating mem for task %s\n", tsc->name);
                vDirectPrintMsg("could not allocate memory for section while allocating mem for task \n");
                return 0;
            }
            tsc->name = (char *)((u_int32_t)trc->elfh + (u_int32_t)strtab_sect->sh_offset + s[i].sh_name);
            //vDirectPrintMsg("processing allocation for section %s\n", tsc->name);
            vDirectPrintMsg("processing allocation for section \n");
            tsc->section_index = i;
            tsc->amem = (void *)(cm_addr + s[i].sh_addr);
            LIST_INSERT_HEAD(&trc->sections, tsc, sections);

            if (s[i].sh_type != SHT_NOBITS)
            {
                /* coy the section if it contains data */
                memcpy(tsc->amem, (void *)((u_int32_t)trc->elfh + (u_int32_t)s[i].sh_offset), s[i].sh_size);
            }
            else
            {
                bzero(tsc->amem, s[i].sh_size);
            }

        }

    }
    return 1;
}

task_register_cons *task_register(const char *name, Elf32_Ehdr *elfh)
{
    struct task_register_cons_t *trc = 
        (task_register_cons *)SYSTEM_MALLOC_CALL(sizeof(task_register_cons));
    if (trc == NULL)
    {
        return NULL;
    }
    trc->name = name;
    trc->elfh = elfh;
    trc->task_handle = 0;
    TASK_ACQUIRE_TR_LOCK();
    //RB_INSERT(task_register_tree_t, &task_register_tree_var, trc);
    TASK_RELEASE_TR_LOCK();

    //trc->request_hook = NULL;
    trc->cont_mem = NULL;
    trc->cont_mem_size = 0;

    LIST_INIT(&trc->sections);
    //vDirectPrintMsg("tasks registered: %i \n", get_number_of_tasks());
    vDirectPrintMsg("tasks registered: \n");

    return trc;
}

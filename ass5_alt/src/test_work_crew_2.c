#include <assert.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "work_crew_2.h"
void test_function(void *args)
{
    int fn_id = *((int *)args);
    printf("\n\n\nfn_id = %d\n\n\n\n", fn_id);
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Hello world lil buddy\n");
    }

    int thread_cnt = 4;
    int jobs = 10;
    int jobs_max = 10;

    printf("thread_cnt = %d jobs = %d jobs_max = %d\n", thread_cnt, jobs, jobs_max);

    job_factory_t *curr_job_factory = create_job_factory(thread_cnt, jobs_max);
    int job_values[jobs];
    for (int i = 0; i < jobs; i++)
    {
        job_values[i] = i;
        add_job(curr_job_factory, test_function, &job_values[i]);
    }

    job_factory_wait(curr_job_factory);
    destroy_job_factory(curr_job_factory);

    // return 0;
}
#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "work_crew.h"

static const size_t num_threads = 4;
static const size_t num_items = 100;

void worker(void *arg)
{
    int *val = arg;
    int old = *val;

    *val += 1000;
    printf("tid=%p, old=%d, val=%d\n", pthread_self(), old, *val);

    if (*val % 2)
        usleep(100000);
}

int main(int argc, char **argv)
{
    job_factory_t *_job_factory;
    int *vals;
    size_t i;

    _job_factory = create_job_factory(num_threads, 10);
    vals = calloc(num_items, sizeof(*vals));

    for (i = 0; i < num_items; i++)
    {
        vals[i] = i;
        add_job_to_factory(_job_factory, &worker, vals + i);
    }

    job_factory_wait(_job_factory);

    for (i = 0; i < num_items; i++)
    {
        printf("%d\n", vals[i]);
    }

    free(vals);
    destroy_job_factory(_job_factory);
    return 0;
}

#include <assert.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "work_crew_2.h"

job_t *create_job(job_fn_t job_fn, void *args)
{
    job_t *new_job = (job_t *)malloc(sizeof(job_t));
    if (new_job != NULL)
    {
        new_job->args = args;
        new_job->job = job_fn;
    }

    return new_job;
}

void print_job(job_t *_job)
{
    printf("job function : %p\t job args : %p\n", _job->job, _job->args);
}

void destroy_job(job_t *job_to_destroy)
{
    if (job_to_destroy != NULL)
    {
        free(job_to_destroy);
    }
}

static bool has_job(job_factory_t *_job_factory)
{
    // printf("curr_job = %lu < jobs_cnt = %lu\n", _job_factory->curr_job, _job_factory->jobs_size);
    return _job_factory->jobs_cnt > 0 && _job_factory->curr_job < _job_factory->jobs_cnt;
}

job_t *get_job(job_factory_t *_job_factory)
{
    if (_job_factory == NULL || _job_factory->jobs == NULL)
    {
        return NULL;
    }

    if (!has_job(_job_factory))
    {
        return NULL;
    }

    job_t *curr_job = _job_factory->jobs[_job_factory->curr_job];
    _job_factory->curr_job++; // Increment immediately after getting the job while still holding the lock
    return curr_job;
}

static void *factory_worker(void *factory)
{
    job_factory_t *_job_factory = (job_factory_t *)factory;
    job_t *job;

    while (true)
    {
        pthread_mutex_lock(&(_job_factory->factory_mutex));

        while (!has_job(_job_factory) && !_job_factory->done)
        {
            pthread_cond_wait(&(_job_factory->factory_cond), &(_job_factory->factory_mutex));
        }

        if (!has_job(_job_factory) && _job_factory->done)
        {
            printf("Breaking out : \n");
            print_job_factory(_job_factory);
            pthread_mutex_unlock(&(_job_factory->factory_mutex));
            break;
        }

        job = get_job(_job_factory); // This now increments curr_job while holding the lock

        // Check if all jobs are processed to signal other threads
        // if (!has_job(_job_factory) && _job_factory->curr_job >= _job_factory->jobs_cnt)
        if (!has_job(_job_factory) && _job_factory->curr_job >= _job_factory->jobs_size)
        {
            printf("Done processing jobs\n");
            print_job_factory(_job_factory);
            _job_factory->done = true;
            pthread_cond_broadcast(&(_job_factory->factory_cond));
        }

        pthread_mutex_unlock(&(_job_factory->factory_mutex));

        if (job == NULL)
            continue;

        printf("THREAD ID (%p) RUNNING:\n", pthread_self());
        job->job(job->args);
        // destroy_job(job); // Note: jobs are destroyed in destroy_job_factory
    }

    printf("THREAD ID (%p) DYING:\n", pthread_self());

    return NULL;
}

job_factory_t *create_job_factory(size_t num_workers, size_t jobs_max)
{
    printf("Attempting to make new job factory\n");
    job_factory_t *new_job_factory = (job_factory_t *)malloc(sizeof(job_factory_t));
    if (new_job_factory == NULL)
    {
        return NULL;
    }

    new_job_factory->jobs = malloc(jobs_max * sizeof(job_t *));
    if (new_job_factory->jobs == NULL)
    {
        free(new_job_factory);
        return NULL;
    }

    new_job_factory->jobs_size = jobs_max;

    if (num_workers == 0)
    {
        long num_cores = sysconf(_SC_NPROCESSORS_ONLN);
        if (num_cores < 1)
        {
            return NULL;
        }
        else
        {
            num_workers = num_cores + 1;
        }
    }

    pthread_cond_init(&(new_job_factory->factory_cond), NULL);
    pthread_mutex_init(&(new_job_factory->factory_mutex), NULL);

    new_job_factory->done = false;
    new_job_factory->jobs_cnt = 0;
    new_job_factory->curr_job = 0;

    pthread_t curr_thread;
    for (size_t i = 0; i < num_workers; i++)
    {
        pthread_create(&curr_thread, NULL, factory_worker, new_job_factory);
        printf("Created a new thread with value %p\n", curr_thread);
        pthread_detach(curr_thread);
    }

    print_job_factory(new_job_factory);
    return new_job_factory;
}

static void destroy_jobs(job_t **jobs, size_t jobs_size)
{
    if (jobs == NULL)
        return;
    for (size_t i = 0; i < jobs_size; i++)
    {
        destroy_job(jobs[i]);
    }
}

void destroy_job_factory(job_factory_t *job_factory_to_destroy)
{
    if (job_factory_to_destroy == NULL)
    {
        return;
    }

    pthread_mutex_lock(&(job_factory_to_destroy->factory_mutex));
    destroy_jobs(job_factory_to_destroy->jobs, job_factory_to_destroy->jobs_cnt);
    free(job_factory_to_destroy->jobs);
    job_factory_to_destroy->done = true;
    pthread_cond_broadcast(&(job_factory_to_destroy->factory_cond));
    pthread_mutex_unlock(&(job_factory_to_destroy->factory_mutex));

    pthread_mutex_destroy(&(job_factory_to_destroy->factory_mutex));
    pthread_cond_destroy(&(job_factory_to_destroy->factory_cond));
    free(job_factory_to_destroy);
}

bool add_job(job_factory_t *_job_factory, job_fn_t _job_func, void *args)
{
    printf("Attempting to add job # %lu\n", _job_factory->jobs_cnt + 1);
    if (_job_factory == NULL || _job_func == NULL)
        return false;

    pthread_mutex_lock(&(_job_factory->factory_mutex));
    if (_job_factory->jobs_cnt > _job_factory->jobs_size) // fix?
    {
        printf("Returning false\n");
        pthread_mutex_unlock(&(_job_factory->factory_mutex));
        return false;
    }

    _job_factory->jobs[_job_factory->jobs_cnt] = create_job(_job_func, args);
    _job_factory->jobs_cnt++;
    printf("Added job # %lu\n", _job_factory->jobs_cnt);
    pthread_cond_signal(&(_job_factory->factory_cond));
    pthread_mutex_unlock(&(_job_factory->factory_mutex));
    return true;
}

void job_factory_wait(job_factory_t *_job_factory)
{
    pthread_mutex_lock(&(_job_factory->factory_mutex));
    while (!_job_factory->done)
    {
        pthread_cond_wait(&(_job_factory->factory_cond), &(_job_factory->factory_mutex));
    }
    pthread_mutex_unlock(&(_job_factory->factory_mutex));
}

void print_job_factory(job_factory_t *_job_factory)
{
    printf("Printing job factory...\n");
    printf("\tDone = %d\n", _job_factory->done);
    printf("\tCurr job = %lu\n", _job_factory->curr_job);
    printf("\tJobs count = %lu\n", _job_factory->jobs_cnt);
    printf("\tJobs size = %lu\n", _job_factory->jobs_size);
}
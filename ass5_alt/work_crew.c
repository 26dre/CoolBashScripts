#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "work_crew.h"
#define MIN_JOB_SIZE 2

static void print_job_factory(job_factory_t *_job_factory)
{
    if (_job_factory == NULL)
        return;
    printf("Printed real job factory");
}

static job_t *create_job(job_func_t job, void *arg)
{
    if (job == NULL)
        return NULL;

    job_t *ret_job = malloc(sizeof(job_t));
    ret_job->args = arg;
    ret_job->job = job;

    return ret_job;
}

static void destroy_job(job_t *job_to_destroy)
{
    if (job_to_destroy == NULL)
        return;
    free(job_to_destroy);
}

static job_t *get_next_job(job_factory_t *curr_job_factory)
{
    if (curr_job_factory == NULL || curr_job_factory->jobs_size < curr_job_factory->next_job)
    {
        return NULL;
    }
    job_t *curr_job = curr_job_factory->jobs[curr_job_factory->next_job];
    curr_job_factory->next_job++;
    return curr_job;
}

static bool jobs_left(job_factory_t *_job_factory)
{
    return _job_factory->next_job < _job_factory->jobs_size;
}

static void *factory_worker(void *job_factory)
{
    job_factory_t *_job_factory = (job_factory_t *)job_factory;
    job_t *curr_job;
    while (true)
    {
        pthread_mutex_lock(&(_job_factory->job_factory_mutex));
        while (jobs_left(_job_factory) && !_job_factory->stop)
        {
            pthread_cond_wait(&(_job_factory->job_left_cond), &(_job_factory->job_factory_mutex));
        }
        if (_job_factory->stop)
            break;

        curr_job = get_next_job(_job_factory);
        _job_factory->job_proc_cnt++;

        pthread_mutex_unlock(&(_job_factory->job_factory_mutex));

        if (curr_job != NULL)
        {
            curr_job->job(curr_job->args);
            destroy_job(curr_job);
        }

        pthread_mutex_lock(&(_job_factory->job_factory_mutex));
        _job_factory->job_proc_cnt--;
        if (!_job_factory->stop && _job_factory->job_proc_cnt == 0 && !jobs_left(_job_factory))
            pthread_cond_signal(&(_job_factory->job_completed_cond));
    }
    _job_factory->thread_cnt--;
    pthread_cond_signal(&(_job_factory->job_completed_cond));
    pthread_mutex_unlock(&(_job_factory->job_factory_mutex));
    return NULL;
}

job_factory_t *create_job_factory(size_t num_workers, size_t jobs_cnt)
{
    job_factory_t *_job_factory;
    pthread_t worker_thread;
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

    _job_factory = (job_factory_t *)malloc(sizeof(job_factory_t));
    print_job_factory(_job_factory);
    _job_factory->thread_cnt = num_workers;

    pthread_mutex_init(&(_job_factory->job_factory_mutex), NULL);
    pthread_cond_init(&(_job_factory->job_completed_cond), NULL);
    pthread_cond_init(&(_job_factory->job_left_cond), NULL);
    _job_factory->stop = false;
    _job_factory->job_proc_cnt = 0;
    _job_factory->jobs = malloc(jobs_cnt * sizeof(job_t *));
    _job_factory->next_job = 0;

    for (size_t i = 0; i < num_workers; i++)
    {
        pthread_create(&worker_thread, NULL, factory_worker, _job_factory);
        pthread_detach(worker_thread);
    }

    return _job_factory;
}

bool add_job_to_factory(job_factory_t *_job_factory, job_func_t _job_func, void *args)
{
    printf("Adding job to factory");
    if (_job_factory == NULL)
        return false;
    static size_t job_ptr = 0;

    pthread_mutex_lock(&(_job_factory->job_factory_mutex));
    // critical section
    if (job_ptr > _job_factory->jobs_size)
        return false;
    job_t *curr_job = create_job(_job_func, args);
    _job_factory->jobs[job_ptr] = curr_job;
    pthread_cond_broadcast(&(_job_factory->job_left_cond));
    // end critical section
    pthread_mutex_unlock(&(_job_factory->job_factory_mutex));
    job_ptr++;

    return true;
}

void destroy_job_factory(job_factory_t *job_factory_to_destroy)
{
    if (job_factory_to_destroy == NULL)
        return;

    pthread_mutex_lock(&(job_factory_to_destroy->job_factory_mutex));

    if (job_factory_to_destroy->jobs != NULL)
    {
        for (size_t job_to_destroy_ptr = 0; job_to_destroy_ptr < job_factory_to_destroy->jobs_size; job_to_destroy_ptr++)
        {
            job_t *job_to_destroy = job_factory_to_destroy->jobs[job_to_destroy_ptr];
            if (job_to_destroy != NULL)
            {
                free(job_to_destroy);
            }
        }

        free(job_factory_to_destroy->jobs);
    }

    job_factory_to_destroy->stop = true;

    pthread_cond_broadcast(&(job_factory_to_destroy->job_left_cond));
    pthread_mutex_unlock(&(job_factory_to_destroy->job_factory_mutex));

    job_factory_wait(job_factory_to_destroy);

    pthread_cond_destroy(&(job_factory_to_destroy->job_left_cond));
    pthread_cond_destroy(&(job_factory_to_destroy->job_completed_cond));
    pthread_mutex_destroy(&(job_factory_to_destroy->job_factory_mutex));
}

void job_factory_wait(job_factory_t *_job_factory)
{
    if (_job_factory == NULL)
    {
        return;
    }

    pthread_mutex_lock(&(_job_factory->job_factory_mutex));
    while (true)
    {
        if (jobs_left(_job_factory) || (!_job_factory->stop && _job_factory->job_proc_cnt != 0) || (_job_factory->job_proc_cnt == 0 && _job_factory->thread_cnt != 0))
        {
            pthread_cond_wait(&(_job_factory->job_completed_cond), &(_job_factory->job_factory_mutex));
        }
        else
        {
            break;
        }
    }

    pthread_mutex_unlock(&(_job_factory->job_factory_mutex));
}
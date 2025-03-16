#ifndef WORK_CREW_H
#define WORK_CREW_H

typedef void (*job_func_t)(void *arg);
struct job
{
    job_func_t job;
    void *args;
};

typedef struct job job_t;

struct job_factory
{
    pthread_mutex_t job_factory_mutex;
    pthread_cond_t job_left_cond;
    pthread_cond_t job_completed_cond;
    job_t **jobs;
    size_t jobs_size;
    size_t next_job;
    size_t job_proc_cnt;
    size_t thread_cnt;
    bool stop;
};
typedef struct job_factory job_factory_t;
void job_factory_wait(job_factory_t *_job_factory);
job_factory_t *create_job_factory(size_t num_workers, size_t jobs_cnt);
bool add_job_to_factory(job_factory_t *_job_factory, job_func_t _job_func, void *args);
void destroy_job_factory(job_factory_t *job_factory_to_destroy);
#endif
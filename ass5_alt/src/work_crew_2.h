
#ifndef WORK_CREW_2_H
#define WORK_CREW_2_H
typedef void (*job_fn_t)(void *arg);
struct job
{
    job_fn_t job;
    void *args;
};
typedef struct job job_t;

struct job_factory
{
    pthread_mutex_t factory_mutex;
    pthread_cond_t factory_cond;
    size_t curr_job;
    size_t jobs_cnt;
    size_t jobs_size;
    job_t **jobs;
    bool done;
};

typedef struct job_factory job_factory_t;
void job_factory_wait(job_factory_t *_job_factory);
job_factory_t *create_job_factory(size_t num_workers, size_t jobs_max);
bool add_job(job_factory_t *_job_factory, job_fn_t _job_func, void *args);
void destroy_job_factory(job_factory_t *job_factory_to_destroy);
void print_job_factory(job_factory_t *_job_factory);

#endif
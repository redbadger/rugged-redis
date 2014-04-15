#include "rugged_redis.h"

extern VALUE rb_mRuggedRedis;
extern VALUE rb_cRuggedBackend;

VALUE rb_cRuggedRedisBackend;

void Init_rugged_redis_backend(void)
{
    rb_cRuggedRedisBackend = rb_define_class_under(rb_mRuggedRedis, "Backend", rb_cRuggedBackend);
}


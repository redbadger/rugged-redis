#include "rugged_redis.h"

VALUE rb_mRugged;
VALUE rb_cRuggedBackend;

VALUE rb_mRuggedRedis;

void Init_rugged_redis(void)
{
  rb_mRugged = rb_const_get(rb_cObject, rb_intern("Rugged"));
  rb_cRuggedBackend = rb_const_get(rb_mRugged, rb_intern("Backend"));

  rb_mRuggedRedis = rb_const_get(rb_mRugged, rb_intern("Redis"));

  Init_rugged_redis_backend();
}

#include "rugged_redis.h"

extern VALUE rb_mRuggedRedis;
extern VALUE rb_cRuggedBackend;

VALUE rb_cRuggedRedisBackend;

typedef struct {
  hiredis_odb_backend   *odb_backend;
  hiredis_refdb_backend *refdb_backend;
} rugged_redis_backend;

static void rb_rugged_redis_backend__free(rugged_redis_backend *backend)
{
  // TODO free the backends

  return;
}

static rugged_redis_backend *rugged_redis_backend_new(char* host, int port, char* password)
{
  rugged_redis_backend *backend = malloc(sizeof(rugged_redis_backend));

  // TODO create actual backends
  backend->odb_backend = 1;
  backend->refdb_backend = 2;

  return backend;
}

/*
  Public: Initialize a redis backend.

  opts - hash containing the connection options.
         :host     - string, host to connect to
         :port     - integer, port number
         :password - (optional) string, redis server password

*/
static VALUE rb_rugged_redis_backend_new(VALUE klass, VALUE rb_opts)
{
  VALUE val;

  char *host;
  char *password = NULL;
  int port;

  Check_Type(rb_opts, T_HASH);

  val = rb_hash_aref(rb_opts, ID2SYM(rb_intern("host")));
  Check_Type(val, T_STRING);
  host = StringValueCStr(val);

  val = rb_hash_aref(rb_opts, ID2SYM(rb_intern("port")));
  Check_Type(val, T_FIXNUM);
  port = NUM2INT(val);

  if ((val = rb_hash_aref(rb_opts, ID2SYM(rb_intern("password")))) != Qnil) {
    Check_Type(val, T_STRING);
    password = StringValueCStr(val);
  }

  return Data_Wrap_Struct(klass, NULL, rb_rugged_redis_backend__free, rugged_redis_backend_new(host, port, password));
}

void Init_rugged_redis_backend(void)
{
  rb_cRuggedRedisBackend = rb_define_class_under(rb_mRuggedRedis, "Backend", rb_cRuggedBackend);

  rb_define_singleton_method(rb_cRuggedRedisBackend, "new", rb_rugged_redis_backend_new, 1);
}


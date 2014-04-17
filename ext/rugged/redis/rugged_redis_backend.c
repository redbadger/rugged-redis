#include <git2/sys/odb_backend.h>
#include <git2/sys/refdb_backend.h>
#include <rugged.h>

#include "rugged_redis.h"

extern VALUE rb_mRuggedRedis;
extern VALUE rb_cRuggedBackend;

VALUE rb_cRuggedRedisBackend;

typedef struct {
  rugged_backend backend;

  char *host;
  int port;
  char *password;
} rugged_redis_backend;

// libgit2-redis interface

int git_refdb_backend_hiredis(git_refdb_backend **backend_out, const char* prefix, const char* path, const char *host, int port, char* password);
int git_odb_backend_hiredis(git_odb_backend **backend_out, const char* prefix, const char* path, const char *host, int port, char* password);

static void rb_rugged_redis_backend__free(rugged_redis_backend *backend)
{
  free(backend->host);
  if (backend->password != NULL)
    free(backend->password);

  // libgit will free the backends eventually

  free(backend);

  return;
}

// Redis backend factory functions

static int rugged_redis_odb_backend(git_odb_backend **backend_out, rugged_backend *backend, const char* path)
{
  rugged_redis_backend *rugged_backend = (rugged_redis_backend *) backend;
  return git_odb_backend_hiredis(backend_out, "rugged", path, rugged_backend->host, rugged_backend->port, rugged_backend->password);
}

static int rugged_redis_refdb_backend(git_refdb_backend **backend_out, rugged_backend *backend, const char* path)
{
  rugged_redis_backend *rugged_backend = (rugged_redis_backend *) backend;
  return git_refdb_backend_hiredis(backend_out, "rugged", path, rugged_backend->host, rugged_backend->port, rugged_backend->password);
}

// Redis backend initializer

static rugged_redis_backend *rugged_redis_backend_new(char* host, int port, char* password)
{
  rugged_redis_backend *redis_backend = malloc(sizeof(rugged_redis_backend));

  redis_backend->backend.odb_backend = rugged_redis_odb_backend;
  redis_backend->backend.refdb_backend = rugged_redis_refdb_backend;

  redis_backend->host = strdup(host);
  redis_backend->port = port;

  if (password != NULL)
    redis_backend->password = strdup(password);
  else
    redis_backend->password = NULL;

  return redis_backend;
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


#' Duplicate an R object
#'
#' In R semantics, objects are copied by value. This means that
#' modifying the copy leaves the original object intact. Since
#' copying data in memory is an expensive operation, copies in R are
#' as lazy as possible. They only happen when the new object is
#' actually modified. However, some operations (like [node_poke_car()]
#' or [node_poke_cdr()]) do not support copy-on-write. In those cases,
#' it is necessary to duplicate the object manually in order to
#' preserve copy-by-value semantics.
#'
#' Some objects are not duplicable, like symbols and environments.
#' `duplicate()` returns its input for these unique objects.
#'
#' @param x Any R object. However, uncopyable types like symbols and
#'   environments are returned as is (just like with `<-`).
#' @param shallow This is relevant for recursive data structures like
#'   lists, calls and pairlists. A shallow copy only duplicates the
#'   top-level data structure. The objects contained in the list are
#'   still the same.
#' @seealso pairlist
#' @keywords internal
#' @export
duplicate <- function(x, shallow = FALSE) {
  .Call(ffi_duplicate, x, shallow)
}

#' Address of an R object
#' @param x Any R object.
#' @return Its address in memory in a string.
#' @keywords internal
#' @export
obj_address <- function(x) {
  .Call(ffi_obj_address, x)
}

# Imported from lifecycle
sexp_address <- obj_address

# nocov start - These functions are mostly for interactive experimentation

poke_type <- function(x, type) {
  invisible(.Call(ffi_poke_type, x, type))
}
sexp_named <- function(x) {
  # Don't use `substitute()` because dots might be forwarded
  arg <- match.call(expand.dots = FALSE)$x
  .Call(ffi_named, arg, parent.frame())
}

mark_object <- function(x) {
  invisible(.Call(ffi_mark_object, x))
}
unmark_object <- function(x) {
  invisible(.Call(ffi_unmark_object, x))
}

true_length <- function(x) {
  .Call(ffi_true_length, x)
}
env_frame <- function(x) {
  .Call(ffi_env_frame, x)
}
env_hash_table <- function(x) {
  .Call(ffi_env_hash_table, x)
}

promise_expr <- function(name, env = caller_env()) {
  .Call(ffi_promise_expr, name, env)
}
promise_env <- function(name, env = caller_env()) {
  .Call(ffi_promise_env, name, env)
}
promise_value <- function(name, env = caller_env()) {
  .Call(ffi_promise_value, name, env)
}

warningcall <- function(call, msg) {
  .Call(ffi_test_Rf_warningcall, call, msg)
}
errorcall <- function(call, msg) {
  .Call(ffi_test_Rf_errorcall, call, msg)
}

obj_attrib <- function(x) {
  .Call(ffi_attrib, x)
}

vec_alloc <- function(type, n) {
  stopifnot(
    is_string(type),
    is_integer(n, 1)
  )
  .Call(ffi_vec_alloc, type, n)
}

find_var <- function(env, sym) {
  .Call(ffi_find_var, env, sym);
}

chr_get <- function(x, i = 0L) {
  .Call(ffi_chr_get, x, i)
}

list_poke <- function(x, i, value) {
  .Call(ffi_list_poke, x, i, value)
}

# nocov end

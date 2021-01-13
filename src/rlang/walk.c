#include <rlang.h>
#include "walk.h"

static
bool sexp_iterate_recurse(sexp* x,
                          int depth,
                          sexp* parent,
                          enum r_node_relation rel,
                          r_ssize i,
                          sexp_iterator_fn* it,
                          void* data);


void sexp_iterate(sexp* x, sexp_iterator_fn* it, void* data) {
  sexp_iterate_recurse(x, 0, r_null, R_NODE_RELATION_root, 0, it, data);
}

static
bool sexp_iterate_recurse(sexp* x,
                          int depth,
                          sexp* parent,
                          enum r_node_relation rel,
                          r_ssize i,
                          sexp_iterator_fn* it,
                          void* data) {
 recurse:
  if (depth % 10 == 0) {
    R_CheckStack();
  }

  enum r_type type = r_typeof(x);
  if (!it(data, x, type, depth, parent, rel, i)) return false;

  ++depth;

  if (!sexp_iterate_recurse(ATTRIB(x), depth, x, R_NODE_RELATION_attrib, 0, it, data)) return false;

  switch (type) {
  case r_type_null:
  case r_type_logical:
  case r_type_integer:
  case r_type_double:
  case r_type_complex:
  case r_type_raw:
  case r_type_special:
  case r_type_builtin:
  case r_type_string:
  case r_type_s4:
    return true;
  case r_type_symbol:
    if (!sexp_iterate_recurse(PRINTNAME(x), depth, x, R_NODE_RELATION_symbol_string, 0, it, data)) return false;
    if (!sexp_iterate_recurse(SYMVALUE(x), depth, x, R_NODE_RELATION_symbol_value, 0, it, data)) return false;
    if (!sexp_iterate_recurse(INTERNAL(x), depth, x, R_NODE_RELATION_symbol_internal, 0, it, data)) return false;
    return true;
  case r_type_closure:
    if (!sexp_iterate_recurse(FORMALS(x), depth, x, R_NODE_RELATION_function_fmls, 0, it, data)) return false;
    if (!sexp_iterate_recurse(BODY(x), depth, x, R_NODE_RELATION_function_body, 0, it, data)) return false;
    if (!sexp_iterate_recurse(CLOENV(x), depth, x, R_NODE_RELATION_function_env, 0, it, data)) return false;
    return true;
  case r_type_environment:
    if (!sexp_iterate_recurse(FRAME(x), depth, x, R_NODE_RELATION_environment_frame, 0, it, data)) return false;
    if (!sexp_iterate_recurse(ENCLOS(x), depth, x, R_NODE_RELATION_environment_enclos, 0, it, data)) return false;
    if (!sexp_iterate_recurse(HASHTAB(x), depth, x, R_NODE_RELATION_environment_hashtab, 0, it, data)) return false;
    return true;
  case r_type_promise:
    if (!sexp_iterate_recurse(PRVALUE(x), depth, x, R_NODE_RELATION_promise_value, 0, it, data)) return false;
    if (!sexp_iterate_recurse(PREXPR(x), depth, x, R_NODE_RELATION_promise_expr, 0, it, data)) return false;
    if (!sexp_iterate_recurse(PRENV(x), depth, x, R_NODE_RELATION_promise_env, 0, it, data)) return false;
    return true;
  case r_type_pointer:
    if (!sexp_iterate_recurse(EXTPTR_PROT(x), depth, x, R_NODE_RELATION_pointer_prot, 0, it, data)) return false;
    if (!sexp_iterate_recurse(EXTPTR_TAG(x), depth, x, R_NODE_RELATION_pointer_tag, 0, it, data)) return false;
    return true;

  case r_type_pairlist:
  case r_type_call:
  case r_type_dots:
    if (!sexp_iterate_recurse(TAG(x), depth, x, R_NODE_RELATION_node_tag, 0, it, data)) return false;
    if (!sexp_iterate_recurse(CAR(x), depth, x, R_NODE_RELATION_node_car, 0, it, data)) return false;
    parent = x;
    x = CDR(x);
    rel = R_NODE_RELATION_node_cdr;
    goto recurse;

  case r_type_list:
  case r_type_expression:
  case r_type_character:
  case r_type_weakref: {
    r_ssize n = r_length(x);

    sexp* const * p_x;
    if (type == r_type_character) {
      p_x = r_chr_deref_const(x);
    } else {
      p_x = r_list_deref_const(x);
    }

    enum r_node_relation vec_rel = 0;
    switch (type) {
    case r_type_list: vec_rel = R_NODE_RELATION_list_elt; break;
    case r_type_expression: vec_rel = R_NODE_RELATION_expression_elt; break;
    case r_type_character: vec_rel = R_NODE_RELATION_character_elt; break;
    case r_type_weakref: vec_rel = R_NODE_RELATION_weakref_elt; break;
    default: r_stop_internal("sexp_iterate_recurse", "while setting `vec_rel`.");
    }

    for (r_ssize i = 0; i < n; ++i) {
      if (!sexp_iterate_recurse(p_x[i], depth, x, vec_rel, i, it, data)) return false;
    }
    return true;
  }

  default:
    r_abort("Unimplemented type");
  }
}

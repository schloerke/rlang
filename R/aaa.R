# Changelog:
#
# - 2021-04-29: `expr` is now evaluated in caller environment rather
#   than the top environment.

on_load <- function(expr, env = parent.frame()) {
  ns <- topenv(env)
  expr <- substitute(expr)
  callback <- function() eval_bare(expr, env)
  ns$.__rlang_hook__. <- c(ns$.__rlang_hook__., list(callback))
}

run_on_load <- function(env = parent.frame()) {
  ns <- topenv(env)

  hook <- ns$.__rlang_hook__.
  env_unbind(ns, ".__rlang_hook__.")

  for (callback in hook) {
    callback()
  }

  ns$.__rlang_hook__. <- NULL
}

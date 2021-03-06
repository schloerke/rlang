% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fn.R
\name{as_function}
\alias{as_function}
\alias{is_lambda}
\title{Convert to function}
\usage{
as_function(x, env = caller_env())

is_lambda(x)
}
\arguments{
\item{x}{A function or formula.

If a \strong{function}, it is used as is.

If a \strong{formula}, e.g. \code{~ .x + 2}, it is converted to a function
with up to two arguments: \code{.x} (single argument) or \code{.x} and \code{.y}
(two arguments). The \code{.} placeholder can be used instead of \code{.x}.
This allows you to create very compact anonymous functions (lambdas) with up
to two inputs. Functions created from formulas have a special
class. Use \code{is_lambda()} to test for it.

If a \strong{string}, the function is looked up in \code{env}. Note that
this interface is strictly for user convenience because of the
scoping issues involved. Package developers should avoid
supplying functions by name and instead supply them by value.}

\item{env}{Environment in which to fetch the function in case \code{x}
is a string.}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

\code{as_function()} transforms a one-sided formula into a function.
This powers the lambda syntax in packages like purrr.
}
\examples{
f <- as_function(~ .x + 1)
f(10)

g <- as_function(~ -1 * .)
g(4)

h <- as_function(~ .x - .y)
h(6, 3)

# Functions created from a formula have a special class:
is_lambda(f)
is_lambda(as_function(function() "foo"))
}

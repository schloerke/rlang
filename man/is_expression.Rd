% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr.R
\name{is_expression}
\alias{is_expression}
\alias{is_syntactic_literal}
\alias{is_symbolic}
\title{Is an object an expression?}
\usage{
is_expression(x)

is_syntactic_literal(x)

is_symbolic(x)
}
\arguments{
\item{x}{An object to test.}
}
\description{
In rlang, an \emph{expression} is the return type of \code{\link[=parse_expr]{parse_expr()}}, the
set of objects that can be obtained from parsing R code. Under this
definition expressions include numbers, strings, \code{NULL}, symbols,
and function calls. These objects can be classified as:
\itemize{
\item Symbolic objects, i.e. symbols and function calls (for which
\code{is_symbolic()} returns \code{TRUE})
\item Syntactic literals, i.e. scalar atomic objects and \code{NULL}
(testable with \code{is_syntactic_literal()})
}

\code{is_expression()} returns \code{TRUE} if the input is either a symbolic
object or a syntactic literal.

Note that in base R, there exists \code{\link[=expression]{expression()}} vectors, a data
type similar to a list that supports special attributes created by
the parser called source references. This data type is not
supported in rlang.
}
\details{
\code{is_symbolic()} returns \code{TRUE} for symbols and calls (objects with
type \code{language}). Symbolic objects are replaced by their value
during evaluation. Literals are the complement of symbolic
objects. They are their own value and return themselves during
evaluation.

\code{is_syntactic_literal()} is a predicate that returns \code{TRUE} for the
subset of literals that are created by R when parsing text (see
\code{\link[=parse_expr]{parse_expr()}}): numbers, strings and \code{NULL}. Along with symbols,
these literals are the terminating nodes in an AST.

Note that in the most general sense, a literal is any R object that
evaluates to itself and that can be evaluated in the empty
environment. For instance, \code{quote(c(1, 2))} is not a literal, it is
a call. However, the result of evaluating it in \code{\link[=base_env]{base_env()}} is a
literal(in this case an atomic vector).

As the data structure for function arguments, pairlists are also a
kind of language objects. However, since they are mostly an
internal data structure and can't be returned as is by the parser,
\code{is_expression()} returns \code{FALSE} for pairlists.
}
\examples{
q1 <- quote(1)
is_expression(q1)
is_syntactic_literal(q1)

q2 <- quote(x)
is_expression(q2)
is_symbol(q2)

q3 <- quote(x + 1)
is_expression(q3)
is_call(q3)


# Atomic expressions are the terminating nodes of a call tree:
# NULL or a scalar atomic vector:
is_syntactic_literal("string")
is_syntactic_literal(NULL)

is_syntactic_literal(letters)
is_syntactic_literal(quote(call()))

# Parsable literals have the property of being self-quoting:
identical("foo", quote("foo"))
identical(1L, quote(1L))
identical(NULL, quote(NULL))

# Like any literals, they can be evaluated within the empty
# environment:
eval_bare(quote(1L), empty_env())

# Whereas it would fail for symbolic expressions:
# eval_bare(quote(c(1L, 2L)), empty_env())


# Pairlists are also language objects representing argument lists.
# You will usually encounter them with extracted formals:
fmls <- formals(is_expression)
typeof(fmls)

# Since they are mostly an internal data structure, is_expression()
# returns FALSE for pairlists, so you will have to check explicitly
# for them:
is_expression(fmls)
is_pairlist(fmls)
}
\seealso{
\code{\link[=is_call]{is_call()}} for a call predicate.
}

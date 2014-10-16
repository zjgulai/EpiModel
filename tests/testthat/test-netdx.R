context("Network diagnostics")


# Setup -------------------------------------------------------------------

## Model 1: Edges Only
num <- 50
nw <- network.initialize(num, directed = FALSE)
formation <- ~ edges
target.stats <- 15
dissolution <- ~ offset(edges)
duration <- 20
coef.diss <- dissolution_coefs(dissolution, duration)
est1 <- netest(nw,
               formation,
               dissolution,
               target.stats,
               coef.diss,
               verbose = FALSE)


## Model 2: Includes offset term
n <- 50
nw <- network.initialize(n, directed = FALSE)
nw <- set.vertex.attribute(nw, "loc", rep(0:1, each = n/2))
dissolution <- ~ offset(edges)
duration <- 40
coef.diss <- dissolution_coefs(dissolution, duration)
formation <- ~ edges + offset(nodemix("loc", base=c(1, 3)))
target.stats <- 15
est2 <- netest(nw,
              formation,
              dissolution,
              target.stats,
              coef.diss,
              coef.form = -Inf,
              verbose = FALSE)


## Model 3: Includes faux-offset term
formation <- ~ edges + nodemix("loc", base=c(1, 3))
target.stats <- c(15, 0)
est3 <- netest(nw,
               formation,
               dissolution,
               target.stats,
               coef.diss,
               verbose = FALSE)


# Tests -------------------------------------------------------------------

test_that("netdx works for single simulations of edges only model", {
  dx <- netdx(est1, nsims = 1, nsteps = 10, verbose = FALSE)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx works for multiple simulations of edges only model", {
  dx <- netdx(est1, nsims = 2, nsteps = 10, verbose = FALSE)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx works for expanded monitoring formula", {
  dx <- netdx(est1, nsims = 2, nsteps = 10, verbose = FALSE,
              nwstats.formula = ~edges + concurrent)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx works for reduced monitoring formula", {
  dx <- netdx(est1, nsims = 2, nsteps = 10, verbose = FALSE,
              nwstats.formula = ~meandeg)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx for model with offset term", {
  dx <- netdx(est2, nsims = 2, nsteps = 10, verbose = FALSE)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx for model with offset term and expanded formula", {
  dx <- netdx(est2, nsims = 2, nsteps = 10, verbose = FALSE,
              nwstats.formula = ~edges + meandeg + concurrent + nodematch("loc"))
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})

test_that("netdx for model with faux offset term", {
  dx <- netdx(est3, nsims = 2, nsteps = 10, verbose = FALSE)
  expect_is(dx, "netdx")
  plot(dx)
  plot(dx, type = "duration")
  plot(dx, type = "dissolution")
})
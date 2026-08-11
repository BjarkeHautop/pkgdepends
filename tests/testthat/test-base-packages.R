test_that("drop_base_refs", {
  refs <- c(
    "pkg1",
    "parallel",
    "cran::stats",
    "bioc::tools",
    "r-lib/cli",
    "local::.",
    "*=?source"
  )
  expect_snapshot(
    keep <- drop_base_refs(parse_pkg_refs(refs))
  )
  expect_equal(keep, c(TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE))
})

test_that("base packages are not resolved as GitHub packages", {
  # `user/parallel` is a real package, not a base package
  keep <- drop_base_refs(parse_pkg_refs("user/parallel"))
  expect_true(keep)
})

test_that("direct base package refs are dropped, with a warning (#478)", {
  setup_fake_apps()
  lib <- withr::local_tempdir()

  expect_snapshot({
    p <- new_pkg_installation_proposal(
      c("parallel", "pkg1"),
      config = list(library = lib)
    )
    p$get_refs()
  })

  suppressMessages(p$resolve())
  expect_equal(unique(p$get_resolution()$package), "pkg1")

  suppressMessages(p$solve())
  expect_silent(p$stop_for_solution_error())
  expect_equal(p$get_solution()$data$package, "pkg1")
})

test_that("a base package on its own is not a solver error (#478)", {
  setup_fake_apps()
  lib <- withr::local_tempdir()

  expect_snapshot({
    p <- new_pkg_installation_proposal(
      "parallel",
      config = list(library = lib)
    )
  })

  suppressMessages(p$resolve())
  expect_equal(nrow(p$get_resolution()), 0L)

  suppressMessages(p$solve())
  expect_equal(p$get_solution()$status, "OK")
  expect_equal(nrow(p$get_solution()$data), 0L)
  expect_silent(p$stop_for_solution_error())
  expect_snapshot(p$get_solution())
})

test_that("no refs at all", {
  setup_fake_apps()
  lib <- withr::local_tempdir()

  p <- new_pkg_installation_proposal(character(), config = list(library = lib))
  suppressMessages(p$resolve())
  expect_equal(nrow(p$get_resolution()), 0L)

  suppressMessages(p$solve())
  expect_equal(p$get_solution()$status, "OK")
  expect_equal(nrow(p$get_solution()$data), 0L)
})

test_that("the whole pipeline works with nothing to install", {
  setup_fake_apps()
  lib <- withr::local_tempdir()

  p <- new_pkg_installation_proposal(character(), config = list(library = lib))
  suppressMessages(p$resolve())
  suppressMessages(p$solve())
  suppressMessages(p$download())
  expect_equal(nrow(p$get_downloads()), 0L)
  expect_equal(nrow(p$get_install_plan()), 0L)
  suppressMessages(p$install())
  expect_equal(dir(lib), character())
})

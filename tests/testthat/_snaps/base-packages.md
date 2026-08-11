# drop_base_refs

    Code
      keep <- drop_base_refs(parse_pkg_refs(refs))
    Message
      ! Ignoring base packages parallel, stats, and tools: base packages are part of R, they cannot be installed or updated separately.

# direct base package refs are dropped, with a warning (#478)

    Code
      p <- new_pkg_installation_proposal(c("parallel", "pkg1"), config = list(
        library = lib))
    Message
      ! Ignoring base package parallel: base packages are part of R, they cannot be installed or updated separately.
    Code
      p$get_refs()
    Output
      [1] "pkg1"

# a base package on its own is not a solver error (#478)

    Code
      p <- new_pkg_installation_proposal("parallel", config = list(library = lib))
    Message
      ! Ignoring base package parallel: base packages are part of R, they cannot be installed or updated separately.

---

    Code
      p$get_solution()
    Output
      <pkg_solution>
      + result: OK
      + no refs
      + no constraints
      + empty solution


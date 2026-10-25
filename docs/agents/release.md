# Release

- `dart pub publish` is run by the maintainer, never by the agent.
  `dart pub publish --dry-run` must show 0 warnings before handing over.
- Hover is verified by the maintainer, not the agent: the agent cannot hover.
  Before a release the maintainer runs the example and eyeballs hover. Report a
  hover change as tested, not as seen working, and name it for that eyeball pass.

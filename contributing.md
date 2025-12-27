# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test sourcery https://github.com/mise-plugins/mise-sourcery.git "sourcery --version"
```

Tests are automatically run in GitHub Actions on push and PR.

<div align="center">

# asdf-sourcery 

[![Build](https://github.com/younke/asdf-sourcery/actions/workflows/build.yml/badge.svg)](https://github.com/younke/asdf-sourcery/actions/workflows/build.yml) [![Lint](https://github.com/younke/asdf-sourcery/actions/workflows/lint.yml/badge.svg)](https://github.com/younke/asdf-sourcery/actions/workflows/lint.yml) [![Mise](https://github.com/younke/asdf-sourcery/actions/workflows/test-mise.yml/badge.svg)](https://github.com/younke/asdf-sourcery/actions/workflows/test-mise.yml)

[sourcery](https://krzysztofzablocki.github.io/Sourcery/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `unzip`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

# Install

Plugin:

```shell
asdf plugin add sourcery
# or
asdf plugin add sourcery https://github.com/younke/asdf-sourcery.git
```

sourcery:

```shell
# Show all installable versions
asdf list-all sourcery

# Install specific version
asdf install sourcery latest

# Set a version globally (on your ~/.tool-versions file)
asdf set -u sourcery latest

# Now sourcery commands are available
sourcery --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/younke/asdf-sourcery/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Vasily Ptitsyn](https://github.com/younke/)

# Use bats in Repositories

Create a repository...

Create a structure with submodules, e.g:

```plain
src/
    <project>.bash
    ...
test/
    bats/               <- submodule
    test_helper/
        bats-support/   <- submodule
        bats-assert/    <- submodule
    <test>.bats
    ...
```

```bash
git submodule add https://github.com/bats-core/bats-core.git test/bats
```

```bash
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
```

```bash
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```

```bash
git add .
```

```bash
git commit -m "Add bats as submodules"
```

```bash
git push
```

Init and update all submodules:

```bash
git submodule update --init --recursive
```

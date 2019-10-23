# Atlantis 1

This is the original version of Atlantis, modified and updated to be able to compile under Xcode 10 and later. It still needs a lot of work at present.

When using this repository, after the first checkout, you will want to be in the root of the repo and run the following command:

```
git config --local include.path ../.gitconfig
```

This will include the repository git configuration, which (at present) only defines a git commit template. (The reason for the `..` is that the include path is relative to the `.git` configuration directory.)
# Atlantis 1

This is the original version of Atlantis, modified and updated to be able to compile under Xcode 10 and later. It still needs a lot of work at present. Codesigning is almost certainly not going to work, as it's currently tied to my account.

To build Atlantis, you will want to make an overall directory to contain both the Atlantis project and Lemuria (the windowing toolkit on which Atlantis is built); I use `~/Source/Riverdark` myself, because Riverdark is where I've always hosted Atlantis.

Go to that directory, and execute the following; change the repo URLs as appropriate if you've forked.

```
git clone https://github.com/OpenAtlantis/Atlantis.git
git clone https://github.com/OpenAtlantis/Lemuria.git
cd Atlantis
git config --local include.path ../.gitconfig
cd ../Lemuria
git config --local include.path ../.gitconfig
```

This will ensure you have both projects checked out where Atlantis expects to find Lemuria, and will include the repository git configuration for each. 

The repository configuration only presently defines a git commit template, but I'd appreciate it if folks stuck with that template overall; it makes the commit history easier to read.

Once that's done, open the `Atlantis/Atlantis.xcodeproj` file, and you should be able to build.

There will be many warnings. So very many warnings. This codebase is Not Modernized. But at least it should build.
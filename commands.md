# grep & friends

    echo systemlist('shopt -s globstar; grep -n trim **/*.py')

# fzf

**Install & setup**:

    git clone --depth 1 https://github.com/junegunn/fzf.git
    ~/.fzf ~/.fzf/install

**Update**:

    cd ~/.fzf && git pull && ./install

**Use**:

    COMMAND [DIRECTORY/][FUZZY_PATTERN]<TAB> e.g. vim ~/<tab>

**git**:

    <ctrl-g>b for branch <ctrl-g>h for commits
    <ctrl-t> When typing a command, use ctrl-t to autocomplete e.g. $ vim ca<ctrl-t>
    <ctrl-r> commands history

# Vim

**Contribute to Vim**

- Fork and clone repo
- Always create a branch! This will be tried to be merged into the main Vim
- branch
- You have to build Vim locally: for doing that go to ./src and run make
- Tests are in testdir
- To see what happens, open vim --clean and :call test\_whatever to see what
  happens
- From shell run make test or something similar (TODO)

**LSP**

If yegapan/lsp does not work, disable vim_conda_activate LSP:
Set `:LspServer debug on` and `:LspServer restart`
   Now you can see all the messages and the error messages with `:LspServer
   debug messages/error`. You can start a LSP with verbosity on.

**clang-tidy**

You need a .clang-tidy. The checks are ordered by category

_concurrency-, clang-diagnostic-_, _clang-analyzer-_, _bugprone-_, ...

To include them, just add them. To exclude some, you can use the "-"

-\*, (avoid ALL the checks which is the default)

_-modernize-avoid-c-arrays, -modernize-use-nullptr,
-readability-identifier-length, -readability-magic-numbers_

Finally, for each check, you can specify options:

- { key: readability-identifier-naming.NamespaceCase, value: lower_case }
- { key: readability-identifier-naming.ClassCase, value: CamelCase }
- { key: readability-identifier-naming.StructCase, value: CamelCase }

# pytest

You can set an alias in the pyproject.toml

    coverage run --branch -m pytest .
    coverage run --branch -m pytest .\tests\test_dataset.py
    coverage run --branch -m pytest .\tests\test_dataset.py -k "not plot and not open_tutorial"
    # pytest: module::class::method
    coverage run --branch -m pytest tests/test_dataset.py::Test_Dataset_raise::test_validate_name_value_tuples_raise[MIMO]
    coverage report -m

# git

Track remote branch

    git fetch origin
    git branch -r
    git checkout --track origin/remote-branch-name

**Forward in time:**

    git commit

**Back in time:** Only HEAD git checkout <commit>

    # HEAD and branch (keep working directory)
      git reset --soft <commit>

    # HEAD, branch and working directory
      git reset --hard <commit>

**Rebase** (put onto main with out changes):

    git rebase -i main -Xtheirs

**diff**:

    git difftool move_fix_sampling_periods .\src\dymoval\dataset.py
    :Diff <commit-id>

**ssh/https:**

    git remote set-url origin git@github.com:ubaldot/vim-replica.git
    git remote set-url origin https://github.com/OWNER/REPOSITORY.git

How to make reviews pushed on your repo (github): Open up the .git/config file
and add a new line under [remote "origin"]:

    fetch = +refs/pull/_/head:refs/pull/origin/_
    git fetch origin git checkout -b 999 pull/origin/999 # 999 is the branch number, e.g. #999
    git checkout -b 999 pull/origin/999
    git pull https://github.com/forkuser/forkedrepo.git newfeature
    git merge newfeature
    git push origin master
    git branch -d newfeature

**tags:**

    git tag -a v1.4
    git tag -a v1.4 -m "my version 1.4"
    git tag # list tags
    git tag -a v1.2 <commit-id>
    # tag old commits
    git tag -a -f v1.4 <commit-id>
    # re-tag old commits
    git push origin v1.4
    git checkout v1.4
    # delete
    git tag -d v1

# conda

First thing to do is config (.condarc).

    conda update --name base --channel conda-forge --yes
    conda config --set channel_priority strict
    conda install -n base conda-libmamba-solver
    conda config --set solver libmamba
    conda config --set solver classic
    conda conda config --add <channels>

**common commands**:

    conda create -n dymoval_dev python=3.10

**Create environment from file** (yes, you need `conda env update`):

    conda env update --name dymoval_dev --file environment.yml
    conda env remove --name bio-env
    # view virtual environments
    conda list
    conda env list
    # Install packages from a foo.yml file
    conda env update --file foo.yml
    # Install packages in a specific environment
    conda env update --name bar --file foo.yml

**Update conda**:

    # TODO
    conda update -n base -c defaults conda

**Reproducible builds**

This is tricky...

**pip**

From a new environment:

    pip list --format=freeze > pip_freeze.txt

Then, you have to remove dymoval and you may need to edit the version of the
files already installed through conda.

    pip install -r pip_freeze.txt

**conda**

In a new environment install all the dependencies picked by the pyproject.toml
file with conda install. Or just prepare a environment.yml file. Then export:

    conda env export > environment_locked.yml

and then remove everything. Keep only the pinned dependencies that match with
the pyproject.toml file.

    # multiplatform but it does not lock versions.
    conda env export --from-history > environment.yml
    # to check that everything is installed
    conda env update --name env_name --file environment.yml
    conda list

**editable mode**

--no-deps is used for avoiding installing dependencies through pip (they
should be installed by conda)

    pip install --no-deps -e .

**update projects.toml**

You should fill out the pyproject.toml manually. For figuring out the
dependencies, run

    conda env export --from-history

The following is a great guide to how to setup project and package stuff.

    https://py-pkgs.org/04-package-structure#intra-package-references

**release**

TL;DR Update version in pyproject.toml and then

    pdm build
    pdm publish

**release on conda-forge**

Edit conda/meta.yml in this way:

1. Update version
2. Cpy sha256 from pypi where you just upload the package and replace that
   number to meta.yml. On PYPI click on dowload files, view hashes (of the
   tar.gz file)
3. run the following

   conda build conda/

You must issue a PR Pull the repo in
~/Documents/github/ubaldot/staged-recipes/ make a branch with the package name
Copy the meta.yml that you edited before in /staged-recipes/dymoval Push and
open a PR

    pip install . # install all the dependencies with pip (user).
    pip install ".[dev]" # install all the dependencies with pip (dev).

# pdm

It builds both the sdist and the wheels packages

It publish on pypi, you may want to configure your ~/.pypirc file for easy
access if you use a githib action but it is really not needed.

    pdm build pdm publish

Once done you have to make a conda package, i.e. to create a meta.yml file.

# conda setup

**build tools**

    conda install grayskull
    conda install conda-build
    conda install conda-verify
    # Not really needed
    conda install anaconda-client
    # for uploading to
    anaconda.org

**Create a meta.yml**

    grayskull pipy <your-package>

**OBS**: you first need your package published on PyPI and then you have to
manually edit it!!!

    https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html

**build.sh** if the package contains weird stuff that needs special treatment
(like source code C that needs compilation) write what you have to do in here.
If none, use

    {{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation

You can use this in the build section of the meta.yml file, so you don't need
any build.sh

**bld.bat** - same as before.

**run_test.[py,pl,sh,bat]** is a file that can trivially contain

    import <your_package>

**Optional patches** **Other files** like icons, readme, etc.

**Note**: You can "inline" into meta.yml all the build.sh, test, etc if they
are made of few lines. => In principle, you only need the meta.yml file.

Example of recipes are here:

    https://github.com/conda-forge/staged-recipes/pulls?q=is%3Apr+is%3Amerged+

Learn how to add a receipe:

    https://conda-forge.org/docs/maintainer/adding_pkgs.html#

**build** Assuming ./conda/meta.yml exists

    conda build conda/

To have conda build upload to anaconda.org automatically, use

    conda config --set anaconda_upload yes
    anaconda login

#packages can be uploaded with .tar.bz2 or .conda compression formats

    anaconda upload /path/to/conda-package.tar.bz2
    anaconda upload /path/to/conda-package.conda

# Sphinx

    cd docs
    make clean
    sphinx-apidoc -f -n -o ./docs/source ../src/dymoval/
    make html
    cd ..

# Manim dev

**Setup**

    conda install grayskull
    conda install --name base --channel defaults
    conda-build

**fetch sdist**

    poetry build --format sdist
    grayskull pypi dist/manim_v.0.18.0.tar.gz --output ./conda

**alternative**

    grayskull pypi https://github.com/ManimCommunity/manim --output ./conda

**build**

    conda build ./conda

**install**

    conda install --use-local manim --only-deps
    poetry install --only dev
    pip install -e . --no-deps

Check that you installed everything correctly

    conda env export

# Platformio

Add this to your platformio.ini:

    build_flags = -Ilib -Isrc

And then you need to run this command:

    pio run -t compiledb

This will generate a file called compile_commands.json which sets all the
include paths for all the files.

# Serialplot

see:

    https://github.com/hyOzd/serialplot/issues/5

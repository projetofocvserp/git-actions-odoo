To remove a submodule you need to:

    Delete the relevant section from the .gitmodules file.
    Stage the .gitmodules changes git add .gitmodules
    Delete the relevant section from .git/config.
    Run git rm --cached path_to_submodule (no trailing slash).
    Run rm -rf .git/modules/path_to_submodule (no trailing slash).
    Commit git commit -m "Removed submodule "
    Delete the now untracked submodule files rm -rf path_to_submodule

# Comandos basicos

- git submodule update --init --remote
- git submodule add -b BRANCH GITHUBREPO DEST/FOLDER
- git submodule sync
- git submodule update --init --recursive --remote
- git submodule foreach 'git b'

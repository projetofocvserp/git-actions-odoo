# GITHUB ACTIONS

## CONFIGURAÇÕES DE SUBMODULOS

Para remover os submodulos:

    Delete the relevant section from the .gitmodules file.
    Stage the .gitmodules changes git add .gitmodules
    Delete the relevant section from .git/config.
    Run git rm --cached path_to_submodule (no trailing slash).
    Run rm -rf .git/modules/path_to_submodule (no trailing slash).
    Commit git commit -m "Removed submodule "
    Delete the now untracked submodule files rm -rf path_to_submodule

## COMANDOS BASICOS PARA CONFIGURAÇÃO DOS SUBMODULOS

- git submodule update --init --remote
- git submodule add -b BRANCH GITHUBREPO DEST/FOLDER
- git submodule sync
- git submodule update --init --recursive --remote
- git submodule foreach 'git b'

## CONFIGURAÇÕES DE VARIÁVEIS DE AMBIENTE.

Algumas variáveis de ambiente com chaves devem ser configurada no repositório.

- Acesse e repositório, vá em configurações ( settings ), senhas e variáveis ( secrets and variables).
- Acesse o menu Ações ( actions )
- Adicione as novas chaves de configuração no repositório.
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY contendo as chaves da aws com permissões de acesso. crie um usuário de serviço especificamente para essa ação ( recomendado ).
  - Obs: as chaves da aws tem que ter permissão de deploy no kubernetes no ambiente e namespace necessário.
- SSH_PRIVATE_KEY, chave ssh criado para acesso do github, ssh-keygen
- Vá na guia de variaveis ( Variables ), crie uma nova variável CHECKOUT_BRANCH, será usada para acessar os ambientes, 14.0, homolog, etc...

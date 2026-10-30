# osx-install

Scripts para provisionar um macOS novo do zero: ferramentas de desenvolvimento, apps, fontes, shell e identidades git — tudo de forma idempotente (pode rodar quantas vezes quiser; o que já estiver instalado é pulado).

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-install.sh | sh
```

Flags disponíveis (combináveis, passadas depois do `--`):

| Flag | Efeito |
|------|--------|
| `--skip-app-store` | Pula a instalação via `mas` (Spark, Xcode) — útil quando não é possível/desejável logar na App Store na hora. |
| `--setup-git` | Configura identidades git e assinatura de commits (função `setup_git`). **Desligado por padrão** — só roda se a flag for passada. |
| `--setup-ssh` | Configura o SSH com o agente do 1Password e os hosts pessoais (função `setup_ssh`). **Desligado por padrão**. |
| `--setup-macos` | Roda o `osx-settings.sh` no fim da instalação. Rodando de um clone, usa o arquivo local; via `curl`, baixa o da `master`. **Desligado por padrão**. |

```bash
curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-install.sh | sh -s -- --skip-app-store --setup-git --setup-ssh --setup-macos
```

Para aplicar só os ajustes de sistema (Dock, trackpad, teclado, energia etc.), sem o resto:

```bash
curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-settings.sh | sh
```

## O que o `osx-install.sh` faz

### Ferramentas de linha de comando (Homebrew)

Instala o Homebrew (se necessário) e pacotes de uso diário: `gh`, `jq`, `httpie`, `tmux`, `vim`, `wget`, `direnv`, `starship`, `redis`, `libpq`, `uv`, entre outros — a lista completa está na função `install_tools`.

### Gerenciadores de versão de runtimes

Instala via git e configura no `~/.zshenv`:

| Runtime | Gerenciador | Versão padrão |
|---------|-------------|---------------|
| Node.js | [nodenv](https://github.com/nodenv/nodenv) | 24.9.0 |
| Python  | [pyenv](https://github.com/pyenv/pyenv) (+ virtualenv) | 3.13.14 |
| Go      | [goenv](https://github.com/go-nv/goenv) | 1.23.1 |
| Ruby    | [rbenv](https://github.com/rbenv/rbenv) (+ ruby-build) | 3.4.10 |

### Apps (casks e Mac App Store)

1Password, Claude (desktop), DBeaver, Docker Desktop, navegadores, Granola, Microsoft Office, Microsoft Teams, ngrok, OBS, Raycast, Slack, Spotify, VS Code, Warp, Windows App e outros — mais Spark e Xcode via `mas`. O Claude Code é instalado pelo [instalador oficial](https://claude.ai/install.sh), não via brew.

### Outros runtimes e ferramentas

Fora do brew, cada um pelo instalador oficial (pulados se já existirem):

- [bun](https://bun.sh) em `~/.bun` (o próprio instalador ajusta o `~/.zshrc`).
- .NET SDK 9.0 em `~/.dotnet`, via `dotnet-install.sh`, com `DOTNET_ROOT` no `~/.zshenv`.
- `claude-swap` via `uv tool install`.

### Fontes

Nerd Fonts (Hack, Inconsolata, JetBrains Mono) e outras fontes de uso em terminal/editor.

### Shell (oh-my-zsh + starship)

- Instala o [oh-my-zsh](https://ohmyz.sh/) em modo unattended, com os plugins `git` e `aws`.
- O tema do oh-my-zsh fica desativado: o prompt é o [starship](https://starship.rs/).
- Garante no `~/.zshrc`: `~/.local/bin` e `libpq` no PATH, hook do [direnv](https://direnv.net/) e init do starship.
- Cria o `~/.config/starship.toml` com o preset `nerd-font-symbols`, se ele ainda não existir.

### Claude Code (plugins, OMC, claude-mem, LiteLLM)

A função `setup_claude` roda depois do `install_misc`:

- Instala o CLI `omc` (`npm -g oh-my-claude-sisyphus`) e os plugins `oh-my-claudecode`, `claude-mem`, `vercel`, `warp` e `posthog`, com seus marketplaces.
- Faz merge de defaults no `~/.claude/settings.json` (modelos Opus/Sonnet com contexto de 1M, `defaultMode: auto`, agent teams, `effortLevel: high`). O que já estiver no arquivo é mantido.
- Cria `~/.config/claude-omc/config.jsonc` com o roteamento de modelos do OMC por tier.
- Gateway [LiteLLM](https://litellm.tools.danniel.xyz): lê as virtual keys dos campos `vk_claude_code` e `vk_claude_mem` do item `LiteLLM - danniel.xyz` (vault Private) do 1Password. Grava `~/.config/litellm/env` (chmod 600) e o `~/Work/.envrc`, que aponta o Claude Code para o gateway em qualquer cwd dentro de `~/Work`. Também configura o observer do claude-mem para usar o gateway. O 1Password e o `op` são instalados antes, pelo `install_casks`. Numa máquina nova, o script abre o app e espera você logar e ligar a integração com o CLI (Enter tenta de novo, `s` pula). Sem terminal interativo, ou se você pular, a etapa fica de fora e o Claude Code fala direto com a Anthropic. Rodar o script de novo depois configura o gateway.

O HUD e o `CLAUDE.md` do OMC ficam por conta do `/oh-my-claudecode:omc-setup`, rodado dentro do `claude` (ver os passos manuais).

### Identidades git (opcional, via `--setup-git`)

Configura `~/.gitconfig` com resolução automática de identidade por diretório (trabalho por padrão, pessoal em `~/Work/projects/DennyLoko/` via `includeIf`) e assinatura de commits/tags via SSH (1Password `op-ssh-sign`). Não roda a menos que `--setup-git` seja passado — em máquinas onde a identidade git já está configurada (ou é gerenciada de outra forma), o script não sobrescreve nada por padrão.

### SSH (opcional, via `--setup-ssh`)

- Com `SSH_KEY_VAULTS` (vaults separados por vírgula), grava o `~/.config/1Password/ssh/agent.toml` com as chaves desses vaults, na ordem dada. Sem a variável o arquivo não é tocado, e o agente usa o padrão do 1Password (só o vault Personal/Private/Employee). Numa máquina pessoal, basta não passar a variável. Via `curl`, a variável vai no `sh`:

  ```bash
  curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-install.sh | SSH_KEY_VAULTS=Marisa.Care,Private sh -s -- --setup-ssh
  ```
- No `~/.ssh/config`, coloca `Include ~/.ssh/config.d/*` no topo, o host `github-personal` (push nos repos pessoais com a chave do GitHub pessoal) e um `Host *` no fim apontando o `IdentityAgent` para o 1Password.
- Os hosts pessoais (endereço, usuário, forwarding) não ficam no repo. Eles vêm do campo de notas do item `SSH config` (vault Private) do 1Password e são gravados em `~/.ssh/config.d/1password` (chmod 600). A nota é a fonte da verdade: o arquivo é regravado a cada execução, então mudanças nos hosts são feitas no 1Password.
- O que já estiver no `~/.ssh/config` é mantido. Se o 1Password não estiver pronto, a parte dos hosts é pulada com um aviso (como no LiteLLM).

## O que o `osx-settings.sh` faz

Ajustes de `defaults` e `pmset` do macOS (pede `sudo` para a parte de energia):

- **Aparência**: modo escuro.
- **Finder**: mostra todas as extensões, path bar (a partir da home), caminho POSIX no título, visualização em colunas e janelas novas abrindo em Documentos.
- **Dock**: auto-hide (sem delay), ícones pequenos com magnificação, animações mais rápidas e sem apps recentes.
- **Itens do Dock** (via [`dockutil`](https://github.com/kcrawford/dockutil), instalado pelo `osx-install.sh`): o Dock é montado do zero, na ordem dada, então rodar de novo dá sempre o mesmo resultado. Por padrão: Apps, Spark Desktop, Slack, Google Chrome, Warp e Ajustes do Sistema, mais a pasta Downloads (leque, ordenada por data de inclusão). App que não estiver instalado é pulado com aviso; sem `dockutil`, a etapa toda é pulada. Para trocar a lista, passe caminhos separados por vírgula em `DOCK_APPS` e `DOCK_FOLDERS`:

  ```bash
  DOCK_APPS="/System/Applications/Apps.app,/Applications/Google Chrome.app,/Applications/Warp.app" sh osx-settings.sh
  ```
- **Mesa e janelas**: clicar no papel de parede não revela a mesa, sem margem entre janelas lado a lado, ícones e widgets da mesa ocultos.
- **Hot corner**: canto inferior direito desligado.
- **Trackpad**: toque para clicar (embutido e Bluetooth) e velocidade 1.5.
- **Teclado**: repetição de tecla rápida e sem correção automática, maiúscula automática ou ponto com espaço duplo.
- **Barra de menus**: porcentagem da bateria.
- **Descanso de tela e energia**: protetor de tela em 3h; tela apaga em 20 min na bateria e 2h na tomada; na tomada o Mac nunca dorme.

Trackpad e teclado só valem depois de sair e entrar de novo na sessão.

## Passos manuais pós-instalação

1. Entrar no 1Password e habilitar o **SSH agent** (Settings → Developer) — a autenticação SSH depende dele. O `--setup-ssh` configura o lado do SSH, mas não liga o agente.
2. Para usar o `op` CLI, habilitar a integração com o app (Settings → Developer → **Integrate with 1Password CLI**; no macOS Sequoia+ o terminal precisa de permissão para acessar dados de outros apps). Com a integração ativa o `op` autentica sob demanda — **não** coloque `op signin` no `~/.zshrc`, senão cada terminal novo dispara um prompt de autorização.
3. Abrir um terminal novo (ou `source ~/.zshrc`) para o shell recém-configurado valer.
4. Rodar `claude`, fazer login e executar `/oh-my-claudecode:omc-setup`, que instala o HUD e o `CLAUDE.md` do OMC. Depois, rodar o `osx-install.sh` de novo para ligar o HUD na status line.
5. Dentro de `~/Work`, rodar `direnv allow` se o direnv pedir.

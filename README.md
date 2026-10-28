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

```bash
curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-install.sh | sh -s -- --skip-app-store --setup-git
```

Para aplicar os ajustes de sistema (Finder, Dock, hot corners):

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

## O que o `osx-settings.sh` faz

Ajustes de `defaults` do macOS:

- **Finder**: mostra todas as extensões, path bar a partir da home e caminho POSIX no título.
- **Dock**: auto-hide (sem delay), magnificação e animações mais rápidas.
- **Hot corner**: canto inferior direito abre o Launchpad.

## Passos manuais pós-instalação

1. Entrar no 1Password e habilitar o **SSH agent** (Settings → Developer) — a autenticação SSH depende dele.
2. Para usar o `op` CLI, habilitar a integração com o app (Settings → Developer → **Integrate with 1Password CLI**; no macOS Sequoia+ o terminal precisa de permissão para acessar dados de outros apps). Com a integração ativa o `op` autentica sob demanda — **não** coloque `op signin` no `~/.zshrc`, senão cada terminal novo dispara um prompt de autorização.
3. Abrir um terminal novo (ou `source ~/.zshrc`) para o shell recém-configurado valer.
4. Rodar `claude`, fazer login e executar `/oh-my-claudecode:omc-setup`, que instala o HUD e o `CLAUDE.md` do OMC. Depois, rodar o `osx-install.sh` de novo para ligar o HUD na status line.
5. Dentro de `~/Work`, rodar `direnv allow` se o direnv pedir.

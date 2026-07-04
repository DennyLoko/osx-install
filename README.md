# osx-install

Scripts para provisionar um macOS novo do zero: ferramentas de desenvolvimento, apps, fontes, shell e identidades git — tudo de forma idempotente (pode rodar quantas vezes quiser; o que já estiver instalado é pulado).

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-install.sh | sh
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

1Password, Claude (desktop), Docker Desktop, navegadores, Raycast, Spotify, VS Code, Warp e outros — mais Spark e Xcode via `mas`. O Claude Code é instalado pelo [instalador oficial](https://claude.ai/install.sh), não via brew.

### Fontes

Nerd Fonts (Hack, Inconsolata, JetBrains Mono) e outras fontes de uso em terminal/editor.

### Shell (oh-my-zsh + starship)

- Instala o [oh-my-zsh](https://ohmyz.sh/) em modo unattended, com os plugins `git` e `aws`.
- O tema do oh-my-zsh fica desativado: o prompt é o [starship](https://starship.rs/).
- Garante no `~/.zshrc`: `~/.local/bin` e `libpq` no PATH, hook do [direnv](https://direnv.net/) e init do starship.

## O que o `osx-settings.sh` faz

Ajustes de `defaults` do macOS:

- **Finder**: mostra todas as extensões, path bar a partir da home e caminho POSIX no título.
- **Dock**: auto-hide (sem delay), magnificação e animações mais rápidas.
- **Hot corner**: canto inferior direito abre o Launchpad.

## Passos manuais pós-instalação

1. Entrar no 1Password e habilitar o **SSH agent** (Settings → Developer) — a autenticação SSH depende dele.
2. Configurar uma conta no 1Password CLI — sem isso o `op signin` do `~/.zshrc` falha com `no accounts configured` a cada shell novo. Ou habilita a integração com o app (Settings → Developer → **Integrate with 1Password CLI**, e no macOS Sequoia+ o terminal precisa de permissão para acessar dados de outros apps), ou adiciona manualmente com `op account add`.
3. Abrir um terminal novo (ou `source ~/.zshrc`) para o shell recém-configurado valer.

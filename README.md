# dotfiles

macOS（Apple Silicon）を **Nix で宣言的に管理する** ための設定です。
[nix-darwin](https://github.com/nix-darwin/nix-darwin) でシステム設定と Homebrew を、[home-manager](https://github.com/nix-community/home-manager) でユーザー環境（CLI ツール・シェル・dotfiles）を管理しています。

- CLI ツールは nixpkgs から入れる（Homebrew の formula は gcc だけ）
- GUI アプリのうち一部は Homebrew cask として宣言し、残りは手動でインストールする
- zsh（oh-my-zsh + powerlevel10k）、git、Neovim（LazyVim）、Ghostty の設定
- Dock・Finder・キーボード・トラックパッドなどの macOS の設定
- sudo を Touch ID で通す

## ディレクトリ構造

```
.
├── flake.nix            # エントリポイント。入力（nixpkgs / nix-darwin / home-manager）とホスト定義
├── flake.lock           # 入力のバージョン固定
├── darwin/              # nix-darwin（システム全体）
│   ├── system.nix       #   macOS の defaults、フォント、Touch ID sudo、ユーザー定義
│   └── homebrew.nix     #   Homebrew で管理する cask / formula、App Store アプリ
├── home/                # home-manager（ユーザー環境）
│   ├── default.nix      #   CLI パッケージ、PATH、環境変数、dotfiles のリンク
│   ├── zsh.nix          #   zsh（oh-my-zsh, p10k, autosuggestions, syntax-highlighting, エイリアス）
│   └── git.nix          #   git の設定
└── config/              # アプリの設定ファイル本体（ホームからシンボリックリンクされる）
    ├── p10k.zsh         #   → ~/.p10k.zsh
    ├── ghostty/         #   → ~/.config/ghostty
    └── nvim/            #   → ~/.config/nvim（LazyVim）
```

`config/` の中身は Nix のストアにはコピーされず、リポジトリ内のファイルを直接指すリンクになっています（`mkOutOfStoreSymlink`）。そのため、編集すると `rebuild` しなくてもすぐ反映されます。LazyVim の `lazy-lock.json` や `p10k configure` による書き込みも、そのままリポジトリに残ります。

## 管理しているもの

| 種類 | 中身 | 場所 |
|---|---|---|
| CLI（Nix） | bat, cmake, curl, direnv, eza, fastfetch, fd, fzf, gh, git, go, jq, lazygit, llama-cpp, llvm, make, neovim, ninja, nodejs, pkgconf, powershell, python3, ripgrep, sl, tree, uv, wget, zsh-completions | `home/default.nix` |
| Homebrew formula | gcc（競プロ用の `gcc-16` / `g++-16`） | `darwin/homebrew.nix` |
| Homebrew cask | azookey, codex, ghostty, homebrew-app, iterm2 | `darwin/homebrew.nix` |
| フォント | MesloLGS NF | `darwin/system.nix` |
| 手動で管理 | 上記以外の GUI アプリ、rustup（`~/.rustup`, `~/.cargo`） | — |

## 新しい Mac への導入手順

### 1. 前提ツールを入れる

Xcode Command Line Tools（git を使うため）:

```bash
xcode-select --install
```

Homebrew（nix-darwin は Homebrew 本体をインストールしないため、先に入れておく）:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Nix（Determinate Systems のインストーラ）:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

インストールが終わったら新しいターミナルを開き、`nix --version` が通ることを確認します。

> 公式インストーラを使う場合は、`darwin/system.nix` の `nix.enable` を `true` にしてください。

### 2. リポジトリを clone する

このリポジトリは `~/nix-config` に置く前提です（`config/` へのリンク先になります）。

```bash
git clone https://github.com/luna1-sol/dotfiles.git ~/nix-config
```

### 3. マシンに合わせて `flake.nix` を直す

`flake.nix` の先頭にある値を、そのマシンに合わせます。

```nix
username = "luna";               # `whoami` の結果
homeDirectory = "/Users/luna";   # `echo $HOME` の結果
repoPath = "${homeDirectory}/nix-config";  # clone した場所
```

ホスト名が `Akihiro-MacBook-Air` 以外の場合は、`darwinConfigurations."Akihiro-MacBook-Air"` の名前を `scutil --get LocalHostName` の結果に変えます。

### 4. 既存のファイルを退避する

home-manager と nix-darwin は既存のファイルを上書きしないので、ぶつかるものを先に退避します。

```bash
cd ~ && for f in .zshrc .zprofile .zshenv .gitconfig .p10k.zsh; do [ -e "$f" ] && mv "$f" "$f.before-nix"; done
```

```bash
for d in nvim ghostty; do [ -e ~/.config/$d ] && mv ~/.config/$d ~/.config/$d.before-nix; done
```

Nix のインストーラが書き換えた `/etc` のシェル設定は、nix-darwin が管理するので名前を変えておきます。

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin && sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
```

### 5. 初回の適用

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix-config
```

適用が終わったらターミナルを開き直します（Ghostty は Cmd+Q で一度終了）。以下が Nix のパスを指していれば完了です。

```bash
which git node nvim
```

## 普段の使い方

| やりたいこと | 方法 |
|---|---|
| 設定を反映する | `rebuild`（= `sudo darwin-rebuild switch --flake ~/nix-config`。sudo は Touch ID で通る） |
| パッケージを最新にする | `cd ~/nix-config && nix flake update && rebuild` |
| CLI ツールを追加する | `home/default.nix` の `home.packages` に追加して `rebuild` |
| GUI アプリを追加する | `darwin/homebrew.nix` の `casks` に追加して `rebuild` |
| エイリアス・zsh 設定を変える | `home/zsh.nix` を編集して `rebuild`（`~/.zshrc` は生成物なので直接編集しない） |
| nvim / Ghostty / p10k を変える | `config/` 以下を編集するだけ（`rebuild` は不要） |
| 前の状態に戻す | `sudo darwin-rebuild --rollback` |

パッケージ名は [search.nixos.org](https://search.nixos.org/packages) で探せます。

> flake は **git に追加されていないファイルを読みません**。新しいファイルを作ったら `git add` してから `rebuild` してください。

### Homebrew の扱い

`darwin/homebrew.nix` で `onActivation.cleanup = "uninstall"` にしているため、ここに書かれていない formula や cask は `rebuild` のたびにアンインストールされます。手動で `brew install` したものも消えるので、Homebrew で入れるものは必ず `homebrew.nix` に書いてください。GUI アプリを Homebrew を使わずに入れた場合は影響を受けません。

App Store のアプリは `masApps` に ID を書けば宣言できます（App Store へのサインインが必要）。

### プロジェクトごとの開発環境

グローバルな Node は nixpkgs の `nodejs` です。特定のバージョンが必要なプロジェクトでは、`flake.nix` に devShell を書き、direnv で自動的に読み込みます。

```bash
echo "use flake" > .envrc && direnv allow
```

## 補足

- **Rust**: rustup は Nix の管理外です。`~/.cargo/bin` は PATH に入っています。
- **gcc**: Nix の gcc は `cc` を上書きして Rust などのリンカとぶつかりやすいため、Homebrew の gcc を使っています。`gcc` / `g++` は `gcc-16` / `g++-16` のエイリアスです。
- **gdb**: Apple Silicon ではネイティブのバイナリをデバッグできないので入れていません。`lldb` を使います。

## アンインストール

1. nix-darwin を外す: `sudo darwin-uninstaller`
2. Nix を外す: `/nix/nix-installer uninstall`
3. 退避したファイル（`*.before-nix`, `/etc/*.before-nix-darwin`）を元の名前に戻す

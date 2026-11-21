# 導入手順

新しい Mac（Apple Silicon）にこの設定を入れる手順です。

## 1. 前提ツールを入れる

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

## 2. リポジトリを clone する

このリポジトリは `~/nix-config` に置く前提です（`config/` へのリンク先になります）。

```bash
git clone https://github.com/luna1-sol/dotfiles.git ~/nix-config
```

## 3. マシンに合わせて `flake.nix` を直す

`flake.nix` の先頭にある値を、そのマシンに合わせます。

```nix
username = "luna";               # `whoami` の結果
homeDirectory = "/Users/luna";   # `echo $HOME` の結果
repoPath = "${homeDirectory}/nix-config";  # clone した場所
```

ホスト名が `Akihiro-MacBook-Air` 以外の場合は、`darwinConfigurations."Akihiro-MacBook-Air"` の名前を `scutil --get LocalHostName` の結果に変えます。

## 4. 既存のファイルを退避する

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

## 5. 初回の適用

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix-config
```

適用が終わったらターミナルを開き直します（Ghostty は Cmd+Q で一度終了）。以下が Nix のパスを指していれば完了です。

```bash
which git node nvim
```

2 回目以降は `rebuild` で反映できます。使い方は [README](README.md#使用方法) を参照してください。

## アンインストール

1. nix-darwin を外す: `sudo darwin-uninstaller`
2. Nix を外す: `/nix/nix-installer uninstall`
3. 退避したファイル（`*.before-nix`, `/etc/*.before-nix-darwin`）を元の名前に戻す

# dotfiles

macOS（Apple Silicon）を **Nix で宣言的に管理する** ための設定です。
[nix-darwin](https://github.com/nix-darwin/nix-darwin) でシステム設定と Homebrew を、[home-manager](https://github.com/nix-community/home-manager) でユーザー環境（CLI ツール・シェル・dotfiles）を管理しています。

- CLI ツールは nixpkgs から入れる
- GUI アプリのうち一部は Homebrew cask として宣言し、残りは手動でインストールする
- zsh（oh-my-zsh + powerlevel10k）、git、Neovim（LazyVim）、Ghostty の設定
- Dock・Finder・キーボード・トラックパッドなどの macOS の設定
- sudo を Touch ID で通す

新しい Mac に入れるときは **[SETUP.md](SETUP.md)** を参照してください。

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

何が入っているかは各ファイルを見てください。CLI ツールは `home/default.nix` の `home.packages`、GUI アプリは `darwin/homebrew.nix` の `casks` にあります。

`config/` の中身は Nix のストアにはコピーされず、リポジトリ内のファイルを直接指すリンクになっています（`mkOutOfStoreSymlink`）。そのため、編集すると `rebuild` しなくてもすぐ反映されます。LazyVim の `lazy-lock.json` や `p10k configure` による書き込みも、そのままリポジトリに残ります。

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

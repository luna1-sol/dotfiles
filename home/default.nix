{ config, pkgs, username, homeDirectory, repoPath, ... }:
let
  # リポジトリ内のファイルへ直接シンボリックリンクを張る（編集が即反映され、
  # LazyVim の lazy-lock.json や `p10k configure` の書き込みもそのまま残る）
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoPath}/${path}";
in
{
  imports = [
    ./zsh.nix
    ./git.nix
    ./ssh.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  # 旧 Homebrew formula の置き換え
  home.packages = with pkgs; [
    bat
    cmake
    curl
    eza
    fastfetch
    fd
    gh
    go
    jq
    lazygit
    llama-cpp
    llvm
    neovim
    gnumake
    ninja
    nodejs # nvm の代わり。プロジェクトごとのバージョンは devShell + direnv で
    pkgconf
    powershell
    python3 # = python 3.14
    ripgrep
    sl
    tree
    uv
    wget
    zsh-completions
    # gdb は Apple Silicon のネイティブバイナリをデバッグできないので入れない（lldb を使う）
    # gcc は darwin/homebrew.nix 参照
    # rust は既存の rustup（~/.rustup, ~/.cargo）をそのまま使う
  ];

  # programs.neovim は ~/.config/nvim/init.lua を生成することがあり、
  # LazyVim の設定ディレクトリ（下でリンク）と衝突するのでパッケージだけ入れる
  home.sessionVariables.EDITOR = "nvim";

  programs.fzf.enable = true;

  # プロジェクトに入ると flake の devShell を自動で読み込む
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ~/.local/bin, ~/.cargo/bin などは今まで通り PATH に入れる
  home.sessionPath = [
    "${homeDirectory}/.local/bin"
    "${homeDirectory}/.cargo/bin"
    "${homeDirectory}/.antigravity-ide/antigravity-ide/bin"
    "${homeDirectory}/.lmstudio/bin"
  ];

  home.file.".p10k.zsh".source = link "config/p10k.zsh";
  xdg.configFile."nvim".source = link "config/nvim";
  xdg.configFile."ghostty".source = link "config/ghostty";

  home.stateVersion = "26.05";
}

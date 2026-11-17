{ lib, pkgs, repoPath, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      # テーマは下の plugins で p10k を読むので空にする
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      l = "ls";
      ".." = "cd ..";
      "..." = "cd ../..";
      c = "clear";

      gs = "git status";
      ga = "git add";
      gaa = "git add .";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gb = "git branch";
      gco = "git checkout";
      gl = "git log --oneline --graph --decorate";

      # 競プロ（gcc は Homebrew）
      gcc = "gcc-16";
      "g++" = "g++-16";
      "g++23" = "g++ -std=c++23 -O2 -Wall -Wextra";
      run = "g++ -std=c++23 -O2 -Wall -Wextra main.cpp && ./a.out";
      runcpp = "g++ -std=c++23 -O2 -Wall -Wextra main.cpp && ./a.out";
      vi = "nvim";
      vim = "nvim";
      ojtest = ''oj t -c "./a.out"'';

      # 設定は Nix で生成されるので、編集先はリポジトリ
      zshrc = "code ${repoPath}";
      reload = "exec zsh";
      rebuild = "sudo darwin-rebuild switch --flake ${repoPath}";
    };

    # 旧 ~/.zprofile（brew shellenv で /opt/homebrew/bin を先頭に入れていた）を
    # home-manager 管理に置き換えるため、中身は空でも生成させる
    profileExtra = "# managed by home-manager";

    initContent = lib.mkMerge [
      # p10k instant prompt は .zshrc の先頭に置く必要がある
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        setopt hist_reduce_blanks
        setopt inc_append_history

        # Homebrew に残したもの（gcc-16 など）用。Nix のパッケージを優先するため末尾に追加
        export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''
    ];
  };
}

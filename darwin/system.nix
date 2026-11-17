{ self, pkgs, username, homeDirectory, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Determinate Systems のインストーラで入れた Nix は Determinate 側が nix 本体と
  # /etc/nix/nix.conf を管理するため、nix-darwin 側の Nix 管理は切る。
  # （公式インストーラを使う場合はここを true にし、下の nix.settings を有効にする）
  nix.enable = false;
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };

  # ユーザー単位の defaults / homebrew を適用する対象ユーザー
  system.primaryUser = username;

  # nix-darwin が /etc/zshrc を管理して Nix のパスを通す
  programs.zsh.enable = true;

  # sudo を Touch ID で通す
  security.pam.services.sudo_local.touchIdAuth = true;

  # Ghostty / p10k 用の Nerd Font
  fonts.packages = [ pkgs.meslo-lgs-nf ];

  # ---- macOS の設定（2026-11-17 時点のこのMacの値を写したもの） ----
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    dock = {
      autohide = true;
      tilesize = 35;
      show-recents = false;
      mru-spaces = false;
      magnification = false;
      wvous-br-corner = 5; # 右下ホットコーナー: スクリーンセーバー
    };

    finder = {
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # リスト表示
    };

    trackpad = {
      Clicking = true; # タップでクリック
      TrackpadThreeFingerDrag = true;
    };
  };

  # 設定の世代にこの flake のリビジョンを記録する
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # 初回導入時の値。後から上げないこと。
  system.stateVersion = 6;
}

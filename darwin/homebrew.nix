{ ... }:
{
  # Homebrew 本体は nix-darwin では入らないので、既存の /opt/homebrew をそのまま使う。
  # ここに書いたものが `darwin-rebuild switch` のたびに brew bundle で揃えられる。
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # 最初は "none"（リストにないものを消さない）。
      # Nix 側で問題なく動くのを確認したら "uninstall" に変えると、
      # ここにない formula / cask（Nix に移した CLI など）が自動で消える。
      cleanup = "uninstall";
    };

    # Nix で扱いにくいものだけ brew に残す
    brews = [
      # 競プロ用の gcc-16 / g++-16（bits/stdc++.h）。Nix の gcc は cc を上書きして
      # rustc などのリンカと衝突しやすいので brew のままにする。
      "gcc"
    ];

    casks = [
      # 元から Homebrew で入れていたもの
      "azookey"
      "codex"
      "ghostty"
      "homebrew-app"
      "iterm2"
      # それ以外の GUI アプリは公式サイトなどから手動でインストールする
    ];

    # App Store のアプリ。有効にすると mas が入り、App Store にサインイン済みである必要がある。
    # 1回目の switch が通った後で必要なものだけコメントを外すのがおすすめ。
    masApps = {
      # "Xcode" = 497799835;
      # "TestFlight" = 899247664;
      # "Developer" = 640199958;
      # "Swift Playground" = 1496833156;
      # "LINE" = 539883307;
      # "RunCatNeo" = 6757801838;
      # "Microsoft Word" = 462054704;
      # "Microsoft Excel" = 462058435;
      # "Microsoft PowerPoint" = 462062816;
      # "GarageBand" = 682658836;
      # "Keynote" = 361285480;
      # "Numbers" = 361304891;
      # "Pages" = 361309726;
      # "Final Cut Pro" = 1631624924;
      # "Logic Pro" = 1615087040;
      # "Compressor" = 6746516157;
      # "MainStage" = 6746637089;
      # "Pixelmator Pro" = 6746662575;
    };
  };
}

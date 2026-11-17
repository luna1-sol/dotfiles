{
  description = "Akihiro-MacBook-Air: nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # macOS のログイン名とホームディレクトリ（このMacでは名前が異なる点に注意）
      username = "ela";
      homeDirectory = "/Users/luna";
      # このリポジトリを置く場所（dotfiles のシンボリックリンク先に使う）
      repoPath = "${homeDirectory}/nix-config";
    in
    {
      # `darwin-rebuild switch --flake .` はホスト名で自動的にこれを選ぶ
      darwinConfigurations."Akihiro-MacBook-Air" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self username homeDirectory repoPath; };
        modules = [
          ./darwin/system.nix
          ./darwin/homebrew.nix

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # 既存の ~/.zshrc などは上書きせず *.before-nix に退避する
              backupFileExtension = "before-nix";
              extraSpecialArgs = { inherit username homeDirectory repoPath; };
              users.${username} = import ./home;
            };
          }
        ];
      };
    };
}

{ ... }:
let
  email = "elavell@protonmail.com";
  # 1Password に入っている SSH 鍵（認証と同じ鍵をコミット署名にも使う）
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID956riO9mo5acuo9AIaqE8+VWZmPbc+n7jHVgj5UL90";
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "luna1-sol";
        inherit email;
        signingkey = signingKey;
      };
      init.defaultBranch = "main";

      # コミットとタグに 1Password の SSH 鍵で署名する
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
      ".direnv/"
    ];
  };

  # `git log --show-signature` などで自分の署名をローカルで検証するためのファイル
  home.file.".ssh/allowed_signers".text = "${email} ${signingKey}\n";
}

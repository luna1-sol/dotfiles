{ config, ... }:
let
  # 1Password の SSH エージェント（1Password の 設定 → 開発者 →「SSH エージェントを使用」をオンにする）
  agentSock = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "github.com" = {
        # 公開鍵を指定すると、1Password の中の対応する鍵だけが使われる
        identityFile = "~/.ssh/id_ed25519.pub";
        identitiesOnly = true;
      };

      "*" = {
        # パスに空白が入っているので引用符で囲む
        identityAgent = ''"${agentSock}"'';
      };
    };
  };

  # ssh の設定を読まないツール（git の一部の操作など）も 1Password のエージェントを使うようにする
  home.sessionVariables.SSH_AUTH_SOCK = agentSock;
}

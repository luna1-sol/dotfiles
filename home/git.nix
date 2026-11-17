{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "luna1-sol";
        email = "elavell@protonmail.com";
      };
      init.defaultBranch = "main";
    };
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
      ".direnv/"
    ];
  };
}

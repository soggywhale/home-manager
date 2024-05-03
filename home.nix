{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "whale";
  home.homeDirectory = "/home/whale";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.git = {
    enable = true;
    userName = "soggywhale";
    userEmail = "soggywhale@proton.me";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "/etc/nixos";
    };
  };
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.mako
    pkgs.libnotify
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
  #
  # Services
  #
  services.syncthing.enable = true;
  programs = {
        bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };
    lsd = {
      enable = true;
      enableAliases = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;
      shellAliases = {
        update = "sudo nixos-rebuild switch --flake r#default";
      };
      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = lib.concatStrings [
    "$package"
    "git_branch"
    "$directory"
    "$character"
  ];
      character = {
          success_symbol = "[🐳](bg:red)[](fg:red)";
          error_symbol = "[🐋](bg:red)[](fg:red)";
        };
      directory = {
          format =  "[ $path ]($style)[$read_only]($style)[](fg:blue bg:red)";
          style = "bg:blue";
        };
      git_branch = {
          format = "[$symbol$branch]($style)";
          style = "fg:blue";
          symbol = " ";
        };
      git_status = {
          format  = "[$conflicted$deleted$renamed$staged$untracked$modified$diverged$behind$ahead]($style)";
          style = "fg:blue";
          ahead = "↑";
          behind = "↓";
          conflicted = "✖";
          deleted = "✘";
          diverged = "⇕";
          modified = "±";
          renamed = "➜";
          staged = "●";
          untracked = "…";
        };
      };
         };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    waybar = {
      enable = true;
    };
    kitty = {
      enable = true;
      font.name = "SFMono Nerd Font";
      font.size = 17;
      shellIntegration.enableZshIntegration = true;
      extraConfig = "
	tab_bar_min_tabs            1
tab_bar_edge                bottom
tab_bar_style               powerline
tab_powerline_style         slanted
tab_title_template          {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}


window_padding_width 5
background_opacity 0.77

confirm_os_window_close 0

# BEGIN_KITTY_THEME
# Catppuccin-Macchiato
include $HOME/.cache/wal/colors-kitty.conf
# END_KITTY_THEME
	";
    };};

    programs.pywal.enable = true;
      xdg.configFile."lf/icons".source = ./icons;

  programs.lf = {
    enable = true;
    commands = {
      dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
      editor-open = ''$$EDITOR $f'';
      mkdir = ''
        ''${{
          printf "Directory Name: "
          read DIR
          mkdir $DIR
        }}
      '';
    };

    keybindings = {

      "\\\"" = "";
      o = "";
      c = "mkdir";
      "." = "set hidden!";
      "`" = "mark-load";
      "\\'" = "mark-load";
      "<enter>" = "open";

      do = "dragon-out";

      "g~" = "cd";
      gh = "cd";
      "g/" = "/";

      ee = "editor-open";
      V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';

      # ...
    };

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
    };

    extraConfig =
      let
        previewer = pkgs.writeShellScriptBin "pv.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5

          if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
              ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
              exit 1
          fi

          ${pkgs.pistol}/bin/pistol "$file"
        '';
        cleaner = pkgs.writeShellScriptBin "clean.sh" ''
          ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        '';
      in
      ''
        set cleaner ${cleaner}/bin/clean.sh
        set previewer ${previewer}/bin/pv.sh
      '';
  };
  gtk = {
    enable = true;
    theme = {
      name = "Lavanda-Dark";
    };
  };
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/whale/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

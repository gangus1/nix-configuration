# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      ../../modules/nixos/nvidia-beta.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  virtualisation.libvirtd.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackages = with pkgs.vimPlugins; {
        start = [ nvchad nvchad-ui ];
      };
    };
  };

  environment.shells = with pkgs; [ zsh ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
      enable = true;
      config.gnome.default = [
        "gnome"
        "gtk"
      ];
      extraPortals = with pkgs; [
        # xdg-desktop-portal-wlr
        # xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
  };

  # Enable the Deepin Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.gdm.wayland = false;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "sganguly";

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-connections
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    # gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs ( old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
            # GNOME 45: triple-buffering-v4-45
            rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
            sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
          };
        } );
      });
    })
  ];

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = "adwaita-dark";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sganguly = {
    isNormalUser = true;
    description = "Saptarshi Ganguly";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  home-manager = {
     extraSpecialArgs = {inherit inputs;};
     users = {
	    "sganguly" = import ./home.nix;
     };
  };

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  services.mullvad-vpn.enable = true;
  services.colord.enable = true;

  hardware.flipperzero.enable = true;
  hardware.ledger.enable = true;

  # programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.enable = true;
  #programs.zsh.ohMyZsh = {
  #  enable = true;
  # plugins = [ "git" "python" "man" "zsh-autosuggestions" "zsh-autocomplete" "zsh-syntaxhighlighting" ];
  #  theme = "powerlevel10k";
  #};

  services.samba = {
    enable = true;
    openFirewall = true;
    package = pkgs.samba4Full;
  };

  services.gnome.gnome-user-share.enable = true;

  programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    lshw    
    gcc
    git
    fzf
    ripgrep
    tldr
    python3

    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.search-light
    gnome.gnome-tweaks
    gnomeExtensions.transparent-window-moving
    gnomeExtensions.just-perfection
  ];

  services.flatpak.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
}

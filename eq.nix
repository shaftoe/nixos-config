{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./eq-hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    (pkgs.callPackage
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/runvoy/nixpkgs/5472f55e39bec9bb9896ad08b8f4efcac9e13a65/pkgs/by-name/ru/runvoy/package.nix";
        hash = "sha256-jOAoFeZAbGCljSnL2C9qmrW6ihTqiWnIAITur7pt5lM=";
      })
      {}
    )
    git
    lynx
    lsof
    tmux
    vim
    wget
  ];

  environment.etc."papertrail-bundle.pem".source = pkgs.fetchurl {
    url = "https://papertrailapp.com/tools/papertrail-bundle.pem";
    sha256 = "sha256-rjHss8bp/zFUy3pV8BcJBEj4hILw6UrJJ8DGeh8zuc8=";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "plexmediaserver"
  ];

  networking.hostName = "eq";
  networking.domain = "l3x.in";
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.openssh.enable = true;
  services.ntp.enable = true;
  services.plex = {
    enable = true;
    openFirewall = true;
  };
  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      locations."/" = {
        return = "301 http://eq.l3x.in:32400/";
      };
    };
  };
  services.rsyslogd = {
    enable = true;
    extraConfig = ''
      $DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs
      $ActionSendStreamDriver gtls # use gtls netstream driver
      $ActionSendStreamDriverMode 1 # require TLS
      $ActionSendStreamDriverAuthMode x509/name # authenticate by hostname
      $ActionSendStreamDriverPermittedPeer *.papertrailapp.com
      *.* @@logs5.papertrailapp.com:50971
    '';
  };

  system.stateVersion = "25.11";
}

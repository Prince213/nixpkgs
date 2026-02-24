{ lib, ... }:
{
  name = "mox";

  meta.maintainers = with lib.maintainers; [
    prince213
  ];

  nodes.machine =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      systemd.services.mox-setup = {
        description = "Mox Setup";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "network-online.target"
          "unbound.service"
        ];
        after = [
          "network-online.target"
          "unbound.service"
        ];
        before = [ "mox.service" ];
        serviceConfig = {
          WorkingDirectory = "/var/lib/mox";
          Type = "oneshot";
          RemainAfterExit = true;
          User = "mox";
          Group = "mox";
          ExecStart = "${lib.getExe pkgs.mox} quickstart -hostname mail admin@example.com";
        };
      };

      systemd.services.mox = {
        wantedBy = [ "multi-user.target" ];
        after = [ "mox-setup.service" ];
        requires = [ "mox-setup.service" ];
        serviceConfig = {
          WorkingDirectory = "/var/lib/mox";
          ExecStart = "${lib.getExe pkgs.mox} -config /var/lib/mox/config/mox.conf serve";
          Restart = "always";
        };
      };

      users.users.mox = {
        isSystemUser = true;
        name = "mox";
        group = "mox";
        home = "/var/lib/mox";
        createHome = true;
        description = "Mox Mail Server User";
      };
      users.groups.mox = { };

      environment.systemPackages = [
        pkgs.mox
        pkgs.unbound
      ];

      environment.etc."resolv.conf".text = ''
        nameserver 127.0.0.1
      '';

      networking.nameservers = [ "127.0.0.1" ];
      networking.hosts = {
        "127.0.0.1" = [
          "com."
          "mail.example.com"
          "example.com"
        ];
      };

      # Use unbound as a local DNS resolver and dissable DNSSEC validation
      # Listen only on the localhost interface both for IPv4 and IPv6
      # Define a local zone for com. to redirect queries to localhost and provide a static response
      # Define static DNS records
      services.unbound = {
        enable = true;
        resolveLocalQueries = true;
        enableRootTrustAnchor = false;
        settings = {
          server = {
            interface = [ "127.0.0.1" ];
            access-control = [
              "127.0.0.1/8 allow"
              "::1/128 allow"
            ];
          };
          local-zone = [
            "\"com.\" redirect"
          ];
          local-data = [
            "\"com. IN NS localhost\""
            "\"localhost. IN A 127.0.0.1\""
          ];
        };
      };
    };

  testScript = ''
    start_all()

    # Wait for machine to be available
    machine.wait_for_unit("multi-user.target")

    # Verify the mox service is running
    machine.wait_for_unit("mox.service")

    # Verify config file exists
    machine.succeed("test -f /var/lib/mox/config/mox.conf")

    # Verify mox user was created
    machine.succeed("getent passwd mox")

    # Check if ports are listening (assuming default SMTP port)
    machine.wait_until_succeeds("ss -tln | grep ':25 '")

    # Test running the mox command
    machine.succeed("mox version")

    # Check logs for any errors
    machine.succeed("journalctl -u mox.service --no-pager | grep -v 'error|failed'")
  '';

  interactive.sshBackdoor.enable = true;
}

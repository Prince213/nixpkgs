{ lib, ... }:
{
  name = "mox";

  meta.maintainers = with lib.maintainers; [
    prince213
  ];

  nodes.machine =
    { pkgs, config, ... }:
    {
      system.services.mox = {
        imports = [ pkgs.mox.services.default ];
        mox = {
          hostname = "mail";
          user = "admin@example.com";
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
        config.system.services.mox.mox.package
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

      systemd.services.mox-setup = {
        description = "Mox Setup";
        requires = [
          "unbound.service"
        ];
        after = [
          "unbound.service"
        ];
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

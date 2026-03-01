{
  lib,
  buildGoModule,
  buildPackages,
  coreutils,
  cronet-go,
  fetchFromGitHub,
  go,
  installShellFiles,
  nixosTests,
  stdenvNoCC,

  withStaticCronet ? true,
  withNaiveOutbound ? false,
}:
assert withNaiveOutbound -> !withStaticCronet -> stdenvNoCC.hostPlatform.isLinux;
buildGoModule (finalAttrs: {
  pname = "sing-box";
  version = "1.13.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lhkz/mXydZz5iJllqSp4skA4+jxs8oUmon/oFs98Zfc=";
  };

  vendorHash = "sha256-vVLaG0PV1OXA+YL67BnrHJiSkNVzJbZ8TeMKbO2rMu0=";

  tags = [
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_gvisor"
    "with_tailscale"
  ]
  ++ lib.optional withNaiveOutbound "with_naive_outbound"
  ++ lib.optional (withNaiveOutbound && !withStaticCronet) "with_purego";

  subPackages = [
    "cmd/sing-box"
  ];

  env = {
    CGO_ENABLED = 0;
  }
  // lib.optionalAttrs (withNaiveOutbound && withStaticCronet) {
    CGO_ENABLED = 1;
    CGO_LDFLAGS = "-fuse-ld=lld";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optional (withNaiveOutbound && withStaticCronet) buildPackages.rustc.llvmPackages.bintools;

  buildInputs = lib.optional (withNaiveOutbound && withStaticCronet) cronet-go;

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
  ];

  preBuild = lib.optionalString withNaiveOutbound ''
    cd vendor/github.com/sagernet/cronet-go
    chmod -R u+w .
    cp -r ${cronet-go}/ .
    ${lib.optionalString (!withStaticCronet) ''
      patch -p1 < ${./cronet-go.patch}
      substituteInPlace internal/cronet/loader_unix.go \
        --subst-var out
    ''}
    cd ../../../..
  '';

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf
  ''
  + lib.optionalString (withNaiveOutbound && !withStaticCronet) ''
    ln -s "${cronet-go}/lib/${go.GOOS}_${go.GOARCH}/libcronet.so" "$out/lib/"
  '';

  passthru = {
    tests = { inherit (nixosTests) sing-box; };
  };

  meta = {
    homepage = "https://sing-box.sagernet.org";
    description = "Universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      nickcao
      prince213
    ];
    mainProgram = "sing-box";
  };
})

{
  fetchgit,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mpackage";
  version = "0-unstable-2025-05-07";

  src = fetchgit {
    url = "https://git.midipix.org/mpackage";
    rev = "96402bc16930375a5992a8244e01b4dd332c8d76";
    hash = "sha256-LX2FeV8N0U6U9hdt+GaE8Qsic9eGDjIPcWQijB6Retk=";
  };

  installFlags = [
    "DESTDIR=$(out)"
  ];

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Basic configuration and installation scripts for a midipix-based distribution";
    homepage = "https://git.midipix.org/mpackage";
    changelog = "https://git.midipix.org/mpackage/log/";
    license = with lib.licenses; [
      # COPYING.MPACKAGE
      gpl2Plus
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
  };
})

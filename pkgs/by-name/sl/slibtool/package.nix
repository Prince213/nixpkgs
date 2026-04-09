{
  fetchgit,
  gnum4,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slibtool";
  version = "0.7.4-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/slibtool";
    rev = "fba3f81c9270cff16900140e6a370984b46b5c1c";
    hash = "sha256-ioHcLdaTCHp0lj/PU0jd3sjwPnLVFXmATsq1SUYKJoY=";
  };

  nativeBuildInputs = [
    gnum4
  ];

  meta = {
    description = "Strong libtool implementation, written in C";
    homepage = "https://git.midipix.org/slibtool";
    changelog = "https://git.midipix.org/slibtool/log/";
    license = with lib.licenses; [
      # COPYING.SLIBTOOL
      # COPYING.SOFORT
      mit
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
  };
})

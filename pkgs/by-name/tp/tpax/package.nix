{
  fetchgit,
  gnum4,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tpax";
  version = "0-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/tpax";
    rev = "1ea593b08cb3c3c917f9a65b2cbd4f85db6eaa6c";
    hash = "sha256-K8PLhKR9Kca8ajKJjvvFzysdzEF9w/ALE1LmpC6nfXQ=";
  };

  nativeBuildInputs = [
    gnum4
  ];

  meta = {
    description = "Topological pax(1) implementation";
    homepage = "https://git.midipix.org/tpax";
    changelog = "https://git.midipix.org/tpax/log/";
    license = with lib.licenses; [
      # COPYING.TPAX
      gpl2Plus
      # COPYING.SOFORT
      mit
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
    mainProgram = "tpax";
  };
})

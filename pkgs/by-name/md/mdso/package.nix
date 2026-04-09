{
  fetchgit,
  gnum4,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mdso";
  version = "0-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/mdso";
    rev = "70e4a66d0e352118cd0790cf7adabc4047878698";
    hash = "sha256-l5k78HWFU5sKH0Vi39U1LH/QKB/FdJseVqGfxx1PCeQ=";
  };

  nativeBuildInputs = [
    gnum4
  ];

  meta = {
    description = "Portable, cross-platform tool for creating midipix-specific import libraries";
    homepage = "https://git.midipix.org/mdso";
    changelog = "https://git.midipix.org/mdso/log/";
    license = with lib.licenses; [
      # COPYING.MDSO
      gpl2Plus
      # COPYING.SOFORT
      mit
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
    mainProgram = "mdso";
  };
})

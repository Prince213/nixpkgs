{
  fetchgit,
  gnum4,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "perk";
  version = "0-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/perk";
    rev = "b16e125584f1b26b732b93b98432f228972c7d58";
    hash = "sha256-QzyVVV/YgGc825FlaMOhoLwZKqL+/shGlZBIPzN2mIo=";
  };

  nativeBuildInputs = [
    gnum4
  ];

  meta = {
    description = "PE Resource Kit";
    homepage = "https://git.midipix.org/perk";
    changelog = "https://git.midipix.org/perk/log/";
    license = with lib.licenses; [
      # COPYING.PERK
      gpl2Plus
      # COPYING.SOFORT
      mit
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
    mainProgram = "perk";
  };
})

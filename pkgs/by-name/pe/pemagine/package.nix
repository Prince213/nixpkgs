{
  fetchgit,
  gnum4,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pemagine";
  version = "0-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/pemagine";
    rev = "4ea97c18bcc8970fb42a8804be1dcb3f03342296";
    hash = "sha256-zErjCx3itrd+POCIUg1TomqajTggU17oEiD2nOqf4GQ=";
  };

  nativeBuildInputs = [
    gnum4
  ];

  meta = {
    description = "Tour into portable bits and executable bytes";
    homepage = "https://git.midipix.org/pemagine";
    changelog = "https://git.midipix.org/pemagine/log/";
    license = with lib.licenses; [
      # COPYING.PEMAGINE
      gpl2Plus
      # COPYING.SOFORT
      mit
    ];
    maintainers = with lib.maintainers; [
      prince213
    ];
    broken = true;
  };
})

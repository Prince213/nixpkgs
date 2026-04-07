{
  fetchgit,
  gnum4,
  musl,
  stdenvNoLibc,
}:

stdenvNoLibc.mkDerivation (finalAttrs: {
  pname = "musl-midipix";
  version = "${musl.version}-2026-02-17";

  src = fetchgit {
    url = "https://git.midipix.org/mmglue";
    rev = "169a1c041a9dc4f19abfa6fd8290e79d5aa03948";
    hash = "sha256-otmFflw9dnGcwQpchCKYWLqijkMF5GhVAj0r65fSO4o=";
  };

  postUnpack = ''
    tar xf ${musl.src}
  '';

  patches = [
    ./mb_ccenv_skip_native.patch
  ];

  postPatch = ''
    substituteInPlace project/extras.mk \
      --replace-fail 'ar -crs' '$(AR) -crs'
  '';

  nativeBuildInputs = [
    gnum4
  ];

  configureFlags = [
    "--source-dir=../musl-${musl.version}"
  ];

  env = {
    ccenv_native_cc = "";
    mb_native_cchost = "";
  };
})

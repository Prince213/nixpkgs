{
  stdenv,
  fetchurl,
  fetchpatch,
  autoreconfHook,
  makeWrapper,
  pkg-config,
  ocaml,
  findlib,
  libxml2,
  augeas,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ocaml-augeas";
  version = "0.6";

  src = fetchurl {
    url = "https://people.redhat.com/~rjones/augeas/files/ocaml-augeas-0.6.tar.gz";
    sha256 = "04bn62hqdka0658fgz0p0fil2fyic61i78plxvmni1yhmkfrkfla";
  };

  patches = [
    (fetchpatch {
      url = "https://salsa.debian.org/debian/ocaml-augeas/-/raw/07c2408a7e5a06cefe5d53a89fecaa8556a39b06/debian/patches/0001-Use-ocamlopt-g-option.patch";
      hash = "sha256-EMd/EfWO2ni0AMonfS7G5FENpVVq0+q3gUPd4My+Upg=";
    })
    (fetchpatch {
      url = "https://salsa.debian.org/debian/ocaml-augeas/-/raw/07c2408a7e5a06cefe5d53a89fecaa8556a39b06/debian/patches/0002-caml_named_value-returns-const-value-pointer-in-OCam.patch";
      hash = "sha256-Y53UHwrTVeV3hnsvABmWxlPi2Fanm0Iy1OR8Zql5Ub8=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    ocaml
    findlib
    augeas
    libxml2
  ];

  createFindlibDestdir = true;

  meta = with lib; {
    homepage = "https://people.redhat.com/~rjones/augeas/";
    description = "OCaml bindings for Augeas";
    license = with licenses; lgpl21Plus;
    platforms = with platforms; linux;
  };
}

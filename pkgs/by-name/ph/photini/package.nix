{
  lib,
  fetchFromGitHub,
  python3Packages,
  gitUpdater,
}:

python3Packages.buildPythonApplication rec {
  pname = "photini";
  version = "2024.9.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jim-easterbrook";
    repo = "Photini";
    tag = version;
    hash = "sha256-0jr1mNejCF0yW9LkrrsOTcE4ZPGZrMU9Pnt0eXD+3YQ=";
  };

  build-system = with python3Packages; [ setuptools-scm ];
  dependencies = with python3Packages; [
    pyside6
    cachetools
    appdirs
    chardet
    exiv2
    filetype
    requests
    requests-oauthlib
    requests-toolbelt
    pyenchant
    gpxpy
    keyring
    pillow
    toml
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    homepage = "https://github.com/jim-easterbrook/Photini";
    changelog = "https://photini.readthedocs.io/en/release-${version}/misc/changelog.html";
    description = "Easy to use digital photograph metadata (Exif, IPTC, XMP) editing application";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zebreus ];
    mainProgram = "photini";
  };
}

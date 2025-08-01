{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  openjdk17,
  makeWrapper,
  autoPatchelfHook,
  zlib,
  libzen,
  libmediainfo,
  curlWithGnuTls,
  libmms,
  glib,
  genericUpdater,
  writeShellScript,
}:

let
  lanterna = fetchurl {
    url = "https://search.maven.org/remotecontent?filepath=com/googlecode/lanterna/lanterna/3.1.1/lanterna-3.1.1.jar";
    hash = "sha256-7zxCeXYW5v9ritnvkwRpPKdgSptCmkT3HJOaNgQHUmQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "filebot";
  version = "5.1.7";

  src = fetchurl {
    url = "https://web.archive.org/web/20230917142929/https://get.filebot.net/filebot/FileBot_${finalAttrs.version}/FileBot_${finalAttrs.version}-portable.tar.xz";
    hash = "sha256-GpjWo2+AsT0hD3CJJ8Pf/K5TbWtG0ZE2tIpH/UEGTws=";
  };

  unpackPhase = "tar xvf $src";

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    libzen
    libmediainfo
    curlWithGnuTls
    libmms
    glib
  ];

  postPatch = ''
    # replace lanterna.jar to be able to specify `com.googlecode.lanterna.terminal.UnixTerminal.sttyCommand`
    cp ${lanterna} jar/lanterna.jar
  '';

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/opt $out/bin
    # Since FileBot has dependencies on relative paths between files, all required files are copied to the same location as is.
    cp -r filebot.sh jar/ $out/opt/
    # Copy lib based on platform and force filebot to use libmediainfo.so from nix
    local platformDir
    case "${stdenv.hostPlatform.system}" in
      "x86_64-linux")
        platformDir="Linux-x86_64"
        ;;
      "aarch64-linux")
        platformDir="Linux-aarch64"
        ;;
    esac
    if [ -n "$platformDir" ]; then
      mkdir -p "$out/opt/lib"
      cp -r "lib/$platformDir" "$out/opt/lib/"
      rm "$out/opt/lib/$platformDir/libmediainfo.so"
      ln -s "${libmediainfo}/lib/libmediainfo.so" "$out/opt/lib/$platformDir/"
    fi
    # Filebot writes to $APP_DATA, which fails due to read-only filesystem. Using current user .local directory instead.
    substituteInPlace $out/opt/filebot.sh \
      --replace 'APP_DATA="$FILEBOT_HOME/data/$(id -u)"' 'APP_DATA=''${XDG_DATA_HOME:-$HOME/.local/share}/filebot/data' \
      --replace '$FILEBOT_HOME/data/.license' '$APP_DATA/.license' \
      --replace '-jar "$FILEBOT_HOME/jar/filebot.jar"' '-Dcom.googlecode.lanterna.terminal.UnixTerminal.sttyCommand=${coreutils}/bin/stty -jar "$FILEBOT_HOME/jar/filebot.jar"'
    wrapProgram $out/opt/filebot.sh \
      --prefix PATH : ${lib.makeBinPath [ openjdk17 ]}
    # Expose the binary in bin to make runnable.
    ln -s $out/opt/filebot.sh $out/bin/filebot
  '';

  passthru.updateScript = genericUpdater {
    versionLister = writeShellScript "filebot-versionLister" ''
      curl -s https://www.filebot.net \
        | sed -rne 's,^.*FileBot_([0-9]*\.[0-9]+\.[0-9]+)-portable.tar.xz.*,\1,p'
    '';
  };

  meta = with lib; {
    description = "Ultimate TV and Movie Renamer";
    longDescription = ''
      FileBot is the ultimate tool for organizing and renaming your Movies, TV
      Shows and Anime as well as fetching subtitles and artwork. It's smart and
      just works.
    '';
    homepage = "https://filebot.net";
    changelog = "https://www.filebot.net/forums/viewforum.php?f=7";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      gleber
      felschr
    ];
    platforms = platforms.linux;
    mainProgram = "filebot";
  };
})

{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenvNoCC fetchurl lib autoPatchelfHook makeWrapper;
in
  stdenvNoCC.mkDerivation (finalAttrs: rec {
    pname = "PixiEditor";
    version = "2.0.1.7";

    #todo: It works. But I need to upgrade its version, its outdated. Its kinda boring to do that manually all the time.
    # Remote tarball (preferred for reproducibility)
    src = fetchurl {
      url = "https://github.com/PixiEditor/PixiEditor/releases/download/2.0.1.7/PixiEditor-2.0.1.7-amd64-linux.tar.gz";
      sha256 = "15xk5h6pk6sy0vziia9cnw2p79kp8m693h5xm5m5253knjvj20jd";
    };

    # If the tarball unpacks straight into files with no top-level directory:
    sourceRoot = ".";

    # GUI app
    doInstallCheck = false;

    nativeBuildInputs = [
      autoPatchelfHook # automatically fixes ELF interpreter + RPATH
      makeWrapper # provides wrapProgram for convenience
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      lttng-ust
      liburcu
      util-linux
      fontconfig
      freetype
      icu # <-- provides libicui18n/icuuc/icudata
      libunwind # common for .NET
      openssl # if TLS used
      harfbuzz
      libpng
      expat

      # X11 + GL
      libGL
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXfixes
      xorg.libXi
      xorg.libxcb
      xorg.libICE
      xorg.libSM
    ];

    desktopItem = pkgs.makeDesktopItem {
      name = "PixiEditor";
      exec = "PixiEditor %F";
      desktopName = "PixiEditor";
      genericName = "PixiEditor";
      comment = "Universal 2D Graphics Editor";
      categories = ["Graphics" "RasterGraphics" "VectorGraphics"];
      icon = "PixiEditorLogo"; # must match installed icon name
    };

    # No build – just install the unpacked files into $out
    installPhase = ''
      runHook preInstall

      # Install supporting files
        mkdir -p $out/share/${pname}
      cp -r ./* $out/share/${pname}/

      # Symlink for main binary
      mkdir -p $out/bin
      ln -s $out/share/${pname}/PixiEditor $out/bin/PixiEditor

      runHook postInstall
    '';

    postInstall = ''
      libPath=${pkgs.lib.makeLibraryPath [
        pkgs.icu
        pkgs.zlib
        pkgs.libunwind
        pkgs.openssl
        pkgs.fontconfig
        pkgs.freetype
        pkgs.harfbuzz
        pkgs.libpng
        pkgs.expat
        pkgs.libGL
        pkgs.xorg.libX11
        pkgs.xorg.libXext
        pkgs.xorg.libXrender
        pkgs.xorg.libXrandr
        pkgs.xorg.libXcursor
        pkgs.xorg.libXfixes
        pkgs.xorg.libXi
        pkgs.xorg.libxcb
        pkgs.xorg.libICE
        pkgs.xorg.libSM
        pkgs.lttng-ust
        pkgs.liburcu
        pkgs.util-linux
      ]}

      wrapProgram $out/bin/PixiEditor \
      	--prefix LD_LIBRARY_PATH : "$libPath" \
      	--set-default SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      	--set-default FONTCONFIG_FILE "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" \
      	--set-default FONTCONFIG_PATH "${pkgs.fontconfig.out}/etc/fonts" \
      	--set-default XDG_DATA_DIRS "${pkgs.fontconfig.out}/share" \
      	--run '
      		[ -z "$XDG_CACHE_HOME" ] && XDG_CACHE_HOME="$HOME/.cache"
      		[ -z "$MESA_SHADER_CACHE_DIR" ] && MESA_SHADER_CACHE_DIR="$XDG_CACHE_HOME/mesa_shader_cache"
      		export XDG_CACHE_HOME MESA_SHADER_CACHE_DIR
      		mkdir -p "$MESA_SHADER_CACHE_DIR"
      	'

      # Desktop install
      mkdir -p $out/share/applications
      cp -r ${desktopItem}/share/applications/* $out/share/applications/
      install -Dm644 ${./PixiEditorLogo.svg} \
      	$out/share/icons/hicolor/scalable/apps/PixiEditorLogo.svg
    '';

    postFixup = ''
      set -e
      so="$out/share/PixiEditor/libcoreclrtraceptprovider.so"
      if [ -f "$so" ]; then
      	if patchelf --print-needed "$so" | grep -q 'liblttng-ust.so.0'; then
      		# Point it to the SONAME that nixpkgs actually provides
      		patchelf --replace-needed liblttng-ust.so.0 liblttng-ust.so.1 "$so"
      	fi
      fi
    '';

    meta = with lib; {
      description = "PixiEditor packaged from official site installation .tar.gz";
      homepage = "https://pixieditor.net/download/";
      license = licenses.lgpl3;
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  })

{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, meson
, ninja
, pkg-config
, cmake
, libarchive
, gettext
, glib
, perl
, wrapGAppsHook3
, gtk3
, openssl
, libcanberra-gtk3
, libayatana-appindicator
, libsecret
, lua5_4
, python3
, pciutils
, isocodes
, enchant
, gsettings-desktop-schemas
, desktop-file-utils
, copyDesktopItems
, makeDesktopItem
, librsvg
}:

let
  src = lib.importJSON ../sources.json;

  publicSuffixList = fetchurl {
    url = "https://raw.githubusercontent.com/publicsuffix/list/a179a48c465e818cfd8d626691cb317985da87fb/public_suffix_list.dat";
    hash = "sha256-czMZL4GFiNnQBE0n1nIQx4Ks1th89x9UoA36IKVhz8k=";
  };

  buildPython = python3.withPackages (ps: [ ps.cffi ]);
in
stdenv.mkDerivation {
  pname = "zoitechat";
  inherit (src) version;

  src = fetchFromGitHub {
    owner = "ZoiteChat";
    repo = "zoitechat";
    inherit (src) rev hash;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    libarchive.dev
    gettext
    glib.dev
    perl
    buildPython
    desktop-file-utils
    copyDesktopItems
    librsvg
    wrapGAppsHook3
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "zoitechat";
      exec = "${placeholder "out"}/bin/zoitechat --existing %U";
      icon = "zoitechat";
      desktopName = "ZoiteChat";
      genericName = "IRC Client";
      comment = "Chat with other people online";
      categories = [ "GTK" "Network" "IRCClient" ];
      mimeTypes = [ "x-scheme-handler/irc" "x-scheme-handler/ircs" ];
    })
  ];

  buildInputs = [
    glib
    gtk3
    openssl
    libcanberra-gtk3
    libayatana-appindicator
    libsecret
    lua5_4
    python3
    libarchive
    perl
    pciutils
    isocodes
    enchant
    gsettings-desktop-schemas
  ];

  mesonFlags = [
    (lib.mesonBool "gtk-frontend" true)
    (lib.mesonBool "plugin" true)
    (lib.mesonBool "install-appdata" false)
    (lib.mesonBool "with-checksum" true)
    (lib.mesonBool "with-fishlim" true)
    (lib.mesonBool "with-sysinfo" true)
    (lib.mesonOption "with-lua" "lua-5.4")
    (lib.mesonOption "with-python" "python3-embed")
    (lib.mesonOption "with-perl" "${perl}/bin/perl")
  ];

  postInstall = ''
    rm -f "$out/share/applications/net.zoite.Zoitechat.desktop"

    svg="$sourceRoot/data/icons/zoitechat.svg"
    icondir="$out/share/icons/hicolor"

    if [ ! -f "$svg" ]; then
      echo "postInstall: no icon at $svg" >&2
      exit 1
    fi

    install -Dm444 "$svg" "$out/share/pixmaps/zoitechat.svg"
    install -Dm444 "$svg" "$icondir/scalable/apps/zoitechat.svg"

    for size in 48 128 256 512; do
      install -d "$icondir/$size"'x'"$size/apps"
      rsvg-convert -w "$size" -h "$size" "$svg" \
        -o "$icondir/$size"'x'"$size/apps/zoitechat.png"
    done
  '';

  postPatch = ''
    patchShebangs .
    sed -i "1s|.*|#!${buildPython}/bin/python3|" plugins/python/generate_plugin.py
    substituteInPlace plugins/sysinfo/meson.build \
      --replace-fail "sysinfo_cargs = ['-DHAVE_CONFIG_H']" \
      "sysinfo_cargs = ['-DHAVE_CONFIG_H', '-D_DEFAULT_SOURCE']"
    cp ${publicSuffixList} src/common/public_suffix_list.dat
  '';

  meta = {
    description = "GTK3 IRC client based on HexChat";
    homepage = "https://zoitechat.org";
    license = lib.licenses.gpl2Plus;
    mainProgram = "zoitechat";
    platforms = lib.platforms.linux;
  };
}

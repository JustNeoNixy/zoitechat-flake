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

  postPatch = ''
    patchShebangs .
    sed -i "1s|.*|#!${buildPython}/bin/python3|" plugins/python/generate_plugin.py
    substituteInPlace plugins/sysinfo/meson.build \
      --replace-fail "sysinfo_cargs = ['-DHAVE_CONFIG_H']" \
      "sysinfo_cargs = ['-DHAVE_CONFIG_H', '-D_DEFAULT_SOURCE']"
    cp ${publicSuffixList} src/common/public_suffix_list.dat
  '';

  postInstall = ''
    rm -f "$out/share/applications/net.zoite.Zoitechat.desktop"

    svg="$out/share/icons/hicolor/scalable/apps/zoitechat.svg"
    icon="$out/share/icons/hicolor/48x48/apps/zoitechat.png"

    if [ -f "$svg" ]; then
      install -d "$out/share/icons/hicolor/256x256/apps"
      rsvg-convert -w 256 -h 256 "$svg" \
        -o "$out/share/icons/hicolor/256x256/apps/zoitechat.png"
      icon="$out/share/icons/hicolor/256x256/apps/zoitechat.png"
    fi

    echo "postInstall: icon=$icon"
    test -f "$icon" || echo "postInstall: WARNING icon missing" >&2

    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/zoitechat.desktop" <<EOF
[Desktop Entry]
Name=ZoiteChat
GenericName=IRC Client
Comment=Chat with other people online
Exec=$out/bin/zoitechat --existing %U
Icon=$icon
Terminal=false
Type=Application
Categories=GTK;Network;IRCClient;
StartupNotify=true
StartupWMClass=net.zoite.Zoitechat
X-GNOME-UsesNotifications=true
MimeType=x-scheme-handler/irc;x-scheme-handler/ircs;
EOF

    desktop-file-validate "$out/share/applications/zoitechat.desktop" || true
  '';

  meta = {
    description = "GTK3 IRC client based on HexChat";
    homepage = "https://zoitechat.org";
    license = lib.licenses.gpl2Plus;
    mainProgram = "zoitechat";
    platforms = lib.platforms.linux;
  };
}

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

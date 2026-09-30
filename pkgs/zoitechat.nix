{ lib
, stdenv
, fetchFromGitHub
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
    patchShebangs meson_post_install.py tools 2>/dev/null || true
  '';

  meta = {
    description = "GTK3 IRC client based on HexChat";
    homepage = "https://zoitechat.org";
    license = lib.licenses.gpl2Plus;
    mainProgram = "zoitechat";
    platforms = lib.platforms.linux;
  };
}

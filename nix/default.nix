{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  libva,
  libGL,
  vulkan-loader,
  wayland,
  libpulseaudio,
  pciutils,
}:

let
  pins = import ./hashes.nix;
  pname = "helium";
  inherit (pins) version;
  asset =
    pins.assets.${stdenv.hostPlatform.system}
      or (throw "helium: no AppImage pin for ${stdenv.hostPlatform.system}");
  src = fetchurl {
    url = "https://github.com/${pins.binary.owner}/${pins.binary.repo}/releases/download/${version}/${asset.name}";
    inherit (asset) hash;
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
  rpath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libgbm
    nspr
    nss
    pango
    pipewire
    systemd
    libva
    libGL
    vulkan-loader
    wayland
    libpulseaudio
    pciutils
  ];
in
stdenv.mkDerivation {
  inherit pname version;
  src = appimageContents;

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -a opt/helium $out/share/helium
    cp -a usr/share/* $out/share/ 2>/dev/null || true

    install -Dm644 ${appimageContents}/helium.desktop \
      $out/share/applications/helium.desktop

    if [ -f ${appimageContents}/helium.png ]; then
      install -Dm644 ${appimageContents}/helium.png \
        $out/share/icons/hicolor/256x256/apps/helium.png
    fi
    if [ -d ${appimageContents}/usr/share/icons ]; then
      cp -a ${appimageContents}/usr/share/icons $out/share/
    fi

    for elf in $out/share/helium/{helium,chrome_crashpad_handler,chrome,chromedriver,helium_crashpad_handler}; do
      if [ -f "$elf" ] && [ -x "$elf" ]; then
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$elf" || true
        patchelf --set-rpath "$out/share/helium:${rpath}" "$elf" || true
      fi
    done
    for so in $out/share/helium/lib*.so*; do
      if [ -f "$so" ]; then
        patchelf --set-rpath "$out/share/helium:${rpath}" "$so" || true
      fi
    done

    if [ -e $out/share/helium/libvulkan.so.1 ]; then
      rm -f $out/share/helium/libvulkan.so.1
      ln -s ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $out/share/helium/libvulkan.so.1
    fi

    makeWrapper $out/share/helium/helium $out/bin/helium \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "$out/share/helium:${rpath}" \
      --prefix PATH : "${lib.makeBinPath [ pciutils ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  meta = {
    description = "Helium browser (solvedggorg fork)";
    homepage = pins.homepage;
    license = lib.licenses.gpl3;
    platforms = builtins.attrNames pins.assets;
    mainProgram = pname;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

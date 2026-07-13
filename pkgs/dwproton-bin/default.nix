# Modify From https://github.com/powerofthe69/nix-gaming-edge
{
  lib,
  stdenv,
  fetchzip,
  renameInternalName ? true,
}:
stdenv.mkDerivation {
  pname = "dwproton";
  version = "11.0-6";

  src = fetchzip {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-11.0-6/dwproton-11.0-6-x86_64.tar.xz";
    hash = "sha256-7nj4uEr8FnCWThD4A2iBynfxTFfNeScxMHshEzgN9F4=";
  };

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Create the steamcompat directory
    mkdir -p $steamcompattool
    cp -r ./* $steamcompattool/

    # Remove broken symlinks from upstream tarball
    find $steamcompattool -xtype l -delete

    # Modify the display name
    sed -i -r "s|\"display_name\".*|\"display_name\" \"dwproton\"|" \
      $steamcompattool/compatibilitytool.vdf

    ${lib.optionalString renameInternalName ''
      sed -i -r 's|"dwproton-[^"]*"(\s*// Internal name)|"dwproton"\1|' $steamcompattool/compatibilitytool.vdf
    ''}

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/steam/compatibilitytools.d/dwproton

    #Symlink the files INSIDE, not the folder itself. Oopsie
    ln -s $steamcompattool/* $out/share/steam/compatibilitytools.d/dwproton/

    runHook postInstall
  '';

  meta = {
    description = "Dawn Winery's custom Proton fork with fixes for various games";
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = lib.licenses.bsd3;
    platforms = ["x86_64-linux"];
  };
}

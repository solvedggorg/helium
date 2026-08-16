# Binary pins for the Nix package. CI (nix-release.yml) rewrites this
# after uploading AppImages to github.com/solvedggorg/helium/releases.
{
  version = "0.15.4.1";
  homepage = "https://github.com/solvedggorg/helium";
  binary = {
    owner = "imputnet";
    repo = "helium-linux";
  };
  assets = {
    x86_64-linux = {
      name = "helium-0.15.4.1-x86_64.AppImage";
      hash = "sha256-h3yxZnMb/EHvPJALQlJgHUVYUNsfuv0pnewgf6K6sx8=";
    };
    aarch64-linux = {
      name = "helium-0.15.4.1-arm64.AppImage";
      hash = "sha256-VNVETBXVO1skExhK3maw7N/HuFufeHRky/z1CRwjqkw=";
    };
  };
}

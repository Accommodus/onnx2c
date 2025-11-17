{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) stdenv fetchFromGitHub cmake pkg-config git protobuf lib;
in
stdenv.mkDerivation {
  pname = "onnx2c";
  version = "git";

  meta = with lib; {
    description = "Open Neural Network Exchange to C compiler";
    longDescription = "Onnx2c is a ONNX to C compiler. It will read an ONNX file, and generate C code to be included in your project. Onnx2c's target is "Tiny ML", meaning running the inference on microcontrollers.";
    homepage = "https://github.com/kraiskil/onnx2c";
    license = {
      shortName = "ONNX2C-LICENSE";
      fullName = "ONNX2C custom redistribution license";
      url = "https://github.com/kraiskil/onnx2c/blob/master/LICENSE.txt";
      free = true;
      redistributable = true;
    };
    mainProgram = "onnx2c";
  };

  # Keep .git metadata so we can init submodules inside the Nix build.
  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      (lib.cleanSourceFilter path type)
      || (builtins.match ".*/\\.git(/.*)?$" (toString path) != null);
  };

  # Submodules are required for the build; initialize them if the checkout permits it.
  preConfigure = ''
    if [ -f .gitmodules ] && [ -d .git ]; then
      git submodule update --init --recursive
    fi
  '';

  nativeBuildInputs = [ cmake pkg-config git ];
  buildInputs = [ protobuf ];
  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];
  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./onnx2c $out/bin/
    runHook postInstall
  '';

  checkPhase = ''
    make test
  '';
}

{ python3, jsoncpp, lib, stdenv, fetchFromGitHub, cmake, gcc}:

stdenv.mkDerivation rec {
  pname = "mavsdk";
  version = "1.4.16";
  src = fetchFromGitHub {
    owner = "mavlink";
    repo = "MAVSDK";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-vBPtiE69rqCsnCs6HTUPLCwesDul+zu1/nmJv46nXN0=";
  };

  cmakeFlags = [
    "-DSUPERBUILD=OFF"
  ];

  buildInputs = [ python3 jsoncpp gcc cmake ];
}

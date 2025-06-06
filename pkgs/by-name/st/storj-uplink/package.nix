{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "storj-uplink";
  version = "1.128.4";

  src = fetchFromGitHub {
    owner = "storj";
    repo = "storj";
    rev = "v${version}";
    hash = "sha256-7CH//aZ7DOXIP6A1gAZpiFO55LrLtBhvtZl/tVhYl8g=";
  };

  subPackages = [ "cmd/uplink" ];

  vendorHash = "sha256-CTcFTEKj5s43OlrIC7lOh3Lh/6k8/Igckv0zwrdGKbE=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Command-line tool for Storj";
    homepage = "https://storj.io";
    license = licenses.agpl3Only;
    mainProgram = "uplink";
    maintainers = with maintainers; [ felipeqq2 ];
  };
}

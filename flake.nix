{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      devShell.x86_64-linux =
        pkgs.mkShell {
          shellHook = ''
            export JAVA_HOME="${pkgs.jdk}"
            export JAVA_HOME_JDK8="${pkgs.jdk8}"
          '';

          buildInputs = with pkgs; [
            jdk
            jdk8
            ant
            maven
            doxygen
            graphviz
            libfido2
            (python3.withPackages (ps: with ps; [
              pyscard
            ]))
          ];
        };
    };
}

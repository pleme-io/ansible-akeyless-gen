{
  description = "Generated Ansible collection for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.runCommand "ansible-akeyless-gen" {
          src = self;
        } ''
          mkdir -p $out/share/ansible/collections/akeyless
          cp -r $src/modules $out/share/ansible/collections/akeyless/ 2>/dev/null || true
          cp -r $src/plugins $out/share/ansible/collections/akeyless/ 2>/dev/null || true
          cp -r $src/*.py $out/share/ansible/collections/akeyless/ 2>/dev/null || true
          # Ensure at least one file exists
          touch $out/share/ansible/collections/akeyless/.generated
        '';
      }
    );
}

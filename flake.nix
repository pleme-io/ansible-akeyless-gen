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
          touch $out/share/ansible/collections/akeyless/.generated
        '';

        checks.default = pkgs.runCommand "check-ansible-gen" { src = self; } ''
          cd $src
          count=$(find . -name '*.py' -not -path './.git/*' | wc -l | tr -d ' ')
          if [ "$count" -eq 0 ]; then echo "FAIL: no Python files found"; exit 1; fi
          echo "OK: $count Python files found"
          mkdir -p $out && echo "$count files" > $out/result.txt
        '';
      }
    );
}

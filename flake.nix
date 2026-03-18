{
  description = "Generated Ansible collection for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3;
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

        # Python syntax validation for all generated Ansible modules
        checks.default = pkgs.runCommand "check-ansible-gen" {
          src = self;
          nativeBuildInputs = [ python ];
        } ''
          cd $src
          PY_COUNT=0
          FAIL=0
          for f in $(find . -name '*.py' -not -path './.git/*'); do
            PY_COUNT=$((PY_COUNT + 1))
            if ! python3 -c "
          import ast, sys
          try:
              ast.parse(open(sys.argv[1]).read())
          except SyntaxError as e:
              print(f'FAIL: {sys.argv[1]}: {e}')
              sys.exit(1)
          " "$f"; then
              FAIL=$((FAIL + 1))
            fi
          done
          if [ "$PY_COUNT" -eq 0 ]; then
            echo "FAIL: no Python files found"
            exit 1
          fi
          if [ "$FAIL" -gt 0 ]; then
            echo "FAIL: $FAIL/$PY_COUNT Python files have syntax errors"
            exit 1
          fi
          echo "OK: $PY_COUNT Python files pass syntax check"
          mkdir -p $out
          echo "ansible-gen: $PY_COUNT files checked" > $out/result.txt
        '';
      }
    );
}

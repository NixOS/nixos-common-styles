{
  description = "Common styles for NixOS related web sites.";

  inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-21.11"; };

  outputs =
    { self
    , nixpkgs
    }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ overlay ]; });
      package = builtins.fromJSON (builtins.readFile ./package.json);

      overlay = final: prev: {
        commonStyles = prev.pkgs.stdenv.mkDerivation {
          name = "nixos-common-styles-${self.lastModifiedDate}";

          src = self;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          buildInputs = [
            prev.pkgs.nodePackages.svgo
          ];

          installPhase = ''
            mkdir $out
            cp -R src/* $out/

            # First delete source SVG files.
            # This serves two purposes:
            #   - Validate they're not accidentally used in the final build
            #   - Skip needlessly optimizing them
            find $out/ -name '*.src.svg' -delete
            # Then optimize the remaining SVGs
            find $out/ -name '*.svg' -print0 \
              | xargs --null --max-procs=$NIX_BUILD_CORES --max-args=1 svgo
          '';
        };

        storyBookYarnPkg = prev.pkgs.yarn2nix-moretea.mkYarnPackage rec {
          name = "${package.name}-yarn-${package.version}";

          src = null;
          dontUnpack = true;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          packageJSON = ./package.json;
          yarnLock = ./yarn.lock;

          preConfigure = ''
            mkdir ${package.name}
            cd ${package.name}
            ln -s ${packageJSON} ./package.json
            ln -s ${yarnLock} ./yarn.lock
          '';
          yarnPreBuild = ''
            mkdir -p $HOME/.node-gyp/${prev.pkgs.nodejs.version}
            echo 9 > $HOME/.node-gyp/${prev.pkgs.nodejs.version}/installVersion
            ln -sfv ${prev.pkgs.nodejs}/include $HOME/.node-gyp/${prev.pkgs.nodejs.version}
          '';
          publishBinsFor =
            [
              "@storybook/html"
            ];
          postInstall = ''
            # XXX: this is a hacky way to get things working
            #      we need to upstream this fixes

            # node_modules is ready only
            sed -i -e "s|node_modules/.cache/storybook|.cache/storybook|" \
              $out/libexec/${package.name}/node_modules/@storybook/core-common/dist/esm/utils/resolve-path-in-sb-cache.js
            sed -i -e "s|node_modules/.cache/storybook|.cache/storybook|" \
              $out/libexec/${package.name}/node_modules/@storybook/core-common/dist/cjs/utils/resolve-path-in-sb-cache.js

            # copied favicon.ico is not writable
            sed -i -e 's|await cpy(defaultFavIcon, options.outputDir);|await cpy(defaultFavIcon, options.outputDir); fs.chmod(path.join(options.outputDir, path.basename(defaultFavIcon)), 0o200);|' \
              $out/libexec/${package.name}/node_modules/@storybook/core-server/dist/esm/build-static.js
            sed -i -e 's|await (0, _cpy.default)(defaultFavIcon, options.outputDir);|await (0, _cpy.default)(defaultFavIcon, options.outputDir);_fsExtra.default.chmod(_path.default.join(options.outputDir, _path.default.basename(defaultFavIcon)), 0o200);|' \
              $out/libexec/${package.name}/node_modules/@storybook/core-server/dist/cjs/build-static.js
          '';
        };

        storyBook = prev.pkgs.stdenv.mkDerivation {
          name = "${package.name}-${package.version}";
          src = prev.pkgs.lib.cleanSource ./.;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          buildInputs =
            [
              final.pkgs.storyBookYarnPkg
              prev.pkgs.nodejs
              prev.pkgs.nodePackages.yarn
            ];

          patchPhase = ''
            rm -rf node_modules
            ln -sf ${final.pkgs.storyBookYarnPkg}/libexec/${package.name}/node_modules .
          '';

          buildPhase = ''
            # Yarn writes cache directories etc to $HOME.
            export HOME=$PWD/yarn_home
            yarn run build-storybook
          '';

          installPhase = ''
            mkdir -p $out
            cp -R ./storybook-static/* $out/
            cp netlify.toml $out/
          '';

          shellHook = ''
            rm -rf node_modules
            ln -sf ${final.pkgs.storyBookYarnPkg}/libexec/${package.name}/node_modules .
            export PATH=$PWD/node_modules/.bin:$PATH
            echo "======================================"
            echo "= To develop run: yarn run storybook ="
            echo "======================================"
          '';
        };

      };
    in

    {

      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) commonStyles storyBookYarnPkg storyBook; });

      defaultPackage = forAllSystems (system: self.packages.${system}.commonStyles);

      checks = forAllSystems (system: { build = self.defaultPackage.${system}; });
    };
}

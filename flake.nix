{
  description = "Common styles for NixOS related web sites.";

  nixConfig = {
    extra-substituters =
      [ "https://nixos-common-styles.cachix.org" ];
    extra-trusted-public-keys =
      [ "nixos-common-styles.cachix.org-1:k7qPYZGMsdFahLafsW9x63hyMnGiv/+6vg1fJMJyutQ=" ];
  };

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs 
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packageInfo = pkgs.lib.importJSON ./package.json;

        embedSVG = pkgs.writeScriptBin "embed-svg"
          ''
            #!${pkgs.bash}/bin/bash

            in=$1
            out=$2

            mkdir -p $in.tmp

            cp $in/*.svg $in.tmp/
            rm -f $in.tmp/*.src.svg

            echo ":: Optimizing svg files"
            for f in $in.tmp/*.svg; do
              echo "::  - $f"
              ${pkgs.nodePackages.svgo}/bin/svgo $f &
            done
            # Wait until all `svgo` processes are done
            # According to light testing, it is twice as fast that way.
            wait

            echo ":: Embedding SVG files"
            source ${pkgs.stdenv}/setup
            ls -la $in
            cp $in/svg.less $out
            for f in $in.tmp/*.svg; do
              echo "::  - $f"
              token=$(basename $f)
              token=''${token^^}
              token=''${token//[^A-Z0-9]/_}
              token=SVG_''${token/%_SVG/}
              substituteInPlace $out --replace "@$token)" "'$(cat $f)')"
              substituteInPlace $out --replace "@$token," "'$(cat $f)',"
            done

            rm -rf $in.tmp
          '';

        commonStyles = pkgs.stdenv.mkDerivation {
          name = "${packageInfo.name}-${self.lastModifiedDate}";

          src = self;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          buildInputs = [
            pkgs.nodePackages.svgo
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

        storyBookYarnPkg = pkgs.yarn2nix-moretea.mkYarnPackage rec {
          name = "${packageInfo.name}-yarn-${packageInfo.version}";

          src = null;
          dontUnpack = true;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          packageJSON = ./package.json;
          yarnLock = ./yarn.lock;

          preConfigure = ''
            mkdir ${packageInfo.name}
            cd ${packageInfo.name}
            ln -s ${packageJSON} ./package.json
            ln -s ${yarnLock} ./yarn.lock
          '';
          yarnPreBuild = ''
            mkdir -p $HOME/.node-gyp/${pkgs.nodejs.version}
            echo 9 > $HOME/.node-gyp/${pkgs.nodejs.version}/installVersion
            ln -sfv ${pkgs.nodejs}/include $HOME/.node-gyp/${pkgs.nodejs.version}
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
              $out/libexec/${packageInfo.name}/node_modules/@storybook/core-common/dist/esm/utils/resolve-path-in-sb-cache.js
            sed -i -e "s|node_modules/.cache/storybook|.cache/storybook|" \
              $out/libexec/${packageInfo.name}/node_modules/@storybook/core-common/dist/cjs/utils/resolve-path-in-sb-cache.js

            # copied favicon.ico is not writable
            sed -i -e 's|await cpy(defaultFavIcon, options.outputDir);|await cpy(defaultFavIcon, options.outputDir); fs.chmod(path.join(options.outputDir, path.basename(defaultFavIcon)), 0o200);|' \
              $out/libexec/${packageInfo.name}/node_modules/@storybook/core-server/dist/esm/build-static.js
            sed -i -e 's|await (0, _cpy.default)(defaultFavIcon, options.outputDir);|await (0, _cpy.default)(defaultFavIcon, options.outputDir);_fsExtra.default.chmod(_path.default.join(options.outputDir, _path.default.basename(defaultFavIcon)), 0o200);|' \
              $out/libexec/${packageInfo.name}/node_modules/@storybook/core-server/dist/cjs/build-static.js
          '';
        };

        storyBook = pkgs.stdenv.mkDerivation {
          name = "${packageInfo.name}-storybook-${packageInfo.version}";
          src = pkgs.lib.cleanSource ./.;

          preferLocalBuild = true;
          enableParallelBuilding = true;

          buildInputs = [
              storyBookYarnPkg
            ] ++
            (with pkgs; [
              nodejs
            ]) ++
            (with pkgs.nodePackages; [
              yarn
            ]);

          patchPhase = ''
            rm -rf node_modules
            ln -sf ${storyBookYarnPkg}/libexec/${packageInfo.name}/node_modules .
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
            ln -sf ${storyBookYarnPkg}/libexec/${packageInfo.name}/node_modules .
            export PATH=$PWD/node_modules/.bin:$PATH
            echo "======================================"
            echo "= To develop run: yarn run storybook ="
            echo "======================================"
          '';
        };

      in rec {
        packages = { inherit embedSVG commonStyles storyBook; };

        defaultPackage = packages.commonStyles;

        devShell = packages.storyBook;

        checks = { inherit commonStyles storyBook; };
      }
    );
}

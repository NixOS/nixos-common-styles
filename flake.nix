{
  description = "Common styles for NixOS related web sites.";

  inputs.nixpkgs = { url = "nixpkgs/nixos-unstable"; };

  outputs =
    { self
    , nixpkgs 
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      package = builtins.fromJSON (builtins.readFile ./package.json);

      commonStylesAssets =
        pkgs.runCommandNoCCLocal
          "nixos-common-styles-assets-${self.lastModifiedDate}"
          { nativeBuildInputs = [ flake.packages."${system}".embedSVG ];
            src = ./src/assets;
          }
          ''
            echo $src
            mkdir -p ./assets
            cp $src/* ./assets
            chmod -R +w ./assets
            embed-svg ./assets $out
          '';

      flake = {

        defaultPackage."${system}" = flake.packages."${system}".commonStyles;

        checks."${system}".build = flake.defaultPackage."${system}";

        packages."${system}" = rec {

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
            name = "nixos-common-styles-${self.lastModifiedDate}";

            src = self;

            enableParallelBuilding = true;

            buildInputs = [
              embedSVG
            ];

            installPhase = ''
              mkdir $out
              cp -R src/* $out/

              rm -rf $out/assets
              mkdir -v $out/assets
              cp ${commonStylesAssets} $out/assets/svg.less
            '';
          };

          storyBookYarnPkg = pkgs.yarn2nix-moretea.mkYarnPackage rec {
            name = "${package.name}-yarn-${package.version}";
            src = null;
            dontUnpack = true;
            packageJSON = ./package.json;
            yarnLock = ./yarn.lock;
            preConfigure = ''
              mkdir ${package.name}
              cd ${package.name}
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
                $out/libexec/${package.name}/node_modules/@storybook/core/dist/server/utils/resolve-path-in-sb-cache.js

              # copied favicon.ico is not writable
              sed -i -e 's|await (0, _cpy.default)(defaultFavIcon, outputDir);|await (0, _cpy.default)(defaultFavIcon, outputDir);_fsExtra.default.chmod(_path.default.join(outputDir, _path.default.basename(defaultFavIcon)), 0o200);|' \
                $out/libexec/${package.name}/node_modules/@storybook/core/dist/server/build-static.js
            '';
          };

          storyBook = pkgs.stdenv.mkDerivation {
            name = "${package.name}-${package.version}";
            src = pkgs.lib.cleanSource ./.;

            buildInputs =
              [
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
              ln -sf ${storyBookYarnPkg}/libexec/${package.name}/node_modules .
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
              ln -sf ${storyBookYarnPkg}/libexec/${package.name}/node_modules .
              export PATH=$PWD/node_modules/.bin:$PATH
              echo "======================================"
              echo "= To develop run: yarn run storybook ="
              echo "======================================"
            '';
          };

        };
      };

    in flake;
}

const fs = require("fs");
const glob = require("glob");
const path = require("path");

/*! fromentries. MIT License. Feross Aboukhadijeh <https://feross.org/opensource> */
function fromEntries (iterable) {
  return [...iterable].reduce((obj, [key, val]) => {
    obj[key] = val
    return obj
  }, {})
}

const SVG_FILES = fromEntries(glob
  .sync(__dirname + "/../src/assets/*.svg")
  .map(svg_file => {
    const key = "SVG_" + (path
      .basename(svg_file)
      .toUpperCase()
      .replace(/[^A-Z0-9]/g, "_")
      .replace(/_SVG$/, "")
    );
    const content = "'" + fs.readFileSync(svg_file).toString() + "'";
    return [key, content];
  }));

module.exports = {
  "stories": [
    "../stories/**/*.stories.mdx",
    "../stories/**/*.stories.@(js|jsx|ts|tsx)"
  ],
  "addons": [
    "@storybook/addon-links",
    "@storybook/addon-essentials"
  ],
  "webpackFinal": async (config, {configType}) => {
    // `configType` has a value of 'DEVELOPMENT' or 'PRODUCTION'
    // You can change the configuration based on that.
    // 'PRODUCTION' is used when building the static version of storybook.


    // LESS
    config.module.rules.push({
      test: /\.less$/,
      use: [
        {
          loader: 'style-loader'
        }, 
        {
          loader: 'css-loader',
        },
        {
          loader: 'less-loader',
          options: {
            lessOptions: {
              math: "always",
              globalVars: SVG_FILES,
              modifyVars: {
                "path-fonts": "./",
              }
            }
          }
        },
      ],
    });
    config.resolve.extensions.push(".less");

    return config;
  }
}

const readFileSync = require("fs").readFileSync;
const path = require("path");

module.exports = {
  install: function (less, pluginManager, functions) {
    functions.add("read-file", function (filenameNode) {
		let filename = filenameNode.value;
		const {currentDirectory} = this.currentFileInfo;
		const fullFilename = path.join(currentDirectory, filename);

		return readFileSync(fullFilename);
    });
  },
};

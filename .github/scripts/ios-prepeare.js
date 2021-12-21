const fs = require('fs');
const fileName = './Visario_iOS.xcodeproj/project.pbxproj';
const file = fs.readFileSync(fileName);
const BUNDLE_ID = process.argv[2];
const BUILD_NUMBER = process.argv[3];
const BUILD_VERSION = `${Math.floor(+process.argv[3] / 10)}.0.0`;

let fileStrings = file.toString().split('\n');

fileStrings = fileStrings.map(fileString => {
  if (fileString.includes('PRODUCT_BUNDLE_IDENTIFIER')) {
    return `\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};`;
  }

  if (fileString.includes('MARKETING_VERSION')) {
    return `\t\t\t\tMARKETING_VERSION = ${BUILD_VERSION};`;
  }

  if (fileString.includes('CURRENT_PROJECT_VERSION')) {
    return `\t\t\t\tCURRENT_PROJECT_VERSION = ${BUILD_NUMBER};`;
  }

  return fileString;
})

fs.writeFileSync(fileName, fileStrings.join('\n'));

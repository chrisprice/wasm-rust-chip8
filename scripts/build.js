const { readFileSync, writeFileSync } = require('fs');
const wabt = require('./libwabt');

const input = 'src/chip8.wat';
const output = 'src/chip8.wasm';
const log = 'src/chip8.log';

module.exports = {
  process(src, path) {
    if (path.endsWith('.wat')) {
      wabt.ready.then(() => {
        const module = wabt.parseWat(input, readFileSync(input, 'utf8'));
        module.resolveNames();
        module.validate();
        const binaryOutput = module.toBinary({ log: true });
        writeFileSync(log, binaryOutput.log, 'utf8');
        writeFileSync(output, binaryOutput.buffer);
      });
      return '';
    }
    return src;
  },
};

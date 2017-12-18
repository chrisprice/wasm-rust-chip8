const fs = require('fs');

// require the wat to force jest to run the transform
require('../chip8.wat');

const mem = new WebAssembly.Memory({ initial: 1 });
const array = new Uint8Array(mem.buffer);

const readUInt16 = offset => new Uint16Array(mem.buffer, offset)[0];
const writeUInt16 = (offset, value) => new Uint16Array(mem.buffer, offset)[0] = value;

const init = async () => {
  const wasmModule = await WebAssembly.compile(fs.readFileSync(`${__dirname}/../chip8.wasm`))
  return new WebAssembly.Instance(wasmModule, {
    _: {
      mem
    }
  });
};

const clear = () => {
  array.fill(0);
};

module.exports = {
  mem,
  array,
  readUInt16,
  writeUInt16,
  init,
  clear
};
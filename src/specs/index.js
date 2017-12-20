const fs = require('fs');

// require the wat to force jest to run the transform
require('../chip8.wat');

const mem = new WebAssembly.Memory({ initial: 1 });
const array = new Uint8Array(mem.buffer);

const readUInt16 = offset => new Uint16Array(mem.buffer, offset)[0];
const writeUInt16 = (offset, value) => new Uint16Array(mem.buffer, offset)[0] = value;

const read = (descriptor, index) => {
  if (index >= descriptor.count) {
    throw new Error(`Invalid index $[index}/${descriptor.count}`);
  }
  if (descriptor.bits % 8 !== 0) {
    throw new Error(`No support for non-byte aligned values ${descriptor.bits}`);
  }
  const bytes = descriptor.bits / 8;
  const offset = descriptor.offset + index * bytes;
  let value = 0;
  for (let i = 0; i < bytes; i++) {
    value = (value << 8) | array[offset + i];
  }
  return value;
};

const write = (descriptor, index, value) => {
  if (index >= descriptor.count) {
    throw new Error(`Invalid index $[index}/${descriptor.count}`);
  }
  if (descriptor.bits % 8 !== 0) {
    throw new Error(`No support for non-byte aligned values ${descriptor.bits}`);
  }
  const bytes = descriptor.bits / 8;
  const offset = descriptor.offset + index * bytes;
  for (let i = bytes - 1; i >= 0; i--) {
    array[offset + i] = value & 0xff;
    value = value >> 8;
  }
  return value;
};

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
  read,
  write,
  readUInt16,
  writeUInt16,
  init,
  clear
};
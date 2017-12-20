const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets I to address NNN', () => {
  write(descriptors.PROGRAM, 0, 0xab0b);
  wasmInstance.exports.tick();
  expect(read(descriptors.I, 0)).toEqual(0xb0b);
});

test('adds VX to I', () => {
  write(descriptors.PROGRAM, 0, 0xf01e);
  write(descriptors.I, 0, 0x1101);
  write(descriptors.V, 0, 0xff);
  wasmInstance.exports.tick();
  expect(read(descriptors.I, 0)).toEqual(0x1200);
});

// TODO: fixup once I've found enough memory!
test('sets I to the location of the sprite for the character in VX', () => {
  write(descriptors.PROGRAM, 0, 0xf029);
  write(descriptors.V, 0, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.I, 0)).toEqual(0x0ec0);
});

test('stores V0 to VX (inclusive) in memory starting at I (increased by X)', () => {
  write(descriptors.PROGRAM, 0, 0xf155);
  write(descriptors.I, 0, 0x0010);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.DATA, 0x10)).toEqual(0xf0);
  expect(read(descriptors.DATA, 0x11)).toEqual(0x0f);
});

test('fills V0 to VX (inclusive) from memory starting at I (increased by X)', () => {
  write(descriptors.PROGRAM, 0, 0xf165);
  write(descriptors.I, 0, 0x0010);
  write(descriptors.DATA, 0x010, 0xf0);
  write(descriptors.DATA, 0x011, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xf0);
  expect(read(descriptors.V, 1)).toEqual(0x0f);
});

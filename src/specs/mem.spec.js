const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets I to address NNN', () => {
  write(descriptors.PROGRAM, 0, 0xab0a);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0xb0a);
});

test('adds VX to I', () => {
  write(descriptors.PROGRAM, 0, 0xf01e);
  write(descriptors.I, 0, 0x1101);
  write(descriptors.V, 0, 0xff);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0x1200);
});

// TODO: fixup once I've found enough memory!
test('sets I to the location of the sprite for the character in VX', () => {
  write(descriptors.PROGRAM, 0, 0xf029);
  write(descriptors.V, 0, 0x0f);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0x0ec0);
});

test('stores V0 to VX (inclusive) in memory starting at I (increased by X)', () => {
  write(descriptors.PROGRAM, 0, 0xf255);
  write(descriptors.I, 0, 0x0110);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0x0f);
  write(descriptors.V, 2, 0x0f);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0x0110);
  expect(read(descriptors.DATA, 0x110)).toEqual(0xf0);
  expect(read(descriptors.DATA, 0x111)).toEqual(0x0f);
  expect(read(descriptors.DATA, 0x112)).toEqual(0x0f);
});

test('fills V0 to VX (inclusive) from memory starting at I (increased by X)', () => {
  write(descriptors.PROGRAM, 0, 0xf365);
  write(descriptors.I, 0, 0x0010);
  write(descriptors.DATA, 0x010, 0x10);
  write(descriptors.DATA, 0x011, 0x11);
  write(descriptors.DATA, 0x012, 0x12);
  write(descriptors.DATA, 0x013, 0x13);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0x0010);
  expect(read(descriptors.V, 0)).toEqual(0x10);
  expect(read(descriptors.V, 1)).toEqual(0x11);
  expect(read(descriptors.V, 2)).toEqual(0x12);
  expect(read(descriptors.V, 3)).toEqual(0x13);
});

test('stores the BCD representation of vx at I (+0, +1, +2)', () => {
  write(descriptors.PROGRAM, 0, 0xf033);
  write(descriptors.I, 0, 0x0010);
  write(descriptors.V, 0, 0xf1);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toEqual(0x0010);
  expect(read(descriptors.DATA, 0x12)).toEqual(0x01);
  expect(read(descriptors.DATA, 0x11)).toEqual(0x04);
  expect(read(descriptors.DATA, 0x10)).toEqual(0x02);
});

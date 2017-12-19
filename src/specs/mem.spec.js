const { init, clear, array, readUInt16, writeUInt16 } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets I to address NNN', () => {
  writeUInt16(0, 0xab0b);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea2)).toEqual(0xb0b);
});

test('adds VX to I', () => {
  writeUInt16(0, 0xf01e);
  writeUInt16(0xea2, 0x1101);
  array[0xeb0] = 0xff;
  wasmInstance.exports.tick();
  expect(readUInt16(0xea2)).toEqual(0x1200);
});

// TODO: fixup once I've found enough memory!
test('sets I to the location of the sprite for the character in VX', () => {
  writeUInt16(0, 0xf029);
  array[0xeb0] = 0x0f;
  wasmInstance.exports.tick();
  expect(readUInt16(0xea2)).toEqual(0x0ec0);
});

test('stores V0 to VX (inclusive) in memory starting at I (increased by X)', () => {
  writeUInt16(0, 0xf155);
  writeUInt16(0xea2, 0x0010);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0x010]).toEqual(0xf0);
  expect(array[0x011]).toEqual(0x0f);
});

test('fills V0 to VX (inclusive) from memory starting at I (increased by X)', () => {
  writeUInt16(0, 0xf165);
  writeUInt16(0xea2, 0x0010);
  array[0x010] = 0xf0;
  array[0x011] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xf0);
  expect(array[0xeb1]).toEqual(0x0f);
});

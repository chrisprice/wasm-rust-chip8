const { init, clear, array, readUInt16, writeUInt16 } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('program counter increments on noop', () => {
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
});

test('jumps to address NNN', () => {
  // writeUInt16(0, 0x1b0b);
  array[0x000] = 0x12;
  array[0x001] = 0x0a;
  wasmInstance.exports.tick();
  console.log(array[0xea0].toString(16), array[0xea1].toString(16));
  expect(readUInt16(0xea0)).toEqual(0x20a);
});

test('calls subroutine at address NNN', () => {
  writeUInt16(0, 0x2b0b);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0xb0b);
  expect(array[0xecf]).toEqual(2);
  expect(readUInt16(0xed0)).toEqual(0x002);
});

test('call, call', () => {
  writeUInt16(0, 0x2010);
  writeUInt16(0x010, 0x2100);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x010);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x100);
  expect(array[0xecf]).toEqual(4);
  expect(readUInt16(0xed2)).toEqual(0x012);
});

test('calls subroutine at address NNN, returns from subroutine', () => {
  writeUInt16(0, 0x2010);
  writeUInt16(0x010, 0x00ee);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x010);
  expect(array[0xecf]).toEqual(2);
  expect(readUInt16(0xed0)).toEqual(0x002);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x002);
  expect(array[0xecf]).toEqual(0);
});

test('call, return, call', () => {
  writeUInt16(0, 0x2010);
  writeUInt16(2, 0x2010);
  writeUInt16(0x010, 0x00ee);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x010);
  expect(array[0xecf]).toEqual(2);
  expect(readUInt16(0xed0)).toEqual(0x002);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x002);
  expect(array[0xecf]).toEqual(0);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x010);
  expect(array[0xecf]).toEqual(2);
  expect(readUInt16(0xed0)).toEqual(0x004);
});

test('jump to V0 + NNN', () => {
  writeUInt16(0, 0xB010);
  writeUInt16(0xeb0, 0x0010);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(0x020);
});

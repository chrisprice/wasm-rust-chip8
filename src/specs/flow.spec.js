const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('program counter increments on normal instruction', () => {
  write(descriptors.PROGRAM, 0, 0x8000);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('program counter increments on normal instruction', () => {
  write(descriptors.PC, 0, 0x200);
  write(descriptors.PROGRAM, 0x100, 0x8000);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x202);
});

test('jumps to address NNN', () => {
  write(descriptors.PROGRAM, 0, 0x1b0b);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0xb0b);
});

test('calls subroutine at address NNN', () => {
  write(descriptors.PROGRAM, 0, 0x2b0b);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0xb0b);
  expect(read(descriptors.SP, 0)).toEqual(2);
  expect(read(descriptors.STACK, 0)).toEqual(0x002);
});

test('call, call', () => {
  write(descriptors.PROGRAM, 0, 0x2010);
  write(descriptors.PROGRAM, 8, 0x2100);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x010);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x100);
  expect(read(descriptors.SP, 0)).toEqual(4);
  expect(read(descriptors.STACK, 1)).toEqual(0x012);
});

test('calls subroutine at address NNN, returns from subroutine', () => {
  write(descriptors.PROGRAM, 0, 0x2010);
  write(descriptors.PROGRAM, 8, 0x00ee);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x010);
  expect(read(descriptors.SP, 0)).toEqual(2);
  expect(read(descriptors.STACK, 0)).toEqual(0x002);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x002);
  expect(read(descriptors.SP, 0)).toEqual(0);
});

test('call, return, call', () => {
  write(descriptors.PROGRAM, 0, 0x2010);
  write(descriptors.PROGRAM, 1, 0x2010);
  write(descriptors.PROGRAM, 8, 0x00ee);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x010);
  expect(read(descriptors.SP, 0)).toEqual(2);
  expect(read(descriptors.STACK, 0)).toEqual(0x002);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x002);
  expect(read(descriptors.SP, 0)).toEqual(0);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x010);
  expect(read(descriptors.SP, 0)).toEqual(2);
  expect(read(descriptors.STACK, 0)).toEqual(0x004);
});

test('jump to V0 + NNN', () => {
  write(descriptors.PROGRAM, 0, 0xB010);
  write(descriptors.V, 0, 0x0010);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(0x020);
});

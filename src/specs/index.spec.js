const { init, clear, array, read, write } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

const littleEndianDescriptor = {
  bits: 16,
  offset: 5,
  count: 2
};

test('read LE', () => {
  array[7] = 0x12;
  array[8] = 0x34;
  expect(read(littleEndianDescriptor, 1)).toBe(0x3412)
});

test('write BE', () => {
  write(littleEndianDescriptor, 1, 0x3412);
  expect(array[7]).toBe(0x12)
  expect(array[8]).toBe(0x34)
});

const bigEndianDescriptor = {
  bits: 16,
  offset: 5,
  count: 2,
  bigEndian: true
};

test('read BE', () => {
  array[7] = 0x12;
  array[8] = 0x34;
  expect(read(bigEndianDescriptor, 1)).toBe(0x1234)
});

test('write BE', () => {
  write(bigEndianDescriptor, 1, 0x1234);
  expect(array[7]).toBe(0x12)
  expect(array[8]).toBe(0x34)
});
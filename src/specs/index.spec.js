const { init, clear, array, read, write } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

const descriptor = {
  bits: 16,
  offset: 5,
  count: 2
};

test('read', () => {
  array[8] = 0x12;
  array[7] = 0x34;
  expect(read(descriptor, 1)).toBe(0x1234)
});

test('write', () => {
  write(descriptor, 1, 0x1234);
  expect(array[8]).toBe(0x12)
  expect(array[7]).toBe(0x34)
});
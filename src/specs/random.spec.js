const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('assign vx to rand() & nn', () => {
  write(descriptors.PROGRAM, 0, 0xc0ff);
  write(descriptors.PROGRAM, 1, 0xc0ff);
  write(descriptors.PROGRAM, 2, 0xc0ff);
  write(descriptors.PRNG, 0, 0xaa);
  write(descriptors.PRNG, 1, 0x00);
  wasmInstance.exports._();
  expect(read(descriptors.PRNG, 0)).toEqual(0xd5);
  expect(read(descriptors.PRNG, 1)).toEqual(0x01);
  expect(read(descriptors.V, 0)).toEqual(0xd5);
  wasmInstance.exports._();
  expect(read(descriptors.PRNG, 0)).toEqual(0x4e);
  expect(read(descriptors.PRNG, 1)).toEqual(0x02);
  expect(read(descriptors.V, 0)).toEqual(0x4e);
  wasmInstance.exports._();
  expect(read(descriptors.PRNG, 0)).toEqual(0x2f);
  expect(read(descriptors.PRNG, 1)).toEqual(0x03);
  expect(read(descriptors.V, 0)).toEqual(0x2f);
});

test('assign vx to rand() & nn', () => {
  write(descriptors.PROGRAM, 0, 0xc00f);
  write(descriptors.PROGRAM, 1, 0xc00f);
  write(descriptors.PROGRAM, 2, 0xc00f);
  write(descriptors.PRNG, 0, 0xaa);
  write(descriptors.PRNG, 1, 0x00);
  wasmInstance.exports._();
  expect(read(descriptors.V, 0)).toEqual(0x05);
  wasmInstance.exports._();
  expect(read(descriptors.V, 0)).toEqual(0x0e);
  wasmInstance.exports._();
  expect(read(descriptors.V, 0)).toEqual(0x0f);
});

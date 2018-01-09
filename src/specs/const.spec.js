const { init, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeEach(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets vx to nn', () => {
  write(descriptors.PROGRAM, 0, 0x6789);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(2);
  expect(read(descriptors.V, 7)).toEqual(0x89);
});

test('adds nn to vx', () => {
  write(descriptors.PROGRAM, 0, 0x78f0);
  write(descriptors.V, 8, 0x0f);
  wasmInstance.exports._();
  expect(read(descriptors.PC, 0)).toEqual(2);
  expect(read(descriptors.V, 8)).toEqual(0xff);
});

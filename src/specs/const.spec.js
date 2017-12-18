const { init, clear, array, readUInt16, writeUInt16 } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets vx to nn', () => {
  writeUInt16(0, 0x6789);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
  expect(array[0xeb7]).toEqual(0x89);
});

test('adds nn to vx', () => {
  writeUInt16(0, 0x78f0);
  array[0xeb8] = 0x0f;
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
  expect(array[0xeb8]).toEqual(0xff);
});

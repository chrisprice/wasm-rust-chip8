const { init, clear, array, readUInt16, writeUInt16 } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('assign vx to vy', () => {
  writeUInt16(0, 0x8010);
  array[0xeb1] = 0x56;
  wasmInstance.exports.tick();
  console.log(readUInt16(0xea0));
  expect(array[0xeb0]).toEqual(0x56);
  expect(array[0xeb1]).toEqual(0x56);
});

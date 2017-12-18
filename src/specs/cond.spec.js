const { init, clear, array, readUInt16, writeUInt16 } = require('./index');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('skips the next instruction if vx equals nn', () => {
  writeUInt16(0, 0x3456);
  writeUInt16(0xeb4, 0x56);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(4);
});

test('does not skip the next instruction if vx does not equal nn', () => {
  writeUInt16(0, 0x3456);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
});

test('skips the next instruction if vx does not equal nn', () => {
  writeUInt16(0, 0x4456);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(4);
});

test('does not skip the next instruction if vx equals nn', () => {
  writeUInt16(0, 0x4456);
  writeUInt16(0xeb4, 0x56);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
});

test('skips the next instruction if vx equals vy', () => {
  writeUInt16(0, 0x5450);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(4);
});

test('does not skip the next instruction if vx does not equal vy', () => {
  writeUInt16(0, 0x5450);
  writeUInt16(0xeb4, 0x56);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
});

test('skips the next instruction if vx does not equal vy', () => {
  writeUInt16(0, 0x9450);
  writeUInt16(0xeb4, 0x56);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(4);
});

test('does not skip the next instruction if vx equals vy', () => {
  writeUInt16(0, 0x9450);
  wasmInstance.exports.tick();
  expect(readUInt16(0xea0)).toEqual(2);
});

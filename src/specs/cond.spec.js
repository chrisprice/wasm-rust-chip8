const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('skips the next instruction if vx equals nn', () => {
  write(descriptors.PROGRAM, 0, 0x3456);
  write(descriptors.V, 4, 0x56);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('does not skip the next instruction if vx does not equal nn', () => {
  write(descriptors.PROGRAM, 0, 0x3456);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('skips the next instruction if vx does not equal nn', () => {
  write(descriptors.PROGRAM, 0, 0x4456);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('does not skip the next instruction if vx equals nn', () => {
  write(descriptors.PROGRAM, 0, 0x4456);
  write(descriptors.V, 4, 0x56);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('skips the next instruction if vx equals vy', () => {
  write(descriptors.PROGRAM, 0, 0x5450);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('does not skip the next instruction if vx does not equal vy', () => {
  write(descriptors.PROGRAM, 0, 0x5450);
  write(descriptors.V, 4, 0x56);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('skips the next instruction if vx does not equal vy', () => {
  write(descriptors.PROGRAM, 0, 0x9450);
  write(descriptors.V, 4, 0x56);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('does not skip the next instruction if vx equals vy', () => {
  write(descriptors.PROGRAM, 0, 0x9450);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('skips if key stored in vx is pressed', () => {
  write(descriptors.PROGRAM, 0, 0xe09e);
  write(descriptors.V, 0, 0x1);
  write(descriptors.KEYBOARD, 0, 0x1);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('does not skip if key stored in vx is not pressed', () => {
  write(descriptors.PROGRAM, 0, 0xe09e);
  write(descriptors.V, 0, 0x1);
  write(descriptors.KEYBOARD, 0, 0x0);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('does not skip if key stored in vx is pressed', () => {
  write(descriptors.PROGRAM, 0, 0xe0a1);
  write(descriptors.V, 0, 0x1);
  write(descriptors.KEYBOARD, 0, 0x1);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
});

test('skips if key stored in vx is not pressed', () => {
  write(descriptors.PROGRAM, 0, 0xe0a1);
  write(descriptors.V, 0, 0x1);
  write(descriptors.KEYBOARD, 0, 0x0);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(4);
});

test('waits for key press', () => {
  write(descriptors.PROGRAM, 0, 0xf00a);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(0);
});

test('waits for key press, sets vx to the pressed key', () => {
  write(descriptors.PROGRAM, 0, 0xf00a);
  write(descriptors.KEYBOARD, 0, 0x01);
  wasmInstance.exports.tick();
  expect(read(descriptors.PC, 0)).toEqual(2);
  expect(read(descriptors.V, 0)).toEqual(0x01);
});
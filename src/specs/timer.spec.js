const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('sets vx to the value of the delay timer', () => {
  write(descriptors.PROGRAM, 0, 0xf007);
  write(descriptors.DT, 0, 0x36);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x35);
});

test('sets the delay timer to the value of vx', () => {
  write(descriptors.PROGRAM, 0, 0xf015);
  write(descriptors.V, 0, 0x35);
  wasmInstance.exports.tick();
  expect(read(descriptors.DT, 0)).toEqual(0x35);
});

test('sets the sound timer to the value of vx', () => {
  write(descriptors.PROGRAM, 0, 0xf018);
  write(descriptors.V, 0, 0x35);
  wasmInstance.exports.tick();
  expect(read(descriptors.ST, 0)).toEqual(0x35);
});

// could make the argument that timers are normally hardware based...
// and therefore the folllowing shouldn't be part of the software
test('decrements the delay and sound timers once per tick', () => {
  write(descriptors.PROGRAM, 0, 0x0000);
  write(descriptors.DT, 0, 0x35);
  write(descriptors.ST, 0, 0x47);
  wasmInstance.exports.tick();
  expect(read(descriptors.DT, 0)).toEqual(0x34);
  expect(read(descriptors.ST, 0)).toEqual(0x46);
});

test('timers do not go negative', () => {
  write(descriptors.PROGRAM, 0, 0x0000);
  wasmInstance.exports.tick();
  expect(read(descriptors.DT, 0)).toEqual(0x00);
  expect(read(descriptors.ST, 0)).toEqual(0x00);
});

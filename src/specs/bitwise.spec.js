const { init, clear, read, write } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeAll(async () => {
  wasmInstance = await init()
});
beforeEach(clear);

test('assign vx to vy', () => {
  write(descriptors.PROGRAM, 0, 0x8010);
  write(descriptors.V, 1, 0x56);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x56);
  expect(read(descriptors.V, 1)).toEqual(0x56);
});

test('set vx to vx or vy', () => {
  write(descriptors.PROGRAM, 0, 0x8011);
  write(descriptors.V, 0, 0x50);
  write(descriptors.V, 1, 0x05);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x55);
  expect(read(descriptors.V, 1)).toEqual(0x05);
});

test('set vx to vx and vy', () => {
  write(descriptors.PROGRAM, 0, 0x8012);
  write(descriptors.V, 0, 0x55);
  write(descriptors.V, 1, 0x05);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x05);
  expect(read(descriptors.V, 1)).toEqual(0x05);
});

test('set vx to vx xor vy', () => {
  write(descriptors.PROGRAM, 0, 0x8013);
  write(descriptors.V, 0, 0x51);
  write(descriptors.V, 1, 0x05);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x54);
  expect(read(descriptors.V, 1)).toEqual(0x05);
});

test('set vx to vx add vy (no carry)', () => {
  write(descriptors.PROGRAM, 0, 0x8014);
  write(descriptors.V, 0, 0x0f);
  write(descriptors.V, 1, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x1e);
  expect(read(descriptors.V, 1)).toEqual(0x0f);
  expect(read(descriptors.V, 0xf)).toEqual(0x00);
});

test('set vx to vx add vy (carry)', () => {
  write(descriptors.PROGRAM, 0, 0x8014);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe0);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x01);
});

// VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
test('set vx to vx minus vy (no borrow)', () => {
  write(descriptors.PROGRAM, 0, 0x8015);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe1);
  expect(read(descriptors.V, 1)).toEqual(0x0f);
  expect(read(descriptors.V, 0xf)).toEqual(0x00);
});

test('set vx to vx minus vy (borrow)', () => {
  write(descriptors.PROGRAM, 0, 0x8015);
  write(descriptors.V, 0, 0x0f);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe1);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x01);
});

// VX is subtracted from VY. VF is set to 0 when there's a borrow, and 1 when there isn't.
test('set vx to vy minus vx (no borrow)', () => {
  write(descriptors.PROGRAM, 0, 0x8017);
  write(descriptors.V, 0, 0x0f);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe1);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x00);
});

test('set vx to vy minus vx (borrow)', () => {
  write(descriptors.PROGRAM, 0, 0x8017);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe1);
  expect(read(descriptors.V, 1)).toEqual(0x0f);
  expect(read(descriptors.V, 0xf)).toEqual(0x01);
});

// Shifts VY right by one and copies the result to VX. VF is set to the value of the least significant bit of VY before the shift.
//  On (THIS!) some modern interpreters, VX is shifted instead, while VY is ignored.
test('set vx to vy shifted right (vy LSB=0)', () => {
  write(descriptors.PROGRAM, 0, 0x8016);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0x0f);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x78);
  expect(read(descriptors.V, 1)).toEqual(0x0f);
  expect(read(descriptors.V, 0xf)).toEqual(0x00);
});

test('set vx to vy shifted right (vy LSB=1)', () => {
  write(descriptors.PROGRAM, 0, 0x8016);
  write(descriptors.V, 0, 0x0f);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x07);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x01);
});

// Shifts VY left by one and copies the result to VX. VF is set to the value of the most significant bit of VY before the shift
//  On (THIS!) some modern interpreters, VX is shifted instead, while VY is ignored.
test('set vx to vy shifted left (vy MSB=0)', () => {
  write(descriptors.PROGRAM, 0, 0x801e);
  write(descriptors.V, 0, 0x0f);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0x1e);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x00);
});

test('set vx to vy shifted left (vy MSB=1)', () => {
  write(descriptors.PROGRAM, 0, 0x801e);
  write(descriptors.V, 0, 0xf0);
  write(descriptors.V, 1, 0xf0);
  wasmInstance.exports.tick();
  expect(read(descriptors.V, 0)).toEqual(0xe0);
  expect(read(descriptors.V, 1)).toEqual(0xf0);
  expect(read(descriptors.V, 0xf)).toEqual(0x01);
});

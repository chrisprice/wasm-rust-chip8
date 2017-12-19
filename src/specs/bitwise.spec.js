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
  expect(array[0xeb0]).toEqual(0x56);
  expect(array[0xeb1]).toEqual(0x56);
});

test('set vx to vx or vy', () => {
  writeUInt16(0, 0x8011);
  array[0xeb0] = 0x50;
  array[0xeb1] = 0x05;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x55);
  expect(array[0xeb1]).toEqual(0x05);
});

test('set vx to vx and vy', () => {
  writeUInt16(0, 0x8012);
  array[0xeb0] = 0x55;
  array[0xeb1] = 0x05;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x05);
  expect(array[0xeb1]).toEqual(0x05);
});

test('set vx to vx xor vy', () => {
  writeUInt16(0, 0x8013);
  array[0xeb0] = 0x51;
  array[0xeb1] = 0x05;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x54);
  expect(array[0xeb1]).toEqual(0x05);
});

test('set vx to vx add vy (no carry)', () => {
  writeUInt16(0, 0x8014);
  array[0xeb0] = 0x0f;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x1e);
  expect(array[0xeb1]).toEqual(0x0f);
  expect(array[0xebf]).toEqual(0x00);
});

test('set vx to vx add vy (carry)', () => {
  writeUInt16(0, 0x8014);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0xf0;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe0);
  expect(array[0xeb1]).toEqual(0xf0);
  expect(array[0xebf]).toEqual(0x01);
});

// VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
test('set vx to vx minus vy (no borrow)', () => {
  writeUInt16(0, 0x8015);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe1);
  expect(array[0xeb1]).toEqual(0x0f);
  expect(array[0xebf]).toEqual(0x00);
});

test('set vx to vx minus vy (borrow)', () => {
  writeUInt16(0, 0x8015);
  array[0xeb0] = 0x0f;
  array[0xeb1] = 0xf0;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe1);
  expect(array[0xeb1]).toEqual(0xf0);
  expect(array[0xebf]).toEqual(0x01);
});

// VX is subtracted from VY. VF is set to 0 when there's a borrow, and 1 when there isn't.
test('set vx to vy minus vx (no borrow)', () => {
  writeUInt16(0, 0x8017);
  array[0xeb0] = 0x0f;
  array[0xeb1] = 0xf0;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe1);
  expect(array[0xeb1]).toEqual(0xf0);
  expect(array[0xebf]).toEqual(0x00);
});

test('set vx to vy minus vx (borrow)', () => {
  writeUInt16(0, 0x8017);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe1);
  expect(array[0xeb1]).toEqual(0x0f);
  expect(array[0xebf]).toEqual(0x01);
});

// Shifts VY right by one and copies the result to VX. VF is set to the value of the least significant bit of VY before the shift.
test('set vx to vy shifted right (vy LSB=0)', () => {
  writeUInt16(0, 0x8016);
  array[0xeb0] = 0x0f;
  array[0xeb1] = 0xf0;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x78);
  expect(array[0xeb1]).toEqual(0xf0);
  expect(array[0xebf]).toEqual(0x00);
});

test('set vx to vy shifted right (vy LSB=1)', () => {
  writeUInt16(0, 0x8016);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x07);
  expect(array[0xeb1]).toEqual(0x0f);
  expect(array[0xebf]).toEqual(0x01);
});

// Shifts VY left by one and copies the result to VX. VF is set to the value of the most significant bit of VY before the shift
test('set vx to vy shifted left (vy MSB=0)', () => {
  writeUInt16(0, 0x801e);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0x0f;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0x1e);
  expect(array[0xeb1]).toEqual(0x0f);
  expect(array[0xebf]).toEqual(0x00);
});

test('set vx to vy shifted left (vy MSB=1)', () => {
  writeUInt16(0, 0x801e);
  array[0xeb0] = 0xf0;
  array[0xeb1] = 0xf0;
  wasmInstance.exports.tick();
  expect(array[0xeb0]).toEqual(0xe0);
  expect(array[0xeb1]).toEqual(0xf0);
  expect(array[0xebf]).toEqual(0x01);
});

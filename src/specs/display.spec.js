const { init, read, write, array } = require('./index');
const descriptors = require('./descriptors');

let wasmInstance = null;

beforeEach(async () => {
  wasmInstance = await init()
});

test('clears', () => {
  write(descriptors.PROGRAM, 0, 0x00e0);
  for (let i = 0; i < descriptors.VIDEO.count; i++) {
    write(descriptors.VIDEO, i, 0xff);
  }
  wasmInstance.exports._();
  for (let i = 0; i < descriptors.VIDEO.count; i++) {
    expect(read(descriptors.VIDEO, i)).toBe(0x00);
  }
});

// Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen

test('draws a sprite at (vx, vy) of height n offset I', () => {
  write(descriptors.V, 0, 0);
  write(descriptors.V, 1, 0);
  write(descriptors.PROGRAM, 0, 0xd015);
  write(descriptors.I, 0, descriptors.SPRITE.offset);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toBe(descriptors.SPRITE.offset);
  // Each row in VIDEO is encoded as a 64-bit LE. See https://archive.org/stream/byte-magazine-1978-12/1978_12_BYTE_03-12_Life#page/n113/mode/2up
  expect(read(descriptors.VIDEO, 0 * 8 + 7)).toBe(read(descriptors.SPRITE, 0));
  expect(read(descriptors.VIDEO, 1 * 8 + 7)).toBe(read(descriptors.SPRITE, 1));
  expect(read(descriptors.VIDEO, 2 * 8 + 7)).toBe(read(descriptors.SPRITE, 2));
  expect(read(descriptors.VIDEO, 3 * 8 + 7)).toBe(read(descriptors.SPRITE, 3));
  expect(read(descriptors.VIDEO, 4 * 8 + 7)).toBe(read(descriptors.SPRITE, 4));
  expect(read(descriptors.V, 0xf)).toBe(0);
});

test('draws a sprite at (vx, vy) of height n offset I (wraps x/y)', () => {
  write(descriptors.V, 0, 64);
  write(descriptors.V, 1, 32);
  write(descriptors.PROGRAM, 0, 0xd015);
  write(descriptors.I, 0, descriptors.SPRITE.offset);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toBe(descriptors.SPRITE.offset);
  // Each row in VIDEO is encoded as a 64-bit LE. See https://archive.org/stream/byte-magazine-1978-12/1978_12_BYTE_03-12_Life#page/n113/mode/2up
  expect(read(descriptors.VIDEO, 0 * 8 + 7)).toBe(read(descriptors.SPRITE, 0));
  expect(read(descriptors.VIDEO, 1 * 8 + 7)).toBe(read(descriptors.SPRITE, 1));
  expect(read(descriptors.VIDEO, 2 * 8 + 7)).toBe(read(descriptors.SPRITE, 2));
  expect(read(descriptors.VIDEO, 3 * 8 + 7)).toBe(read(descriptors.SPRITE, 3));
  expect(read(descriptors.VIDEO, 4 * 8 + 7)).toBe(read(descriptors.SPRITE, 4));
  expect(read(descriptors.V, 0xf)).toBe(0);
});

test('draws a sprite at (vx, vy) of height n offset I (collision)', () => {
  write(descriptors.V, 0, 64);
  write(descriptors.V, 1, 32);
  write(descriptors.VIDEO, 7, 0xff);
  write(descriptors.PROGRAM, 0, 0xd015);
  write(descriptors.I, 0, descriptors.SPRITE.offset);
  wasmInstance.exports._();
  expect(read(descriptors.I, 0)).toBe(descriptors.SPRITE.offset);
  // Each row in VIDEO is encoded as a 64-bit LE. See https://archive.org/stream/byte-magazine-1978-12/1978_12_BYTE_03-12_Life#page/n113/mode/2up
  expect(read(descriptors.VIDEO, 0 * 8 + 7)).toBe(read(descriptors.SPRITE, 0)^0xff);
  expect(read(descriptors.VIDEO, 1 * 8 + 7)).toBe(read(descriptors.SPRITE, 1));
  expect(read(descriptors.VIDEO, 2 * 8 + 7)).toBe(read(descriptors.SPRITE, 2));
  expect(read(descriptors.VIDEO, 3 * 8 + 7)).toBe(read(descriptors.SPRITE, 3));
  expect(read(descriptors.VIDEO, 4 * 8 + 7)).toBe(read(descriptors.SPRITE, 4));
  expect(read(descriptors.V, 0xf)).toBe(1);
});

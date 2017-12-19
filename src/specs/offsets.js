module.exports = {
  PC: {
    bits: 16,
    offset: 0xea0,
    count: 1
  },
  I: {
    bits: 16,
    offset: 0xea2,
    count: 1
  },
  V: {
    bits: 8,
    offset: 0xea4,
    count: 16
  },
  SPRITE: {
    bits: 24,
    offset: 0xeb4,
    count: 16
  },
  SP: {
    bits: 8,
    offset: 0xee4,
    count: 1
  },
  STACK: {
    bits: 12,
    offset: 0xee5,
    count: 16
  },
  RESERVED: {
    bits: 24,
    offset: 0xefd,
    count: 1
  }
};
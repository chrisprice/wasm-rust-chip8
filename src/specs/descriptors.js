module.exports = {
  PROGRAM: {
    bits: 16,
    // TODO: fix
    // offset: 0x200,
    // count: (0xea0 - 0x200) / 2
    offset: 0x000,
    count: 0xea0 / 2
  },
  DATA: {
    bits: 8,
    // TODO: fix
    // offset: 0x200,
    // count: (0xea0 - 0x200)
    offset: 0x000,
    count: 0xea0
  },
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
  DT: {
    bits: 8,
    offset: 0xea4,
    count: 1
  },
  ST: {
    bits: 8,
    offset: 0xea5,
    count: 1
  },
  V: {
    bits: 8,
    offset: 0xeb0,
    count: 16
  },
  SPRITE: {
    bits: 40,
    offset: 0xeb4,
    count: 1
  },
  SP: {
    bits: 8,
    offset: 0xecf,
    count: 1
  },
  STACK: {
    bits: 16,
    offset: 0xed0,
    count: 16
  }
};
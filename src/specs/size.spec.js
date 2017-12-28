const { init, clear, read, write } = require('./index');
const fs = require('fs');

test('wasm output is less than 512 bytes', () => {
  const stats = fs.statSync(require.resolve('../chip8.wasm'));
  expect(stats.size).toBeLessThan(10);
})
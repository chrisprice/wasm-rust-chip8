const hex = (value, length = 2) => {
  const padded = "0000" + value.toString(16).toUpperCase();
  return padded.substr(padded.length - length);
};

const inRange = (value, lower, upper) => value >= lower && value <= upper;

const ROMS = [
  "15PUZZLE",
  "BLINKY",
  "BLITZ",
  "BRIX",
  "CONNECT4",
  "GUESS",
  "HIDDEN",
  "IBM",
  "INVADERS",
  "KALEID",
  "MAZE",
  "MERLIN",
  "MISSILE",
  "PONG",
  "PONG2",
  "PUZZLE",
  "SYZYGY",
  "TANK",
  "TETRIS",
  "TICTAC",
  "UFO",
  "VBRIX",
  "VERS",
  "WIPEOFF"
];

const translateKeys = {
  49: 0x1, // 1
  50: 0x2, // 2
  51: 0x3, // 3
  52: 0xc, // 4
  81: 0x4, // Q
  87: 0x5, // W
  69: 0x6, // E
  82: 0xd, // R
  65: 0x7, // A
  83: 0x8, // S
  68: 0x9, // D
  70: 0xe, // F
  90: 0xa, // Z
  88: 0x0, // X
  67: 0xb, // C
  86: 0xf // V
};

const dissassemble = (program, addr) => {
  const opcode = (program[addr] << 8) | program[addr + 1];

  const x = (opcode & 0x0f00) >> 8;
  const y = (opcode & 0x00f0) >> 4;
  const nnn = opcode & 0x0fff;
  const kk = opcode & 0x00ff;
  const n = opcode & 0x000f;

  if (opcode === 0x00e0) return "CLS";
  if (opcode === 0x00ee) return "RET";
  if (inRange(opcode, 0x1000, 0x1fff)) return `JP 0x${hex(nnn, 3)}`;
  if (inRange(opcode, 0x2000, 0x2fff)) return `CALL 0x${hex(nnn, 3)}`;
  if (inRange(opcode, 0x3000, 0x3fff)) return `SE V${x} ${kk}`;
  if (inRange(opcode, 0x4000, 0x4fff)) return `SNE V${x} ${kk}`;
  if (inRange(opcode, 0x5000, 0x5fff)) return `SE V${x} V${y}`;
  if (inRange(opcode, 0x6000, 0x6fff)) return `LD V${x} ${kk}`;
  if (inRange(opcode, 0x7000, 0x7fff)) return `ADD V${x} ${kk}`;
  if (inRange(opcode, 0x8000, 0x8fff)) {
    if (n === 0x0) return `LD V${x} V${y}`;
    if (n === 0x1) return `OR V${x} V${y}`;
    if (n === 0x2) return `AND V${x} V${y}`;
    if (n === 0x3) return `XOR V${x} V${y}`;
    if (n === 0x4) return `ADD V${x} V${y}`;
    if (n === 0x5) return `SUB V${x} V${y}`;
    if (n === 0x6) return `SHR V${x}`;
    if (n === 0x7) return `SUBN V${x} V${y}`;
    if (n === 0xe) return `SHL V${x}`;
  }
  if (inRange(opcode, 0x9000, 0x9fff)) return `SNE V${x} V${y}`;
  if (inRange(opcode, 0xa000, 0xafff)) return `LDI 0x${hex(x)}${hex(kk)}`;
  if (inRange(opcode, 0xb000, 0xbfff)) return `JP V0 + ${nnn}`;
  if (inRange(opcode, 0xc000, 0xcfff)) return `RND ${kk}`;
  if (inRange(opcode, 0xd000, 0xdfff)) return `DRW V${x} V${y} ${n}`;
  if (inRange(opcode, 0xe000, 0xefff)) {
    if (kk === 0x9e) return `SKP V${x}`;
    if (kk === 0xa1) return `SKNP V${x}`;
  }
  if (inRange(opcode, 0xf000, 0xffff)) {
    if (kk === 0x07) return `LD V${x} DT`;
    if (kk === 0x0a) return `LD V${x} K`;
    if (kk === 0x15) return `LD DT, V${x}`;
    if (kk === 0x1e) return `ADD I, V${x}`;
    if (kk === 0x29) return `LD F, V${x}`;
    if (kk === 0x33) return `LD B, V${x}`;
    if (kk === 0x55) return `LD [I], [V${x}]`;
    if (kk === 0x65) return `LD [V${x}], [I]`;
  }
  return "-";
};

const run = async () => {
  const WIDTH = 64;
  const HEIGHT = 32;

  // load and instantiate the WASM module
  const res = await fetch("chip8.wasm");
  const module = await WebAssembly.compile(await res.arrayBuffer());
  const memory = new WebAssembly.Memory({ initial: 1 });
  const instance = await WebAssembly.instantiate(module, {
    _: {
      _: memory
    }
  });
  let lastTick = performance.now();
  const tick = () => {
    const now = performance.now();
    const timerTick = now - lastTick > (1000 / 60);
    if (timerTick) {
      lastTick = now;
    }
    instance.exports._(timerTick);
  }

  // obtain the various memory sections
  // TODO: reserve memory for interpreter
  window.programMemory = new Uint8Array(
    memory.buffer,
    0,
    // 0xEA0
    0xF00
  );
  window.reservedMemory = new Uint8Array(
    memory.buffer,
    0xEA0,
    0xF00 - 0xEA0
  );
  window.displayMemory = new Uint8Array(
    memory.buffer,
    0xF00,
    0x1000 - 0xF00
  );

  // initialise the canvas
  const canvas = document.getElementById("canvas");
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "black";
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  const updateDisplay = () => {
    const imageData = ctx.createImageData(WIDTH, HEIGHT);
    // displayMemory[7] = 96;
    // displayMemory[15] = 144;
    // displayMemory[23] = 32;
    // displayMemory[39] = 32;
    // console.log(displayMemory);
    for (let y = 0; y < HEIGHT; y++) {
      for (let x = 0; x < WIDTH; x++) {
        // Each row is stored as a LE 64-bit unsigned integer
        const byteOffset = y * WIDTH / 8 + 7 - (Math.floor(x / 8));
        // MSB is left, LSB is right
        const bitOffset = 7 - (x % 8);
        const value = (displayMemory[byteOffset] >> bitOffset) & 0x01;
        const i = y * WIDTH + x;
        // console.log(x, y, byteOffset, bitOffset)
        imageData.data[i * 4] = value ? 0x33 : 0x00;
        imageData.data[i * 4 + 1] = value ? 0xff : 0x00;
        imageData.data[i * 4 + 2] = value ? 0x66 : 0x00;
        imageData.data[i * 4 + 3] = 0xff;
      }
    }
    ctx.putImageData(imageData, 0, 0);
  };

  const dumpRegisters = () => {
    document.querySelector('#r1').innerHTML = new Array(16)
      .fill(0)
      .map((d, i) => `<div>V${i}: ${hex(reservedMemory[0x10 + i])}</div>`)
      .join('');
    document.querySelector('#r2').innerHTML = [
      `<div>PC: ${hex(reservedMemory[1])}${hex(reservedMemory[0])}</div>`,
      `<div>I: ${hex(reservedMemory[3])}${hex(reservedMemory[2])}</div>`,
    ].join('');
  };

  const dumpMemory = () => {
    let html = '';
    for (let address = 0; address < programMemory.byteLength; address += 2) {
      const clazz = `addr_${address}`;
      const haddress = "0x" + hex(address, 4);
      html += `<div class='${clazz}'>${haddress} - ${hex(programMemory[address])} ${hex(programMemory[address + 1])} - ${dissassemble(
          programMemory,
          address
        )}</div>`;
    }
    document.querySelector('.memory').innerHTML = html;
  };

  const updateProgramCounter = () => {
    const pc = (reservedMemory[1] << 8) | reservedMemory[0];
    const currentAddress = document.querySelector(`.memory .addr_${pc}`);
    if (currentAddress) {
      const container = document.querySelector('.memory');
      container.scrollTop =
        currentAddress.offsetTop - container.offsetTop;
    }
  };

  const updateUI = () => {
    dumpRegisters();
    updateDisplay();
    updateProgramCounter();
  };

  const loadRom = rom =>
    fetch(`roms/${rom}`)
      .then(i => i.arrayBuffer())
      .then(buffer => {
        // write the ROM to memory
        const rom = new DataView(buffer, 0, buffer.byteLength);
        for (i = 0; i < rom.byteLength; i++) {
          programMemory[0x200 + i] = rom.getUint8(i);
        }
        // reset program counter
        reservedMemory[0x000] = 0x00;
        reservedMemory[0x001] = 0x02;
        // programMemory[0x200] = 0xd0;
        // programMemory[0x201] = 0x15;
        // programMemory[0xea2] = 0x0e;
        // programMemory[0xea3] = 0xc0;
        dumpMemory();
        updateUI();
      });

  document.querySelector("#roms").innerHTML =
    ROMS.map(rom => `<option value='${rom}'>${rom}</option>`)
      .join();

  document.getElementById("roms").addEventListener("change", e => {
    loadRom(e.target.value);
  });

  document.getElementById("step").addEventListener("click", () => {
    tick();
    updateUI();
  });

  let running = false;
  const runloop = () => {
    if (running) {
      requestAnimationFrame(runloop);
      for (var i = 0; i < 10; i++) {
        tick();
      }
      updateUI();
    }
  };

  const runButton = document.getElementById("run");
  runButton.addEventListener("click", () => {
    if (running) {
      running = false;
      runButton.innerHTML = "Start";
    } else {
      running = true;
      requestAnimationFrame(runloop);
      runButton.innerHTML = "Stop";
    }
  });

  document.addEventListener("keydown", event => {
    reservedMemory[0x08] = translateKeys[event.keyCode];
  });

  document.addEventListener("keyup", event => {
    reservedMemory[0x08] = 0x00;
  });

  document.querySelector("#roms").value = "BLINKY";
  loadRom("BLINKY");
};

run();

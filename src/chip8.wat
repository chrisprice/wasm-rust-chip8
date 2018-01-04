(module
  (import "_" "_" (memory 1))
  ;; initialise program counter
  (data (i32.const 0xec0) "\60\90\20\00\20")
  ;; initialise LFSR PRNG
  (data (i32.const 0xea6) "\aa")
  (func (export "_")
    (param $timerTick i32)
    ;; internal registers, required by > 1 instruction
    (local $programCounter i32)
    (local $address i32)
    (local $instruction i32)
    (local $stackPointer i32)
    (local $delayTimer i32)
    (local $soundTimer i32)
    (local $key i32)
    ;; operands
    (local $m i32)
    (local $n i32)
    (local $nn i32)
    (local $nnn i32)
    (local $x i32)
    ;; registers
    (local $vx i32)
    (local $vy i32)
    (local $vf i32)
    ;; loop variables
    (local $i i32)
    (local $l i32)
    ;; per-iteration store addresses/values
    ;; could make these offsets from OOB address
    (local $address8 i32)
    (local $value8 i32)
    (local $address16 i32)
    (local $value16 i32)
    (local $address64 i32)
    (local $value64 i64)
    ;; instruction specific working variables
    (local $a i32)
    (local $b i32)
    (local $c i32)
    (local $d i32)
    (local $B i64)
    (local $C i64)

    ;; --- LOAD INTERNAL REGISTERS ---
    ;; load timers and store decremented values on tick
    (i32.store16
      (i32.const 0xea4)
      (i32.sub
        (tee_local $a
          (i32.load16_u
            (i32.const 0xea4)
          )
        )
        (i32.or
          (select
            (get_local $timerTick)
            (i32.const 0)
            (tee_local $delayTimer
              (i32.and
                (get_local $a)
                (i32.const 0xff)
              )
            )
          )
          (select
            (i32.shl
              (get_local $timerTick)
              (i32.const 8)
            )
            (i32.const 0)
            (tee_local $soundTimer
              ;; >> 8 === & 0xff00 but saves a byte (1 byte literal versus 2)
              (i32.shr_u
                (get_local $a)
                (i32.const 8)
              )
            )
          )
        )
      )
    )

    ;; load key
    ;; could optimise: mutually exclusive load with stackPointer, vy & key
    ;; could include nn which would collapse 3xnn, 4xnn, 5xy0, 9xy0, ex9e & exa1
    ;; switch on m === 0 for stackPointer
    (set_local $key
      (i32.load8_u
        (i32.const 0x0ea8)
      )
    )

    ;; load stackPointer
    (set_local $stackPointer
      (i32.load8_u
        (i32.const 0x0ecf)
      )
    )

    ;; load address
    ;; could optimise: mutually exclusive load with stack address
    (set_local $address
      (i32.load16_u
        (i32.const 0x0ea2)
      )
    )

    ;; --- EXTRACT OPERANDS ---
    ;; extract ---n
    (set_local $n
      (i32.and
        ;; extract --nn
        (tee_local $nn
          (i32.and
            ;; extract -nnn
            (tee_local $nnn
              (i32.and
                ;; load instruction (big endian)
                (tee_local $instruction
                  (i32.or
                    (i32.shl
                      (i32.load8_u
                        ;; load programCounter
                        (tee_local $programCounter
                          (i32.load16_u
                            (i32.const 0x0ea0)
                          )
                        )
                      )
                      (i32.const 8)
                    )
                    (i32.load8_u offset=1
                      (get_local $programCounter)
                    )
                  )
                )
                (i32.const 0xfff)
              )
            )
            (i32.const 0xff)
          )
        )
        (i32.const 0xf)
      )
    )

    ;; --- LOAD REGISTERS ---
    ;; load register X (vx)
    (set_local $vx
      (i32.load8_u offset=0x0eb0
        ;; extract -x--
        (tee_local $x
          (i32.shr_u
            (i32.and
              (get_local $instruction)
              (i32.const 0xf00)
            )
            (i32.const 8)
          )
        )
      )
    )
    ;; load register Y (vy)
    (set_local $vy
      (i32.load8_u offset=0x0eb0
        ;; extract --y-
        (i32.shr_u
          (i32.and
            (get_local $instruction)
            (i32.const 0xf0)
          )
          (i32.const 4)
        )
      )
    )

    ;; increment programCounter
    (set_local $programCounter
      (i32.add
        (get_local $programCounter)
        (i32.const 2)
      )
    )

    ;; --- INSTRUCTION LOOP BLOCK ---
    ;; allow instructions to loop if required
    ;; looping instructions should set l in their implementation
    ;; l defaults to 0 causing a single iteration
    ;; (equivalent to `do {} while (i < l)`)
    (loop $loop

      ;; --- INSTRUCTION PROCESSING ---
      ;; breaking from this block prevents other instruction matching
      (block $instructionProcessing
        (block $0xxx
          (block $1xxx
            (block $2xxx
              (block $3xxx
                (block $4xxx
                  (block $5xxx
                    (block $6xxx
                      (block $7xxx
                        (block $8xxx
                          (block $9xxx
                            (block $axxx
                              (block $bxxx
                                (block $cxxx
                                  (block $dxxx
                                    (block $exxx
                                      (block $fxxx
                                        (br_table $0xxx $1xxx $2xxx $3xxx $4xxx $5xxx $6xxx $7xxx $8xxx $9xxx $axxx $bxxx $cxxx $dxxx $exxx $fxxx
                                          (tee_local $m
                                            ;; extract m---
                                            (i32.shr_u
                                              (i32.and
                                                (get_local $instruction)
                                                (i32.const 0xf000)
                                              )
                                              (i32.const 12)
                                            )
                                          )
                                        )
                                      )
                                      (block $fx07
                                        (block $fx0a
                                          (block $fx18
                                            (block $fx1e
                                              (block $fx29
                                                (block $fx33
                                                  (block $fx15$fx55$fx65
                                                    (br_table $fx18 $fx29 $fx0a $fx33 $instructionProcessing $fx15$fx55$fx65 $fx1e $fx07
                                                      (i32.and
                                                        (get_local $n)
                                                        (i32.const 0x7)
                                                      )
                                                    )
                                                  )
                                                  ;; $fx15$fx55$fx65
                                                  (if
                                                    (i32.and
                                                      (get_local $nn)
                                                      (i32.const 0x40)
                                                    )
                                                    (then
                                                      ;; fx55 mem[address -> address + x] = v[0 -> vx]
                                                      ;; fx65 v[0 -> vx] = mem[address -> address + x]
                                                      (set_local $l
                                                        (i32.add
                                                          (get_local $x)
                                                          (i32.const 1)
                                                        )
                                                      )
                                                      (set_local $address8
                                                        (i32.add
                                                          (select
                                                            (get_local $address)
                                                            (i32.const 0xeb0)
                                                            (tee_local $a
                                                              (i32.and
                                                                (get_local $nn)
                                                                (i32.const 0x10)
                                                              )
                                                            )
                                                          )
                                                          (get_local $i)
                                                        )
                                                      )
                                                      (set_local $value8
                                                        (i32.load8_u
                                                          (i32.add
                                                            (select
                                                              (i32.const 0xeb0)
                                                              (get_local $address)
                                                              (get_local $a)
                                                            )
                                                            (get_local $i)
                                                          )
                                                        )
                                                      )
                                                      (br $instructionProcessing)
                                                    )
                                                  )
                                                  ;; fx15 delay(vx)
                                                  ;; store delayTimer
                                                  (set_local $address8
                                                    (i32.const 0xea4)
                                                  )
                                                  (set_local $value8
                                                    (get_local $vx)
                                                  )
                                                  (br $instructionProcessing)
                                                )
                                                ;; fx33 bcd
                                                (set_local $l
                                                  (i32.const 3)
                                                )
                                                (set_local $address8
                                                  (i32.sub
                                                    (i32.add
                                                      (get_local $address)
                                                      (i32.const 2)
                                                    )
                                                    (get_local $i)
                                                  )
                                                )
                                                (set_local $value8
                                                  (i32.rem_u
                                                    (get_local $vx)
                                                    (i32.const 10)
                                                  )
                                                )
                                                (set_local $vx
                                                  (i32.div_u
                                                    (get_local $vx)
                                                    (i32.const 10)
                                                  )
                                                )
                                                (br $instructionProcessing)
                                              )
                                              ;; fx29 address = sprite(vx)
                                              ;; TODO: find space!
                                              (set_local $address16
                                                (i32.const 0x02)
                                              )
                                              (set_local $value16
                                                (i32.const 0xec0)
                                              )
                                              (br $instructionProcessing)
                                            )
                                            ;; fx1e address += vx
                                            ;; could share logic with $axxx
                                            (set_local $address16
                                              (i32.const 0x02)
                                            )
                                            (set_local $value16
                                              (i32.add
                                                (get_local $vx)
                                                (get_local $address)
                                              )
                                            )
                                            (br $instructionProcessing)
                                          )
                                          ;; fx18 sound(vx)
                                          ;; store soundTimer
                                          (set_local $address8
                                            (i32.const 0xea5)
                                          )
                                          (set_local $value8
                                            (get_local $vx)
                                          )
                                          (br $instructionProcessing)
                                        )
                                        ;; fx0a vx = wait_for_key()
                                        (set_local $programCounter
                                          (i32.sub
                                            (get_local $programCounter)
                                            (select
                                              (i32.const 0)
                                              (i32.const 2)
                                              (get_local $key)
                                            )
                                          )
                                        )
                                        ;; could fallthrough
                                        (set_local $nn
                                          (select
                                            (get_local $key)
                                            (get_local $vx)
                                            (get_local $key)
                                          )
                                        )
                                        (br $6xxx)
                                      )
                                      ;; fx07 vx = delay()
                                      (set_local $nn
                                        (get_local $delayTimer)
                                      )
                                      (br $6xxx)
                                    )
                                    ;; ex9e skip if key() == vx
                                    ;; exa1 skip if key() != vx
                                    (set_local $m
                                      (i32.eq
                                        (get_local $n)
                                        (i32.const 0xe)
                                      )
                                    )
                                    (set_local $nn
                                      (get_local $key)
                                    )
                                    (br $3xxx)
                                  )
                                  ;; dxyn draw at (vx, vy) n bytes starting at address
                                  (set_local $l
                                    (get_local $n)
                                  )
                                  (set_local $address64
                                    (i32.mul
                                      (i32.const 8)
                                      (i32.rem_u
                                        (i32.add
                                          (get_local $vy)
                                          (get_local $i)
                                        )
                                        (i32.const 32)
                                      )
                                    )
                                  )
                                  (set_local $address8
                                    (i32.const 0xebf)
                                  )
                                  (set_local $value8
                                    (i32.or
                                      (get_local $value8)
                                      (i64.ne
                                        (tee_local $value64
                                          (i64.xor
                                            (tee_local $B
                                              (i64.load offset=0xf00
                                                (i32.mul
                                                  (i32.const 8)
                                                  (i32.rem_u
                                                    (i32.add
                                                      (get_local $vy)
                                                      (get_local $i)
                                                    )
                                                    (i32.const 32)
                                                  )
                                                )
                                              )
                                            )
                                            (tee_local $C
                                              (i64.rotl
                                                (i64.load8_u
                                                  (i32.add
                                                    (get_local $address)
                                                    (get_local $i)
                                                  )
                                                )
                                                (i64.sub
                                                  (i64.const 56) ;; 64 - 8
                                                  (i64.extend_u/i32
                                                    (get_local $vx)
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                        (i64.or
                                          (get_local $B)
                                          (get_local $C)
                                        )
                                      )
                                    )
                                  )
                                  (br $instructionProcessing)
                                )
                                ;; cxnn sets vx = rand() & nn
                                (set_local $b
                                  (i32.load8_u
                                    (i32.const 0x0ea6)
                                  )
                                )
                                (set_local $a
                                  (i32.load8_u
                                    (i32.const 0x0ea7)
                                  )
                                )
                                (set_local $b
                                  (i32.xor
                                    (get_local $b)
                                    (i32.shl
                                      (get_local $b)
                                      (i32.const 3)
                                    )
                                  )
                                )
                                (set_local $b
                                  (i32.xor
                                    (get_local $b)
                                    (i32.shr_u
                                      (get_local $b)
                                      (i32.const 5)
                                    )
                                  )
                                )
                                (set_local $b
                                  (i32.xor
                                    (get_local $b)
                                    (i32.shr_u
                                      (get_local $a)
                                      (i32.const 5)
                                    )
                                  )
                                )
                                (i32.store8
                                  (i32.const 0x0ea6)
                                  (get_local $b)
                                )
                                (i32.store8
                                  (i32.const 0x0ea7)
                                  (i32.add
                                    (get_local $a)
                                    (i32.const 1)
                                  )
                                )
                                (set_local $nn
                                  (i32.and
                                    (get_local $nn)
                                    (get_local $b)
                                  )
                                )
                                (br $6xxx)
                              )
                              ;; bnnn jump v0 + nnn
                              (set_local $programCounter
                                (i32.add
                                  (i32.load8_u
                                    (i32.const 0x0eb0)
                                  )
                                  (get_local $nnn)
                                )
                              )
                              (br $instructionProcessing)
                            )
                            ;; annn set i = nnn
                            (set_local $address16
                              (i32.const 0x02)
                            )
                            (set_local $value16
                              (get_local $nnn)
                            )
                            (br $instructionProcessing)
                          )
                          ;; 9xy0 skip vx != vy
                          ;; hack the leading nibble to invert the logic
                          (set_local $m
                            (i32.const 0)
                          )
                          (br $5xxx)
                        )
                        ;; 8xxx
                        (block $8xy0
                          (block $8xy1
                            (block $8xy2
                              (block $8xy3
                                (block $8xy4
                                  (block $8xy5
                                    (block $8xy6
                                      (block $8xy7
                                        (block $8xye
                                          (br_table $8xy0 $8xy1 $8xy2 $8xy3 $8xy4 $8xy5 $8xy6 $8xy7 $8xye
                                            (get_local $n)
                                          )
                                        )
                                        ;; 8xye set vx = vy << 1
                                        (set_local $address16
                                          (i32.const 0x1f)
                                        )
                                        (set_local $value16
                                          (i32.shr_u
                                            (get_local $vx)
                                            (i32.const 7)
                                          )
                                        )
                                        (set_local $nn
                                          (i32.shl
                                            (get_local $vx)
                                            (i32.const 1)
                                          )
                                        )
                                        (br $6xxx)
                                      )
                                      ;; 8xy7 set vx = vy - vx
                                      (set_local $address16
                                        (i32.const 0x1f)
                                      )
                                      (set_local $value16
                                        (tee_local $a
                                          (i32.gt_u
                                            (get_local $vx)
                                            (get_local $vy)
                                          )
                                        )
                                      )
                                      (set_local $nn
                                        (select
                                          (i32.sub
                                            (get_local $vx)
                                            (get_local $vy)
                                          )
                                          (i32.sub
                                            (get_local $vy)
                                            (get_local $vx)
                                          )
                                          (get_local $a)
                                        )
                                      )
                                      (br $6xxx)
                                    )
                                    ;; 8xy6 set vx = vy >> 1
                                    (set_local $address16
                                      (i32.const 0x1f)
                                    )
                                    (set_local $value16
                                      (i32.and
                                        (get_local $vx)
                                        (i32.const 0x01)
                                      )
                                    )
                                    (set_local $nn
                                      (i32.shr_u
                                        (get_local $vx)
                                        (i32.const 1)
                                      )
                                    )
                                    (br $6xxx)
                                  )
                                  ;; 8xy5 set vx -= vy
                                  (set_local $address16
                                    (i32.const 0x1f)
                                  )
                                  (set_local $value16
                                    (tee_local $a
                                      (i32.gt_u
                                        (get_local $vy)
                                        (get_local $vx)
                                      )
                                    )
                                  )
                                  (set_local $nn
                                    (select
                                      (i32.sub
                                        (get_local $vy)
                                        (get_local $vx)
                                      )
                                      (i32.sub
                                        (get_local $vx)
                                        (get_local $vy)
                                      )
                                      (get_local $a)
                                    )
                                  )
                                  (br $6xxx)
                                )
                                ;; 8xy4 set vx += vy
                                (set_local $nn
                                  (i32.add
                                    (get_local $vx)
                                    (get_local $vy)
                                  )
                                )
                                (set_local $address16
                                  (i32.const 0x1f)
                                )
                                (set_local $value16
                                  (i32.shr_u
                                    (get_local $nn)
                                    (i32.const 8)
                                  )
                                )
                                (br $6xxx)
                              )
                              ;; 8xy3 set vx = vx XOR vy
                              (set_local $nn
                                (i32.xor
                                  (get_local $vx)
                                  (get_local $vy)
                                )
                              )
                              (br $6xxx)
                            )
                            ;; 8xy2 set vx = vx & vy
                            (set_local $nn
                              (i32.and
                                (get_local $vx)
                                (get_local $vy)
                              )
                            )
                            (br $6xxx)
                          )
                          ;; 8xy1 set vx = vx | vy
                          (set_local $nn
                            (i32.or
                              (get_local $vx)
                              (get_local $vy)
                            )
                          )
                          (br $6xxx)
                        )
                        ;; 8xy0 set vx = vy
                        (set_local $nn
                          (get_local $vy)
                        )
                        (br $6xxx)
                      )
                      ;; 7xnn set vx += nn
                      (set_local $nn
                        (i32.add
                          (get_local $vx)
                          (get_local $nn)
                        )
                      )
                      ;; fallthrough
                    )
                    ;; 6xnn set vx = nn
                    (set_local $address8
                      (i32.add
                        (i32.const 0xeb0)
                        (get_local $x)
                      )
                    )
                    (set_local $value8
                      (get_local $nn)
                    )
                    (br $instructionProcessing)
                  )
                  ;; 5xy0 skip vx == vy
                  (set_local $nn
                    (get_local $vy)
                  )
                  ;; fallthrough
                )
                ;; 4xnn skip vx != nn
                ;; fallthrough
              )
              ;; 3xnn skip vx == nn
              (if
                (i32.xor
                  (i32.ne (get_local $vx) (get_local $nn))
                  (i32.and (get_local $m) (i32.const 0x1))
                )
                (then
                  (set_local $programCounter
                    (i32.add
                      (get_local $programCounter)
                      (i32.const 2)
                    )
                  )
                )
              )
              (br $instructionProcessing)
            )
            ;; 2nnn call nnn
            ;; store incremented program counter on stack
            (set_local $address16
              (i32.add
                (i32.const 0x30)
                (get_local $stackPointer)
              )
            )
            (set_local $value16
              (get_local $programCounter)
            )
            ;; incremented stack pointer
            (set_local $address8
              (i32.const 0xecf)
            )
            (set_local $value8
              (i32.add
                (get_local $stackPointer)
                (i32.const 2)
              )
            )
            ;; fallthrough
          )
          ;; 1nnn jump nnn
          (set_local $programCounter
            (get_local $nnn)
          )
          (br $instructionProcessing)
        )
        ;; 00e0/00ee
        (if (i32.and (get_local $instruction) (i32.const 0xe))
          (then
            ;; 00ee return
            ;; decrement stack pointer
            (set_local $address8
              (i32.const 0xecf)
            )
            ;; set program counter to address from stack
            (set_local $programCounter
              (i32.load16_u offset=0xed0
                (tee_local $value8
                  (i32.sub
                    (get_local $stackPointer)
                    (i32.const 2)
                  )
                )
              )
            )
          )
          (else
            ;; 00e0 clear screen
            (set_local $address64
              (i32.or
                (i32.const 0)
                (i32.mul
                  (get_local $i)
                  (i32.const 8)
                )
              )
            )
            (set_local $l
              (i32.const 32)
            )
          )
        )
      )

      ;; --- STORE VALUES ---
      ;; could move these to avoid storing OOB
      (i32.store8
        (get_local $address8)
        (get_local $value8)
      )
      (i32.store16 offset=0xea0
        (get_local $address16)
        (get_local $value16)
      )
      (i64.store offset=0xf00
        (get_local $address64)
        (get_local $value64)
      )

      ;; loop if ++i < l
      (br_if $loop
        (i32.lt_u
          (tee_local $i
            (i32.add
              (get_local $i)
              (i32.const 1)
            )
          )
          (get_local $l)
        )
      )
    )


    ;; --- STORE PROGRAM COUNTER ---
    ;; store programCounter
    (i32.store16
      (i32.const 0x0ea0)
      (get_local $programCounter)
    )
  )
)
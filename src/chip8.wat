(module
  (import "_" "mem" (memory 1))
  (data (i32.const 0xec0) "\60\90\20\00\20")
  (type $processInstruction (func (param $pc i32) (param $op i32) (result i32)))
  (func $incrementAddress (param $value i32) (result i32)
    (i32.add
      (i32.const 2)
      (get_local $value)
    )
  )
  (func $load16_u_be (param $offset i32) (result i32)
    (i32.or
      (i32.shl
        (i32.load8_u
          (get_local $offset)
        )
        (i32.const 8)
      )
      (i32.load8_u
        (i32.add
          (get_local $offset)
          (i32.const 1)
        )
      )
    )
  )
  (func $store16_u_be (param $offset i32) (param $value i32)
    (i32.store8
      (get_local $offset)
      (i32.shr_u
        (get_local $value)
        (i32.const 8)
      )
    )
    (i32.store8
      (i32.add
        (get_local $offset)
        (i32.const 1)
      )
      (get_local $value)
    )
  )
  (func $move_memory (param $from i32) (param $to i32) (param $repeat i32) (local $i i32)
    (loop $loop
      (i32.store8
        (i32.add
          (get_local $to)
          (get_local $i)
        )
        (i32.load8_u
          (i32.add
            (get_local $from)
            (get_local $i)
          )
        )
      )
      (br_if $loop
        (i32.eq
          (tee_local $i
            (i32.add
              (get_local $i)
              (i32.const 1)
            )
          )
          (get_local $repeat)
        )
      )
    )
  )
  (func $NOOP (param $pc i32) (param $op i32) (result i32)
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Native call to NNN (disp_clear=00E0, return=00EE)
  (func $0NNN  (param $pc i32) (param $op i32) (result i32)
    (if (result i32)
      (i32.eq (get_local $op) (i32.const 0x00e0))
      (then
        (call $00E0
          (get_local $pc)
          (get_local $op)
        )
      )
      (else
        (if (result i32)
          (i32.eq (get_local $op) (i32.const 0x00ee))
          (then
            (call $00EE
              (get_local $pc)
              (get_local $op)
            )
          )
          (else
            (call $NOOP
              (get_local $pc)
              (get_local $op)
            )
          )
        )
      )
    )
  )
  ;; clear display
  (func $00E0 (param $pc i32) (param $op i32) (result i32) (local $i i32)
    (loop $loop
      (i64.store offset=0xf00
        (i32.mul
          (get_local $i)
          (i32.const 8)
        )
        (i64.const 0)
      )
      (br_if $loop
        (i32.lt_u
          (tee_local $i
            (i32.add
              (get_local $i)
              (i32.const 1)
            )
          )
          (i32.const 32)
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Return
  (func $00EE (param $pc i32) (param $op i32) (result i32) (local $sp i32)
    ;; load decremented stack pointer
    (set_local $sp
      (i32.sub
        (i32.load8_u
          (i32.const 0xecf)
        )
        (i32.const 2)
      )
    )
    ;; store stack pointer
    (i32.store8
      (i32.const 0xecf)
      (get_local $sp)
    )
    ;; set program counter to address from stack
    (call $load16_u_be
      (i32.add
        (i32.const 0xed0)
        (get_local $sp)
      )
    )
  )
  ;; Jump to NNN
  (func $1NNN (param $pc i32) (param $op i32) (result i32)
    (i32.and
      (i32.const 0x0fff)
      (get_local $op)
    )
  )
  ;; Call NNN
  (func $2NNN (param $pc i32) (param $op i32) (result i32) (local $sp i32)
    ;; load stack pointer
    (set_local $sp
      (i32.load8_u
        (i32.const 0xecf)
      )
    )
    ;; store incremented program counter on stack
    (call $store16_u_be
      (i32.add
        (i32.const 0xed0)
        (get_local $sp)
      )
      (call $incrementAddress
        (get_local $pc)
      )
    )
    ;; store incremented stack pointer
    (i32.store8
      (i32.const 0xecf)
      (call $incrementAddress
        (get_local $sp)
      )
    )
    ;; set program counter to address
    (i32.and
      (get_local $op)
      (i32.const 0x0fff)
    )
  )
  ;; Skip the next instruction if vX equals NN
  (func $3XNN (param $pc i32) (param $op i32) (result i32)
    (if
      (i32.eq
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x0f00)
            )
            (i32.const 8)
          )
        )
        (i32.and
          (get_local $op)
          (i32.const 0x00ff)
        )
      )
      (then
        (set_local $pc
          (call $incrementAddress
            (get_local $pc)
          )
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Skip the next instruction if vX does not equal NN
  (func $4XNN (param $pc i32) (param $op i32) (result i32)
    (if
      (i32.ne
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x0f00)
            )
            (i32.const 8)
          )
        )
        (i32.and
          (get_local $op)
          (i32.const 0x00ff)
        )
      )
      (then
        (set_local $pc
          (call $incrementAddress
            (get_local $pc)
          )
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Skip the next instruction if vX equals vY
  (func $5XY0 (param $pc i32) (param $op i32) (result i32)
    (if
      (i32.eq
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x0f00)
            )
            (i32.const 8)
          )
        )
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x00f0)
            )
            (i32.const 4)
          )
        )
      )
      (then
        (set_local $pc
          (call $incrementAddress
            (get_local $pc)
          )
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Sets vX to NN
  (func $6XNN (param $pc i32) (param $op i32) (result i32)
    (i32.store8 offset=0x0eb0
      (i32.shr_u
        (i32.and
          (get_local $op)
          (i32.const 0x0f00)
        )
        (i32.const 8)
      )
      (i32.and
        (i32.const 0x0ff)
        (get_local $op)
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Adds NN to vX
  (func $7XNN (param $pc i32) (param $op i32) (result i32) (local $vx i32)
    (i32.store8 offset=0x0eb0
      (tee_local $vx
        (i32.shr_u
          (i32.and
            (get_local $op)
            (i32.const 0x0f00)
          )
          (i32.const 8)
        )
      )
      (i32.add
        (i32.and
          (i32.const 0x0ff)
          (get_local $op)
        )
        (i32.load8_u offset=0x0eb0
          (get_local $vx)
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Bitwise dispatch
  (func $8XY$ (param $pc i32) (param $op i32) (result i32) (local $vx i32)
    (i32.store8 offset=0xeb0
      (tee_local $vx
        (i32.shr_u
          (i32.and
            (get_local $op)
            (i32.const 0x0f00)
          )
          (i32.const 8)
        )
      )
      (call_indirect (type $processInstruction)
        (i32.load8_u offset=0xeb0
          (get_local $vx)
        )
        (i32.load8_u offset=0xeb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x00f0)
            )
            (i32.const 4)
          )
        )
        (i32.add
          (i32.const 0x0010)
          (i32.and
            (get_local $op)
            (i32.const 0x000f)
          )
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Set vX to the value of vY.
  (func $8XY0 (param $vx i32) (param $vy i32) (result i32)
    get_local $vy
  )
  ;; Set vX to vX or vY.
  (func $8XY1 (param $vx i32) (param $vy i32) (result i32)
    (i32.or
      (get_local $vx)
      (get_local $vy)
    )
  )
  ;; Set vX to vX and vY.
  (func $8XY2 (param $vx i32) (param $vy i32) (result i32)
    (i32.and
      (get_local $vx)
      (get_local $vy)
    )
  )
  ;; Set vX to vX xor vY.
  (func $8XY3 (param $vx i32) (param $vy i32) (result i32)
    (i32.xor
      (get_local $vx)
      (get_local $vy)
    )
  )
  ;; Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
  (func $8XY4 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
    (tee_local $result
      (i32.add
        (get_local $vx)
        (get_local $vy)
      )
    )
    (i32.store
      (i32.const 0x0ebf)
      (i32.shr_u
        (i32.and
          (i32.const 0x0100)
          (get_local $result)
        )
        (i32.const 8)
      )
    )
  )
  ;; VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
  (func $8XY5 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
    (if (result i32)
      (i32.gt_u
        (get_local $vx)
        (get_local $vy)
      )
      (then
        (i32.sub
          (get_local $vx)
          (get_local $vy)
        )
        (i32.store
          (i32.const 0x0ebf)
          (i32.const 0x0)
        )
      )
      (else
        (i32.sub
          (get_local $vy)
          (get_local $vx)
        )
        (i32.store
          (i32.const 0x0ebf)
          (i32.const 0x1)
        )
      )
    )
  )
  ;; Shifts VY right by one and copies the result to VX. VF is set to the value of the least significant bit of VY before the shift.
  (func $8XY6 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
    (i32.shr_u
      (get_local $vy)
      (i32.const 1)
    )
    (i32.store
      (i32.const 0x0ebf)
      (i32.and
        (i32.const 0x01)
        (get_local $vy)
      )
    )
  )
  ;; VX is subtracted from VY. VF is set to 0 when there's a borrow, and 1 when there isn't.
  (func $8XY7 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
    (if (result i32)
      (i32.gt_u
        (get_local $vy)
        (get_local $vx)
      )
      (then
        (i32.sub
          (get_local $vy)
          (get_local $vx)
        )
        (i32.store
          (i32.const 0x0ebf)
          (i32.const 0x0)
        )
      )
      (else
        (i32.sub
          (get_local $vx)
          (get_local $vy)
        )
        (i32.store
          (i32.const 0x0ebf)
          (i32.const 0x1)
        )
      )
    )
  )
  ;; Shifts VY left by one and copies the result to VX. VF is set to the value of the most significant bit of VY before the shift
  (func $8XYE (param $vx i32) (param $vy i32) (result i32) (local $result i32)
    (i32.shl
      (get_local $vy)
      (i32.const 1)
    )
    (i32.store
      (i32.const 0x0ebf)
      (i32.shr_u
        (i32.and
          (i32.const 0x80)
          (get_local $vy)
        )
        (i32.const 7)
      )
    )
  )
  ;; Skip the next instruction if vX does not equal vY
  (func $9XY0 (param $pc i32) (param $op i32) (result i32)
    (if
      (i32.ne
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x0f00)
            )
            (i32.const 8)
          )
        )
        (i32.load8_u offset=0x0eb0
          (i32.shr_u
            (i32.and
              (get_local $op)
              (i32.const 0x00f0)
            )
            (i32.const 4)
          )
        )
      )
      (then
        (set_local $pc
          (call $incrementAddress
            (get_local $pc)
          )
        )
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Sets I to the address NNN
  (func $ANNN (param $pc i32) (param $op i32) (result i32)
    (call $store16_u_be
      (i32.const 0x0ea2)
      (i32.and
        (i32.const 0x0fff)
        (get_local $op)
      )
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Jump to V0 + NNN
  (func $BNNN (param $pc i32) (param $op i32) (result i32)
    (i32.add
      (i32.load8_u
        (i32.const 0x0eb0)
      )
      (i32.and
        (i32.const 0x0fff)
        (get_local $op)
      )
    )
  )
  ;; Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
  (func $DXYN (param $pc i32) (param $op i32) (result i32) (local $vx i64) (local $vy i32) (local $n i32) (local $I i32) (local $i i32) (local $old i64) (local $update i64) (local $new i64) (local $collision i32)
    ;; vx
    (set_local $vx
      (i64.load8_u offset=0xeb0
        (i32.shr_u
          (i32.and
            (get_local $op)
            (i32.const 0x0f00)
          )
          (i32.const 8)
        )
      )
    )
    ;; vy
    (set_local $vy
      (i32.load8_u offset=0xeb0
        (i32.shr_u
          (i32.and
            (get_local $op)
            (i32.const 0x00f0)
          )
          (i32.const 4)
        )
      )
    )
    ;; n
    (set_local $n
      (i32.and
        (get_local $op)
        (i32.const 0x000f)
      )
    )
    ;; I
    (set_local $I
      (call $load16_u_be
        (i32.const 0x0ea2)
      )
    )
    (loop $loop
      (i64.store offset=0xf00
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
        (tee_local $new
          (i64.xor
            (tee_local $old
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
            (tee_local $update
              (i64.rotl
                (i64.load8_u
                  (get_local $I)
                )
                (i64.sub
                  (i64.const 56) ;; 64 - 8
                  (get_local $vx)
                )
              )
            )
          )
        )
      )
      (set_local $collision
        (i32.or
          (get_local $collision)
          (i64.ne
            (get_local $new)
            (i64.or
              (get_local $old)
              (get_local $update)
            )
          )
        )
      )
      (call $store16_u_be
        (i32.const 0x0ea2)
        (tee_local $I
          (i32.add
            (get_local $I)
            (i32.const 1)
          )
        )
      )
      (br_if $loop
        (i32.lt_u
          (tee_local $i
            (i32.add
              (get_local $i)
              (i32.const 1)
            )
          )
          (get_local $n)
        )
      )
    )
    (i32.store8
      (i32.const 0xebf)
      (get_local $collision)
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Mem/misc. dispatch
  (func $FX$$ (param $pc i32) (param $op i32) (result i32) (local $x i32) (local $subop i32)
    (set_local $x
      (i32.shr_u
        (i32.and
          (get_local $op)
          (i32.const 0x0f00)
        )
        (i32.const 8)
      )
    )
    (set_local $subop
      (i32.and
        (get_local $op)
        (i32.const 0xff)
      )
    )
    (if
      (i32.eq
        (get_local $subop)
        (i32.const 0x1e)
      )
      (then
        (call $FX1E
          (get_local $x)
        ))
    )
    (if
      (i32.eq
        (get_local $subop)
        (i32.const 0x29)
      )
      (then
        (call $FX29
          (get_local $x)
        ))
    )
    (if
      (i32.eq
        (get_local $subop)
        (i32.const 0x55)
      )
      (then
        (call $FX55
          (get_local $x)
        ))
    )
    (if
      (i32.eq
        (get_local $subop)
        (i32.const 0x65)
      )
      (then
        (call $FX65
          (get_local $x)
        ))
    )
    (call $incrementAddress
      (get_local $pc)
    )
  )
  ;; Adds VX to I
  (func $FX1E (param $x i32)
    (call $store16_u_be
      (i32.const 0x0ea2)
      (i32.add
        (call $load16_u_be
          (i32.const 0x0ea2)
        )
        (i32.load8_u offset=0xeb0
          (get_local $x)
        )
      )
    )
  )
  ;; TODO: find space for these sprites!
  ;; Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
  (func $FX29 (param $x i32)
    (call $store16_u_be
      (i32.const 0x0ea2)
      (i32.const 0x0ec0)
    )
  )
  ;; Stores V0 to VX (including VX) in memory starting at address I (increased by X)
  (func $FX55 (param $x i32)
    (call $move_memory
      (i32.const 0x0eb0)
      (call $load16_u_be
        (i32.const 0x0ea2)
      )
      (get_local $x)
    )
  )
  ;; Fills V0 to VX (including VX) with values from memory starting at address I (increased by X)
  (func $FX65 (param $x i32)
    (call $move_memory
      (call $load16_u_be
        (i32.const 0x0ea2)
      )
      (i32.const 0x0eb0)
      (get_local $x)
    )
  )
  (table anyfunc
    (elem
      $0NNN
      $1NNN
      $2NNN
      $3XNN
      $4XNN
      $5XY0
      $6XNN
      $7XNN
      $8XY$
      $9XY0
      $ANNN
      $BNNN
      $NOOP
      $DXYN
      $NOOP
      $FX$$
      ;; bitwise operations
      $8XY0
      $8XY1
      $8XY2
      $8XY3
      $8XY4
      $8XY5
      $8XY6
      $8XY7
      $NOOP
      $NOOP
      $NOOP
      $NOOP
      $NOOP
      $NOOP
      $8XYE
    )
  )
  (func (export "tick") (local $pc i32) (local $op i32)
    (call $store16_u_be
      (i32.const 0x0ea0)
      (call_indirect (type $processInstruction)
        ;; load program counter
        (tee_local $pc
          (call $load16_u_be
            (i32.const 0x0ea0)
          )
        )
        ;; load instruction
        (tee_local $op
          (call $load16_u_be
            (get_local $pc)
          )
        )
        ;; dispatch on leading nibble
        (i32.shr_u
          (i32.and
            (get_local $op)
            (i32.const 0xf000)
          )
          (i32.const 12)
        )
      )
    )
  )
)
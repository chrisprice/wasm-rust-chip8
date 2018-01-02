(module
  (import "_" "mem" (memory 1))
  (data (i32.const 0xec0) "\60\90\20\00\20")
  (data (i32.const 0xea6) "\aa")
  ;; (func $move_memory (param $from i32) (param $to i32) (param $repeat i32) (local $i i32)
  ;;   (loop $loop
  ;;     (i32.store8
  ;;       (i32.add
  ;;         (get_local $to)
  ;;         (get_local $i)
  ;;       )
  ;;       (i32.load8_u
  ;;         (i32.add
  ;;           (get_local $from)
  ;;           (get_local $i)
  ;;         )
  ;;       )
  ;;     )
  ;;     (br_if $loop
  ;;       (i32.le_u
  ;;         (tee_local $i
  ;;           (i32.add
  ;;             (get_local $i)
  ;;             (i32.const 1)
  ;;           )
  ;;         )
  ;;         (get_local $repeat)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; Skip the next instruction if vX does not equal NN
  ;; (func $4XNN (param $pc i32) (param $op i32) (result i32)
  ;;   (if
  ;;     (i32.ne
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x0f00)
  ;;           )
  ;;           (i32.const 8)
  ;;         )
  ;;       )
  ;;       (i32.and
  ;;         (get_local $op)
  ;;         (i32.const 0x00ff)
  ;;       )
  ;;     )
  ;;     (then
  ;;       (set_local $pc
  ;;         (call $incrementAddress
  ;;           (get_local $pc)
  ;;         )
  ;;       )
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Skip the next instruction if vX equals vY
  ;; (func $5XY0 (param $pc i32) (param $op i32) (result i32)
  ;;   (if
  ;;     (i32.eq
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x0f00)
  ;;           )
  ;;           (i32.const 8)
  ;;         )
  ;;       )
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x00f0)
  ;;           )
  ;;           (i32.const 4)
  ;;         )
  ;;       )
  ;;     )
  ;;     (then
  ;;       (set_local $pc
  ;;         (call $incrementAddress
  ;;           (get_local $pc)
  ;;         )
  ;;       )
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Sets vX to NN
  ;; (func $6XNN (param $pc i32) (param $op i32) (result i32)
  ;;   (i32.store8 offset=0x0eb0
  ;;     (i32.shr_u
  ;;       (i32.and
  ;;         (get_local $op)
  ;;         (i32.const 0x0f00)
  ;;       )
  ;;       (i32.const 8)
  ;;     )
  ;;     (i32.and
  ;;       (i32.const 0x0ff)
  ;;       (get_local $op)
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Adds NN to vX
  ;; (func $7XNN (param $pc i32) (param $op i32) (result i32) (local $vx i32)
  ;;   (i32.store8 offset=0x0eb0
  ;;     (tee_local $vx
  ;;       (i32.shr_u
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0x0f00)
  ;;         )
  ;;         (i32.const 8)
  ;;       )
  ;;     )
  ;;     (i32.add
  ;;       (i32.and
  ;;         (i32.const 0x0ff)
  ;;         (get_local $op)
  ;;       )
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (get_local $vx)
  ;;       )
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Bitwise dispatch
  ;; (func $8XY$ (param $pc i32) (param $op i32) (result i32) (local $x i32)
  ;;   (i32.store8 offset=0xeb0
  ;;     (tee_local $x
  ;;       (i32.shr_u
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0x0f00)
  ;;         )
  ;;         (i32.const 8)
  ;;       )
  ;;     )
  ;;     (call_indirect (type $processInstruction)
  ;;       (i32.load8_u offset=0xeb0
  ;;         (get_local $x)
  ;;       )
  ;;       (i32.load8_u offset=0xeb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x00f0)
  ;;           )
  ;;           (i32.const 4)
  ;;         )
  ;;       )
  ;;       (i32.add
  ;;         (i32.const 0x0010)
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0x000f)
  ;;         )
  ;;       )
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Set vX to the value of vY.
  ;; (func $8XY0 (param $vx i32) (param $vy i32) (result i32)
  ;;   get_local $vy
  ;; )
  ;; ;; Set vX to vX or vY.
  ;; (func $8XY1 (param $vx i32) (param $vy i32) (result i32)
  ;;   (i32.or
  ;;     (get_local $vx)
  ;;     (get_local $vy)
  ;;   )
  ;; )
  ;; ;; Set vX to vX and vY.
  ;; (func $8XY2 (param $vx i32) (param $vy i32) (result i32)
  ;;   (i32.and
  ;;     (get_local $vx)
  ;;     (get_local $vy)
  ;;   )
  ;; )
  ;; ;; Set vX to vX xor vY.
  ;; (func $8XY3 (param $vx i32) (param $vy i32) (result i32)
  ;;   (i32.xor
  ;;     (get_local $vx)
  ;;     (get_local $vy)
  ;;   )
  ;; )
  ;; ;; Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
  ;; (func $8XY4 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
  ;;   (tee_local $result
  ;;     (i32.add
  ;;       (get_local $vx)
  ;;       (get_local $vy)
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (i32.const 0x0ebf)
  ;;     (i32.shr_u
  ;;       (i32.and
  ;;         (i32.const 0x0100)
  ;;         (get_local $result)
  ;;       )
  ;;       (i32.const 8)
  ;;     )
  ;;   )
  ;; )
  ;; ;; VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
  ;; (func $8XY5 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
  ;;   (if (result i32)
  ;;     (i32.gt_u
  ;;       (get_local $vx)
  ;;       (get_local $vy)
  ;;     )
  ;;     (then
  ;;       (i32.sub
  ;;         (get_local $vx)
  ;;         (get_local $vy)
  ;;       )
  ;;       (i32.store
  ;;         (i32.const 0x0ebf)
  ;;         (i32.const 0x0)
  ;;       )
  ;;     )
  ;;     (else
  ;;       (i32.sub
  ;;         (get_local $vy)
  ;;         (get_local $vx)
  ;;       )
  ;;       (i32.store
  ;;         (i32.const 0x0ebf)
  ;;         (i32.const 0x1)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; Shifts VY right by one and copies the result to VX. VF is set to the value of the least significant bit of VY before the shift.
  ;; ;;  On (THIS!) some modern interpreters, VX is shifted instead, while VY is ignored.
  ;; (func $8XY6 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
  ;;   (i32.shr_u
  ;;     (get_local $vx)
  ;;     (i32.const 1)
  ;;   )
  ;;   (i32.store
  ;;     (i32.const 0x0ebf)
  ;;     (i32.and
  ;;       (i32.const 0x01)
  ;;       (get_local $vx)
  ;;     )
  ;;   )
  ;; )
  ;; ;; VX is subtracted from VY. VF is set to 0 when there's a borrow, and 1 when there isn't.
  ;; (func $8XY7 (param $vx i32) (param $vy i32) (result i32) (local $result i32)
  ;;   (if (result i32)
  ;;     (i32.gt_u
  ;;       (get_local $vy)
  ;;       (get_local $vx)
  ;;     )
  ;;     (then
  ;;       (i32.sub
  ;;         (get_local $vy)
  ;;         (get_local $vx)
  ;;       )
  ;;       (i32.store
  ;;         (i32.const 0x0ebf)
  ;;         (i32.const 0x0)
  ;;       )
  ;;     )
  ;;     (else
  ;;       (i32.sub
  ;;         (get_local $vx)
  ;;         (get_local $vy)
  ;;       )
  ;;       (i32.store
  ;;         (i32.const 0x0ebf)
  ;;         (i32.const 0x1)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; Shifts VY left by one and copies the result to VX. VF is set to the value of the most significant bit of VY before the shift
  ;; ;;  On (THIS!) some modern interpreters, VX is shifted instead, while VY is ignored.
  ;; (func $8XYE (param $vx i32) (param $vy i32) (result i32) (local $result i32)
  ;;   (i32.shl
  ;;     (get_local $vx)
  ;;     (i32.const 1)
  ;;   )
  ;;   (i32.store
  ;;     (i32.const 0x0ebf)
  ;;     (i32.shr_u
  ;;       (i32.and
  ;;         (i32.const 0x80)
  ;;         (get_local $vx)
  ;;       )
  ;;       (i32.const 7)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Skip the next instruction if vX does not equal vY
  ;; (func $9XY0 (param $pc i32) (param $op i32) (result i32)
  ;;   (if
  ;;     (i32.ne
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x0f00)
  ;;           )
  ;;           (i32.const 8)
  ;;         )
  ;;       )
  ;;       (i32.load8_u offset=0x0eb0
  ;;         (i32.shr_u
  ;;           (i32.and
  ;;             (get_local $op)
  ;;             (i32.const 0x00f0)
  ;;           )
  ;;           (i32.const 4)
  ;;         )
  ;;       )
  ;;     )
  ;;     (then
  ;;       (set_local $pc
  ;;         (call $incrementAddress
  ;;           (get_local $pc)
  ;;         )
  ;;       )
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Sets I to the address NNN
  ;; (func $ANNN (param $pc i32) (param $op i32) (result i32)
  ;;   (i32.store
  ;;     (i32.const 0x0ea2)
  ;;     (i32.and
  ;;       (i32.const 0x0fff)
  ;;       (get_local $op)
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Jump to V0 + NNN
  ;; (func $BNNN (param $pc i32) (param $op i32) (result i32)
  ;;   (i32.add
  ;;     (i32.load8_u
  ;;       (i32.const 0x0eb0)
  ;;     )
  ;;     (i32.and
  ;;       (i32.const 0x0fff)
  ;;       (get_local $op)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Sets VX to random() AND NN
  ;; (func $CXNN (param $pc i32) (param $op i32) (result i32) (local $s i32) (local $a i32)
  ;;   (set_local $s
  ;;     (i32.load8_u
  ;;       (i32.const 0x0ea6)
  ;;     )
  ;;   )
  ;;   (set_local $a
  ;;     (i32.load8_u
  ;;       (i32.const 0x0ea7)
  ;;     )
  ;;   )
  ;;   (set_local $s
  ;;     (i32.xor
  ;;       (get_local $s)
  ;;       (i32.shl
  ;;         (get_local $s)
  ;;         (i32.const 3)
  ;;       )
  ;;     )
  ;;   )
  ;;   (set_local $s
  ;;     (i32.xor
  ;;       (get_local $s)
  ;;       (i32.shr_u
  ;;         (get_local $s)
  ;;         (i32.const 5)
  ;;       )
  ;;     )
  ;;   )
  ;;   (set_local $s
  ;;     (i32.xor
  ;;       (get_local $s)
  ;;       (i32.shr_u
  ;;         (get_local $a)
  ;;         (i32.const 5)
  ;;       )
  ;;     )
  ;;   )
  ;;   (i32.store8 offset=0xeb0
  ;;     (i32.shr_u
  ;;       (i32.and
  ;;         (get_local $op)
  ;;         (i32.const 0x0f00)
  ;;       )
  ;;       (i32.const 8)
  ;;     )
  ;;     (i32.and
  ;;       (i32.and
  ;;         (i32.const 0xff)
  ;;         (get_local $op)
  ;;       )
  ;;       (get_local $s)
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (i32.const 0x0ea6)
  ;;     (get_local $s)
  ;;   )
  ;;   (i32.store8
  ;;     (i32.const 0x0ea7)
  ;;     (i32.add
  ;;       (get_local $a)
  ;;       (i32.const 1)
  ;;     )
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
  ;; (func $DXYN (param $pc i32) (param $op i32) (result i32) (local $vx i64) (local $vy i32) (local $n i32) (local $I i32) (local $i i32) (local $old i64) (local $update i64) (local $new i64) (local $collision i32)
  ;;   ;; vx
  ;;   (set_local $vx
  ;;     (i64.load8_u offset=0xeb0
  ;;       (i32.shr_u
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0x0f00)
  ;;         )
  ;;         (i32.const 8)
  ;;       )
  ;;     )
  ;;   )
  ;;   ;; vy
  ;;   (set_local $vy
  ;;     (i32.load8_u offset=0xeb0
  ;;       (i32.shr_u
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0x00f0)
  ;;         )
  ;;         (i32.const 4)
  ;;       )
  ;;     )
  ;;   )
  ;;   ;; n
  ;;   (set_local $n
  ;;     (i32.and
  ;;       (get_local $op)
  ;;       (i32.const 0x000f)
  ;;     )
  ;;   )
  ;;   ;; I
  ;;   (set_local $I
  ;;     (i32.load16_u
  ;;       (i32.const 0x0ea2)
  ;;     )
  ;;   )
  ;;   (loop $loop
  ;;     (i64.store offset=0xf00
  ;;       (i32.mul
  ;;         (i32.const 8)
  ;;         (i32.rem_u
  ;;           (i32.add
  ;;             (get_local $vy)
  ;;             (get_local $i)
  ;;           )
  ;;           (i32.const 32)
  ;;         )
  ;;       )
  ;;       (tee_local $new
  ;;         (i64.xor
  ;;           (tee_local $old
  ;;             (i64.load offset=0xf00
  ;;               (i32.mul
  ;;                 (i32.const 8)
  ;;                 (i32.rem_u
  ;;                   (i32.add
  ;;                     (get_local $vy)
  ;;                     (get_local $i)
  ;;                   )
  ;;                   (i32.const 32)
  ;;                 )
  ;;               )
  ;;             )
  ;;           )
  ;;           (tee_local $update
  ;;             (i64.rotl
  ;;               (i64.load8_u
  ;;                 (get_local $I)
  ;;               )
  ;;               (i64.sub
  ;;                 (i64.const 56) ;; 64 - 8
  ;;                 (get_local $vx)
  ;;               )
  ;;             )
  ;;           )
  ;;         )
  ;;       )
  ;;     )
  ;;     (set_local $collision
  ;;       (i32.or
  ;;         (get_local $collision)
  ;;         (i64.ne
  ;;           (get_local $new)
  ;;           (i64.or
  ;;             (get_local $old)
  ;;             (get_local $update)
  ;;           )
  ;;         )
  ;;       )
  ;;     )
  ;;     (set_local $I
  ;;       (i32.add
  ;;         (get_local $I)
  ;;         (i32.const 1)
  ;;       )
  ;;     )
  ;;     (br_if $loop
  ;;       (i32.lt_u
  ;;         (tee_local $i
  ;;           (i32.add
  ;;             (get_local $i)
  ;;             (i32.const 1)
  ;;           )
  ;;         )
  ;;         (get_local $n)
  ;;       )
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (i32.const 0xebf)
  ;;     (get_local $collision)
  ;;   )
  ;;   (call $incrementAddress
  ;;     (get_local $pc)
  ;;   )
  ;; )
  ;; ;; Skip/don't skip if VX is/isn't pressed
  ;; (func $EX$$ (param $pc i32) (param $op i32) (result i32)
  ;;   (if (result i32)
  ;;     (i32.xor
  ;;       (i32.eq
  ;;         (i32.load8_u offset=0xeb0
  ;;           (i32.shr_u
  ;;             (i32.and
  ;;               (get_local $op)
  ;;               (i32.const 0x0f00)
  ;;             )
  ;;             (i32.const 8)
  ;;           )
  ;;         )
  ;;         (i32.load8_u
  ;;           (i32.const 0xea8)
  ;;         )
  ;;       )
  ;;       (i32.eq
  ;;         (i32.and
  ;;           (get_local $op)
  ;;           (i32.const 0xff)
  ;;         )
  ;;         (i32.const 0x9e)
  ;;       )
  ;;     )
  ;;     (then
  ;;       (call $incrementAddress
  ;;         (get_local $pc)
  ;;       )
  ;;     )
  ;;     (else
  ;;       (i32.add
  ;;         (get_local $pc)
  ;;         (i32.const 4)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; Mem/misc. dispatch
  ;; (func $FX$$ (param $pc i32) (param $op i32) (result i32) (local $x i32) (local $subop i32)
  ;;   (set_local $x
  ;;     (i32.shr_u
  ;;       (i32.and
  ;;         (get_local $op)
  ;;         (i32.const 0x0f00)
  ;;       )
  ;;       (i32.const 8)
  ;;     )
  ;;   )
  ;;   (set_local $subop
  ;;     (i32.and
  ;;       (get_local $op)
  ;;       (i32.const 0xff)
  ;;     )
  ;;   )
  ;;   (if (result i32)
  ;;     (i32.eq
  ;;       (get_local $subop)
  ;;       (i32.const 0x0a)
  ;;     )
  ;;     (then
  ;;     ;; Waits for keypress, sets VX to key
  ;;     ;; Inlined to allow mutation of pc
  ;;     ;; (func $FX0A (param $x i32)
  ;;       (if (result i32)
  ;;         (i32.ne
  ;;           (i32.load8_u
  ;;             (i32.const 0xea8)
  ;;           )
  ;;           (i32.const 0)
  ;;         )
  ;;         (then
  ;;           (i32.store8 offset=0xeb0
  ;;             (get_local $x)
  ;;             (i32.load8_u
  ;;               (i32.const 0xea8)
  ;;             )
  ;;           )
  ;;           (call $incrementAddress
  ;;             (get_local $pc)
  ;;           )
  ;;         )
  ;;         (else
  ;;           (get_local $pc)
  ;;         )
  ;;       )
  ;;     ;; )
  ;;     )
  ;;     (else
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x07)
  ;;         )
  ;;         (then
  ;;           (call $FX07
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x15)
  ;;         )
  ;;         (then
  ;;           (call $FX15
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x18)
  ;;         )
  ;;         (then
  ;;           (call $FX18
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x1e)
  ;;         )
  ;;         (then
  ;;           (call $FX1E
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x29)
  ;;         )
  ;;         (then
  ;;           (call $FX29
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x33)
  ;;         )
  ;;         (then
  ;;           (call $FX33
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x55)
  ;;         )
  ;;         (then
  ;;           (call $FX55
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (if
  ;;         (i32.eq
  ;;           (get_local $subop)
  ;;           (i32.const 0x65)
  ;;         )
  ;;         (then
  ;;           (call $FX65
  ;;             (get_local $x)
  ;;           ))
  ;;       )
  ;;       (call $incrementAddress
  ;;         (get_local $pc)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; Sets vx to the value of the delay timer
  ;; (func $FX07 (param $x i32)
  ;;   (i32.store8 offset=0xeb0
  ;;     (get_local $x)
  ;;     (i32.load8_u
  ;;       (i32.const 0xea4)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Sets the delay timer to the value of vx
  ;; (func $FX15 (param $x i32)
  ;;   (i32.store8
  ;;     (i32.const 0xea4)
  ;;     (i32.load8_u offset=0xeb0
  ;;       (get_local $x)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Sets the sound timer to the value of vx
  ;; (func $FX18 (param $x i32)
  ;;   (i32.store8
  ;;     (i32.const 0xea5)
  ;;     (i32.load8_u offset=0xeb0
  ;;       (get_local $x)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Adds VX to I
  ;; (func $FX1E (param $x i32)
  ;;   (i32.store16
  ;;     (i32.const 0x0ea2)
  ;;     (i32.add
  ;;       (i32.load16_u
  ;;         (i32.const 0x0ea2)
  ;;       )
  ;;       (i32.load8_u offset=0xeb0
  ;;         (get_local $x)
  ;;       )
  ;;     )
  ;;   )
  ;; )
  ;; ;; TODO: find space for these sprites!
  ;; ;; Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
  ;; (func $FX29 (param $x i32)
  ;;   (i32.store16
  ;;     (i32.const 0x0ea2)
  ;;     (i32.const 0x0ec0)
  ;;   )
  ;; )
  ;; ;; Stores the binary-coded decimal representation of VX, with the most significant of three digits at the address in I
  ;; (func $FX33 (param $x i32) (local $i i32)
  ;;   (set_local $i
  ;;     (i32.load16_u
  ;;       (i32.const 0x0ea2)
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (get_local $i)
  ;;     (i32.div_u
  ;;       (i32.load8_u
  ;;         (get_local $x)
  ;;       )
  ;;       (i32.const 100)
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (i32.add
  ;;       (get_local $i)
  ;;       (i32.const 1)
  ;;     )
  ;;     (i32.div_u
  ;;       (i32.rem_u
  ;;         (i32.load8_u
  ;;           (get_local $x)
  ;;         )
  ;;         (i32.const 100)
  ;;       )
  ;;       (i32.const 10)
  ;;     )
  ;;   )
  ;;   (i32.store8
  ;;     (i32.add
  ;;       (get_local $i)
  ;;       (i32.const 2)
  ;;     )
  ;;     (i32.rem_u
  ;;       (i32.load8_u offset=0xeb0
  ;;         (get_local $x)
  ;;       )
  ;;       (i32.const 10)
  ;;     )
  ;;   )
  ;; )
  ;; ;; Stores V0 to VX (including VX) in memory starting at address I (increased by X)
  ;; (func $FX55 (param $x i32)
  ;;   (call $move_memory
  ;;     (i32.const 0x0eb0)
  ;;     (i32.load16_u
  ;;       (i32.const 0x0ea2)
  ;;     )
  ;;     (get_local $x)
  ;;   )
  ;; )
  ;; ;; Fills V0 to VX (including VX) with values from memory starting at address I (increased by X)
  ;; (func $FX65 (param $x i32)
  ;;   (call $move_memory
  ;;     (i32.load16_u
  ;;       (i32.const 0x0ea2)
  ;;     )
  ;;     (i32.const 0x0eb0)
  ;;     (get_local $x)
  ;;   )
  ;; )
  ;; (table anyfunc
  ;;   (elem
  ;;     $0NNN
  ;;     $1NNN
  ;;     $2NNN
  ;;     $3XNN
  ;;     $4XNN
  ;;     $5XY0
  ;;     $6XNN
  ;;     $7XNN
  ;;     $8XY$
  ;;     $9XY0
  ;;     $ANNN
  ;;     $BNNN
  ;;     $CXNN
  ;;     $DXYN
  ;;     $EX$$
  ;;     $FX$$
  ;;     ;; bitwise operations
  ;;     $8XY0
  ;;     $8XY1
  ;;     $8XY2
  ;;     $8XY3
  ;;     $8XY4
  ;;     $8XY5
  ;;     $8XY6
  ;;     $8XY7
  ;;     $NOOP
  ;;     $NOOP
  ;;     $NOOP
  ;;     $NOOP
  ;;     $NOOP
  ;;     $NOOP
  ;;     $8XYE
  ;;   )
  ;; )
  (func (export "tick")
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
    (local $y i32)
    ;; registers
    (local $vx i32)
    (local $vy i32)
    ;; loop variables
    (local $i i32)
    (local $l i32)
    ;; instruction specific working variables
    (local $a i32)
    (local $b i32)
    (local $c i32)
    (local $d i32)
    (local $A i64)
    (local $B i64)
    (local $C i64)

    ;; --- LOAD INTERNAL REGISTERS ---
    ;; load programCounter
    (set_local $programCounter
      (i32.load16_u
        (i32.const 0x0ea0)
      )
    )
    ;; load address
    (set_local $address
      (i32.load16_u
        (i32.const 0x0ea2)
      )
    )
    ;; load instruction (big endian)
    (set_local $instruction
      (i32.or
        (i32.shl
          (i32.load8_u
            (get_local $programCounter)
          )
          (i32.const 8)
        )
        (i32.load8_u offset=1
          (get_local $programCounter)
        )
      )
    )
    ;; load stackPointer
    (set_local $stackPointer
      (i32.load8_u
        (i32.const 0x0ecf)
      )
    )
    ;; load (and decrement if > 0) delayTimer
    (set_local $delayTimer
      (select
        (tee_local $delayTimer
          (i32.load8_u
            (i32.const 0xea4)
          )
        )
        (i32.sub
          (get_local $delayTimer)
          (i32.const 1)
        )
        (i32.eqz
          (get_local $delayTimer)
        )
      )
    )
    ;; load (and decrement if > 0) soundTimer
    (set_local $soundTimer
      (select
        (tee_local $soundTimer
          (i32.load8_u
            (i32.const 0xea5)
          )
        )
        (i32.sub
          (get_local $soundTimer)
          (i32.const 1)
        )
        (i32.eqz
          (get_local $soundTimer)
        )
      )
    )
    ;; load key
    (set_local $key
      (i32.load8_u
        (i32.const 0x0ea8)
      )
    )

    ;; --- EXTRACT OPERANDS ---
    ;; extract m---
    (set_local $m
      (i32.shr_u
        (i32.and
          (get_local $instruction)
          (i32.const 0xf000)
        )
        (i32.const 12)
      )
    )
    ;; extract ---n
    (set_local $n
      (i32.and
        (get_local $instruction)
        (i32.const 0xf)
      )
    )
    ;; extract --nn
    (set_local $nn
      (i32.and
        (get_local $instruction)
        (i32.const 0xff)
      )
    )
    ;; extract -nnn
    (set_local $nnn
      (i32.and
        (get_local $instruction)
        (i32.const 0xfff)
      )
    )
    ;; extract -x--
    (set_local $x
      (i32.shr_u
        (i32.and
          (get_local $instruction)
          (i32.const 0xf00)
        )
        (i32.const 8)
      )
    )
    ;; extract --y-
    (set_local $y
      (i32.shr_u
        (i32.and
          (get_local $instruction)
          (i32.const 0xf0)
        )
        (i32.const 4)
      )
    )

    ;; --- LOAD REGISTERS ---
    ;; load register X (vx)
    (set_local $vx
      (i32.load8_u offset=0x0eb0
        (get_local $x)
      )
    )
    ;; load register Y (vy)
    (set_local $vy
      (i32.load8_u offset=0x0eb0
        (get_local $y)
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
                                          (get_local $m)
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
                                                      (i32.store8
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
                                                  (set_local $delayTimer
                                                    (get_local $vx)
                                                  )
                                                  (br $instructionProcessing)
                                                )
                                                ;; fx33 bcd
                                                (i32.store8 offset=0
                                                  (get_local $address)
                                                  (i32.div_u
                                                    (get_local $vx)
                                                    (i32.const 100)
                                                  )
                                                )
                                                (i32.store8 offset=1
                                                  (get_local $address)
                                                  (i32.div_u
                                                    (i32.rem_u
                                                      (get_local $vx)
                                                      (i32.const 100)
                                                    )
                                                    (i32.const 10)
                                                  )
                                                )
                                                (i32.store8 offset=2
                                                  (get_local $address)
                                                  (i32.rem_u
                                                    (get_local $vx)
                                                    (i32.const 10)
                                                  )
                                                )
                                                (br $instructionProcessing)
                                              )
                                              ;; fx29 address = sprite(vx)
                                              ;; TODO: find space!
                                              (set_local $address
                                                (i32.const 0xec0)
                                              )
                                              (br $instructionProcessing)
                                            )
                                            ;; fx1e address += vx
                                            ;; could share logic with $axxx
                                            (set_local $address
                                              (i32.add
                                                (get_local $vx)
                                                (get_local $address)
                                              )
                                            )
                                            (br $instructionProcessing)
                                          )
                                          ;; fx18 sound(vx)
                                          (set_local $soundTimer
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
                                    (tee_local $A
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
                                  )
                                  (i32.store8
                                    (i32.const 0xebf)
                                    (tee_local $d
                                      (i32.or
                                        (get_local $d)
                                        (i64.ne
                                          (get_local $A)
                                          (i64.or
                                            (get_local $B)
                                            (get_local $C)
                                          )
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
                            (set_local $address
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
                        (set_local $nn
                          (if (result i32)
                            (i32.and
                              (get_local $n)
                              (i32.const 0x4)
                            )
                            ;; 8xy4, 8xy5, 8xy6, 8xy7, 8xye
                            (then
                              (select
                                ;; 8xy5 vx - vy, 8xy7 vy - vx
                                ;; vx > vy (0)  vx - vy (0)  vx - vy (0)  0
                                ;; vx < vy (1)  vx - vy (0)  vy - vx (1)  1
                                ;; vx > vy (0)  vy - vx (1)  vx - vy (0)  1
                                ;; vx < vy (1)  vy - vx (1)  vy - vx (1)  0
                                ;; carry = xor
                                (i32.or
                                  (select
                                    (i32.sub
                                      (get_local $vy)
                                      (get_local $vx)
                                    )
                                    (i32.sub
                                      (get_local $vx)
                                      (get_local $vy)
                                    )
                                    (tee_local $a
                                      (i32.gt_u
                                        (get_local $vy)
                                        (get_local $vx)
                                      )
                                    )
                                  )
                                  (select
                                    (i32.const 0x100)
                                    (i32.const 0x0)
                                    (i32.xor
                                      (get_local $a)
                                      (i32.and
                                        (get_local $n)
                                        (i32.const 0x2)
                                      )
                                    )
                                  )
                                )
                                ;; 8xy4 vx + vy, 8xy6 vx >> 1, 8xye vx << 1
                                (select
                                  (i32.rotl
                                    (get_local $vx)
                                    ;; 8xy6 >> 1, 8xye << 1
                                    ;; shift left 31 to shift right 1
                                    (select
                                      (i32.const 1)
                                      (i32.const 31)
                                      (i32.and
                                        (get_local $n)
                                        (i32.const 0x8)
                                      )
                                    )
                                  )
                                  (i32.add
                                    (get_local $vx)
                                    (get_local $vy)
                                  )
                                  (i32.and
                                    (get_local $n)
                                    (i32.const 0x2)
                                  )
                                )
                                (i32.and
                                  (get_local $n)
                                  (i32.const 0x1)
                                )
                              )
                              tee_local $nn
                              (i32.store8
                                (i32.const 0xebf)
                                (i32.ne
                                  (i32.const 0x00)
                                  ;; equivalent to AND 0xffffff00
                                  (i32.shr_u
                                    (get_local $nn)
                                    (i32.const 8)
                                  )
                                )
                              )
                            )
                            (else
                              ;; 8xy0, 8xy1, 8xy2, 8xy3
                              (select
                                ;; 8xy2 AND, 8xy3 XOR
                                (select
                                  (i32.xor
                                    (get_local $vx)
                                    (get_local $vy)
                                  )
                                  (i32.and
                                    (get_local $vx)
                                    (get_local $vy)
                                  )
                                  ;; could stash in a local
                                  (i32.and
                                    (get_local $n)
                                    (i32.const 0x1)
                                  )
                                )
                                ;; 8xy0, 8xy1
                                (select
                                  (i32.or
                                    (get_local $vx)
                                    (get_local $vy)
                                  )
                                  (get_local $vy)
                                  (i32.and
                                    (get_local $n)
                                    (i32.const 0x1)
                                  )
                                )
                                (i32.and
                                  (get_local $n)
                                  (i32.const 0x2)
                                )
                              )
                            )
                          )
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
                    (i32.store8 offset=0x0eb0
                      (get_local $x)
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
            (i32.store16 offset=0xed0
              (get_local $stackPointer)
              (get_local $programCounter)
            )
            ;; incremented stack pointer
            (set_local $stackPointer
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
            (set_local $stackPointer
              (i32.sub
                (get_local $stackPointer)
                (i32.const 2)
              )
            )
            ;; set program counter to address from stack
            (set_local $programCounter
              (i32.load16_u offset=0xed0
                (get_local $stackPointer)
              )
            )
          )
          (else
            ;; 00e0 clear screen
            (i64.store offset=0xf00
              (i32.mul
                (get_local $i)
                (i32.const 8)
              )
              (i64.const 0)
            )
            (set_local $l
              (i32.const 32)
            )
          )
        )
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

    ;; --- STORE INTERNAL REGISTERS ---
    ;; store soundTimer
    (i32.store8
      (i32.const 0xea5)
      (get_local $soundTimer)
    )
    ;; store delayTimer
    (i32.store8
      (i32.const 0xea4)
      (get_local $delayTimer)
    )
    ;; store stackPointer
    (i32.store8
      (i32.const 0x0ecf)
      (get_local $stackPointer)
    )
    ;; store address
    (i32.store16
      (i32.const 0x0ea2)
      (get_local $address)
    )
    ;; store programCounter
    (i32.store16
      (i32.const 0x0ea0)
      (get_local $programCounter)
    )
  )
)
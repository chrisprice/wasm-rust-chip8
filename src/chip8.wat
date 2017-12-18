(module
  (import "_" "mem" (memory 1))
  (type $processInstruction (func (param $pc i32) (param $op i32) (result i32)))
  (func $incrementAddress (param $value i32) (result i32)
    (i32.add
      (i32.const 2)
      (get_local $value)
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
        (i32.const 0)
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
    (i32.load16_u offset=0xed0
      (get_local $sp)
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
    (i32.store16 offset=0xed0
      (get_local $sp)
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
  (func $8XYZ (param $pc i32) (param $op i32) (result i32) (local $vx i32)
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
  (func $8XY0 (param $vx i32) (param $vy i32) (result i32)
    i32.const 4
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
  ;; Jump to V0 + NNN
  (func $BNNN (param $pc i32) (param $op i32) (result i32)
    (i32.add
      (i32.load16_u
        (i32.const 0x0eb0)
      )
      (i32.and
        (i32.const 0x0fff)
        (get_local $op)
      )
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
      $8XYZ
      $9XY0
      $NOOP
      $BNNN
      $NOOP
      $NOOP
      $NOOP
      $NOOP
      ;; bitwise operations
      $8XY0
    )
  )
  (func (export "tick") (local $pc i32) (local $op i32)
    (i32.store16
      (i32.const 0x0ea0)
      (call_indirect (type $processInstruction)
        ;; load program counter
        (tee_local $pc
          (i32.load16_u
            (i32.const 0x0ea0)
          )
        )
        ;; load instruction
        (tee_local $op
          (i32.load16_u
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
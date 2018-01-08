(module
  (import "_" "_" (memory 1))
  ;; ;; initialise microcode
  (data (i32.const 0xf000) "\01\01\01\01")
  (global $microcode (mut i32) i32.const 0)
  (func $condition (result i32)
    (i32.and
      (get_global $microcode)
      (i32.const 0x1)
    )
    (set_global $microcode
      (i32.shr_u
        (get_global $microcode)
        (i32.const 0x1)
      )
    )
  )
  (func (export "_")
    (param $timerTick i32)
    (result i32)
    (local $programCounter i32)
    (local $instruction i32)
    ;; loop variables
    (local $i i32)
    (local $l i32)

    ;; (set_global $microcode
      (i32.load offset=0xf000
        (i32.shr_u
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
          (i32.const 12)
        )
      )
    ;; )

    ;; (get_global $microcode)
    ;; (get_local $instruction)

    (if (call $condition)
      (then
      ;; increment programCounter
      (set_local $programCounter
        (i32.add
          (get_local $programCounter)
          (i32.const 2)
        )
      )
      )
    )

    ;; --- INSTRUCTION LOOP BLOCK ---
    ;; allow instructions to loop if required
    ;; looping instructions should set l in their implementation
    ;; l defaults to 0 causing a single iteration
    ;; (equivalent to `do {} while (i < l)`)
    (loop $loop


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
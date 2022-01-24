; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- | FileCheck %s

; PR46195 - https://bugs.llvm.org/show_bug.cgi?id=46195
; It is not safe to sink the load after the call.

define void @translate(i16* %ptr) nounwind {
; CHECK-LABEL: translate:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    movl $-32707, %ebp # imm = 0x803D
; CHECK-NEXT:    andl (%rdi), %ebp
; CHECK-NEXT:    callq maybe_mutate
; CHECK-NEXT:    orl $514, %ebp # imm = 0x202
; CHECK-NEXT:    movw %bp, (%rbx)
; CHECK-NEXT:    addq $8, %rsp
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
  %i0 = load i16, i16* %ptr, align 4
  call void @maybe_mutate(i16* %ptr)
  %i1 = and i16 %i0, -32707
  %i2 = or i16 %i1, 514
  store i16 %i2, i16* %ptr, align 4
  ret void
}

declare void @maybe_mutate(i16*)
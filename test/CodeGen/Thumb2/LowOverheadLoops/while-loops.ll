; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-eabi -mattr=+mve --verify-machineinstrs %s -o - | FileCheck %s

define void @simple(i32* nocapture readonly %x, i32* nocapture readnone %y, i32* nocapture %z, i32 %m, i32 %n) {
; CHECK-LABEL: simple:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    ldr r1, [sp, #8]
; CHECK-NEXT:    mov r12, r3
; CHECK-NEXT:    movs r3, #0
; CHECK-NEXT:    add.w lr, r1, #3
; CHECK-NEXT:    cmp.w r3, lr, lsr #2
; CHECK-NEXT:    beq .LBB0_3
; CHECK-NEXT:  @ %bb.1: @ %do.body.preheader
; CHECK-NEXT:    dlstp.32 lr, r1
; CHECK-NEXT:  .LBB0_2: @ %do.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q0, [r0], #16
; CHECK-NEXT:    vaddva.s32 r12, q0
; CHECK-NEXT:    letp lr, .LBB0_2
; CHECK-NEXT:  .LBB0_3: @ %if.end
; CHECK-NEXT:    str.w r12, [r2]
; CHECK-NEXT:    pop {r7, pc}
entry:
  %add = add i32 %n, 3
  %div = lshr i32 %add, 2
  %cmp.not = icmp eq i32 %div, 0
  br i1 %cmp.not, label %if.end, label %do.body

do.body:                                          ; preds = %entry, %do.body
  %n.addr.0 = phi i32 [ %sub, %do.body ], [ %n, %entry ]
  %count.0 = phi i32 [ %sub3, %do.body ], [ %div, %entry ]
  %s.0 = phi i32 [ %add2, %do.body ], [ %m, %entry ]
  %x.addr.0 = phi i32* [ %add.ptr, %do.body ], [ %x, %entry ]
  %0 = tail call <4 x i1> @llvm.arm.mve.vctp32(i32 %n.addr.0)
  %1 = bitcast i32* %x.addr.0 to <4 x i32>*
  %2 = load <4 x i32>, <4 x i32>* %1, align 4
  %3 = tail call i32 @llvm.arm.mve.addv.predicated.v4i32.v4i1(<4 x i32> %2, i32 0, <4 x i1> %0)
  %add2 = add nsw i32 %3, %s.0
  %add.ptr = getelementptr inbounds i32, i32* %x.addr.0, i32 4
  %sub = add i32 %n.addr.0, -4
  %sub3 = add nsw i32 %count.0, -1
  %cmp4 = icmp sgt i32 %count.0, 1
  br i1 %cmp4, label %do.body, label %if.end

if.end:                                           ; preds = %do.body, %entry
  %s.1 = phi i32 [ %m, %entry ], [ %add2, %do.body ]
  store i32 %s.1, i32* %z, align 4
  ret void
}

define void @nested(i32* nocapture readonly %x, i32* nocapture readnone %y, i32* nocapture %z, i32 %m, i32 %n) {
; CHECK-LABEL: nested:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, r8, r9, lr}
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, r9, lr}
; CHECK-NEXT:    cbz r3, .LBB1_8
; CHECK-NEXT:  @ %bb.1: @ %for.body.preheader
; CHECK-NEXT:    ldr r5, [sp, #28]
; CHECK-NEXT:    mov.w r12, #0
; CHECK-NEXT:    movs r1, #0
; CHECK-NEXT:    b .LBB1_4
; CHECK-NEXT:  .LBB1_2: @ in Loop: Header=BB1_4 Depth=1
; CHECK-NEXT:    mov r4, r3
; CHECK-NEXT:  .LBB1_3: @ %if.end
; CHECK-NEXT:    @ in Loop: Header=BB1_4 Depth=1
; CHECK-NEXT:    str.w r4, [r2, r1, lsl #2]
; CHECK-NEXT:    adds r1, #1
; CHECK-NEXT:    cmp r1, r3
; CHECK-NEXT:    beq .LBB1_8
; CHECK-NEXT:  .LBB1_4: @ %for.body
; CHECK-NEXT:    @ =>This Loop Header: Depth=1
; CHECK-NEXT:    @ Child Loop BB1_6 Depth 2
; CHECK-NEXT:    adds r7, r5, #3
; CHECK-NEXT:    cmp.w r12, r7, lsr #2
; CHECK-NEXT:    beq .LBB1_2
; CHECK-NEXT:  @ %bb.5: @ %do.body.preheader
; CHECK-NEXT:    @ in Loop: Header=BB1_4 Depth=1
; CHECK-NEXT:    bic r9, r7, #3
; CHECK-NEXT:    mov r7, r5
; CHECK-NEXT:    mov r4, r3
; CHECK-NEXT:    add.w r8, r0, r9, lsl #2
; CHECK-NEXT:    dlstp.32 lr, r5
; CHECK-NEXT:  .LBB1_6: @ %do.body
; CHECK-NEXT:    @ Parent Loop BB1_4 Depth=1
; CHECK-NEXT:    @ => This Inner Loop Header: Depth=2
; CHECK-NEXT:    vldrw.u32 q0, [r0], #16
; CHECK-NEXT:    vaddva.s32 r4, q0
; CHECK-NEXT:    letp lr, .LBB1_6
; CHECK-NEXT:  @ %bb.7: @ %if.end.loopexit
; CHECK-NEXT:    @ in Loop: Header=BB1_4 Depth=1
; CHECK-NEXT:    sub.w r5, r5, r9
; CHECK-NEXT:    mov r0, r8
; CHECK-NEXT:    b .LBB1_3
; CHECK-NEXT:  .LBB1_8: @ %for.cond.cleanup
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, r9, pc}
entry:
  %cmp20.not = icmp eq i32 %m, 0
  br i1 %cmp20.not, label %for.cond.cleanup, label %for.body

for.cond.cleanup:                                 ; preds = %if.end, %entry
  ret void

for.body:                                         ; preds = %entry, %if.end
  %x.addr.023 = phi i32* [ %x.addr.2, %if.end ], [ %x, %entry ]
  %a.022 = phi i32 [ %inc, %if.end ], [ 0, %entry ]
  %n.addr.021 = phi i32 [ %n.addr.2, %if.end ], [ %n, %entry ]
  %add = add i32 %n.addr.021, 3
  %div = lshr i32 %add, 2
  %cmp1.not = icmp eq i32 %div, 0
  br i1 %cmp1.not, label %if.end, label %do.body.preheader

do.body.preheader:                                ; preds = %for.body
  %0 = and i32 %add, -4
  %scevgep = getelementptr i32, i32* %x.addr.023, i32 %0
  br label %do.body

do.body:                                          ; preds = %do.body.preheader, %do.body
  %n.addr.1 = phi i32 [ %sub, %do.body ], [ %n.addr.021, %do.body.preheader ]
  %count.0 = phi i32 [ %sub4, %do.body ], [ %div, %do.body.preheader ]
  %s.0 = phi i32 [ %add3, %do.body ], [ %m, %do.body.preheader ]
  %x.addr.1 = phi i32* [ %add.ptr, %do.body ], [ %x.addr.023, %do.body.preheader ]
  %1 = tail call <4 x i1> @llvm.arm.mve.vctp32(i32 %n.addr.1)
  %2 = bitcast i32* %x.addr.1 to <4 x i32>*
  %3 = load <4 x i32>, <4 x i32>* %2, align 4
  %4 = tail call i32 @llvm.arm.mve.addv.predicated.v4i32.v4i1(<4 x i32> %3, i32 0, <4 x i1> %1)
  %add3 = add nsw i32 %4, %s.0
  %add.ptr = getelementptr inbounds i32, i32* %x.addr.1, i32 4
  %sub = add i32 %n.addr.1, -4
  %sub4 = add nsw i32 %count.0, -1
  %cmp5 = icmp sgt i32 %count.0, 1
  br i1 %cmp5, label %do.body, label %if.end.loopexit

if.end.loopexit:                                  ; preds = %do.body
  %5 = sub i32 %n.addr.021, %0
  br label %if.end

if.end:                                           ; preds = %if.end.loopexit, %for.body
  %n.addr.2 = phi i32 [ %n.addr.021, %for.body ], [ %5, %if.end.loopexit ]
  %s.1 = phi i32 [ %m, %for.body ], [ %add3, %if.end.loopexit ]
  %x.addr.2 = phi i32* [ %x.addr.023, %for.body ], [ %scevgep, %if.end.loopexit ]
  %arrayidx = getelementptr inbounds i32, i32* %z, i32 %a.022
  store i32 %s.1, i32* %arrayidx, align 4
  %inc = add nuw nsw i32 %a.022, 1
  %exitcond.not = icmp eq i32 %inc, %m
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

declare <4 x i1> @llvm.arm.mve.vctp32(i32)
declare i32 @llvm.arm.mve.addv.predicated.v4i32.v4i1(<4 x i32>, i32, <4 x i1>)
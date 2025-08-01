; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck -check-prefix=GFX900 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1010 < %s | FileCheck -check-prefix=GFX1010 %s

;------------------------------------------------------------------------------
; I32 Tests
;------------------------------------------------------------------------------

; Should be folded: icmp eq + select with constant in true value
define i32 @icmp_select_fold_eq_i32_imm(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_fold_eq_i32_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_eq_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_i32_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 %arg, 4242
  %sel = select i1 %cmp, i32 4242, i32 %other
  ret i32 %sel
}

; Should be folded: icmp eq + select with constant in true value (commutative)
define i32 @icmp_select_fold_eq_imm_i32(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_fold_eq_imm_i32:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_eq_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_imm_i32:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 4242, %arg
  %sel = select i1 %cmp, i32 4242, i32 %other
  ret i32 %sel
}

; Should be folded: icmp ne + select with constant in false value
define i32 @icmp_select_fold_ne_i32_imm(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_fold_ne_i32_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_i32_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i32 %arg, 4242
  %sel = select i1 %cmp, i32 %other, i32 4242
  ret i32 %sel
}

; Should be folded: icmp ne + select with constant in false value (commutative)
define i32 @icmp_select_fold_ne_imm_i32(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_fold_ne_imm_i32:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_imm_i32:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i32 4242, %arg
  %sel = select i1 %cmp, i32 %other, i32 4242
  ret i32 %sel
}

; Should NOT be folded: icmp eq with different constants
define i32 @icmp_select_no_fold_i32_different(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_different:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x978
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_different:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x978, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 %arg, 4242
  %sel = select i1 %cmp, i32 2424, i32 %other
  ret i32 %sel
}

; Should NOT be folded: icmp eq with constant in other position
define i32 @icmp_select_no_fold_i32_other_pos(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_other_pos:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x1092
; GFX900-NEXT:    v_cmp_eq_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_other_pos:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x1092, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 %arg, 4242
  %sel = select i1 %cmp, i32 %other, i32 4242
  ret i32 %sel
}

; Should NOT be folded: unsupported comparison type
define i32 @icmp_select_no_fold_i32_unsupported_cmp(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_unsupported_cmp:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1094
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x102d
; GFX900-NEXT:    v_cmp_gt_u32_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_unsupported_cmp:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_gt_u32_e32 vcc_lo, 0x1094, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x102d, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ugt i32 %arg, 4243
  %sel = select i1 %cmp, i32 4141, i32 %other
  ret i32 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i32 @icmp_select_no_fold_i32_enc_imm(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_enc_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, 0, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_enc_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, 0, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 %arg, 0
  %sel = select i1 %cmp, i32 0, i32 %other
  ret i32 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i32 @icmp_select_no_fold_i32_enc_imm_2(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_enc_imm_2:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, 64, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 64, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_enc_imm_2:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, 64, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 64, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i32 64, %arg
  %sel = select i1 %cmp, i32 64, i32 %other
  ret i32 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i32 @icmp_select_no_fold_i32_enc_imm_3(i32 %arg, i32 %other) {
; GFX900-LABEL: icmp_select_no_fold_i32_enc_imm_3:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u32_e32 vcc, -16, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, -16, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i32_enc_imm_3:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u32_e32 vcc_lo, -16, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, -16, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i32 %arg, -16
  %sel = select i1 %cmp, i32 %other, i32 -16
  ret i32 %sel
}

;------------------------------------------------------------------------------
; I64 Tests
;------------------------------------------------------------------------------

; Should be folded: icmp eq + select with constant in true value
define i64 @icmp_select_fold_eq_i64_imm(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_fold_eq_i64_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_i64_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_eq_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 %arg, 424242424242
  %sel = select i1 %cmp, i64 424242424242, i64 %other
  ret i64 %sel
}

; Should be folded: icmp eq + select with constant in true value (commutative)
define i64 @icmp_select_fold_eq_imm_i64(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_fold_eq_imm_i64:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_imm_i64:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_eq_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 424242424242, %arg
  %sel = select i1 %cmp, i64 424242424242, i64 %other
  ret i64 %sel
}

; Should be folded: icmp ne + select with constant in false value
define i64 @icmp_select_fold_ne_i64_imm(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_fold_ne_i64_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_i64_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i64 %arg, 424242424242
  %sel = select i1 %cmp, i64 %other, i64 424242424242
  ret i64 %sel
}

; Should be folded: icmp ne + select with constant in false value (commutative)
define i64 @icmp_select_fold_ne_imm_i64(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_fold_ne_imm_i64:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_imm_i64:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i64 424242424242, %arg
  %sel = select i1 %cmp, i64 %other, i64 424242424242
  ret i64 %sel
}

; Should NOT be folded: icmp eq with different constants
define i64 @icmp_select_no_fold_i64_different(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_different:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_mov_b32_e32 v4, 0x719c60f8
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v4, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, 56, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_different:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x719c60f8, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, 56, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 %arg, 424242424242
  %sel = select i1 %cmp, i64 242424242424, i64 %other
  ret i64 %sel
}

; Should NOT be folded: icmp eq with constant in other position
define i64 @icmp_select_no_fold_i64_other_pos(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_other_pos:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_mov_b32_e32 v4, 0xc6d1a9b2
; GFX900-NEXT:    v_mov_b32_e32 v1, 0x62
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v4, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_other_pos:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b2
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_eq_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0xc6d1a9b2, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, 0x62, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 %arg, 424242424242
  %sel = select i1 %cmp, i64 %other, i64 424242424242
  ret i64 %sel
}

; Should NOT be folded: unsupported comparison type
define i64 @icmp_select_no_fold_i64_unsupported_cmp(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_unsupported_cmp:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_mov_b32 s4, 0xc6d1a9b3
; GFX900-NEXT:    s_movk_i32 s5, 0x62
; GFX900-NEXT:    v_cmp_gt_u64_e32 vcc, s[4:5], v[0:1]
; GFX900-NEXT:    v_mov_b32_e32 v4, 0xc6d1a9b2
; GFX900-NEXT:    v_mov_b32_e32 v1, 0x62
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v4, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, v1, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_unsupported_cmp:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    s_mov_b32 s4, 0xc6d1a9b3
; GFX1010-NEXT:    s_movk_i32 s5, 0x62
; GFX1010-NEXT:    v_cmp_gt_u64_e32 vcc_lo, s[4:5], v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0xc6d1a9b2, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, 0x62, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ugt i64 %arg, 424242424242
  %sel = select i1 %cmp, i64 424242424242, i64 %other
  ret i64 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i64 @icmp_select_no_fold_i64_enc_imm(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_enc_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, 0, v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 0, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, 0, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_enc_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, 0, v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, 0, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 %arg, 0
  %sel = select i1 %cmp, i64 0, i64 %other
  ret i64 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i64 @icmp_select_no_fold_i64_enc_imm_2(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_enc_imm_2:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, 32, v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 32, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, 0, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_enc_imm_2:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, 32, v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 32, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, 0, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i64 32, %arg
  %sel = select i1 %cmp, i64 32, i64 %other
  ret i64 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i64 @icmp_select_no_fold_i64_enc_imm_3(i64 %arg, i64 %other) {
; GFX900-LABEL: icmp_select_no_fold_i64_enc_imm_3:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u64_e32 vcc, -8, v[0:1]
; GFX900-NEXT:    v_cndmask_b32_e32 v0, -8, v2, vcc
; GFX900-NEXT:    v_cndmask_b32_e32 v1, -1, v3, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i64_enc_imm_3:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u64_e32 vcc_lo, -8, v[0:1]
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, -8, v2, vcc_lo
; GFX1010-NEXT:    v_cndmask_b32_e32 v1, -1, v3, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i64 %arg, -8
  %sel = select i1 %cmp, i64 %other, i64 -8
  ret i64 %sel
}

;------------------------------------------------------------------------------
; I16 Tests
;------------------------------------------------------------------------------

; Should be folded: icmp eq + select with constant in true value
define i16 @icmp_select_fold_eq_i16_imm(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_fold_eq_i16_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_eq_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_i16_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 %arg, 4242
  %sel = select i1 %cmp, i16 4242, i16 %other
  ret i16 %sel
}

; Should be folded: icmp eq + select with constant in true value (commutative)
define i16 @icmp_select_fold_eq_imm_i16(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_fold_eq_imm_i16:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_eq_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_imm_i16:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 4242, %arg
  %sel = select i1 %cmp, i16 4242, i16 %other
  ret i16 %sel
}

; Should be folded: icmp ne + select with constant in false value
define i16 @icmp_select_fold_ne_i16_imm(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_fold_ne_i16_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_i16_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i16 %arg, 4242
  %sel = select i1 %cmp, i16 %other, i16 4242
  ret i16 %sel
}

; Should be folded: icmp ne + select with constant in false value (commutative)
define i16 @icmp_select_fold_ne_imm_i16(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_fold_ne_imm_i16:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_imm_i16:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i16 4242, %arg
  %sel = select i1 %cmp, i16 %other, i16 4242
  ret i16 %sel
}

; Should NOT be folded: icmp eq with different constants
define i16 @icmp_select_no_fold_i16_different(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_different:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x978
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_different:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x978, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 %arg, 4242
  %sel = select i1 %cmp, i16 2424, i16 %other
  ret i16 %sel
}

; Should NOT be folded: icmp eq with constant in other position
define i16 @icmp_select_no_fold_i16_other_pos(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_other_pos:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1092
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x1092
; GFX900-NEXT:    v_cmp_eq_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_other_pos:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_eq_u16_e32 vcc_lo, 0x1092, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x1092, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 %arg, 4242
  %sel = select i1 %cmp, i16 %other, i16 4242
  ret i16 %sel
}

; Should NOT be folded: unsupported comparison type
define i16 @icmp_select_no_fold_i16_unsupported_cmp(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_unsupported_cmp:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x1093
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x1092
; GFX900-NEXT:    v_cmp_gt_u16_e32 vcc, s4, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_unsupported_cmp:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_gt_u16_e32 vcc_lo, 0x1093, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x1092, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ugt i16 %arg, 4242
  %sel = select i1 %cmp, i16 4242, i16 %other
  ret i16 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i16 @icmp_select_no_fold_i16_enc_imm(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_enc_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, 0, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_enc_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, 0, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 %arg, 0
  %sel = select i1 %cmp, i16 0, i16 %other
  ret i16 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i16 @icmp_select_no_fold_i16_enc_imm_2(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_enc_imm_2:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, 45, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 45, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_enc_imm_2:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, 45, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 45, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i16 45, %arg
  %sel = select i1 %cmp, i16 45, i16 %other
  ret i16 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i16 @icmp_select_no_fold_i16_enc_imm_3(i16 %arg, i16 %other) {
; GFX900-LABEL: icmp_select_no_fold_i16_enc_imm_3:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_cmp_ne_u16_e32 vcc, -12, v0
; GFX900-NEXT:    v_cndmask_b32_e32 v0, -12, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i16_enc_imm_3:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_cmp_ne_u16_e32 vcc_lo, -12, v0
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, -12, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i16 %arg, -12
  %sel = select i1 %cmp, i16 %other, i16 -12
  ret i16 %sel
}

;------------------------------------------------------------------------------
; I8 Tests
;------------------------------------------------------------------------------

; Should be folded: icmp eq + select with constant in true value
define i8 @icmp_select_fold_eq_i8_imm(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_fold_eq_i8_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_cmp_eq_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_i8_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_eq_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 %arg, 123
  %sel = select i1 %cmp, i8 123, i8 %other
  ret i8 %sel
}

; Should be folded: icmp eq + select with constant in true value (commutative)
define i8 @icmp_select_fold_eq_imm_i8(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_fold_eq_imm_i8:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_cmp_eq_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_eq_imm_i8:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_eq_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 123, %arg
  %sel = select i1 %cmp, i8 123, i8 %other
  ret i8 %sel
}

; Should be folded: icmp ne + select with constant in false value
define i8 @icmp_select_fold_ne_i8_imm(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_fold_ne_i8_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_i8_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i8 %arg, 123
  %sel = select i1 %cmp, i8 %other, i8 123
  ret i8 %sel
}

; Should be folded: icmp ne + select with constant in false value (commutative)
define i8 @icmp_select_fold_ne_imm_i8(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_fold_ne_imm_i8:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_fold_ne_imm_i8:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, v0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i8 123, %arg
  %sel = select i1 %cmp, i8 %other, i8 123
  ret i8 %sel
}

; Should NOT be folded: icmp eq with different constants
define i8 @icmp_select_no_fold_i8_different(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_different:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x7c
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_different:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x7c, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 %arg, 123
  %sel = select i1 %cmp, i8 124, i8 %other
  ret i8 %sel
}

; Should NOT be folded: icmp eq with constant in other position
define i8 @icmp_select_no_fold_i8_other_pos(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_other_pos:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7b
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX900-NEXT:    v_cmp_eq_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_other_pos:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX1010-NEXT:    v_cmp_eq_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x7b, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 %arg, 123
  %sel = select i1 %cmp, i8 %other, i8 123
  ret i8 %sel
}

; Should NOT be folded: unsupported comparison type
define i8 @icmp_select_no_fold_i8_unsupported_cmp(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_unsupported_cmp:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0x7c
; GFX900-NEXT:    v_mov_b32_e32 v2, 0x7b
; GFX900-NEXT:    v_cmp_lt_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, v2, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_unsupported_cmp:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0x7c
; GFX1010-NEXT:    v_cmp_lt_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0x7b, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ugt i8 %arg, 123
  %sel = select i1 %cmp, i8 123, i8 %other
  ret i8 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i8 @icmp_select_no_fold_i8_enc_imm(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_enc_imm:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_mov_b32_e32 v2, 0
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_enc_imm:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 0, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 %arg, 0
  %sel = select i1 %cmp, i8 0, i8 %other
  ret i8 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i8 @icmp_select_no_fold_i8_enc_imm_2(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_enc_imm_2:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    v_mov_b32_e32 v2, 25
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, 25, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_enc_imm_2:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 25
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, 25, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp eq i8 25, %arg
  %sel = select i1 %cmp, i8 25, i8 %other
  ret i8 %sel
}

; Should NOT be folded: immediate can be encoded into cndmask
define i8 @icmp_select_no_fold_i8_enc_imm_3(i8 %arg, i8 %other) {
; GFX900-LABEL: icmp_select_no_fold_i8_enc_imm_3:
; GFX900:       ; %bb.0: ; %entry
; GFX900-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX900-NEXT:    s_movk_i32 s4, 0xfb
; GFX900-NEXT:    v_cmp_ne_u16_sdwa vcc, v0, s4 src0_sel:BYTE_0 src1_sel:DWORD
; GFX900-NEXT:    v_cndmask_b32_e32 v0, -5, v1, vcc
; GFX900-NEXT:    s_setpc_b64 s[30:31]
;
; GFX1010-LABEL: icmp_select_no_fold_i8_enc_imm_3:
; GFX1010:       ; %bb.0: ; %entry
; GFX1010-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX1010-NEXT:    v_mov_b32_e32 v2, 0xfb
; GFX1010-NEXT:    v_cmp_ne_u16_sdwa vcc_lo, v0, v2 src0_sel:BYTE_0 src1_sel:DWORD
; GFX1010-NEXT:    v_cndmask_b32_e32 v0, -5, v1, vcc_lo
; GFX1010-NEXT:    s_setpc_b64 s[30:31]
entry:
  %cmp = icmp ne i8 %arg, -5
  %sel = select i1 %cmp, i8 %other, i8 -5
  ret i8 %sel
}

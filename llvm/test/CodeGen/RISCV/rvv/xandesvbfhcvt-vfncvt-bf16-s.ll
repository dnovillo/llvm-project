; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: sed 's/iXLen/i32/g' %s | llc -mtriple=riscv32 -mattr=+v,+xandesvbfhcvt \
; RUN:   -verify-machineinstrs -target-abi=ilp32d | FileCheck %s
; RUN: sed 's/iXLen/i64/g' %s | llc -mtriple=riscv64 -mattr=+v,+xandesvbfhcvt \
; RUN:   -verify-machineinstrs -target-abi=lp64d | FileCheck %s

define <vscale x 1 x bfloat> @intrinsic_vfncvt_bf16.s_nxv1bf16_nxv1f32(<vscale x 1 x float> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfncvt_bf16.s_nxv1bf16_nxv1f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, mf4, ta, ma
; CHECK-NEXT:    nds.vfncvt.bf16.s v9, v8
; CHECK-NEXT:    vmv1r.v v8, v9
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 1 x bfloat> @llvm.riscv.nds.vfncvt.bf16.s.nxv1bf16.nxv1f32(
    <vscale x 1 x bfloat> poison,
    <vscale x 1 x float> %0,
    iXLen 7, iXLen %1)

  ret <vscale x 1 x bfloat> %a
}

define <vscale x 2 x bfloat> @intrinsic_vfncvt_bf16.s_nxv2bf16_nxv2f32(<vscale x 2 x float> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfncvt_bf16.s_nxv2bf16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, mf2, ta, ma
; CHECK-NEXT:    nds.vfncvt.bf16.s v9, v8
; CHECK-NEXT:    vmv1r.v v8, v9
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 2 x bfloat> @llvm.riscv.nds.vfncvt.bf16.s.nxv2bf16.nxv2f32(
    <vscale x 2 x bfloat> poison,
    <vscale x 2 x float> %0,
    iXLen 7, iXLen %1)

  ret <vscale x 2 x bfloat> %a
}

define <vscale x 4 x bfloat> @intrinsic_vfncvt_bf16.s_nxv4bf16_nxv4f32(<vscale x 4 x float> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfncvt_bf16.s_nxv4bf16_nxv4f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m1, ta, ma
; CHECK-NEXT:    nds.vfncvt.bf16.s v10, v8
; CHECK-NEXT:    vmv.v.v v8, v10
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 4 x bfloat> @llvm.riscv.nds.vfncvt.bf16.s.nxv4bf16.nxv4f32(
    <vscale x 4 x bfloat> poison,
    <vscale x 4 x float> %0,
    iXLen 7, iXLen %1)

  ret <vscale x 4 x bfloat> %a
}

define <vscale x 8 x bfloat> @intrinsic_vfncvt_bf16.s_nxv8bf16_nxv8f32(<vscale x 8 x float> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfncvt_bf16.s_nxv8bf16_nxv8f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m2, ta, ma
; CHECK-NEXT:    nds.vfncvt.bf16.s v12, v8
; CHECK-NEXT:    vmv.v.v v8, v12
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 8 x bfloat> @llvm.riscv.nds.vfncvt.bf16.s.nxv8bf16.nxv8f32(
    <vscale x 8 x bfloat> poison,
    <vscale x 8 x float> %0,
    iXLen 7, iXLen %1)

  ret <vscale x 8 x bfloat> %a
}

define <vscale x 16 x bfloat> @intrinsic_vfncvt_bf16.s_nxv16bf16_nxv16f32(<vscale x 16 x float> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfncvt_bf16.s_nxv16bf16_nxv16f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m4, ta, ma
; CHECK-NEXT:    nds.vfncvt.bf16.s v16, v8
; CHECK-NEXT:    vmv.v.v v8, v16
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 16 x bfloat> @llvm.riscv.nds.vfncvt.bf16.s.nxv16bf16.nxv16f32(
    <vscale x 16 x bfloat> poison,
    <vscale x 16 x float> %0,
    iXLen 7, iXLen %1)

  ret <vscale x 16 x bfloat> %a
}

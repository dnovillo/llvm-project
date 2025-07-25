//===- AMDGPUDisassembler.hpp - Disassembler for AMDGPU ISA -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
///
/// This file contains declaration for AMDGPU ISA disassembler
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_AMDGPU_DISASSEMBLER_AMDGPUDISASSEMBLER_H
#define LLVM_LIB_TARGET_AMDGPU_DISASSEMBLER_AMDGPUDISASSEMBLER_H

#include "SIDefines.h"
#include "llvm/ADT/APInt.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/Support/DataExtractor.h"
#include <memory>

namespace llvm {

class MCAsmInfo;
class MCInst;
class MCOperand;
class MCSubtargetInfo;
class Twine;

// Exposes an interface expected by autogenerated code in
// FixedLenDecoderEmitter
class DecoderUInt128 {
private:
  uint64_t Lo = 0;
  uint64_t Hi = 0;

public:
  DecoderUInt128() = default;
  DecoderUInt128(uint64_t Lo, uint64_t Hi = 0) : Lo(Lo), Hi(Hi) {}
  operator bool() const { return Lo || Hi; }
  uint64_t extractBitsAsZExtValue(unsigned NumBits,
                                  unsigned BitPosition) const {
    assert(NumBits && NumBits <= 64);
    assert(BitPosition < 128);
    uint64_t Val;
    if (BitPosition < 64)
      Val = Lo >> BitPosition | Hi << 1 << (63 - BitPosition);
    else
      Val = Hi >> (BitPosition - 64);
    return Val & ((uint64_t(2) << (NumBits - 1)) - 1);
  }
  DecoderUInt128 operator&(const DecoderUInt128 &RHS) const {
    return DecoderUInt128(Lo & RHS.Lo, Hi & RHS.Hi);
  }
  DecoderUInt128 operator&(const uint64_t &RHS) const {
    return *this & DecoderUInt128(RHS);
  }
  DecoderUInt128 operator~() const { return DecoderUInt128(~Lo, ~Hi); }
  bool operator==(const DecoderUInt128 &RHS) {
    return Lo == RHS.Lo && Hi == RHS.Hi;
  }
  bool operator!=(const DecoderUInt128 &RHS) {
    return Lo != RHS.Lo || Hi != RHS.Hi;
  }
  bool operator!=(const int &RHS) { return *this != DecoderUInt128(RHS); }
};

//===----------------------------------------------------------------------===//
// AMDGPUDisassembler
//===----------------------------------------------------------------------===//

class AMDGPUDisassembler : public MCDisassembler {
private:
  std::unique_ptr<MCInstrInfo const> const MCII;
  const MCRegisterInfo &MRI;
  const MCAsmInfo &MAI;
  const unsigned TargetMaxInstBytes;
  mutable ArrayRef<uint8_t> Bytes;
  mutable uint32_t Literal;
  mutable uint64_t Literal64;
  mutable bool HasLiteral;
  mutable std::optional<bool> EnableWavefrontSize32;
  unsigned CodeObjectVersion;
  const MCExpr *UCVersionW64Expr;
  const MCExpr *UCVersionW32Expr;
  const MCExpr *UCVersionMDPExpr;

  const MCExpr *createConstantSymbolExpr(StringRef Id, int64_t Val);

  void decodeImmOperands(MCInst &MI, const MCInstrInfo &MCII) const;

public:
  AMDGPUDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx,
                     MCInstrInfo const *MCII);
  ~AMDGPUDisassembler() override = default;

  void setABIVersion(unsigned Version) override;

  DecodeStatus getInstruction(MCInst &MI, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &CS) const override;

  const char* getRegClassName(unsigned RegClassID) const;

  MCOperand createRegOperand(unsigned int RegId) const;
  MCOperand createRegOperand(unsigned RegClassID, unsigned Val) const;
  MCOperand createSRegOperand(unsigned SRegClassID, unsigned Val) const;
  MCOperand createVGPR16Operand(unsigned RegIdx, bool IsHi) const;

  MCOperand errOperand(unsigned V, const Twine& ErrMsg) const;

  template <typename InsnType>
  DecodeStatus tryDecodeInst(const uint8_t *Table, MCInst &MI, InsnType Inst,
                             uint64_t Address, raw_ostream &Comments) const;
  template <typename InsnType>
  DecodeStatus tryDecodeInst(const uint8_t *Table1, const uint8_t *Table2,
                             MCInst &MI, InsnType Inst, uint64_t Address,
                             raw_ostream &Comments) const;

  Expected<bool> onSymbolStart(SymbolInfoTy &Symbol, uint64_t &Size,
                               ArrayRef<uint8_t> Bytes,
                               uint64_t Address) const override;

  Expected<bool> decodeKernelDescriptor(StringRef KdName,
                                        ArrayRef<uint8_t> Bytes,
                                        uint64_t KdAddress) const;

  Expected<bool>
  decodeKernelDescriptorDirective(DataExtractor::Cursor &Cursor,
                                  ArrayRef<uint8_t> Bytes,
                                  raw_string_ostream &KdStream) const;

  /// Decode as directives that handle COMPUTE_PGM_RSRC1.
  /// \param FourByteBuffer - Bytes holding contents of COMPUTE_PGM_RSRC1.
  /// \param KdStream       - Stream to write the disassembled directives to.
  // NOLINTNEXTLINE(readability-identifier-naming)
  Expected<bool> decodeCOMPUTE_PGM_RSRC1(uint32_t FourByteBuffer,
                                         raw_string_ostream &KdStream) const;

  /// Decode as directives that handle COMPUTE_PGM_RSRC2.
  /// \param FourByteBuffer - Bytes holding contents of COMPUTE_PGM_RSRC2.
  /// \param KdStream       - Stream to write the disassembled directives to.
  // NOLINTNEXTLINE(readability-identifier-naming)
  Expected<bool> decodeCOMPUTE_PGM_RSRC2(uint32_t FourByteBuffer,
                                         raw_string_ostream &KdStream) const;

  /// Decode as directives that handle COMPUTE_PGM_RSRC3.
  /// \param FourByteBuffer - Bytes holding contents of COMPUTE_PGM_RSRC3.
  /// \param KdStream       - Stream to write the disassembled directives to.
  // NOLINTNEXTLINE(readability-identifier-naming)
  Expected<bool> decodeCOMPUTE_PGM_RSRC3(uint32_t FourByteBuffer,
                                         raw_string_ostream &KdStream) const;

  void convertEXPInst(MCInst &MI) const;
  void convertVINTERPInst(MCInst &MI) const;
  void convertFMAanyK(MCInst &MI) const;
  void convertSDWAInst(MCInst &MI) const;
  void convertMAIInst(MCInst &MI) const;
  void convertWMMAInst(MCInst &MI) const;
  void convertDPP8Inst(MCInst &MI) const;
  void convertMIMGInst(MCInst &MI) const;
  void convertVOP3DPPInst(MCInst &MI) const;
  void convertVOP3PDPPInst(MCInst &MI) const;
  void convertVOPCDPPInst(MCInst &MI) const;
  void convertVOPC64DPPInst(MCInst &MI) const;
  void convertMacDPPInst(MCInst &MI) const;
  void convertTrue16OpSel(MCInst &MI) const;

  unsigned getVgprClassId(unsigned Width) const;
  unsigned getAgprClassId(unsigned Width) const;
  unsigned getSgprClassId(unsigned Width) const;
  unsigned getTtmpClassId(unsigned Width) const;

  static MCOperand decodeIntImmed(unsigned Imm);

  MCOperand decodeMandatoryLiteralConstant(unsigned Imm) const;
  MCOperand decodeMandatoryLiteral64Constant(uint64_t Imm) const;
  MCOperand decodeLiteralConstant(bool ExtendFP64) const;
  MCOperand decodeLiteral64Constant() const;

  MCOperand decodeSrcOp(unsigned Width, unsigned Val) const;

  MCOperand decodeNonVGPRSrcOp(unsigned Width, unsigned Val) const;

  MCOperand decodeVOPDDstYOp(MCInst &Inst, unsigned Val) const;
  MCOperand decodeSpecialReg32(unsigned Val) const;
  MCOperand decodeSpecialReg64(unsigned Val) const;
  MCOperand decodeSpecialReg96Plus(unsigned Val) const;

  MCOperand decodeSDWASrc(unsigned Width, unsigned Val) const;
  MCOperand decodeSDWASrc16(unsigned Val) const;
  MCOperand decodeSDWASrc32(unsigned Val) const;
  MCOperand decodeSDWAVopcDst(unsigned Val) const;

  MCOperand decodeBoolReg(unsigned Val) const;
  MCOperand decodeSplitBarrier(unsigned Val) const;
  MCOperand decodeDpp8FI(unsigned Val) const;

  MCOperand decodeVersionImm(unsigned Imm) const;

  int getTTmpIdx(unsigned Val) const;

  const MCInstrInfo *getMCII() const { return MCII.get(); }

  bool isVI() const;
  bool isGFX9() const;
  bool isGFX90A() const;
  bool isGFX9Plus() const;
  bool isGFX10() const;
  bool isGFX10Plus() const;
  bool isGFX11() const;
  bool isGFX11Plus() const;
  bool isGFX12() const;
  bool isGFX12Plus() const;
  bool isGFX1250() const;

  bool hasArchitectedFlatScratch() const;
  bool hasKernargPreload() const;

  bool isMacDPP(MCInst &MI) const;
};

//===----------------------------------------------------------------------===//
// AMDGPUSymbolizer
//===----------------------------------------------------------------------===//

class AMDGPUSymbolizer : public MCSymbolizer {
private:
  void *DisInfo;
  std::vector<uint64_t> ReferencedAddresses;

public:
  AMDGPUSymbolizer(MCContext &Ctx, std::unique_ptr<MCRelocationInfo> &&RelInfo,
                   void *disInfo)
                   : MCSymbolizer(Ctx, std::move(RelInfo)), DisInfo(disInfo) {}

  bool tryAddingSymbolicOperand(MCInst &Inst, raw_ostream &cStream,
                                int64_t Value, uint64_t Address, bool IsBranch,
                                uint64_t Offset, uint64_t OpSize,
                                uint64_t InstSize) override;

  void tryAddingPcLoadReferenceComment(raw_ostream &cStream,
                                       int64_t Value,
                                       uint64_t Address) override;

  ArrayRef<uint64_t> getReferencedAddresses() const override {
    return ReferencedAddresses;
  }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_AMDGPU_DISASSEMBLER_AMDGPUDISASSEMBLER_H

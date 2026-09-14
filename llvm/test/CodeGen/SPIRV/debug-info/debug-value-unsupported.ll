; RUN: llc --verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown --spirv-ext=+SPV_KHR_non_semantic_info %s -o - | FileCheck %s --implicit-check-not=DebugValue --implicit-check-not=DebugOperation
; RUN: %if spirv-tools %{ llc --verify-machineinstrs --spirv-ext=+SPV_KHR_non_semantic_info -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; Constants and unavailable values have no typed SPIR-V result-id mapping in
; DBG_VALUE. An expression with no NonSemantic counterpart has no emitted
; DebugExpression. None can be represented by DebugValue.

; CHECK-DAG: [[EXT:%[0-9]+]] = OpExtInstImport "NonSemantic.Shader.DebugInfo.100"
; CHECK-DAG: [[VOID:%[0-9]+]] = OpTypeVoid
; CHECK-DAG: [[CONSTANT:%[0-9]+]] = OpString "constant"
; CHECK-DAG: [[UNAVAILABLE:%[0-9]+]] = OpString "unavailable"
; CHECK-DAG: [[EXPRESSION:%[0-9]+]] = OpString "unsupported_expression"
; CHECK-DAG: OpExtInst [[VOID]] [[EXT]] DebugLocalVariable [[CONSTANT]]
; CHECK-DAG: OpExtInst [[VOID]] [[EXT]] DebugLocalVariable [[UNAVAILABLE]]
; CHECK-DAG: OpExtInst [[VOID]] [[EXT]] DebugLocalVariable [[EXPRESSION]]
; CHECK: OpExtInst [[VOID]] [[EXT]] DebugExpression{{ *$}}
; CHECK: OpFunction

target triple = "spirv64-unknown-unknown"

define spir_func i32 @f(i32 %x) !dbg !5 {
entry:
    #dbg_value(i32 42, !9, !DIExpression(), !12)
    #dbg_value(i32 poison, !10, !DIExpression(), !12)
    #dbg_value(i32 %x, !11, !DIExpression(DW_OP_LLVM_convert, 32, DW_ATE_signed), !12)
  ret i32 %x, !dbg !12
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "debug-value-unsupported.c", directory: "/src")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !DISubroutineType(types: !6)
!6 = !{!7, !7}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!5 = distinct !DISubprogram(name: "f", linkageName: "f", scope: !1, file: !1, line: 1, type: !4, scopeLine: 1, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0)
!9 = !DILocalVariable(name: "constant", scope: !5, file: !1, line: 2, type: !7)
!10 = !DILocalVariable(name: "unavailable", scope: !5, file: !1, line: 3, type: !7)
!11 = !DILocalVariable(name: "unsupported_expression", scope: !5, file: !1, line: 4, type: !7)
!12 = !DILocation(line: 5, column: 3, scope: !5)

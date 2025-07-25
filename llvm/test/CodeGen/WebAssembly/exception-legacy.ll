; RUN: llc < %s -asm-verbose=false -disable-wasm-fallthrough-return-opt -wasm-disable-explicit-locals -wasm-keep-registers -wasm-enable-eh -wasm-use-legacy-eh -exception-model=wasm -mattr=+exception-handling -verify-machineinstrs | FileCheck --implicit-check-not=ehgcr -allow-deprecated-dag-overlap %s
; RUN: llc < %s -asm-verbose=false -disable-wasm-fallthrough-return-opt -wasm-disable-explicit-locals -wasm-keep-registers -wasm-enable-eh -wasm-use-legacy-eh -exception-model=wasm -mattr=+exception-handling -verify-machineinstrs -O0
; RUN: llc < %s -disable-wasm-fallthrough-return-opt -wasm-keep-registers -wasm-enable-eh -wasm-use-legacy-eh -exception-model=wasm -mattr=+exception-handling

target triple = "wasm32-unknown-unknown"

%struct.Temp = type { i8 }

@_ZTIi = external dso_local constant ptr

; CHECK: .tagtype  __cpp_exception i32

; CHECK-LABEL: throw:
; CHECK:     throw __cpp_exception, $0
; CHECK-NOT: unreachable
define void @throw(ptr %p) {
  call void @llvm.wasm.throw(i32 0, ptr %p)
  ret void
}

; Simple test with a try-catch
;
; void foo();
; void catch() {
;   try {
;     foo();
;   } catch (int) {
;   }
; }

; CHECK-LABEL: catch:
; CHECK:     global.get  ${{.+}}=, __stack_pointer
; CHECK:     try
; CHECK:       call      foo
; CHECK:     catch     $[[EXN:[0-9]+]]=, __cpp_exception
; CHECK:       global.set  __stack_pointer
; CHECK:       i32.store __wasm_lpad_context
; CHECK:       call       $drop=, _Unwind_CallPersonality, $[[EXN]]
; CHECK:       block
; CHECK:         br_if     0
; CHECK:         call      $drop=, __cxa_begin_catch
; CHECK:         call      __cxa_end_catch
; CHECK:         br        1
; CHECK:       end_block
; CHECK:       rethrow   0
; CHECK:     end_try
define void @catch() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr @_ZTIi]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = call i32 @llvm.eh.typeid.for(ptr @_ZTIi)
  %matches = icmp eq i32 %3, %4
  br i1 %matches, label %catch, label %rethrow

catch:                                            ; preds = %catch.start
  %5 = call ptr @__cxa_begin_catch(ptr %2) [ "funclet"(token %1) ]
  call void @__cxa_end_catch() [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

rethrow:                                          ; preds = %catch.start
  call void @llvm.wasm.rethrow() [ "funclet"(token %1) ]
  unreachable

try.cont:                                         ; preds = %catch, %entry
  ret void
}

; Destructor (cleanup) test
;
; void foo();
; struct Temp {
;   ~Temp() {}
; };
; void cleanup() {
;   Temp t;
;   foo();
; }

; CHECK-LABEL: cleanup:
; CHECK: try
; CHECK:   call      foo
; CHECK: catch_all
; CHECK:   global.set  __stack_pointer
; CHECK:   call      $drop=, _ZN4TempD2Ev
; CHECK:   rethrow   0
; CHECK: end_try
define void @cleanup() personality ptr @__gxx_wasm_personality_v0 {
entry:
  %t = alloca %struct.Temp, align 1
  invoke void @foo()
          to label %invoke.cont unwind label %ehcleanup

invoke.cont:                                      ; preds = %entry
  %call = call ptr @_ZN4TempD2Ev(ptr %t)
  ret void

ehcleanup:                                        ; preds = %entry
  %0 = cleanuppad within none []
  %call1 = call ptr @_ZN4TempD2Ev(ptr %t) [ "funclet"(token %0) ]
  cleanupret from %0 unwind to caller
}

; Calling a function that may throw within a 'catch (...)' generates a
; terminatepad, because __cxa_end_catch() also can throw within 'catch (...)'.
;
; void foo();
; void terminatepad() {
;   try {
;     foo();
;   } catch (...) {
;     foo();
;   }
; }

; CHECK-LABEL: terminatepad
; CHECK: try
; CHECK:   call      foo
; CHECK: catch
; CHECK:   call      $drop=, __cxa_begin_catch
; CHECK:   try
; CHECK:     call      foo
; CHECK:   catch_all
; CHECK:     try
; CHECK:       call      __cxa_end_catch
; CHECK:     catch_all
; CHECK:       call      _ZSt9terminatev
; CHECK:       unreachable
; CHECK:     end_try
; CHECK:     rethrow
; CHECK:   end_try
; CHECK:   call      __cxa_end_catch
; CHECK: end_try
define void @terminatepad() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr null]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = call ptr @__cxa_begin_catch(ptr %2) [ "funclet"(token %1) ]
  invoke void @foo() [ "funclet"(token %1) ]
          to label %invoke.cont1 unwind label %ehcleanup

invoke.cont1:                                     ; preds = %catch.start
  call void @__cxa_end_catch() [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

try.cont:                                         ; preds = %invoke.cont1, %entry
  ret void

ehcleanup:                                        ; preds = %catch.start
  %5 = cleanuppad within %1 []
  invoke void @__cxa_end_catch() [ "funclet"(token %5) ]
          to label %invoke.cont2 unwind label %terminate

invoke.cont2:                                     ; preds = %ehcleanup
  cleanupret from %5 unwind to caller

terminate:                                        ; preds = %ehcleanup
  %6 = cleanuppad within %5 []
  call void @_ZSt9terminatev() #2 [ "funclet"(token %6) ]
  unreachable
}

; Tests prologues and epilogues are not generated within EH scopes.
; They should not be treated as funclets; BBs starting with a catch instruction
; should not have a prologue, and BBs ending with a catchret/cleanupret should
; not have an epilogue. This is separate from __stack_pointer restoring
; instructions after a catch instruction.
;
; void bar(int) noexcept;
; void no_prolog_epilog_in_ehpad() {
;   int stack_var = 0;
;   bar(stack_var);
;   try {
;     foo();
;   } catch (int) {
;     foo();
;   }
; }

; CHECK-LABEL: no_prolog_epilog_in_ehpad
; CHECK:     try
; CHECK:       call      foo
; CHECK:     catch
; CHECK-NOT:   global.get  $push{{.+}}=, __stack_pointer
; CHECK:       global.set  __stack_pointer
; CHECK:       block
; CHECK:         block
; CHECK:           br_if     0
; CHECK:           call      $drop=, __cxa_begin_catch
; CHECK:           try
; CHECK:             call      foo
; CHECK:           catch
; CHECK-NOT:         global.get  $push{{.+}}=, __stack_pointer
; CHECK:             global.set  __stack_pointer
; CHECK:             call      __cxa_end_catch
; CHECK:             rethrow
; CHECK-NOT:         global.set  __stack_pointer, $pop{{.+}}
; CHECK:           end_try
; CHECK:         end_block
; CHECK:         rethrow
; CHECK:       end_block
; CHECK-NOT:   global.set  __stack_pointer, $pop{{.+}}
; CHECK:       call      __cxa_end_catch
; CHECK:     end_try
define void @no_prolog_epilog_in_ehpad() personality ptr @__gxx_wasm_personality_v0 {
entry:
  %stack_var = alloca i32, align 4
  call void @bar(ptr %stack_var)
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr @_ZTIi]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = call i32 @llvm.eh.typeid.for(ptr @_ZTIi)
  %matches = icmp eq i32 %3, %4
  br i1 %matches, label %catch, label %rethrow

catch:                                            ; preds = %catch.start
  %5 = call ptr @__cxa_begin_catch(ptr %2) [ "funclet"(token %1) ]
  %6 = load float, ptr %5, align 4
  invoke void @foo() [ "funclet"(token %1) ]
          to label %invoke.cont1 unwind label %ehcleanup

invoke.cont1:                                     ; preds = %catch
  call void @__cxa_end_catch() [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

rethrow:                                          ; preds = %catch.start
  call void @llvm.wasm.rethrow() [ "funclet"(token %1) ]
  unreachable

try.cont:                                         ; preds = %invoke.cont1, %entry
  ret void

ehcleanup:                                        ; preds = %catch
  %7 = cleanuppad within %1 []
  call void @__cxa_end_catch() [ "funclet"(token %7) ]
  cleanupret from %7 unwind to caller
}

; When a function does not have stack-allocated objects, it does not need to
; store SP back to __stack_pointer global at the epilog.
;
; void foo();
; void no_sp_writeback() {
;   try {
;     foo();
;   } catch (...) {
;   }
; }

; CHECK-LABEL: no_sp_writeback
; CHECK:     try
; CHECK:       call      foo
; CHECK:     catch
; CHECK:       call      $drop=, __cxa_begin_catch
; CHECK:       call      __cxa_end_catch
; CHECK:     end_try
; CHECK-NOT: global.set  __stack_pointer
; CHECK:     return
define void @no_sp_writeback() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr null]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = call ptr @__cxa_begin_catch(ptr %2) [ "funclet"(token %1) ]
  call void @__cxa_end_catch() [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

try.cont:                                         ; preds = %catch.start, %entry
  ret void
}

; When the result of @llvm.wasm.get.exception is not used. This is created to
; fix a bug in LateEHPrepare and this should not crash.
define void @get_exception_wo_use() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr null]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  catchret from %1 to label %try.cont

try.cont:                                         ; preds = %catch.start, %entry
  ret void
}

; Tests a case when a cleanup region (cleanuppad ~ clanupret) contains another
; catchpad
define void @complex_cleanup_region() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %invoke.cont unwind label %ehcleanup

invoke.cont:                                      ; preds = %entry
  ret void

ehcleanup:                                        ; preds = %entry
  %0 = cleanuppad within none []
  invoke void @foo() [ "funclet"(token %0) ]
          to label %ehcleanupret unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %ehcleanup
  %1 = catchswitch within %0 [label %catch.start] unwind label %ehcleanup.1

catch.start:                                      ; preds = %catch.dispatch
  %2 = catchpad within %1 [ptr null]
  %3 = call ptr @llvm.wasm.get.exception(token %2)
  %4 = call i32 @llvm.wasm.get.ehselector(token %2)
  catchret from %2 to label %ehcleanupret

ehcleanup.1:                                      ; preds = %catch.dispatch
  %5 = cleanuppad within %0 []
  unreachable

ehcleanupret:                                     ; preds = %catch.start, %ehcleanup
  cleanupret from %0 unwind to caller
}

; Regression test for the bug that 'rethrow' was not treated correctly as a
; terminator in isel.
define void @rethrow_terminator() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind label %ehcleanup

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr @_ZTIi]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = call i32 @llvm.eh.typeid.for.p0(ptr @_ZTIi)
  %matches = icmp eq i32 %3, %4
  br i1 %matches, label %catch, label %rethrow

catch:                                            ; preds = %catch.start
  %5 = call ptr @__cxa_begin_catch(ptr %2) [ "funclet"(token %1) ]
  %6 = load i32, ptr %5, align 4
  call void @__cxa_end_catch() [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

rethrow:                                          ; preds = %catch.start
  invoke void @llvm.wasm.rethrow() #1 [ "funclet"(token %1) ]
          to label %unreachable unwind label %ehcleanup

try.cont:                                         ; preds = %entry, %catch
  ret void

ehcleanup:                                        ; preds = %rethrow, %catch.dispatch
  ; 'rethrow' BB is this BB's predecessor, and its
  ; 'invoke void @llvm.wasm.rethrow()' is lowered down to a 'RETHROW' in Wasm
  ; MIR. And this 'phi' creates 'CONST_I32' instruction in the predecessor
  ; 'rethrow' BB. If 'RETHROW' is not treated correctly as a terminator, it can
  ; create a BB like
  ; bb.3.rethrow:
  ;   RETHROW 0
  ;   %0 = CONST_I32 20
  ;   BR ...
  %tmp = phi i32 [ 10, %catch.dispatch ], [ 20, %rethrow ]
  %7 = cleanuppad within none []
  call void @take_i32(i32 %tmp) [ "funclet"(token %7) ]
  cleanupret from %7 unwind to caller

unreachable:                                      ; preds = %rethrow
  unreachable
}

; The bitcode below is generated when the code below is compiled and
; Temp::~Temp() is inlined into inlined_cleanupret():
;
; void inlined_cleanupret() {
; try {
;   Temp t;
;   throw 2;
; } catch (...)
; }
;
; Temp::~Temp() {
;   try {
;     throw 1;
;   } catch (...) {
;   }
; }
;
; ~Temp() generates cleanupret, which is lowered to a 'rethrow' later. That
; rethrow's immediate argument should correctly target the top-level cleanuppad
; (catch_all). This is a regression test for the bug where we did not compute
; rethrow's argument correctly.

; CHECK-LABEL: inlined_cleanupret:
; CHECK: try
; CHECK:   call  __cxa_throw
; CHECK: catch_all
; CHECK:   try
; CHECK:     try
; CHECK:       call  __cxa_throw
; CHECK:       catch
; CHECK:       call  __cxa_end_catch
; CHECK:       try
; CHECK:         try
; Note that this rethrow targets the top-level catch_all
; CHECK:           rethrow   4
; CHECK:         catch
; CHECK:           try
; CHECK:             call  __cxa_end_catch
; CHECK:           delegate    5
; CHECK:           return
; CHECK:         end_try
; CHECK:       delegate    3
; CHECK:     end_try
; CHECK:   catch_all
; CHECK:     call  _ZSt9terminatev
; CHECK:   end_try
; CHECK: end_try
define void @inlined_cleanupret() personality ptr @__gxx_wasm_personality_v0 {
entry:
  %exception = tail call ptr @__cxa_allocate_exception(i32 4)
  store i32 2, ptr %exception, align 16
  invoke void @__cxa_throw(ptr nonnull %exception, ptr nonnull @_ZTIi, ptr null)
          to label %unreachable unwind label %ehcleanup

ehcleanup:                                        ; preds = %entry
  %0 = cleanuppad within none []
  %exception.i = call ptr @__cxa_allocate_exception(i32 4) [ "funclet"(token %0) ]
  store i32 1, ptr %exception.i, align 16
  invoke void @__cxa_throw(ptr nonnull %exception.i, ptr nonnull @_ZTIi, ptr null) [ "funclet"(token %0) ]
          to label %unreachable unwind label %catch.dispatch.i

catch.dispatch.i:                                 ; preds = %ehcleanup
  %1 = catchswitch within %0 [label %catch.start.i] unwind label %terminate.i

catch.start.i:                                    ; preds = %catch.dispatch.i
  %2 = catchpad within %1 [ptr null]
  %3 = tail call ptr @llvm.wasm.get.exception(token %2)
  %4 = tail call i32 @llvm.wasm.get.ehselector(token %2)
  %5 = call ptr @__cxa_begin_catch(ptr %3) [ "funclet"(token %2) ]
  invoke void @__cxa_end_catch() [ "funclet"(token %2) ]
          to label %invoke.cont.i unwind label %terminate.i

invoke.cont.i:                                    ; preds = %catch.start.i
  catchret from %2 to label %_ZN4TempD2Ev.exit

terminate.i:                                      ; preds = %catch.start.i, %catch.dispatch.i
  %6 = cleanuppad within %0 []
  call void @_ZSt9terminatev() #2 [ "funclet"(token %6) ]
  unreachable

_ZN4TempD2Ev.exit:                                ; preds = %invoke.cont.i
  cleanupret from %0 unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %_ZN4TempD2Ev.exit
  %7 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %8 = catchpad within %7 [ptr null]
  %9 = tail call ptr @llvm.wasm.get.exception(token %8)
  %10 = tail call i32 @llvm.wasm.get.ehselector(token %8)
  %11 = call ptr @__cxa_begin_catch(ptr %9) #8 [ "funclet"(token %8) ]
  call void @__cxa_end_catch() [ "funclet"(token %8) ]
  catchret from %8 to label %try.cont

try.cont:                                         ; preds = %catch.start
  ret void

unreachable:                                      ; preds = %entry
  unreachable
}

; Regression test for a bug where, when an invoke unwinds to a catchswitch, the
; catchswitch's unwind destination was not included in the invoke's unwind
; destination when there was no direct link from catch.start to there.

; CHECK-LABEL: unwind_destinations:
; CHECK: try
; CHECK:   try
; CHECK:     call  foo
; CHECK:   catch  $0=, __cpp_exception
; CHECK:     call  _ZSt9terminatev
; CHECK:     unreachable
; CHECK:   end_try
; Note the below is "terminate" BB and should not be DCE'd
; CHECK: catch_all
; CHECK:   call  _ZSt9terminatev
; CHECK:   unreachable
; CHECK: end_try
; CHECK: return
define void @unwind_destinations() personality ptr @__gxx_wasm_personality_v0 {
entry:
  invoke void @foo()
          to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind label %terminate

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr null]
  %2 = call ptr @llvm.wasm.get.exception(token %1)
  %3 = call ptr @__cxa_begin_catch(ptr %2) #5 [ "funclet"(token %1) ]
  call void @_ZSt9terminatev() #2 [ "funclet"(token %1) ]
  unreachable

; Even if there is no link from catch.start to this terminate BB, when there is
; an exception that catch.start does not catch (e.g. a foreign exception), it
; should end up here, so this BB should NOT be DCE'ed
terminate:                                        ; preds = %catch.dispatch
  %4 = cleanuppad within none []
  call void @_ZSt9terminatev() #2 [ "funclet"(token %4) ]
  unreachable

try.cont:                                         ; preds = %entry
  ret void
}

declare void @foo()
declare void @bar(ptr)
declare void @take_i32(i32)
declare i32 @__gxx_wasm_personality_v0(...)
; Function Attrs: noreturn
declare void @llvm.wasm.throw(i32, ptr) #1
; Function Attrs: nounwind
declare ptr @llvm.wasm.get.exception(token) #0
; Function Attrs: nounwind
declare i32 @llvm.wasm.get.ehselector(token) #0
; Function Attrs: noreturn
declare void @llvm.wasm.rethrow() #1
; Function Attrs: nounwind
declare i32 @llvm.eh.typeid.for(ptr) #0
; Function Attrs: nounwind
declare ptr @__cxa_allocate_exception(i32) #0
declare ptr @__cxa_begin_catch(ptr)
declare void @__cxa_end_catch()
; Function Attrs: noreturn
declare void @__cxa_throw(ptr, ptr, ptr) #1
declare void @_ZSt9terminatev()
declare ptr @_ZN4TempD2Ev(ptr returned)

attributes #0 = { nounwind }
attributes #1 = { noreturn }
attributes #2 = { noreturn nounwind }

; CHECK: __cpp_exception:

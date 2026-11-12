; RUN: llc -mtriple=x86_64-pc-windows-msvc < %s -filetype=obj | llvm-readobj --codeview - | FileCheck %s

; Two distinct subprograms with the same name, scope and type (as a declaration
; and its definition in different units can be) share one function id type
; index. Only @g1's body switches to inc.h, but readers may resolve either
; inlinee lines record, so both records must list the extra file.

; CHECK:      SubSectionType: InlineeLines (0xF6)
; CHECK:      InlineeSourceLine {
; CHECK-NEXT:   Inlinee: g (0x[[ID:[0-9A-F]+]])
; CHECK-NEXT:   FileID: {{.*}}t.cpp
; CHECK-NEXT:   SourceLineNum: 2
; CHECK-NEXT:   ExtraFileCount: 1
; CHECK-NEXT:   ExtraFiles [
; CHECK-NEXT:     FileID: {{.*}}inc.h
; CHECK-NEXT:   ]
; CHECK-NEXT: }
; CHECK-NEXT: InlineeSourceLine {
; CHECK-NEXT:   Inlinee: g (0x[[ID]])
; CHECK-NEXT:   FileID: {{.*}}t.cpp
; CHECK-NEXT:   SourceLineNum: 20
; CHECK-NEXT:   ExtraFileCount: 1
; CHECK-NEXT:   ExtraFiles [
; CHECK-NEXT:     FileID: {{.*}}inc.h
; CHECK-NEXT:   ]
; CHECK-NEXT: }

target datalayout = "e-m:w-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc"

@x = global i32 0, align 4

define void @f() !dbg !10 {
entry:
  store volatile i32 1, ptr @x, align 4, !dbg !20
  store volatile i32 2, ptr @x, align 4, !dbg !23
  store volatile i32 3, ptr @x, align 4, !dbg !24
  store volatile i32 4, ptr @x, align 4, !dbg !26
  ret void, !dbg !27
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!5, !6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "t.cpp", directory: "D:\5Csrc")
!2 = !DIFile(filename: "inc.h", directory: "D:\5Csrc")
!5 = !{i32 2, !"CodeView", i32 1}
!6 = !{i32 2, !"Debug Info Version", i32 3}
!7 = !DISubroutineType(types: !{null})
!10 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 10, type: !7, scopeLine: 10, spFlags: DISPFlagDefinition, unit: !0)
!11 = distinct !DISubprogram(name: "g", scope: !1, file: !1, line: 2, type: !7, scopeLine: 2, spFlags: DISPFlagDefinition | DISPFlagLocalToUnit, unit: !0)
!12 = distinct !DISubprogram(name: "g", scope: !1, file: !1, line: 20, type: !7, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagLocalToUnit, unit: !0)
!13 = !DILexicalBlockFile(scope: !11, file: !2, discriminator: 0)
!14 = distinct !DILocation(line: 11, scope: !10)
!15 = distinct !DILocation(line: 12, scope: !10)
!20 = !DILocation(line: 3, scope: !11, inlinedAt: !14)
!23 = !DILocation(line: 1, scope: !13, inlinedAt: !14)
!24 = !DILocation(line: 21, scope: !12, inlinedAt: !15)
!26 = !DILocation(line: 4, scope: !11, inlinedAt: !14)
!27 = !DILocation(line: 13, scope: !10)

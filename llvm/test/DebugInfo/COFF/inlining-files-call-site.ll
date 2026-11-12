; RUN: llc -mtriple=x86_64-pc-windows-msvc < %s -filetype=obj | llvm-readobj --codeview - | FileCheck %s

; f inlines outer, and outer's call to inner comes from an #include'd file
; (t.inc). Every instruction belongs to inner or f, so no instruction carries a
; location in outer with file t.inc. The only evidence that outer's line table
; switches to t.inc is inner's call site, which must be listed as an extra file
; of outer.

; CHECK:      SubSectionType: InlineeLines (0xF6)
; CHECK:      InlineeSourceLine {
; CHECK-NEXT:   Inlinee: outer (0x{{.*}})
; CHECK-NEXT:   FileID: {{.*}}t.cpp (0x0)
; CHECK-NEXT:   SourceLineNum: 2
; CHECK-NEXT:   ExtraFileCount: 1
; CHECK-NEXT:   ExtraFiles [
; CHECK-NEXT:     FileID: {{.*}}t.inc (0x{{.*}})
; CHECK-NEXT:   ]
; CHECK-NEXT: }
; CHECK:      InlineeSourceLine {
; CHECK-NEXT:   Inlinee: inner (0x{{.*}})
; CHECK-NEXT:   FileID: {{.*}}t.cpp (0x0)
; CHECK-NEXT:   SourceLineNum: 5
; CHECK-NEXT:   ExtraFileCount: 0

@x = global i32 0, align 4

define void @f() !dbg !12 {
entry:
  %0 = load volatile i32, ptr @x, align 4, !dbg !20
  %inc = add nsw i32 %0, 1, !dbg !20
  store volatile i32 %inc, ptr @x, align 4, !dbg !20
  %1 = load volatile i32, ptr @x, align 4, !dbg !23
  %inc.i = add nsw i32 %1, 1, !dbg !23
  store volatile i32 %inc.i, ptr @x, align 4, !dbg !23
  ret void, !dbg !24
}

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!8, !9}

!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!3 = !DIFile(filename: "t.cpp", directory: "D:\5Csrc\5Cllvm\5Cbuild")
!8 = !{i32 2, !"CodeView", i32 1}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!12 = distinct !DISubprogram(name: "f", scope: !3, file: !3, line: 8, type: !13, isLocal: false, isDefinition: true, scopeLine: 8, flags: DIFlagPrototyped, isOptimized: true, unit: !2)
!13 = !DISubroutineType(types: !14)
!14 = !{null}
!15 = distinct !DISubprogram(name: "outer", scope: !3, file: !3, line: 2, type: !13, isLocal: true, isDefinition: true, scopeLine: 2, flags: DIFlagPrototyped, isOptimized: true, unit: !2)
!16 = distinct !DISubprogram(name: "inner", scope: !3, file: !3, line: 5, type: !13, isLocal: true, isDefinition: true, scopeLine: 5, flags: DIFlagPrototyped, isOptimized: true, unit: !2)
!17 = !DIFile(filename: "./t.inc", directory: "D:\5Csrc\5Cllvm\5Cbuild")
!18 = !DILexicalBlockFile(scope: !15, file: !17, discriminator: 0)
!19 = distinct !DILocation(line: 9, column: 3, scope: !12)
!20 = !DILocation(line: 8, column: 3, scope: !12)
!21 = distinct !DILocation(line: 1, column: 1, scope: !18, inlinedAt: !19)
!23 = !DILocation(line: 6, column: 3, scope: !16, inlinedAt: !21)
!24 = !DILocation(line: 11, column: 1, scope: !12)

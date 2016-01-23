.class public good11
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good11/main()I
  pop
  return
.end method
ldc 0
istore 0
ldc 0
istore 1
label0:
bipush 1
iload 2
invokestatic runtime/readInt()Idup
istore 2
ldc 0
if_acmpne label2pop
bipush 0
label2:
ifeq label1
iload 0
iload 0
iload 2
iadd
dup
istore 0
pop
iload 1
dup
ldc 1
iadd
istore 1
pop
goto label0
label1:
iload 0
iload 1
idiv
invokestatic runtime/printInt(I)V
bipush 0
pop

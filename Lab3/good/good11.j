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

.method public static main()I
  .limit locals 1000
  .limit stack 1000
ldc 0
istore_0
ldc 0
istore_1
ldc 0
istore_2
label0:
bipush 1
iload_2
invokestatic Runtime/readInt()I
dup
istore_2
ldc 0
if_acmpne label2
pop
bipush 0
label2:
ifeq label1
iload_0
iload_0
iload_2
iadd
dup
istore_0
pop
iload_1
dup
ldc 1
iadd
istore_1
pop
goto label0
label1:
iload_0
iload_1
idiv
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 0
ireturn
.end method

.class public good03
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good03/main()I
  pop
  return
.end method
.method public static main()I
  .limit locals 1000
  .limit stack 1000
invokestatic Runtime/readInt()I
istore_0
ldc 1
istore_1
ldc 1
istore_2
label0:
bipush 1
iload_2
iload_0
ldc 1
iadd
if_icmplt label2
pop
bipush 0
label2:
ifeq label1
iload_1
iload_2
iload_1
imul
dup
istore_1
pop
iload_2
ldc 1
iadd
dup
istore_2
pop
goto label0
label1:
iload_1
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 0
ireturn
.end method

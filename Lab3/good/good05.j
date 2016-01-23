.class public good05
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good05/main()I
  pop
  return
.end method
.method public static main()I
  .limit locals 1000
  .limit stack 1000
iload_0
ldc 1
dup
istore_0
pop
iload_1
iload_0
dup
istore_1
pop
iload_2
invokestatic Runtime/readInt()I
dup
istore_2
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
label0:
bipush 1
iload_1
iload_2
if_icmplt label2
pop
bipush 0
label2:
ifeq label1
iload_1
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_1
iload_0
iload_1
iadd
dup
istore_1
pop
iload_0
iload_1
iload_0
isub
dup
istore_0
pop
goto label0
label1:
bipush 0
ireturn
.end method

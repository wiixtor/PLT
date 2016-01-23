.class public good07
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good07/main()I
  pop
  return
.end method
.method public static main()I
  .limit locals 1000
  .limit stack 1000
invokestatic Runtime/readInt()I
istore_0
iload_0
ldc 2
idiv
istore_1
label0:
bipush 1
iload_1
ldc 1
if_icmpgt label2
pop
bipush 0
label2:
ifeq label1
bipush 1
iload_1
iload_0
iload_1
idiv
imul
iload_0
if_acmpeq label5
pop
bipush 0
label5:
ifeq label3
iload_1
invokestatic Runtime/printInt(I)V
bipush 0
pop
goto label4
label3:
label4:
iload_1
dup
ldc 1
isub
istore_1
pop
goto label0
label1:
bipush 0
ireturn
.end method

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
invokestatic runtime/readInt()Iistore 0
iload 0
ldc 2
idiv
istore 1
label0:
bipush 1
iload 1
ldc 1
if_icmpgt label2pop
bipush 0
label2:
ifeq label1
bipush 1
iload 1
iload 0
iload 1
idiv
imul
iload 0
if_acmpeq label5pop
bipush 0
label5:
ifeq label3
iload 1
invokestatic runtime/printInt(I)V
bipush 0
pop
goto label4
label3:
label4:
iload 1
dup
ldc 1
isub
istore 1
pop
goto label0
label1:

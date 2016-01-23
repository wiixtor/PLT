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
iload 0
ldc 1
dup
istore 0
pop
iload 1
iload 0
dup
istore 1
pop
iload 2
invokestatic runtime/readInt()Idup
istore 2
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
label0:
bipush 1
iload 1
iload 2
if_icmplt label2pop
bipush 0
label2:
ifeq label1
iload 1
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 1
iload 0
iload 1
iadd
dup
istore 1
pop
iload 0
iload 1
iload 0
isub
dup
istore 0
pop
goto label0
label1:

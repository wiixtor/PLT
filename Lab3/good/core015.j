.class public core015
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic core015/main()I
  pop
  return
.end method

.method public static main()I
  .limit locals 1000
  .limit stack 1000
ldc 17
invokestatic core015/ev(I)I
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 0
ireturn
bipush 0
ireturn
.end method

.method public static ev(I)I
  .limit locals 1000
  .limit stack 1000
bipush 1
iload_0
ldc 0
if_icmpgt label2
pop
bipush 0
label2:
ifeq label0
iload_1
iload_0
ldc 2
isub
invokestatic core015/ev(I)I
dup
istore_1
pop
goto label1
label0:
bipush 1
iload_0
ldc 0
if_icmplt label5
pop
bipush 0
label5:
ifeq label3
iload_1
ldc 0
dup
istore_1
pop
goto label4
label3:
iload_1
ldc 1
dup
istore_1
pop
label4:
label1:
iload_1
ireturn
bipush 0
ireturn
.end method

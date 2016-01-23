.class public good15
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good15/main()I
  pop
  return
.end method

.method public static main()I
  .limit locals 1000
  .limit stack 1000
ldc 1
istore_0
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 1
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 45
if_acmpne label0
pop
bipush 0
label0:
ior
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 0
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmpge label1
pop
bipush 0
label1:
ior
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 1
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmplt label2
pop
bipush 0
label2:
iand
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 0
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmpgt label3
pop
bipush 0
label3:
iand
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 0
istore_1
bipush 1
ldc 34
ldc 6
if_icmplt label6
pop
bipush 0
label6:
bipush 1
iload_1
ldc 0
if_icmplt label7
pop
bipush 0
label7:
iand
ifeq label4
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
goto label5
label4:
ldc 42
invokestatic Runtime/printInt(I)V
bipush 0
pop
label5:
bipush 0
ireturn
.end method

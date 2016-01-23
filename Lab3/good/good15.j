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
bipush 0
ldc 1
ior
ifne label0
bipush 0
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 45
if_acmpne label2
pop
bipush 0
label2:
ior
ifne label0
bipush  0
goto label1
label0:
bipush 1
label1:
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 0
ldc 0
ior
ifne label3
bipush 0
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmpge label5
pop
bipush 0
label5:
ior
ifne label3
bipush  0
goto label4
label3:
bipush 1
label4:
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 1
iand
ifeq label6
bipush 1
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmplt label8
pop
bipush 0
label8:
iand
ifeq label7
bipush  1
goto label7
label6:
bipush 0
label7:
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 0
iand
ifeq label9
bipush 1
bipush 1
iload_0
dup
ldc 1
iadd
istore_0
ldc 0
if_icmpgt label11
pop
bipush 0
label11:
iand
ifeq label10
bipush  1
goto label10
label9:
bipush 0
label10:
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
ldc 0
istore_1
bipush 1
bipush 1
ldc 34
ldc 6
if_icmplt label16
pop
bipush 0
label16:
iand
ifeq label14
bipush 1
bipush 1
iload_1
ldc 0
if_icmplt label17
pop
bipush 0
label17:
iand
ifeq label15
bipush  1
goto label15
label14:
bipush 0
label15:
ifeq label12
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
goto label13
label12:
ldc 42
invokestatic Runtime/printInt(I)V
bipush 0
pop
label13:
bipush 0
ireturn
.end method

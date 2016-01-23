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
ldc 1
istore 0
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 1
ior label0bipush 1
bipush 1
iload 0
dup
ldc 1
iadd
istore 0
ldc 45
if_acmpne label2pop
bipush 0
label2:
ior label1bipush 0
goto label1
label0:
bipush 1
label1:
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 0
ior label3bipush 1
bipush 1
iload 0
dup
ldc 1
iadd
istore 0
ldc 0
if_icmpge label5pop
bipush 0
label5:
ior label4bipush 0
goto label4
label3:
bipush 1
label4:
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 1
iand label6bipush 1
bipush 1
iload 0
dup
ldc 1
iadd
istore 0
ldc 0
if_icmplt label8pop
bipush 0
label8:
iand label7bipush 1
goto label7
label6:
bipush 0
label7:
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
bipush 1
ldc 0
iand label9bipush 1
bipush 1
iload 0
dup
ldc 1
iadd
istore 0
ldc 0
if_icmpgt label11pop
bipush 0
label11:
iand label10bipush 1
goto label10
label9:
bipush 0
label10:
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
ldc 0
istore 1
bipush 1
bipush 1
ldc 34
ldc 6
if_icmplt label16pop
bipush 0
label16:
iand label14bipush 1
bipush 1
iload 1
ldc 0
if_icmplt label17pop
bipush 0
label17:
iand label15bipush 1
goto label15
label14:
bipush 0
label15:
ifeq label12
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
goto label13
label12:
ldc 42
invokestatic runtime/printInt(I)V
bipush 0
pop
label13:

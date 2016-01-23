.class public good13
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good13/main()I
  pop
  return
.end method
iload 0
invokestatic runtime/readInt()Idup
istore 0
pop
iload 1
ldc 2
dup
istore 1
pop
label0:
bipush 1
iload 1
iload 0
if_icmple label2pop
bipush 0
label2:
ifeq label1
ldc 1
istore 2
ldc 2
istore 3
label3:
bipush 1
bipush 1
iload 3
iload 3
imul
iload 1
if_icmple label7pop
bipush 0
label7:
iand label5bipush 1
iload 2
iand label6bipush 1
goto label6
label5:
bipush 0
label6:
ifeq label4
bipush 1
iload 1
iload 3
idiv
iload 3
imul
iload 1
if_acmpeq label10pop
bipush 0
label10:
ifeq label8
iload 2
ldc 0
dup
istore 2
pop
goto label9
label8:
label9:
iload 3
dup
ldc 1
iadd
istore 3
pop
goto label3
label4:
bipush 1
iload 2
iand label13bipush 1
bipush 1
iload 0
iload 1
idiv
iload 1
imul
iload 0
if_acmpeq label15pop
bipush 0
label15:
iand label14bipush 1
goto label14
label13:
bipush 0
label14:
ifeq label11
iload 1
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
iload 0
iload 1
idiv
dup
istore 0
pop
goto label12
label11:
iload 1
dup
ldc 1
iadd
istore 1
pop
label12:
goto label0
label1:
ldc 0
return

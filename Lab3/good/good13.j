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

.method public static main()I
  .limit locals 1000
  .limit stack 1000
iload_0
invokestatic Runtime/readInt()I
dup
istore_0
pop
iload_1
ldc 2
dup
istore_1
pop
label0:
bipush 1
iload_1
iload_0
if_icmple label2
pop
bipush 0
label2:
ifeq label1
ldc 1
istore_2
ldc 2
istore_3
label3:
bipush 1
iload_3
iload_3
imul
iload_1
if_icmple label5
pop
bipush 0
label5:
iload_2
iand
ifeq label4
bipush 1
iload_1
iload_3
idiv
iload_3
imul
iload_1
if_acmpeq label8
pop
bipush 0
label8:
ifeq label6
iload_2
ldc 0
dup
istore_2
pop
goto label7
label6:
label7:
iload_3
dup
ldc 1
iadd
istore_3
pop
goto label3
label4:
iload_2
bipush 1
iload_0
iload_1
idiv
iload_1
imul
iload_0
if_acmpeq label11
pop
bipush 0
label11:
iand
ifeq label9
iload_1
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_0
iload_0
iload_1
idiv
dup
istore_0
pop
goto label10
label9:
iload_1
dup
ldc 1
iadd
istore_1
pop
label10:
goto label0
label1:
ldc 0
ireturn
bipush 0
ireturn
.end method

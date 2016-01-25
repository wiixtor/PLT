.class public core013
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic core013/main()I
  pop
  return
.end method

.method public static main()I
  .limit locals 1000
  .limit stack 1000
bipush 1
ldc 0
ldc 1
isub
invokestatic core013/test(I)I
iand
ifeq label0
bipush 1
ldc 0
invokestatic core013/test(I)I
iand
ifeq label0
bipush  1
goto label1
label0:
bipush 0
label1:
invokestatic core013/printBool(I)V
pop
bipush 0
ldc 0
ldc 2
isub
invokestatic core013/test(I)I
ior
ifne label2
bipush 0
ldc 1
invokestatic core013/test(I)I
ior
ifne label2
bipush  0
goto label3
label2:
bipush 1
label3:
invokestatic core013/printBool(I)V
pop
bipush 1
bipush 1
ldc 3
invokestatic core013/test(I)I
iand
ifeq label6
bipush 1
ldc 0
ldc 5
isub
invokestatic core013/test(I)I
iand
ifeq label6
bipush  1
goto label7
label6:
bipush 0
label7:
iand
ifeq label4
bipush 1
ldc 1
iand
ifeq label4
bipush  1
goto label5
label4:
bipush 0
label5:
invokestatic core013/printBool(I)V
pop
bipush 0
ldc 3
invokestatic core013/test(I)I
ior
ifne label8
bipush 0
bipush 1
ldc 0
ldc 5
isub
invokestatic core013/test(I)I
iand
ifeq label10
bipush 1
ldc 1
iand
ifeq label10
bipush  1
goto label11
label10:
bipush 0
label11:
ior
ifne label8
bipush  0
goto label9
label8:
bipush 1
label9:
invokestatic core013/printBool(I)V
pop
ldc 1
invokestatic core013/printBool(I)V
pop
ldc 0
invokestatic core013/printBool(I)V
pop
ldc 0
ireturn
bipush 0
ireturn
.end method

.method public static printBool(I)V
  .limit locals 1000
  .limit stack 1000
iload_0
ifeq label12
goto label13
label12:
label13:
ireturn
.end method

.method public static test(I)I
  .limit locals 1000
  .limit stack 1000
bipush 1
iload_1
ldc 0
if_icmpgt label14
pop
bipush 0
label14:
ireturn
bipush 0
ireturn
.end method

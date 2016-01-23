.class public good09
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good09/main()I
  pop
  return
.end method

.method public static main()I
  .limit locals 1000
  .limit stack 1000
invokestatic Runtime/readInt()I
istore_0
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_0
dup
ldc 1
iadd
istore_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_0
ldc 1
iadd
dup
istore_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
iload_0
invokestatic Runtime/printInt(I)V
bipush 0
pop
bipush 0
ireturn
.end method

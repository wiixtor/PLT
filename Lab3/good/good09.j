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
invokestatic runtime/readInt()Iistore 0
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
dup
ldc 1
iadd
istore 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
ldc 1
iadd
dup
istore 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop

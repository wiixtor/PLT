.class public good17
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic good17/main()I
  pop
  return
.end method
iload 0
ldc 6
dup
istore 0
pop
iload 1
iload 0
ldc 7
iadd
dup
istore 1
pop
iload 1
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 2
ldc 4
dup
istore 2
pop
iload 2
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
iload 2
dup
istore 0
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
iload 1
invokestatic runtime/printInt(I)V
bipush 0
pop

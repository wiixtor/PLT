.class public core009
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic core009/main()I
  pop
  return
.end method
.method public static foo()I  .limit locals 1000
  .limit stack 1000
istore 0
iload 0
invokestatic runtime/printInt(I)V
bipush 0
pop
ldc 0
return
ldc 10
return

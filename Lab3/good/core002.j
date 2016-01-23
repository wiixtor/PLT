.class public core002
.super java/lang/Object

.method public <init>()V
  aload_0
  invokespecial java/lang/Object/<init>()V
  return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 1
  invokestatic core002/main()I
  pop
  return
.end method

.method public static main()I
  .limit locals 1000
  .limit stack 1000
invokestatic Runtime/foo()V
pop
ldc 0
ireturn
bipush 0
ireturn
.end method

.method public static foo()V
  .limit locals 1000
  .limit stack 1000
ireturn
.end method

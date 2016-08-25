class A
{
  A parent;
  A(){}
}

class B extends A
{
  int a = 9;
}

class C {}
class D<T> {}
abstract class E {}
class F {}

class H {}
class I {}

class G extends A with C, D<H> implements E, F
{
  int a = 9;
}
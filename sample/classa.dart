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

class G extends A with C, D<int> implements E, F
{
  int a = 9;
}
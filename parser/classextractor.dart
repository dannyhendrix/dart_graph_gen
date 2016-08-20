library classextractor;

import "tokenizer.dart";

class ClassDefinition
{
  Token token;
  ClassDefinition generic;
  List<ClassDefinition> extendsClass;
  List<ClassDefinition> implementsClass;
  ClassDefinition(this.token);
  String toString() => "${token.token}${generic == null ? "" : "<$generic>"}${extendsClass == null ? "" : " extends $extendsClass"}${implementsClass == null ? "" : " implements $implementsClass"}";
}

//enum ClassExtractorState {ClassToken, ClassId, ExtendsToken, ExtendsId, ImplementsToken, ImplemetsId}
// class A<T extends B> extends B<T extends B> with C<T extends B>,D<T extends B> implements E<T extends B>, G<T extends B>
enum ClassExtractorState {Start, AfterClassToken, AfterClassName, After, ImplementsToken, ImplemetsId}
class ClassExtractor
{
  List<ClassDefinition> extractClasses(List<Token> tokens)
  {
    List<ClassDefinition> classes = [];
    ClassDefinition currentClass;
    Iterator<Token> iterator = tokens.iterator;
    while(iterator.moveNext())
    {
      Token t = iterator.current;
      if(!(t is IdToken && t.token == "class"))
        continue;
      //className
      iterator.moveNext();
      t = iterator.current;
      currentClass = new ClassDefinition(t);
      classes.add(currentClass);
      //4 options: 1) < 2) extends 3) implements 4) {
      iterator.moveNext();
      checkForGeneric(iterator, currentClass);
      checkForExtends(iterator, currentClass);
      checkForImplements(iterator, currentClass);
    }
    return classes;
  }

  void checkForGeneric(Iterator<Token> iterator, ClassDefinition currentClass)
  {
    if(iterator.current.token != "<")
      return;
    // skip <
    iterator.moveNext();
    //T extends B> or T>
    ClassDefinition generic = new ClassDefinition(iterator.current);
    currentClass.generic = generic;
    iterator.moveNext();
    // > or extends B>
    if(iterator.current.token == "extends")
    {
      iterator.moveNext();
      // B>
      generic.extendsClass = [new ClassDefinition(iterator.current)];
      iterator.moveNext();
    }
    // currently at >
    iterator.moveNext();
  }

  void checkForExtends(Iterator<Token> iterator, ClassDefinition currentClass)
  {
    if(iterator.current.token != "extends")
      return;
    // B or B<T> or B<T extends C>
    iterator.moveNext();
    ClassDefinition extendsClass = new ClassDefinition(iterator.current);
    currentClass.extendsClass = [extendsClass];
    iterator.moveNext();
    checkForGeneric(iterator, extendsClass);
    // either "with" or something else..
    if(iterator.current.token != "with")
      return;
    do
    {
      iterator.moveNext();
      extendsClass = new ClassDefinition(iterator.current);
      currentClass.extendsClass.add(extendsClass);
      iterator.moveNext();
      checkForGeneric(iterator, extendsClass);
    }
    while(iterator.current.token == ",");
  }
  void checkForImplements(Iterator<Token> iterator, ClassDefinition currentClass)
  {
    if(iterator.current.token != "implements")
      return;
    // B or B<T> or B<T extends C>
    iterator.moveNext();
    ClassDefinition implementsClass = new ClassDefinition(iterator.current);
    currentClass.implementsClass = [implementsClass];
    iterator.moveNext();
    checkForGeneric(iterator, implementsClass);
    // either "with" or something else..
    while(iterator.current.token == ",")
    {
      iterator.moveNext();
      implementsClass = new ClassDefinition(iterator.current);
      currentClass.implementsClass.add(implementsClass);
      iterator.moveNext();
      checkForGeneric(iterator, implementsClass);
    }
  }
}
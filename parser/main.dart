import 'dart:async';
import 'dart:io';
import 'tokenizer.dart';
import 'classextractor.dart';

void main(List<String> arguments)
{
  Parser parser = new Parser();
  String file = arguments.length > 0 ? arguments[0] : "sample/sample.dart";
  parser.openFile(file);
}

class Parser
{
  Tokenizer tokenizer = new Tokenizer();
  ClassExtractor classExtractor = new ClassExtractor();

  void openFile(String path)
  {
    Future<String> stream = new File(path).readAsString();
    stream.then(readInput);
  }

  void readInput(String input)
  {
    print("--------- Input -----------");
    print(input);

    List<Token> tokens = tokenizer.tokenize(input);
    print("--------- Tokenizer -----------");
    for(Token t in tokens)
      print(t.toString());

    print("--------- ClassExtractor -----------");
    List<ClassDefinition> classes = classExtractor.extractClasses(tokens);
    for(ClassDefinition cd in classes)
        print(cd.toString());
  }
}

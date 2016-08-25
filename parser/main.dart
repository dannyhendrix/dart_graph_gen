import 'dart:async';
import 'dart:io';
import 'parser.dart';

void main(List<String> arguments)
{
  Parser parser = new Parser();
  String fileDir = arguments.length > 0 ? arguments[0] : "sample";
  /*
  String file = arguments.length > 0 ? arguments[0] : "sample/sample.dart";
  parser.openFile(file);
  */
  // Get the system temp directory.
  Directory dir = new Directory(fileDir);

  // List directory contents, recursing into sub-directories,
  // but not following symbolic links.
  Stream<FileSystemEntity> a = dir.list(recursive: true, followLinks: false);
  int counter = 1;
  Function callback = (){
    counter--;
    if(counter == 0)
      parser.createGraph();
  };
  //a.forEach()
  a.forEach((FileSystemEntity entity)
  {
    String path = entity.path;
    if(!path.endsWith(".dart"))
      return;
    counter++;
    parser.openFile(path, callback);
  }).then((a){
    callback();
  });

}

class Parser
{
  Tokenizer tokenizer = new Tokenizer();
  ClassExtractor classExtractor = new ClassExtractor();
  GraphGenerator graphGenerator = new GraphGenerator();
  List<ClassDefinition> classes = [];

  void openFile(String path, Function callback)
  {
    Future<String> stream = new File(path).readAsString();
    stream.then(readInput).then((a){
      callback();
    });
  }

  void readInput(String input)
  {
    print("--------- Input -----------");
    //print(input);

    List<Token> tokens = tokenizer.tokenize(input);
    print("--------- Tokenizer -----------");
    //for(Token t in tokens)
      //print(t.toString());

    print("--------- ClassExtractor -----------");
    /*List<ClassDefinition> classes = classExtractor.extractClasses(tokens);
    for(ClassDefinition cd in classes)
        print(cd.toString());
    */
    classes.addAll(classExtractor.extractClasses(tokens));
  }

  void createGraph()
  {
    print("--------- GraphGenerator -----------");
    graphGenerator.createGraph(classes);
  }
}

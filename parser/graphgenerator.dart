part of parser;

class GraphGenerator
{
  GraphGenerator();

  Map createGraph(List<ClassDefinition> classes)
  {
    Map output = {};
    Map<String, int> classIdLookup = {};
    //1 class references
    Map<String,String> nodes = {};
    int i = 0;
    for(ClassDefinition c in classes)
    {
      nodes[i.toString()] = c.token.token;
      classIdLookup[c.token.token] = i;
      i++;
    }
    output["nodes"] = nodes;

    //2 references to other classes
    List<Map> edges = [];
    for(ClassDefinition c in classes)
    {
      //a class can be generic with a type that extends a class. This class is a reference.
      if(c.generic != null && c.generic.extendsClass != null)
        edges.add(createEdge(classIdLookup[c.token.token],classIdLookup[c.generic.extendsClass.first],0));

      if(c.extendsClass != null)
        for(ClassDefinition cd in c.extendsClass)
        //TODO these extending classes can be generic?
          edges.add(createEdge(classIdLookup[c.token.token],classIdLookup[cd.token.token],1));

      if(c.implementsClass != null)
        for(ClassDefinition cd in c.implementsClass)
        //TODO these implementing classes can be generic?
          edges.add(createEdge(classIdLookup[c.token.token],classIdLookup[cd.token.token],2));

    }
    output["edges"] = edges;
    /*
    Map input = {"nodes":{0:"ClassA",1:"ClassB",2:"ClassB",3:"ClassB",4:"ClassB",5:"ClassB",6:"ClassB",7:"ClassB",8:"ClassB",9:"ClassB"},
    "types":{0:"use",1:"extend",2:"implements"},
    "edges":[
    {"s":0,"e":6,"t":1},
    {"s":6,"e":0,"t":2}
  ]};
     */

    //print(JSON.encode(output));

    new File("graph.json").writeAsString(JSON.encode(output));
  }
  Map createEdge(int from, int to, int type)
  {
    return {"s":from,"e":to,"t":type};
  }
}
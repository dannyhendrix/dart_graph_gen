import 'dart:html';
import 'dart:math' as Math;

void main()
{
  Map input = {"nodes":{0:"ClassA",1:"ClassB",2:"ClassB",3:"ClassB",4:"ClassB",5:"ClassB",6:"ClassB",7:"ClassB",8:"ClassB",9:"ClassB"},
    "types":{0:"use",1:"extend",2:"implements"},
    "edges":[
    {"s":0,"e":6,"t":1},
    {"s":6,"e":0,"t":2}
  ]};

  GraphVisualizer visualizer = new GraphVisualizer(input);
  document.body.append(visualizer.canvas);

}

class VisualizationNode
{
  int x,y;
  String name;
  VisualizationNode(this.name, this.x, this.y);
}

class GraphVisualizer
{
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  GraphVisualizer(Map input)
  {
    final int paddingW = 50;
    final int paddingH = 50;
    final int radius = 10;

    final int cols = Math.min(6,input["nodes"].length);
    final int rows = (input["nodes"].length/cols).ceil().toInt();

    canvas = new CanvasElement(width:paddingW*cols+paddingW, height: (10+paddingH)*rows+paddingH);
    ctx = canvas.getContext("2d");

    int x = paddingW;
    int y = paddingH;
    Map<int,VisualizationNode> nodes = {};
    input["nodes"].forEach((int k, String v) {
      drawNode(x, y, v, radius);
      nodes[k] = new VisualizationNode(v,x,y);
      x+= paddingW;
      if((k+1)%cols == 0)
      {
        y += paddingH+10;
        x = paddingW;
      }
    });

    input["edges"].forEach((Map m) {
      drawEdge(nodes[m["s"]],nodes[m["e"]],m["t"]);
    });
  }

  void drawEdge(VisualizationNode from, VisualizationNode to, int type)
  {
    String color = "#000";
    bool filled = false;
    bool closed = false;
    switch(type)
    {
    //use, extends, implements
      case 1:
        closed = true;
        break;
      case 2:
        closed = true;
        filled = true;
        break;
    }
    drawArrow(from,to,closed,filled,color);
  }
  void drawArrow(VisualizationNode from, VisualizationNode to, bool filled, bool closed, String color)
  {
    ctx.strokeStyle = color;
    ctx.fillStyle = color;
    //arrow
    ctx.beginPath();
    int headlen = 10;   // length of head in pixels
    var angle = Math.atan2(to.y-from.y,to.x-from.x);
    ctx.moveTo(from.x, from.y);
    ctx.lineTo(to.x, to.y);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(to.x-headlen*Math.cos(angle-Math.PI/6),to.y-headlen*Math.sin(angle-Math.PI/6));
    ctx.lineTo(to.x, to.y);
    ctx.lineTo(to.x-headlen*Math.cos(angle+Math.PI/6),to.y-headlen*Math.sin(angle+Math.PI/6));
    if(filled)
      ctx.fill();
    if(closed)
      ctx.closePath();
    ctx.stroke();
  }
  void drawNode(int x, int y, String name, int radius)
  {
    ctx.moveTo(x,y);
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false);
    ctx.fillStyle = '#ccc';
    ctx.fill();
    ctx.lineWidth = 1;
    ctx.strokeStyle = '#000';
    ctx.stroke();
    ctx.fillStyle = "black";
    ctx.fillText(name,x-radius,y+radius+10);
  }
  String getTypeColor(int type)
  {
    String color = "#000";
    bool filled = false;
    bool closed = false;
    switch(type)
    {
      //use, extends, implements
      case 0:

      break;
      case 1:
        closed = true;
        break;
      case 2:
        closed = true;
        filled = true;
        break;
    }
  }
}
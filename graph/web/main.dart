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
    canvas = new CanvasElement(width:200, height: 300);
    ctx = canvas.getContext("2d");
    int x = 40;
    int y = 40;
    Map<int,VisualizationNode> nodes = {};
    input["nodes"].forEach((int k, String v) {
      drawNode(x, y, v);
      nodes[k] = new VisualizationNode(v,x,y);
      x+= 45;
      if((k+1)%4 == 0)
      {
        y += 55;
        x = 40;
      }
    });

    input["edges"].forEach((Map m) {
      drawEdge(nodes[m["s"]],nodes[m["e"]],m["t"]);
    });
  }

  void drawEdge(VisualizationNode from, VisualizationNode to, int type)
  {
    ctx.beginPath();
    ctx.moveTo(from.x-10, from.y);
    ctx.lineTo(to.x, to.y);
    ctx.strokeStyle = getTypeColor(type);
    ctx.stroke();

    //arrow
    ctx.beginPath();
    int headlen = 10;   // length of head in pixels
    var angle = Math.atan2(to.y-from.y,to.x-from.x);
    ctx.moveTo(from.x, from.y);
    ctx.lineTo(to.x, to.y);
    ctx.lineTo(to.x-headlen*Math.cos(angle-Math.PI/6),to.y-headlen*Math.sin(angle-Math.PI/6));
    ctx.moveTo(to.x, to.y);
    ctx.lineTo(to.x-headlen*Math.cos(angle+Math.PI/6),to.y-headlen*Math.sin(angle+Math.PI/6));
    ctx.stroke();
  }
  void drawNode(int x, int y, String name)
  {
    ctx.moveTo(x,y);
    int radius = 10;

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
    switch(type)
    {
      case 0:
        return "#000";
      case 1:
        return "#f00";
      case 2:
        return "#0f0";
      case 3:
        return "#00f";
      default:
        return "#333";
    }
  }
}
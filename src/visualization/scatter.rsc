module visualization::scatter

import Prelude;
import lang::java::jdt::JavaADT;
import vis::Figure;
import vis::KeySym;
//import vis::Render;
import util::Math;

//alias DataPoint = tuple[str label, int x_value, int y_value];
alias FigureGrid = list[list[Figure]];
alias Point = tuple[int x, int y];

data ScatterOption    = x_axis(str name)
                            | y_axis(str name)
                            | x_max(int max)
                            | y_max(int max)
                            | resolution(int res)
                            | log()
                            | toStr(str (value \data) toStringFunction)
                            ;


public Figure scatter(lrel[value \data, int x_values, int y_values] correlation, list[ScatterOption] options) {
    str x_axis_name = "X";
    str y_axis_name = "Y";
    int x_maximum = 100;
    int y_maximum = 100;
    int resolution = 100;
    bool logscale = false;
    str(value) dataPrinter;
    
    top-down visit (options) {
        case x_axis(name):
            x_axis_name = name;
        case y_axis(name):
            y_axis_name = name;
        case x_max(max):
            x_maximum = max;
        case y_max(max):
            y_maximum = max;
        case resolution(res):
            resolution = res;
        case log():
            logscale = true;
        case toStr(str(value)toStringFunction):
            dataPrinter = toStringFunction;
    }
    
    println(correlation);
    
    correlation = [<\data, projection(x, x_maximum, resolution, logscale), projection(y, y_maximum, resolution, logscale)> | <\data, x, y> <- correlation];
    
    //lrel[int,int] points = [<x,y> | x <- [0..RESOLUTION], y <- [0..RESOLUTION]];
    
    map[tuple[int,int],set[value]] pointMap = toMap(correlation);
    FigureGrid figureGrid = [];
    
    for (y <- [0..101]) {
        figureGrid += [[ ]];
        
        for (x <- [0..101]) {
            if (<x,y> in pointMap) {
                figureGrid[y] += [ellipse(
                    fillColor("green"),
                    onMouseDownAtPoint(<x,y>, bool(int _, map[KeyModifier, bool] _, Point p) {
                        iprintln(dataPrinter(pointMap[<p.x, p.y>]));
                        return true;
                    })
                )
                ];
            } else {
                figureGrid[y] += [space()];
            }
        }
    }
    
    /* flip the grid vertically */
    figureGrid = verticalFlip(figureGrid);
    
    /*
    sortedCorrelation = sort(correlation,
        bool(<_, int a_x_value, int a_y_value>,
              <_, int b_x_value, int b_y_value>)
        {
            if (a_x_value < b_x_value) {
                return true;
            } else if (a_x_value == b_x_value) {
                return a_y_value < b_y_value;
            } else {
                return false;
            }
        }
    );
    */
    
    //println(sortedCorrelation);
    
    
    
    
    println("drawing...");
    return grid(figureGrid);
    
}

/* helpers */
private FProperty onMouseDownAtPoint(Point point, bool(int, map[KeyModifier, bool], Point) handle) {
    return onMouseDown(bool(int buttonNumber, map[KeyModifier, bool] keyModifiers) {
        return handle(buttonNumber, keyModifiers, point);
    });
}
private FigureGrid verticalFlip(FigureGrid figureGrid) = reverse(figureGrid);
private int expand(int number) = round(number * 1.2);

private int projection(int coord, int max_coord, int precision, bool logscale:true) = round(precision * log10(coord) / log10(max_coord));
private int projection(int coord, int max_coord, int precision, bool logscale:false) = round(precision * coord / max_coord);

private map[tuple[int,int],set[value]] toMap(lrel[value,int,int] correlation) {
    map[tuple[int,int],set[value]] pointMap = ();
    
    for (<\data, x, y> <- correlation) {
        if (!(<x,y> in pointMap)) {
            pointMap[<x,y>] = {\data};
        } else {
            pointMap[<x,y>] += {\data};
        }
    }
    
    return pointMap;
}

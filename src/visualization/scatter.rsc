module visualization::scatter

import Prelude;
import lang::java::jdt::JavaADT;
import vis::Figure;
import vis::KeySym;
//import vis::Render;
import util::Math;
import IO;

//alias DataPoint = tuple[str label, int x_value, int y_value];
alias FigureGrid = list[list[Figure]];
alias Point = tuple[int x, int y];
alias DataPoint = tuple[value dataItem, Point point];
alias DataPointList = lrel[value dataItems, Point points];
alias PointMap = map[Point, set[value]];

data ScatterOption    = x_axis(str name)
                      | y_axis(str name)
                      | x_max(int max)
                      | y_max(int max)
                      | resolution(int res)
                      | logarithmic()
                      | onPointSelect(void(Point p, value dataItem) callback)
                      ;


public Figure scatter(DataPointList dataPoints, list[ScatterOption] options) {
    str x_axis_name = "X";
    str y_axis_name = "Y";
    int x_maximum = 100;
    int y_maximum = 100;
    int resolution = 100;
    bool logscale = false;
    void (Point p, value dataItem) pointSelectionCallback = void(_, _) { println("No data handler provided"); };
    
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
        case logarithmic():
            logscale = true;
        case onPointSelect(void (Point p, value dataItem) cb):
            pointSelectionCallback = cb;
    }
    
    /* map the x and y values to actual positions in the scatter plot grid */
    DataPointList projected = mapper(dataPoints, DataPoint(DataPoint dataPoint) {
        return <dataPoint.dataItem,
        		<projection(dataPoint.point.x, x_maximum, resolution, logscale),
            	projection(dataPoint.point.y, y_maximum, resolution, logscale)>>;
    });
        
    /* we iterate over points, because I have no idea how else we can produce a grid, hence the map of
     * points to data items */
    PointMap pointMap = toMap(projected);
    
    /* actually make the grid */
    FigureGrid scatterGrid = makeDataGrid(pointMap, pointSelectionCallback);
    
    return grid(scatterGrid);
}

private FigureGrid
makeDataGrid(PointMap pointMap, void(Point, set[value]) clickHandler) {
    FigureGrid figureGrid = [];
    for (y <- [0..100]) {
        figureGrid += [[ ]];
        
        for (x <- [0..100]) {
            Figure shape;
            if (<x,y> in pointMap) {
                handler = void(Point p) {
                    clickHandler(p, pointMap[p]);
                };
                
                onclick = onMouseDownAtPoint(<x,y>, handler); 
                
                shape = ellipse(fillColor("green"), onclick);
            } else {
                shape = space();
            }
            figureGrid[y] += [shape];
        }
    }
    
    /* flip the grid vertically, because it's being drawn from the top */
    figureGrid = verticalFlip(figureGrid);
    
    return figureGrid;
}

/* helpers */

/* simplify the callback, we don't need all the extra key and mouse button parameters */
private FProperty onMouseDownAtPoint(Point point, bool(Point) handle) {
    return onMouseDown(bool(int _, map[KeyModifier, bool] _) {
        handle(point);
        return true;
    });
}

private FigureGrid verticalFlip(FigureGrid figureGrid) = reverse(figureGrid);

/* make sure the grid is large enough to hold all the points, maybe a little unnecessary, but whatever */
private int expand(int number) = round(number * 1.2);

/* linear or logarithmic projection */
private int projection(int coord, int max_coord, int precision, bool logscale:true) = round(precision * log10(coord) / log10(max_coord));
private int projection(int coord, int max_coord, int precision, bool logscale:false) = round(precision * coord / max_coord);


private PointMap toMap(DataPointList dataPoints) {
    PointMap pointMap = ();
    
    for (<dataItem, <x, y>> <- dataPoints) {
        if (!(<x,y> in pointMap)) {
            pointMap[<x,y>] = { dataItem };
        } else {
            pointMap[<x,y>] += { dataItem };
        }
    }
    
    return pointMap;
}

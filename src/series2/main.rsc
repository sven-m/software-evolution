module series2::main

import metrics::complexity;
import metrics::volume;
import misc::astloader;
import visualization::scatter;
import misc::stringconversion;

import Prelude;
import Type;
import lang::java::jdt::JavaADT;
import vis::Figure;
import vis::Render;

import util::Editors;

public loc bigProject = |project://SQLBig/|;
public loc smallProject = |project://SQLSmall/|;
public loc qlProject = |project://QL|;

data MethodInfo = methodInfo(AstNode method, int volume, int complexity);

public void main() {
    println("getting all complexities and sizes...");
    DataPointList dataPoints = [makeDataPoint(method) | method <- extractMethods(smallProject)];
    
    println("done.");
    //correlation 
    /*lrel[str methods, tuple[int sizes, int complexities] points] correlation = [
        <"A", 1, 1>,
        <"B", 2, 2>,
        <"C", 3, 3>,
        <"D", 4, 4>,
        <"E", 5, 5>,
        <"F", 6, 6>,
        <"G", 7, 7>,
        <"H", 1000, 1000>,
        <"I", 1000, 1000>,
        <"J", 1000, 1000>
    ];*/
    
    MenuBuilder menuBuilder = MenuBuilderResult(value dataItem) {
        return buildMenuItem(dataItem);
    };
    
    println("building figure...");
    Figure scatterPlot = scatter(dataPoints,
        [
            x_axis("Unit Size"),
            y_axis("Complexity"),
            x_max(max(dataPoints.points.x)),
            y_max(max(dataPoints.points.y)),
            logarithmic(),
            userInteraction(menuBuilder)
        ]
    );
    println("done.");
    
    println("drawing...");
    render(scatterPlot);
    println("done.");
}

private DataPoint makeDataPoint(AstNode method:methodDeclaration(_, _, _, _, _, _, _, _)) {
    int volume = getASTVolume(method);
    int complexity = numericUnitComplexity(method);
    Point point = <volume, complexity>;
    
    MethodInfo dataItem = methodInfo(method, volume, complexity);
    
    return <dataItem, point>;
}

private MenuBuilderResult buildMenuItem(value dataItem) {
    if (MethodInfo info:methodInfo(method, volume, complexity) := dataItem) {
        if (methodDeclaration(_, _, _, _, _, _, _, _) := method) {
            void() clickHandler = void() {
                edit(method@location);
            };
        
            return <"<label(method)> (SIZE = <volume> SLOC, COMP = <complexity>)", clickHandler>;
        }
    }
}

private void typeError(Symbol expected, Symbol actual) {
    assert false : "data should be <expected>, but is <actual>.";
}

private str label(value dataItem) {
    if (AstNode method:methodDeclaration(_, _, _, _, str name, _, _, _) := dataItem) {
        return "<toShortString(method)> @ <method@location.file>:<method@location.begin.line>";
    } else {
        typeError(adt("AstNode", []), typeOf(dataItem));
    }
}
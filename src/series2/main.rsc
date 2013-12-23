module series2::main

import metrics::complexity;
import metrics::volume;
import misc::astloader;
import visualization::scatter;

import Prelude;
import Type;
import lang::java::jdt::JavaADT;
import vis::Figure;
import vis::Render;

import util::Editors;

public loc bigProject = |project://SQLBig/|;
public loc smallProject = |project://SQLSmall/|;
public loc qlProject = |project://QL|;


public void main() {
    println("getting all complexities and sizes...");
    DataPointList dataPoints = [<m, <getASTVolume(m), numericUnitComplexity(m)>> | m <- extractMethods(smallProject)];
    
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
    
    println("building figure...");
    Figure scatterPlot = scatter(dataPoints,
        [
            x_axis("Unit Size"),
            y_axis("Complexity"),
            x_max(max(dataPoints.points.x)),
            y_max(max(dataPoints.points.y)),
            logarithmic(),
            onPointSelect(void (Point p, value dataItem) { println("X:<p.x> Y:<p.y> L:<label(takeOneFrom(dataItem))>"); } )
        ]
    );
    println("done.");
    
    println("drawing...");
    render(scatterPlot);
    println("done.");
}

private void assertIsMethod(value dataItem) {
    assert (methodDeclaration(_, _, _, _, _, _, _, _) := dataItem) 
    : "data should be AstNode (methodDeclaration(...)), but is of type <typeOf(dataItem)>.";
}

//public str label(methodDeclaration(_, _, _, _, str name, _, _, _)) = name;
private str label(value dataItem) {
    assertIsMethod(dataItem);
    
    if (methodDeclaration(_, _, _, _, str name, _, _, _) := dataItem) {
        return name;
    }
}

private void printLocation(value dataItem) {
    assertIsMethod(dataItem);
    
    if (AstNode method:methodDeclaration(_, _, _, _, _, _, _, _) := dataItem) {
        println(method@location);
    }
}

private void editLocation(value dataItem) {
    assertIsMethod(dataItem);
    
    if (AstNode method:methodDeclaration(_, _, _, _, _, _, _, _) := dataItem) {
        edit(method@location);
    }
}

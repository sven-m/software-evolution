module series2::main

import metrics::complexity;
import metrics::volume;
import misc::astloader;
import visualization::scatter;

import Prelude;
import lang::java::jdt::JavaADT;
import vis::Figure;
import vis::Render;

public loc bigProject = |project://SQLBig/|;
public loc smallProject = |project://SQLSmall/|;
public loc qlProject = |project://QL|;


public void main() {
    println("computing correlation lrel");
    lrel[value \data, int sizes, int complexities] correlation = [<m, getASTVolume(m), numericUnitComplexity(m)> | m <- extractMethods(smallProject)];
    println("done.");
    //correlation 
    /*lrel[str methods, int sizes, int complexities] correlation = [
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
    
    iprintln(toSet(correlation.sizes));
    iprintln(toSet(correlation.complexities));
    render(scatter(correlation,
        [
            x_axis("Unit Size"),
            y_axis("Complexity"),
            x_max(max(correlation.sizes)),
            y_max(max(correlation.complexities)),
            log(),
            toStr(str (value \data) { return label(\data); })
        ]
    ));
}

//public str label(methodDeclaration(_, _, _, _, str name, _, _, _)) = name;
private str label(value \data) {
    if (methodDeclaration(_, _, _, _, str name, _, _, _) := \data) {
        return name;
    } else {
        assert false : "data should be AstNode (methodDeclaration(...)).";
        return "AAAAH";
    }
}

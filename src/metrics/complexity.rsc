module metrics::complexity

import Prelude;
import lang::java::jdt::JavaADT;

import misc::astloader;
import misc::verbose;
import metrics::volume;


data ComplexityClass    = simple()
                        | moderate()
                        | complex()
                        | untestable()
                        ;


public map[ComplexityClass classes, int volumes] complexityDistribution(project(projectNodes)) {
    /* extract methods from all root nodes and combine them all into a list */
    list[AstNode] allMethods = [ *extractMethods(n) | n <- projectNodes ];
    
    return distribution([unitComplexity(m) | m <- allMethods]);
}


/*
 * helper functions
 */

public int numericUnitComplexity(AstNode method:methodDeclaration(_, _, _, _, _, _, _, _)) {
    int cc = 1;
        
    top-down visit(method) {
        case ifStatement(boolExpr, _, _):
            cc += 1 + conjunctions(boolExpr);
        case conditionalExpression(_, _, _):
            cc += 1;
        case whileStatement(boolExpr, _):
            cc += 1 + conjunctions(boolExpr);
        case doStatement(_, boolExpr):
            cc += 1 + conjunctions(boolExpr);
        case forStatement(_, some(boolExpr), _, _):
            cc += 1 + conjunctions(boolExpr);
        case forStatement(_, _, _, _):
            cc += 1;
        case enhancedForStatement(_, _, _):
            cc += 1;
        case switchCase(_, _):
            cc += 1;
        case catchClause(_, _):
            cc += 1;
    }
    
    return cc;
}

private int conjunctions(AstNode boolExpr) {
    int conjunctions = 0;
    
    for (/infixExpression("&&", _, _, _) := boolExpr) {
        conjunctions += 1;
    }
    
    return conjunctions;
}

public ComplexityClass unitComplexity(AstNode method:methodDeclaration(_, _, _, _, _, _, _, _)) {
    return classify(unitComplexityNumeric(method));
}


private ComplexityClass classify(int complexity) {
    assert complexity > 0 : "Numeric value denoting complexity should be a positive integer";

    return
                if (complexity in [ 1..11]) { simple();     } 
        else    if (complexity in [11..21]) { moderate();   }
        else    if (complexity in [21..51]) { complex();    }
        else                                { untestable(); };
}


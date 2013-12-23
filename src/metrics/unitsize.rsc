module metrics::unitsize

import Prelude;
import misc::astloader;
import misc::ranking;
import misc::verbose;
import metrics::volume;

import lang::java::jdt::JavaADT;

data UnitSizeClass    = tiny()
                            | small()
                            | average()
                            | large()
                            ;

public map[UnitSizeClass classes, int volumes] unitSizeDistribution(project(projectNodes)) {
    /* extract methods from all root nodes and combine them all into a list */
    list[AstNode] allMethods = [ *extractMethods(n) | n <- projectNodes ];
    
    return distribution([unitSize(m) | m <- allMethods]);
}

public UnitSizeClass unitSize(AstNode method:methodDeclaration(_, _, _, _, _, _, _, _)) {
    return classify(getASTVolume(method));
}

private UnitSizeClass classify(int unitSize) {
    assert unitSize > 0 : "Numeric value denoting unit size should be a positive integer";

    return
              if (unitSize in [ 1 ..  20])    { tiny();        }
        else if (unitSize in [20 ..  50])    { small();        }
        else if (unitSize in [50 .. 100])    { average();    }
        else                                             { large();        }
}


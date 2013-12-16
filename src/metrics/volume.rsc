module metrics::volume

import Prelude;
import lang::java::jdt::JavaADT;
import lang::java::jdt::JDT;
import misc::astloader;
import Traversal;

public int getProjectVolume(project(projectNodes)) {
	return ( 0 | it + getASTVolume(n) | n <- projectNodes);
}

public int getASTVolume(AstNode rootNode) {
	set[int] usedLines = {};
	
	top-down visit (rootNode) {
	/* ignore "compilationUnit", this comprises the whole file, including blank
	 * lines and (starting) comments.
	 */ 
	case compilationUnit(_, _, _):
		;
	/* ignore "methodDeclaration" and "typeDeclaration", because they include the
	 * javadoc attached to the class/method. The node for the return type does get
	 * the right starting line */  
	case methodDeclaration(_, _, _, _, _, _, _, _):
		;
	case typeDeclaration(_, _, _, _, _, _, _, _):
		;
	case AstNode n:
		/* only count the first and last line of every element in the tree, this works
		 * 99% of the time.
		 */
		usedLines += {n@location.begin.line};//, n@location.end.line}; 
	}
	
	/* take out duplicates and compute number of lines */
	numberOfLines = size(usedLines);
	
	return numberOfLines;
}


public void addVolumeAnnotations(AstNode rootNode) {
	return bottom-up visit(rootNode) {
		case AstNode n: {
			tc = getTraversalContext();
			println("---");
			for (tn <- tc) {
				println(tn);
			}
		}
	}
}
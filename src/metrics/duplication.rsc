module metrics::duplication

import Prelude;
import lang::java::jdt::JDT;
import lang::java::jdt::JavaADT;
import Set;
import List;

import misc::verbose;
import misc::progress;
import misc::benchmarking;
import misc::astloader;
import metrics::volume;


int MASS_THRESHOLD = 5;


public int duplicateLines(loc project) {
	int counter = 0;
	set[AstNode] allTrees = getProject(project);
	
	int numOfSubTrees;
	
	/* get ALL sub trees, combine lists from all files */
	initProgress("", size(allTrees), 1);
	startBench("processing sub trees");
	rel[AstNode nodes, loc locations] subTrees = { *getSubTrees(n) | n <- allTrees };
	numOfSubTrees = size(subTrees);
	stopBench(numOfSubTrees);
	
	debug("number of sub trees: <numOfSubTrees>");
	
	/* get a set of unique clone instances */
	startBench("getting unique clone instances");
	set[AstNode] uniqueNodes = subTrees.nodes;
	stopBench();
	
	/* determine duplicate elements, including overlapping ones */
	initProgress("", numOfSubTrees, 1000);
	startBench("determine duplicates (including overlaps)");
	set[AstNode] clonesWithOverlap = getClonesWithOverlap(uniqueNodes, subTrees);
	stopBench(numOfSubTrees);
	
	/* scan for parts of the AST that are subsets of other parts (overlap) */
	startBench("scan for overlaps");
	set[AstNode] overlap = scanOverlap(clonesWithOverlap);
	stopBench();
	
	/* subtract the overlap resulting in a map with clones */
	startBench("subtracting overlaps");
	set[AstNode] clones = clonesWithOverlap - overlap;
	stopBench();
	
	return duplicationSize(clones, subTrees);
}


/* 
 * Main helper functions
 */

rel[AstNode nodes, loc instances] getSubTrees(AstNode ast) {
	list[AstNode] stl = [];
	
	int offset;
	int length;
	
	progress("processing AST from file: <ast@location.path>)");
	
 	top-down visit(ast) {
 	case b:block(l): {
 		if (getASTVolume(b) > MASS_THRESHOLD) {
 			stl += b;
	 		
	 		for (subSeq <- getSubSequences(l)) {
	 			if (getASTVolume(subSeq) > MASS_THRESHOLD) {
	 				stl += subSeq;
	 			}
	 		}
	 	}
 	}
 	
	case AstNode n:
		if (getASTVolume(n) > MASS_THRESHOLD) {
			stl += n;
		}
	}
	
	return { <n, n@location> | n <- stl };
}


set[AstNode] getClonesWithOverlap(set[AstNode] uniqueNodes, rel[AstNode, loc] subTrees)
	= { n | n <- uniqueNodes, track(), size(subTrees[n]) > 1 };

bool track() {
	progress();
	return true;
}

set[AstNode] scanOverlap(set[AstNode] clonesWithOverlap)
{
	set[AstNode] result = {};
	
	
	initProgress("scanOverlaps", size(clonesWithOverlap), 100);
	
	for (ast <- clonesWithOverlap) {
		progress();
		
		top-down visit (ast) {
		case b:block(l): {
			if (b != ast) {
				result += b;
			}
			
			for (subSeq <- getSubSequences(l)) {
				if (subSeq in clonesWithOverlap) {
					result += subSeq;
				}
			}
		}
			
		case AstNode n: {
			if (ast != n && n in clonesWithOverlap) {
				result += n;
			}
		}
		}
	}
	
	return result;
}


void report(set[AstNode] clones, rel[AstNode, loc] subTrees) {
	numberOfClones = size(clones);
	
	if (numberOfClones == 0) {
		println("No clones found.");
	} else {
		plural = if (numberOfClones > 1) "s"; else "";
		println("<numberOfClones> clone<plural> found: ");
	}
	
	for (c <- clones) {
		println("  Size: <getASTVolume(c)> lines. # of instances: <size(subTrees[c])>");
		for (instanceLocation <- subTrees[c]) { 
			println("    -\> <instanceLocation.path> on lines <instanceLocation.begin.line> "
				+ "to <instanceLocation.end.line>.");
		}
	}
}

int duplicationSize(set[AstNode] clones, rel[AstNode nodes, loc locations] subTrees) {
	return (0 | it + getASTVolume(c) * (size(subTrees[c])-1) | c <- clones);
}


/*
 * Small helper functions
 */

list[AstNode] getSubSequences([]) = [];
list[AstNode] getSubSequences([AstNode _]) = [];
list[AstNode] getSubSequences(list[AstNode] nodeList:[AstNode a, AstNode b, *AstNode n]) {
	int offset;
	int length;
	int totalSize = size(nodeList);
	
	list[AstNode] subSequences = [];
	for (offset <- [0 .. totalSize-1]) {
		for (length <- [totalSize-1 .. 1]) {
		
			if (offset + length <= totalSize && offset + length > 0) {
				subSequences += makeBlock(slice(nodeList, offset, length));
			}
		}
	}
	
	return subSequences;
}

AstNode makeBlock([AstNode first, *AstNode seq]) {
	return block(seq)[@location=|project:://x/|(0,0,<0,0>,<0,0>)];
}

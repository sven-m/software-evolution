module misc::astloader

import Prelude;
import lang::java::jdt::JDT;
import lang::java::jdt::JavaADT;

import misc::verbose;

data Resource	= project(set[AstNode] projectNodes)
					| file(AstNode fileNode);

map[loc, Resource] resourceCache = ();

public Resource getFile(loc fileLocation) {
	
	debug("loading AST from file <fileLocation.path>");
	return file(createAstFromFile(file));
}

public Resource getProject(loc projectLocation) {
	Resource astCollection;
	
	if (projectLocation in resourceCache) {
		debug("ASTs from project <projectLocation.authority> already loaded");
	} else {
		debug("loading ASTs from project <projectLocation.authority>");
		resourceCache[projectLocation] = project(createAstsFromProject(projectLocation));
		debug("loading ASTs from project complete");
	}
	
	astCollection = resourceCache[projectLocation];
	
	return astCollection;
}

public list[AstNode] extractMethods(loc projectLocation) = extractMethods(createAstsFromProject(projectLocation));
public list[AstNode] extractMethods(set[AstNode] projectNodes) = [ *extractMethods(n) | n <- projectNodes ];
public list[AstNode] extractMethods(AstNode rootNode:compilationUnit(_, _, _)) {
	list[AstNode] methods = [];
	
	top-down visit(rootNode) {
		case method:methodDeclaration(_, _, _, _, _, _, _, _): {
			methods += method;
		}
	};
	
	return methods;
}
module misc::stringconversion

import lang::java::jdt::JavaADT;
import lang::java::jdt::Java;

public str toShortString(methodDeclaration(_, _, genericTypes, returnType, name, parameters, _, _)) {
    return "<toShortString(returnType, "void")> <name><toShortString(genericTypes)>(<toShortString(parameters)>)";
}

public str toShortString(singleVariableDeclaration(name, _, _, \type, _, isVarargs)) {
    return "<toShortString(\type)> <name><(isVarargs) ? "..." : "">";
}

//| singleVariableDeclaration(str name, list[Modifier] modifiers, list[AstNode] annotations, AstNode \type, Option[AstNode] initializer, bool isVarargs)

// Option[AstNode]
public str toShortString(some(\node), _) = toShortString(\node);
public str toShortString(none(), str noneValue) = noneValue;
public str toShortString(some(\node), _, str prefix) = "<prefix><toShortString(\node)>";

// list[AstNode]
public str toShortString(nullLiteral())  = "null"; // only for testing purposes
public str toShortString([AstNode \node]) = toShortString(\node);
public str toShortString([AstNode first, *AstNode rest]) = "<toShortString(first)>, <toShortString(rest)>";
public str toShortString(list[AstNode] nodeList:[AstNode _, *AstNode _], tuple[str left, str right] surroundWith) {
    return "<surroundWith.left><toShortString(nodeList)><surroundWith.right>";
}

// list[value]
public str toShortString([]) = "";

// AstNode: Types
public str toShortString(arrayType(\type)) = "<toShortString(\type)>[]";
public str toShortString(parameterizedType(mainType, genericTypes)) = "<toShortString(mainType)>\<<toShortString(genericTypes)>\>";
public str toShortString(primitiveType(primitive)) = toShortString(primitive);
public str toShortString(simpleType(name)) = name;
public str toShortString(unionType(types)) = toShortString(types);
public str toShortString(wildcardType(bound, lowerOrUpper)) = "? <toShortString(lowerOrUpper, "", " ")> <toShortString(bound, "", " ")>"; 

// Primitive type
public str toShortString(byte())     = "byte";
public str toShortString(short())    = "short";
public str toShortString(\int())     = "int";
public str toShortString(long())     = "long";
public str toShortString(float())    = "float";
public str toShortString(double())   = "double";
public str toShortString(char())     = "char";
public str toShortString(boolean())  = "boolean";
public str toShortString(\void())    = "void";
public str toShortString(null())     = "null";

// list[PrimitiveType]
public str toShortString([PrimitiveType item]) = toShortString(item);
public str toShortString([PrimitiveType first, *PrimitiveType rest]) = "<toShortString(first)>, <toShortString(rest)>";


//public str toShortString(list[PrimitiveType] types) = x;
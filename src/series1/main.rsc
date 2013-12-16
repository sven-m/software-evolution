module series1::main

import series1::analysis;
import misc::astloader;

public loc bigProject = |project://SQLBig/|;
public loc smallProject = |project://SQLSmall/|;
public loc qlProject = |project://QL|;


public void main() {
	Resource project = getProject(smallProject);
	analyze(project);
}
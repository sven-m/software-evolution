module series1::analysis

import Prelude;

import misc::ranking;
import misc::astloader;
import misc::verbose;

import metrics::volume;
import metrics::complexity;
import metrics::unitsize;
import metrics::duplication;

int projectVolume = -1;

public void analyze(Resource project) {
    analyzeVolume(project);
    analyzeComplexity(project);
    analyzeUnitSize(project);
    //analyzeDuplication(project);
}

public void analyzeVolume(Resource projectResource) {
    println("Computing volume...");
    projectVolume = getProjectVolume(projectResource);
    println("Volume: <projectVolume> source lines of code");
}

public void analyzeDuplication(Resource projectResource) {
    println("Computing duplication...");
    Rank duplicationRank = rankDuplication(duplicateLines(projectResource));
    
    println("Duplication: <rankToStr(duplicationRank)>");
}

public void analyzeComplexity(Resource projectResource) {
    map[ComplexityClass classes, int volumes] complexityDist;
    Rank complexityRank;
    
    println("Computing complexity distribution...");
    
    complexityDist = complexityDistribution(projectResource);
    complexityRank = rankComplexity(complexityDist);
    
    println("Complexity: <rankToStr(complexityRank)>");
}

public void analyzeUnitSize(Resource projectResource) {
    map[UnitSizeClass sizes, int volumes] unitSizeDist;
    Rank unitSizeRank;
    
    println("Computing unit size distribution...");
    
    unitSizeDist = unitSizeDistribution(projectResource);
    unitSizeRank = rankUnitSize(unitSizeDist);
    
    println("Unit size: <rankToStr(unitSizeRank)>");
}

public Rank rankComplexity(map[ComplexityClass classes, int volumes] distribution)
{
    int unitsTotalVolume = (0 | it + distribution[complexityMeasure] | complexityMeasure <- distribution);
    
    info("Total number of <unitsTotalVolume> units");
    
    real simpleShare = percent(distribution[simple()], unitsTotalVolume);
    real moderateShare = percent(distribution[moderate()], unitsTotalVolume);
    real complexShare = percent(distribution[complex()], unitsTotalVolume);
    real untestableShare = percent(distribution[untestable()], unitsTotalVolume);
    
    info("Simple share     : <simpleShare>");
    info("Moderate share   : <moderateShare>");
    info("Complex share    : <complexShare>");
    info("Untestable share : <untestableShare>");
    
    if (moderateShare <= 25 && complexShare == 0 && untestableShare == 0) {
        return excellent();
    } else if (moderateShare <= 30 && complexShare <= 5 && untestableShare == 0) {
        return good();
    } else if (moderateShare <= 40 && complexShare <= 10 && untestableShare == 0) {
        return medium();
    } else if (moderateShare <= 50 && complexShare <= 15 && untestableShare <= 5) {
        return bad();
    } else {
        return poor();
    }
}

Rank rankUnitSize(map[UnitSizeClass classes, int volumes] distribution) {
    int unitsTotalVolume = (0 | it + distribution[unitSize] | unitSize <- distribution);
    
    info("Units take up <unitsTotalVolume> source lines of code");
    
    real tinyShare = percent(distribution[tiny()], unitsTotalVolume);
    real smallShare = percent(distribution[small()], unitsTotalVolume);
    real averageShare = percent(distribution[average()], unitsTotalVolume);
    real largeShare = percent(distribution[large()], unitsTotalVolume);
    
    info("Tiny share    : <tinyShare>");
    info("Small share   : <smallShare>");
    info("Average share : <averageShare>");
    info("Large share   : <largeShare>");
    
    if (smallShare <= 50 && averageShare <= 15 && largeShare <= 3) {
        return excellent();
    } else if (smallShare <= 50 && averageShare <= 20 && largeShare <= 5) {
        return good();
    } else if (smallShare <= 55 && averageShare <= 25 && largeShare <= 7) {
        return medium();
    } else if (smallShare <= 60 && averageShare <= 30 && largeShare <= 10) {
        return bad();
    } else {
        return poor();
    }
}

Rank rankDuplication(duplicatedLines) {
    real duplicateShare = percent(duplicatedLines, projectVolume);
    
    info("Duplication share: <duplicateShare>");
    
    if (duplicateShare <= 3) {
        return excellent();
    } else if (duplicateShare <= 5) {
        return good();
    } else if (duplicateShare <= 10) {
        return medium();
    } else if (duplicateShare <= 20) {
        return bad();
    } else {
        return poor();
    }
}

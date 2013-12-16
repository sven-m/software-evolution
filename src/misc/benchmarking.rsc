module misc::benchmarking

import Prelude;
import util::Benchmark;

import misc::verbose;

int startTime;
int stopTime;

public void startBench(str message) {
	info("Benchmarking: <message>... ");
	startTime = getMilliTime();
}


public void stopBench() = stopBench(0);
public void stopBench(int numOfItems) {
	stopTime = getMilliTime();
	
	summarize(numOfItems);
}

private void summarize(int numOfItems) {
	str summary;
	
	if (numOfItems > 0) {
		summary = " (<(duration() / 1.0) / numOfItems> ms/item)";
	} else {
		summary = "";
	}
	info("done in <duration()> ms <summary>");
}

public int duration() {
	return stopTime - startTime;
}
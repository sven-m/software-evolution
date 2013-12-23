module misc::progress

import Prelude;
import misc::verbose;

private int current;
private int stepSize;
private int totalSize;

private int getProgress() = totalSize > 0 ? totalSize - current : current;
private bool shouldPrint() = current % stepSize == 0;

public void initProgress(str message, int total, int step) {
    current = 0;
    totalSize = total;
    stepSize = step;
    
    info("\<START <message>\>");
}

public void progress() = progress("");
public void progress(str item) {
    if (shouldPrint()) {
        info("<getProgress()> left<if (item != "") {>: <item><} else {>.<}>");
    }
    current += 1;
}

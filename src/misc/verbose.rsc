module misc::verbose

import Prelude;

data VerboseLevel = debugLevel()
                        | infoLevel()
                        | silent()
                        ;

private VerboseLevel level = debugLevel();

map[VerboseLevel, str] prefix = (
    debugLevel() : "DEBUG",
    infoLevel() : "INFO",
    silent() : "SILENT"
);

public void info(str message) {
    if (level != silent()) {
        log(infoLevel(), message);
    }
}

public void debug(str message) {
    if (level == debugLevel()) {
        log(debugLevel(), message);
    }
}

private void log(VerboseLevel lvl, str message) {
    println("<prefix[lvl]>: <message>");
}

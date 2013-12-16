module misc::ranking

data Rank	= excellent()
				| good()
				| medium()
				| bad()
				| poor()
				;
			
public str rankToStr(excellent())	= "++";
public str rankToStr(good())			= "+";
public str rankToStr(medium())		= "o";
public str rankToStr(bad())			= "-";
public str rankToStr(poor())			= "--";

public real percent(int part, int whole) = part * 100.0 / whole;
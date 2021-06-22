--
-- 
--

dofile("common.inc");

function doit()
	askForWindow('Searches for and clicks Max button until stopped.\n \nGreat for filling grass hammocks, loading distaffs, dropping many itmes, etc quickly.\n \nNot so good for dividing straw amongst many camel pens.\n \nPress Shift over ATITD window to continue.');

	while 1 do
		checkBreak();
		srReadScreen();
		local max = srFindImage("max.png");
		if max then
			safeClick(max[0]+3,max[1]+3);
			sleepWithStatus(100, "Clicking Max button");
		else
			sleepWithStatus(100, "Searching for Max button");
		end
	end
end

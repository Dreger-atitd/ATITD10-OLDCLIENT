--
-- 
--

dofile("common.inc");

function doit()
	askForWindow('Tap ALT or CTRL over tub to steep in canvas.\n \nPress Shift over ATITD window to continue.');

    while 1 do
        local item = "Canvas";
		checkBreak();
		srReadScreen();
                statusScreen("Tap ALT or CTRL button over tub to steep item.");
	waitForKeypress(true);
        if lsAltHeld() then
            item = "Wool";
        else
            item = "Canvas";
        end
	local pos = makePoint(srMousePos());
	statusScreen("Release the Ctrl button.");
	waitForKeyrelease();
        lsSleep(50);
        safeClick(pos[0], pos[1]);
        lsSleep(50);
        srReadScreen();
        clickAllText("Steep", 20, 3);
        lsSleep(50);
        srReadScreen();
        clickAllText(item, 20, 3);
        lsSleep(50);
    end
end

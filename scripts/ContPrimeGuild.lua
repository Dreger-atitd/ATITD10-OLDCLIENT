dofile("ui_utils.inc");
dofile("settings.inc");
dofile("constants.inc");
dofile("screen_reader_common.inc");
dofile("common.inc");
dofile("serialize.inc");

function doit()
  askForWindow("Press Shift over ATITD window to continue.");
  srReadScreen();
  xyWindowSize = srGetWindowSize();
  while(true) do
    checkBreak();
    promptForThing();
    --clickOK();
    lsSleep(50);
  end
end



function promptForThing()
        statusScreen("Tap CTRL button over the thing to contribute to your primary guild.");
	waitForKeypress(true);
	local pos = makePoint(srMousePos());
	statusScreen("Release the Ctrl button.");
	waitForKeyrelease();
        lsSleep(50);
        safeClick(pos[0], pos[1], 1);
        lsSleep(50);
        srReadScreen();
        clickAllImages("ownership.png"); --clickAllText("Ownership", 20, 3);
        lsSleep(50);
        srReadScreen();
        clickAllImages("myPrimaryGuild.png"); --clickAllText("Primary", 20, 3);
        lsSleep(50);
        srReadScreen();
        clickAllImages("sureYes.png");
        lsSleep(50);
        srReadScreen();
        clickAllImages("ok.png");
end
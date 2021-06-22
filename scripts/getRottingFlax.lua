
dofile("common.inc");
dofile("settings.inc");

scriptCompleted = false;
screenCenter = {}

function doit()
    askForWindow('Getting Flax!');
    screenCenter = {srGetWindowSize()[0] * .5, srGetWindowSize()[1] * .5}
    runGetRotten();
end

function runGetRotten()
        while not scriptCompleted do
            lsSleep(75);
            checkBreak();
            getRotten()
        end
end


ESC_KEY = "\27"

function getRotten()
    srReadScreen();
    local rotten = findImage("rottingFlax.png");
    if rotten then
        srSetMousePos(screenCenter[0], screenCenter[1]);
        safeClick(rotten[0] + 5, rotten[1] + 3);
        lsSleep(75);
        checkBreak();
        srReadScreen();
        local getRotten = findImage("getRotten.png");
        if getRotten then
            safeClick(getRotten[0] + 5, getRotten[1] + 3);
        else
            srKeyEvent(ESC_KEY);
            scriptCompleted = true;
        end
     else
         scriptCompleted = true;
     end
end

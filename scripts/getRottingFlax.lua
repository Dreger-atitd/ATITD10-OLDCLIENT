
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
    lsSleep(75);
    checkBreak();
    srReadScreen();
    local rotten = srFindImageInRange("rottingFlax.png", 0, 80, srGetWindowSize()[0], srGetWindowSize()[1] - 80, 3000);
    if not rotten then
        return;
    end
    if rotten then
        srSetMousePos(screenCenter[1], screenCenter[2]);
        srClickMouseNoMove(rotten[0] + 5, rotten[1] + 5);
        lsSleep(75);
        
        srReadScreen();
        local getRotten = srFindImage("getRotten.png",4000);
        if getRotten then
            srClickMouseNoMove(getRotten[0] + 3, getRotten[1] + 3);
        else
            srKeyEvent(ESC_KEY);
            --scriptCompleted = true;
        end
     else
         scriptCompleted = true;
     end
end

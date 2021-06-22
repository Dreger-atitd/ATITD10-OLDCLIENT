dofile("common.inc");
dofile("settings.inc");


carving = {
    "knapChisel.png",
    "carveSharpened.png",
    "knapChisel.png",
    "carveWood.png",
    "knapChisel.png"
--    "carveChit.png",
--    "carveCrude.png",
--    "carvePeg.png",
--    "carvePestle.png",
--    "carveLeather.png"
}

carvingCurrent = 1


xyWindowSize = srGetWindowSize();

fpLocations = {}
firepitWindowLocations = {
    {1,1},
    {1,260},
    {1,520},
    {1,780},
    {1110,1},
    {1110,260},
    {1110,520},
    {1110,780}
}
FP_X = 1;
FP_Y = 2;
FP_W_X = 3;
FP_W_Y = 4;
FP_W_BOX = 5;
FP_STATUS = 6;
FP_UPD = 7;
FP_UNLIT_VAL = 8;
FP_LIT_MINVAL = 9;
FP_LIT_MAXVAL = 10;
FP_LIT_LASTMAXVAL = 11;
FP_ISPEAKING = 12;
FP_PEAKING_START = 13;
FP_STOKED = 14;
FP_STOKED_TIME = 15;
FP_PEAKING_STOP = 16;
FP_LIGHT_TIME = 17;
FP_STOKED_ENDTIME = 18;
FP_PEAKING_END = 19;

FP_STATUS_UNLIT = 0;
FP_STATUS_MERRILY = 1;
FP_STATUS_SMOULDERING = 2;
FP_STATUS_DONE = 3;

FP_UPD_UP = 0;
FP_UPD_PEAK = 1;
FP_UPD_DOWN = 2;

PIT_WINDOW_WIDTH = 341;
PIT_WINDOW_HEIGHT = 201;
THIS_PLACE_X = 105;
THIS_PLACE_Y = 13;


function doit()
        --srCaptureMode(0);
        local config = {};
        askForWindowAndSetupGlobals(config);
        runFirepits(config);
end

function askForWindowAndSetupGlobals(config)

    askForWindow(askText);
    fpLocations = windowManager("Firepit Setup", wmText, false, false, PIT_WINDOW_WIDTH, PIT_WINDOW_HEIGHT, math.floor(xyWindowSize[1] *.5), 10, 10, true, false, true);
    askForFocus();
    --setupGlobals(config);
end

function runFirepits(config)
        local completed = false;
        checkBreak();
        lsDoFrame();
        lsDoFrame();
        
        srReadScreen();
        lsSleep(tick_delay);
        for i = 1, #fpLocations do
            checkBreak();
            fpLocations[i][FP_W_X] = firepitWindowLocations[i][1];
            fpLocations[i][FP_W_Y] = firepitWindowLocations[i][2];
            fpLocations[i][FP_W_BOX] = {x = fpLocations[i][FP_W_X], y = fpLocations[i][FP_W_Y],
                                        width = 444, height = 255,
                                        left = fpLocations[i][FP_W_X], top = fpLocations[i][FP_W_Y],
                                        right = fpLocations[i][FP_W_X] + 444, bottom = fpLocations[i][FP_W_Y]+255}
            fpLocations[i][FP_STATUS] = FP_STATUS_UNLIT;
            fpLocations[i][FP_UPD] = FP_UPD_UP;
            fpLocations[i][FP_UNLIT_VAL] = srReadPixel(fpLocations[i][FP_X], fpLocations[i][FP_Y])
            fpLocations[i][FP_LIT_MINVAL] = 0;
            fpLocations[i][FP_LIT_MAXVAL] = fpLocations[i][FP_UNLIT_VAL];
            fpLocations[i][FP_LIT_LASTMAXVAL] = fpLocations[i][FP_UNLIT_VAL];
            fpLocations[i][FP_ISPEAKING] = false;
            fpLocations[i][FP_PEAKING_START] = 0;
            fpLocations[i][FP_STOKED] = false;
            fpLocations[i][FP_STOKED_TIME] = 0;
            fpLocations[i][FP_PEAKING_END] = lsGetTimer();
            fpLocations[i][FP_PEAKING_STOP] = 0;
            fpLocations[i][FP_LIGHT_TIME] = 0;
            fpLocations[i][FP_STOKED_ENDTIME] = 0;
            

            --lsPrintln("boxHeight: " .. fpLocations[i][FP_W_BOX].height)


            --local firepit = fpLocations[i];
            --local firepitWindow = {};
            --firepitWindow[0] = firepit[2];
            --firepitWindow[1] = firepit[3];
            --srSetMousePos(firepitWindow[0], firepitWindow[1]);
            --lsSleep(300);
            --srSetMousePos(firepit[0], firepit[1]);
            --lsSleep(300);
        end
     
        local allLit = false;
        local allDone = false;
        
        while not completed do
            --clickAllText("Place Wood");
            --clickAllText("Place Tinder");
            --if not allDone then
                local someUndone = false;
                local someUnlit = false;
                for i = 1, #fpLocations do
                
                    local firepit = fpLocations[i];
                    if not firepit[FP_STATUS] == FP_STATUS_DONE then
                        someUndone = true;
                    end
                    if firepit[FP_STATUS] == FP_STATUS_UNLIT then
                        someUnlit = true;
                        local pos = srFindImageInRange("placeWood.png", fpLocations[i][FP_W_BOX].x, fpLocations[i][FP_W_BOX].y,
                                            fpLocations[i][FP_W_BOX].width, fpLocations[i][FP_W_BOX].height);
                        if pos then safeClick(pos[0]+5, pos[1]+3); end
                        pos = srFindImageInRange("placeTinder.png", fpLocations[i][FP_W_BOX].x, fpLocations[i][FP_W_BOX].y,
                                            fpLocations[i][FP_W_BOX].width, fpLocations[i][FP_W_BOX].height);
                        if pos then safeClick(pos[0]+5, pos[1]+3); end
                        pos = srFindImageInRange("strikeFlint.png", fpLocations[i][FP_W_BOX].x, fpLocations[i][FP_W_BOX].y,
                                            fpLocations[i][FP_W_BOX].width, fpLocations[i][FP_W_BOX].height);
                        if pos then safeClick(pos[0]+5, pos[1]+3); end
                        
                        lsSleep(75);
                    end
                end
                if not someUndone then
                   allDone = true;
                end
                if not someUnlit then
                   allLit = true;
                end
                
            --else
            --    completed = true;
            --end
            
            local uiY = 12;
            for i = 1, #fpLocations do
                
                local firepit = fpLocations[i];
                
                safeClick(firepit[FP_W_X], firepit[FP_W_Y]);
                lsSleep(75);
                srReadScreen();
                local litValAndSurity = fpGetLitVal(firepit);
                local curColor = litValAndSurity[1];
                local curSurity = litValAndSurity[2];
                local surityFactor = litValAndSurity[3]
                local isPeaking = false;
                local isStoked = false;
                local notPeakingTime = 0;
                local peakingTime = 0;
                local stokedTime = 0;
                local stokedDoneTime = 0;
                local startedGoingUp = 0;
                local timeGoingUp = 0;

                --local fpWBounds = srGetWindowBorders(firepit[FP_W_X]+5, firepit[FP_W_Y]);

                local fpW_X = firepit[FP_W_X];
                local fpW_Y = firepit[FP_W_Y];
                local fpW_R = firepit[FP_W_BOX].right;
                local fpW_B = firepit[FP_W_BOX].bottom;
                local fpW_W = firepit[FP_W_BOX].width;
                local fpW_H = firepit[FP_W_BOX].height;
                --firepit[FP_W_BOX] = { 
                --                  x = fpW_X,
                --                  y = fpW_Y,
                --                  width = fpW_W,
                --                  height = fpW_H,
                --                  left = fpW_X,
                --                  top = fpW_Y,
                --                  right = fpW_R,
                --                  bottom = fpW_B
                --                };
                local merrily = srFindImageInRange("merrily.png", fpW_X, fpW_Y, fpW_W, fpW_H, 5000);
                local smouldering = srFindImageInRange("smouldering.png", fpW_X, fpW_Y, fpW_W, fpW_H, 5000);
                local stokeTheFire = srFindImageInRange("stokeFirepit.png", fpW_X, fpW_Y, fpW_W, fpW_H, 5000);



                local wasStatus = firepit[FP_STATUS];
                
                if (firepit[FP_STATUS] == FP_STATUS_SMOULDERING) and not smouldering then
                    firepit[FP_STATUS] = FP_STATUS_DONE;
                end
                if (firepit[FP_STATUS] == FP_STATUS_MERRILY) and smouldering then
                    firepit[FP_STATUS] = FP_STATUS_SMOULDERING;
                end
                if (firepit[FP_STATUS] == FP_STATUS_UNLIT) and merrily then
                    firepit[FP_STATUS] = FP_STATUS_MERRILY;
                end

                if firepit[FP_STATUS] == FP_STATUS_MERRILY and stokeTheFire then -- we're either on our way down or up
                    isStoked = false;
                    if firepit[FP_STOKED_ENDTIME] == 0 then
                        firepit[FP_STOKED_ENDTIME] = lsGetTimer();
                        firepit[FP_STOKED_TIME] = 0;
                    end
                    stokedDoneTime = lsGetTimer() - firepit[FP_STOKED_ENDTIME];
                end

                if firepit[FP_STATUS] == FP_STATUS_MERRILY and not stokeTheFire then
                    isStoked = true;
                    if firepit[FP_STOKED_TIME] == 0 then
                        firepit[FP_STOKED_TIME] = lsGetTimer();
                        firepit[FP_STOKED_ENDTIME] = 0;
                    end
                    stokedTime = lsGetTimer() - firepit[FP_STOKED_TIME];
                end

                
                if wasStatus == FP_STATUS_UNLIT and firepit[FP_STATUS] == FP_STATUS_MERRILY then -- just lit!
                    firepit[FP_LIGHT_TIME] = lsGetTimer();
                    startedGoingUp = lsGetTimer();
                    firepit[FP_UPD] = FP_UPD_UP; -- Going up
                end

                
                   

                if curColor == -1 and curSurity > 1 then -- max intensity
                    isPeaking = true;
                end

                


                if isPeaking then
                    if firepit[FP_PEAKING_START] == 0 then
                        firepit[FP_PEAKING_START] = lsGetTimer();
                        firepit[FP_PEAKING_STOP] = 0;
                    end
                    peakingTime = lsGetTimer() - firepit[FP_PEAKING_START];
                else
                    
                    if firepit[FP_PEAKING_STOP] == 0 then
                        firepit[FP_PEAKING_STOP] = lsGetTimer();
                        firepit[FP_PEAKING_START] = 0;
                    end
                    notPeakingTime = lsGetTimer() - firepit[FP_PEAKING_STOP];
                end

                if (not isStoked and
                      not firepit[FP_STOKED] and
                      not isPeaking and
                      firepit[FP_UPD] == FP_UPD_DOWN and
                      (stokedDoneTime > 3000 )) then
                    firepit[FP_UPD] = FP_UPD_UP;
                    startedGoingUp = lsGetTimer();
                elseif (not isStoked and
                          not firepit[FP_STOKED] and
                          firepit[FP_UPD] == FP_UPD_DOWN and
                          isPeaking and
                          (stokedDoneTime > 2000 and (curSurity > (surityFactor * .25)))) then
                    firepit[FP_UPD] = FP_UPD_UP;
                    startedGoingUp = lsGetTimer();
                end

                if (not isStoked and
                      firepit[FP_STOKED] and
                      not isPeaking and
                      firepit[FP_UPD] == FP_UPD_PEAK and
                      (notPeakingTime > 1000 or curSurity < (surityFactor * .25))) then
                    firepit[FP_UPD] = FP_UPD_DOWN;
                    firepit[FP_STOKED] = false;
                end

                if startedGoingUp then
                    timeGoingUp = lsGetTimer() - startedGoingUp;
                else
                    timeGoingUp = 0;
                end


                if (not isStoked and
                      isPeaking and
                      stokeTheFire and
                      not firepit[FP_STOKED] and
                      firepit[FP_UPD] == FP_UPD_UP and
                      timeGoingUp > 2000 and
                      (peakingTime > 1100 and curSurity > (surityFactor * .25))) then
                    firepit[FP_STOKED] = true;
                    safeClick(stokeTheFire[0] + 3, stokeTheFire[1] + 3);
                    firepit[FP_UPD] = FP_UPD_PEAK;
                    startedGoingUp = 0;
                end




--FP_X = 0;
--FP_Y = 1;
--FP_W_X = 2;
--FP_W_Y = 3;
--FP_W_BOX = 4;
--FP_STATUS = 5;
--FP_UPD = 6;
--FP_UNLIT_VAL = 7;
--FP_LIT_MINVAL = 8;
--FP_LIT_MAXVAL = 9;
--FP_LIT_LASTMAXVAL = 10;
--FP_ISPEAKING = 11;
--FP_PEAKING_START = 12;
--FP_STOKED = 13;
--FP_STOKED_TIME = 14;
--FP_PEAKING_STOP = 15;
--FP_LIGHT_TIME = 16;
--FP_STOKED_ENDTIME = 17;
--FP_PEAKING_END = 18;





 

                local stoked = "false";
                if isStoked then
                    stoked = "true";
                end

                local fpStoked = "false";
                if firepit[FP_STOKED] then
                    fpStoked = "true";
                end

                local peaking = "false";
                if isPeaking then
                    peaking = "true";
                end

                local upd = "";
                if     firepit[FP_UPD] == FP_UPD_UP   then upd = "up"
                elseif firepit[FP_UPD] == FP_UPD_PEAK then upd = "peak"
                elseif firepit[FP_UPD] == FP_UPD_DOWN then upd = "down"
                end

                local status = "";
                if     firepit[FP_STATUS] == FP_STATUS_UNLIT       then status = "unlit"
                elseif firepit[FP_STATUS] == FP_STATUS_MERRILY     then status = "merrily"
                elseif firepit[FP_STATUS] == FP_STATUS_SMOULDERING then status = "smoldering"
                elseif firepit[FP_STATUS] == FP_STATUS_DONE        then status = "done"
                end

                lsPrint(5, uiY, 10, .8, .8, 0x909090ff, "#: " .. i .. 
                        " Status: " .. status .. 
                        " UPD: " .. upd ..
                        
                        " isPeaking: " .. peaking .. 
                        " peakingTime: " .. peakingTime .. 
                        " notPeakingTime: " .. notPeakingTime);
                uiY = uiY + 20;

                lsPrint(5, uiY, 10, .8, .8, 0x909090ff, "#: " .. i ..
                        " stoked: " .. stoked .. 
                        " fpStoked: " .. fpStoked ..
                        " stokedTime: " .. stokedTime ..
                        " stokedDoneTime: " .. stokedDoneTime .. " curSurity: " .. curSurity .. " CurColor: " .. curColor);
                uiY = uiY + 24;

               checkBreak();
            end
            lsDoFrame();
            checkBreak();
            lsSleep(75);
            gatherLimestone();
            --doCarving();
        end
end
function closePopUp()
    while 1 do -- Perform a loop in case there are multiple pop-ups behind each other; this will close them all before continuing.
        checkBreak();
        srReadScreen();
        OK = srFindImage("OK.png");
        if OK then
            srClickMouseNoMove(OK[0]+2,OK[1]+2);
            lsSleep(75);
        else
            break;
        end
    end
end
-- Add some Limestone
-- Place Tinder
-- Place Wood
-- Remove Tinder
-- Remove Wood
-- Strike flint
-- This Firepit is burning merrily
-- This Firepit is smouldering out


function fpGetLitVal(firepit)
    local fpPoints = {};
    local surity = 0;
    local lastMax = -999999999;
    local surityFactor = 0;
    math.random(); math.random(); math.random(); math.random();
    fpPoints = {srReadPixel(firepit[FP_X], firepit[FP_Y]),
        srReadPixel(firepit[FP_X] + (math.random(6) - 3), firepit[FP_Y] + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 25, firepit[FP_Y] - 5),
        srReadPixel((firepit[FP_X] - 25) + (math.random(6) - 3), (firepit[FP_Y] - 5) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 8, firepit[FP_Y] + 28),
        srReadPixel((firepit[FP_X] - 8) + (math.random(6) - 3), (firepit[FP_Y] + 28) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 24, firepit[FP_Y] + 5),
        srReadPixel((firepit[FP_X] - 24) + (math.random(6) - 3), (firepit[FP_Y] + 5) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 15, firepit[FP_Y] + 30),
        srReadPixel((firepit[FP_X] - 15) + (math.random(6) - 3), (firepit[FP_Y] + 30) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 15, firepit[FP_Y] + 5),
        srReadPixel((firepit[FP_X] - 15) + (math.random(6) - 3), (firepit[FP_Y] + 5) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 20, firepit[FP_Y] + 10),
        srReadPixel((firepit[FP_X] - 20) + (math.random(6) - 3), (firepit[FP_Y] + 10) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 20, firepit[FP_Y] + 35),
        srReadPixel((firepit[FP_X] - 20) + (math.random(6) - 3), (firepit[FP_Y] + 35) + (math.random(6) - 3)),
        srReadPixel(firepit[FP_X] - 3, firepit[FP_Y] + 5),
        srReadPixel((firepit[FP_X] - 3) + (math.random(6) - 3), (firepit[FP_Y] + 5) + (math.random(6) - 3)),
        srReadPixel((firepit[FP_X]), firepit[FP_Y] + 30),
        srReadPixel((firepit[FP_X]) + (math.random(6) - 3), (firepit[FP_Y] + 30) + (math.random(6) - 3)),
        srReadPixel((firepit[FP_X] - 15), firepit[FP_Y] + 35),
        srReadPixel((firepit[FP_X] - 15) + (math.random(6) - 3), (firepit[FP_Y] + 35) + (math.random(6) - 3)),};
    for i = 1, #fpPoints do
        if not (fpPoints[i] < 0) then
            fpPoints[i] = -999999999;
        end
        if fpPoints[i] == -1 then
            surity = surity + 1;
        end
        lastMax = math.max(lastMax, fpPoints[i]);
    end
    
    
    return {lastMax, surity, #fpPoints};
end

function lightFirepits()
    local allLit = true;
    for i = 1, #fpLocations do
        local firepit = fpLocations[i];
        if firepit[FP_STATUS] == FP_STATUS_UNLIT then
            lsPrintln("fpHasBeenLit: " .. fpHasBeenLit(firepit) .. " Status: " .. firepit[FP_STATUS]);
        end
    end
    return allLit;
end

function fpHasBeenLit(firepit)
    if firepit[FP_STATUS] == FP_STATUS_UNLIT then
        local curColor = srReadPixel(firepit[FP_X], firepit[FP_Y]);
        if firepit[FP_UNLIT_VAL] == curColor then
            return false;
        end
        firepit[FP_STATUS] = FP_STATUS_MERRY;
    end
    return true;
end

function displayBox(box, forever, time)
    local start = lsGetTimer()
    --moveMouse(Vector:new { box.left, box.top })
    while forever or (time and (lsGetTimer() - start) < time) do
        srReadScreen()
        srMakeImage("box", box.left, box.top, box.width, box.height)
        srShowImageDebug("box", 0, current_y, 0, 1)
        checkBreak()
        if forever or time then
            lsDoFrame()
            lsSleep(10)
        else
            current_y = current_y + box.height
        end
    end
end

function getBrightness(box)
    currentBrightness = 0;
    for y = 0, 3 do
        for x = 0, 3 do
            --lsPrintln(box[x][y])
            local curColor = toColour(box[x][y]);
            if curColour and (curColour[3] > currentBrightness) then
                currentBrightness = curColour[3];
            end
        end
    end
end

function iterateBoxPixels(box, xy_func, y_func)
    srReadScreen()
    for y = 0, box.height, 1 do
        if y_func then y_func(y) end
        for x = 0, box.width do
            local pixel = srReadPixelFromBuffer(box.left + x, box.top + y)
            if xy_func(x, y, pixel) then
                return
            end
        end
        checkBreak()
    end
end

function getBoxPixels(box)
    local pixels = {}
    iterateBoxPixels(box,
        function(x, y, pixel)
            pixels[y][x] = pixel
        end,
        function(y)
            pixels[y] = {}
        end)
    return pixels
end

function toColour(pixelRGBA)
    local rgb = math.floor(pixelRGBA / 256)
    local red = (rgb >> 16) & 0xFF;
    local green = (rgb >> 8) & 0xFF;
    local blue = rgb & 0xFF;
    --  lsPrintln("White R=" .. red .. " G=" .. green .. " B=" .. blue)
    return { red, green, blue }
end



function gatherLimestone()
	timeStarted = lsGetTimer();
	--while 1 do
		checkBreak();
		srReadScreen();
		local slate = srFindImage("limestone.png",7000);
			if slate then
			srClickMouseNoMove(slate[0]+3,slate[1]+10,0);
			--sleepWithStatus(2300, "Clicking Limestone Icon\n\nLimestone Collected: " .. tostring(counter) .. "\n\n\nElapsed Time: " .. getElapsedTime(timeStarted));
			--counter = counter + 1;
			--else
			--sleepWithStatus(50, "Searching for Limestone Icon\n\nLimestone Collected: " .. tostring(counter) .. "\n\n\nElapsed Time: " .. getElapsedTime(timeStarted));
			end
			closePopUp()
	--end
end


function doCarving()
                    srReadScreen();
                    local focusMaxed = srFindImage("focusMax.png", 4000)
                    if not focusMaxed then
                        if carvingCurrent > #carving then
                            carvingCurrent = 1
                        end
                        local carveWhat = srFindImage(carving[carvingCurrent])
                        while not carveWhat and carvingCurrent < #carving do
                                carvingCurrent = carvingCurrent + 1
                                lsSleep(50);
                                carveWhat = srFindImage(carving[carvingCurrent])
                        end
                        if carveWhat then
                            safeClick(carveWhat[0] + 5, carveWhat[1] + 3)
                            lsSleep(250)
                            srReadScreen()
                            clickOK();
                            carvingCurrent = carvingCurrent + 1
                        else
                            carvingCurrent = carvingCurrent + 1
                        end
                    end
end

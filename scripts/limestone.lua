
dofile("common.inc");
dofile("settings.inc");


carving = {
--    "knapChisel.png",
--    "carveSharpened.png",
--    "knapChisel.png",
--    "carveWood.png",
--    "knapChisel.png",
    "slateShovel.png"
--    "carveChit.png",
--    "carveCrude.png",
--    "carvePeg.png",
--    "carvePestle.png",
--    "carveLeather.png"
}

carvingCurrent = 1

function doit()
    askForWindow('Gather Limestone!');
    runLimestone();
end

function runLimestone()
        local completed = false;
        while not completed do
            lsSleep(75);
            checkBreak();
            doCarving();
            gatherLimestone();
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
                            safeClick(carveWhat[0] + 5, carveWhat[1] + 3);
                            lsSleep(125);
                            srReadScreen();
                            carvingCurrent = carvingCurrent + 1
                        else
                            carvingCurrent = carvingCurrent + 1
                        end
                    end
                if srFindImage("chooseA.png") then
                    clickAllImages("knifeFlint.png");
                    clickAllImages("knifeStone.png");
                    clickOK();
                end
end

function gatherLimestone()
		checkBreak();
		srReadScreen();
		local slate = srFindImage("limestone.png",7000);
		if slate then
	           srClickMouseNoMove(slate[0]+3,slate[1]+10,0);
                   lsSleep(75);
                   closePopUp();
		end
end
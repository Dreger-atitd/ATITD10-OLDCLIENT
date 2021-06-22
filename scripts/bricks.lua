-- bricks.lua v1.0 -- Run and repair brick racks.
-- 
--

dofile("common.inc");
dofile("settings.inc");

brickList = {"Bricks", "Firebricks"};
rackList = {};
brickType = "b";
brick = 1;
function doit()
  promptParameters();
  askForWindow("You know the routine, hit SHIFT over the ATiTD window.");

  getBrickLocations();
  while (true) do
    checkBreak();
    for i = 1, #rackList do
      doBrick(rackList[i][1], rackList[i][2], "t");
      checkBreak();
    end
    for i = 1, #rackList do
      doBrick(rackList[i][1], rackList[i][2], "r");
      checkBreak();
    end
    for i = 1, #rackList do
      doBrick(rackList[i][1], rackList[i][2], brickType);
      checkBreak();
    end
    sleepWithStatus(
        50000,
        "Waiting for next round",
        nil,
        0.7
      )
  end
end


function promptParameters()

  scale = 1.1;

  local z = 0;
  local is_done = nil;
  -- Edit box and text display
  while not is_done do
    -- Make sure we don't lock up with no easy way to escape!
    checkBreak();

    local y = 5;

    lsSetCamera(0,0,lsScreenX*scale,lsScreenY*scale);

    lsPrint(10, y, 0, scale, scale, 0xd0d0d0ff, "Brick type:");
    brick = lsDropdown("brick", 120, y, 0, 180, brick, brickList);

    if brick == 1 then
        brickType = "b"
    elseif brick == 2 then
        brickType = "f"
    end


    if lsButtonText(10, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff, "OK") then
      is_done = 1;
    end

    if lsButtonText((lsScreenX - 100) * scale, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff,
      "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(100);
  end
end

function refreshWindows()
  srReadScreen();
  this = findAllText("This is");
  for i=1,#this do
    clickText(this[i]);
  end
  lsSleep(100);
end

function getCenterPos()
	xyWindowSize = srGetWindowSize();
	local ret = {};
	ret[0] = xyWindowSize[0] / 2;
	ret[1] = xyWindowSize[1] / 2;
	return ret;
end

function doBrick(mx, my, hotKey)
    srSetMousePos(mx, my);
    lsSleep(50);
    srKeyEvent(hotKey);
    lsSleep(75);
end


function cleanup()
  if(unpinWindows) then
    closeAllWindows();
  end
end

function closePopUp()
  while 1 do -- Perform a loop in case there are multiple pop-ups behind each other;
    checkBreak();
    srReadScreen();
    OK = srFindImage("OK.png");
    if OK then
      srClickMouseNoMove(OK[0]+2,OK[1]+2);
      lsSleep(100);
    else
      break;
    end
  end
end



function getBrickLocations()
    rackList = {};
    local was_shifted = lsShiftHeld();
    
    local is_done = false;
    mx = 0;
    my = 0;
    z = 0;
    while not is_done do
        mx, my = srMousePos();
        local is_shifted = lsShiftHeld();
        is_done = lsControlHeld();

        if is_shifted and not was_shifted then
            rackList[#rackList + 1] = {mx, my};
        end
        was_shifted = is_shifted;
        checkBreak();
        lsPrint(10, 10, z, 1.0, 1.0, 0xc0c0ffff,
            "Set brickrack locations.");
        local y = 60;
        lsPrint(10, y, z, 0.7, 0.7, 0xf0f0f0ff, "Lock ATITD screen (Alt+L)");
        y = y + 20;
        lsPrint(10, y, z, 0.7, 0.7, 0xf0f0f0ff, "Suggest F8F8F8 view.");
        y = y + 60;
        lsPrint(10, y, z, 0.7, 0.7, 0xc0c0ffff, "Hover and type SHIFT over all brick racks! Press CTRL when done");
        y = y + 70;
        lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "TIP (Optional):");
        y = y + 20;
        lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "For Maximum Performance (least lag) Uncheck:");
        y = y + 16;
        lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "Options, Interface, Other: 'Use Flyaway Messages'");
        
        if ButtonText(205, lsScreenY - 30, z, 110, 0xFFFFFFff,
            "End script") then
            error "Clicked End Script button";
        end
        lsDoFrame();
        lsSleep(10);
    end
end
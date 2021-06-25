-- common_window.inc
--
-- Common functions for handling windows: opening, arranging, unpinning
--
-- DO NOT INCLUDE THIS FILE! Include common.inc instead
--

TOP_LEFT = 0;
TOP_RIGHT = 1;
BOTTOM_LEFT = 2;
BOTTOM_RIGHT = 3;

doingFirepits = nil;
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

-------------------------------------------------------------------------------
-- stashWindow(sourceX, sourceY, corner, bounds)
--
-- Drags a window from a given location to a corner of the screen.
--
-- sourceX, sourceY -- location of anchor point to drag window
-- corner -- destination corner (TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT,
--           or BOTTOM_RIGHT)
-- bounds (optional) -- bounds of window
-------------------------------------------------------------------------------

local stashBit = 0;

function stashWindow(sourceX, sourceY, corner, bounds)
  if not sourceX or not sourceY or not corner then
    error("Incorrect number of arguments for stashWindow()");
  end
  --stashBit = (stashBit + 2) % 4;
  --if not bounds then
  --  srReadScreen();
  --  bounds = newGetWindowBorders(sourceX, sourceY);
  --end
  bounds = {};
  bounds[0] = sourceX;
  bounds[1] = sourceY;
  local size = {};
  size[0] = 10; --bounds[2] - bounds[0];
  size[1] = 10; --bounds[3] - bounds[1];
  local screen = srGetWindowSize();
  local dest = {};
  dest[0] = screen[0] - size[0] + (sourceX - bounds[0]) - 5;
  if corner == TOP_LEFT or corner == BOTTOM_LEFT then
    dest[0] = sourceX - bounds[0] + 5;
  end
  dest[1] = screen[1] - size[1] + (sourceY - bounds[1]) - stashBit - 5;
  if corner == TOP_LEFT or corner == TOP_RIGHT then
    dest[1] = sourceY - bounds[1] + stashBit + 5;
  end
  safeDrag(sourceX, sourceY, dest[0], dest[1]);
  srSetMousePos(sourceX, sourceY);
  lsSleep(click_delay);
  return dest;
end

function distance( x1, y1, x2, y2 )
  local dx = x1 - x2;
  local dy = y1 - y2;
  return math.sqrt ( dx * dx + dy * dy );
end

function getChatWindowBorders(sourceX, sourceY)
    local screen = srGetWindowSize();
    local nearestImage = {};
    local nearestDistance = 999999999;
    local imagesInRange = {};
    local brcWidth = srImageSize("ocr/BRChatWindowCorner.png")[0];
    local brcHeight = srImageSize("ocr/BRChatWindowCorner.png")[1];
    local tlcWidth = srImageSize("ocr/TLChatWindowCorner.png")[0];
    local tlcHeight = srImageSize("ocr/TLChatWindowCorner.png")[1];


    imagesInRange = findAllImagesInRange("ocr/BRChatWindowCorner.png", sourceX, sourceY, screen[0]-sourceX, screen[1]-sourceY, 3500);
    --lsPrintln("-" .. inspectit.inspect(imagesInRange));
    if not imagesInRange[1] then
        imagesInRange = findAllImagesInRange("ocr/BRChatWindowCornerOr.png", sourceX, sourceY, screen[0]-sourceX, screen[1]-sourceY, 3500);
        brcWidth = srImageSize("ocr/BRChatWindowCornerOr.png")[0];
        brcHeight = srImageSize("ocr/BRChatWindowCornerOr.png")[1];
        --lsPrintln("--" .. inspectit.inspect(imagesInRange));
    end

    
    if not imagesInRange[1] then return nil; end;

    for i = 1, #imagesInRange do
        local testDistance = distance(sourceX, sourceY, imagesInRange[i][0], imagesInRange[i][1]);
        if testDistance < nearestDistance then
            nearestImage = imagesInRange[i];
            nearestDistance = testDistance;
        end
    end
    
    local brWinCorner = nearestImage;
    if not brWinCorner then return nil; end;

    nearestDistance = 999999999;
    local imagesInRange = findAllImagesInRange("ocr/TLChatWindowCorner.png", 0, 0, brWinCorner[0]+brcWidth, brWinCorner[1]+brcHeight, 3500);
    --lsPrintln("---" .. inspectit.inspect(imagesInRange));
    if not imagesInRange[1] then return false; end;

    for i = 1, #imagesInRange do
        local testDistance = distance(brWinCorner[0], brWinCorner[0], imagesInRange[i][0], imagesInRange[i][1]);
        if testDistance < nearestDistance then
            nearestImage = imagesInRange[i];
            nearestDistance = testDistance;
        end
    end
    
    
    local tlWinCorner = nearestImage;
    if not tlWinCorner then return nil; end;
    
    --if (sourceX < tlWinCorner[0] or sourceY < tlWinCorner[1]) or 
    --   (sourceX > brWinCorner[0]+brcWidth or sourceY > brWinCorner[1]+brcHeight) then
    --     return false;
    --end

    local bounds = {};
    bounds[0] = tlWinCorner[0]+tlcWidth-(tlcWidth * .5);
    bounds[2] = brWinCorner[0]+brcWidth-(brcWidth * .5);
    bounds[1] = tlWinCorner[1]+tlcHeight-(tlcHeight * .5);
    bounds[3] = brWinCorner[1]+brcHeight-(brcHeight * .5);
    local region = {};
          region = { [0] = bounds[0], [1] = bounds[1], [2] = bounds[2], [3] = bounds[3], 
                  x = bounds[0], y = bounds[1], right = bounds[2], bottom = bounds[3],
                  top = bounds[1], left = bounds[0], width = bounds[2] - bounds[0],
                  height = bounds[3] - bounds[1] };
    lsPrintln(inspectit.inspect(region));
    return region;
end



function newGetWindowBorders(sourceX, sourceY)
    --if nil then
    --    return srGetWindowBorders(sourceX, sourceY);
    --end
    local screen = srGetWindowSize();
    local nearestImage = {};
    local nearestDistance = 999999999;
    local imagesInRange = {};
    local brcWidth = srImageSize("BRWindowCorner.png")[0];
    local brcHeight = srImageSize("BRWindowCorner.png")[1];
    local tlcWidth = srImageSize("TLWindowCorner.png")[0];
    local tlcHeight = srImageSize("TLWindowCorner.png")[1];
    local firstX = sourceX - brcWidth;
    local firstY = sourceY - brcHeight;
    if firstX < 0 then firstX = 0; end;
    if firstY < 0 then firstY = 0; end;
    imagesInRange = findAllImagesInRange("BRWindowCorner.png", firstX, firstY, screen[0]-firstX, screen[1]-firstY, 600);

    if not imagesInRange then return nil; end;
    --lsPrintln("Images in range #1");
    for i = 1, #imagesInRange do
        local testDistance = distance(sourceX, sourceY, imagesInRange[i][0], imagesInRange[i][1]);
        if testDistance < nearestDistance then
            nearestImage = imagesInRange[i];
            nearestDistance = testDistance;
        end
    end

    local brWinCorner = nearestImage;
    if not brWinCorner[0] then return nil; end;
    --lsPrintln("Past not BRCorner2");
    --lsPrintln(inspectit.inspect(brWinCorner));
    nearestDistance = 999999999;
    local imagesInRange = findAllImagesInRange("TLWindowCorner.png", 0, 0, brWinCorner[0]+brcWidth, brWinCorner[1]+brcHeight, 600);
    if not imagesInRange then return false; end;
    --lsPrintln("Images in range #2");
    for i = 1, #imagesInRange do
        local testDistance = distance(brWinCorner[0], brWinCorner[0], imagesInRange[i][0], imagesInRange[i][1]);
        if testDistance < nearestDistance then
            nearestImage = imagesInRange[i];
            nearestDistance = testDistance;
        end
    end
    
    
    local tlWinCorner = nearestImage;
    if not tlWinCorner then return nil; end;
    --lsPrintln("Past not TLCorner2");
    
    if (sourceX < tlWinCorner[0] or sourceY < tlWinCorner[1]) or 
       (sourceX > brWinCorner[0]+brcWidth or sourceY > brWinCorner[1]+brcHeight) then
         return false;
    end
    
    local bounds = {};
    bounds[0] = tlWinCorner[0]+1;
    bounds[2] = brWinCorner[0]+brcWidth-1;
    bounds[1] = tlWinCorner[1]+1;
    bounds[3] = brWinCorner[1]+brcHeight-1;
    local region = {};
          region = { [0] = bounds[0], [1] = bounds[1], [2] = bounds[2], [3] = bounds[3], 
                  x = bounds[0], y = bounds[1], right = bounds[2], bottom = bounds[3],
                  top = bounds[1], left = bounds[0], width = bounds[2] - bounds[0],
                  height = bounds[3] - bounds[1] };
    --lsPrintln(inspectit.inspect(region));

    return region;
end

function getTLWindowCorner()--sourceX, sourceY)
    --local tlcImgSize = srImageSize("TLWindowCorner.png", 4000);
    local screen = srGetWindowSize();
    local tlRange = makeBox(screen[0]-500, screen[1]-300, 500, 300);
    local tlCorners = findAllImages("TLWindowCorner.png", tlRange);
    local tlCorner = tlCorners[#tlCorners];
    return {tlCorner[0]+1, tlCorner[1]+1};
end







-------------------------------------------------------------------------------
-- stashAllWindows(corner)
--
-- Move all windows not in the same quadrant as corner into the given
-- corner.  Use this twice on different corners to make sure that you
-- grab all windows.
--
-- corner -- Destination corner
-------------------------------------------------------------------------------

function stashAllWindows(corner)
  if not corner then
    error("Incorrect number of arguments for stashAllWindows()");
  end
  local top = (corner == TOP_LEFT or corner == TOP_RIGHT);
  local left = (corner == TOP_LEFT or corner == BOTTOM_LEFT);
  local screen = srGetWindowSize();
  local done = false;
  local stashes = {};
  srReadScreen();
  local anchors = findAllImages("ThisIs.png");
  while not done do
    done = true;
    for i=1,#anchors do
      if not wasStashed(anchors[i], stashes) then
        safeClick(anchors[i][0], anchors[i][1]);
        lsSleep(click_delay);
        local lastPos = stashWindow(anchors[i][0], anchors[i][1], corner);
        stashes[#stashes + 1] = lastPos;
        done = false;
      end
    end
    lsSleep(tick_delay);
    srReadScreen();
    anchors = findAllImages("ThisIs.png");
    statusScreen("Stashing Windows");
  end
end

function wasStashed(pos, stashes)
  local result = false;
  for i=1,#stashes do
    local diffX = math.abs(stashes[i][0] - pos[0]);
    local diffY = math.abs(stashes[i][1] - pos[1]);
    if diffX < 20 and diffY < 20 then
      result = true;
      break;
    end
  end
  return result;
end

-------------------------------------------------------------------------------
-- openAndPin(x, y, timeout)
--
-- Click at the given position to open a window, then pin that window.
--
-- x, y -- position to click
-- timeout -- time to wait before giving up
--
-- Returns true on success.
-------------------------------------------------------------------------------

function openAndPin(x, y, timeout)
  if not x or not y or not timeout then
    error("Incorrect number of arguments for openAndPin()");
  end
  local success = false;
  srReadScreen();
  local anchors = findAllImages("ThisIs.png");
  local startTime = lsGetTimer();
  safeBegin();
  srSetMousePos(x, y);
  lsSleep(50);
  srClickMouse(x, y, 0);
  lsSleep(50);
  srClickMouse(x+1, y+1, 1);
  lsDoFrame();
  statusScreen("Clicking to open window");
  local done = false;
  local anchor = nil;
  while not done do
    checkBreak();
    srReadScreen();
    local newAnchors = findAllImages("ThisIs.png");
    done = false;
    local limit = math.min(#anchors, #newAnchors);
    for i=1,limit do
      if anchors[i][0] ~= newAnchors[i][0]
        or anchors[i][1] ~= newAnchors[i][1]
      then
        anchor = newAnchors[i];
        done = true;
        break;
      end
    end
    if not done and #anchors ~= #newAnchors then
      done = true;
      anchor = newAnchors[#newAnchors];
    end
    if not done and lsGetTimer() > startTime + timeout then
      done = true;
    end
    anchors = newAnchors;
    statusScreen("Waiting for window to open");
    lsSleep(tick_delay);
  end
  if anchor then
    success = true;
    if not findImageInWindow("UnPin.png", x+5, y) then
      safeClick(anchor[0], anchor[1], 0);
      statusScreen("Pinning window");
    end
  end
  return success;
end

-------------------------------------------------------------------------------
-- arrangeInGrid(cascade, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight)
--
-- Arrange all open windows into a grid on the screen. Stashes them first.
--
-- cascade (optional) -- arrange windows into an overlapping cascade
-- waterGap (optional) -- leave a gap at the top for getting water
-- varWidth, varHeight (optional) -- specify window width/height - instead of detecting.
-- sizeRight (optional) -- amount of space to right of screen, defaults to automato width
-- offsetWidth (optional) -- adds an additional width offset
-- offsetHeight (optional) -- adds an additional height offset

-------------------------------------------------------------------------------

function arrangeInGrid(cascade, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight)
  stashAllWindows(BOTTOM_LEFT);
  stashAllWindows(BOTTOM_RIGHT);
  arrangeStashed(cascade, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight);
end



function arrangeFPGrid(fpCount)
  --local screen = srGetWindowSize();
  --local bottomRightX = screen[0] - 200;
  --local bottomRightY = screen[1] - 100;
  for i = fpCount, 1, -1 do
    lsSleep(click_delay);
    srReadScreen();
    local fpWin = getTLWindowCorner(); --bottomRightX, bottomRightY);
    safeDrag(fpWin[1], fpWin[2], firepitWindowLocations[i][1], firepitWindowLocations[i][2]);
  end
end
-------------------------------------------------------------------------------
-- arrangeStashed(cascade, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight)
--
-- Arrange all open windows into a grid on the screen. Assumes they
-- are pre-stashed.
--
-- cascade (optional) -- arrange windows into a overlapping cascade
-- waterGap (optional) -- leave a 50px gap at the top (for water or similar)
-- varWidth (optional) -- width of windows, if not set width will be initial window width
-- varHeight (optional) --  height of windows, if not set height will be initial window height
-- sizeRight (optional) -- amount of space to right of screen, defaults to automato width
-- offsetWidth (optional) -- adds an additional width offset
-- offsetHeight (optional) -- adds an additional height offset

-------------------------------------------------------------------------------

function arrangeStashed(cascade, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight)
  local screen = srGetWindowSize();
  local bottomRightX = screen[0] - 401;
  local bottomRightY = screen[1] - 301;
  local cascadepl = "true";
  local waterGappl = "true"
  if not cascade then cascadepl = "false"; end
  if not waterGappl then waterGappl = "false"; end
  --lsPrintln("arrangeStashed - cascade: " .. cascadepl .. " waterGap: " .. waterGappl .. " varWidth: " .. varWidth .. " varHeight: " .. varHeight .. " offsetWidth: " .. offsetWidth .. " offsetHeight: " .. offsetHeight);


 if sizeRight then
         screen[0] = screen[0] - sizeRight;
 else
        screen[0] = screen[0] - 100; --srGetWindowSize()[0];
 end

  local currentX = 0;
  local currentY = 0;
  if waterGap then
    currentY = 95;
  end
  local lastX = 0;
  local lastY = 0;
  local xMax = 0;
  local yMax = 0;
  local counter = 0;
  
  srReadScreen();
  local window = srFindImageInRange("ThisIs.png", bottomRightX, bottomRightY,  400, 300, 7000); --srFindImageInRange("ThisIs.png", bottomRightX, bottomRightY);
  while window and (window[0] > lastX or window[1] > lastY) do
    counter = counter + 1
    safeClick(window[0], window[1]);
    lsSleep(80);
    srReadScreen();
    local bounds = nil;
    local freshWindow = srFindImageInRange("ThisIs.png", bottomRightX, bottomRightY,  400, 300, 7000);
    if freshWindow then
        bounds = newGetWindowBorders(freshWindow[0], freshWindow[1]);
        if not bounds then
            bounds = newGetWindowBorders(window[0], window[1]);
        end
    else
        bounds = newGetWindowBorders(window[0], window[1]);
    end
    if bounds then
      local width, height;
      if not varWidth then
        width = bounds[2] - bounds[0] + 7; -- The +7 offset is due to bigger borders in T9. Prevent touching/overlapping.
      else
        width = varWidth;
      end
      if not varHeight then
        height = bounds[3] - bounds[1] + 14; -- The +14 offset is due to bigger borders in T9. Prevent touching/overlapping.
      else
        height = varHeight;
      end
      if offsetWidth then
       width = width + offsetWidth;
      end
      if offsetHeight then
       height = height + offsetHeight;
      end

      if cascade then
        if currentY + height >= screen[1] then
          currentX = currentX + xMax;
          currentY = 0;
          xMax = 0;
        end
        if currentX + width >= screen[0] then
          error("Cannot arrange these windows into a cascade.");
        end
      else
        if currentX + width >= screen[0] then
          currentX = 0;
          currentY = currentY + yMax;
          yMax = 0;
        end
        if currentY + height >= screen[1] then
          error("Cannot arrange these windows into a grid.");
        end
      end
      lastX = window[0] - bounds[0] + currentX;
      lastY = window[1] - bounds[1] + currentY;
      safeDrag(window[0], window[1], lastX, lastY);
      if cascade then
        currentX = currentX + 8;
        currentY = currentY + 25;

        -- This fixes a bug and I'm not sure why it does this.
        -- The 2nd window on a cascade paritally covers This Is on first window. Left border is touching on Window 1 and 2.
        if counter == 1 then
          currentX = currentX + 4 -- Add an additional 4 on currentX and Y on 2nd window
          currentY = currentY + 4
        end

      else
        currentX = currentX + width + 5;
      end
      xMax = math.max(xMax, width);
      yMax = math.max(yMax, height);
      lsSleep(tick_delay);
      srReadScreen();
      window = srFindImageInRange("ThisIs.png", bottomRightX, bottomRightY,  400, 300, 7000);
      statusScreen("Arranging Windows " .. counter);
    else
      lsSleep(tick_delay);
      srReadScreen();
      window = srFindImageInRange("ThisIs.png", bottomRightX, bottomRightY,  400, 300, 7000);
      statusScreen("Arranging Windows " .. counter);
    end
  end
end

-------------------------------------------------------------------------------
-- closeAllWindows(x, y, width, height)
--
-- Close all open windows.
--
-- x, y (optional) -- origin of box to search
-- width, height (optional) -- size of box to search
-------------------------------------------------------------------------------

function closeAllWindows(x, y, width, height)
  if not x then
    x = 0;
  end
  if not y then
    y = 0;
  end
  if not width then
    width = srGetWindowSize()[0];
  end
  if not height then
    height = srGetWindowSize()[1];
  end

  local closeImages = {"deadPinned.png", "deadPinnedRed.png", "unpinned.png", "pinned.png"};
  local closeRight = {1, 1, 0, 0};

  local found = true;
  while found do
    found = false;
    for i=1,#closeImages do
      local image = closeImages[i];
      local right = closeRight[i];
      srReadScreen();
      local images = findAllImagesInRange(image, x, y, width, height);
      while #images >= 1 do
        done = true;
        safeClick(images[#images][0]+3, images[#images][1]+3, right);
        sleepWithStatus(10, "Please wait ...", nil, nil, "Closing Windows");
        srReadScreen();
        images = findAllImagesInRange(image, x, y, width, height);
      end
    end
  end
end

-------------------------------------------------------------------------------
-- closeEmptyRegions()
--
-- Closes all empty windows on the screen
--
-------------------------------------------------------------------------------

function closeEmptyRegions()
  allRegs = findAllTextRegions();
  if allRegs then
    for i = 1, #allRegs do
      local p = parseRegion(allRegs[i]);
      if p == nil then
        unpinRegion(allRegs[i]);
      end
    end
  end
end

-------------------------------------------------------------------------------
-- windowManager(title, message, allowCascade, allowWaterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight, default_focus, default_waterGap)
--
-- Run a window manager interface to let the user open, pin, arrange,
-- or clear windows.
--
-- title (optional) -- title of window
-- message (optional) -- extra instructions for the user
-- allowCascade (optional) -- allow the user to arrange in a cascade
-- allowWaterGap (optional) -- allow the user to add a water gap
-- varWidth, varHeight (optional) -- specify window width/height - instead of detecting
-- sizeRight (optional) -- amount of space to right of screen, defaults to automato width
-- offsetWidth (optional) -- adds an additional width offset
-- offsetHeight (optional) -- adds an additional height offset
-- default_focus (optional) -- bool: force 'Pause for Focus' box to be checked
-- default_waterGap (optional) -- bool: force 'Leave Gap for Water' box to be checked

-------------------------------------------------------------------------------

pauseForFocus = false;

function windowManager(title, message, allowCascade, allowWaterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight, default_focus, default_waterGap, doFirepit)
  doingFirepits = doFirepit;
  if doingFirepits then allowCascade = nil; end
  if doingFirepits then
    message = "Tap ALT over proper location of each fire pit in order to open, pin, and stash. Then use arrange!";
  end
  if not title then
    title = "Window Manager";
  end
  if not message then
    message = "Tap Ctrl to open and pin a window.\nTap Alt to open, pin and stash."
  end
  local waterGap = false;
  if default_waterGap then
    waterGap = true;
  end

  if default_focus then
    pauseForFocus = true;
  end
  local firepitLocations = {};
  local shift = false;
  local done = false;
  while not done do
    local y = 10;
    lsPrint(10, y, 0, 1.0, 1.0, 0xFFFFFFff, title);
    y = y + 50;

    if lsButtonText(30, y, 0, 250, 0x80D080ff, "Form Grid") then
      lsDoFrame();
      if pauseForFocus then
        askForWindow(focusMessage);
      end
      if not doingFirepits then
          arrangeInGrid(false, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight);
      else
          arrangeFPGrid(#fpLocations);
      end
    end
    y = y + 30;

    if allowCascade then
      if lsButtonText(30, y, 0, 250, 0x80D080ff, "Form Cascade") then
        lsDoFrame();
        if pauseForFocus then
          askForWindow(focusMessage);
        end
        arrangeInGrid(true, waterGap, varWidth, varHeight, sizeRight, offsetWidth, offsetHeight);
      end
      y = y + 30;
    end

    if lsButtonText(30, y, 0, 250, 0x80D080ff, "Stash Windows (Right)") then
      lsDoFrame();
      if pauseForFocus then
        askForWindow(focusMessage);
      end
      stashAllWindows(BOTTOM_RIGHT);
    end
    y = y + 30;

    if lsButtonText(30, y, 0, 250, 0x80D080ff, "Stash Windows (Left)") then
      lsDoFrame();
      if pauseForFocus then
        askForWindow(focusMessage);
      end
      stashAllWindows(BOTTOM_LEFT);
    end
    y = y + 30;

    if lsButtonText(30, y, 0, 250, 0x80D080ff, "Un-Pin Windows") then
      lsDoFrame();
      if pauseForFocus then
        askForWindow(focusMessage);
      end
      closeAllWindows();
    end
    y = y + 40;

    pauseForFocus = CheckBox(30, y, 10, 0xffffffff, " Pause for Focus",
                            pauseForFocus);
    if allowWaterGap then
      y = y + 20;
      waterGap = CheckBox(30, y, 10, 0xffffffff, " Leave Gap for Water",
                            waterGap);
    end
      y = y + 30;

    lsPrintWrapped(10, y, 0, lsScreenY - 20, 0.7, 0.7, 0xd0d0d0ff,
                   message);
    if lsButtonText(lsScreenX - 110, lsScreenY - 30, 0, 100,
                    0xffffffff, "End Script") then
      error(quit_message);
    end
    while lsControlHeld() do
      checkBreak();
      shift = true;
    end
    if shift then
      shift = false;
      local x = 0;
      local y = 0;
      x, y = srMousePos();
      openAndPin(x, y, 500);
    end
    while lsAltHeld() do
      checkBreak();
      shift = true;
    end
    
    if shift then
      shift = false;
      local x = 0;
      local y = 0;
      x, y = srMousePos();
      if doFirepit then
          local fpPos = {x, y};
          fpLocations[#fpLocations+1] = fpPos;
      end
      openAndPin(x+2, y+2, 500);
      --if not doFirepit then
          stashWindow(x+2, y+2, BOTTOM_RIGHT);
      --end;
    end
    if lsButtonText(10, lsScreenY - 30, 0, 100, 0xFFFFFFff, "Done") then
      done = true;
    end
    checkBreak();
    lsDoFrame();
    lsSleep(tick_delay);
  end
  if doingFirepits then return fpLocations; end;
end

-------------------------------------------------------------------------------
-- unpinManager(title, message)
--
-- Interface to help the user clear away all windows when a macro completes.
--
-- title (optional)  -- title of window
-- message (optional) -- extra instructions for the user
-------------------------------------------------------------------------------

function unpinManager(title, message)
  if not title then
    title = "Unpin Manager";
  end
  if not message then
    message = "";
  end
  while lsShiftHeld() and lsControlHeld() do
    lsPrintWrapped(10, 80, 0, lsScreenX - 20, 0.8, 0.8, 0x808080ff,
                  "Please release Ctrl+Shift");
    lsSleep(tick_delay);
    lsDoFrame();
  end
  local done = false;
  while not done do
    lsPrint(10, 10, 0, 1.0, 1.0, 0xFFFFFFff, title);
    lsPrintWrapped(10, 60, 0, lsScreenX - 20, 0.7, 0.7,
                   0xd0d0d0ff, message);
    if lsButtonText(30, 160, 0, 250, 0x80D080ff, "Un-Pin Windows") then
      lsDoFrame();
      if pauseForFocus then
        askForWindow(focusMessage);
      end
      closeAllWindows();
    end
    if lsButtonText(lsScreenX - 110, lsScreenY - 30, 0, 100,
                    0xffffffff, "Done") then
      done = true;
    end
    if lsShiftHeld() and lsControlHeld() then
      done = true;
    end
    lsDoFrame();
    lsSleep(tick_delay);
  end
end

-------------------------------------------------------------------------------
-- unpinRegion(region)
--
-- Unpins a region
--
-- region - region object to unpin
-------------------------------------------------------------------------------

function unpinRegion(region)
  if region then
    lsPrintln("Unpinning at: " .. region[0] + region[2] - 15 .. ", " .. region[1] + region[3] + 15);
    safeClick(region[0] + region[2] - 15, region[1] + 15, 0);
  end
end

-------------------------------------------------------------------------------
-- unpinOnExit(f)
--
-- Execute function f and present an unpin manager window when it
-- completes or if an error is thrown.
--
-- f -- function to execute with no arguments
-------------------------------------------------------------------------------

function unpinOnExit(f)
  if not f then
    error("Incorrect number of arguments for f");
  end
  local status, error = pcall(f);
  unpinManager("Complete", error);
end

-------------------------------------------------------------------------------
-- closeEmptyAndErrorWindows()
--
-- Closes all empty windows and error windows on the screen
--
-------------------------------------------------------------------------------

function closeEmptyAndErrorWindows()
  local windows = findAllWindows();
  local closed = 0;
  if windows then
    for i = 1, #windows do
      temp = makeBox(windows[i].x + 7, windows[i].y + 4,
          windows[i].width -35, windows[i].height - 7);
      p = parseWindow(temp);

      if #p == 0 then
        unpinWindow(windows[i]);
        closed = closed + 1;
      end
    end
  end
  return closed;
end

-------------------------------------------------------------------------------
-- unpinWindow(window)
--
-- Unpins a window
--
-- window - window object to unpin
-------------------------------------------------------------------------------

function unpinWindow(window)
  if window then
    safeClick(window.x + window.width - 15, window.y + 15, 0);
  end
end

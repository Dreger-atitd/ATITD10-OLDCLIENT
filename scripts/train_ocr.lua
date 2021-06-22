-- Console will output last character in each line (when training).
-- Also check https://www.atitd.org/wiki/tale6/User:Skyfeather/VT_OCR for more info on OCR

dofile("common.inc");
dofile("settings.inc");

offsetX = 102;
offsetY = 72;

function doit()
  askForWindow("Train OCR\n\nType a single letter/number in main chat.\n\nUse offsetX/Y to get the white box to surround this letter/number. Tip: You can also resize Main Chat to move into the white box. Top&Left of white box should border the letter/number. \n\nThen check Train button to show the code (in Console).\n\nThis macro is looking for your main chat window and the last letter/number you typed...\n\nOnce you find the values in Console, copy that to automato/games/ATITD9//data/charTemplate.txt file.");
  while true do
    findStuff();
  end
end

dyn_offset_key = 1;

function findStuff()
  checkBreak();

  local y = 0;
  local scale = 0.9;
  local newText = "";
  local padX = 0;
  local padY = 0;
  dyn_offset_key = readSetting("dyn_offset_key", dyn_offset_key);

  srReadScreen();

  --use this region for training windows
  --local regions = findAllTextRegions();
  --regions = regions[1];

  --use this region and colors for training chat
  local regions = findChatRegionReplacement();
  --local chatBox = makeBox(regions[0],regions[1], lsScreenX, lsScreenY);

  --srSetWindowInvertColorRange(0x1e2e31, 0x263539);
  srSetWindowInvertColorRange(0xFEFEFE, 0xFFFFFF); --E6D1AA);
  srSetWindowBackgroundColorRange(0xE6D1AA,0xFFFFFF);

  --sleepWithStatus(5000, regions[0] .. ", " .. regions[1] .. ", " .. regions[2] .. ", " .. regions[3]);

  local triggerPad = false;
  --lsDisplaySystemSprite(1, 180, lsScreenY - 160, 0, 50, 50, 0x0000FFFF);
  --lsDisplaySystemSprite(1, 180+12, lsScreenY - (160+12), 0, 25, 25, 0xFF0000FF);
  srShowImageDebug("XYPadnew.png", 180, lsScreenY - 160, 0, 1);
  
  local moveCursor = lsMouseClick(180, lsScreenY - 160, 50, 50, 1);
  if moveCursor then
     --lsPrintln(inspectit.inspect(moveCursor));
     padX = moveCursor[0] - 180;
     padY = moveCursor[1] - (lsScreenY - 160);
     triggerPad = true;
  else
     triggerPad = false;
  end
  if triggerPad then
    offsetX = readSetting("offsetX",offsetX);
    offsetY = readSetting("offsetY",offsetY);
    if padX < 20 then offsetX = offsetX - 1; end;
    if padX < 13 then offsetX = offsetX - 9; end;
    if padY < 20 then offsetY = offsetY - 1; end;
    if padY < 13 then offsetY = offsetY - 9; end;
    if padX > 30 then offsetX = offsetX + 1; end;
    if padX > 38 then offsetX = offsetX + 9; end;
    if padY > 30 then offsetY = offsetY + 1; end;
    if padY > 38 then offsetY = offsetY + 9; end;
    --lsPrintln("padX: " .. padX .. " padY: " .. padY);
    writeSetting("offsetX",offsetX);
    writeSetting("offsetY",offsetY);
    dyn_offset_key = dyn_offset_key + 1;
    writeSetting("dyn_offset_key", dyn_offset_key);
  end

  lsPrint(10, lsScreenY - 160, z, scale, scale, 0xFFFFFFff, "offsetX:");

  offsetX = readSetting("offsetX",offsetX);
  foo, offsetX = lsEditBox("offsetX"..dyn_offset_key, 80, lsScreenY - 160, 0, 50, 30, 1.0, 1.0, 0x000000ff, offsetX);
  offsetX = tonumber(offsetX);
  if not offsetX then
    lsPrint(140, lsScreenY - 160+3, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    offsetX = 0;
  end
  
  writeSetting("offsetX",offsetX);

  lsPrint(10, lsScreenY - 130, z, scale, scale, 0xFFFFFFff, "offsetY:");

  offsetY = readSetting("offsetY",offsetY);
  foo, offsetY = lsEditBox("offsetY"..dyn_offset_key, 80, lsScreenY - 130, 0, 50, 30, 1.0, 1.0, 0x000000ff, offsetY);

  offsetY = tonumber(offsetY);
  if not offsetY then
    lsPrint(140, lsScreenY - 130+3, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    offsetY = 0;
  end
  writeSetting("offsetY",offsetY);

  zoom = CheckBox(10, lsScreenY - 100, z, 0xffffffff, " Zoom 2x", zoom);
  if zoom then
    zoomLevel = 2;
  else
    zoomLevel = 1.0;
  end


  lsPrint(10, lsScreenY - 80, 10, 0.7, 0.7, 0xFFFFFFff, "Train Results displays in Console!");
  lsPrint(10, lsScreenY - 60, 10, 0.7, 0.7, 0xFFFFFFff, "Replace ? with the character you are training");

  
  srStripRegion(regions[0], regions[1], regions[2], regions[3]);
  if lsButtonText(0, lsScreenY - 30, z, 100, 0xFFFFFFff, "Train") then
    --Console will output ??? as last character in each line (when training). Replace ??? with the correct number of letter (case sensitive)
    newText = srTrainTextReader(regions[0]+offsetX,regions[1]+offsetY, '?');
    lsPrintln("newText: " .. newText);
    dynamicKey = dynamicKey + 1;
    ocr_data = newText;
    writeSetting("dynamicKey", dynamicKey);
    writeSetting("ocr_data", ocr_data);
  else
  end

  srMakeImage("current-region", regions[0], regions[1], regions[2], regions[3], true);
  srShowImageDebug("current-region", 0, 0, 1, zoomLevel);

  lsDrawLine(offsetX * zoomLevel, offsetY * zoomLevel, offsetX * zoomLevel, (offsetY + 12) * zoomLevel, 2, 1 + zoomLevel, 1, 0x66FF66FF);

  if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100,
    0xFFFFFFff, "End Script") then
    error(quitMessage);
  end

  checkData(newText);

  lsDoFrame();
  lsSleep(50);
end
ocr_data = "";
ocr_data_key = "";
dynamicKey = 1;
function checkData(newText)
    local scale = 1;
    local done;
    local y = 232;
    local text;
    dynamicKey = readSetting("dynamicKey", dynamicKey);
    ocr_data = readSetting("ocr_data", ocr_data);
    if not ocr_data == newText and not newText == "" then 
        dynamicKey = dynamicKey + 1;
        ocr_data = newText;
        writeSetting("ocr_data", ocr_data);
        writeSetting("dynamicKey", dynamicKey);
    end;
    ocr_data_key = "ocr_data_key_" .. dynamicKey;
    done, ocr_data = lsEditBox(ocr_data_key, 10, y, 10, lsScreenX - 20, 0, scale, scale, 0x000000ff, ocr_data);
    text = ocr_data;
    y = y + 30;
    if lsButtonText(120, lsScreenY - 30, z, 100, 0xFFFFFFff, "Clear") then
      ocr_data = "";
      text = "";
      dynamicKey = dynamicKey + 1;
      writeSetting("dynamicKey", dynamicKey);
      writeSetting("ocr_data", ocr_data);
    end
    if lsButtonText(230, lsScreenY - 30, z, 100, 0xFFFFFFff, "Append") then
        local outputFile = io.open("data/charTemplate.txt","a");
	outputFile:write(ocr_data .. "\n");
	outputFile:close();
    end
    local toks = explode(",", text);
    -- 5,8,64,768,64,8,48,440,128,432,48,v
    local w = tonumber(toks[1]);
    if w and w > 0 then
      -- lsPrint(x, y, 10, scale, scale, 0xFF0000ff, "w=" .. w .. " len=" .. #toks);
      local x = 10;
      local pix = 10;
      for i=1,w do
        local hard = tonumber(toks[1 + i]);
        local soft = tonumber(toks[1 + i + w]);
        if not soft or not hard then
          break;
        end
        local j = 0;
        while hard + soft > 0 and j < 30 do
          if hard & 1 > 0 then
            lsDrawRect(x + (i - 1) * pix, y + j * pix, x + i * pix, y + (j + 1) * pix, 1, 0xFFFFFFff);
          elseif soft & 1 > 0 then
            lsDrawRect(x + (i - 1) * pix, y + j * pix, x + i * pix, y + (j + 1) * pix, 1, 0x888888ff);
          else
            lsDrawRect(x + (i - 1) * pix, y + j * pix, x + i * pix, y + (j + 1) * pix, 1, 0xFF0000ff);
          end
          j = j + 1;
          hard = hard >> 1;
          soft = soft >> 1;
        end
      end
    else
      lsPrint(x, y, 10, scale, scale, 0xFF0000ff, "Error parsing line");
    end
end
-- Hackling Rake - Original macro by Bardoth (T6) - Revised by Cegaiel
-- Runs the Hacking Rake (or Flax Comb). Monitors the skills tab and only clicks when its all black.
--
--




improved_rake = 0;
num_flax = 0;
per_rake = 10;
rakeStep = 1;

function doitRake(oneCycle)
	rakeStep = 1;
	local task = "";
	local task_text = "";
	local warn_small_font=nil;
	local warn_large_font=nil;
	local loop_count=1;
	local straw = 0;
	local tow = 0;
	local lint = 0;
	local clean = 0;
	local eatTimer = 0;
	local startTime = lsGetTimer();
        local doneRaking = false
        clickAllOK();
        clickAllImages("deadPinned.png");
        clickAllImages("ThisIs.png");
        if not (srFindImage("flaxComb.png") or srFindImage("hacklingRake.png")) then -- make sure comb or rake is available.
            lsPrintln("No comb or rake available!");
            return nil;
        end
	checkCurrentStep(); -- Verify what step we're on when you start macro and update.
        if rakeStep > 1 then
          delay_loop_count = 1; --If we're starting in the middle of a previous session, then don't advance loop_count (later). Finish up what's already being processed.
	end
	
	while not doneRaking do
		runTimer = lsGetTimer();
                lsSleep(125);
		srReadScreen();
                local grilledFood = findImage("grilledOnionsWindow.png"); -- findText("Grilled Fish");
		local buffed = srFindImage("enduranceBoosted.png", 7000);
		OK = srFindImage("ok.png"); -- If we got an OK popup, this suggests "Your Flax Comb/Hackling Rake has wore out", quit
		local foundRepair = srFindImage("repair.png");
                local foundNoFlax = srFindImage("noFlaxLeft.png");
		local enduranceMax = srFindImage("enduranceMax.png");
                if foundNoFlax then
                    doneRaking = true;
                    break;
                end;

		-- Prevent eating more than 1 grilled per 10m, in case the screen didn't detect foodbuff
		if grilledFood and not buffed  and (eatTimer == 0 or runTimer - eatTimer > 600000) then
                      local consume = srFindImage("consume.png");
                      if consume then
                          srClickMouseNoMove(consume[0]+5, consume[1]+3);
                          lsSleep(1000);
                          srReadScreen();
                          buffed = srFindImage("enduranceBoosted.png", 7000);
                          if buffed then
                            eatTimer = lsGetTimer();
                          end
                      else
                         lsPrintln("Consume not found");
                      end
		end


		if rakeStep == 1 then
			task = "seperateRotten.png";
			task_text = "Remove Straw";
		elseif rakeStep == 2 then
			task = "seperateTow.png";
			task_text = "Separate Tow";
		elseif rakeStep == 3 then
			task = "refineLint.png";
			task_text = "Refine the Lint";
		elseif rakeStep == 4 then
			task = "cleanThe.png";
			task_text = "Clean the Rake";
		end
		

		if eatTimer > 0 and (runTimer - eatTimer > 720000) then
		  eatTimer = 0;
		  lastAte = "\nAte Last Grilled: 12m has elapsed, problem? Reseting";
		elseif eatTimer > 0 then
		  lastAte = "\nAte Last Grilled: " .. getElapsedTime(eatTimer);
		elseif buffed then
		  lastAte = "\nAte Last Grilled: Waiting on Buff to Expire";
		elseif not grilledFood then
		  lastAte = "\nAte Last Grilled: Menu not pinned";
		else
		  lastAte = "\nAte Last Grilled: Never";
		end 

                GUI = "Next Step: " .. rakeStep .. "/4 - " .. task_text .. "\n\n----------------------------------------------\n1) Straw Removed: " .. straw  .. "\n2) Tow Seperated: " .. tow   .. "\n3) Lint Refined: " .. lint ..  "\n4) Cleanings: " .. clean  .. "\n----------------------------------------------\n\nFlax Processed: " .. (loop_count-1)*per_rake .. "\n\nElapsed Time: " .. getElapsedTime(startTime) .. lastAte;


		if foundRepair then
		  if repairRake() then
		    clickAllImages("ThisIs.png");
		    lsSleep(100);
                    rakeStep = 1;
                  else
                    doneRaking = true;
                  end
		elseif enduranceMax then
			sleepWithStatus(200, GUI, nil, 0.7, "Waiting on Endurance Timer");

		else
		
			clickAllImages("ThisIs.png"); 
			lsSleep(100);
			clickAllImages(task);
			lsSleep(100);
			if rakeStep == 1 then
				straw = straw + per_rake;
			elseif rakeStep == 2 then
				tow = tow + per_rake;
			elseif rakeStep == 3 then
				lint = lint + per_rake;
			elseif
				rakeStep == 4 then
				clean = clean + 1;			
				rakeStep = 0;
				  if delay_loop_count then  -- We started macro while flax comb was in middle of processing... Finish this up before we advance loop counter (so that we can still process the "How much Flax?" at beginning.
				    delay_loop_count = nil;
				  else
				    loop_count = loop_count +1;
				  end
			end
			rakeStep = rakeStep + 1;
			sleepWithStatus(100, GUI, nil, 0.7, "Endurance OK - Clicking window(s)");
			clickAllImages("ThisIs.png");
			lsSleep(100);
		end
            clickAllImages("no.png");
            if srFindImage("noFlaxLeft.png") then
                    doneRaking = true;
                    break;
            end;
            clickAllOK();
            if oneCycle then
                return nil;
            end
        end

end


function checkCurrentStep()
  clickAllImages("ThisIs.png");
  lsSleep(100);
  local rakeStep = 1;
  local taskStep1 = srFindImage("removeStraw.png",7000); --findText("Remove Straw");
  local taskStep2 = srFindImage("seperateTow.png",7000); --findText("Separate Tow");
  local taskStep3 = srFindImage("refineLint.png",7000); --findText("Refine the Lint");
  local taskStep4 = srFindImage("cleanTheFlax.png",7000);  --findText("");
  if not taskStep4 then
      taskStep4 = srFindImage("cleanTheHackling.png",7000);
  end
  local taskStep5 = srFindImage("repair.png",7000); --findText("Repair");
  if taskStep1 then
    rakeStep = 1;
  elseif taskStep2 then
    rakeStep = 2;
  elseif taskStep3 then
    rakeStep = 3;
  elseif taskStep4 then
    rakeStep = 4;
  elseif taskStep5 then
    rakeStep = 1;
  else
    error("Could not find Flax Comb or Hackling Rake menus pinned");
  end
  return rakeStep;
end


function repairRake()
  sleepWithStatus(1000, "Attempting to Repair Rake !")
  local repair = srFindImage("repair.png");
  local material;
  local plusButtons;
  local maxButton;

  if repair then
    srClickMouseNoMove(repair[0]+5, repair[1]+2);
    lsSleep(125);
    srReadScreen();
    local loadMaterials = srFindImage("loadMaterials.png");
    srClickMouseNoMove(loadMaterials[0]+10, loadMaterials[1]+5);
    lsSleep(500);
    srReadScreen();
    plusButtons = findAllImages("plus.png");

	for i=1,#plusButtons do
		local x = plusButtons[i][0];
		local y = plusButtons[i][1];
             srClickMouseNoMove(x, y);

		if i == 1 then
		  material = "Boards";
		elseif i == 2 then
		  material = "Bricks";
		elseif i == 3 then
		  material = "Thorns";
		else
		  material = "What the heck?";
		end

             sleepWithStatus(1000,"Loading " .. material, nil, 0.7);

		srReadScreen();
		OK = srFindImage("ok.png")

		if OK then
		  sleepWithStatus(5000, "You don\'t have any \'" .. material .. "\', Aborting !\n\nClosing Build Menu and Popups ...", nil, 0.7)
		  srClickMouseNoMove(OK[0], OK[1]);
                  lsSleep(75);
		  srReadScreen();
		  local blackX = srFindImage("blackX.png");
		  srClickMouseNoMove(blackX[0], blackX[1]);
		  return false

		else -- No OK button, Load Material

		  srReadScreen();
		  maxButton = srFindImage("max.png");
		  if maxButton then		
		    srClickMouseNoMove(maxButton[0], maxButton[1]);
		  end

		  sleepWithStatus(1000,"Loaded " .. material, nil, 0.7);
		end -- if OK
	end -- for loop
        return true;
  end -- if repair
  return false;
end

-- Hackling Rake - Original macro by Bardoth (T6) - Revised by Cegaiel
-- Runs the Hacking Rake (or Flax Comb). Monitors the skills tab and only clicks when its all black.
--
--

dofile("common.inc");
dofile("settings.inc");
dofile("hackling_rake.inc");




function doit()
	local resourceSelected = false;
        local dropdown_resource_values = {"All Available", "All But Twine", "Dried Papyrus", "Raw Silk", "Yarn", "Thread", "Twine" };
        local dropdown_resource_value = nil;
        local doingAllAvail = false;
        local skipTwine = false;
        local resource = nil;
        
        while not resourceSelected do
            checkBreak();
            lsPrint(10, 10, 0, 0.7, 0.7, 0xffffffff,
            "Choose resource to weave:");
            lsSetCamera(0,0,lsScreenX*1.3,lsScreenY*1.3);
            dropdown_resource_value = readSetting("dropdown_resource_value",dropdown_resource_value);
            dropdown_resource_value = lsDropdown("thisResource", 15, 40, 0, 320, dropdown_resource_value, dropdown_resource_values);
            writeSetting("dropdown_resource_value",dropdown_resource_value);
            if ButtonText(10, lsScreenY - 30, 0, 70, 0xFFFFFFff, "Next") then
                resourceSelected = 1;
            end
            lsDoFrame();
            lsSleep(60);
        end
        resource = dropdown_resource_values[dropdown_resource_value];
        if resource == "All Available" or resource == "All But Twine" then
            doingAllAvail = true;
            if resource == "All But Twine" then
                dropdown_resource_value = dropdown_resource_value + 1;
                skipTwine = true;
            else
                dropdown_resource_value = dropdown_resource_value + 2;
            end
            resource = dropdown_resource_values[dropdown_resource_value];
        end
	askForWindow("Loom v1.0 by Dreger\n\nPin Loom window and have loaded with resources and/or the resources in your inventory.\n\nYou MUST have Skills window open and everything from Strength to Perception skill should be visible.\n\nYou can optionally pin 'Eat some Grilled Onion (and/or Fish)' menu to eat it whenever your endurance is not green.");
        clickAllOK();
	step = 1;
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
        local done = false;
        local skipSilk = true;

	checkCurrentStep(); -- Verify what step we're on when you start macro and update.
	
	while not done do
		runTimer = lsGetTimer();
		srReadScreen();
                
                lsSleep(125);
		srReadScreen();
                local grilledFood = srFindImage("grilledOnionsWindow.png"); -- findText("Grilled Fish");
		local buffed = srFindImage("enduranceBoosted.png", 7000);
		local enduranceMax = srFindImage("enduranceMax.png", 7000);
                
		-- Prevent eating more than 1 grilled per 10m, in case the screen didn't detect foodbuff
		if grilledFood and not buffed  and (eatTimer == 0 or runTimer - eatTimer > 600000) then
                      local consume = srFindImage("consume.png");
		      if consume then
                         safeClick(consume[0]+5,consume[1]+3,0);
                         eatTimer = lsGetTimer();
                      end
		end
		

		if eatTimer > 0 and (runTimer - eatTimer > 720000) then
		  eatTimer = 0;
		  lastAte = "\nAte Last Grilled: 12m has elapsed, problem? Reseting";
		elseif eatTimer > 0 then
		  lastAte = "\nAte Last Grilled: " .. getElapsedTime(eatTimer);
		elseif buffed then
		  lastAte = "\nAte Last Grilled: Waiting on Buff to Expire";
		elseif not grilledOnion then
		  lastAte = "\nAte Last Grilled: Menu not pinned";
		else
		  lastAte = "\nAte Last Grilled: Never";
		end 

GUI = "Elapsed Time: " .. getElapsedTime(startTime) .. lastAte;

                  
		if stats_black then
			sleepWithStatus(200, GUI, nil, 0.7, "Waiting on Endurance Timer");
                        srReadScreen();
		else
		        
                        --lsSleep(100);
			--clickAllImages("ThisIs.png");
                        --srReadScreen();
			--lsSleep(150);
                        local imageName = "";
                        if resource == "Dried Papyrus" then
                          imageName = "Papyrus";
                        elseif resource == "Raw Silk" then
                          imageName = "Silk";
                        else
                          imageName = resource;
                        end
                        
			clickAllImages("weave" .. imageName .. ".png");
                        lsSleep(500);
                        srReadScreen();
                        local needRestring = srFindImage("needRestring.png", 7000);
                        if not needRestring then
                            needRestring = srFindImage("restring.png", 7000);
                        end
                        if needRestring then
                            clickAllOK();
                            lsSleep(50);
                            srReadScreen();
			    clickAllImages("ThisIs.png");
                            lsSleep(50);
                            srReadScreen();
			    clickAllImages("restring.png");
                            lsSleep(50);
                            srReadScreen();
                            needRestring = false;
                        end
                        if not needRestring then
                            needRestring = srFindImage("restring.png", 7000);
                        end
                        lsSleep(50);
                        srReadScreen();
                        lsSleep(50);
                        local hadOK = clickOK();
                        if hadOK and not needRestring then
                            clickAllOK();
                            sleepWithStatus(250, "Loading the loomn");
                            clickAllImages("load" .. imageName .. ".png");
                            lsSleep(250);
                            srReadScreen();
                            local max = srFindImage("max.png");
        		    if max then
			        safeClick(max[0]+5,max[1]+5,0);
			        sleepWithStatus(250, "Clicking Max button");
                                lsSleep(250);
		            else
			        sleepWithStatus(250, "Searching for Max button");
                                max = srFindImage("max.png");
                                safeClick(max[0]+5,max[1]+5,0);
                                lsSleep(250);
		            end
                            srReadScreen();
                            hadOK = clickOK();
                            if hadOK then
                                clickAllOK();
                                if doingAllAvail then
                                    dropdown_resource_value = dropdown_resource_value + 1;
                                    if dropdown_resource_value == 4 and skipSilk then
                                      dropdown_resource_value = dropdown_resource_value + 1;
                                    end
                                    if dropdown_resource_value > #dropdown_resource_values or (dropdown_resource_value >= #dropdown_resource_values and skipTwine) then
                                        done = true;
                                    else
                                        resource = dropdown_resource_values[dropdown_resource_value];
                                    end
                                else
                                   done = true;
                                end
                            end
                        elseif needRestring then -- no twine for restring!
                            done = true;
                        end
                        
			--if step == 1 then
			--	straw = straw + per_rake;
			--elseif step == 2 then
			--	tow = tow + per_rake;
			--elseif step == 3 then
			--	lint = lint + per_rake;
			--elseif
			--	step == 4 then
			--	clean = clean + 1;			
			--	step = 0;
			--	  if delay_loop_count then  -- We started macro while flax comb was in middle of processing... Finish this up before we advance loop counter (so that we can still process the "How much Flax?" at beginning.
			--	    delay_loop_count = nil;
			--	  else
			--	    loop_count= loop_count +1;
			--	  end
			--end
			--step = step + 1;
			sleepWithStatus(100, GUI, nil, 0.7, "Endurance OK - weaving: " .. resource);
			--clickAllText("This is")
			--lsSleep(100);
		end

end

		--lsPlaySound("Complete.wav");
		--lsMessageBox("Elapsed Time:", getElapsedTime(startTime));
    doitRake();
end


function checkCurrentStep()
  clickAllText("This is");
  lsSleep(100);
  taskStep1 = srFindImage("weaveTwine.png");
  taskStep2 = srFindImage("restring.png");

  if taskStep1 then
    step = 1;
  elseif taskStep2 then
    step = 2;
  elseif taskStep3 then
    step = 3;
  elseif taskStep4 then
    step = 4;
  elseif taskStep5 then
    step = 1;
  else
    error("Could not find Loome menus pinned");
  end
end


function restringLoom()
  step = 1;
  srReadScreen();
  clickOK();
  srReadScreen();
  clickAllImages("ThisIs.png");
  lsSleep(100);
  srReadScreen();
  clickAllImages("restring.png");
  lsSleep(100);
  
end

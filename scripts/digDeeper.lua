-- Hackling Rake - Original macro by Bardoth (T6) - Revised by Cegaiel
-- Runs the Hacking Rake (or Flax Comb). Monitors the skills tab and only clicks when its all black.
--
--

dofile("common.inc");
dofile("settings.inc");





function doit()
	
	askForWindow("digDeeper v1.0 by Dreger\n\nPin This is a Hole in Ground window. You can optionally pin 'Eat some Grilled Onion (and/or Fish)' menu to eat it whenever your endurance is not green.");

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

	while not done do
		runTimer = lsGetTimer();
		srReadScreen();
                
                grilledFish = true;
                grilledFood = findText("Grilled Fish");
                if (not grilledFood) then
                    grilledFish = false
                    grilledFood = findText("Grilled Onions");
                end

		
		stats_black = srFindImage("enduranceMax.png");

		-- Prevent eating more than 1 grilled per 10m, in case the screen didn't detect foodbuff
		if grilledFood and not buffed  and (eatTimer == 0 or runTimer - eatTimer > 600000) then
                  if (grilledFish) then
                      clickAllText("Grilled Fish");
                  else
		      clickAllText("Grilled Onions");
                  end
                  eatTimer = lsGetTimer()
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
		        
                        
			clickAllImages("digDeeper.png");
                        lsSleep(750);
                        srReadScreen();
                        
		end

end

		--lsPlaySound("Complete.wav");
		lsMessageBox("Elapsed Time:", getElapsedTime(startTime));
end


function checkCurrentStep()
  clickAllText("This is");
  lsSleep(100);
  taskStep1 = findImage("weaveTwine.png");
  taskStep2 = findImage("restring.png");

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

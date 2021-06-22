-- Hackling Rake - Original macro by Bardoth (T6) - Revised by Cegaiel
-- Runs the Hacking Rake (or Flax Comb). Monitors the skills tab and only clicks when its all black.
--
--
dofile("common.inc");
dofile("hackling_rake.inc");

function doit()
	askForWindow("Hackling Rake v1.0 by Bardoth - (Revised by Cegaiel)\n\nPin Hacking Rake or Flax Comb window up and have Rotten Flax in your inventory.\n\nMake sure your rake is showing \"Step 1, Remove Straw\" before starting.\n\nYou MUST have Skills window open and everything from Strength to Perception skill should be visible.\n\nYou can optionally pin 'Eat some Grilled Onion (and/or Fish)' menu to eat it whenever your endurance is not green.");
        doitRake();
end

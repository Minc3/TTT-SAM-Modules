if SAM_LOADED then return end

local run = function(fn)
	if not GAMEMODE then
		timer.Simple(0, fn)
	else
		fn()
	end
end

run(function()
	if engine.ActiveGamemode() ~= "terrortown" then return end

	sam.command.set_category("TTT Dev")

		sam.command.new("bot")

			:SetPermission("bot", "superadmin")
			:Help("Spawn bot(s).\n(Number of bots to spawn.)")

			:AddArg("number", {
			   optional = true,
			   default = 1,
			   hint = "number",
			   min = 0,
			   max = 128,
			   round = true,
			})

		    :OnExecute(function(calling_ply, targets)
		    	for i = 1, targets do 
		    		RunConsoleCommand("bot", "\n")
		    	end
		    end)

		:End()

		sam.command.new("bot_mimic")

			:SetPermission("sv_cheats", "superadmin")
			:Help("bots will mimic player\n(sv_cheats 1) required")


		    :OnExecute(function(calling_ply, targets)

		    	RunConsoleCommand("bot_mimic", "1")
		    	
		    end)

		:End()

		sam.command.new("console")

			:SetPermission("console", "superadmin")
			:Help("Console command")

			:AddArg("text")

		    :OnExecute(function(calling_ply, targets)

		    	game.ConsoleCommand(targets .. "\n")

		    end)

		:End()

		sam.command.new("freezebots")

			:SetPermission("freezebots", "superadmin")
			:Help("Stop bots from moving")

		    :OnExecute(function(calling_ply)

		    	for k, v in pairs(player.GetAll()) do
		    		if v:IsBot() then
		    			v:SetWalkSpeed(1)
		    		end
		    	end

		    end)

		:End()

end)
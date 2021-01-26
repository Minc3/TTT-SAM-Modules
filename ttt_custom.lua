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

	sam.command.set_category("TTT Admin")

	sam.command.new("role")

		:SetPermission("role", "admin")
		:Help("Force a role on player(s) \n(0=Innocent)\n(1=Traitor)\n(2=Detective)")

		:AddArg("player")

		:AddArg("number", {
		   optional = true,
		   default = 0,
		   hint = "role",
		   min = 0,
		   max = 2,
		   round = true,
		})

		:OnExecute(function(calling_ply, targets, role)
			for i = 1, #targets do
			    local target = targets[i]

			    local current_role = target:GetRole()

			    if GetRoundState() == 1 or GetRoundState() == 2 then
				   sam.player.send_message(calling_ply, " The round has not begun")
			    elseif not target:Alive() then
				   sam.player.send_message(calling_ply, " {V_1} is dead", { V_1 = calling_ply:Nick() })
			    elseif current_role == role then
				   sam.player.send_message(calling_ply, " {V_1} is already that role", { V_1 = calling_ply:Nick() })
			    else
			    target:ResetEquipment()
			    RemoveLoadoutWeapons(target)
			    RemoveBoughtWeapons(target)

			    target:SetRole(role)

			    if role == 0 then
				 target:SetCredits(0)
			    elseif role == 1 then
				   target:SetCredits( GetConVarNumber("ttt_credits_starting") )
			    else
				   target:SetCredits( GetConVarNumber("ttt_det_credits_starting") )
			    end

			    SendFullStateUpdate()

			    GiveLoadoutItems(target)
			    GiveLoadoutWeapons(target)

			    local roleName = {
				[0] = "innocent",
				[1] = "traitor",
				[2] = "detective",
			    }

			    sam.player.send_message(calling_ply, " {V_1} is now role {V_2}", { V_1 = calling_ply:Nick(), V_2 = roleName[role] })
			    end
			end
		end)
	:End()

	sam.command.new("respawn")

		:SetPermission("respawn", "admin")
		:Help("Respawn dead player(s)")

		:AddArg("player")

		:OnExecute(function(calling_ply, targets, role)
			for i = 1, #targets do
			    local target = targets[i]
			    local nick = target:Nick()

			    if GetRoundState() == 1 then
				   sam.player.send_message(calling_ply, "Can't respawn {V_2} on a inactive round", {V_2 = nick})
			    elseif target:GetObserverMode() ==  OBS_MODE_NONE then
				   sam.player.send_message(calling_ply, "{V_2} is already alive", {V_2 = nick})
			    else

			    local corpse = corpse_find(target)

				if corpse then 
				   corpse_remove(corpse)
				   CORPSE.SetFound( corpse, false )
				   target:SetNWBool("body_found", false)
				end

				target:SpawnForRound( true )
				target:SetCredits( ( (target:GetRole() == ROLE_INNOCENT) and 0 ) or GetConVarNumber("ttt_credits_starting") )

				SendFullStateUpdate()
				sam.player.send_message(calling_ply, "{V_2} has been respawned", {V_2 = nick})
			    end
			end
		end)
	:End()

	sam.command.new("karma")

		:SetPermission("karma", "admin")
		:Help("Set player(s) karma")

		:AddArg("player")

		:AddArg("number", {
		   optional = true,
		   default = 1000,
		   hint = "karma",
		   min = 0,
		   max = 1000,
		   round = true, 
		})

		:OnExecute(function(calling_ply, targets, karma)
			for i = 1, #targets do
			    local target = targets[i]
			    local nick = target:Nick()

			    target:SetBaseKarma( karma )
			    target:SetLiveKarma( karma )
			    sam.player.send_message(calling_ply, "{V_2} karma has been set to {V_3}", {V_2 = nick, V_3 = karma})
			end  
		end) 
	:End()

	sam.command.new("spectator")

		:SetPermission("spectator", "admin")
		:Help("Force player(s) in or out of spec\n(OUT=0)\n(IN=1)")

		:AddArg("player")

		:AddArg("number", {
		   optional = true,
		   default = 0,
		   hint = "spec",
		   min = 0,
		   max = 1,
		   round = true,
		})

		:OnExecute(function(calling_ply, targets, spec)
			for i = 1, #targets do
			    local target = targets[i]
			    local nick = target:Nick()

			    target:ConCommand("ttt_spectator_mode " .. spec)

			    if spec == 1 then
				   sam.player.send_message(nil , " {V_1} forced {V_2} in to spectator!", { V_1 = calling_ply:Nick(), V_2 = nick })
			    else
				   sam.player.send_message(nil , " {V_1} forced {V_2} out of spectator!", { V_1 = calling_ply:Nick(), V_2 = nick })
			    end
			end  
		end) 
	:End()

	sam.command.new("give")

		:SetPermission("give", "superadmin")
		:Help("Gives player(s) weapon")

		:AddArg("player")

		:AddArg("text", {
		   optional = true,
		   default = "weapon_ttt_m16",
		   hint = "wep",
		 })

		:OnExecute(function(calling_ply, targets, wep)
			for i = 1, #targets do
			    local target = targets[i]
			    target:Give(wep)
			end  
		end) 
	:End()

	sam.command.new("credits")

		:SetPermission("credits", "admin")
		:Help("Give player(s) credits")

		:AddArg("player")

		:AddArg("number", {
		   optional = true,
		   default = 0,
		   hint = "amount",
		   min = 0,
		   max = 100,
		   round = true,
		})

		:OnExecute(function(calling_ply, targets, amount)
			for i = 1, #targets do
			    local target = targets[i]
			   target:AddCredits(amount)
			end
		end) 
	:End()

	sam.command.new("identify")

		:SetPermission("identify", "admin")
		:Help("Identifies a target's body\n(Missing=0)\n(Found=1)")

		:AddArg("player")

		:AddArg("number", {
	           optional = true,
	           default = 0,
	           hint = "identify",
	           min = 0,
	           max = 1,
	           round = true,
	        })

		:OnExecute(function(calling_ply, targets, identify)
			for i = 1, #targets do
			    local target = targets[i]
			    local nick = target:Nick()
			    local body = corpse_find( target )

			    if not body then 
				   sam.player.send_message(calling_ply, "{V_2} body not found!", {V_2 = nick})
			    return 
			    end

			    if identify == 1 then
				   CORPSE.SetFound( body, true )
				   target:SetNWBool("body_found", true)

					if target:GetRole() == ROLE_TRAITOR then
					    SendConfirmedTraitors(GetInnocentFilter(false))
					    SCORE:HandleBodyFound( calling_ply, target )
					end
					sam.player.send_message(calling_ply, "{V_2} has been marked as found", {V_2 = nick})
			    else
					CORPSE.SetFound( body, false )
					target:SetNWBool("body_found", false)
					SendFullStateUpdate()
					sam.player.send_message(calling_ply, "{V_2} has been marked as not found", {V_2 = nick})
			   end
			end
		end) 
	:End()

	sam.command.set_category("TTT Utility")

	sam.command.new("minply")

	    :SetPermission("minply", "superadmin")
	    :Help("The amount of players required to start a game")

	    :AddArg("number", {
	        optional = true,
	        default = 2,
	        hint = "amount",
	        min = 1,
	        max = 100,
	        round = true,
	    })

	    :OnExecute(function(calling_ply, targets)
	       RunConsoleCommand("ttt_minimum_players", targets)
	    end)
	:End()

	sam.command.new("preventwin")

	    :SetPermission("preventwin", "superadmin")
	    :Help("Toggles the prevention of winning")

	    :OnExecute(function(calling_ply, targets)
	    	local toggle = GetConVar( "ttt_debug_preventwin" ):GetInt()

			if toggle == 1 then
			   RunConsoleCommand("ttt_debug_preventwin", 0)
			   sam.player.send_message(nil , " {V_1} allowed the round to end as normal", { V_1 = calling_ply:Nick() })
			else
			   RunConsoleCommand("ttt_debug_preventwin", 1)
			   sam.player.send_message(nil , " {V_1} prevented the round from ending untill timeout", { V_1 = calling_ply:Nick() })
			end
	    end)
	:End()

	sam.command.new("roundrestart")

	    :SetPermission("roundrestart", "superadmin")
	    :Help("Restarts the round")

	    :OnExecute(function(calling_ply, targets)
		   RunConsoleCommand("ttt_roundrestart", "\n")
		   sam.player.send_message(nil , " {V_1} has restarted the round", { V_1 = calling_ply:Nick() })
	    end)

	:End()

	-- Below is copied from ulx
	function GetLoadoutWeapons(r)
		local tbl = {
			[ROLE_INNOCENT] = {},
			[ROLE_TRAITOR]  = {},
			[ROLE_DETECTIVE]= {}
		};
		for k, w in pairs(weapons.GetList()) do
			if w and type(w.InLoadoutFor) == "table" then
				for _, wrole in pairs(w.InLoadoutFor) do
					table.insert(tbl[wrole], WEPS.GetClass(w))
				end
			end
		end
	    return tbl[r]
	end

	function RemoveBoughtWeapons(ply)
		for _, wep in pairs(weapons.GetList()) do
			local wep_class = WEPS.GetClass(wep)
			if wep and type(wep.CanBuy) == "table" then
				for _, weprole in pairs(wep.CanBuy) do
					if weprole == ply:GetRole() and ply:HasWeapon(wep_class) then
						ply:StripWeapon(wep_class)
					end
				end
			end
		end
	end

	function RemoveLoadoutWeapons(ply)
		local weps = GetLoadoutWeapons( GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole() )
		for _, cls in pairs(weps) do
			if ply:HasWeapon(cls) then
				ply:StripWeapon(cls)
			end
		end
	end

	function GiveLoadoutWeapons(ply)
		local r = GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole()
		local weps = GetLoadoutWeapons(r)
		if not weps then return end

		for _, cls in pairs(weps) do
			if not ply:HasWeapon(cls) then
				ply:Give(cls)
			end
		end
	end

	function GiveLoadoutItems(ply)
		local items = EquipmentItems[ply:GetRole()]
		if items then
			for _, item in pairs(items) do
				if item.loadout and item.id then
					ply:GiveEquipmentItem(item.id)
				end
			end
		end
	end

	function corpse_find(v)
		for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
			if ent.uqid == v:UniqueID() and IsValid(ent) then
				return ent or false
			end
		end
	end

	function corpse_remove(corpse)
		CORPSE.SetFound(corpse, false)
		if string.find(corpse:GetModel(), "zm_", 6, true) then
			corpse:Remove()
		elseif corpse.player_ragdoll then
			corpse:Remove()
		end
	end
end)

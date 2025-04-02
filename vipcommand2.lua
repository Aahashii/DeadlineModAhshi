---@diagnostic disable: undefined-global

-- author: Aahashii, modified file from blackshibe
-- version: 0.23.0 dev
-- description: runs a VIP server bot

if not is_private_server() and not is_studio() then
	return
end

local prefix = "-"
local commands

local function resolve_player(name, sender)
	if name == "me" then
		return {players.get(sender)}
	elseif name == "all" then
		return players.get_all()
	else
		local all_players = players.get_all()
		local matched_players = {}
		for _, player in pairs(all_players) do
			if player.name:lower():find(name:lower(), 1, true) then
				table.insert(matched_players, player)
			end
		end
		return matched_players
	end
end

commands = {
	help2 = function()
		local result = "Commands: "
		for command, _ in pairs(commands) do
			result = result .. command .. ", "
		end
		return result:sub(1, -3)
	end,
	explode = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.explode() end
	end,
	kill = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.kill() end
	end,
	bot = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do spawning.bot(p.get_position()) end
	end,
	kick = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.kick() end
	end,
	setteamdefender = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.set_team("defender") end
	end,
	setteamattacker = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.set_team("attacker") end
	end,
	spawn = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.spawn() end
	end,
	respawn = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.respawn() end
	end,
	tp = function(args, sender)
		local args_split = args:split(" ")
		local players_list = resolve_player(args_split[1], sender)
		local target = resolve_player(args_split[2], sender)
		if #players_list > 0 and #target > 0 then
			for _, p in pairs(players_list) do p.set_position(target[1].get_position()) end
		end
	end,
	walkspeed = function(args, sender)
		local args_split = args:split(" ")
		local players_list = resolve_player(args_split[1], sender)
		local speed = tonumber(args_split[2])
		if speed then
			for _, p in pairs(players_list) do p.set_speed(speed) end
		end
	end,
	health = function(args, sender)
		local args_split = args:split(" ")
		local players_list = resolve_player(args_split[1], sender)
		local health = tonumber(args_split[2])
		if health then
			for _, p in pairs(players_list) do p.set_health(health) end
		end
	end,
	initialhealth = function(args, sender)
		local args_split = args:split(" ")
		local players_list = resolve_player(args_split[1], sender)
		local health = tonumber(args_split[2])
		if health then
			for _, p in pairs(players_list) do p.set_initial_health(health) end
		end
	end,
	ban = function(name, sender)
		for _, p in pairs(resolve_player(name, sender)) do p.ban_from_server() end
	end,
	refill = function(args, sender)
                local args_split = args:split(" ")
		local players_list = resolve_player(args_split[1], sender)
		for _, p in pairs(players_list) do p.refill_ammo() end
	end,
	lag = function(fps)
		sharedvars.dbg_limit_fps = true
		sharedvars.dbg_max_fps = fps
	end,
	set = function(args, sender)
		local args_split = args:split(" ")
		local var_name = args_split[1]
		local value = args_split[2]
		if sharedvars[var_name] ~= nil then
			sharedvars[var_name] = tonumber(value) or value
			return "Set " .. var_name .. " to " .. tostring(sharedvars[var_name])
		else
			return "Variable " .. var_name .. " not found."
		end
	end,
        loadmod = function()
		 require("https://raw.githubusercontent.com/Aahashii/DeadlineModAhshi/refs/heads/main/JJSMap")
	end,
        setmodmap = function(string)
        map.set_map(string)
        end,
        printsets = function()
        for name, description in pairs(sharedvars_descriptions) do
    print(name, description) --> prints every sharedvars value
end
        end,
	gamemode = function(setgm)
		gamemode.force_set_gamemode(setgm)
	end,
}

chat.player_chatted:Connect(function(sender, channel, content)
	local command = content:split(" ")[1]
	local first_letter = command:sub(1, 1)
	if first_letter ~= prefix then return end
	command = command:sub(2, -1)
	if not commands[command] then return end
	local result = commands[command](content:sub(#command + 3, -1), sender)
	print(result)
	chat.send_announcement(result)
end)

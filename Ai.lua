if not game:IsLoaded() then
	game.Loaded:Wait()
end

local statuslist = {}
statuslist.fallensurvival = {
	name = 'Fallen Survival';
	status = 'Undetected';
	support = {'Zenith'; 'Valex'; 'Wave'; 'Potassium'; 'Volcano';};
}
statuslist.tridentsurvival = {
	name = 'Trident Survival';
	status = 'Undetected';
	support = {'Wave'; 'Zenith'; 'MacSploit'; 'Velocity'; 'Potassium'; 'Seliware'; 'Valex'; 'Volcano';};
}
statuslist.lonesurvival = {
	name = 'Lone Survival';
	status = 'Undetected';
	support = {'Wave'; 'Zenith'; 'MacSploit'; 'Velocity'; 'Potassium'; 'Seliware'; 'Valex'; 'Volcano';};
}

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() and players.LocalPlayer

-- ✅ Your executor’s working APIs
local executor = identifyexecutor() or "Unknown"
local messagebox = messageboxasync or messagebox
local request = request or http_request
local loadstring = loadstring

-- ✅ Validate environment
if type(messagebox) ~= "function" then
	return localPlayer:Kick("[amongus.hook] missing alias ( messagebox ) - unsupported executor")
end

-- ✅ Valex auto-detect + banner
if string.lower(executor):find("valex") then
	pcall(function()
		messagebox("Detected Valex Executor ✅\n\nWelcome, " .. localPlayer.Name .. "!", "amongus.hook", 64)
	end)
end

-- ✅ Safe messagebox wrapper
local function protectedMessagebox(body, title, id)
	local success, output = pcall(messagebox, body, title, id)
	if not success then
		localPlayer:Kick("[amongus.hook] messagebox_error - " .. tostring(body))
		task.wait(9e9)
	end
	return output
end

-- ✅ Protected loader
local function protectedLoad(url)
	local success, response = pcall(request, {Url = url; Method = "GET";})
	if not success then
		protectedMessagebox("protectedLoad failed(1) - request error\n\nurl: " .. url, "amongus.hook [" .. executor .. "]", 48)
		task.wait(9e9)
	elseif type(response) ~= "table" or type(response.Body) ~= "string" or response.StatusCode ~= 200 then
		protectedMessagebox("protectedLoad failed(2) - bad response\n\nurl: " .. url, "amongus.hook [" .. executor .. "]", 48)
		task.wait(9e9)
	else
		local loader = loadstring(response.Body)
		if not loader then
			protectedMessagebox("protectedLoad failed(3) - syntax error\n\nurl: " .. url, "amongus.hook [" .. executor .. "]", 48)
			task.wait(9e9)
		else
			return loader()
		end
	end
end

-- ✅ Basic environment check
if type(loadstring) ~= "function" then
	return protectedMessagebox("missing alias ( loadstring ) - unsupported executor", "amongus.hook [" .. executor .. "]", 48)
elseif type(request) ~= "function" then
	return protectedMessagebox("missing alias ( request ) - unsupported executor", "amongus.hook [" .. executor .. "]", 48)
elseif not Drawing then
	protectedLoad("https://raw.githubusercontent.com/mainstreamed/amongus-hook/refs/heads/main/drawingfix.lua")
end

local placeid = game.PlaceId
local dir = "https://raw.githubusercontent.com/mainstreamed/amongus-hook/main/"

local function loadGame(name)
	local gameData = statuslist[name]
	if not gameData then return end

	if gameData.status ~= "Undetected" and protectedMessagebox(
		gameData.name .. " is Currently Marked as " .. gameData.status .. "!\n\nAre You Sure You Want to Continue?",
		"amongus.hook",
		52
	) ~= 6 then
		return
	elseif gameData.support and not table.find(gameData.support, executor) then
		print("GoonerBypassingAmonguasHook")
		return
	end

	protectedLoad(dir .. name .. "/main.lua")
end

-- ✅ Game detection
if placeid == 13253735473 then
	return loadGame("tridentsurvival")
elseif placeid == 13800717766 or placeid == 15479377118 or placeid == 16849012343 then
	return loadGame("fallensurvival")
elseif placeid == 13800223141 or placeid == 139307005148921 then
	return loadGame("lonesurvival")
else
	protectedMessagebox(
		"This Game is Unsupported!\n\nIf you believe this is incorrect, please open a ticket in our discord! - discord.gg/2jycAcKvdw",
		"amongus.hook [" .. placeid .. "]",
		48
	)
end

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

-- ✅ Executor detection
local executor = identifyexecutor() or "Unknown"
local request = request or http_request
local loadstring = loadstring

-- ✅ Validate environment
if type(print) ~= "function" then
	return localPlayer:Kick("[amongus.hook] missing alias ( print ) - unsupported environment")
end

-- ✅ Valex auto-detect + banner
if string.lower(executor):find("valex") then
	pcall(function()
		print("Detected Valex Executor ✅ | Welcome, " .. localPlayer.Name .. "!")
	end)
end

-- ✅ Safe print wrapper
local function protectedPrint(body, title)
	local success, output = pcall(print, "[" .. title .. "] " .. body)
	if not success then
		localPlayer:Kick("[amongus.hook] print_error - " .. tostring(body))
		task.wait(9e9)
	end
	return output
end

-- ✅ Protected loader
local function protectedLoad(url)
	local success, response = pcall(request, {Url = url; Method = "GET";})
	if not success then
		protectedPrint("protectedLoad failed(1) - request error | url: " .. url, "amongus.hook [" .. executor .. "]")
		task.wait(9e9)
	elseif type(response) ~= "table" or type(response.Body) ~= "string" or response.StatusCode ~= 200 then
		protectedPrint("protectedLoad failed(2) - bad response | url: " .. url, "amongus.hook [" .. executor .. "]")
		task.wait(9e9)
	else
		local loader = loadstring(response.Body)
		if not loader then
			protectedPrint("protectedLoad failed(3) - syntax error | url: " .. url, "amongus.hook [" .. executor .. "]")
			task.wait(9e9)
		else
			return loader()
		end
	end
end

-- ✅ Basic environment check
if type(loadstring) ~= "function" then
	return protectedPrint("missing alias ( loadstring ) - unsupported executor", "amongus.hook [" .. executor .. "]")
elseif type(request) ~= "function" then
	return protectedPrint("missing alias ( request ) - unsupported executor", "amongus.hook [" .. executor .. "]")
elseif not Drawing then
	protectedLoad("https://raw.githubusercontent.com/mainstreamed/amongus-hook/refs/heads/main/drawingfix.lua")
end

local placeid = game.PlaceId
local dir = "https://raw.githubusercontent.com/mainstreamed/amongus-hook/main/"

local function loadGame(name)
	local gameData = statuslist[name]
	if not gameData then return end

	if gameData.status ~= "Undetected" then
		print(gameData.name .. " is Currently Marked as " .. gameData.status .. "! Skipping load.")
		return
	elseif gameData.support and not table.find(gameData.support, executor) then
		print("Executor not supported for " .. gameData.name .. " ( " .. executor .. " )")
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
	protectedPrint(
		"This Game is Unsupported! If you believe this is incorrect, please open a ticket in our discord: discord.gg/2jycAcKvdw",
		"amongus.hook [" .. placeid .. "]"
	)
end

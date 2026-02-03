-- RINOLIVE DELTA / XENO SAFE GUARD
if getgenv().__RinoNotifierStarted then
	return
end
getgenv().__RinoNotifierStarted = true

repeat task.wait() until game:IsLoaded()
task.wait(3)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

--================ CONFIG =================
local WEBHOOK = "https://discord.com/api/webhooks/1449391153064575148/rIt_v0jashDSj6Y4DpfZ_ZyROYmTW7WY6Wok9KmXvJQHiUtciFrYaWWnQUdjo0ePJ1lj"

local HIGHLIGHT_WEBHOOK = "https://discord.com/api/webhooks/1467699262149103823/rJ4ChLVXev2dB6hqyyoLtoI-sUB9XqQOBb498vkIV6spbLZu5I4PwznsPnpueaT-mIgF"

local MIN_MONEY = 10000000
local SCAN_DELAY = 4
local HOP_DELAY = 22
--========================================

local requestFunc =
	request or
	http_request or
	(syn and syn.request) or
	(fluxus and fluxus.request)

local sentServer = {}
local sentHighlight = {}

local BLACKLIST = {
	["radioactive slap"] = true,
	["radioactive"] = true,
	["slap"] = true,
	["radioactive airstrike"] = true,
	["airstrike"] = true,
}

-------------------------------------------------
-- FORMAT MONEY
-------------------------------------------------
local function fmt(n)
	if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
	if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
	return tostring(n)
end

-------------------------------------------------
-- PLAYER COUNT
-------------------------------------------------
local function getPlayerCount()
	return #Players:GetPlayers(), Players.MaxPlayers
end

-------------------------------------------------
-- Láº¤Y TĂN PET THáº¬T
-------------------------------------------------
local function getPetName(label)
	local gui =
		label:FindFirstAncestorWhichIsA("BillboardGui")
		or label:FindFirstAncestorWhichIsA("SurfaceGui")

	if not gui then return nil end

	for _, v in ipairs(gui:GetDescendants()) do
		if v:IsA("TextLabel") then
			local t = v.Text
			if t
				and #t > 2
				and not t:find("/s")
				and not t:lower():find("workspace")
				and not t:lower():find("animal")
			then
				return t
			end
		end
	end
	return nil
end

-------------------------------------------------
-- HIGHLIGHT Äáº¸P (GIá»NG áº¢NH)
-------------------------------------------------
local function sendPrettyHighlight(pets)

	if sentHighlight[game.JobId] then
		return
	end

	sentHighlight[game.JobId] = true

	local cur, max = getPlayerCount()

	local lines = ""
	for i, p in ipairs(pets) do
		lines = lines .. i .. ". " .. p.name .. " â€“ $" .. fmt(p.money) .. "/s\n"
	end

	local data = {
		username = "yeu truc ",
		embeds = {{
			title = "City 3TN Highlights",
			color = 3066993,
            description =
				"**" .. pets[1].name .. " ($" .. fmt(pets[1].money) .. "/s)**\n\n" ..
				lines .. "\n" ..
				"đŸ‘¥ Players " .. cur .. "/" .. max,
			footer = {
				text = "Made by RINOLIVE"
			}
		}}
	}

	if requestFunc then
		requestFunc({
			Url = HIGHLIGHT_WEBHOOK,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(data)
		})
	end
end

-------------------------------------------------
-- SCAN SERVER
-------------------------------------------------
local function scanServer()
	local pets = {}

	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("TextLabel") then
			local t = v.Text
			if t and t:find("/s") and (t:find("M") or t:find("B")) then
				local num = tonumber(t:match("[%d%.]+"))
				if num then
					if t:find("B") then
						num = num * 1e9
					else
						num = num * 1e6
					end

					if num >= MIN_MONEY and num < 1e12 then
						local name = getPetName(v)
						if name then
							local lname = name:lower()
							if not BLACKLIST[lname] then
								table.insert(pets, {
									name = name,
									money = num
								})
							end
						end
					end
				end
			end
		end
	end

	if #pets == 0 then return end

	-------------------------------------------------
	-- Gá»¬I HIGHLIGHT Má»I
	-------------------------------------------------
	sendPrettyHighlight(pets)

	-------------------------------------------------
	-- NOTIFIER Gá»C (GIá»® NGUYĂN)
	-------------------------------------------------
	if sentServer[game.JobId] then return end
	sentServer[game.JobId] = true

	local cur, max = getPlayerCount()

	local desc = "đŸ‘¥ Players: " .. cur .. "/" .. max .. "\n\n"
	desc = desc .. "đŸ·ï¸ Name  |  đŸ’° Money/s\n"

	for _, p in ipairs(pets) do
		local icon = "đŸ’"

		if p.money >= 100_000_000 then
			icon = "đŸ”¥"
		end

		desc = desc .. icon .. " " .. p.name .. " â€” $" .. fmt(p.money) .. "/s\n"
	end

	local joinLink =
		"https://chillihub1.github.io/chillihub-joiner/?placeId="
		.. game.PlaceId .. "&gameInstanceId=" .. game.JobId

	local joinScript =
		"game:GetService('TeleportService'):TeleportToPlaceInstance("
		.. game.PlaceId .. ", '" .. game.JobId .. "', game.Players.LocalPlayer)"

	if requestFunc then
		requestFunc({
			Url = WEBHOOK,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				embeds = {{
					title = " City Notifier | RINOLIVE",
					color = 0xf1c40f,
					description = desc,
					fields = {
						{ name = "đŸ†” Job ID", value = game.JobId, inline = false },
						{ name = "đŸŒ Click Join Sever ", value = "[[JOIN TO SEVER]](" .. joinLink .. ")", inline = false },
						{ name = "đŸ“œ Join Script", value = "```lua\n" .. joinScript .. "\n```", inline = false }
					},
					footer = { text = "RINOLIVE | " .. os.date("%H:%M") }
				}}
			})
		})
	end
end

-------------------------------------------------
-- LOOP SCAN
-------------------------------------------------
task.spawn(function()
	while true do
		pcall(scanServer)
		task.wait(SCAN_DELAY)
	end
end)

-------------------------------------------------
-- AUTO HOP
-------------------------------------------------
TeleportService.TeleportInitFailed:Connect(function()
	task.wait(5)
	TeleportService:Teleport(game.PlaceId, LP)
end)

task.spawn(function()
	while true do
		task.wait(HOP_DELAY)
		TeleportService:Teleport(game.PlaceId, LP)
	end
end)

if queue_on_teleport then
	queue_on_teleport([[
		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/nguyenhuynhquocvuong07xel-cell/rinolive-notifiercity/refs/heads/main/notifier.lua",
			true
		))()
	]])
end

print("âœ… RINOLIVE FINAL | HIGHLIGHT FIXED + NOTIFIER OK")

-- RINOLIVE DELTA / XENO SAFE GUARD
if getgenv().__RinoNotifierStarted then
	return
end
getgenv().__RinoNotifierStarted = true

--================ RINOLIVE FINAL | BRAINROT ONLY | XENO 24/24 =================
repeat task.wait() until game:IsLoaded()
task.wait(3)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

--================ CONFIG =================
local WEBHOOK = "https://discord.com/api/webhooks/1449391153064575148/rIt_v0jashDSj6Y4DpfZ_ZyROYmTW7WY6Wok9KmXvJQHiUtciFrYaWWnQUdjo0ePJ1lj"
local MIN_MONEY = 10_000_000
local SCAN_DELAY = 4
local HOP_DELAY =  20 -- đổi 20 nếu muốn hop nhanh hơn
--========================================

-- XENO / DELTA request
local requestFunc =
	request or
	http_request or
	(syn and syn.request) or
	(fluxus and fluxus.request)

local sentServer = {}

--================ BLACKLIST (IM LẶNG) =================
local BLACKLIST = {
	["radioactive slap"] = true,
	["radioactive"] = true,
	["slap"] = true
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
-- LẤY TÊN PET THẬT (CHỐNG ANIMAL / WORKSPACE)
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
				and not t:find("%d")
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
-- SCAN BRAINROT
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
	if sentServer[game.JobId] then return end
	sentServer[game.JobId] = true

	local cur, max = getPlayerCount()

	-------------------------------------------------
	-- DISCORD FORMAT
	-------------------------------------------------
	local desc = "👥 Players: " .. cur .. "/" .. max .. "\n\n"
	desc ..= "🏷️ Name | 💰 Money/s\n"

	for _, p in ipairs(pets) do
		desc ..= p.name .. " — $" .. fmt(p.money) .. "/s\n"
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
					title = "Brainrot Notify | RINOLIVE",
					color = 0x2ecc71,
					description = desc,
					fields = {
						{ name = "🆔 Job ID", value = game.JobId, inline = false },
						{ name = "🌐 Join Server", value = "[JOIN](" .. joinLink .. ")", inline = false },
						{ name = "📜 Join Script", value = "```lua\n" .. joinScript .. "\n```", inline = false }
					},
					footer = { text = "RINOLIVE | " .. os.date("%H:%M") }
				}}
			})
		})
	end
end

-------------------------------------------------
-- AUTO SCAN LOOP
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

-------------------------------------------------
-- 🔥 FIX XENO: AUTO LOAD LẠI SAU MỖI TELEPORT (24/24)
-------------------------------------------------
if queue_on_teleport then
	queue_on_teleport([[
		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/nguyenhuynhquocvuong07xel-cell/rinolive-notifiercity/main/notifier.lua",
			true
		))()
	]])
end

print("✅ RINOLIVE FINAL | XENO FIX | CHẠY 24/24 | KHÔNG CHẾT NGẦM")

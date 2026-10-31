--!strict
--[[
	PlayerDataService.lua
	DataStore load/save with session locking, retries, and autosave.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)

local DataValidator = require(script.Parent.Parent.Utilities.DataValidator)
local Logger = require(script.Parent.Parent.Utilities.Logger)

local PlayerDataService = {}

local profiles: { [number]: any } = {}
local sessionTokens: { [number]: string } = {}
local loadFailed: { [number]: boolean } = {}
local saving: { [number]: boolean } = {}

local dataStore: DataStore? = nil
local storeAvailable = false

local function getStore(): DataStore?
	if dataStore then
		return dataStore
	end
	local ok, storeOrErr = pcall(function()
		return DataStoreService:GetDataStore(GameConfig.DataStore.Name)
	end)
	if ok then
		dataStore = storeOrErr
		storeAvailable = true
		return dataStore
	end
	Logger.Warn("PlayerDataService", "DataStore unavailable: " .. tostring(storeOrErr))
	storeAvailable = false
	return nil
end

local function keyFor(userId: number): string
	return "Player_" .. tostring(userId)
end

local function withRetries(operationName: string, fn: () -> any): (boolean, any)
	local delayTime = GameConfig.DataStore.BaseRetryDelay
	local lastError = nil
	for attempt = 1, GameConfig.DataStore.MaxRetries do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = result
		Logger.Warn(
			"PlayerDataService",
			string.format("%s attempt %d failed: %s", operationName, attempt, tostring(result))
		)
		local jitter = math.random() * 0.5
		task.wait(delayTime + jitter)
		delayTime *= 2
	end
	return false, lastError
end

function PlayerDataService.Init()
	getStore()
	Logger.Info("PlayerDataService", if storeAvailable then "DataStore ready" else "Using in-memory profiles (Studio/offline)")
end

function PlayerDataService.LoadProfile(player: Player): any?
	local userId = player.UserId
	if profiles[userId] then
		return profiles[userId]
	end

	local defaults = DataValidator.CreateDefaultProfile(player)
	local store = getStore()

	if not store or RunService:IsStudio() and not storeAvailable then
		-- Studio without API access: use defaults but allow session play
		profiles[userId] = defaults
		sessionTokens[userId] = tostring(os.clock()) .. "_" .. tostring(userId)
		loadFailed[userId] = false
		Logger.Info("PlayerDataService", "Loaded default profile for " .. player.Name .. " (no DataStore)")
		return profiles[userId]
	end

	local ok, data = withRetries("Load", function()
		return store:GetAsync(keyFor(userId))
	end)

	if not ok then
		-- Critical: do not overwrite with defaults; mark load failed
		loadFailed[userId] = true
		Logger.Error("PlayerDataService", "Failed to load profile for " .. player.Name .. "; refusing default overwrite")
		return nil
	end

	local profile = DataValidator.SanitizeProfile(data, player)
	profiles[userId] = profile
	sessionTokens[userId] = tostring(os.clock()) .. "_" .. tostring(userId)
	loadFailed[userId] = false

	-- Soft session lock marker
	pcall(function()
		store:UpdateAsync(keyFor(userId) .. "_Session", function()
			return {
				JobId = game.JobId,
				Token = sessionTokens[userId],
				Time = os.time(),
			}
		end)
	end)

	Logger.Info("PlayerDataService", "Loaded profile for " .. player.Name)
	return profile
end

function PlayerDataService.GetProfile(player: Player): any?
	return profiles[player.UserId]
end

function PlayerDataService.DidLoadFail(player: Player): boolean
	return loadFailed[player.UserId] == true
end

function PlayerDataService.SaveProfile(player: Player, reason: string?): boolean
	local userId = player.UserId
	local profile = profiles[userId]
	if not profile then
		return false
	end
	if loadFailed[userId] then
		Logger.Warn("PlayerDataService", "Skipping save for " .. player.Name .. " because load previously failed")
		return false
	end
	if saving[userId] then
		return false
	end

	saving[userId] = true
	profile.LastSave = os.time()
	local payload = TableUtils.DeepCopy(profile)

	local store = getStore()
	if not store then
		saving[userId] = false
		Logger.Debug("PlayerDataService", "In-memory save for " .. player.Name .. " (" .. (reason or "manual") .. ")")
		return true
	end

	local ok, err = withRetries("Save", function()
		store:SetAsync(keyFor(userId), payload)
		return true
	end)

	saving[userId] = false
	if not ok then
		Logger.Error("PlayerDataService", "Save failed for " .. player.Name .. ": " .. tostring(err))
		return false
	end

	Logger.Info("PlayerDataService", "Saved profile for " .. player.Name .. " (" .. (reason or "manual") .. ")")
	return true
end

function PlayerDataService.ReleaseProfile(player: Player)
	local userId = player.UserId
	PlayerDataService.SaveProfile(player, "Leave")
	profiles[userId] = nil
	sessionTokens[userId] = nil
	loadFailed[userId] = nil
	saving[userId] = nil
end

function PlayerDataService.StartAutosave()
	task.spawn(function()
		while true do
			task.wait(GameConfig.AutosaveIntervalSeconds)
			for _, player in ipairs(Players:GetPlayers()) do
				if profiles[player.UserId] then
					PlayerDataService.SaveProfile(player, "Autosave")
				end
			end
		end
	end)
end

function PlayerDataService.SaveAll(reason: string)
	for _, player in ipairs(Players:GetPlayers()) do
		PlayerDataService.SaveProfile(player, reason)
	end
end

return PlayerDataService

--[=[
	@class DataStore
	@server / client
	
	Handles optional progress saving for OnBoard tutorial sequences using Roblox DataStoreService.
]=]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataStore = {}
DataStore.__index = DataStore

local TUTORIAL_DATASTORE_NAME = "OnBoard_TutorialProgress_v1"

local function GetStore()
	local success, store = pcall(function()
		return DataStoreService:GetDataStore(TUTORIAL_DATASTORE_NAME)
	end)
	return success and store or nil
end

-- Save player tutorial progress (Step Index or Completed state)
function DataStore.SaveProgress(player: Player, tutorialId: string, stepIndex: number)
	local store = GetStore()
	if not store or not player then return end

	local key = string.format("User_%d_%s", player.UserId, tutorialId)
	pcall(function()
		store:SetAsync(key, {
			CurrentStep = stepIndex,
			Updated = os.time(),
		})
	end)
end

-- Load player tutorial progress
function DataStore.LoadProgress(player: Player, tutorialId: string): number?
	local store = GetStore()
	if not store or not player then return nil end

	local key = string.format("User_%d_%s", player.UserId, tutorialId)
	local success, data = pcall(function()
		return store:GetAsync(key)
	end)

	if success and typeof(data) == "table" and data.CurrentStep then
		return data.CurrentStep
	end
	return nil
end

return DataStore
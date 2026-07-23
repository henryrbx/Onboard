local Modules = script.Parent
local Elements = script.Parent.Parent.Elements
local Types = require(script.Parent.Parent.Types)
local Config = require(Modules.Config)
local Theme = require(Modules.Theme)
local Highlight = require(Elements.Highlight)
local Overlay = require(Elements.Overlay)
local Arrow = require(Elements.Arrow)
local Focus = require(Elements.Focus)
local Card = require(Elements.Card)
local Utils = require(script.Parent.Parent.Utils)

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Tutorial = {}
Tutorial.__index = Tutorial

export type TutorialInstance = {
	Start: (self: TutorialInstance) -> (),
	Stop: (self: TutorialInstance) -> (),
	Next: (self: TutorialInstance) -> (),
	AddStep: (self: TutorialInstance, stepConfig: any) -> TutorialInstance,
	CreateStep: (self: TutorialInstance, stepConfig: any) -> TutorialInstance,
	StepChanged: Types.Signal<any>,
	Completed: Types.Signal<any>,
	OnStepChanged: Types.Signal<any>,
	OnCompleted: Types.Signal<any>
}

function Tutorial.new(steps: { any }?, customTheme: Types.Theme?, options: table?): TutorialInstance
	local self = setmetatable({}, Tutorial)
	self._steps = steps or {}
	self._theme = customTheme or Theme.GetGlobal()
	self._currentIndex = 1

	-- Merge user options with Config defaults
	self._options = options or {}
	if self._options.DataStore == nil then
		self._options.DataStore = Config.DataStore
	end

	-- 🔴 FIX: Store signals directly on self so _loadStep can access them!
	self.StepChanged = Utils.CreateSignal()
	self.Completed = Utils.CreateSignal()

	-- Alias references for compatibility
	self.OnStepChanged = self.StepChanged
	self.OnCompleted = self.Completed

	return (self :: any) :: TutorialInstance
end

function Tutorial:AddStep(stepConfig: any): TutorialInstance
	table.insert(self._steps, stepConfig)
	return self
end

function Tutorial:CreateStep(stepConfig: any): TutorialInstance
	return self:AddStep(stepConfig)
end

function Tutorial:_clearStepVisuals()
	if self._activeHighlight then self._activeHighlight:Destroy() self._activeHighlight = nil end
	if self._activeOverlay then self._activeOverlay:Destroy() self._activeOverlay = nil end
	if self._activeArrow then self._activeArrow:Destroy() self._activeArrow = nil end
	if self._activeFocus then self._activeFocus:Destroy() self._activeFocus = nil end
	if self._activeCard then self._activeCard:Destroy() self._activeCard = nil end

	if self._activeConnections then
		for _, conn in ipairs(self._activeConnections) do
			conn:Disconnect()
		end
		self._activeConnections = nil
	end
end

-- Feature 2: Auto-advancing interaction triggers
function Tutorial:_setupTriggers(step)
	self._activeConnections = {}
	if not step.Trigger or not step.Target then return end

	local triggerType = typeof(step.Trigger) == "table" and step.Trigger.Type or step.Trigger

	if triggerType == "Click" and step.Target:IsA("GuiButton") then
		local conn = step.Target.Activated:Connect(function()
			self:Next()
		end)
		table.insert(self._activeConnections, conn)

	elseif triggerType == "ProximityPrompt" then
		local prompt = step.Target:IsA("ProximityPrompt") and step.Target or step.Target:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			local conn = prompt.Triggered:Connect(function()
				self:Next()
			end)
			table.insert(self._activeConnections, conn)
		end

	elseif triggerType == "TouchEvent" and step.Target:IsA("BasePart") then
		local conn = step.Target.Touched:Connect(function(hit)
			local player = Players.LocalPlayer
			if player and player.Character and hit:IsDescendantOf(player.Character) then
				self:Next()
			end
		end)
		table.insert(self._activeConnections, conn)
	end
end

-- Feature 5: Optional DataStore Progress Saving
function Tutorial:_saveProgress(index: number)
	if not self._options.DataStore or not self._options.DataStore.Enabled then return end

	local player = Players.LocalPlayer
	if not player then return end

	local storeName = self._options.DataStore.TutorialId or "OnBoard_TutorialProgress"
	task.spawn(function()
		pcall(function()
			local store = DataStoreService:GetDataStore(storeName)
			store:SetAsync("User_" .. player.UserId, index)
		end)
	end)
end

function Tutorial:_loadProgress(): number?
	if not self._options.DataStore or not self._options.DataStore.Enabled then return nil end

	local player = Players.LocalPlayer
	if not player then return nil end

	local storeName = self._options.DataStore.TutorialId or "OnBoard_TutorialProgress"
	local success, result = pcall(function()
		local store = DataStoreService:GetDataStore(storeName)
		return store:GetAsync("User_" .. player.UserId)
	end)

	if success and typeof(result) == "number" then
		return result
	end
	return nil
end

function Tutorial:_loadStep(index: number)
	self:_clearStepVisuals()

	local step = self._steps[index]
	if not step then
		self:Stop()
		return
	end

	step.IsActive = true

	--OnStart callback hook
	if typeof(step.OnStart) == "function" then
		task.spawn(step.OnStart)
	end

	-- Save progress to DataStore (Feature 5)
	self:_saveProgress(index)

	-- Visual Elements Setup
	if step.Highlight and step.Target then
		self._activeHighlight = Highlight.new(step.Target, self._theme)
	end

	if step.Overlay then
		self._activeOverlay = Overlay.new(step.Target, self._theme)
	end

	if step.Arrow and step.Target then
		self._activeArrow = Arrow.new(step.Target, self._theme)
	end

	if step.Focus then
		local focusConfig = typeof(step.Focus) == "table" and step.Focus or nil
		self._activeFocus = Focus.new(step.Target, focusConfig)
		self._activeFocus:Show()
	end

	-- Banner Card Setup
	local titleText = step.Title or ""
	local descText = step.Description or ""
	self._activeCard = Card.new(self._theme)
	self._activeCard:SetStep(titleText, descText, step.Target, index, #self._steps)

	-- Setup Interaction Triggers (Feature 2)
	self:_setupTriggers(step)

	-- Setup Trackers
	if step.Tracker then
		step.Tracker:Start()
		local conn = step.Tracker.Completed:Connect(function()
			self:Next()
		end)
		table.insert(self._activeConnections, conn)
	end

	self.StepChanged:Fire(step)
end

function Tutorial:Start()
	local savedStep = self:_loadProgress()
	if savedStep and savedStep <= #self._steps then
		self._currentIndex = savedStep
	else
		self._currentIndex = 1
	end

	self:_loadStep(self._currentIndex)
end

function Tutorial:Next()
	local currentStep = self._steps[self._currentIndex]

	-- Feature 6: OnComplete callback hook
	if currentStep and typeof(currentStep.OnComplete) == "function" then
		task.spawn(currentStep.OnComplete)
	end

	self._currentIndex += 1
	if self._currentIndex > #self._steps then
		self:Stop()
	else
		self:_loadStep(self._currentIndex)
	end
end

function Tutorial:Stop()
	self:_clearStepVisuals()
	self.Completed:Fire()
end

return Tutorial
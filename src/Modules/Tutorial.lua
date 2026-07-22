local Modules = script.Parent
local Elements = script.Parent.Parent.Elements
local Types = require(script.Parent.Parent.Types)
local Config = require(Modules.Config)
local Theme = require(Modules.Theme)
local Highlight = require(Elements.Highlight)
local Overlay = require(Elements.Overlay)
local Arrow = require(Elements.Arrow)
local Card = require(Elements.Card)
local Utils = require(script.Parent.Parent.Utils)

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

function Tutorial.new(steps: { any }?, customTheme: Types.Theme?): TutorialInstance
	local self = setmetatable({}, Tutorial)
	self._steps = steps or {}
	self._theme = customTheme or Theme.GetGlobal()
	self._currentIndex = 1

	-- Create signal instances
	local stepSignal = Utils.CreateSignal()
	local completedSignal = Utils.CreateSignal()

	-- Support both naming conventions (StepChanged and OnStepChanged)
	self.StepChanged = stepSignal
	self.OnStepChanged = stepSignal

	self.Completed = completedSignal
	self.OnCompleted = completedSignal

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
	if self._activeHighlight then
		self._activeHighlight:Destroy()
		self._activeHighlight = nil
	end

	if self._activeOverlay then
		self._activeOverlay:Destroy()
		self._activeOverlay = nil
	end

	if self._activeArrow then
		self._activeArrow:Destroy()
		self._activeArrow = nil
	end

	if self._activeCard then
		self._activeCard:Destroy()
		self._activeCard = nil
	end

	if self._activeTrackerConnection then
		self._activeTrackerConnection:Disconnect()
		self._activeTrackerConnection = nil
	end
end

function Tutorial:_loadStep(index: number)
	self:_clearStepVisuals()

	local step = self._steps[index]
	if not step then
		self:Stop()
		return
	end

	step.IsActive = true

	-- 1. Visual helpers
	if step.Highlight and step.Target then
		self._activeHighlight = Highlight.new(step.Target, self._theme)
	end

	if step.Overlay then
		self._activeOverlay = Overlay.new(step.Target, self._theme)
	end

	if step.Arrow and step.Target then
		self._activeArrow = Arrow.new(step.Target, self._theme)
	end

	-- 2. Banner Card UI
	local titleText = if typeof(step.Title) == "function" then step.Title() else (step.Title or "")
	local descText = if typeof(step.Description) == "function" then step.Description() else (step.Description or "")

	self._activeCard = Card.new(self._theme)
	self._activeCard:SetStep(titleText, descText, step.Target, index, #self._steps)

	-- 3. Step completion tracking
	if step.Tracker then
		step.Tracker:Start()
		self._activeTrackerConnection = step.Tracker.Completed:Connect(function()
			self:Next()
		end)
	end

	self.StepChanged:Fire(step)
end

function Tutorial:Start()
	self._currentIndex = 1
	self:_loadStep(self._currentIndex)
end

function Tutorial:Next()
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
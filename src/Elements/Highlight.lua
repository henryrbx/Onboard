local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Modules = script.Parent.Parent.Modules
local Elements = script.Parent.Parent.Elements
local Types = require(script.Parent.Parent.Types)
local Config = require(Modules.Config)
local Theme = require(Modules.Theme)
local Utils = require(script.Parent.Parent.Utils)

local Highlight = {}
Highlight.__index = Highlight

local function getPlayerGui(): PlayerGui
	local player = Players.LocalPlayer
	if not player then
		player = Players:GetPropertyChangedSignal("LocalPlayer"):Wait() :: any
		player = Players.LocalPlayer
	end
	return player:WaitForChild("PlayerGui") :: PlayerGui
end

local function getOrCreateScreenGui(): ScreenGui
	local playerGui = getPlayerGui()
	local existing = playerGui:FindFirstChild(Config.UI.ScreenGuiName)
	if existing and existing:IsA("ScreenGui") then return existing end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = Config.UI.ScreenGuiName
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = Config.UI.OverlayZIndex + 2
	screenGui.Parent = playerGui
	return screenGui
end

export type HighlightInstance = {
	Target: Types.Target,
	Destroy: (self: HighlightInstance) -> ()
}

function Highlight.new(target: Types.Target, customTheme: Types.Theme?): HighlightInstance
	local self = setmetatable({}, Highlight)
	self.Target = target
	self._theme = customTheme or Theme.GetGlobal()
	self._category = Utils.GetTargetCategory(target)

	if self._category == "UI" then
		self:_mountUIHighlight()
	elseif self._category == "World" then
		self:_mountWorldHighlight()
	end

	return (self :: any) :: HighlightInstance
end

function Highlight:_mountUIHighlight()
	local targetGui = self.Target :: GuiObject

	local highlightFrame = Instance.new("Frame")
	highlightFrame.Name = "OnBoard_WhiteHighlight"
	highlightFrame.BackgroundTransparency = 1
	highlightFrame.Size = UDim2.fromScale(1, 1)
	highlightFrame.Position = UDim2.fromScale(0, 0)
	highlightFrame.ZIndex = Config.UI.OverlayZIndex + 3
	highlightFrame.Parent = targetGui

	-- Pull stroke properties from nested Theme/Config structure
	local highlightTheme = (self._theme and self._theme.Highlight) or Config.Theme.Highlight

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = highlightTheme.Color or Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = highlightTheme.Thickness or 4
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Transparency = highlightTheme.Transparency or 0.3
	uiStroke.Parent = highlightFrame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = highlightTheme.CornerRadius or UDim.new(0, 12)
	uiCorner.Parent = highlightFrame

	-- Optional: Handle pulse animation if enabled in nested config
	if highlightTheme.Pulse and highlightTheme.Pulse.Enabled then
		local pulseTweenInfo = TweenInfo.new(
			1 / highlightTheme.Pulse.Speed,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut,
			-1,
			true
		)
		self._pulseTween = TweenService:Create(uiStroke, pulseTweenInfo, {
			Transparency = math.clamp(uiStroke.Transparency - 0.2, 0, 1)
		})
		self._pulseTween:Play()
	end

	self._uiFrame = highlightFrame
end

function Highlight:_mountWorldHighlight()
	local worldTheme = (self._theme and self._theme.WorldHighlight) or Config.Theme.WorldHighlight

	local worldHighlight = Instance.new("Highlight")
	worldHighlight.Name = "OnBoard_WorldHighlight"
	worldHighlight.FillColor = worldTheme.FillColor or Color3.fromRGB(0, 162, 255)
	worldHighlight.FillTransparency = worldTheme.FillTransparency or 0.5
	worldHighlight.OutlineColor = worldTheme.OutlineColor or Color3.fromRGB(255, 255, 255)
	worldHighlight.OutlineTransparency = worldTheme.OutlineTransparency or 0
	worldHighlight.Adornee = self.Target :: Instance
	worldHighlight.Parent = self.Target :: Instance

	self._worldHighlight = worldHighlight
end

function Highlight:Destroy()
	if self._pulseTween then
		self._pulseTween:Cancel()
		self._pulseTween = nil
	end
	if self._uiFrame then
		self._uiFrame:Destroy()
		self._uiFrame = nil
	end
	if self._worldHighlight then
		self._worldHighlight:Destroy()
		self._worldHighlight = nil
	end
end

return Highlight
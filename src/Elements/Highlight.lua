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
	local existing = playerGui:FindFirstChild(Config.UIScreenGuiName)
	if existing and existing:IsA("ScreenGui") then return existing end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = Config.UIScreenGuiName
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = Config.OverlayZIndex + 2
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
	highlightFrame.ZIndex = Config.OverlayZIndex + 3
	highlightFrame.Parent = targetGui

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 4
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = highlightFrame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = highlightFrame

	self._uiFrame = highlightFrame
end

function Highlight:_mountWorldHighlight()
	local worldHighlight = Instance.new("Highlight")
	worldHighlight.Name = "OnBoard_WorldHighlight"
	worldHighlight.FillTransparency = 1
	worldHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	worldHighlight.OutlineTransparency = 0
	worldHighlight.Adornee = self.Target :: Instance
	worldHighlight.Parent = self.Target :: Instance

	self._worldHighlight = worldHighlight
end

function Highlight:Destroy()
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)
local Config = require(script.Parent.Config)
local Theme = require(script.Parent.Theme)
local Utils = require(script.Parent.Utils)

local Overlay = {}
Overlay.__index = Overlay

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
	screenGui.DisplayOrder = Config.OverlayZIndex
	screenGui.Parent = playerGui
	return screenGui
end

export type OverlayInstance = {
	SetTarget: (self: OverlayInstance, target: Types.Target?) -> (),
	Destroy: (self: OverlayInstance) -> ()
}

function Overlay.new(targetOrTheme: any?, customTheme: Types.Theme?): OverlayInstance
	local self = setmetatable({}, Overlay)

	-- Handle argument ambiguity if Tutorial passes (target, theme) or just (theme)
	local resolvedTheme: Types.Theme
	if type(targetOrTheme) == "table" and targetOrTheme.OverlayColor ~= nil then
		resolvedTheme = targetOrTheme
	elseif customTheme then
		resolvedTheme = customTheme
	else
		resolvedTheme = Theme.GetGlobal()
	end

	self._theme = resolvedTheme
	self._target = if typeof(targetOrTheme) == "Instance" then targetOrTheme else nil
	self._renderConnection = nil :: RBXScriptConnection?

	local screenGui = getOrCreateScreenGui()

	local overlayFrame = Instance.new("Frame")
	overlayFrame.Name = "OnBoard_DimOverlay"
	overlayFrame.Size = UDim2.fromScale(1, 1)
	overlayFrame.BackgroundColor3 = self._theme.OverlayColor
	overlayFrame.BackgroundTransparency = self._theme.OverlayTransparency
	overlayFrame.ZIndex = Config.OverlayZIndex
	overlayFrame.Parent = screenGui

	self._overlayFrame = overlayFrame
	return (self :: any) :: OverlayInstance
end

function Overlay:SetTarget(target: Types.Target?)
	self._target = target
end

function Overlay:Destroy()
	if self._renderConnection then
		self._renderConnection:Disconnect()
		self._renderConnection = nil
	end
	if self._overlayFrame then
		self._overlayFrame:Destroy()
		self._overlayFrame = nil
	end
end
return Overlay

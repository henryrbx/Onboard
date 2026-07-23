--[=[
	@class Focus
	@client
	
	Renders a focus spotlight cutout overlay for 2D GuiObjects or 3D BaseParts/Models.
	Supports dynamic shapes, modal input blocking, and nested configuration overrides.
]=]

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Types = require(script.Parent.Parent.Types)

--Configuration

local DEFAULT_CONFIG = {
	Enabled = true,

	Overlay = {
		Color = Color3.fromRGB(0, 0, 0),
		Transparency = 0.45,
		BlockInput = false, --Swallows/Blocks clicks outside target cutout
	},

	Focus = {
		Padding = Vector2.new(10, 10),
		CornerRadius = UDim.new(0, 12),
		MinSize = Vector2.new(40, 40),
		Shape = "Rounded", -- Can be: "Rounded", "Circle", or "Rectangle"
	},

	Border = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 3,
		Transparency = 0.2,
	},

	Animation = {
		Enabled = false,
		Duration = 0.18,
		EasingStyle = Enum.EasingStyle.Quint,
		EasingDirection = Enum.EasingDirection.Out,
	},

	Tracking = {
		Enabled = true,
		HideWhenOffscreen = true,
		ClampToViewport = true,
	},

	Effects = {
		Pulse = false,
		PulseSpeed = 2,
		PulseAmount = 2,
		Glow = false,
	},
}

--Funtions

local function DeepMerge(defaultTable: table, overrideTable: table?): table
	local result = {}
	for k, v in pairs(defaultTable) do
		if typeof(v) == "table" then
			result[k] = DeepMerge(v, overrideTable and overrideTable[k])
		else
			result[k] = (overrideTable and overrideTable[k] ~= nil) and overrideTable[k] or v
		end
	end
	return result
end

local function GetViewportSize(): Vector2
	local camera = Workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end

local function GetGuiInset(): Vector2
	return GuiService:GetGuiInset()
end

local Focus = {}
Focus.__index = Focus
Focus.DefaultConfig = DEFAULT_CONFIG

export type FocusInstance = {
	Show: (self: FocusInstance) -> (),
	Hide: (self: FocusInstance) -> (),
	Destroy: (self: FocusInstance) -> (),
	SetTarget: (self: FocusInstance, target: Types.Target?) -> ()
}

function Focus.new(target: Types.Target?, customConfig: table?): FocusInstance
	local self = setmetatable({}, Focus)

	self._config = DeepMerge(DEFAULT_CONFIG, customConfig)
	self._target = target

	-- ScreenGui setup
	self._screenGui = Instance.new("ScreenGui")
	self._screenGui.Name = "OnBoard_FocusOverlay"
	self._screenGui.DisplayOrder = 998
	self._screenGui.IgnoreGuiInset = true
	self._screenGui.ResetOnSpawn = false
	self._screenGui.Enabled = self._config.Enabled

	-- Overlay container
	self._overlayContainer = Instance.new("Frame")
	self._overlayContainer.Name = "OverlayContainer"
	self._overlayContainer.Size = UDim2.fromScale(1, 1)
	self._overlayContainer.BackgroundTransparency = 1
	self._overlayContainer.Parent = self._screenGui

	-- Create 4 surrounding overlay frames
	self._topFrame = self:_createOverlayFrame("TopFrame")
	self._bottomFrame = self:_createOverlayFrame("BottomFrame")
	self._leftFrame = self:_createOverlayFrame("LeftFrame")
	self._rightFrame = self:_createOverlayFrame("RightFrame")

	-- Border Frame matching cutout region
	self._borderFrame = Instance.new("Frame")
	self._borderFrame.Name = "FocusBorder"
	self._borderFrame.BackgroundTransparency = 1
	self._borderFrame.Parent = self._screenGui

	if self._config.Border.Enabled then
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Name = "BorderStroke"
		uiStroke.Color = self._config.Border.Color
		uiStroke.Thickness = self._config.Border.Thickness
		uiStroke.Transparency = self._config.Border.Transparency
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = self._borderFrame
		self._uiStroke = uiStroke
	end

	-- Shape / UICorner configuration (Feature 1)
	local shape = self._config.Focus.Shape
	if shape == "Circle" or shape == "Rounded" then
		local uiCorner = Instance.new("UICorner")
		if shape == "Circle" then
			uiCorner.CornerRadius = UDim.new(1, 0)
		else
			uiCorner.CornerRadius = self._config.Focus.CornerRadius
		end
		uiCorner.Parent = self._borderFrame
	end

	-- Glow Effect Setup
	if self._config.Effects.Glow and self._config.Border.Enabled then
		local glowStroke = Instance.new("UIStroke")
		glowStroke.Name = "GlowStroke"
		glowStroke.Color = self._config.Border.Color
		glowStroke.Thickness = self._config.Border.Thickness * 2.5
		glowStroke.Transparency = math.clamp(self._config.Border.Transparency + 0.5, 0, 0.95)
		glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		glowStroke.Parent = self._borderFrame
	end

	-- Parent ScreenGui
	local player = Players.LocalPlayer
	if player then
		local playerGui = player:WaitForChild("PlayerGui", 5)
		if playerGui then
			self._screenGui.Parent = playerGui
		end
	end

	self:_updateBounds()

	-- Tracking loop
	if self._config.Tracking.Enabled then
		self._renderConn = RunService.RenderStepped:Connect(function()
			self:_updateBounds()
		end)
	end

	-- Pulse Animation
	if self._config.Effects.Pulse and self._uiStroke then
		self:_startPulseAnimation()
	end

	return (self :: any) :: FocusInstance
end

function Focus:_createOverlayFrame(name: string): ImageButton
	local button = Instance.new("ImageButton")
	button.Name = name
	button.BackgroundColor3 = self._config.Overlay.Color
	button.BackgroundTransparency = self._config.Overlay.Transparency
	button.BorderSizePixel = 0
	button.AutoButtonColor = false

	-- Active controls whether it registers UI input
	button.Active = self._config.Overlay.BlockInput

	-- Interactable controls whether inputs (like camera drag) pass through
	button.Interactable = self._config.Overlay.BlockInput

	button.Parent = self._overlayContainer
	return button
end

function Focus:_calculateTargetBounds(): (Vector2, Vector2)
	local vp = GetViewportSize()
	local inset = GetGuiInset()

	if not self._target then
		local center = vp / 2
		local halfSize = self._config.Focus.MinSize / 2
		return center - halfSize, center + halfSize
	end

	if typeof(self._target) == "Instance" then
		if self._target:IsA("GuiObject") then
			local absPos = self._target.AbsolutePosition + inset
			local absSize = self._target.AbsoluteSize

			local targetWidth = math.max(absSize.X, self._config.Focus.MinSize.X)
			local targetHeight = math.max(absSize.Y, self._config.Focus.MinSize.Y)
			local targetSize = Vector2.new(targetWidth, targetHeight)

			-- If Circle shape, enforce square bounds so aspect ratio stays round
			if self._config.Focus.Shape == "Circle" then
				local maxDim = math.max(targetWidth, targetHeight)
				targetSize = Vector2.new(maxDim, maxDim)
			end

			local minPos = absPos - self._config.Focus.Padding
			local maxPos = absPos + targetSize + self._config.Focus.Padding
			return minPos, maxPos

		elseif self._target:IsA("BasePart") or self._target:IsA("Model") then
			local camera = Workspace.CurrentCamera
			if not camera then
				return Vector2.zero, vp
			end

			local cframe, size
			if self._target:IsA("BasePart") then
				cframe = self._target.CFrame
				size = self._target.Size
			else
				cframe, size = self._target:GetBoundingBox()
			end

			local halfSize = size / 2
			local corners = {
				cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
				cframe * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
				cframe * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
				cframe * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
			}

			local minX, minY = math.huge, math.huge
			local maxX, maxY = -math.huge, -math.huge
			local hasVisibleCorner = false

			for _, corner in ipairs(corners) do
				local screenPos, isVisible = camera:WorldToViewportPoint(corner)
				if isVisible then
					hasVisibleCorner = true
					minX = math.min(minX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxX = math.max(maxX, screenPos.X)
					maxY = math.max(maxY, screenPos.Y)
				end
			end

			if not hasVisibleCorner and self._config.Tracking.HideWhenOffscreen then
				return Vector2.zero, Vector2.zero
			end

			local minPos = Vector2.new(minX, minY) - self._config.Focus.Padding
			local maxPos = Vector2.new(maxX, maxY) + self._config.Focus.Padding
			return minPos, maxPos
		end
	end

	return Vector2.zero, vp
end

function Focus:_updateBounds()
	local vp = GetViewportSize()
	local rawMin, rawMax = self:_calculateTargetBounds()

	if rawMin == Vector2.zero and rawMax == Vector2.zero then
		self._screenGui.Enabled = false
		return
	else
		if self._config.Enabled then
			self._screenGui.Enabled = true
		end
	end

	local minX = math.floor(rawMin.X)
	local minY = math.floor(rawMin.Y)
	local maxX = math.ceil(rawMax.X)
	local maxY = math.ceil(rawMax.Y)

	if self._config.Tracking.ClampToViewport then
		minX = math.clamp(minX, 0, vp.X)
		minY = math.clamp(minY, 0, vp.Y)
		maxX = math.clamp(maxX, 0, vp.X)
		maxY = math.clamp(maxY, 0, vp.Y)
	end

	local cutoutWidth = math.max(0, maxX - minX)
	local cutoutHeight = math.max(0, maxY - minY)

	-- Seamless Non-overlapping bounds math
	self._topFrame.Position = UDim2.fromOffset(0, 0)
	self._topFrame.Size = UDim2.fromOffset(vp.X, minY)

	self._bottomFrame.Position = UDim2.fromOffset(0, maxY)
	self._bottomFrame.Size = UDim2.fromOffset(vp.X, math.max(0, vp.Y - maxY))

	self._leftFrame.Position = UDim2.fromOffset(0, minY)
	self._leftFrame.Size = UDim2.fromOffset(minX, cutoutHeight)

	self._rightFrame.Position = UDim2.fromOffset(maxX, minY)
	self._rightFrame.Size = UDim2.fromOffset(math.max(0, vp.X - maxX), cutoutHeight)

	self._borderFrame.Position = UDim2.fromOffset(minX, minY)
	self._borderFrame.Size = UDim2.fromOffset(cutoutWidth, cutoutHeight)
end

function Focus:_startPulseAnimation()
	if not self._uiStroke then return end

	local baseThickness = self._config.Border.Thickness
	local pulseThickness = baseThickness + self._config.Effects.PulseAmount

	local tweenInfo = TweenInfo.new(
		1 / self._config.Effects.PulseSpeed,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1,
		true
	)

	self._pulseTween = TweenService:Create(self._uiStroke, tweenInfo, {
		Thickness = pulseThickness,
		Transparency = math.clamp(self._config.Border.Transparency - 0.1, 0, 1)
	})
	self._pulseTween:Play()
end

function Focus:SetTarget(target: Types.Target?)
	self._target = target
	self:_updateBounds()
end

function Focus:Show()
	self._screenGui.Enabled = true
end

function Focus:Hide()
	self._screenGui.Enabled = false
end

function Focus:Destroy()
	if self._renderConn then
		self._renderConn:Disconnect()
		self._renderConn = nil
	end

	if self._pulseTween then
		self._pulseTween:Cancel()
		self._pulseTween = nil
	end

	if self._screenGui then
		self._screenGui:Destroy()
		self._screenGui = nil :: any
	end
end

return Focus
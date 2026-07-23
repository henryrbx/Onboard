local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Modules = script.Parent.Parent.Modules
local Elements = script.Parent.Parent.Elements
local Types = require(script.Parent.Parent.Types)
local Config = require(Modules.Config)
local Theme = require(Modules.Theme)
local Utils = require(script.Parent.Parent.Utils)

local Arrow = {}
Arrow.__index = Arrow

local HAND_EMOJIS = {
	PointDown  = "👇",
	PointUp    = "☝️",
	PointRight = "👉",
	PointLeft  = "👈",
}

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
	screenGui.DisplayOrder = Config.OverlayZIndex + 10
	screenGui.Parent = playerGui
	return screenGui
end

export type ArrowInstance = {
	Target: Types.Target,
	Destroy: (self: ArrowInstance) -> ()
}

function Arrow.new(target: Types.Target, customTheme: Types.Theme?): ArrowInstance
	local self = setmetatable({}, Arrow)
	self.Target = target
	self._theme = customTheme or Theme.GetGlobal()
	self._category = Utils.GetTargetCategory(target)
	self._renderConnection = nil :: RBXScriptConnection?

	if self._category == "UI" then
		self:_mountUIArrow()
	elseif self._category == "World" then
		self:_mountWorldArrow()
	end

	return (self :: any) :: ArrowInstance
end

function Arrow:_mountUIArrow()
	local screenGui = getOrCreateScreenGui()
	local pointer = Instance.new("TextLabel")
	pointer.Name = "OnBoard_UIPointer"
	pointer.Size = UDim2.fromOffset(60, 60)
	pointer.BackgroundTransparency = 1
	pointer.Text = HAND_EMOJIS.PointDown
	pointer.TextSize = 40
	pointer.ZIndex = Config.OverlayZIndex + 50
	pointer.Parent = screenGui
	self._uiPointer = pointer

	local animationAngle = 0
	self._renderConnection = RunService.RenderStepped:Connect(function(dt)
		local bounds = Utils.GetTargetScreenBounds(self.Target)
		if bounds then
			pointer.Visible = true

			animationAngle += dt * 5
			local bounce = (math.sin(animationAngle) + 1) * 4
			local camera = workspace.CurrentCamera
			local viewportY = if camera then camera.ViewportSize.Y else 720

			-- Center X over target UI
			local centerX = bounds.Center.X
			if bounds.Center.Y < (viewportY * 0.35) then
				pointer.AnchorPoint = Vector2.new(0.5, 0)
				pointer.Text = HAND_EMOJIS.PointUp
				local baseY = bounds.Max.Y + 25 
				pointer.Position = UDim2.fromOffset(centerX, baseY + bounce)
			else
				pointer.AnchorPoint = Vector2.new(0.5, 1)
				pointer.Text = HAND_EMOJIS.PointDown

				-- Lowest point of bounce keeps tip 12px completely clear above button
				local MIN_GAP_ABOVE_BUTTON = 12 
				local EMOJI_PADDING_OFFSET = 32 

				local baseY = bounds.Min.Y - (MIN_GAP_ABOVE_BUTTON + EMOJI_PADDING_OFFSET)
				pointer.Position = UDim2.fromOffset(centerX, baseY - bounce)
			end
		else
			pointer.Visible = false
		end
	end)
end

function Arrow:_mountWorldArrow()
	local root = Utils.GetLocalCharacterRoot()
	if not root then
		task.spawn(function()
			local player = Players.LocalPlayer
			if player then
				player.CharacterAdded:Wait()
				task.wait(0.2)
				if not self._beamAttachment0 then
					self:_mountWorldArrow()
				end
			end
		end)
		return
	end

	local att0 = Instance.new("Attachment")
	att0.Name = "OnBoard_BeamAtt0"
	--att0.Position = Vector3.new(0, -2.5, 0)
	att0.Position = Vector3.new(0, 0, 0)
	att0.Parent = root

	local att1 = Instance.new("Attachment")
	att1.Name = "OnBoard_BeamAtt1"

	if self.Target:IsA("BasePart") then
		att1.Parent = self.Target
	elseif self.Target:IsA("Model") then
		local primary = self.Target.PrimaryPart or self.Target:FindFirstChildOfClass("BasePart")
		if primary then att1.Parent = primary end
	elseif self.Target:IsA("Attachment") then
		att1 = self.Target
	end

	if not att1.Parent and not self.Target:IsA("Attachment") then
		att0:Destroy()
		return
	end

	local beam = Instance.new("Beam")
	beam.Name = "OnBoard_GuideBeam"

	-- Keeps arrowheads facing toward the target ➡️
	beam.Attachment0 = att1
	beam.Attachment1 = att0

	beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	beam.Width0 = Config.Theme.ArrowWidth0
	beam.Width1 = Config.Theme.ArrowWidth1
	beam.Texture = Config.Theme and Config.Theme.ArrowBeamTexture or "rbxassetid://7072706663"
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.TextureLength = 4
	beam.FaceCamera = true

	-- POSITIVE SPEED: Scrolls the arrows outward from player to target
	beam.TextureSpeed = Config.Theme.ArrowTextureSpeed
	beam.Parent = att0

	self._beamAttachment0 = att0
	self._beamAttachment1 = if att1 ~= self.Target then att1 else nil
	self._beam = beam

	self._renderConnection = RunService.RenderStepped:Connect(function()
		local currentRoot = Utils.GetLocalCharacterRoot()
		if currentRoot and self._beamAttachment0 and self._beamAttachment0.Parent ~= currentRoot then
			self._beamAttachment0.Parent = currentRoot
		end
	end)
end

function Arrow:Destroy()
	if self._renderConnection then
		self._renderConnection:Disconnect()
		self._renderConnection = nil
	end
	if self._uiPointer then
		self._uiPointer:Destroy()
		self._uiPointer = nil
	end
	if self._beam then
		self._beam:Destroy()
		self._beam = nil
	end
	if self._beamAttachment0 then
		self._beamAttachment0:Destroy()
		self._beamAttachment0 = nil
	end
	if self._beamAttachment1 then
		self._beamAttachment1:Destroy()
		self._beamAttachment1 = nil
	end
end

return Arrow
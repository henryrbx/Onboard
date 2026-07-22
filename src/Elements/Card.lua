local Players = game:GetService("Players")

local Modules = script.Parent.Parent.Modules
local Elements = script.Parent.Parent.Elements
local Types = require(Elements.Parent.Types)
local Config = require(Modules.Config)
local Theme = require(Modules.Theme)

local Card = {}
Card.__index = Card

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
	screenGui.DisplayOrder = Config.OverlayZIndex + 50 -- Raised DisplayOrder for ScreenGui
	screenGui.Parent = playerGui
	return screenGui
end

export type CardInstance = {
	SetStep: (self: CardInstance, title: string, text: string, target: Types.Target?, stepIndex: number, totalSteps: number) -> (),
	Destroy: (self: CardInstance) -> ()
}

function Card.new(customTheme: Types.Theme?): CardInstance
	local self = setmetatable({}, Card)
	-- Pull from custom theme, or fallback to Config's global theme
	local theme = customTheme or (Config and Config.Theme) or {}
	self._theme = theme

	local screenGui = getOrCreateScreenGui()

	-- Clear any legacy card frame if it exists
	local oldCard = screenGui:FindFirstChild("OnBoard_TopBannerCard")
	if oldCard then oldCard:Destroy() end

	-- Extract theme settings with safe defaults
	local titleSize = theme.TitleSize or 22
	local descSize = theme.DescriptionSize or 16
	local textColor = theme.TextColor or Color3.fromRGB(255, 255, 255)

	-- Font handling: supports Font objects (Font.fromEnum) or Enum.Font values
	local fontValue = theme.Font or Enum.Font.BuilderSans
	local actualFontFace: Font? = if typeof(fontValue) == "Font" then fontValue else nil
	local actualEnumFont: Enum.Font? = if typeof(fontValue) == "EnumItem" then fontValue else Enum.Font.BuilderSans

	-- Top-Center Floating Banner
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "OnBoard_TopBannerCard"
	cardFrame.Size = UDim2.fromOffset(480, 90)
	cardFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	cardFrame.Position = UDim2.new(0.5, 0, 0.04, 0) -- Top Center
	cardFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	cardFrame.BackgroundTransparency = 0.2
	cardFrame.ZIndex = Config.OverlayZIndex + 50
	cardFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = cardFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 2.4
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = cardFrame
	stroke.Transparency = 0.4

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -20, 0, 36)
	titleLabel.Position = UDim2.fromOffset(10, 12)
	titleLabel.BackgroundTransparency = 1

	-- Apply font properly depending on type
	if actualFontFace then
		titleLabel.FontFace = actualFontFace
	else
		titleLabel.Font = actualEnumFont :: Enum.Font
	end

	titleLabel.TextColor3 = textColor
	titleLabel.TextSize = titleSize
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = Config.OverlayZIndex + 51
	titleLabel.Parent = cardFrame

	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 220, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 240))
	})
	titleGradient.Rotation = 90
	titleGradient.Parent = titleLabel

	local titleStroke = Instance.new("UIStroke")
	titleStroke.Thickness = 2
	titleStroke.Color = Color3.fromRGB(0, 0, 0)
	titleStroke.Parent = titleLabel

	-- Description Text
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -20, 0, 36)
	textLabel.Position = UDim2.fromOffset(10, 46)
	textLabel.BackgroundTransparency = 1

	-- Apply font properly depending on type
	if actualFontFace then
		textLabel.FontFace = actualFontFace
	else
		textLabel.Font = actualEnumFont :: Enum.Font
	end

	textLabel.TextColor3 = textColor
	textLabel.TextSize = descSize
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.ZIndex = Config.OverlayZIndex + 51
	textLabel.Parent = cardFrame

	local textStroke = Instance.new("UIStroke")
	textStroke.Thickness = 1.5
	textStroke.Color = Color3.fromRGB(0, 0, 0)
	textStroke.Parent = textLabel

	self._cardFrame = cardFrame
	self._titleLabel = titleLabel
	self._textLabel = textLabel

	return (self :: any) :: CardInstance
end

function Card:SetStep(title: string, text: string, target: Types.Target?, stepIndex: number, totalSteps: number)
	if self._titleLabel then self._titleLabel.Text = title end
	if self._textLabel then self._textLabel.Text = text end
end

function Card:Destroy()
	if self._cardFrame then
		self._cardFrame:Destroy()
		self._cardFrame = nil
	end
end

return Card
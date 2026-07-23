local Types = require(script.Parent.Parent.Types)

--[=[
	@class Config
	Global configuration and defaults for OnBoard.
]=]

local Config: Types.Config = {
	Theme = {
		-- Typography
		Font = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		TitleSize = 26,
		DescriptionSize = 20,

		-- Colors
		PrimaryColor = Color3.fromRGB(0, 162, 255),
		SecondaryColor = Color3.fromRGB(240, 240, 240),
		TextColor = Color3.fromRGB(255, 255, 255),

		-- Overlay
		OverlayColor = Color3.fromRGB(0, 0, 0),
		OverlayTransparency = 0.6,

		-- Highlight (UI)
		HighlightColor = Color3.fromRGB(255, 244, 253),
		HighlightThickness = 3,
		HighlightCornerRadius = UDim.new(0, 8),
		HighlightPulseSpeed = 2,
		HighlightTransparency = 0.3,

		-- Highlight (World)
		WorldHighlightFillColor = Color3.fromRGB(0, 162, 255),
		WorldHighlightFillTransparency = 0.5,
		WorldHighlightOutlineColor = Color3.fromRGB(255, 255, 255),
		WorldHighlightOutlineTransparency = 0,

		-- Arrow
		ArrowColor = Color3.fromRGB(0, 162, 255),
		ArrowSize = UDim2.fromOffset(40, 40),
		ArrowBeamTexture = "rbxassetid://98078426234204",
		ArrowBeamWidth = 1.5,
		ArrowWidth0 = 5.5,
		ArrowWidth1 = 5.5,
		ArrowTextureSpeed = 1.5,
		
		ArrowStrokeColor = Color3.fromRGB(0, 0, 0),
		ArrowStrokeThickness = 2.5,
		ArrowStrokeTransparency = 0.2,

		-- Animations
		TweenSpeed = 0.35,
		TweenEasingStyle = Enum.EasingStyle.Quad,
		TweenEasingDirection = Enum.EasingDirection.Out,
	},

	-- Default Step Behaviors
	DefaultHighlight = true,
	DefaultOverlay = true,
	DefaultArrow = true,

	-- Framework Settings
	UseDefaultUI = true,
	UIScreenGuiName = "OnBoard_CoreGui",
	OverlayZIndex = 100,
	CoreUIZIndex = 101,
}

return Config
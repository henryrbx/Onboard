local Types = require(script.Parent.Parent.Types)

--[=[
	@class Config
	Global configuration and defaults for OnBoard.
]=]

local Config: Types.Config = {

	Theme = {

		-- Typography
		UI = {
			Font = Font.fromEnum(Enum.Font.BuilderSansExtraBold),

			TitleSize = 26,
			DescriptionSize = 20,
		},

		-- Shared Colors
		Colors = {
			Primary = Color3.fromRGB(0, 162, 255),
			Secondary = Color3.fromRGB(240, 240, 240),
			Text = Color3.fromRGB(255, 255, 255),
		},

		-- Fullscreen Overlay
		Overlay = {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.6,
		},

		-- UI Highlight
		Highlight = {
			Color = Color3.fromRGB(255, 244, 253),
			Transparency = 0.3,

			Thickness = 3,
			CornerRadius = UDim.new(0, 8),

			Pulse = {
				Enabled = true,
				Speed = 2,
			},
		},

		-- 3D World Highlight
		WorldHighlight = {
			FillColor = Color3.fromRGB(0, 162, 255),
			FillTransparency = 0.5,

			OutlineColor = Color3.fromRGB(255, 255, 255),
			OutlineTransparency = 0,
		},

		-- Direction Arrow
		Arrow = {

			Color = Color3.fromRGB(0, 162, 255),
			Size = UDim2.fromOffset(40, 40),

			Stroke = {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2.5,
				Transparency = 0.2,
			},

			Beam = {
				Texture = "rbxassetid://98078426234204",

				Width = 1.5,
				Width0 = 5.5,
				Width1 = 5.5,

				TextureSpeed = 1.5,
			},
		},

		-- Shared Animation Settings
		Animation = {
			Duration = 0.35,
			Style = Enum.EasingStyle.Quad,
			Direction = Enum.EasingDirection.Out,
		},
	},
	-- Default Step Behaviour

	Defaults = {
		Highlight = true,
		Overlay = true,
		Arrow = true,
		Focus = false,
	},

	-- Default UI

	UI = {
		Enabled = true,

		ScreenGuiName = "OnBoard_CoreGui",

		OverlayZIndex = 100,
		CoreZIndex = 101,
	},

	-- Progress Saving

	DataStore = {
		Enabled = true,
		TutorialId = "OnBoard_MainProgress_v1",

		SaveOnStepChange = true,
	},
}

return Config
local Types = require(script.Parent.Parent.Types)
local Config = require(script.Parent.Parent.Modules.Config)

--[=[
	@class Theme
	Runtime theme manager providing dynamic styling, override capabilities, and event signals.
]=]

local Theme = {}
Theme.__index = Theme

export type CustomTheme = {
	Current: Types.Theme,
	Changed: Types.Signal<Types.Theme>,
	Update: (self: CustomTheme, newTheme: PartialTheme) -> (),
	Destroy: (self: CustomTheme) -> ()
}

export type PartialTheme = {
	Font: (Font | Enum.Font)?,
	TitleSize: number?,
	DescriptionSize: number?,
	PrimaryColor: Color3?,
	SecondaryColor: Color3?,
	TextColor: Color3?,
	OverlayColor: Color3?,
	OverlayTransparency: number?,
	HighlightColor: Color3?,
	HighlightThickness: number?,
	HighlightCornerRadius: UDim?,
	HighlightPulseSpeed: number?,
	WorldHighlightFillColor: Color3?,
	WorldHighlightFillTransparency: number?,
	WorldHighlightOutlineColor: Color3?,
	WorldHighlightOutlineTransparency: number?,
	ArrowColor: Color3?,
	ArrowSize: UDim2?,
	ArrowBeamTexture: string?,
	ArrowBeamWidth: number?,
	TweenSpeed: number?,
	TweenEasingStyle: Enum.EasingStyle?,
	TweenEasingDirection: Enum.EasingDirection?,

	-- Support nested sub-tables directly
	UI: {
		Font: (Font | Enum.Font)?,
		TitleSize: number?,
		DescriptionSize: number?,
	}?,
	Colors: {
		Primary: Color3?,
		Secondary: Color3?,
		Text: Color3?,
	}?,
	Overlay: {
		Color: Color3?,
		Transparency: number?,
	}?,
	Highlight: {
		Color: Color3?,
		Thickness: number?,
		CornerRadius: UDim?,
		PulseSpeed: number?,
	}?,
	WorldHighlight: {
		FillColor: Color3?,
		FillTransparency: number?,
		OutlineColor: Color3?,
		OutlineTransparency: number?,
	}?,
	Arrow: {
		Color: Color3?,
		Size: UDim2?,
		BeamTexture: string?,
		BeamWidth: number?,
	}?,
	Tween: {
		Speed: number?,
		EasingStyle: Enum.EasingStyle?,
		EasingDirection: Enum.EasingDirection?,
	}?
}

-- Typed generic signal constructor compatible with Luau strict mode
local function createSignal(): Types.Signal<any>
	local listeners: { (any) -> () } = {}

	local signalObj = {}

	function signalObj:Connect(callback: (any) -> ())
		table.insert(listeners, callback)
		return {
			Disconnect = function()
				local index = table.find(listeners, callback)
				if index then
					table.remove(listeners, index)
				end
			end
		}
	end

	function signalObj:Wait()
		local thread = coroutine.running()
		local connection: any
		connection = self:Connect(function(...)
			connection.Disconnect()
			task.spawn(thread, ...)
		end)
		return coroutine.yield()
	end

	function signalObj:Fire(...)
		for _, callback in ipairs(listeners) do
			task.spawn(callback, ...)
		end
	end

	function signalObj:DisconnectAll()
		table.clear(listeners)
	end

	function signalObj:Destroy()
		self:DisconnectAll()
	end

	return (signalObj :: any) :: Types.Signal<any>
end

local function deepCopyTable<T>(target: T): T
	if typeof(target) ~= "table" then
		return target
	end

	local copy = {}
	for key, value in pairs(target :: any) do
		if typeof(value) == "table" then
			copy[key] = deepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy :: any
end

-- Merges legacy flat key-value pairs or sub-tables safely into the target theme object
local function applyOverrides(targetTheme: any, overrides: PartialTheme)
	for key, value in pairs(overrides) do
		if value == nil then continue end

		-- 1. Handle direct sub-table assignment (e.g. overrides.Colors = { Primary = ... })
		if type(value) == "table" and targetTheme[key] ~= nil and type(targetTheme[key]) == "table" then
			for subKey, subValue in pairs(value) do
				targetTheme[key][subKey] = subValue
			end
			continue
		end

		-- 2. Map legacy flat property keys to their corresponding nested paths
		if key == "Font" and targetTheme.UI then targetTheme.UI.Font = value
		elseif key == "TitleSize" and targetTheme.UI then targetTheme.UI.TitleSize = value
		elseif key == "DescriptionSize" and targetTheme.UI then targetTheme.UI.DescriptionSize = value
		elseif key == "PrimaryColor" and targetTheme.Colors then targetTheme.Colors.Primary = value
		elseif key == "SecondaryColor" and targetTheme.Colors then targetTheme.Colors.Secondary = value
		elseif key == "TextColor" and targetTheme.Colors then targetTheme.Colors.Text = value
		elseif key == "OverlayColor" and targetTheme.Overlay then targetTheme.Overlay.Color = value
		elseif key == "OverlayTransparency" and targetTheme.Overlay then targetTheme.Overlay.Transparency = value
		elseif key == "HighlightColor" and targetTheme.Highlight then targetTheme.Highlight.Color = value
		elseif key == "HighlightThickness" and targetTheme.Highlight then targetTheme.Highlight.Thickness = value
		elseif key == "HighlightCornerRadius" and targetTheme.Highlight then targetTheme.Highlight.CornerRadius = value
		elseif key == "HighlightPulseSpeed" and targetTheme.Highlight then targetTheme.Highlight.PulseSpeed = value
		elseif key == "WorldHighlightFillColor" and targetTheme.WorldHighlight then targetTheme.WorldHighlight.FillColor = value
		elseif key == "WorldHighlightFillTransparency" and targetTheme.WorldHighlight then targetTheme.WorldHighlight.FillTransparency = value
		elseif key == "WorldHighlightOutlineColor" and targetTheme.WorldHighlight then targetTheme.WorldHighlight.OutlineColor = value
		elseif key == "WorldHighlightOutlineTransparency" and targetTheme.WorldHighlight then targetTheme.WorldHighlight.OutlineTransparency = value
		elseif key == "ArrowColor" and targetTheme.Arrow then targetTheme.Arrow.Color = value
		elseif key == "ArrowSize" and targetTheme.Arrow then targetTheme.Arrow.Size = value
		elseif key == "ArrowBeamTexture" and targetTheme.Arrow then targetTheme.Arrow.BeamTexture = value
		elseif key == "ArrowBeamWidth" and targetTheme.Arrow then targetTheme.Arrow.BeamWidth = value
		elseif key == "TweenSpeed" and targetTheme.Tween then targetTheme.Tween.Speed = value
		elseif key == "TweenEasingStyle" and targetTheme.Tween then targetTheme.Tween.EasingStyle = value
		elseif key == "TweenEasingDirection" and targetTheme.Tween then targetTheme.Tween.EasingDirection = value
		elseif targetTheme[key] ~= nil then
			targetTheme[key] = value
		end
	end
end

-- Default global active theme state initialized from Config
local globalTheme: Types.Theme = deepCopyTable(Config.Theme)
local globalChangedSignal = createSignal()

--[=[
	Retrieves the global default theme.
]=]
function Theme.GetGlobal(): Types.Theme
	return globalTheme
end

--[=[
	Updates global theme properties and fires the global theme update signal.
]=]
function Theme.SetGlobal(overrides: PartialTheme): ()
	applyOverrides(globalTheme, overrides)
	globalChangedSignal:Fire(globalTheme)
end

--[=[
	Signal fired whenever the global theme updates.
]=]
Theme.GlobalChanged = globalChangedSignal

--[=[
	Creates a new isolated instance-level theme derived from the current global theme.
]=]
function Theme.new(overrides: PartialTheme?): CustomTheme
	local themeInstance: Types.Theme = deepCopyTable(globalTheme)

	if overrides then
		applyOverrides(themeInstance, overrides)
	end

	local changedSignal = createSignal()

	return {
		Current = themeInstance,
		Changed = changedSignal,
		Update = function(customSelf, newOverrides: PartialTheme)
			applyOverrides(customSelf.Current, newOverrides)
			customSelf.Changed:Fire(customSelf.Current)
		end,
		Destroy = function(customSelf)
			customSelf.Changed:Destroy()
		end
	}
end

return Theme
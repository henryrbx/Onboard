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
	Font: Font?,
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
	TweenEasingDirection: Enum.EasingDirection?
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
	for key, value in pairs(overrides) do
		if (globalTheme :: any)[key] ~= nil then
			(globalTheme :: any)[key] = value
		end
	end
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
		for key, value in pairs(overrides) do
			if (themeInstance :: any)[key] ~= nil then
				(themeInstance :: any)[key] = value
			end
		end
	end

	local changedSignal = createSignal()

	return {
		Current = themeInstance,
		Changed = changedSignal,
		Update = function(customSelf, newOverrides: PartialTheme)
			for key, value in pairs(newOverrides) do
				if (customSelf.Current :: any)[key] ~= nil then
					(customSelf.Current :: any)[key] = value
				end
			end
			customSelf.Changed:Fire(customSelf.Current)
		end,
		Destroy = function(customSelf)
			customSelf.Changed:Destroy()
		end
	}
end

return Theme
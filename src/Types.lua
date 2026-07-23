--[=[
	@class Types
	@ignore
	
	Shared type definitions for the OnBoard framework.
]=]

--==================================================
-- CORE TYPES
--==================================================

-- Represents anything in the world or UI that can be targeted by a tutorial step.
export type Target = 
	GuiObject 
| BasePart 
| Model 
| Folder 
| Attachment 
| PVInstance

-- Supports both static strings and reactive functions for dynamic UI updates.
export type DynamicText = string | () -> string

-- Standard event signature for framework signals.
export type Signal<T... = ...any> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> any,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> ()
}

--==================================================
-- TRACKER SYSTEM
--==================================================

-- Base interface for all Trackers (Number, Boolean, Zone, Signal, Click, Timer, etc.)
export type Tracker = {
	Current: (self: Tracker) -> any,
	Goal: any,
	Progress: (self: Tracker) -> number,
	Completed: Signal<>,

	Start: (self: Tracker) -> (),
	Stop: (self: Tracker) -> (),
	Destroy: (self: Tracker) -> ()
}

--==================================================
-- STEP CONFIGURATION
--==================================================

export type StepConfig = {
	Id: string,
	Title: DynamicText?,
	Description: DynamicText?,
	Target: Target?,

	-- Visual overrides (defaults fallback to Config.lua)
	Highlight: boolean?,
	Overlay: boolean?,
	Arrow: boolean?,

	Tracker: Tracker?
}

-- Internal representation of a Step once processed by the framework
export type Step = StepConfig & {
	Index: number,
	IsActive: boolean
}

--==================================================
-- THEME & CONFIGURATION
--==================================================

export type Theme = {
	-- Typography
	Font: Font,
	TitleSize: number,
	DescriptionSize: number,

	-- Colors
	PrimaryColor: Color3,
	SecondaryColor: Color3,
	TextColor: Color3,

	-- Overlay
	OverlayColor: Color3,
	OverlayTransparency: number,

	-- Highlight (UI)
	HighlightColor: Color3,
	HighlightThickness: number,
	HighlightCornerRadius: UDim,
	HighlightPulseSpeed: number,
	HighlightTransparency: number?,

	-- Highlight (World)
	WorldHighlightFillColor: Color3,
	WorldHighlightFillTransparency: number,
	WorldHighlightOutlineColor: Color3,
	WorldHighlightOutlineTransparency: number,

	-- Arrow
	ArrowColor: Color3,
	ArrowSize: UDim2,
	ArrowBeamTexture: string,
	ArrowBeamWidth: number,
	ArrowWidth0: number,
	ArrowWidth1: number,
	ArrowTextureSpeed: number,

	-- Animations
	TweenSpeed: number,
	TweenEasingStyle: Enum.EasingStyle,
	TweenEasingDirection: Enum.EasingDirection
}

export type Config = {
	Theme: Theme,

	-- Default step behaviors
	DefaultHighlight: boolean,
	DefaultOverlay: boolean,
	DefaultArrow: boolean,

	-- Framework settings
	UseDefaultUI: boolean,
	UIScreenGuiName: string,
	OverlayZIndex: number,
	CoreUIZIndex: number
}

--==================================================
-- PUBLIC API INTERFACE
--==================================================

export type Tutorial = {
	-- Methods
	AddStep: (self: Tutorial, config: StepConfig) -> (),
	Start: (self: Tutorial) -> (),
	Pause: (self: Tutorial) -> (),
	Resume: (self: Tutorial) -> (),
	Next: (self: Tutorial) -> (),
	Previous: (self: Tutorial) -> (),
	Skip: (self: Tutorial) -> (),
	Stop: (self: Tutorial) -> (),
	Reset: (self: Tutorial) -> (),
	Destroy: (self: Tutorial) -> (),

	-- State
	IsPlaying: boolean,
	IsPaused: boolean,
	CurrentStepIndex: number,

	-- Events
	Started: Signal<>,
	Paused: Signal<>,
	Resumed: Signal<>,
	StepChanged: Signal<Step>,
	StepCompleted: Signal<Step>,
	Completed: Signal<>,
	Cancelled: Signal<>
}

return {}
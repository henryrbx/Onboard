--[=[
	@class Types
	Central type definitions for OnBoard.
]=]

local Types = {}

-- Visual / UI Types
export type TypographyConfig = {
	Font: Font,
	TitleSize: number,
	DescriptionSize: number,
}

export type ColorsConfig = {
	Primary: Color3,
	Secondary: Color3,
	Text: Color3,
}

export type OverlayConfig = {
	Color: Color3,
	Transparency: number,
}

export type PulseConfig = {
	Enabled: boolean,
	Speed: number,
}

export type HighlightConfig = {
	Color: Color3,
	Transparency: number,
	Thickness: number,
	CornerRadius: UDim,
	Pulse: PulseConfig,
}

export type WorldHighlightConfig = {
	FillColor: Color3,
	FillTransparency: number,
	OutlineColor: Color3,
	OutlineTransparency: number,
}

export type StrokeConfig = {
	Color: Color3,
	Thickness: number,
	Transparency: number,
}

export type BeamConfig = {
	Texture: string,
	Width: number,
	Width0: number,
	Width1: number,
	TextureSpeed: number,
}

export type ArrowConfig = {
	Color: Color3,
	Size: UDim2,
	Stroke: StrokeConfig,
	Beam: BeamConfig,
}

export type AnimationConfig = {
	Duration: number,
	Style: Enum.EasingStyle,
	Direction: Enum.EasingDirection,
}

-- Theme Table Type
export type ThemeConfig = {
	UI: TypographyConfig,
	Colors: ColorsConfig,
	Overlay: OverlayConfig,
	Highlight: HighlightConfig,
	WorldHighlight: WorldHighlightConfig,
	Arrow: ArrowConfig,
	Animation: AnimationConfig,
}

-- Defaults & Framework Settings Types
export type StepDefaultsConfig = {
	Highlight: boolean,
	Overlay: boolean,
	Arrow: boolean,
	Focus: boolean,
}

export type UIConfig = {
	Enabled: boolean,
	ScreenGuiName: string,
	OverlayZIndex: number,
	CoreZIndex: number,
}

export type DataStoreConfig = {
	Enabled: boolean,
	TutorialId: string,
	SaveOnStepChange: boolean,
}

-- Main Master Config Type
export type Config = {
	Theme: ThemeConfig,
	Defaults: StepDefaultsConfig,
	UI: UIConfig,
	DataStore: DataStoreConfig,
}

-- Core Instance Types
export type Target = GuiObject | BasePart | Model

export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
}

return Types
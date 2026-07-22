--[=[
	@class OnBoard
	@client
	
	Public entry point for the OnBoard onboarding and tutorial framework.
	Provides tutorial sequence constructors, visual overlay/highlight/arrow tools, and tracker factories.
	
	@creator: @Henrycooper9
	@version 1.0.0
	@see https://henryrbx.github.io/Onboard/ -- API Documentation Guide
	
	--------------------------------------------------------------------------------
	LICENSE / TERMS OF USE:
	This is an open-source/testing module. You are free to modify and improve it.
	RESALE OR REDISTRIBUTION IS STRICTLY PROHIBITED. FOR LEARNING PURPOSES ONLY.
	ALSO I TRIED TO EXPLAIN WITH COMMENTS WHERE IT'S NEEDED.
	--------------------------------------------------------------------------------
]=]

local Types = require(script.Types)
local Config = require(script.Config)
local Theme = require(script.Theme)
local Highlight = require(script.Highlight)
local Overlay = require(script.Overlay)
local Arrow = require(script.Arrow)
local Tracker = require(script.Tracker)
local Tutorial = require(script.Tutorial)

local OnBoard = {}

-- Re-export core types for external usage
export type Target = Types.Target
export type DynamicText = Types.DynamicText
export type StepConfig = Types.StepConfig
export type Step = Types.Step
export type Theme = Types.Theme
export type Config = Types.Config
export type Tracker = Types.Tracker
export type Tutorial = Types.Tutorial

-- Expose global configuration and theme management
OnBoard.Config = Config
OnBoard.Theme = Theme

--[=[
	Creates a new Tutorial instance.
	
	```luau
	local Tutorial = OnBoard.new()
	Tutorial:AddStep({
		Id = "Intro",
		Title = "Welcome!",
		Description = "Let's get started with your journey.",
		Target = workspace.StarterNPC,
		Tracker = OnBoard.Track.Zone(workspace.StarterNPC, 10)
	})
	Tutorial:Start()
	```
]=]
function OnBoard.new(customTheme: Types.Theme?): Types.Tutorial
	return Tutorial.new(customTheme)
end

--==================================================
-- STANDALONE VISUAL APIS
--==================================================

--[=[
	Creates a standalone dynamic Highlight for any GuiObject or 3D World target.
]=]
function OnBoard.Highlight(target: Types.Target, customTheme: Types.Theme?)
	return Highlight.new(target, customTheme)
end

--[=[
	Creates a standalone fullscreen Overlay spotlight with target cutout capability.
]=]
function OnBoard.Overlay(target: Types.Target?, customTheme: Types.Theme?)
	return Overlay.new(target, customTheme)
end

--[=[
	Creates a standalone directional Arrow guide (3D Beam path or floating 2D UI pointer).
]=]
function OnBoard.Arrow(target: Types.Target, customTheme: Types.Theme?)
	return Arrow.new(target, customTheme)
end

--==================================================
-- TRACKER NAMESPACE (OnBoard.Track)
--==================================================

--[=[
	Tracker constructors providing condition evaluation and progress monitoring for steps.
]=]
OnBoard.Track = {
	--[=[
		Tracks a numeric getter until it reaches a target goal value.
	]=]
	Number = function(getValue: () -> number, goal: number): Types.Tracker
		return Tracker.Number(getValue, goal)
	end,

	--[=[
		Tracks a custom boolean predicate function until it returns true.
	]=]
	Boolean = function(predicate: () -> boolean): Types.Tracker
		return Tracker.Boolean(predicate)
	end,

	--[=[
		Tracks an RBXScriptSignal or custom framework Signal event.
	]=]
	Signal = function(signal: any, predicate: ((...any) -> boolean)?): Types.Tracker
		return Tracker.Signal(signal, predicate)
	end,

	--[=[
		Tracks player proximity within a given radius of a 3D position or BasePart.
	]=]
	Zone = function(targetPositionOrPart: Vector3 | BasePart, radius: number): Types.Tracker
		return Tracker.Zone(targetPositionOrPart, radius)
	end,

	--[=[
		Tracks a user click/activation on a GuiButton or 3D ClickDetector.
	]=]
	Click = function(targetInstance: GuiButton | ClickDetector): Types.Tracker
		return Tracker.Click(targetInstance)
	end,

	--[=[
		Tracks a countdown timer duration in seconds.
	]=]
	Timer = function(durationSeconds: number): Types.Tracker
		return Tracker.Timer(durationSeconds)
	end,
}

return OnBoard

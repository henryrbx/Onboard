local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Types = require(script.Parent.Parent.Types)

local Tracker = {}

-- Local Signal Constructor to avoid external dependency errors
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

-- Helper to instantiate base tracker structure
local function createBaseTracker(
	goal: any,
	currentGetter: () -> any,
	progressGetter: () -> number
): (any, Types.Signal<any>, (isComplete: boolean) -> ())
	local completedSignal = createSignal()
	local isCompleted = false

	local trackerObj: any = {
		Goal = goal,
		Current = function(self)
			return currentGetter()
		end,
		Progress = function(self)
			if isCompleted then return 1 end
			return math.clamp(progressGetter(), 0, 1)
		end,

		-- Expose signal under all common framework names to prevent nil indexing errors
		Completed = completedSignal,
		OnCompleted = completedSignal,
		Finished = completedSignal,
		OnFinished = completedSignal,
		StepCompleted = completedSignal,

		Start = function(self) end,
		Stop = function(self) end,
		Destroy = function(self)
			completedSignal:Destroy()
		end
	}

	local function triggerCompletion(complete: boolean)
		if complete and not isCompleted then
			isCompleted = true
			completedSignal:Fire()
		end
	end

	return trackerObj, completedSignal, triggerCompletion
end

--[=[
	Tracks a numeric getter until it reaches a goal value.
]=]
function Tracker.Number(getValue: () -> number, goal: number): any
	local base, _, trigger = createBaseTracker(
		goal,
		getValue,
		function()
			local current = getValue()
			return if goal == 0 then 1 else current / goal
		end
	)

	local connection: RBXScriptConnection?

	base.Start = function(self)
		if connection then return end
		connection = RunService.Heartbeat:Connect(function()
			if getValue() >= goal then
				trigger(true)
			end
		end)
	end

	base.Stop = function(self)
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

--[=[
	Tracks a boolean predicate function until it returns true.
]=]
function Tracker.Boolean(predicate: () -> boolean): any
	local base, _, trigger = createBaseTracker(
		true,
		predicate,
		function()
			return if predicate() then 1 else 0
		end
	)

	local connection: RBXScriptConnection?

	base.Start = function(self)
		if connection then return end
		connection = RunService.Heartbeat:Connect(function()
			if predicate() then
				trigger(true)
			end
		end)
	end

	base.Stop = function(self)
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

--[=[
	Tracks an event signal until it fires (with optional predicate filter).
]=]
function Tracker.Signal(signal: any, predicate: ((...any) -> boolean)?): any
	local isFired = false

	local base, _, trigger = createBaseTracker(
		true,
		function() return isFired end,
		function() return if isFired then 1 else 0 end
	)

	local connection: any

	base.Start = function(self)
		if connection or not signal then return end

		connection = signal:Connect(function(...)
			if predicate == nil or predicate(...) then
				isFired = true
				trigger(true)
			end
		end)
	end

	base.Stop = function(self)
		if connection then
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif type(connection) == "table" and connection.Disconnect then
				connection:Disconnect()
			end
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

--[=[
	Tracks player proximity within a given radius of a 3D position or BasePart.
]=]
function Tracker.Zone(targetPositionOrPart: Vector3 | BasePart, radius: number): any
	local function getTargetPos(): Vector3
		if typeof(targetPositionOrPart) == "Vector3" then
			return targetPositionOrPart
		else
			return targetPositionOrPart.Position
		end
	end

	local function getDistance(): number
		local player = Players.LocalPlayer
		if not player then return math.huge end
		local char = player.Character
		if not char then return math.huge end
		local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp then return math.huge end

		return (hrp.Position - getTargetPos()).Magnitude
	end

	local base, _, trigger = createBaseTracker(
		radius,
		getDistance,
		function()
			local dist = getDistance()
			if dist == math.huge then return 0 end
			return math.clamp(1 - (dist / radius), 0, 1)
		end
	)

	local connection: RBXScriptConnection?

	base.Start = function(self)
		if connection then return end
		connection = RunService.Heartbeat:Connect(function()
			if getDistance() <= radius then
				trigger(true)
			end
		end)
	end

	base.Stop = function(self)
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

--[=[
	Tracks a user click/activation on a GuiButton or 3D ClickDetector.
]=]
function Tracker.Click(targetInstance: GuiButton | ClickDetector): any
	local isClicked = false

	local base, _, trigger = createBaseTracker(
		true,
		function() return isClicked end,
		function() return if isClicked then 1 else 0 end
	)

	local connection: any

	base.Start = function(self)
		if connection or not targetInstance then return end

		if targetInstance:IsA("GuiButton") then
			connection = targetInstance.MouseButton1Click:Connect(function()
				isClicked = true
				trigger(true)
			end)
		elseif targetInstance:IsA("ClickDetector") then
			connection = targetInstance.MouseClick:Connect(function(player)
				if player == Players.LocalPlayer then
					isClicked = true
					trigger(true)
				end
			end)
		end
	end

	base.Stop = function(self)
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

--[=[
	Tracks a countdown timer duration in seconds.
]=]
function Tracker.Timer(durationSeconds: number): any
	local elapsedTime = 0

	local base, _, trigger = createBaseTracker(
		durationSeconds,
		function() return elapsedTime end,
		function() return elapsedTime / durationSeconds end
	)

	local connection: RBXScriptConnection?

	base.Start = function(self)
		if connection then return end
		connection = RunService.Heartbeat:Connect(function(dt)
			elapsedTime += dt
			if elapsedTime >= durationSeconds then
				trigger(true)
			end
		end)
	end

	base.Stop = function(self)
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	base.Destroy = function(self)
		self:Stop()
		base.Completed:Destroy()
	end

	return base
end

return Tracker
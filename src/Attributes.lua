task.defer(function()
	local RunService = game:GetService("RunService")
	local VERSION = require(script.Parent.Version)

	local appVersion = VERSION.GetAppVersion()
	local latestVersion = VERSION.GetLatestVersion()
	local isStudio = RunService:IsStudio()
	--Print
	local PRINT_IN_STUDIO = true
	if PRINT_IN_STUDIO or not isStudio then
		print(`🍇 Running Onboard {appVersion} by @henrycooper9`)
	end

	-- Always warn if an update is available (Studio or Live)
	if latestVersion and latestVersion ~= appVersion then
		warn(`A new version of Onboard ({latestVersion}) is available: https://devforum.roblox.com/t/onboard-10-make-high-quality-tutorial-system/4751478`)
	end
end)

return {}
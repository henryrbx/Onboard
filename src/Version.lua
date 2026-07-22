--!strict

local MarketplaceService = game:GetService("MarketplaceService")

local DEVELOPMENT_PLACE_ID = 75631747569497
local MAX_RETRIES = 5

local VERSION = {}
VERSION.appVersion = "v1.0.0"
VERSION.latestVersion = nil :: string?

local isFetching = false

function VERSION.GetLatestVersion(): string?
	if VERSION.latestVersion then
		return VERSION.latestVersion
	end

	-- Prevent duplicate concurrent fetches
	if isFetching then
		while isFetching do
			task.wait(0.1)
		end
		return VERSION.latestVersion
	end

	isFetching = true

	local placeName = ""
	local attempts = 0

	while attempts < MAX_RETRIES do
		attempts += 1
		local success, details = pcall(function()
			return MarketplaceService:GetProductInfo(DEVELOPMENT_PLACE_ID, Enum.InfoType.Asset)
		end)

		if success and details and type(details) == "table" and details.Name then
			placeName = details.Name
			break
		end

		task.wait(1)
	end

	if placeName ~= "" then
		-- Extracts version format like "v1.0.0" or "1.0.0" after "Onboard"
		local rawVersion = string.match(placeName, "Onboard%s+([v%d%.]+)")
		if rawVersion then
			VERSION.latestVersion = rawVersion
		else
			-- Fallback: capture first word after Onboard if not strict vX.Y.Z format
			VERSION.latestVersion = string.match(placeName, "Onboard%s+(%S+)")
		end
	end

	isFetching = false
	return VERSION.latestVersion
end

function VERSION.GetAppVersion(): string
	return VERSION.appVersion
end

function VERSION.isUpToDate(): boolean
	local latestVersion = VERSION.GetLatestVersion()
	local appVersion = VERSION.GetAppVersion()
	return latestVersion ~= nil and latestVersion == appVersion
end

return VERSION
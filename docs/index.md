---
sidebar_position: 1
---

# OnBoard Framework

**OnBoard** is a modern, lightweight onboarding framework designed for Roblox Luau, enabling quick creation of 2D and 3D tutorial sequences.

The core API is simple and declarative:

```lua
local OnBoard = require(ReplicatedStorage.Packages.OnBoard)

local sequence = OnBoard.CreateSequence({
    Id = "StarterTutorial",
    Steps = {
        {
            Title = "Welcome!",
            Text = "Let's get started with your first quest.",
            ShowOverlay = true,
        },
    }
})

sequence:Start()
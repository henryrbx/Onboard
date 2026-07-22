## 🚀 Quick Start Guide

### Basic Setup in a LocalScript

Create a `LocalScript` inside `StarterPlayerScripts` or `StarterGui`:

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnBoard = require(ReplicatedStorage:WaitForChild("OnBoard"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a new sequence
local sequence = OnBoard.CreateSequence({
    Id = "WelcomeTutorial",
    Steps = {
        {
            Title = "Welcome to the Game!",
            Text = "Let's quickly show you around your new home.",
            -- Step 1 has no target, just displays the top banner card
        },
        {
            Title = "Check the Shop",
            Text = "Click the 'Open Shop' button on your screen.",
            Target = playerGui:WaitForChild("MainGui"):WaitForChild("ShopButton"),
        },
        {
            Title = "Visit the Spawn Pad",
            Text = "Walk over to the main spawn pad area in the world.",
            Target = workspace:WaitForChild("MainSpawnPad"),
        }
    }
})

-- Start the tutorial sequence!
sequence:Start()
```
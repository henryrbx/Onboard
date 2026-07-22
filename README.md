# 🚀 OnBoard Framework

**OnBoard** is a lightweight, modern onboarding and tutorial framework for Roblox. It provides simple step-by-step tutorial sequences, automatic screen overlay highlights, adaptive 2D UI point arrows, and 3D world guide beams.

---

## 📌 Features

* **3D World Beams**: Smoothly points players toward physical parts, models, or attachments in workspace.
* **2D UI Pointer**: Animated hand pointer that automatically places itself cleanly around UI targets without overlapping.
* **Smart UI Highlighting**: Cutout overlay and highlight frames for active tutorial steps.
* **Fully Configurable**: Customizable colors, fonts, banner sizes, and beam textures using `Config.lua`.

---

## 🛠️ Installation

1. Place the `OnBoard` folder into `ReplicatedStorage`.
2. Ensure your module structure looks like this:

ReplicatedStorage
└── OnBoard
    ├── init.lua
    ├── Config.lua
    ├── Types.lua
    ├── Theme.lua
    ├── Arrow.lua
    └── Card.lua

---

## 🚀 Quick Start Guide

### 1. Basic Setup in a LocalScript

Create a `LocalScript` inside `StarterPlayerScripts` or `StarterGui`:

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OnBoard = require(ReplicatedStorage:WaitForChild("OnBoard"))

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

---

## 📖 API Reference

### `OnBoard.CreateSequence(config)`
Constructs a new tutorial sequence.

**Parameters:**
* `config.Id` (`string`): Unique identifier for this tutorial sequence.
* `config.Steps` (`table`): Array of step definitions.

---

### `Step` Table Structure

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `Title` | `string` | **Yes** | Header text displayed in the top banner. |
| `Text` | `string` | **Yes** | Detailed description or instruction text. |
| `Target` | `Instance?` | No | Target UI element (`GuiObject`) or 3D world instance (`BasePart`, `Model`, `Attachment`). |
| `ShowArrow` | `boolean?` | No | Whether to show the pointer arrow/beam (Defaults to `true`). |
| `ShowOverlay` | `boolean?` | No | Whether to dim the screen with a cutout highlight (Defaults to `true`). |

---

### `Sequence` Methods

-- Start the sequence from step 1
sequence:Start()

-- Move to the next step programmatically
sequence:Next()

-- Move back to the previous step
sequence:Previous()

-- End and cleanup the tutorial sequence
sequence:Stop()

---

## ⚙️ Configuration (`Config.lua`)

Customize default behavior and appearance directly in `ReplicatedStorage/OnBoard/Config.lua`:

local Config = {
    Theme = {
        Font = Font.fromEnum(Enum.Font.BuilderSans),
        TitleSize = 24,
        DescriptionSize = 16,
        TextColor = Color3.fromRGB(255, 255, 255),
        
        -- Custom 3D Arrow Texture
        ArrowBeamTexture = "rbxassetid://98078426234204",
        
    },

    UIScreenGuiName = "OnBoard_CoreGui",
    OverlayZIndex = 100,
}

return Config

---

## 📜 License & Terms of Use

* **Author**: @Henrycooper9
* **Version**: `1.0.0`

> **Note**: This is an open-source testing/learning framework. You are free to modify and improve it for your own games. **Resale or paid redistribution of this module is strictly prohibited.**

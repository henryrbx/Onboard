# OnBoard

Modern onboarding and tutorial framework for Roblox.

Create polished tutorials that guide players through your game using UI highlights, world indicators, overlays, and animated pointers.

---

## Features

✅ UI element highlighting

✅ 3D world indicators

✅ Animated pointer arrows

✅ Darkened overlay with cutout

✅ Step-by-step tutorial sequences

✅ Easy configuration

---

## Installation

Place the package inside ReplicatedStorage.

```text
ReplicatedStorage
└── OnBoard
```

Require the module.

```lua
local OnBoard = require(ReplicatedStorage.OnBoard)
```

---

## Quick Start

```lua
local Tutorial = OnBoard.CreateSequence({
    Id = "Welcome",

    Steps = {
        {
            Title = "Inventory",
            Text = "Click here to open your inventory.",
            Target = InventoryButton
        },

        {
            Title = "Shop",
            Text = "Buy your first sword.",
            Target = ShopButton
        }
    }
})

Tutorial:Start()
```

---

## Documentation

- Configuration
- API Reference

---
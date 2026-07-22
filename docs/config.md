# ⚙️ Configuration Guide

All default visual themes and system settings for OnBoard are stored in `src/Config.lua`. You can modify this file directly to change how the framework looks and behaves game-wide.

---

## 🎨 Theme Settings

The `Theme` table controls typography, sizing, colors, and beam textures.

```luau
local Config = {
    Theme = {
        -- Font configuration (Supports Font objects or Enum.Font)
        Font = Font.fromEnum(Enum.Font.BuilderSans),
        
        -- Text sizes
        TitleSize = 22,
        DescriptionSize = 16,
        
        -- Primary text color
        TextColor = Color3.fromRGB(255, 255, 255),
        
        -- Asset ID used for 3D world guide beams
        ArrowBeamTexture = "rbxassetid://98078426234204",
    },

    -- ScreenGui container name created in PlayerGui
    UIScreenGuiName = "OnBoard_CoreGui",
    
    -- ZIndex priority layer for overlays and cards
    OverlayZIndex = 100,
}

return Config
```

---

## 🛠️ Configuration Options Explained

| Parameter | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `Theme.Font` | `Font` / `Enum.Font` | `BuilderSans` | Font used for top banner card titles and body text. |
| `Theme.TitleSize` | `number` | `22` | Text size for step headers. |
| `Theme.DescriptionSize` | `number` | `16` | Text size for step description body text. |
| `Theme.TextColor` | `Color3` | `Color3.fromRGB(255, 255, 255)` | Color applied to all top banner labels. |
| `Theme.ArrowBeamTexture` | `string` | `"rbxassetid://98078426234204"` | Asset ID texture rendered on 3D world guide beams. |
| `UIScreenGuiName` | `string` | `"OnBoard_CoreGui"` | Name of the top-level ScreenGui injected into `PlayerGui`. |
| `OverlayZIndex` | `number` | `100` | Base ZIndex ordering used to draw cards above core UI elements. |

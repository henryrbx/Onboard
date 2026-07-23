# API

## CreateSequence

Creates a tutorial sequence.

```lua
local Tutorial = OnBoard.CreateSequence(config)
```

---

## Step

```lua
{
    Title = "...",
    Text = "...",
    Target = GuiObject,

    ShowArrow = true,
    ShowOverlay = true
}
```

| Property | Type | Required |
|----------|------|----------|
| Title | string | ✓ |
| Text | string | ✓ |
| Target | Instance | |
| ShowArrow | boolean | |
| ShowOverlay | boolean | |

---

## Sequence

### Start

```lua
Tutorial:Start()
```

Starts the tutorial.

---

### Next

```lua
Tutorial:Next()
```

Moves to the next step.

---

### Previous

```lua
Tutorial:Previous()
```

Moves to the previous step.

---

### GoToStep

```lua
Tutorial:GoToStep(2)
```

Jumps to a step.

---

### Stop

```lua
Tutorial:Stop()
```

Stops the tutorial and cleans everything up.
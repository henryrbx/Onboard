# 📖 API Reference

This document provides a comprehensive overview of the public classes, methods, and types available in the **OnBoard** framework.

---

## 🛠️ OnBoard (Core Engine)

The entry point for creating tutorial sequences and managing global configs.

### `OnBoard.CreateSequence(config: SequenceConfig): Sequence`
Constructs and returns a new `Sequence` controller instance.

* **`config`** (`SequenceConfig`): Configuration table defining sequence ID and steps.

```luau
local sequence = OnBoard.CreateSequence({
    Id = "StarterTutorial",
    Steps = { ... }
})
```

---

## 📋 Step Configuration

Each step in a tutorial sequence is defined using a table with the following properties:

### `Step` Table Structure

| Property | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `Title` | `string` | **Yes** | Header text displayed in the top banner card. |
| `Text` | `string` | **Yes** | Detailed instruction or body text. |
| `Target` | `Instance?` | No | Target UI element (`GuiObject`) or World object (`BasePart`, `Model`, `Attachment`). |
| `ShowArrow` | `boolean?` | No | Whether to show the pointer arrow or 3D guide beam. *(Defaults to `true`)* |
| `ShowOverlay` | `boolean?` | No | Whether to dim the screen background with a cutout highlight. *(Defaults to `true`)* |

---

## ⚙️ Sequence Controller

Methods provided by the sequence object returned from `OnBoard.CreateSequence()`.

### `Sequence:Start()`
Starts the tutorial sequence from Step 1.

```luau
sequence:Start()
```

### `Sequence:Next()`
Advances the sequence to the next step. If called on the final step, it automatically stops and cleans up the sequence.

```luau
sequence:Next()
```

### `Sequence:Previous()`
Navigates back to the previous step in the sequence.

```luau
sequence:Previous()
```

### `Sequence:GoToStep(index: number)`
Jumps directly to a specific step index.

* **`index`** (`number`): The step number to load.

```luau
sequence:GoToStep(2)
```

### `Sequence:Stop()`
Immediately halts the sequence, cleans up active UI components, and removes all beams/arrows from the screen.

```luau
sequence:Stop()
```

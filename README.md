# NeverloseLibrary Documentation

Comprehensive reference for building a GUI using the **Neverlose** UI library.

## Getting Started

1. **Download the module** into your project (e.g. `NeverloseLibrary.lua`).
2. **Require** it and create the UI instance:

   ```lua
   local MakeUI = require(path.to.NeverloseLibrary)
   local ui = MakeUI({
       cheatname = "MyCheat",      -- optional header text
       ext       = " v1.0",       -- optional extension
       gamename  = " - Game",     -- optional game name
       assetId   = 12702460854,     -- ID of the Roblox GUI asset used by the menu
   })
   ```

3. **Toggle visibility** by pressing `RightShift` (default).

The constructor automatically shows a brief loading screen and then
instantiates the core GUI under `CoreGui`.

## Core Concepts

- `ui.flags` – table of current values indexed by `flag` strings supplied to
  controls. Useful for checking options from your game logic.
- `ui.options` – metadata for each flag including `type` and functions to
  change state programmatically.
- `ui.notify(text)` – display a small on‑screen message using the Drawing API.

### Tabs and Groups

The UI is structured as a set of tabs; every tab can contain one or more groups.

```lua
local tab = ui:addTab("Main")        -- returns a tab object
local grp = tab:createGroup("left", "Settings")  -- columns: "left" or "right"
```

Each group exposes a suite of helper methods to add controls; groups are layouted
vertically within the selected column.

## Available Controls

All methods accept a table of arguments. Fields marked **required** must be
present; others are optional.

### `group:addToggle(args)`
- **args.text** – displayed label (defaults to `args.flag`).
- **args.flag** (required) – unique key for storing state.
- **args.callback(state)** – called when toggle changes.
- **args.disabled** – boolean, show as inactive.
- Returns an object with additional helpers:
  - `:addKeybind({flag=...,key=Enum.KeyCode.X,callback=function()...end})`
  - `:addColorpicker({flag=...,callback=...})` proxies to group method.

The toggle flag value becomes `true`/`false` in `ui.flags`.

### `group:addButton(args)`
- **args.text** (required) – button label.
- **args.callback()** (required) – invoked on click.

### `group:addSlider(args)`
- **args.flag** (required)
- **args.max** (required) – maximum numeric value.
- **args.min** – minimum (default `0`).
- **args.value** – initial value.
- **args.callback(value)** – called when slider moves.
- **args.text** – label shown left of slider.

Value stored as number in `ui.flags`.

### `group:addTextbox(args)`
- **args.flag** (required)
- **args.value** – initial string.
- **args.text** – label.
- **args.callback(text)** – invoked when text changes.

### `group:addDivider()`
Simple horizontal line; no arguments.

### `group:addList(args)`
- **args.flag** (required)
- **args.values** (required) – array of selectable items.
- **args.multiselect** – allow multiple selections.
- **args.text** – label.
- **args.value** – initial selection or table of selections.
- **args.callback(value)** – called with new value(s).

### `group:addConfigbox(args)`
Creates a scrollable list of strings meant for loading/saving configs.
Same argument shape as `addList`; the internal `ui.options[flag]` object
includes a `refresh(newValues)` method you can call when the list changes.

### `group:addColorpicker(args)`
- **args.flag** (required)
- **args.color** – initial `Color3`.
- **args.callback(color)** – fired when color updates.

Note: the current implementation shows only a swatch; you can extend
`buildColorDialog()` in the module to provide a full picker UI.

### `group:addKeybind(args)`
- **args.flag** (required)
- **args.key** – initial `Enum.KeyCode` or `UserInputType`.
- **args.text** – label.
- **args.callback()** – called when bound key is pressed.

### Programmatic Control

Each entry in `ui.options` contains a `changeState` function you can call
from your scripts to update a control. Example:

```lua
ui.options["opt"].changeState(true)     -- toggle on
ui.options["volume"].changeState(5)     -- slider value
```

To read current state simply access `ui.flags.flagName`.

## Example Usage

```lua
local ui = require(path.to.NeverloseLibrary).new({cheatname="MyLib"})

local tab = ui:addTab("Gameplay")
local grp = tab:createGroup("left","Combat")

grp:addToggle{flag="autoAttack",text="Auto attack",callback=function(v)
    print("Auto attack is",v)
end}

grp:addSlider{flag="range",text="Attack range",max=100,value=50,callback=function(v)
    print("Range set to",v)
end}

grp:addKeybind{flag="hotkey",text="Hotkey"}

ui:notify("UI loaded!")
```

Press **RightShift** to show/hide the window; interact with controls to
update `ui.flags`.

## Advanced Topics

* **Customization**: change `ui.libColor` or `ui.disabledcolor` after
  creation to theme the menu. The asset used by the GUI can also be replaced
  by providing a different `assetId` in the constructor.
* **Protection**: if you distribute only the stub, host the library code on a
  remote server and load it at runtime (see previous discussion on obfuscation).
* **Extensions**: the module’s tab/group methods can be expanded by editing
  `NeverloseLibrary.lua` directly; the patterns for creating UI elements shown
  in the source are idiomatic and you can replicate them for custom controls.

## License & Contribution

Include a `LICENSE` file in your repository (MIT is recommended for maximum
reuse). Contributions, bug reports and pull requests are welcome!

---

With this guide you should be able to build any UI layout supported by the
library. Feel free to copy/paste the examples into your own scripts and adapt
as needed.

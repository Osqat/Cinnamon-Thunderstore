# Cinnamon

Cinnamon is a BepInEx GUI library for Ultimate Chicken Horse mods. It helps mod authors draw custom interfaces while keeping the game's cursor visible above those interfaces.

## Features

- Provides a cursor overlay helper for IMGUI and Unity GUI panels.
- Keeps the cursor from being hidden behind mod UI.
- Does not include auto-update behavior in the Thunderstore build.

## For Mod Developers

Reference `Cinnamon.dll` from your mod and call:

```csharp
Cinnamon.UI.CursorOverlay.Request();
```

Call it once per frame while your GUI is open.

## AI Disclosure

This Thunderstore package and parts of the packaging/refactoring work were created with assistance from Anthropic and OpenAI tools.

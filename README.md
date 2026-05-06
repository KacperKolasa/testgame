# THE GRID: BLACKOUT CITY

THE GRID: BLACKOUT CITY is a portrait iOS idle strategy/clicker game built with Swift and SwiftUI. The player restores power to a blacked-out city by tapping an emergency generator, routing power to districts, stabilizing the grid, responding to emergencies, buying upgrades, earning offline progress, and eventually accepting Rebuild Contracts for permanent Grid Token bonuses.

## How to Run

1. Open `TheGridBlackoutCity.xcodeproj` in Xcode 16 or newer.
2. Select the shared `TheGridBlackoutCity` scheme.
3. Choose an iPhone simulator running iOS 17.0 or newer.
4. Build and run.

Unit tests are in the `TheGridBlackoutCityTests` target. From macOS with Xcode installed:

```sh
xcodebuild test -project TheGridBlackoutCity.xcodeproj -scheme TheGridBlackoutCity -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project Overview

The MVP is fully offline and uses no server, ads, or in-app purchases. Visuals combine generated project-owned PNG assets with SwiftUI shapes, gradients, SF Symbols, Canvas drawing, and subtle animations.

The city map and production list are the emotional center of the game. Districts use colorful idle-tycoon sprites, production rows expose income/load/level, and buy/upgrade buttons use chunky reward-forward styling. The generator button gives immediate power, floating gain feedback, haptics, and optional system sounds.

## Architecture Summary

- `Models/` contains Codable game state, district definitions, upgrade definitions, city modifiers, event data, settings, and prestige state.
- `Engine/` contains deterministic gameplay rules for economy, events, offline progress, prestige, and player actions.
- `Services/` contains save/load, haptics, and lightweight sound wrappers.
- `ViewModels/` contains `GameViewModel`, the main `ObservableObject` that owns the timer loop and exposes player actions to SwiftUI.
- `Views/` contains the custom game dock, city map, districts, upgrades, events, prestige, settings, and reusable components.
- `Assets/Generated/` contains generated raster art for the city backdrop, reactor core, district tiles, event banner, and prestige banner.
- `TheGridBlackoutCityTests/` covers economy calculations, save/load safety, offline earnings, event generation/actions, and district power behavior.

SwiftUI views render state and send intent to `GameViewModel`. Gameplay calculations stay in engines so tests can exercise them without UI.

## Gameplay Systems

- Tap generator: earns power per tap, scales through upgrades and prestige.
- Battery storage: caps power, expands through storage upgrades and Battery Yard.
- District restoration: spends power to unlock ten districts.
- Power routing: restored districts can be toggled on/off to manage demand.
- District income: powered districts consume demand and produce credits based on level, upgrades, stability, and events.
- Grid stability: live 0-100 system that affects income and can trigger blackout penalties.
- Emergency events: Power Surge, Hospital Emergency, Storm Damage, Factory Overload, Festival Night, and Data Spike.
- Upgrades: 22 global upgrades across generation, storage, stability, city output, and automation.
- District upgrades: each restored district can reach level 5.
- Offline progress: capped at eight hours, awarding idle credits and passive power while considering demand and battery capacity.
- Prestige: full city restoration unlocks Rebuild Contracts, Grid Tokens, permanent upgrades, and Snow City rules.

## Save System

The game saves a Codable `SaveEnvelope` to `UserDefaults`.

Saved data includes:

- power, credits, stability, battery capacity, population, and city completion,
- district restored/powered/level state,
- global upgrade levels,
- active event and event history,
- prestige count, Grid Tokens, permanent upgrades, and city modifier,
- settings,
- run/all-time stats,
- last active timestamp for offline progress.

Loading is defensive. Missing newer fields decode with defaults where practical, corrupted data returns `nil`, and the app starts a fresh save instead of crashing.

## Known Limitations

- Event scheduling is timer-based and intentionally lightweight for MVP tuning.
- Sound uses simple system sounds instead of custom audio assets.
- City modifiers currently include Standard City and Snow City, with hooks for the other planned modifiers.
- The map is programmatic and stylized rather than a hand-authored art asset.
- The local workspace does not include Xcode, so final compilation must be verified on macOS.

## Future Improvement Ideas

- Add Desert, Coastal, and Neon City modifiers.
- Add route presets and a smarter routing assistant screen.
- Add achievements and milestone rewards.
- Add richer event chains with multi-step decisions.
- Add optional accessibility color themes.
- Add a small tutorial sequence for the first five minutes.

# REVIEW_GUIDE

## Important Files to Inspect

- `TheGridBlackoutCity/Models/GameState.swift`
- `TheGridBlackoutCity/Models/District.swift`
- `TheGridBlackoutCity/Models/Upgrade.swift`
- `TheGridBlackoutCity/Engine/EconomyEngine.swift`
- `TheGridBlackoutCity/Engine/EventEngine.swift`
- `TheGridBlackoutCity/Engine/OfflineProgressEngine.swift`
- `TheGridBlackoutCity/Engine/PrestigeEngine.swift`
- `TheGridBlackoutCity/Services/SaveService.swift`
- `TheGridBlackoutCity/ViewModels/GameViewModel.swift`
- `TheGridBlackoutCity/Views/CityMapView.swift`
- `TheGridBlackoutCityTests/`

## Architecture Summary

The app uses a single `GameViewModel` as the SwiftUI-facing state owner. It loads saves, applies offline progress, starts a one-second timer, and exposes player actions. Calculations are delegated to deterministic engines. Views render state and call intent methods only.

`GameState` is Codable and contains the complete save surface: resources, districts, upgrade levels, prestige, events, settings, stats, timestamps, and timers.

## Known Tradeoffs

- The map is drawn entirely in SwiftUI/Canvas for portability and no asset dependencies.
- Event scheduling is simple weighted random selection, not a director system.
- Save migration covers missing fields defensively but does not include a formal multi-version migrator yet.
- Audio uses system sounds because no copyrighted or external assets are included.
- UI is optimized for modern portrait iPhones; iPad is portrait-only but not deeply customized.

## Areas Likely Needing Balancing

- Passive power growth from Solar Panels and Solar Farm.
- Factory Zone income versus stability pressure.
- Data Center demand spike difficulty.
- Offline credit multiplier.
- Grid Token award rate after the first prestige.
- Snow City demand multiplier.

## Suggested Next Features

- Desert, Coastal, and Neon City modifiers.
- Route presets and an automation policy editor.
- District adjacency bonuses shown directly on the map.
- Event chains with follow-up choices.
- Achievements and milestone rewards.
- Accessibility color mode and reduced-motion option.

## Test Commands

```sh
xcodebuild test -project TheGridBlackoutCity.xcodeproj -scheme TheGridBlackoutCity -destination 'platform=iOS Simulator,name=iPhone 15'
```

Run from the `TheGridBlackoutCity` directory on macOS with Xcode installed.

## Manual QA Checklist

- Launch fresh save without crash.
- Tap generator and confirm power increases.
- Restore Residential Block at 20 power.
- Confirm Residential Block lights up on the city map.
- Confirm powered Residential Block earns credits and consumes power.
- Restore Hospital and test its power toggle.
- Buy Hand Crank Generator and Battery Expansion.
- Confirm battery capacity updates.
- Restore Factory Zone and observe stability pressure.
- Trigger or wait for an event and complete at least one event action.
- Close and reopen the app; confirm offline summary appears after enough elapsed time.
- Restore all districts, open Prestige, and accept a Rebuild Contract.
- Spend Grid Tokens on a permanent upgrade.
- Reset save from Settings and confirm state returns to new game.

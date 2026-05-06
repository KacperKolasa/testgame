# ASSET_NOTES

## Generated Asset Set

The game now includes raster assets generated for this project and copied into:

`TheGridBlackoutCity/Assets/Generated`

## Files

- `blackout_city_backdrop.png`: portrait city restoration background used behind the live map.
- `reactor_core.png`: tappable reactor core art used on the City screen and map.
- `district_spritesheet.png`: source sheet for the ten district tiles.
- `district_residential_block.png`
- `district_hospital.png`
- `district_factory_zone.png`
- `district_night_market.png`
- `district_transit_hub.png`
- `district_data_center.png`
- `district_water_plant.png`
- `district_downtown_core.png`
- `district_solar_farm.png`
- `district_battery_yard.png`
- `event_power_surge.png`: emergency event banner art.
- `prestige_contract.png`: Rebuild Contract banner art.

## Integration

The PNG files are registered in `TheGridBlackoutCity.xcodeproj` under the app target Resources phase. SwiftUI references them by bundle image name through `GameArt` in `Views/Components/MetricComponents.swift`.

## Generation Prompts

Assets were generated with the built-in image generation tool using project-specific prompts for:

- cinematic blackout city portrait background,
- circular emergency reactor core,
- ten-tile isometric district sprite sheet,
- emergency power surge event banner,
- prestige rebuild contract banner.

The original generated files remain under the Codex generated image cache. Copies are stored in the project so the app does not depend on that cache.

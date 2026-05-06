# DESIGN_NOTES

## Design Pillars

1. Bring a dead city back to life.
2. Make idle progress useful without making attention irrelevant.
3. Turn clicking into grid management, not just number growth.
4. Keep the interface calm, readable, and premium.

## Core Loop

The player starts with no power and a small emergency generator. Tapping stores power in the battery. Power restores districts. Powered districts consume demand and earn credits. Credits buy upgrades. Upgrades improve generation, storage, stability, district output, automation, and offline progress. Events interrupt the routine and reward active decisions.

The intended loop is:

1. Tap for power.
2. Restore a district.
3. Route power to the best current districts.
4. Earn credits while watching demand and stability.
5. Buy upgrades.
6. Respond to emergencies.
7. Expand until city completion reaches 100%.
8. Accept a Rebuild Contract for Grid Tokens and permanent growth.

## Active Strategy

The player is asked to make repeated decisions:

- Keep a fragile district powered for an event.
- Shut off Factory Zone or Data Center to protect stability.
- Spend scarce power on repairs instead of expansion.
- Buy income upgrades now or storage/stability upgrades for safer growth.
- Push a Factory Overload for credits or slow production for stability.
- Route power to Night Market during Festival Night.

The game can progress while idle, but active attention produces better outcomes.

## District Roles

- Residential Block: first district, low demand, steady income, population.
- Hospital: low income, protection against blackout penalties, emergency anchor.
- Factory Zone: high income, high demand, stability risk.
- Night Market: midgame active reward district, strong during Festival Night.
- Transit Hub: citywide efficiency and demand reduction.
- Data Center: late-game income, demand spike risk.
- Water Plant: stability and storm mitigation.
- Downtown Core: expensive completion district with strong income.
- Solar Farm: passive power source affected by storms.
- Battery Yard: storage growth and blackout cushioning.

## Events

Events are designed to break idle autopilot.

- Power Surge uses fast repeated stabilize actions.
- Hospital Emergency asks the player to protect a low-income but critical district.
- Storm Damage pressures solar output and power reserves.
- Factory Overload creates a clear risk/reward choice.
- Festival Night rewards planned Night Market routing.
- Data Spike is a late-game stress test for stability and battery reserves.

## Prestige Design

Prestige is framed as accepting a new Rebuild Contract. It should feel like a career progression rather than a reset button.

Grid Tokens reward:

- restored districts,
- population served,
- credits earned during the run,
- completed events.

Permanent upgrades improve tap power, idle power, credit income, starting storage, event rewards, and stability recovery.

Snow City is the first alternate modifier. It increases baseline demand and makes stability upgrades matter earlier. The catalog is intentionally extensible for Desert, Coastal, and Neon cities.

## Visual Direction

The visual language now targets casual idle-tycoon readability rather than a serious command dashboard: bright sky gradients, chunky rounded panels, gold and green purchase buttons, bold outlined district art, large resource strips, visible production rows, and reward-forward progress bars.

Unrestored districts are desaturated and locked-looking. Restored but unpowered districts are visible but muted. Powered districts use bright outlines and stronger saturation. Event-related districts receive a red warning emphasis.

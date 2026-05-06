# BALANCE_NOTES

## Starting Values

- Power: 0
- Credits: 0
- Stability: 100
- Battery capacity: 100
- Power per tap: 1
- Passive power/sec: 0
- Credits/sec: 0 until a district is restored and powered

Residential Block costs 20 power, has 1 demand, earns 1 credit/sec, and serves 100 population. Hospital costs 50 power, has 2 demand, earns 0.5 credits/sec, and provides blackout/event protection.

## Economy Formulas

Global upgrade cost:

```text
cost = baseCost * pow(costMultiplier, currentLevel)
```

District upgrade cost:

```text
cost = max(35, restoreCost * 0.9 + baseIncome * 20) * pow(1.72, currentLevel - 1)
```

District income:

```text
income = baseIncome
       * districtLevelMultiplier
       * globalIncomeMultipliers
       * transitEfficiency
       * eventMultiplier
       * stabilityIncomeMultiplier
```

District demand:

```text
demand = baseDemand
       * districtLevelReduction
       * cityModifierDemand
       * smartRoutingMultiplier
       * smartGridMultiplier
       * transitMultiplier
```

## Stability Bands

- 80-100 stability: 1.00x income
- 50-79 stability: 0.85x income
- 20-49 stability: 0.60x income
- 1-19 stability: 0.35x income
- 0 stability: blackout penalty

Stability changes every tick based on powered district effects, demand pressure, passive generation coverage, battery reserve ratio, event penalties, Water Plant, and stability upgrades.

## Power and Demand

Each tick:

1. Passive power is generated.
2. District demand consumes stored power.
3. If demand cannot be fully covered, income is scaled by coverage.
4. Low coverage damages stability.
5. Battery capacity is recalculated from upgrades, Battery Yard, city modifier, and permanent upgrades.

This makes the battery meaningful. A player can run demand above passive generation for a while, but sustained overdraw drains reserves and destabilizes the city.

## Upgrade Intent

Generation upgrades make tapping and idle power better.

Storage upgrades raise the ceiling and reduce blackout pain.

Stability upgrades let high-demand districts stay active longer.

City output upgrades convert restored districts into stronger credit engines.

Automation upgrades make idle play stronger and soften event pressure without fully replacing active decisions.

## Event Timing

Events begin after at least two districts are restored. The base cooldown is roughly two to three minutes, with district unlocks able to pull the next event earlier. This keeps the first minute focused on tapping and restoration, then introduces active management.

## Prestige Tuning

Grid Tokens are awarded from:

- population served,
- restored districts,
- run credits earned,
- completed events.

The minimum award is 3 tokens so the first completed city always gives the player a meaningful permanent choice. Permanent upgrade costs grow gently by level, encouraging breadth early and specialization later.

## Expected First-Run Feel

- First district should unlock quickly through tapping.
- Hospital should follow soon after Residential Block.
- Factory Zone requires storage planning because its restore cost exceeds starting battery capacity.
- Midgame pressure starts when Factory Zone and Night Market compete for power.
- Late game asks the player to add storage, passive power, and stability before Data Center and Downtown Core can run safely.

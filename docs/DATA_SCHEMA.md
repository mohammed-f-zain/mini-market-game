# Data Schema — Mini Market Tycoon

## DataStore

- Name: `MiniMarketPlayerData_v1` (from `GameConfig.DataStore.Name`)
- Key: `Player_<userId>`
- Session marker key: `Player_<userId>_Session`

## Schema version

`Version = 1`

## Profile shape

```lua
{
  Version = 1,
  Coins = 500,
  Inventory = { -- [productId] = quantity
    Milk = 0,
  },
  Upgrades = {
    Shelves = 0,
    CustomerAttraction = 0,
    StorageCapacity = 0,
  },
  Progression = {
    StoreLevel = 1,
    TotalEarned = 0,
    CustomersServed = 0,
    ProductsSold = 0,
    TimePlayed = 0,
    MilestonesClaimed = {},
  },
  TutorialStep = 0,
  TutorialCompleted = false,
  StoreName = "<DisplayName>'s Market",
  LastSave = <unix timestamp>,
}
```

## Runtime-only (not persisted)

- Plot assignment
- Shelf stock quantities
- Active NPC instances
- Rate-limit buckets
- Transaction anti-duplication set

Shelf stock is runtime for MVP simplicity. Future versions may persist shelves under `Store.Shelves`.

## Validation

`DataValidator.SanitizeProfile` clamps numbers, drops unknown products, enforces upgrade max levels, and never replaces a failed load with defaults for saving.

## Migrations

When `profile.Version < GameConfig.SchemaVersion`, bump version and fill missing fields via sanitize defaults. Append history in `PROJECT_MEMORY.md` for each schema change.

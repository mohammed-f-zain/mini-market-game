# API Reference — Mini Market Tycoon

## RemoteEvents (`Remotes/Events`)

| Name | Direction | Purpose | Payload |
|---|---|---|---|
| Notify | S→C | Toast message | `{ Kind, Message, Duration }` |
| PlayerSnapshot | S→C | Full client state | Snapshot table |
| TutorialUpdate | S→C | Tutorial step | `{ Completed, StepIndex, Step, TotalSteps }` |
| MilestoneUnlocked | S→C | Milestone feedback | `{ Id, Description, Reward }` |

## RemoteFunctions (`Remotes/Functions`)

| Name | Direction | Params | Returns |
|---|---|---|---|
| GetSnapshot | C→S | — | Snapshot or nil |
| PurchaseProduct | C→S | `productId, quantity` | `{ Ok, Error }` |
| RefillShelf | C→S | `shelfId, productId, quantity` | `{ Ok, Error }` |
| PurchaseUpgrade | C→S | `upgradeId` | `{ Ok, Error }` |
| AdvanceTutorial | C→S | — | `{ Ok, Error }` |
| SetStoreName | C→S | `name` | `{ Ok, Error }` |

## EconomyService

- `GetBalance(player)`
- `CanAfford(player, amount)`
- `AddCoins(player, amount, reason)`
- `SpendCoins(player, amount, reason)`

## Snapshot fields

`Coins`, `Inventory`, `Upgrades`, `Progression`, `InventoryCapacity`, `InventoryUsed`, `PlotId`, `StoreName`, `TutorialStep`, `TutorialCompleted`, `Shelves`, `Catalog`, `ActiveCustomers`

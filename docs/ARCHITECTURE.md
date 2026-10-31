# Architecture — Mini Market Tycoon

## Overview

Server-authoritative multiplayer tycoon. The server owns currency, inventory, shelves, upgrades, NPC sales, and persistence. Clients own UI, input, and presentation.

## Layers

1. **Shared** (`ReplicatedStorage/Shared`) — configs, types, utils
2. **Remotes** (`ReplicatedStorage/Remotes`) — RemoteEvents / RemoteFunctions
3. **Services** (`ServerScriptService/Services`) — domain operations
4. **Systems** (`ServerScriptService/Systems`) — gameplay flows (AI, shelves, checkout)
5. **Controllers** (`StarterPlayerScripts/Controllers`) — client UI and feedback

## Bootstrap flow

### Server (`Bootstrap.server.lua`)

1. Create remotes
2. Init DataStore service
3. Build map / register plots
4. Init monetization receipt handler
5. Init player lifecycle + remotes
6. Start autosave + customer spawn loop
7. BindToClose → save all

### Client (`Bootstrap.client.lua`)

1. Wait for remotes
2. Init UI / notifications / tutorial / camera
3. Subscribe to `PlayerSnapshot`
4. Request initial snapshot

## Service responsibilities

| Service | Responsibility |
|---|---|
| PlayerDataService | Load/save/session/autosave |
| PlayerService | Join/leave, remotes, snapshots |
| EconomyService | All coin mutations |
| StoreService | Plots, ownership, shelf state |
| InventoryService | Stock capacity and quantities |
| ProductService | Catalog and prices |
| SupplierService | Wholesale purchases |
| UpgradeService | Upgrade purchases/effects |
| CustomerService | NPC spawn budget |
| NotificationService | Client toasts |
| MonetizationService | ProcessReceipt / game passes |

## Dependency direction

```
Controllers → Remotes → Services/Systems
Systems → Services → PlayerDataService / Config
MapBuilder → StoreService
CustomerAI → Movement, Shopping, Checkout, Store
```

Never let clients decide prices, balances, or ownership.

# PROJECT MEMORY — MINI MARKET TYCOON

## Project Identity
- **Project name:** Mini Market Tycoon
- **Game genre:** Multiplayer Tycoon / Business Simulator / Economy Management
- **Development status:** Foundation + core gameplay implemented (Phases 1–5 functional MVP; Phase 6–7 stubs/polish prep)
- **Technology stack:** Luau, Roblox Studio, Rojo 7.4, Git, DataStoreService, PathfindingService, MarketplaceService, CollectionService, TweenService
- **Repository structure:** Rojo project at repo root (`default.project.json` → `src/`)
- **Current development phase:** Phase 5 complete locally; Phase 6 polish and Phase 7 monetization ID configuration remaining

---

## 1. Project Overview

Mini Market Tycoon is a free-to-play Roblox multiplayer experience where each player owns an individual supermarket plot in a shared neighborhood (up to 12 players). Players buy wholesale products, stock shelves, attract NPC customers, earn coins from automated checkouts, and reinvest in upgrades.

**Gameplay loop:** PURCHASE STOCK → STOCK SHELVES → ATTRACT CUSTOMERS → MAKE SALES → EARN MONEY → UPGRADE STORE → EXPAND BUSINESS.

**Business model:** Free to play. Optional Robux Game Passes and Developer Products (IDs configured after Creator Dashboard setup). Progression must not require purchases.

---

## 2. Architecture Map

| Feature | Main File | Supporting Files | Responsibility |
|---|---|---|---|
| Bootstrap (Server) | `src/ServerScriptService/Bootstrap.server.lua` | MapBuilder, all Services | Server startup |
| Bootstrap (Client) | `src/StarterPlayer/StarterPlayerScripts/Bootstrap.client.lua` | Controllers | Client startup |
| Remotes | `src/ReplicatedStorage/Remotes/RemoteBootstrap.lua` | Events/, Functions/ | Remote creation/access |
| Config | `src/ReplicatedStorage/Shared/Config/*.lua` | GameTypes.lua | Tunable constants |
| Player Management | `Services/PlayerService.lua` | PlayerDataService, StoreService | Join/leave lifecycle |
| Economy | `Services/EconomyService.lua` | EconomyConfig.lua | Currency operations |
| Inventory | `Services/InventoryService.lua` | ProductService.lua | Product storage |
| Products / Supplier | `Services/SupplierService.lua` | ProductService, ProductConfig | Wholesale purchases |
| Store Management | `Services/StoreService.lua` | MapBuilder.lua | Plots, ownership, shelves |
| Shelf Stocking | `Systems/ShelfSystem.lua` | InventoryService, StoreService | Refill / customer take |
| Customer AI | `Systems/CustomerAI.lua` | CustomerMovement, ShoppingSystem | NPC behavior |
| Customer Spawning | `Services/CustomerService.lua` | CustomerAI, UpgradeService | Spawn budget/loop |
| Checkout | `Systems/CheckoutSystem.lua` | EconomyService, ProgressionSystem | Sales transactions |
| Upgrades | `Services/UpgradeService.lua` | UpgradeConfig.lua | Upgrade purchases |
| Progression | `Systems/ProgressionSystem.lua` | EconomyService | Stats + milestones |
| Tutorial | `Systems/TutorialSystem.lua` | UIConfig, TutorialController | Onboarding |
| Data Persistence | `Services/PlayerDataService.lua` | DataValidator.lua | Load/save/autosave |
| Monetization | `Services/MonetizationService.lua` | MarketplaceService | Receipts / passes |
| UI | `Controllers/UIController.lua` | NotificationController, TutorialController | Interface |
| Map | `Utilities/MapBuilder.lua` | Workspace/Map | Neighborhood + stores |
| Security utils | `Utilities/RateLimiter.lua` | DataValidator, Logger | Validation / limits |

---

## 3. File Registry

### default.project.json
- Path: `default.project.json`
- Purpose: Rojo DataModel mapping.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### aftman.toml
- Path: `aftman.toml`
- Purpose: Toolchain pins (rojo, wally, selene, stylua).
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### PROJECT_MEMORY.md
- Path: `PROJECT_MEMORY.md`
- Purpose: Permanent agent navigation and history.
- Status: Implemented (append-only).
- Last updated: 2026-10-31T20:31:59+03:00

### GameConfig.lua
- Path: `src/ReplicatedStorage/Shared/Config/GameConfig.lua`
- Purpose: Global settings (players, colors, customers, inventory, datastore, rate limits).
- Main functions: module table constants.
- Dependencies: none.
- Used by: nearly all server systems.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### EconomyConfig.lua
- Path: `src/ReplicatedStorage/Shared/Config/EconomyConfig.lua`
- Purpose: Economy bounds and transaction reason strings.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### ProductConfig.lua
- Path: `src/ReplicatedStorage/Shared/Config/ProductConfig.lua`
- Purpose: Product catalog (Milk, Bread, Apples, Water, Cereal).
- Main functions: `GetAll`, `Get`, `IsValid`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### UpgradeConfig.lua
- Path: `src/ReplicatedStorage/Shared/Config/UpgradeConfig.lua`
- Purpose: Upgrade definitions and cost formula.
- Main functions: `GetCost`, `GetAll`, `Get`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### UIConfig.lua
- Path: `src/ReplicatedStorage/Shared/Config/UIConfig.lua`
- Purpose: UI colors/fonts/tutorial copy.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### GameTypes.lua
- Path: `src/ReplicatedStorage/Shared/Types/GameTypes.lua`
- Purpose: Shared Luau type exports.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### FormatNumber.lua / TableUtils.lua
- Paths: `src/ReplicatedStorage/Shared/Utils/`
- Purpose: Number formatting and table helpers.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### RemoteBootstrap.lua
- Path: `src/ReplicatedStorage/Remotes/RemoteBootstrap.lua`
- Purpose: Create/get RemoteEvents and RemoteFunctions.
- Main functions: `Init`, `GetEvent`, `GetFunction`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### PlayerDataService.lua
- Path: `src/ServerScriptService/Services/PlayerDataService.lua`
- Purpose: DataStore load/save, retries, autosave, load-fail protection.
- Main functions: `Init`, `LoadProfile`, `GetProfile`, `SaveProfile`, `ReleaseProfile`, `StartAutosave`, `SaveAll`.
- Dependencies: DataValidator, GameConfig, DataStoreService.
- Used by: PlayerService, EconomyService, InventoryService, UpgradeService, MonetizationService.
- Status: Implemented (Studio without API Services uses in-memory profiles).
- Last updated: 2026-10-31T20:31:59+03:00

### PlayerService.lua
- Path: `src/ServerScriptService/Services/PlayerService.lua`
- Purpose: Player lifecycle, remote handlers, snapshots.
- Main functions: `Init`, `OnPlayerAdded`, `OnPlayerRemoving`, `BuildSnapshot`, `PushSnapshot`, `BindRemotes`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### EconomyService.lua
- Path: `src/ServerScriptService/Services/EconomyService.lua`
- Purpose: Centralized coins.
- Main functions: `GetBalance`, `CanAfford`, `AddCoins`, `SpendCoins`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### StoreService.lua
- Path: `src/ServerScriptService/Services/StoreService.lua`
- Purpose: Plot registry, ownership, shelf state, teleport.
- Main functions: `RegisterPlot`, `AssignPlot`, `ReleasePlot`, `GetShelves`, `EnsureShelfCount`, `OwnsPlot`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### InventoryService.lua
- Path: `src/ServerScriptService/Services/InventoryService.lua`
- Purpose: Capacity-limited inventory.
- Main functions: `Add`, `Remove`, `CanAdd`, `GetCapacity`, `GetUsed`.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### ProductService.lua / SupplierService.lua / UpgradeService.lua / CustomerService.lua / NotificationService.lua / MonetizationService.lua
- Path: `src/ServerScriptService/Services/`
- Purpose: Domain services as named.
- Status: Implemented (Monetization IDs = 0 placeholders).
- Last updated: 2026-10-31T20:31:59+03:00

### Systems (CustomerAI, CustomerMovement, ShoppingSystem, CheckoutSystem, ShelfSystem, ProgressionSystem, TutorialSystem)
- Path: `src/ServerScriptService/Systems/`
- Purpose: Gameplay flows.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### Utilities (RateLimiter, DataValidator, Logger, MapBuilder)
- Path: `src/ServerScriptService/Utilities/`
- Purpose: Cross-cutting helpers + procedural map.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### Client Controllers
- Path: `src/StarterPlayer/StarterPlayerScripts/Controllers/`
- Purpose: HUD, shop/inventory/upgrade panels, toasts, tutorial, camera.
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

### Documentation
- Paths: `docs/*.md`, `README.md`, `CHANGELOG.md`
- Status: Implemented.
- Last updated: 2026-10-31T20:31:59+03:00

---

## 4. Feature Registry

### FEAT-001 — Project Foundation
- Description: Rojo project, gitignore, aftman, folder structure, docs.
- Status: Implemented.
- Main files: `default.project.json`, `aftman.toml`, `.gitignore`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-002 — Shared Configuration
- Description: Game/economy/product/upgrade/UI configs and types.
- Status: Implemented.
- Main files: `src/ReplicatedStorage/Shared/Config/*`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-003 — Player Lifecycle
- Description: Join load, plot assign, spawn, leave save/release.
- Status: Implemented.
- Main files: `PlayerService.lua`, `PlayerDataService.lua`, `StoreService.lua`
- Known limitations: Multi-server session lock is soft marker only.
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-004 — Economy System
- Description: Central coin add/spend/afford with validation.
- Status: Implemented.
- Main files: `EconomyService.lua`, `EconomyConfig.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-005 — Neighborhood Map & Stores
- Description: Procedural map with 12 plots, roads, warehouse, customer spawn, decorations.
- Status: Implemented.
- Main files: `MapBuilder.lua`, `StoreService.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-006 — Products & Supplier Shop
- Description: Five products; server-validated wholesale purchase remote.
- Status: Implemented.
- Main files: `ProductConfig.lua`, `SupplierService.lua`, `UIController.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-007 — Inventory & Shelves
- Description: Capacity inventory; refill shelves; customer stock take.
- Status: Implemented.
- Main files: `InventoryService.lua`, `ShelfSystem.lua`
- Known limitations: Shelf stock not persisted to DataStore in MVP.
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-008 — NPC Customers & Checkout
- Description: Spawn loop, pathfinding customers, automated checkout sales.
- Status: Implemented.
- Main files: `CustomerService.lua`, `CustomerAI.lua`, `CheckoutSystem.lua`
- Known limitations: Simple deterministic AI; not Studio-playtested in this session.
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-009 — Upgrades
- Description: Shelves, CustomerAttraction, StorageCapacity upgrades.
- Status: Implemented.
- Main files: `UpgradeService.lua`, `UpgradeConfig.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-010 — Progression & Milestones
- Description: Stats tracking and coin milestone rewards.
- Status: Implemented.
- Main files: `ProgressionSystem.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-011 — Tutorial & HUD
- Description: Programmatic HUD, shop/inventory/upgrade panels, tutorial overlay, toasts.
- Status: Implemented.
- Main files: `UIController.lua`, `TutorialController.lua`, `NotificationController.lua`
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-012 — Data Persistence
- Description: Versioned profiles, retries, autosave, BindToClose, load-fail kick.
- Status: Implemented.
- Main files: `PlayerDataService.lua`, `DataValidator.lua`
- Known limitations: Requires API Services enabled for real DataStore tests.
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-013 — Monetization Prep
- Description: ProcessReceipt hook and game pass query helpers; IDs unset (0).
- Status: In Progress.
- Main files: `MonetizationService.lua`
- Known limitations: No real product IDs; must configure before launch.
- Last updated: 2026-10-31T20:31:59+03:00

### FEAT-014 — Polish (Audio/VFX/Mobile)
- Description: Animations, audio, VFX, deeper mobile polish.
- Status: Planned.
- Main files: TBD
- Last updated: 2026-10-31T20:31:59+03:00

---

## 5. Development History — APPEND ONLY

### [2026-10-31T20:31:59+03:00] UPDATE-0001

**Agent:** Cursor Agent

**Operation:** CREATE

**Feature:** Project Foundation + Phases 1–5 MVP + Monetization stubs

**Files Created:**
- `PROJECT_MEMORY.md`
- `default.project.json`
- `aftman.toml`
- `.gitignore`
- `README.md`
- `CHANGELOG.md`
- `docs/ARCHITECTURE.md`
- `docs/GAME_DESIGN.md`
- `docs/DATA_SCHEMA.md`
- `docs/API_REFERENCE.md`
- `docs/SECURITY.md`
- `docs/TESTING.md`
- `src/ReplicatedStorage/Shared/Config/GameConfig.lua`
- `src/ReplicatedStorage/Shared/Config/EconomyConfig.lua`
- `src/ReplicatedStorage/Shared/Config/ProductConfig.lua`
- `src/ReplicatedStorage/Shared/Config/UpgradeConfig.lua`
- `src/ReplicatedStorage/Shared/Config/UIConfig.lua`
- `src/ReplicatedStorage/Shared/Types/GameTypes.lua`
- `src/ReplicatedStorage/Shared/Utils/FormatNumber.lua`
- `src/ReplicatedStorage/Shared/Utils/TableUtils.lua`
- `src/ReplicatedStorage/Remotes/RemoteBootstrap.lua`
- `src/ReplicatedStorage/Remotes/Events/.gitkeep`
- `src/ReplicatedStorage/Remotes/Functions/.gitkeep`
- `src/ServerScriptService/Bootstrap.server.lua`
- `src/ServerScriptService/Services/PlayerDataService.lua`
- `src/ServerScriptService/Services/PlayerService.lua`
- `src/ServerScriptService/Services/EconomyService.lua`
- `src/ServerScriptService/Services/StoreService.lua`
- `src/ServerScriptService/Services/InventoryService.lua`
- `src/ServerScriptService/Services/ProductService.lua`
- `src/ServerScriptService/Services/SupplierService.lua`
- `src/ServerScriptService/Services/UpgradeService.lua`
- `src/ServerScriptService/Services/CustomerService.lua`
- `src/ServerScriptService/Services/NotificationService.lua`
- `src/ServerScriptService/Services/MonetizationService.lua`
- `src/ServerScriptService/Systems/CustomerAI.lua`
- `src/ServerScriptService/Systems/CustomerMovement.lua`
- `src/ServerScriptService/Systems/ShoppingSystem.lua`
- `src/ServerScriptService/Systems/CheckoutSystem.lua`
- `src/ServerScriptService/Systems/ShelfSystem.lua`
- `src/ServerScriptService/Systems/ProgressionSystem.lua`
- `src/ServerScriptService/Systems/TutorialSystem.lua`
- `src/ServerScriptService/Utilities/RateLimiter.lua`
- `src/ServerScriptService/Utilities/DataValidator.lua`
- `src/ServerScriptService/Utilities/Logger.lua`
- `src/ServerScriptService/Utilities/MapBuilder.lua`
- `src/StarterPlayer/StarterPlayerScripts/Bootstrap.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/NotificationController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/TutorialController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/ShopController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/InventoryController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/StoreController.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/CameraController.lua`
- `src/StarterGui/MainUI/init.meta.json`
- `src/Workspace/Map/init.meta.json`
- `src/ServerStorage/Assets/**/.gitkeep`

**Files Modified:**
- None (greenfield besides replaced stub `README.md`)

**Files Deleted:**
- None (README content replaced via overwrite of stub)

**Changes:**
- Created complete Rojo-compatible Mini Market Tycoon project.
- Implemented server-authoritative player, economy, store, inventory, supplier, upgrade, customer, checkout, progression, tutorial, and DataStore systems.
- Built procedural neighborhood map with 12 assignable stores.
- Built client HUD and panels programmatically.
- Added documentation suite and permanent PROJECT_MEMORY.

**Dependencies:**
- Roblox services: Players, DataStoreService, PathfindingService, MarketplaceService, CollectionService, TweenService, Workspace.

**Testing:**
- Static structure validation via filesystem enumeration.
- Roblox Studio Play Solo / multiplayer not executed in this environment (no Studio instance available to the agent).
- Luau runtime not executed locally (requires Roblox/Rojo Studio).

**Known Issues:**
- Shelf stock is runtime-only (not in DataStore schema yet).
- Monetization product IDs are unset (0).
- NPC/pathfinding and multiplayer behavior need Studio verification.
- Physical shelf parts for upgrades beyond base anchors are pre-placed; visual expansion does not yet clone new shelf parts dynamically.

**Status:** Implemented (MVP code complete; Studio testing outstanding).

---

### [2026-10-31T20:57:28+03:00] UPDATE-0002

**Agent:** Cursor Agent

**Operation:** MODIFY

**Feature:** Inventory / Shelf UX feedback

**Files Modified:**
- `src/ServerScriptService/Services/StoreService.lua`
- `src/ServerScriptService/Systems/ShelfSystem.lua`
- `src/ServerScriptService/Services/SupplierService.lua`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/UIController.lua`
- `MiniMarketTycoon.rbxlx` (rebuilt)

**Previous Behavior:**
- Buying stock only updated inventory with weak feedback.
- Shelves had no visible stock labels; customers required shelf stock but this was unclear.
- Reopening Inventory after refill could close the panel instead of refreshing.

**New Behavior:**
- Purchase toast tells player to Inventory → Refill.
- Inventory panel shows empty/hint text and refreshes after buy/refill.
- Shelves show BillboardGui stock labels and turn green when stocked.

**Reason:**
Studio playtest: player bought products but saw no customers because shelves were never refilled, and empty brown shelves looked unstocked.

**Testing:**
- Code changes + `rojo build` to `MiniMarketTycoon.rbxlx`.
- Studio verification pending by user after reopening rebuilt place.

**Status:** Implemented.

---

## 6. Architectural Decisions

### [2026-10-31T20:31:59+03:00] ADR-001 — Server-Authoritative Services Architecture

**Context:** Need clear ownership of economy and multiplayer safety for a solo developer.

**Decision:** Modular ModuleScripts under Services/Systems with a thin Bootstrap; all remotes validated on server.

**Alternatives:** Single Script monolith; client-authoritative prototype.

**Reasoning:** Matches Roblox best practices and the security requirements; easier for agents to navigate via PROJECT_MEMORY.

**Consequences:** More files; remotes must be registered centrally in RemoteBootstrap.

### [2026-10-31T20:31:59+03:00] ADR-002 — Procedural Map via MapBuilder

**Context:** Avoid external 3D asset dependency for MVP.

**Decision:** Build neighborhood and store templates from Parts at server start.

**Alternatives:** Hand-built Studio place file; MeshPart assets.

**Reasoning:** Fully syncable via Rojo; reproducible.

**Consequences:** Visuals are simple low-poly parts; can later replace with richer assets under ServerStorage/Assets.

### [2026-10-31T20:31:59+03:00] ADR-003 — Runtime Shelf Stock (Not Persisted)

**Context:** Faster MVP loop; reduce schema complexity.

**Decision:** Persist inventory/upgrades/coins; keep shelf quantities in StoreService memory.

**Alternatives:** Persist shelves in profile.

**Reasoning:** Players can restock quickly; avoids migration complexity for first shippable loop.

**Consequences:** Rejoin starts with empty shelves until restocked; must document and optionally change later (new ADR).

### [2026-10-31T20:31:59+03:00] ADR-004 — Programmatic UI

**Context:** Keep UI in source control without rbxmx binary dependence.

**Decision:** Build HUD/panels in Luau controllers.

**Alternatives:** Studio-only ScreenGui instances.

**Reasoning:** Rojo-friendly and reviewable.

**Consequences:** StarterGui/MainUI is a disabled placeholder; live UI is MiniMarketHUD ScreenGui.

---

## 7. Database and Data Schema Registry

- **DataStore name:** `MiniMarketPlayerData_v1`
- **Schema version:** 1
- **Key pattern:** `Player_<userId>`
- **Session key:** `Player_<userId>_Session`
- **Fields:** Version, Coins, Inventory, Upgrades, Progression, TutorialStep, TutorialCompleted, StoreName, LastSave
- **Validation:** `DataValidator.SanitizeProfile`
- **Persistence behavior:** Load on join; autosave every 60s; save on leave; SaveAll on shutdown; skip save if load failed
- **Migrations:** Sanitize fills missing fields; bump Version to GameConfig.SchemaVersion
- See also: `docs/DATA_SCHEMA.md`

---

## 8. Remote Communication Registry

| Name | Location | Direction | Purpose | Parameters | Server validation | Rate limits | Systems |
|---|---|---|---|---|---|---|---|
| Notify | Events | S→C | Toast | Kind, Message, Duration | N/A | N/A | NotificationService |
| PlayerSnapshot | Events | S→C | State sync | Snapshot table | N/A | N/A | PlayerService |
| TutorialUpdate | Events | S→C | Tutorial | Step payload | N/A | N/A | TutorialSystem |
| MilestoneUnlocked | Events | S→C | Milestone | Id, Description, Reward | N/A | N/A | ProgressionSystem |
| GetSnapshot | Functions | C→S | Pull state | — | Profile required | — | PlayerService |
| PurchaseProduct | Functions | C→S | Buy stock | productId, quantity | Product, qty, funds, capacity | 4/sec | SupplierService |
| RefillShelf | Functions | C→S | Stock shelf | shelfId, productId, quantity | Ownership via player plot, stock | — | ShelfSystem |
| PurchaseUpgrade | Functions | C→S | Buy upgrade | upgradeId | Upgrade id, level, funds | 3/2sec | UpgradeService |
| AdvanceTutorial | Functions | C→S | Next step | — | Profile | — | TutorialSystem |
| SetStoreName | Functions | C→S | Rename | name string 3–40 | Length check | — | PlayerService |

---

## 9. Dependencies and Relationships

```
Bootstrap.server
  → RemoteBootstrap
  → PlayerDataService
  → MapBuilder → StoreService
  → MonetizationService → EconomyService, PlayerDataService
  → PlayerService → (Economy, Store, Inventory, Upgrade, Supplier, Customer, Tutorial, Shelf, Progression)
  → CustomerService → CustomerAI → Movement, Shopping, Checkout, Shelf, Tutorial

Bootstrap.client
  → UIController / NotificationController / TutorialController / CameraController
  → Remotes (PlayerSnapshot, Notify, TutorialUpdate, GetSnapshot, …)

EconomyService → PlayerDataService
InventoryService → PlayerDataService, ProductConfig
SupplierService → EconomyService, InventoryService, ProductService, RateLimiter
UpgradeService → EconomyService, StoreService, PlayerDataService
CheckoutSystem → EconomyService, ProgressionSystem, StoreService
```

---

## 10. Known Issues and Technical Debt

| ID | Issue | Status | Notes |
|---|---|---|---|
| ISSUE-001 | No Roblox Studio playtest in this session | Open | Must verify NPCs, remotes, UI in Studio |
| ISSUE-002 | Shelf stock not persisted | Open | ADR-003; consider schema v2 |
| ISSUE-003 | Monetization IDs unset | Open | Configure after Creator Dashboard |
| ISSUE-004 | Upgrade shelves do not clone new physical shelf parts | Open | Logic shelf slots increase; visual anchors pre-created (base+2) |
| ISSUE-005 | Soft session lock only | Open | Strengthen multi-server lock before scale |
| ISSUE-006 | Missing automated Luau unit tests | Open | Pure logic tests not yet wired |
| ISSUE-007 | Audio/VFX polish absent | Open | Phase 6 |

---

## 11. Testing Registry

### [2026-10-31T20:31:59+03:00] TEST-0001

- **Feature tested:** Project structure / file presence
- **Environment:** Windows workspace `d:\mini-market-game`
- **Players:** 0 (no Studio)
- **Scenarios:** Directory creation; config/service/controller files written
- **Results:** ~59 source/doc files present
- **Failed tests:** Studio playtests not run
- **Outstanding:** Full checklist in `docs/TESTING.md`

---

## 12. Current Development State

- **Current phase:** Phase 5 + UX feedback fix; Studio playtest in progress via `MiniMarketTycoon.rbxlx`
- **Completed phases (code):** 1 Foundation, 2 Store Management, 3 NPC Customers, 4 Progression, 5 Persistence (integration points)
- **Active development task:** Help user complete Shop → Inventory Refill → Customer loop in Studio
- **Next recommended task:** Reopen rebuilt `MiniMarketTycoon.rbxlx`, refill shelves, confirm NPC customers spawn
- **Features awaiting testing:** NPC pathfinding, DataStore with API Services, multiplayer ownership, mobile HUD
- **Blocking issues:** Live Rojo plugin sync still failing with InvalidUrl; using rbxlx rebuild workflow

---

## 13. Agent Instructions

Every Cursor Agent must follow these instructions:

1. Read PROJECT_MEMORY.md before touching project files.
2. Locate the relevant feature using the Feature Registry.
3. Locate relevant files using the File Registry.
4. Read only the relevant implementation files and their necessary dependencies.
5. Do not scan the entire repository unless genuinely necessary.
6. Never assume a feature is unimplemented simply because its code is not in the first file inspected.
7. Check the Architecture Map before creating new services or modules.
8. Reuse existing implementations where appropriate.
9. Avoid duplicate services, functions, remote events, and configurations.
10. Follow existing naming conventions and architectural decisions.
11. Identify affected dependencies before modifying code.
12. Update PROJECT_MEMORY.md after completing changes.
13. Record every created, modified, deleted, or renamed file.
14. Record test results honestly.
15. Update the File Registry and Feature Registry.
16. Append a timestamped Development History entry.
17. Update the Current Development State.
18. Never delete historical records.
19. Never overwrite the file.
20. If uncertain about an existing implementation, inspect its relevant files before making changes.

### Memory integrity rules (permanent)

1. NEVER delete PROJECT_MEMORY.md.
2. NEVER truncate PROJECT_MEMORY.md.
3. NEVER overwrite its existing contents.
4. NEVER remove historical entries.
5. NEVER rewrite the entire file to simplify it.
6. NEVER remove outdated information from its history.
7. NEVER replace historical entries with summaries.
8. NEVER reset its contents.
9. NEVER move it without explicitly documenting the change.
10. NEVER exclude it from Git.
11. Every new update must be appended; corrections are new timestamped entries.
12. If historical content is damaged, restore from Git before continuing.

---

# Mini Market Tycoon

Multiplayer supermarket tycoon for Roblox. Own a store, buy stock, shelf products, serve NPC customers, earn coins, and upgrade.

## Requirements

- [Rojo](https://rojo.space/) 7.4+
- [Aftman](https://github.com/LPGhatguy/aftman) (optional, for toolchain)
- Roblox Studio
- Git

## Install toolchain

```bash
aftman install
```

## Sync with Roblox Studio

1. Install the Rojo plugin in Roblox Studio.
2. From the project root:

```bash
rojo serve
```

3. In Studio, connect the Rojo plugin to `localhost:34872`.
4. Press Play (or Start Server + clients for multiplayer tests).

## Project layout

- `src/` — game source (Rojo tree)
- `docs/` — architecture, design, schema, security, testing
- `PROJECT_MEMORY.md` — permanent agent knowledge base (read before changing code)
- `default.project.json` — Rojo project map

## Gameplay loop

**Purchase stock → Stock shelves → Attract customers → Make sales → Earn money → Upgrade store → Expand**

Starting coins: **500**. Free to play; Robux purchases are optional cosmetics/boosts only (IDs configured later).

## Testing

See [docs/TESTING.md](docs/TESTING.md). Use Studio’s multiplayer clients (2–4) for ownership and economy checks.

## Publishing notes

1. Enable Studio API Services for DataStore testing.
2. Create Game Passes / Developer Products in Creator Dashboard.
3. Put real product IDs into `MonetizationService` config (never invent IDs).
4. Security + performance pass before public launch.

## Documentation

| Doc | Purpose |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Systems and dependencies |
| [GAME_DESIGN.md](docs/GAME_DESIGN.md) | Loop, economy, NPCs |
| [DATA_SCHEMA.md](docs/DATA_SCHEMA.md) | Player profile schema |
| [API_REFERENCE.md](docs/API_REFERENCE.md) | Remotes and services |
| [SECURITY.md](docs/SECURITY.md) | Validation rules |
| [TESTING.md](docs/TESTING.md) | Test checklist |
| [PROJECT_MEMORY.md](PROJECT_MEMORY.md) | Living development memory |

# Game Design — Mini Market Tycoon

## Fantasy

You own a small supermarket in a shared neighborhood. Grow stock, serve customers, upgrade, and outpace neighboring players.

## Core loop

1. Buy products from the supplier warehouse (wholesale).
2. Move stock from inventory onto shelves.
3. NPC customers choose stocked stores.
4. Customers browse, take products, pay at checkout.
5. Owner earns sell-price coins.
6. Reinvest into shelves, attraction, and storage.
7. Unlock milestones and raise store level.

## Starting state

- 500 coins
- Empty inventory
- 3 shelves
- Store level 1
- Tutorial incomplete

## Products (MVP)

| Product | Buy | Sell |
|---|---:|---:|
| Milk | 10 | 20 |
| Bread | 8 | 15 |
| Apples | 5 | 10 |
| Water | 4 | 8 |
| Cereal | 12 | 25 |

## Upgrades

1. **Additional Shelves** — more shelf slots
2. **Customer Attraction** — faster customer spawns for your store
3. **Storage Capacity** — larger inventory

## NPC customers

- Global spawn budget (max active)
- Prefer stores with stock and higher attraction
- Deterministic path: spawn → entrance → shelf → checkout → leave
- Only purchase existing shelf stock

## Monetization design

Free to play. Optional Robux for cosmetics, VIP flair, and coin packs. Never required for progression. Product IDs configured after Creator Dashboard setup.

## Visual direction

Bright low-poly neighborhood: primary `#28A9E0`, secondary `#38C985`, accent `#FFC857`, background `#F4F7FA`.

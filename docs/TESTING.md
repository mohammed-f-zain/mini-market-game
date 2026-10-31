# Testing — Mini Market Tycoon

## Environment

- Roblox Studio Play Solo
- Studio multiplayer (2–4 clients)
- Enable API Services for DataStore tests

## Player

- [ ] Join assigns unique plot and teleports to store
- [ ] Leave releases plot
- [ ] Rejoin loads profile (with API Services)
- [ ] Two players cannot share a plot

## Economy

- [ ] Buy 5 Milk deducts 50 coins and adds inventory
- [ ] Insufficient funds rejected
- [ ] Invalid quantity rejected
- [ ] Customer sale increases coins by sell prices only

## Inventory / shelves

- [ ] Refill moves inventory → shelf
- [ ] Cannot overfill shelf
- [ ] Cannot refill another player's store (no remote path)

## NPC

- [ ] Customers spawn when shelves have stock
- [ ] Empty stores are skipped
- [ ] NPCs cleaned up after leaving
- [ ] Active count respects max

## Upgrades / progression

- [ ] Upgrade spends coins and increases level
- [ ] Max level blocked
- [ ] Milestones grant rewards once

## Security

- [ ] Remote with bad types returns error
- [ ] Rapid purchase remotes rate-limited

## Launch checklist

- [ ] 8–12 player stress session
- [ ] DataStore soak + shutdown save
- [ ] Monetization receipt test with real product IDs
- [ ] Mobile HUD usability

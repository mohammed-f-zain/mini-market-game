# Security — Mini Market Tycoon

## Boundaries

- Server is source of truth for money, stock, ownership, upgrades, and sales.
- Clients may request actions only; never send prices or balances to apply.

## Protections implemented

1. **Remote validation** — type checks, quantity bounds, product/upgrade IDs
2. **Rate limiting** — purchase and upgrade remotes
3. **Ownership checks** — shelf refill uses caller's assigned store only
4. **Economy centralization** — all coin changes via `EconomyService`
5. **Anti double-checkout** — transaction ID set in `CheckoutSystem`
6. **DataStore load failure** — refuse default overwrite / kick player
7. **Monetization** — `ProcessReceipt` idempotent via purchase ID set; IDs not invented

## Exploit attempts to reject

- Negative / NaN / infinite amounts
- Fake product prices from client
- Modifying another player's store
- Spamming remotes
- Claiming sales without shelf stock

## Remaining hardening (pre-launch)

- Additional per-remote telemetry
- Stronger session lock conflict handling across servers
- Persist and validate shelf state if made durable

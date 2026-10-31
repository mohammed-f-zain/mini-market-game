--!strict
--[[
	GameTypes.lua
	Shared Luau type definitions.
]]

export type UpgradesData = {
	Shelves: number,
	CustomerAttraction: number,
	StorageCapacity: number,
}

export type ProgressionData = {
	StoreLevel: number,
	TotalEarned: number,
	CustomersServed: number,
	ProductsSold: number,
	TimePlayed: number,
	MilestonesClaimed: { [string]: boolean },
}

export type ShelfStock = {
	ProductId: string?,
	Quantity: number,
}

export type StoreRuntime = {
	PlotId: number,
	Shelves: { [string]: ShelfStock },
}

export type PlayerProfile = {
	Version: number,
	Coins: number,
	Inventory: { [string]: number },
	Upgrades: UpgradesData,
	Progression: ProgressionData,
	TutorialStep: number,
	TutorialCompleted: boolean,
	StoreName: string,
	LastSave: number,
}

export type TransactionRecord = {
	Reason: string,
	Amount: number,
	BalanceAfter: number,
	Timestamp: number,
}

export type PurchaseRequest = {
	ProductId: string,
	Quantity: number,
}

export type RefillRequest = {
	ShelfId: string,
	ProductId: string,
	Quantity: number,
}

export type UpgradeRequest = {
	UpgradeId: string,
}

export type NotificationPayload = {
	Kind: string,
	Message: string,
	Duration: number?,
}

export type PlayerSnapshot = {
	Coins: number,
	Inventory: { [string]: number },
	Upgrades: UpgradesData,
	Progression: ProgressionData,
	InventoryCapacity: number,
	InventoryUsed: number,
	PlotId: number?,
	StoreName: string,
	TutorialStep: number,
	TutorialCompleted: boolean,
	Shelves: { [string]: ShelfStock },
}

return nil

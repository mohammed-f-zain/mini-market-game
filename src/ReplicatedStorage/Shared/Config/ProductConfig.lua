--!strict
--[[
	ProductConfig.lua
	Catalog of purchasable and sellable products.
]]

export type ProductDefinition = {
	Id: string,
	DisplayName: string,
	Description: string,
	PurchasePrice: number,
	SellPrice: number,
	IconColor: Color3,
	UnlockStoreLevel: number,
	ModelName: string,
}

local ProductConfig: { [string]: ProductDefinition } = {
	Milk = {
		Id = "Milk",
		DisplayName = "Milk",
		Description = "Fresh dairy milk.",
		PurchasePrice = 10,
		SellPrice = 20,
		IconColor = Color3.fromHex("FFFFFF"),
		UnlockStoreLevel = 1,
		ModelName = "Product_Milk",
	},
	Bread = {
		Id = "Bread",
		DisplayName = "Bread",
		Description = "Warm bakery bread.",
		PurchasePrice = 8,
		SellPrice = 15,
		IconColor = Color3.fromHex("D4A574"),
		UnlockStoreLevel = 1,
		ModelName = "Product_Bread",
	},
	Apples = {
		Id = "Apples",
		DisplayName = "Apples",
		Description = "Crisp red apples.",
		PurchasePrice = 5,
		SellPrice = 10,
		IconColor = Color3.fromHex("E74C3C"),
		UnlockStoreLevel = 1,
		ModelName = "Product_Apples",
	},
	Water = {
		Id = "Water",
		DisplayName = "Water",
		Description = "Bottled drinking water.",
		PurchasePrice = 4,
		SellPrice = 8,
		IconColor = Color3.fromHex("5DADE2"),
		UnlockStoreLevel = 1,
		ModelName = "Product_Water",
	},
	Cereal = {
		Id = "Cereal",
		DisplayName = "Cereal",
		Description = "Crunchy breakfast cereal.",
		PurchasePrice = 12,
		SellPrice = 25,
		IconColor = Color3.fromHex("F5B041"),
		UnlockStoreLevel = 1,
		ModelName = "Product_Cereal",
	},
}

function ProductConfig.GetAll(): { ProductDefinition }
	local list: { ProductDefinition } = {}
	for _, product in pairs(ProductConfig) do
		if type(product) == "table" and product.Id then
			table.insert(list, product :: ProductDefinition)
		end
	end
	table.sort(list, function(a, b)
		return a.DisplayName < b.DisplayName
	end)
	return list
end

function ProductConfig.Get(productId: string): ProductDefinition?
	local product = ProductConfig[productId]
	if type(product) == "table" and product.Id then
		return product :: ProductDefinition
	end
	return nil
end

function ProductConfig.IsValid(productId: string): boolean
	return ProductConfig.Get(productId) ~= nil
end

return ProductConfig

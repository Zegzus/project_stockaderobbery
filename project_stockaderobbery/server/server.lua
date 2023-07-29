--------------------------------
------- Created by Hamza -------
-------------------------------- 

local ESX = nil

local SmelteryTimer = {}
local ExchangeTimer = {}
local GoldJobTimer = {}

local NPC = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while true do
		NPC = math.random(1,#Config.MissionNPC)
		TriggerClientEvent("esx_money:spawnNPC",-1,Config.MissionNPC[NPC])
		Citizen.Wait(7200000*2)
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	TriggerClientEvent("esx_money:spawnNPC",playerId,Config.MissionNPC[NPC])
end)

-- server side for cooldown timer
RegisterServerEvent("esx_money:GoldJobCooldown")
AddEventHandler("esx_money:GoldJobCooldown",function(source)
	table.insert(GoldJobTimer,{GoldJobTimer = GetPlayerIdentifier(source), timeGoldJob = (2 * 60000)}) -- cooldown timer for doing missions
end)

-- thread for syncing the cooldown timer
Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
	Citizen.Wait(1000)
		for k,v in pairs(GoldJobTimer) do
			if v.timeGoldJob <= 0 then
				RemoveGoldJobTimer(v.GoldJobTimer)
			else
				v.timeGoldJob = v.timeGoldJob - 1000
			end
		end
	end
end)

-- server side function to get cooldown timer
ESX.RegisterServerCallback("esx_money:getGoldJobCoolDown",function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if not CheckGoldJobTimer(GetPlayerIdentifier(source)) then
		cb(false)
	else
		TriggerClientEvent("esx:showNotification",source,string.format("Następna robota będzie dostępna za: " ..GetGoldJobTimer(GetPlayerIdentifier(source)).." minut"))
		cb(true)
	end
end)

-- server side function to get payment
RegisterServerEvent('esx_money:missionAccepted')
AddEventHandler('esx_money:missionAccepted', function()
	TriggerClientEvent("esx_money:startMission",source,0)
end)

ESX.RegisterServerCallback("esx_money:getPayment",function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local Players = ESX.GetPlayers()
	local blackMoney = 0
	blackMoney = xPlayer.getAccount('black_money').money
	local moneyCash = 0
	moneyCash = xPlayer.getMoney()
	if Config.UseBlackMoneyAsMissionCost == true then
		if blackMoney <= Config.MissionCost then
			TriggerClientEvent('esx:showNotification', source, "Nie masz wystarczająco brudnej gotówki")
			cb(false)
		else
			xPlayer.removeAccountMoney('black_money', Config.MissionCost)
			TriggerEvent("esx_money:GoldJobCooldown",source)
			cb(true)
		end
	else
		if moneyCash <= Config.MissionCost then
			TriggerClientEvent('esx:showNotification', source, "Nie masz wystarczająco gotówki")
			cb(false)
		else
			xPlayer.removeMoney(Config.MissionCost)
			TriggerEvent("esx_money:GoldJobCooldown",source)
			cb(true)
		end
	end
end)

-- server side function to accept the mission
ESX.RegisterServerCallback("esx_money:getMissionavailability",function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local Players = ESX.GetPlayers()
	local policeOnline = 0
	for i = 1, #Players do
		local xPlayer = ESX.GetPlayerFromId(Players[i])
		if xPlayer["job"]["name"] == Config.PoliceDatabaseName then
			policeOnline = policeOnline + 1
		end
	end
	if policeOnline >= Config.RequiredPoliceOnline then
		cb(true)
	else
		cb(false)
		TriggerClientEvent('esx:showNotification', source, "Nie ma tylu policjantów na służbie")
	end
end)

-- mission reward
RegisterServerEvent('esx_money:reward')
AddEventHandler('esx_money:reward', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local SecondItem = false
	
	-- item 1
	local itemAmount1 = ((math.random(Config.ItemMinAmount1,Config.ItemMaxAmount1)) * 100)
	local item1 = ESX.GetItemLabel(Config.ItemName1)
	
	-- item 2
	local itemAmount2 = math.random(Config.ItemMinAmount2,Config.ItemMaxAmount2)
	local item2 = ESX.GetItemLabel(Config.ItemName2)
	
	local chance = math.random(1,Config.RandomChance)
	if chance == 1 then
		SecondItem = true	
	end
	
	if Config.EnableSecondItemReward == true and SecondItem == true then
		xPlayer.addInventoryItem(Config.ItemName1,itemAmount1)
		xPlayer.addInventoryItem(Config.ItemName2,itemAmount2)
		if Config.EnableCustomNotification == true then
			TriggerClientEvent("esx_money:missionComplete", source,itemAmount1,item1,itemAmount2,item2)
		else
			TriggerClientEvent('esx:showNotification', source, "~g~Robota ukończona:~s~ Otrzymałeś ~b~"..itemAmount1.."x~s~ ~y~"..item1.."~s~ and "..itemAmount2.."x~s~ ~y~"..item2.."~s~")
		end
	else
		xPlayer.addInventoryItem(Config.ItemName1,itemAmount1)
		if Config.EnableCustomNotification == true then
			TriggerClientEvent("esx_money:missionComplete", source,itemAmount1,item1)
		else
			TriggerClientEvent('esx:showNotification', source, "~g~Robota ukończona:~s~ Otrzymałeś ~b~"..itemAmount1.."x~s~ ~y~"..item1.."~s~")
		end
	end
	
end)

RegisterServerEvent('esx_money:GoldJobInProgress')
AddEventHandler('esx_money:GoldJobInProgress', function(targetCoords, streetName)
	TriggerClientEvent('esx_money:outlawNotify', -1,string.format("^3 Shots fired ^0 at ^5%s^0 and ongoing grand theft auto",streetName))
	TriggerClientEvent('esx_money:GoldJobInProgress', -1, targetCoords)
end)

-- sync mission data
RegisterServerEvent("esx_money:syncMissionData")
AddEventHandler("esx_money:syncMissionData",function(data)
	TriggerClientEvent("esx_money:syncMissionData",-1,data)
end)

-- ## DO NOT TOUCH BELOW THIS!! ## --

-- Functions for Mission Timer:
function RemoveGoldJobTimer(source)
	for k,v in pairs(GoldJobTimer) do
		if v.GoldJobTimer == source then
			table.remove(GoldJobTimer,k)
		end
	end
end
function GetGoldJobTimer(source)
	for k,v in pairs(GoldJobTimer) do
		if v.GoldJobTimer == source then
			return math.ceil(v.timeGoldJob/60000)
		end
	end
end
function CheckGoldJobTimer(source)
	for k,v in pairs(GoldJobTimer) do
		if v.GoldJobTimer == source then
			return true
		end
	end
	return false
end

--------------------------------
------- Created by Hamza -------
-------------------------------- 

ESX = nil
local timing, isPlayerWhitelisted = math.ceil(1 * 60000), false

local PlayerData = nil
local CurrentMission = nil
local StopMission = false
local Goons = {}
local JobVan

local DeliveryBlip
local blip
local DeliveryBlipCreated = false

local talkingWithNPC = false
local JobInProgress = false

local JobVanSpawned = false
local GoonsSpawned = false
local JobPlayer = false

local isVehicleLockPicked = false
local JobVanPlate = ''
local DeliveryInProgress = false
local InsideJobVan = false
local vanIsDelivered = false

local streetName
local _
local playerGender

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
	TriggerEvent('skinchanger:getSkin', function(skin)
		playerGender = skin.sex
	end)
	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

RegisterNetEvent('esx_money:outlawNotify')
AddEventHandler('esx_money:outlawNotify', function(alert)
	if isPlayerWhitelisted then
	end
end)

function refreshPlayerWhitelisted()	
	if not ESX.PlayerData then
		return false
	end

	if not ESX.PlayerData.job then
		return false
	end

	if Config.PoliceDatabaseName == ESX.PlayerData.job.name then
		return true
	end

	return false
end

-- trigger correct mission:
RegisterNetEvent("esx_money:startMission")
AddEventHandler("esx_money:startMission",function(spot)
	local num = math.random(1,#Config.MissionPosition)
	local numy = 0
	while Config.MissionPosition[num].InUse and numy < 100 do
		numy = numy+1
		num = math.random(1,#Config.MissionPosition)
	end
	if numy == 100 then
		ESX.ShowNotification("Nie ma roboty dla ciebie, przyjedź później")
	else
		CurrentMission = num
		TriggerEvent("esx_money:startTheEvent",num)
		PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
	end
	talkingWithNPC = false
end)

RegisterNetEvent('esx_money:GoldJobInProgress')
AddEventHandler('esx_money:GoldJobInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.PoliceBlipShow then
		local alpha = Config.PoliceBlipAlpha
		local policeNotifyBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.PoliceBlipRadius)

		SetBlipHighDetail(policeNotifyBlip, true)
		SetBlipColour(policeNotifyBlip, Config.PoliceBlipColor)
		SetBlipAlpha(policeNotifyBlip, alpha)
		SetBlipAsShortRange(policeNotifyBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.PoliceBlipTime * 4)
			alpha = alpha - 1
			SetBlipAlpha(policeNotifyBlip, alpha)

			if alpha == 0 then
				RemoveBlip(policeNotifyBlip)
				return
			end
		end
	end
end)

local AnnounceString = false
local AnnounceHeader = false

-- scaleform function:
function Initialize(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieFunctionParameterString(AnnounceHeader)
    PushScaleformMovieFunctionParameterString(AnnounceString)
    PopScaleformMovieFunctionVoid()
    return scaleform
end

-- Text Options for GTA style mission complete/fail notification:
RegisterNetEvent("esx_money:missionComplete")
AddEventHandler("esx_money:missionComplete", function(itemAmount1,item1,itemAmount2,item2)
	SetAudioFlag("LoadMPData", true)
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1)
    AnnounceHeader = "~g~Zadanie ukończone"
	if itemAmount2 or item2 then
		AnnounceString = "+Otrzymałeś: ~b~"..itemAmount1.."x~s~ ~y~"..item1.."~s~ and "..itemAmount2.."x~s~ ~y~"..item2.."~s~"
	else
		AnnounceString = "+Otrzymałeś: ~b~"..itemAmount1.."x~s~ ~y~"..item1.."~s~"
	end
    Citizen.Wait(5 * 1000)
    AnnounceString = false
end)
RegisterNetEvent("esx_money:missionFailDeath")
AddEventHandler("esx_money:missionFailDeath", function()
	SetAudioFlag("LoadMPData", true)
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1)
    AnnounceHeader = "Zadanie nieudane"
    AnnounceString = "Umarłeś"
    Citizen.Wait(5 * 1000)
    AnnounceString = false
end)

-- NPC Mission spawn event:
local MissionPED = nil
RegisterNetEvent("esx_money:spawnNPC")
AddEventHandler("esx_money:spawnNPC",function(NPC)
	local LocationNPC = NPC.Pos
	local heading = NPC.Heading
	RequestModel(GetHashKey(NPC.Ped))
	while not HasModelLoaded(GetHashKey(NPC.Ped)) do
		Citizen.Wait(100)
	end
	MissionPED = CreatePed(7,GetHashKey(NPC.Ped),LocationNPC.x,LocationNPC.y,LocationNPC.z-1,heading,0,true,true)
	FreezeEntityPosition(MissionPED,true)
	SetBlockingOfNonTemporaryEvents(MissionPED, true)
	TaskStartScenarioInPlace(MissionPED, "WORLD_HUMAN_AA_SMOKE", 0, false)
	SetEntityInvincible(MissionPED,true)

end)

-- Requests the mission from NPC function:
function requestMissionFromNPC()
	talkingWithNPC = true
	local player = PlayerPedId()
	local anim_lib = "missheistdockssetup1ig_5@base"
	local anim_dict = "workers_talking_base_dockworker1"
	
	RequestAnimDict(anim_lib)
	while not HasAnimDictLoaded(anim_lib) do
		Citizen.Wait(0)
	end
	
	ESX.TriggerServerCallback('esx_money:getGoldJobCoolDown', function(cooldownTimer)
		
		if not cooldownTimer then
	
			FreezeEntityPosition(player,true)
			TaskPlayAnim(player,anim_lib,anim_dict,3.0,0.5,-1,31,1.0,0,0)
			
			ESX.Progressbar("Rozmawianie", (6000),{
				FreezePlayer = true, 
				onFinish = function()
			end})
			
			ClearPedTasks(player)
			ClearPedSecondaryTask(player)	
	
			ESX.TriggerServerCallback('esx_money:getMissionavailability', function(missionPossible)
				if missionPossible then
					ESX.TriggerServerCallback('esx_money:getPayment', function(payment)
						if payment then
							TriggerServerEvent("esx_money:missionAccepted")	
						else
							talkingWithNPC = false
						end
					end)					
				else
					talkingWithNPC = false
				end
			end)
		else
			talkingWithNPC = false
		end
	end)
	Citizen.Wait(500)
end

-- Core Mission Part
RegisterNetEvent('esx_money:startTheEvent')
AddEventHandler('esx_money:startTheEvent', function(num)
	local Goons = {}
	local loc = Config.MissionPosition[num]
	Config.MissionPosition[num].InUse = true
	local playerped = GetPlayerPed(-1)
	TriggerServerEvent("esx_money:syncMissionData",Config.MissionPosition)
	local JobCompleted = false
	local blip = CreateMissionBlip(loc.Location)
	JobInProgress = true
	
	while not JobCompleted and not StopMission do
		Citizen.Wait(0)
		
		if JobInProgress == true then
		
			local coords = GetEntityCoords(GetPlayerPed(-1))
			
            if (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) > 60) and DeliveryInProgress == false then
				DrawMissionText("Jedź do celu")
			end
			
			if (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 150) and not JobVanSpawned then
				ClearAreaOfVehicles(loc.Location.x, loc.Location.y, loc.Location.z, 15.0, false, false, false, false, false) 
				local missionCoords = {loc.Location.x, loc.Location.y, loc.Location.z}
				JobVanSpawned = true
                while ESX == nil do
                    Citizen.Wait(1)
                end
				ESX.Game.SpawnVehicle('stockade', vector3(loc.Location), 180, function(vehicle)
					SetEntityCoordsNoOffset(vehicle,loc.Location.x, loc.Location.y, loc.Location.z)
					SetEntityHeading(vehicle,loc.Heading)
					FreezeEntityPosition(vehicle, true)
					SetVehicleOnGroundProperly(vehicle)
					FreezeEntityPosition(vehicle, false)
					JobVan = vehicle
					SetEntityAsMissionEntity(JobVan, true, true)
					SetVehicleDoorsLockedForAllPlayers(JobVan, true)
				end)
			end	
			
			if (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 150) and not GoonsSpawned then
				ClearAreaOfPeds(loc.Location.x, loc.Location.y, loc.Location.z, 50, 1)
				GoonsSpawned = true
				SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey("PLAYER"))
				AddRelationshipGroup('MissionNPCs')
				local i = 0
				for k,v in pairs(loc.GoonSpawns) do
					RequestModel(GetHashKey(v.ped))
					while not HasModelLoaded(GetHashKey(v.ped)) do
						Wait(1)
					end
					Goons[i] = CreatePed(4, GetHashKey(v.ped), v.x, v.y, v.z, v.h, false, true)
					NetworkRegisterEntityAsNetworked(Goons[i])
					SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Goons[i]), true)
					SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Goons[i]), true)
					SetPedCanSwitchWeapon(Goons[i], true)
					SetPedArmour(Goons[i], 100)
					SetPedAccuracy(Goons[i], 60)
					SetEntityInvincible(Goons[i], false)
					SetEntityVisible(Goons[i], true)
					SetEntityAsMissionEntity(Goons[i])
					RequestAnimDict(v.animDict) 
					while not HasAnimDictLoaded(v.animDict) do
						Citizen.Wait(0) 
					end 
					TaskPlayAnim(Goons[i], v.animDict, v.anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
					GiveWeaponToPed(Goons[i], GetHashKey(v.weapon), 255, false, false)
					SetPedFleeAttributes(Goons[i], 0, false)	
					SetPedRelationshipGroupHash(Goons[i], GetHashKey("MissionNPCs"))	
					TaskGuardCurrentPosition(Goons[i], 5.0, 5.0, 1)
					i = i +1
				end
            end
			
			if DeliveryInProgress == false and (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 60) and (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) > 10) then
				DrawMissionText("Zabij wszystkich ochroniarzy i ukradnij auto")
			end
			
			if (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 40) and (not JobPlayer and JobVanSpawned) then
				JobPlayer = true
				SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey("PLAYER"))
				AddRelationshipGroup('MissionNPCs')
				local i = 0
                for k,v in pairs(loc.GoonSpawns) do
                    ClearPedTasksImmediately(Goons[i])
                    i = i +1
                end
                SetRelationshipBetweenGroups(0, GetHashKey("MissionNPCs"), GetHashKey("MissionNPCs"))
                SetRelationshipBetweenGroups(5, GetHashKey("MissionNPCs"), GetHashKey("PLAYER"))
                SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("MissionNPCs"))
            end
			
			if isVehicleLockPicked == false and (GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 10) then
				DrawMissionText("Ukradnij i otwórz ~y~auto~s~")
			end
			
			local VanPosition = GetEntityCoords(JobVan) 
			
			if (GetDistanceBetweenCoords(coords, VanPosition.x, VanPosition.y, VanPosition.z, true) <= 2) and isVehicleLockPicked == false then
				DrawText3Ds(VanPosition.x, VanPosition.y, VanPosition.z, "Naciśnij ~g~[G]~s~ by ~y~otworzyć auto~s~")
				if IsControlJustPressed(1, 47) then
					if exports["k5_skillcheck"]:skillCheck("hard") then
						LockpickVanDoor()
						Citizen.Wait(500)
					else
						ESX.ShowNotification("Nie udało ci się")
					end
				end
			end
			
			if IsPedInAnyVehicle(GetPlayerPed(-1), true) and isVehicleLockPicked == true then
				if GetDistanceBetweenCoords(coords, loc.Location.x, loc.Location.y, loc.Location.z, true) < 5 then
					local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					if GetEntityModel(vehicle) == GetHashKey('stockade') then
						RemoveBlip(blip)
						for k,v in pairs(Config.DeliveryPoints) do
							if DeliveryBlipCreated == false then
								PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
								DeliveryBlipCreated = true
								DeliveryBlip = AddBlipForCoord(v.x, v.y, v.z)
								SetBlipColour(DeliveryBlip,5)
								BeginTextCommandSetBlipName("STRING")
								AddTextComponentString("Punkt dostawy")
								EndTextCommandSetBlipName(DeliveryBlip)
								JobVanPlate = GetVehicleNumberPlateText(vehicle)
								SetBlipRoute(DeliveryBlip, true)
								SetBlipRouteColour(DeliveryBlip, 5)
							end	
						end
						
						DeliveryInProgress = true
					end
				end	
			end
						
			if DeliveryInProgress == true and isVehicleLockPicked == true then
				DrawMissionText("Dostarcz auto do celu")
			end
			
			if DeliveryInProgress == true then
                local coords = GetEntityCoords(GetPlayerPed(-1))
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                if GetEntityModel(vehicle) == GetHashKey('stockade') then
                    InsideJobVan = true
                else
                    InsideJobVan = false
                end
				for k,v in pairs(Config.DeliveryPoints) do
					if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DeliveryDrawDistance) then
						DrawMarker(Config.DeliveryMarkerType, v.x, v.y, v.z-0.97, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, Config.DeliveryMarkerScale.x, Config.DeliveryMarkerScale.y, Config.DeliveryMarkerScale.z, Config.DeliveryMarkerColor.r, Config.DeliveryMarkerColor.g, Config.DeliveryMarkerColor.b, Config.DeliveryMarkerColor.a, false, true, 2, false, false, false, false)
					end
					if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 2.0) and vanIsDelivered == false then
						DrawText3Ds(v.x, v.y, v.z, "Naciśnij ~g~[E]~s~ by ~y~dostarczyć~s~")
						if IsControlJustPressed(0, 38) then 
							RemoveBlip(DeliveryBlip)
							vanIsDelivered = true
							DeleteVehicle(JobVan)
							Citizen.Wait(500)
						end
					end
				end
			end
			
			if vanIsDelivered == true then	
				TriggerServerEvent("esx_money:reward")
				Config.MissionPosition[num].InUse = false
				TriggerServerEvent("esx_money:syncMissionData",Config.MissionPosition)
				
				local i = 0
                for k,v in pairs(loc.GoonSpawns) do
                    if DoesEntityExist(Goons[i]) then
                        DeleteEntity(Goons[i])
                    end
                    i = i +1
				end
				
				JobCompleted = true
				JobInProgress = false
				JobVanSpawned = false
				GoonsSpawned = false
				JobPlayer = false
				JobVanPlate = ''
				isVehicleLockPicked = false
				DeliveryInProgress = false
				vanIsDelivered = false
				DeliveryBlipCreated = false
				break
			end
		
			if StopMission == true then
				
				if Config.EnableCustomNotification == true then
					TriggerEvent("esx_money:missionFailDeath")
				else
					ESX.ShowNotification("Misja nieudana! Nie żyjesz")
				end	
								
				Config.MissionPosition[num].InUse = false
				TriggerServerEvent("esx_money:syncMissionData",Config.MissionPosition)
				DeleteVehicle(JobVan)
				
				if DeliveryInProgress == true then
					RemoveBlip(DeliveryBlip)
				else
					RemoveBlip(blip)
				end
				
				local i = 0
                for k,v in pairs(loc.GoonSpawns) do
                    if DoesEntityExist(Goons[i]) then
                        DeleteEntity(Goons[i])
                    end
                    i = i +1
				end
				
				JobCompleted = true
				JobInProgress = false
				JobVanSpawned = false
				GoonsSpawned = false
				JobPlayer = false
				JobVanPlate = ''
				isVehicleLockPicked = false
				DeliveryInProgress = false
				vanIsDelivered = false
				DeliveryBlipCreated = false
				break
			end
			
		end		
	end	
end)

-- Function for lockpicking the van door:
function LockpickVanDoor()
				
	local playerPed = GetPlayerPed(-1)
	
	RequestAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
	while not HasAnimDictLoaded('anim@amb@clubhouse@tutorial@bkr_tut_ig3@') do
		Citizen.Wait(50)
	end
	
	if Config.PoliceNotfiyEnabled == true then
		TriggerServerEvent('esx_money:GoldJobInProgress',GetEntityCoords(PlayerPedId()),streetName)
	end
	
	SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(750)
	FreezeEntityPosition(playerPed, true)
	TaskPlayAnim(playerPed, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', "machinic_loop_mechandplayer", 3.0, -8, -1, 63, 0, 0, 0, 0 )
	
	ESX.Progressbar("Otwieranie auta", (7500),{
        FreezePlayer = true, 
        onFinish = function()
    end})
	
	ClearPedTasks(playerPed)
	FreezeEntityPosition(playerPed, false)
	isVehicleLockPicked = true
	SetVehicleDoorsLockedForAllPlayers(JobVan, false)
	ESX.ShowNotification("Otworzyłeś auto")
end

-- Function for job blip in progress:
function CreateMissionBlip(location)
	local blip = AddBlipForCoord(location.x,location.y,location.z)
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', "Zadanie")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.9) -- set scale
	SetBlipAsShortRange(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 5)
	return blip
end

-- Function for Mission text:
function DrawMissionText(text)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(0.5,0.955)
end

-- Function for 3D text:
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end

-- Thread for Police Notify
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		streetName,_ = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)


AddEventHandler('esx:onPlayerDeath', function(data)
	StopMission = true
	TriggerServerEvent("esx_money:syncMissionData",Config.MissionPosition)
	Citizen.Wait(5000)
	StopMission = false
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

-- Sync mission data
RegisterNetEvent("esx_money:syncMissionData")
AddEventHandler("esx_money:syncMissionData",function(data)
	Config.ArmoredTruck = data
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if AnnounceString then
      scaleform = Initialize("mp_big_message_freemode")
      DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end
  end
end)


RegisterNetEvent("wezrobotehajs")
AddEventHandler("wezrobotehajs",function()
	requestMissionFromNPC()
end)

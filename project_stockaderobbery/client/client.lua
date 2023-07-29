--------------------------------
------- Created by Hamza -------
-------------------------------- 

ESX = nil

local PlayerData = nil
local converting = false
local meltingGold = false
local exchangingGold = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

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

-- Core Thread Function
exports['qtarget']:AddBoxZone("mission", vector3(388.0397, -358.6997, 47.0195), 0.7, 0.7, {
        name="mission",
        heading=270,
        debugPoly=false,
        minZ=32,
        maxZ=34
    }, {
        options = {
            {
            event = "wezrobotehajs",
            icon = "fas fa-sign-in-alt",
            label = "Weź misje",
            },          
        },
            distance = 3
})

-- Core Thread Function
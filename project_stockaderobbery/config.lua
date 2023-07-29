--------------------------------
------- Created by Hamza -------
-------------------------------- 

Config = {}

-- Police Settings:
Config.RequiredPoliceOnline = 5			-- required police online for players to do missions
Config.PoliceDatabaseName = "police"	-- set the exact name from your jobs database for police
Config.PoliceNotfiyEnabled = true		-- police notification upon truck robbery enabled (true) or disabled (false)
Config.PoliceBlipShow = true			-- enable or disable blip on map on police notify
Config.PoliceBlipTime = 30				-- miliseconds that blip is active on map (this value is multiplied with 4 in the script)
Config.PoliceBlipRadius = 50.0			-- set radius of the police notify blip
Config.PoliceBlipAlpha = 250			-- set alpha of the blip
Config.PoliceBlipColor = 5				-- set blip color

-- ## MISSION NPC PART ## --

-- Location where get mission from NPC:
Config.MissionNPC = {
	{
		Pos = {x=388.0397,y=-358.6997,z=48.0195},		-- set NPC coords here
		Heading = 148.0737,							-- set heading of the NPC here
		Ped = 'S_M_M_Mariachi_01'						-- set npc model name here
	},
}

-- Set to true/false depending on whether you want blip on the map for npc
Config.EnableGoldJobBlip = true

-- Mission NPC Blip Settings:
Config.EnableMapBlip = true							-- set between true/false
Config.BlipNameOnMap = "Gold Job NPC"				-- set name of the blip
Config.BlipSprite = 280								-- set blip sprite, lists of sprite ids are here: https://docs.fivem.net/game-references/blips/
Config.BlipDisplay = 4								-- set blip display behaviour, find list of types here: https://runtime.fivem.net/doc/natives/#_0x9029B2F3DA924928
Config.BlipScale = 0.7								-- set blip scale/size on your map
Config.BlipColour = 5								-- set blip color, list of colors available in the bottom of this link: https://docs.fivem.net/game-references/blips/


-- ## GOLD JOB PART ## --

Config.MissionPosition = 
{
	{
		Location = vector3(-882.1442, 6036.6543, 40.9332), -- paleto obok bunkra
		InUse = false,
		Heading = 50.2265,
		GoonSpawns = {
			NPC1 = {
				x = -890.1572,
				y = 6035.4395,
				z = 41.5599,
				h = 216.0971,
				ped = 'G_M_Y_Lost_02',
				animDict = 'amb@world_human_cop_idles@female@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC2 = {
				x = -893.2333,
				y = 6032.7681,
				z = 41.4082,
				h = 219.2614,
				ped = 'G_M_Y_MexGang_01',
				animDict = 'rcmme_amanda1',
				anim = 'stand_loop_cop',
				weapon = 'WEAPON_PISTOL',
			},
			NPC3 = {
				x = -895.0081,
				y = 6031.4766,
				z = 41.2707,
				h = 219.1729,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC4 = {
				x = -897.1825,
				y = 6029.5449,
				z = 40.9013,
				h = 219.3029,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC5 = {
				x = -898.9062,
				y = 6026.9121,
				z = 40.1624,
				h = 217.2985,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC6 = {
				x = -899.6541,
				y = 6024.0879,
				z = 39.3047,
				h = 236.1433,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC7 = {
				x = -894.1702,
				y = 6017.5015,
				z = 37.8297,
				h = 244.2109,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC8 = {
				x = -885.9639,
				y = 6021.8955,
				z = 38.9043,
				h = 260.3008,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC9 = {
				x = -877.2714,
				y = 6024.7920,
				z = 38.4660,
				h = 251.1323,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC10 = {
				x = -884.7090,
				y = 6017.0400,
				z = 37.5383,
				h = 189.5546,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC11 = {
				x = -882.3524,
				y = 6013.0791,
				z = 36.4600,
				h = 228.0527,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC12 = {
				x = -875.7667,
				y = 6013.5322,
				z = 35.9567,
				h = 273.8675,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC13 = {
				x = -869.7886,
				y = 6013.3760,
				z = 34.1283,
				h = 311.4154,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC14 = {
				x = -874.6490,
				y = 6005.4507,
				z = 32.2416,
				h = 200.7217,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
			NPC15 = {
				x = -867.7230,
				y = 6007.4980,
				z = 31.4551,
				h = 194.3214,
				ped = 'G_M_Y_SalvaBoss_01',
				animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base',
				anim = 'base',
				weapon = 'WEAPON_PISTOL',
			},
		}
	}
}

-- Gold Job Delivery Locations:
Config.DeliveryPoints = {
	vector3(2132.3293, 4775.9165, 40.9703),
}

-- Gold Job Delivery Marker Setting:
Config.DeliveryDrawDistance  = 50.0
Config.DeliveryMarkerType  = 27
Config.DeliveryMarkerScale  = { x = 3.0, y = 3.0, z = 1.0 }
Config.DeliveryMarkerColor  = { r = 255, g = 255, b = 0, a = 100 }

-- Enable GTA style "mission complete/fail" notifications:
Config.EnableCustomNotification = true

-- Use BlackMoney or Cash for mission cost?
Config.UseBlackMoneyAsMissionCost = false

-- Set amount of money that mission should cost.
Config.MissionCost = 1000

-- Set cooldown for doing gold jobs in minutes:
Config.JobCooldownTime = 3*60

-- Reward Settings:
Config.ItemName1 = "money"				-- exact name of your item1
Config.ItemMinAmount1 = 100					-- set minimum reward amount of item1 (this value is multiplied with x100)
Config.ItemMaxAmount1 = 100					-- set maximum reward amount of item1 (this value is multiplied with x100)
Config.EnableSecondItemReward = false		-- add another item as reward but this has only 50% chance 
Config.ItemName2 = "cuter"				-- exact name of your item2
Config.ItemMinAmount2 = 1					-- set minimum reward amount of item2
Config.ItemMaxAmount2 = 1					-- set maximum reward amount of item2
Config.RandomChance = 13						-- Set chance, 1/2 is default, which is 50% chance. If u e.g. change value to 4, then 1/4 equals 25% chance.



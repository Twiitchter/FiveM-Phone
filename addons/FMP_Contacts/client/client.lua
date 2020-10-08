-- 				FiveM-Phone =  My Attempt at building a phones				--
--			By DK - 2019			...	Dont forget your Bananas!			--
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--	Global Variables
------------------------------------------------------------------------------

ESX                           = nil

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('Frame:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end
end)

------------------------------------------------------------------------------
--	Script Local Variables													--
------------------------------------------------------------------------------

local Enabled = false
local Loaded = true

------------------------------------------------------------------------------
--	Functions																--
------------------------------------------------------------------------------

function ListApps()


end

function REQUEST_NUI_FOCUS(bool)
    SetNuiFocus(bool, bool)
    if bool == true then
        SendNUIMessage({show = true})
    else
        SendNUIMessage({hide = true})
    end
    return bool
end

RegisterNUICallback(
    "fivem-phone",
    function(data)
        if data.load then
            print("Loaded the tablet")
            Loaded = true
        elseif data.hide then
            print("Hiding the tablet")
            SetNuiFocus(false, false)
            Enabled = false
        elseif data.click then
		-- Click Events
        end
    end
)

------------------------------------------------------------------------------
--	Threads																	--
------------------------------------------------------------------------------

Citizen.CreateThread(function()
        -- Wait for nui to load or just timeout
        local l = 0
        local timeout = false
        while not Loaded do
            Citizen.Wait(0)
            l = l + 1
            if l > 500 then
                Loaded = true
                timeout = true
            end
        end

        if timeout == true then
            print("Failed to load tablet nui... Tabby is god.")
        end

        print("::The client lua for tablet loaded::")

        REQUEST_NUI_FOCUS(false)
		
        while true do
            if (IsControlJustPressed(0, 244)) and GetLastInputMethod(0) then
                Enabled = not Enabled
                REQUEST_NUI_FOCUS(tabEnabled)
                print("The tablet state is: " .. tostring(tabEnabled))
                Citizen.Wait(0)
            end
            if (Enabled) then
                local ped = GetPlayerPed(-1)
                DisableControlAction(0, 1, Enabled) 	-- LookLeftRight
                DisableControlAction(0, 2, Enabled) 	-- LookUpDown
                DisableControlAction(0, 24, Enabled) 	-- Attack
                DisablePlayerFiring(ped, Enabled) 		-- Disable weapon firing
                DisableControlAction(0, 142, Enabled) 	-- MeleeAttackAlternate
                DisableControlAction(0, 106, Enabled) 	-- VehicleMouseControlOverride
            end
            Citizen.Wait(0)
        end
end)


------------------------------------------------------------------------------
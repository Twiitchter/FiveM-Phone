------------------------------------------------------------------------------
__C = exports.core:Core()
------------------------------------------------------------------------------
--	Globals

------------------------------------------------------------------------------
AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerEvent('ClientConsole', 'Start', resourceName..' | has started.')
    OnStart()
end)
------------------------------------------------------------------------------
--	On Start
function OnStart()

end
------------------------------------------------------------------------------

local display = false
 
------------------------------------------------------------------------------
--	Functions																--
------------------------------------------------------------------------------

-- On Command /phone Open Phone.
RegisterCommand("phone", function(source, args)
    SetDisplay(not display)
end)

-- On Keypress F1 Open Phone.
function ButtonOpen()
	if IsControlPressed(0, 288) then
		SetDisplay(not display)	
	end
end

-- The Close by pressing ESC or Backspace.
RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

------------------------------------------------------------------------------
--	Threads																	--
------------------------------------------------------------------------------

Citizen.CreateThread(function()
	ButtonOpen()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)

------------------------------------------------------------------------------
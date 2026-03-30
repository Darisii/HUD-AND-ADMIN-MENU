-- AdminHUD Main Client Script
-- Created by D

local Config = {}
local IsInitialized = false

-- Initialize system
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if not IsInitialized then
            -- Wait for configuration
            if Config and Config.Server then
                IsInitialized = true
                print("[AdminHUD] System initialized successfully")
            end
        end
    end
    end
end)

-- Update player data
RegisterNetEvent('AdminHUD:Client:UpdatePlayerData')
AddEventHandler('AdminHUD:Client:UpdatePlayerData', function(data)
    -- Forward to HUD and Admin systems
    TriggerEvent('HUD:Client:UpdatePlayerData', data)
    TriggerEvent('Admin:Client:UpdatePlayerData', data)
end)

-- Show notification
function ShowNotification(message, type)
    type = type or 'info'
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"AdminHUD", message}
    })
end

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[AdminHUD] Main client script loaded")
        
        -- Load configuration (placeholder)
        Config = {
            Server = {
                name = "AdminHUD Server",
                debug = false
            }
        }
    end
end)

print("[AdminHUD] Main script loaded")

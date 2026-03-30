-- Advanced HUD System
-- Created by D

local Config = {}
local PlayerData = {}
local IsHUDVisible = true
local HUDComponents = {}

-- Load configuration
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        -- Update HUD data
        if PlayerData.money and IsHUDVisible then
            UpdateHUD()
        end
    end
end)

-- Initialize HUD
function InitializeHUD()
    print("[AdminHUD] HUD System Initialized")
    
    -- Create HUD components
    CreateHUDComponents()
    
    -- Start update loop
    StartHUDLoop()
end

-- Create HUD components
function CreateHUDComponents()
    -- Money display
    HUDComponents.money = {
        x = 0.85,
        y = 0.05,
        width = 0.15,
        height = 0.03,
        color = {255, 255, 255},
        background = {0, 0, 0, 150}
    }
    
    -- Health bar
    HUDComponents.health = {
        x = 0.85,
        y = 0.10,
        width = 0.15,
        height = 0.02,
        color = {255, 0, 0},
        background = {0, 0, 0, 150}
    }
    
    -- Armor bar
    HUDComponents.armor = {
        x = 0.85,
        y = 0.13,
        width = 0.15,
        height = 0.02,
        color = {0, 100, 255},
        background = {0, 0, 0, 150}
    }
    
    -- Hunger bar
    HUDComponents.hunger = {
        x = 0.85,
        y = 0.16,
        width = 0.15,
        height = 0.02,
        color = {255, 165, 0},
        background = {0, 0, 0, 150}
    }
    
    -- Thirst bar
    HUDComponents.thirst = {
        x = 0.85,
        y = 0.19,
        width = 0.15,
        height = 0.02,
        color = {0, 150, 255},
        background = {0, 0, 0, 150}
    }
    
    -- Stress bar
    HUDComponents.stress = {
        x = 0.85,
        y = 0.22,
        width = 0.15,
        height = 0.02,
        color = {255, 0, 255},
        background = {0, 0, 0, 150}
    }
end

-- Update HUD
function UpdateHUD()
    local ped = PlayerPedId()
    
    -- Get player stats
    local health = GetEntityHealth(ped)
    local armor = GetPedArmour(ped)
    local hunger = PlayerData.metadata.hunger or 100
    local thirst = PlayerData.metadata.thirst or 100
    local stress = PlayerData.metadata.stress or 0
    
    -- Draw HUD components
    DrawHUDComponent('money', string.format('$%s', formatNumber(PlayerData.money or 0)))
    DrawHUDComponent('health', string.format('Health: %d%%', health))
    DrawHUDComponent('armor', string.format('Armor: %d%%', armor))
    DrawHUDComponent('hunger', string.format('Hunger: %d%%', hunger))
    DrawHUDComponent('thirst', string.format('Thirst: %d%%', thirst))
    DrawHUDComponent('stress', string.format('Stress: %d%%', stress))
end

-- Draw HUD component
function DrawHUDComponent(componentType, text)
    if not HUDComponents[componentType] or not IsHUDVisible then return end
    
    local component = HUDComponents[componentType]
    
    -- Draw background
    DrawRect(
        component.x + component.width/2,
        component.y + component.height/2,
        component.width,
        component.height,
        component.background[1],
        component.background[2],
        component.background[3],
        component.background[4]
    )
    
    -- Draw text
    SetTextFont(0)
    SetTextScale(0.35, 0.35)
    SetTextColour(component.color[1], component.color[2], component.color[3], 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(component.x + component.width/2, component.y)
end

-- Start HUD loop
function StartHUDLoop()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            
            if IsHUDVisible then
                UpdateHUD()
            end
        end
    end)
end

-- Toggle HUD visibility
function ToggleHUD()
    IsHUDVisible = not IsHUDVisible
    
    if IsHUDVisible then
        ShowNotification("HUD enabled", "success")
    else
        ShowNotification("HUD disabled", "info")
    end
end

-- Hide HUD
function HideHUD()
    IsHUDVisible = false
end

-- Show HUD
function ShowHUD()
    IsHUDVisible = true
end

-- Format number with commas
function formatNumber(num)
    if not num then return "0" end
    
    local left, num, right = string.match(num, '^([^%d]*%d)(%d*)(%.*)')
    if left and num and right then
        num = left .. string.reverse(string.gsub(string.reverse(num), "(%d%d%d)", "%1,%2"))
    end
    
    return num .. right
end

-- Get HUD data
function GetHUDData()
    return {
        isVisible = IsHUDVisible,
        components = HUDComponents,
        playerData = PlayerData
    }
end

-- Update player data
RegisterNetEvent('AdminHUD:Client:UpdatePlayerData')
AddEventHandler('AdminHUD:Client:UpdatePlayerData', function(data)
    PlayerData = data
end)

-- HUD toggle command
RegisterCommand('hud', function(source, args)
    ToggleHUD()
end, false)

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Load config (placeholder)
        Config = {}
        
        -- Initialize HUD
        InitializeHUD()
    end
end)

print("[AdminHUD] HUD script loaded")

-- Advanced Admin Menu System
-- Created by D

local Config = {}
local IsAdminMenuOpen = false
local AdminMenuData = {}
local SelectedPlayer = nil

-- Initialize admin menu
function InitializeAdminMenu()
    print("[AdminHUD] Admin Menu Initialized")
    
    -- Load admin permissions
    CheckAdminPermissions()
end

-- Check admin permissions
function CheckAdminPermissions()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            
            -- Check if player is admin
            if IsAdmin() then
                -- Enable admin features
                EnableAdminFeatures()
            end
        end
    end)
end

-- Enable admin features
function EnableAdminFeatures()
    -- Enable admin commands
    -- Enable noclip
    -- Enable god mode
    -- Enable teleport
end

-- Open admin menu
function OpenAdminMenu()
    if not IsAdmin() then
        ShowNotification("You don't have admin permissions", "error")
        return
    end
    
    if IsAdminMenuOpen then return end
    
    IsAdminMenuOpen = true
    SetNuiFocus(true, true)
    
    -- Prepare admin menu data
    PrepareAdminMenuData()
    
    -- Send menu to NUI
    SendNUIMessage({
        action = 'openAdminMenu',
        adminData = AdminMenuData,
        players = GetOnlinePlayers(),
        config = Config
    })
end

-- Close admin menu
function CloseAdminMenu()
    IsAdminMenuOpen = false
    SelectedPlayer = nil
    
    SendNUIMessage({
        action = 'closeAdminMenu'
    })
    
    SetNuiFocus(false, false)
end

-- Prepare admin menu data
function PrepareAdminMenuData()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    AdminMenuData = {
        isAdmin = true,
        playerCoords = coords,
        playerHealth = GetEntityHealth(ped),
        playerArmor = GetPedArmour(ped),
        noclipEnabled = IsNoClipEnabled(),
        godModeEnabled = IsGodModeEnabled(),
        invisibleEnabled = IsInvisibleEnabled()
    }
end

-- Get online players
function GetOnlinePlayers()
    local players = {}
    
    for _, id in ipairs(GetPlayers()) do
        local targetPed = GetPlayerPed(id)
        local targetCoords = GetEntityCoords(targetPed)
        
        table.insert(players, {
            id = id,
            name = GetPlayerName(id),
            coords = targetCoords,
            health = GetEntityHealth(targetPed),
            armor = GetPedArmour(targetPed)
        })
    end
    
    return players
end

-- Admin functions
function TeleportToPlayer(playerId)
    if not IsAdmin() then return end
    
    local targetPed = GetPlayerPed(playerId)
    local targetCoords = GetEntityCoords(targetPed)
    
    SetEntityCoords(PlayerPedId(), targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
    
    LogAdminAction("teleport", string.format("Teleported to player %s", GetPlayerName(playerId)))
    ShowNotification(string.format("Teleported to %s", GetPlayerName(playerId)), "success")
end

function BringPlayer(playerId)
    if not IsAdmin() then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local targetPed = GetPlayerPed(playerId)
    
    SetEntityCoords(targetPed, coords.x, coords.y, coords.z, false, false, false, false)
    
    LogAdminAction("bring", string.format("Brought player %s to admin", GetPlayerName(playerId)))
    ShowNotification(string.format("Brought %s to you", GetPlayerName(playerId)), "success")
end

function HealPlayer(playerId)
    if not IsAdmin() then return end
    
    local targetPed = GetPlayerPed(playerId)
    SetEntityHealth(targetPed, 200)
    
    LogAdminAction("heal", string.format("Healed player %s", GetPlayerName(playerId)))
    ShowNotification(string.format("Healed %s", GetPlayerName(playerId)), "success")
end

function GiveArmor(playerId)
    if not IsAdmin() then return end
    
    local targetPed = GetPlayerPed(playerId)
    SetPedArmour(targetPed, 100)
    
    LogAdminAction("armor", string.format("Gave armor to player %s", GetPlayerName(playerId)))
    ShowNotification(string.format("Gave armor to %s", GetPlayerName(playerId)), "success")
end

function GiveMoney(playerId, amount)
    if not IsAdmin() then return end
    
    TriggerServerEvent('AdminHUD:Server:GiveMoney', playerId, amount)
    
    LogAdminAction("money", string.format("Gave $%d to player %s", amount, GetPlayerName(playerId)))
    ShowNotification(string.format("Gave $%d to %s", amount, GetPlayerName(playerId)), "success")
end

function KickPlayer(playerId, reason)
    if not IsAdmin() then return end
    
    DropPlayer(playerId, reason)
    
    LogAdminAction("kick", string.format("Kicked player %s (Reason: %s)", GetPlayerName(playerId), reason))
    ShowNotification(string.format("Kicked %s", GetPlayerName(playerId)), "success")
end

function BanPlayer(playerId, reason, duration)
    if not IsAdmin() then return end
    
    TriggerServerEvent('AdminHUD:Server:BanPlayer', playerId, reason, duration)
    
    LogAdminAction("ban", string.format("Banned player %s (Reason: %s, Duration: %d)", GetPlayerName(playerId), reason, duration))
    ShowNotification(string.format("Banned %s", GetPlayerName(playerId)), "success")
end

function RevivePlayer(playerId)
    if not IsAdmin() then return end
    
    local targetPed = GetPlayerPed(playerId)
    
    if IsEntityDead(targetPed) then
        local coords = GetEntityCoords(targetPed)
        ResurrectPed(targetPed)
        SetEntityCoords(targetPed, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHealth(targetPed, 200)
    end
    
    LogAdminAction("revive", string.format("Revived player %s", GetPlayerName(playerId)))
    ShowNotification(string.format("Revived %s", GetPlayerName(playerId)), "success")
end

function SpectatePlayer(playerId)
    if not IsAdmin() then return end
    
    local targetPed = GetPlayerPed(playerId)
    local targetCoords = GetEntityCoords(targetPed)
    
    SetEntityVisible(PlayerPedId(), false)
    SetEntityCollision(PlayerPedId(), false)
    
    NetworkSetInSpectatorMode(true, true)
    SetGameplayCamRelativeRotation(true)
    
    Citizen.CreateThread(function()
        while IsAdminMenuOpen and SelectedPlayer == playerId do
            Citizen.Wait(0)
            if DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                SetCamCoord(GetGameplayCamCoords() + (targetCoords - GetGameplayCamCoords()))
            end
        end
        
        SetEntityVisible(PlayerPedId(), true)
        SetEntityCollision(PlayerPedId(), true)
        NetworkSetInSpectatorMode(false, false)
        SetGameplayCamRelativeRotation(false)
    end)
    
    LogAdminAction("spectate", string.format("Started spectating player %s", GetPlayerName(playerId)))
    ShowNotification(string.format("Spectating %s", GetPlayerName(playerId)), "info")
end

function SpawnVehicle(vehicleModel)
    if not IsAdmin() then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    RequestModel(GetHashKey(vehicleModel))
    while not HasModelLoaded(GetHashKey(vehicleModel)) do
        Citizen.Wait(0)
    end
    
    local vehicle = CreateVehicle(GetHashKey(vehicleModel), coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetVehicleNumberPlateText(vehicle, "ADMIN")
    
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    
    LogAdminAction("spawn_vehicle", string.format("Spawned vehicle %s", vehicleModel))
    ShowNotification(string.format("Spawned %s", vehicleModel), "success")
end

function DeleteVehicle()
    if not IsAdmin() then return end
    
    local ped = PlayerPedId()
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        DeleteEntity(vehicle)
        
        LogAdminAction("delete_vehicle", "Deleted vehicle")
        ShowNotification("Vehicle deleted", "success")
    end
end

-- Noclip functions
local NoClipEnabled = false
local NoClipSpeed = 1.0

function ToggleNoclip()
    if not IsAdmin() then return end
    
    NoClipEnabled = not NoClipEnabled
    
    if NoClipEnabled then
        ShowNotification("Noclip enabled", "info")
        LogAdminAction("noclip", "Enabled noclip")
    else
        ShowNotification("Noclip disabled", "info")
        LogAdminAction("noclip", "Disabled noclip")
    end
end

function IsNoClipEnabled()
    return NoClipEnabled
end

-- God mode functions
local GodModeEnabled = false

function ToggleGodMode()
    if not IsAdmin() then return end
    
    GodModeEnabled = not GodModeEnabled
    
    if GodModeEnabled then
        SetEntityInvincible(PlayerPedId(), true)
        ShowNotification("God mode enabled", "info")
        LogAdminAction("godmode", "Enabled god mode")
    else
        SetEntityInvincible(PlayerPedId(), false)
        ShowNotification("God mode disabled", "info")
        LogAdminAction("godmode", "Disabled god mode")
    end
end

function IsGodModeEnabled()
    return GodModeEnabled
end

-- Invisible functions
local InvisibleEnabled = false

function ToggleInvisible()
    if not IsAdmin() then return end
    
    InvisibleEnabled = not InvisibleEnabled
    
    if InvisibleEnabled then
        SetEntityVisible(PlayerPedId(), false)
        SetEntityCollision(PlayerPedId(), false)
        ShowNotification("Invisible mode enabled", "info")
        LogAdminAction("invisible", "Enabled invisible mode")
    else
        SetEntityVisible(PlayerPedId(), true)
        SetEntityCollision(PlayerPedId(), true)
        ShowNotification("Invisible mode disabled", "info")
        LogAdminAction("invisible", "Disabled invisible mode")
    end
end

function IsInvisibleEnabled()
    return InvisibleEnabled
end

-- Logging functions
function LogAdminAction(action, details)
    local playerName = GetPlayerName(PlayerId())
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    
    TriggerServerEvent('AdminHUD:Server:LogAdminAction', {
        admin = playerName,
        action = action,
        details = details,
        timestamp = timestamp
    })
    
    print(string.format("[ADMIN LOG] %s - %s: %s", timestamp, playerName, details))
end

-- Check if admin
function IsAdmin()
    return true -- Placeholder - would check with server
end

-- Noclip movement
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if NoClipEnabled then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local camRot = GetGameplayCamRot(2)
            
            local forward = vector3(
                -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                math.sin(math.rad(camRot.x))
            )
            
            local right = vector3(
                math.cos(math.rad(camRot.z)),
                math.sin(math.rad(camRot.z)),
                0
            )
            
            local up = vector3(0, 0, 1)
            
            local speed = NoClipSpeed
            if IsControlPressed(0, 21) then -- SHIFT
                speed = speed * 2.0
            elseif IsControlPressed(0, 36) then -- CTRL
                speed = speed * 0.5
            end
            
            local newPos = coords
            
            if IsControlPressed(0, 32) then -- W
                newPos = newPos + forward * speed
            end
            if IsControlPressed(0, 33) then -- S
                newPos = newPos - forward * speed
            end
            if IsControlPressed(0, 34) then -- A
                newPos = newPos - right * speed
            end
            if IsControlPressed(0, 35) then -- D
                newPos = newPos + right * speed
            end
            if IsControlPressed(0, 44) then -- Q
                newPos = newPos + up * speed
            end
            if IsControlPressed(0, 38) then -- E
                newPos = newPos - up * speed
            end
            
            SetEntityCoordsNoOffset(ped, newPos.x, newPos.y, newPos.z, false, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityCollision(ped, false, false)
        else
            local ped = PlayerPedId()
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
        end
    end
end)

-- Command handlers
RegisterCommand('adminmenu', function(source, args)
    OpenAdminMenu()
end, false)

RegisterCommand('noclip', function(source, args)
    ToggleNoclip()
end, false)

RegisterCommand('godmode', function(source, args)
    ToggleGodMode()
end, false)

RegisterCommand('invisible', function(source, args)
    ToggleInvisible()
end, false)

-- NUI callbacks
RegisterNUICallback('closeAdminMenu', function(data, cb)
    CloseAdminMenu()
    cb('ok')
end)

RegisterNUICallback('teleportToPlayer', function(data, cb)
    if data.playerId then
        TeleportToPlayer(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    if data.playerId then
        BringPlayer(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('healPlayer', function(data, cb)
    if data.playerId then
        HealPlayer(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('giveArmor', function(data, cb)
    if data.playerId then
        GiveArmor(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('giveMoney', function(data, cb)
    if data.playerId and data.amount then
        GiveMoney(data.playerId, data.amount)
    end
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    if data.playerId and data.reason then
        KickPlayer(data.playerId, data.reason)
    end
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    if data.playerId and data.reason and data.duration then
        BanPlayer(data.playerId, data.reason, data.duration)
    end
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    if data.playerId then
        RevivePlayer(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    if data.playerId then
        SelectedPlayer = data.playerId
        SpectatePlayer(data.playerId)
    end
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    if data.model then
        SpawnVehicle(data.model)
    end
    cb('ok')
end)

RegisterNUICallback('deleteVehicle', function(data, cb)
    DeleteVehicle()
    cb('ok')
end)

RegisterNUICallback('toggleNoclip', function(data, cb)
    ToggleNoclip()
    cb('ok')
end)

RegisterNUICallback('toggleGodMode', function(data, cb)
    ToggleGodMode()
    cb('ok')
end)

RegisterNUICallback('toggleInvisible', function(data, cb)
    ToggleInvisible()
    cb('ok')
end)

-- Get admin menu state
function IsAdminMenuOpen()
    return IsAdminMenuOpen
end

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Config = {}
        InitializeAdminMenu()
    end
end)

print("[AdminHUD] Admin menu script loaded")

local player

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local pedPosition = GetEntityCoords(PlayerPedId())
        local zoneName = GetNameOfZone(pedPosition.x, pedPosition.y, pedPosition.z)
        if player ~= nil then
            TriggerServerEvent('fd_turfs:memberInTurf',source,zoneName,player.gang)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600)
        local id = PlayerId()
        ESX.TriggerServerCallback('fd_turfs:isInGang',function(xPlayer)
            player=xPlayer[1]
        end)
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

end)
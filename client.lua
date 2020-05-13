Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local pedPosition = GetEntityCoords(PlayerPedId())
        local zoneName = GetNameOfZone(pedPosition.x, pedPosition.y, pedPosition.z)
        print(IsPedDeadOrDying(PlayerPedId(),1))
        if IsPedDeadOrDying(PlayerPedId(),1) then
            print("Member in Zone")
            TriggerServerEvent('fd_turfs:memberInTurf',zoneName)
        end
    end
end)

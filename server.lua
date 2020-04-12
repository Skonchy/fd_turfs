ESX=nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local zones={
    forum = {'STRAW','CHAMH'},
    grove = 'DAVIS',
    jamestown = 'RANCHO',
    seoul = 'KOREAT',
    casino = 'CHIL',
    citybikes = 'EAST_V',
    stab = 'SLAB',
    sandyshores = 'SANDY',
    yellowjack = 'DESRT',
    shitterpark =  'WINDF',
    paleto = 'PALETO',
    hookies = 'NCHU',
    barbareno = 'BHAMCA',
    bluffs = 'PBLUFF',
    vineyard = 'TONGVAH',
    weed = 'MTCHIL',
}

local points={
    forum = {},
    grove = {},
    jamestown = {},
    seoul = {},
    casino = {},
    citybikes = {},
    stab = {},
    sandyshores = {},
    yellowjack = {},
    shitterpark = {},
    paleto = {},
    hookies = {},
    barbareno = {},
    bluffs = {},
    vineyard = {},
    weed = {},
}

local open_turfs={}


local gangs={}

function get_gangs()
    MySQL.ready(function()
        MySQL.Async.fetchAll("SELECT * FROM ganglist", {} ,function(result)
            gangs=result
        end)
    end)
end
--for each zone there needs to be a table that lists gangs and points init to 0
Citizen.CreateThread(function()
get_gangs()
Citizen.Wait(3000)
print(dump(gangs))
for k,v in pairs(points) do
    for k1, v1 in pairs(gangs) do
        print(k1)
        table.insert(points[k],{k1,0})
    end
end
end)

function refresh_points(turf)
    points[turf]={}
    for k,v in pairs(gangs) do
        print()
        table.insert(points[turf],{k,0})
    end
end

function turf_taken(turf,gang)
    refresh_points(turf)
    print(turf.." "..gang)
    local open = os.time(os.date('*t'))+172800
    local gang_id=gang
    local gang_name
    MySQL.Async.fetchAll("SELECT name FROM ganglist WHERE id = @id",{['@id']=gang_id},function(result)
        gang_name=result[1]
    end)
    print(gang_name)
    MySQL.Async.execute("UPDATE turfs SET time_open = @time, gang = @gang WHERE id = @turf",{
        ['@time']=open,
        ['@gang']=gang,
        ['@turf']=turf
    }, function(rowsChanged)
    end)
end

function get_open_turfs()
    local open=os.time(os.date('*t'))+21600
    MySQL.Async.fetchAll("SELECT * FROM turfs WHERE time_open < @time", {['@time']=open} , function(result)
        open_turfs=result
    end)
end

function close_turfs() 
    local current_time=os.time(os.date('*t'))
    
    local vprev=0
    local kprev=1
    for k,v in pairs(open_turfs) do
        curTurf=open_turfs[k].description
        for k1,v1 in pairs(points) do
            if k1==curTurf then
                for k2,v2 in pairs(points[curTurf]) do
                    if v2[2] > vprev then
                        vprev=v2
                        kprev=k2
                    end
                end
            end
        end
    end
    if v==0 or v==nil then
        if(open_turfs[kprev]~=nil) then
            MySQL.Async.execute("UPDATE turfs SET gang = @test WHERE id = @id",{
                ['@test']="test",
                ['@id']=open_turfs[kprev].id
            },function(rowsChanged) 
            end)
        end
    else
        turf_taken(open_turfs[kprev].id,kprev)
    end
end

RegisterServerEvent('fd_turfs:memberInTurf')
AddEventHandler(function(source,zone,gang)
    for k4,v4 in pairs(open_turfs) do
        if v4==zone then
            for k,v in pairs(zones) do
                if v==zone then
                    for k2,v2 in pairs(points) do
                        if k2==k then
                            for k3,v3 in pairs(k2) do
                                if k3==gang and total<7200 then
                                    local total=points.k2.k3[2]+1
                                    points.k2.k3[2]=total
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

ESX.RegisterServerCallback('fd_turfs:isInGang', function(source,cb,type)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE gang IS NOT NULL AND identifier = @identifier",{['@identifier']=xPlayer.identifier},function(result)
        cb(result)
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600) -- eventually every 60 minutes or 360000 ms
        get_open_turfs()
        get_gangs()
        close_turfs()
        -- print(dump(gangs))
        -- Citizen.Wait(3000)
        -- print(dump(points))
    end
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
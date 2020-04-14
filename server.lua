ESX=nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local zones={
    forum = 'CHAMH',
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
    strawberry = 'STRAW'
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
    strawberry= {}
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
for k,v in pairs(points) do
    for k1, v1 in pairs(gangs) do
        table.insert(points[k],{k1,0})
    end
end
end)

function refresh_points(turf)
    points[turf]={}
    for k,v in pairs(gangs) do
        table.insert(points[turf],{k,0})
    end
end

function turf_taken(turf,gang)
    refresh_points(turf)
    local open = os.time(os.date('*t'))+21600 --172800
    local gang_id=gang
    local gang_name
    MySQL.Async.fetchAll("SELECT name FROM ganglist WHERE id = @id",{['@id']=gang_id},function(result)
        gang_name=result[1]
    end)
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
    local curTurf
    for k,v in pairs(open_turfs) do
        curTurf=open_turfs[k].description
        for k1,v1 in pairs(points) do
            if k1==curTurf then
                for k2,v2 in pairs(points[k1]) do
                    if points[k1][k2][2] > vprev then
                        vprev=points[k1][k2][2]
                        kprev=k2
                    end
                end
            end
        end
    end
    if vprev==0 then
        if(open_turfs[kprev]~=nil) then
            MySQL.Async.execute("UPDATE turfs SET gang = @gang WHERE id = @id",{
                ['@gang']="test",
                ['@id']=open_turfs[kprev].id
            },function(rowsChanged) 
            end)
        end
    else
        if tonumber(open_turfs[kprev].time_open) <= current_time then
            turf_taken(open_turfs[kprev].id,kprev)
            print("Turf Taken: "..open_turfs[kprev].description.." by gang: "..kprev)
        end
    end
end

RegisterServerEvent('fd_turfs:memberInTurf')
AddEventHandler('fd_turfs:memberInTurf',function(zone,gang)
    for k2,v2 in pairs(open_turfs) do
        if v2.id==zone then
            for k,v in pairs(points[v2.description]) do
                if(k==gang) then
                    local temp = points[v2.description][k][2]
                    temp = temp+1
                    points[v2.description][k][2]=temp
                end
            end
        end
    end
end)

ESX.RegisterServerCallback('fd_turfs:isInGang', function(source,cb,type)
    local xPlayer
    if(true) then
        xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.fetchAll("SELECT * FROM users WHERE gang IS NOT NULL AND identifier = @identifier",{['@identifier']=xPlayer.identifier},function(result)
            cb(result)
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000) -- eventually every 60 minutes or 360000 ms
        get_open_turfs()
        get_gangs()
        close_turfs()
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
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
    -- MySQL.ready(function()
    --     MySQL.Async.fetchAll("SELECT * FROM ganglist", {} ,function(result)
    --         gangs=result
    --     end)
    -- end)
    gangs={}
    exports["externalsql"]:AsyncQueryCallback({
        query = "SELECT DISTINCT gang FROM gangs",
        data = {}
    }, function(result)
        if result.data ~= nil then
            for i=1, tablelength(result.data), 1 do
                table.insert(gangs, result.data[i].gang)
            end
        end
    end)
end
--for each zone there needs to be a table that lists gangs and points init to 0
Citizen.CreateThread(function()
get_gangs()
Citizen.Wait(3000)
for k,v in pairs(points) do
    for _, v1 in pairs(gangs) do
        table.insert(points[k],{v1,0})
    end
end
end)

function refresh_points(turf)
    points[turf]={}
    for _,v in pairs(gangs) do
        table.insert(points[turf],{v,0})
    end
end

function turf_taken(turf,gang)
    refresh_points(turf)
    local open = os.time(os.date('*t'))+21600 --172800
    local gang_name = gang
    local take_turf = turf
    exports["externalsql"]:AsyncQueryCallback({
        query = "UPDATE turfs SET time_open = :time , gang = :gang WHERE id = :turf",
        data ={
            time = open,
            gang = gang_name,
            turf = take_turf
        }
    }, function(yeet) end)
    -- MySQL.Async.fetchAll("SELECT name FROM ganglist WHERE id = @id",{['@id']=gang_id},function(result)
    --     gang_name=result[1]
    -- end)
    -- MySQL.Async.execute("UPDATE turfs SET time_open = @time, gang = @gang WHERE id = @turf",{
    --     ['@time']=open,
    --     ['@gang']=gang,
    --     ['@turf']=turf
    -- }, function(rowsChanged)
    -- end)
end

function get_open_turfs()
    local open=os.time(os.date('*t'))+21600
    exports["externalsql"]:AsyncQueryCallback({
        query = "SELECT * FROM turfs WHERE time_open < :time",
        data ={
            time = open
        }
    }, function(result)
        if result.data ~= nil then
            open_turfs = result.data
        end
    end)
    -- MySQL.Async.fetchAll("SELECT * FROM turfs WHERE time_open < @time", {['@time']=open} , function(result)
    --     open_turfs=result
    -- end)
end

function close_turfs() 
    local current_time=os.time(os.date('*t'))
    
    local vprev=0
    local kprev=1
    local curTurf,gang
    for k,v in pairs(open_turfs) do
        curTurf=open_turfs[k].description
        for k1,v1 in pairs(points) do
            if k1==curTurf then
                for k2,v2 in pairs(points[k1]) do
                    --print(tostring(points[k1][k2][2] > vprev))
                    if points[k1][k2][2] > vprev then
                        vprev=points[k1][k2][2]
                        kprev=k2
                        gang = v2[1]
                    end
                end
            end
        end
    end
    
    --print(dump(open_turfs[kprev]))
    if vprev==0 then
        if(open_turfs[kprev]~=nil) then
            -- MySQL.Async.execute("UPDATE turfs SET gang = @gang WHERE id = @id",{
            --     ['@gang']="test",
            --     ['@id']=open_turfs[kprev].id
            -- },function(rowsChanged) 
            -- end)
        end
    else
        if tonumber(open_turfs[kprev].time_open) <= current_time then
            turf_taken(open_turfs[kprev].id,gang)
            print("Turf Taken: "..open_turfs[kprev].description.." by gang: "..gang)
        end
    end
end

RegisterServerEvent('fd_turfs:memberInTurf')
AddEventHandler('fd_turfs:memberInTurf',function(zone)
    local player = exports["drp_id"]:GetCharacterData(source)
    local gang
    exports["externalsql"]:AsyncQueryCallback({
        query = "SELECT * FROM gangs WHERE char_id = :charid",
        data = {
            charid = player.charid
        }
    }, function(result)
        if result.data[1] ~= nil then
            gang = result.data[1].gang
            for k2,v2 in pairs(open_turfs) do
                if v2.id==zone then
                    for k,v in pairs(points[v2.description]) do
                        if(v[1]==gang) then
                            --print(dump(points[v2.description]))
                            local temp = points[v2.description][k][2]
                            temp = temp+1
                            points[v2.description][k][2]=temp
                        end
                    end
                end
            end
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000) -- eventually every 60 minutes or 360000 ms
        get_open_turfs()
        get_gangs()
        
        print(dump(points))
        close_turfs()
    end
end)


function tablelength(T)
    local count = 0
    for _ in pairs(T) do 
        count = count + 1 
    end
    return count
end

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
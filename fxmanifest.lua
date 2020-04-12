fx_version 'adamant'

game 'gta5'

server_scripts{
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

client_scripts{
    'client.lua'
}

files{

}

dependencies{
    'mysql-async',
	'async'
}
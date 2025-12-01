fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Flux'
github 'https://github.com/fluxcz'
description 'FX Christmas | Flux Development'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'game/src/cl/cl.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'game/src/sv/sv.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_xmas23_convert_package.ytyp'

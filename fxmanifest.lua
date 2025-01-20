fx_version "cerulean"
game "gta5"

author "Stausi"
title "Stausi Scripts - Company Call App"
description "Company Call App"
version 'v1.0.0'
lua54 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/main.lua",
}

client_scripts {
    "client/main.lua"
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    "config.lua",
}

files {
    "web/build/**/*",
	'locales/*.json',
}

ui_page 'web/build/index.html'

dependencies {
    'es_extended',
    "lb-phone",
}

fx_version "cerulean"
game "gta5"

author "Stausi"
title "Stausi Scripts - Company Call App"
description "Company Call App"
version '1.0.0'
lua54 'yes'
package_id "6"

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/main.lua",
}

client_scripts {
    "client/main.lua"
}

shared_scripts {
    '@es_extended/imports.lua',
    '@st_libs/init.lua',
    "config.lua",
}

st_libs {
    'table',
    'print',
    "database",
    "version-checker",
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

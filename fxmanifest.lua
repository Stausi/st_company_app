fx_version "cerulean"
game "gta5"

author "Stausi"
title "Stausi Scripts - Company Call App"
description "Company Call App"
version '1.0.1'
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
    '@st_libs/init.lua',
    "config.lua",
}

st_libs {
    'table',
    'print',
    "database",
    "hook",
    "framework-bridge",
    "version-checker",
}

files {
    "web/build/**/*",
}

ui_page 'web/build/index.html'

dependencies {
    'st_libs',
    'es_extended',
    "lb-phone",
}

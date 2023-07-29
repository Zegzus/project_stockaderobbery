--------------------------------
------- Created by Hamza -------
-------------------------------- 

resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'Edit by Hexus for PF 2.0'
version '1.0'
author 'Hamza'

client_scripts {
    "config.lua",
    "client/client.lua",
    "client/main.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/server.lua"
}
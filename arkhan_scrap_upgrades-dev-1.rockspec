package = "arkhan_scrap_upgrades"
version = "dev-1"
source = {
   url = "git+https://github.com/Warhammer-Mods/arkhan_scrap_upgrades.git"
}
description = {
   detailed = "This mod adds in scrap upgrades for the Tomb Kings using Canopic Jars. Each of the four main Tomb King factions have unique upgrades which cost 100 jars, in addition to a plethora of upgrades for the Tomb King roster, ranging from 30–80 jars.",
   homepage = "https://github.com/Warhammer-Mods/arkhan_scrap_upgrades",
   license = ""
}
dependencies = {
   "lua ~> 5.1",
   "tw-lua-autocomplete",
   "lua-globals"
}
build = {
   type = "builtin",
   modules = {
      ["script.campaign.mod.arky_baby_scrap"] = "script/campaign/mod/arky_baby_scrap.lua"
   }
}

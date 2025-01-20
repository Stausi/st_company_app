Config = {}

Config.ChangeJobCooldown = 30
Config.StatusCooldown = 30
Config.SubCooldown = 30

Config.Companies = {
    { name = "Ambulance", job = "ambulance", img = "ems", showStatus = true },
    { name = "Politiet", job = "police", img = "politiet", showStatus = false },
    { name = "Retsbygningen", job = "retten", img = "retten", showStatus = true },
    { name = "Auto Exotic", job = "mecano", img = "mekaniker", showStatus = true },
    { name = "LS Customs", job = "lscmek", img = "lsc-app", showStatus = true },
    { name = "Bilforhandler", job = "bilforhandler", img = "bilforhandler", showStatus = true },
    { name = "Deluxe Bilforhandler", job = "bilforhandler2", img = "bilforhandler2", showStatus = true },
    { name = "Masaki Leasing", job = "exclusive", img = "masakileasingapp", showStatus = true },
    { name = "MC Forhandler", job = "mcforhandler", img = "mcforhandler", showStatus = true },
    { name = "Bådforhandler", job = "boatdealer", img = "baadforhandler", showStatus = true },
    { name = "Arcadius Investments", job = "revisor", img = "revisor", showStatus = true },
    { name = "LB kapital", job = "iauditor", img = "iauditor", showStatus = true },
    { name = "The Inked Wave", job = "inked_wave", img = "inked_wave", showStatus = true },
    { name = "Itattoo", job = "ss_tattoo", img = "ss_tattoo", showStatus = true },
    { name = "Classic Art", job = "pano_ink", img = "pano_ink", showStatus = true },
    { name = "Empire Ink", job = "empire_ink", img = "empire_ink", showStatus = true },
    { name = "Burgershot", job = "burgershot", img = "burgershot", showStatus = true },
    { name = "Café Søhuset", job = "seahouse", img = "seahouse", showStatus = true },
    { name = "Beton Grillen", job = "kebab", img = "kebab", showStatus = true },
    { name = "Ejendomsmægler", job = "realestate", img = "realestate", showStatus = true },
    { name = "Kørelærernes hus", job = "driving_school", img = "driving_school", showStatus = true },
    { name = "Weazel News", job = "weazel", img = "weazel", showStatus = true },
    { name = "Carpoint", job = "larrys", img = "larrys", showStatus = true },
    { name = "Crown Cars", job = "crowncars", img = "crowncars", showStatus = true },
    { name = "LS Design", job = "lsdesign", img = "lsdesign", showStatus = true },
    { name = "Home Design", job = "homedesign", img = "homedesign", showStatus = true },
    { name = "New Records", job = "nrs", img = "newrecords", showStatus = true },
    { name = "Final.bet", job = "betting", img = "finalbet", showStatus = true },
    { name = "Boligudlejning", job = "bolighaj", img = "bolighaj", showStatus = true },
    { name = "Guldhammer", job = "lmavo", img = "ghadv", showStatus = true },
    { name = "Ret&Råd", job = "retograd", img = "retograd", showStatus = true },
    { name = "Taxi", job = "taxi", img = "taxi", showStatus = true },
}

print_r = function(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    sub_print_r(t, "  ")
end

tableContains = function(t, val)
    for k, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

tablelength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

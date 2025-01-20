local changeJobCooldown = {}
local companyCounters = {}
local serverJobsPlayers = {}
local phoneData = {}

local toggleSubscripeCooldown = {}
local toggleStatusCooldown = {}
local playerCompanyPings = {}
local companyPosts = {}

local companySubscriped = {}

Citizen.CreateThread(function()
    local result = MySQL.query.await("SELECT * FROM phone_company_subscriptions")
    if result then
        for _, data in pairs(result) do
            if not companySubscriped[data.phone_number] then
                companySubscriped[data.phone_number] = {}
            end

            local companies = json.decode(data.companies)
            for _, company in pairs(companies) do
                companySubscriped[data.phone_number][company] = true
            end
        end
    end

    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        local playerJob = xPlayer.job.name

        if not serverJobsPlayers[playerJob] then
            serverJobsPlayers[playerJob] = {}
        end

        local identifier = xPlayer.identifier
        serverJobsPlayers[playerJob][identifier] = true

        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(xPlayer.source)
        if IsJobValid(playerJob) then
            if not companyCounters[playerJob] then
                companyCounters[playerJob] = false
            end

            if not phoneData[playerJob] then
                phoneData[playerJob] = {}
            end

            phoneData[playerJob][xPlayer.source] = phoneNumber
        end

        local sortedSubsCompanies = {}
        local subscribedCompanies = companySubscriped[phoneNumber] or {}
        for _, company in pairs(subscribedCompanies) do
            sortedSubsCompanies[company] = true
        end
    
        playerCompanyPings[xPlayer.source] = sortedSubsCompanies
    end
end)

RegisterNetEvent("st_company_app:SendCompanyMessage", function(message, name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not IsJobValid(name) then 
        return 
    end

    local selectedCompany = nil
    for _, company in pairs(Config.Companies) do
        if company.job == name then
            selectedCompany = company
        end
    end

    if not selectedCompany then
        return
    end

    local companyOnline = IsJobOnline(name)
    if not companyOnline and selectedCompany.showStatus then
        return exports["lb-phone"]:SendNotification(xPlayer.phoneNumber, {
            app = "company_app", 
            title = "Fejl", 
            content = "Der er ingen på arbejde.", 
        })
    end

    exports["lb-phone"]:SendNotification(xPlayer.phoneNumber, {
        app = "company_app", 
        title = "Besked sendt!", 
        content = ("Beskeden til %s er sendt."):format(selectedCompany.name), 
    })

    local playersOnJob = phoneData[name]
    for _, player in pairs(playersOnJob) do
        exports["lb-phone"]:SendNotification(player, {
            app = "company_app", 
            title = selectedCompany.name,
            content = "Opkald modtaget."
        })
    end

    print("sup")
end)

RegisterNetEvent("st_company_app:SendCompanyPost", function(image, title, message)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local jobName = xPlayer.job.name
    if not IsJobValid(jobName) then
        return
    end

    if xPlayer.job.grade_name ~= "boss" then
        return
    end

    local companyName, companyIcon = "", ""
    for _, company in pairs(Config.Companies) do
        if company.job == jobName then 
            companyName = company.name 
            companyIcon = company.img 
        end
    end

    local hasPost = false
    for _, post in pairs(companyPosts) do
        if post.name == jobName then hasPost = true end
    end

    if hasPost then
        return exports["lb-phone"]:SendNotification(_source, {
            app = "company_app", 
            title = companyName,
            content = "Du kan ikke have flere end 1 opslag"
        })
    end

    table.insert(companyPosts, {
        image = image,
        title = title,
        message = message,
        name = jobName,
        icon = companyIcon,
    })

    TriggerClientEvent("st_company_app:updatePosts", -1, companyPosts)
end)

RegisterNetEvent("st_company_app:DeleteCompanyPost", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local jobName = xPlayer.job.name
    for key, post in pairs(companyPosts) do
        if post.name == jobName then table.remove(companyPosts, key) end
    end

    TriggerClientEvent("st_company_app:updatePosts", -1, companyPosts)
end)

RegisterNetEvent("st_company_app:ToggleCompanyStatus", function(name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not toggleStatusCooldown[_source] then
        toggleStatusCooldown[_source] = 0
    end

    if (os.time() - Config.SubCooldown) < toggleStatusCooldown[_source] then
        local minutes = math.floor((Config.StatusCooldown - (os.time() - toggleStatusCooldown[_source])) / 60)
        local seconds = math.fmod((Config.StatusCooldown - (os.time() - toggleStatusCooldown[_source])), 60)
        
        TriggerClientEvent('ox_lib:notify', _source, { 
            type = 'error', 
            duration = 5000, 
            description = ('Cooldown på: ' .. minutes .. " min. & " .. seconds .. " sekunder."),
        })
        
        return
    end

    if companyCounters[name] == nil then return end
    companyCounters[name] = not companyCounters[name]

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(xPlayer.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}

    local sortedSubsCompanies = {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    local companyLabel = ""
    local companies = Config.Companies
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = xPlayer.job.name == company.job
        company.hasSub = sortedSubsCompanies[company.job] == true
        if company.job == name then companyLabel = company.name end
    end

    local typeLabel = IsJobOnline(name) and "åbnet" or "lukket"
    for player, companies in pairs(playerCompanyPings) do
        if companies[name] then
            exports["lb-phone"]:SendNotification(player, {
                app = "company_app", 
                title = companyLabel,
                content = ("%s er %s"):format(companyLabel, typeLabel)
            })
        end
    end

    TriggerClientEvent("st_company_app:updateCompanies", _source, companies)
end)

RegisterNetEvent("st_company_app:ToggleCompanySubscribe", function(name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not toggleSubscripeCooldown[_source] then
        toggleSubscripeCooldown[_source] = 0
    end

    if (os.time() - Config.SubCooldown) < toggleSubscripeCooldown[_source] then
        local minutes = math.floor((Config.SubCooldown - (os.time() - toggleSubscripeCooldown[_source])) / 60)
        local seconds = math.fmod((Config.SubCooldown - (os.time() - toggleSubscripeCooldown[_source])), 60)
        
        TriggerClientEvent('ox_lib:notify', _source, { 
            type = 'error', 
            duration = 5000, 
            description = ('Cooldown på: ' .. minutes .. " min. & " .. seconds .. " sekunder."),
        })
        
        return
    end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(xPlayer.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}
    if tableContains(subscribedCompanies, name) then
        for key, company in pairs(subscribedCompanies) do
            if company == name then table.remove(subscribedCompanies, key) end
        end
    else
        table.insert(subscribedCompanies, name)
    end

    toggleSubscripeCooldown[_source] = os.time()
    -- xPlayer.setCharacterData("subscribedCompanies", subscribedCompanies)

    local sortedSubsCompanies = {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    local companies = Config.Companies
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = xPlayer.job.name == company.job
        company.hasSub = sortedSubsCompanies[company.job] == true
    end

    playerCompanyPings[xPlayer.source] = sortedSubsCompanies

    TriggerClientEvent("st_company_app:updateCompanies", _source, companies)
end)

RegisterServerEvent('esx:setJob')
AddEventHandler('esx:setJob', function(source, job, lastJob)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if job.name == lastJob.name then return end

    if not serverJobsPlayers[job.name] then
        serverJobsPlayers[job.name] = {}
    end

    local identifier = xPlayer.identifier
    serverJobsPlayers[job.name][identifier] = true

    if IsJobValid(job.name) then
        if not companyCounters[job.name] then
            companyCounters[job.name] = false
        end

        if not phoneData[job.name] then
            phoneData[job.name] = {}
        end

        phoneData[job.name][xPlayer.source] = xPlayer.phoneNumber
    end

    if not serverJobsPlayers[lastJob.name] then
        serverJobsPlayers[lastJob.name] = {}
    end

    if serverJobsPlayers[lastJob.name][identifier] then
        serverJobsPlayers[lastJob.name][identifier] = nil
    end

    if IsJobValid(lastJob.name) then
        if not phoneData[lastJob.name] then
            phoneData[lastJob.name] = {}
        end

        phoneData[lastJob.name][xPlayer.source] = nil

        if tablelength(phoneData[lastJob.name]) == 0 then
            companyCounters[lastJob.name] = false
        end
    end
end)

RegisterNetEvent("esx:playerLoaded", function(playerId)
    local playerId = playerId
    local xPlayer = ESX.GetPlayerFromId(playerId)

    local jobName = xPlayer.job.name
    if not serverJobsPlayers[jobName] then
        serverJobsPlayers[jobName] = {}
    end

    local identifier = xPlayer.identifier
    serverJobsPlayers[jobName][identifier] = true

    if IsJobValid(jobName) then
        if not companyCounters[jobName] then
            companyCounters[jobName] = false
        end

        if not phoneData[jobName] then
            phoneData[jobName] = {}
        end

        phoneData[jobName][xPlayer.source] = xPlayer.phoneNumber
    end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(xPlayer.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    playerCompanyPings[xPlayer.source] = sortedSubsCompanies
end)

RegisterNetEvent("esx:playerDropped", function(playerId)
    local playerId = playerId
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local identifier = xPlayer.identifier

    local jobName = xPlayer.job.name
    if not serverJobsPlayers[jobName] then
        serverJobsPlayers[jobName] = {}
    end

    if serverJobsPlayers[jobName][identifier] then
        serverJobsPlayers[jobName][identifier] = nil
    end

    if IsJobValid(jobName) then
        if not companyCounters[jobName] then
            companyCounters[jobName] = false
        end

        if not phoneData[jobName] then
            phoneData[jobName] = {}
        end

        phoneData[jobName][xPlayer.source] = nil

        if phoneData[jobName] and tablelength(phoneData[jobName]) == 0 then
            companyCounters[jobName] = false
        end
    end

    playerCompanyPings[xPlayer.source] = nil
end)

IsJobValid = function(name)
    local activeJobs = {}
    for _, company in pairs(Config.Companies) do
        activeJobs[company.job] = true
    end

    return activeJobs[name]
end

IsJobOnline = function(name)
    if not IsJobValid(name) then
        return false
    end

    return companyCounters[name] == true
end
exports("IsJobOnline", IsJobOnline)

GetPlayersOnlineOnJob = function(name)
    return tablelength(serverJobsPlayers[name] or {})
end
exports("GetPlayersOnlineOnJob", GetPlayersOnlineOnJob)

GetServerPlayersOnlineOnJob = function(name)
    return serverJobsPlayers[name] or {}
end
exports("GetServerPlayersOnlineOnJob", GetServerPlayersOnlineOnJob)

lib.callback.register('st_company_app:GetCompanies', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(xPlayer.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}

    local sortedSubsCompanies = {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    local companies = Config.Companies
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = xPlayer.job.name == company.job
        company.hasSub = sortedSubsCompanies[company.job] == true
    end

    return companies
end)

lib.callback.register('st_company_app:GetPosts', function(source)
    return companyPosts
end)

GetUserData = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local userData = { 
        name = xPlayer.job.label, 
        grade = xPlayer.job.grade_label, 
        jobs = {},
        admin = false,
    }

    -- local playerWhitelistedJobs = exports.drp_jobs:GetJobCenterData(source)
    -- if not playerWhitelistedJobs then return userData end

    -- for _, job in pairs(playerWhitelistedJobs) do
    --     table.insert(userData.jobs, {
    --         name = job.title,
    --         jobName = job.name,
    --         grade = job.grade,
    --         hasJob = xPlayer.job.name == job.name
    --     })

    --     if xPlayer.job.name == job.name then
    --         if IsJobValid(xPlayer.job.name) and xPlayer.job.grade_name == "boss" then
    --             userData.admin = true
    --         end
    --     end
    -- end

    return userData
end

lib.callback.register('st_company_app:GetUserData', function(source)
    return GetUserData(source)
end)

lib.callback.register('st_company_app:HasUserJobCooldown', function(source)
    if not changeJobCooldown[source] then
        changeJobCooldown[source] = 0
    end

    if (os.time() - Config.ChangeJobCooldown) > changeJobCooldown[source] then
        changeJobCooldown[source] = os.time()
        return false
    end

    return true
end)

AddEventHandler('playerDropped', function()
	local _source = source
    changeJobCooldown[_source] = nil
end)

tablelength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

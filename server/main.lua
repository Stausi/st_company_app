local changeJobCooldown = {}
local companyCounters = {}
local serverJobsPlayers = {}
local phoneData = {}

local toggleStatusCooldown = {}
local playerCompanyPings = {}
local companyPosts = {}

local subscribingSafeCache = {}
local companySubscriped = {}

Citizen.CreateThread(function()
    local phone_company_subscriptions_added = st.database.addTable('phone_company_subscriptions',
    [[
      id INT NOT NULL AUTO_INCREMENT,
      phone_number BIGINT(15) NOT NULL,
      companies LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]',
      PRIMARY KEY (id),
      UNIQUE KEY (phone_number)
    ]])

    if not phone_company_subscriptions_added then
        st.print.info('The database is up-to-date.')
    end

    local result = MySQL.query.await("SELECT * FROM phone_company_subscriptions")
    if result then
        for _, data in pairs(result) do
            if companySubscriped[data.phone_number] then
                companySubscriped[data.phone_number] = {}

                local companies = json.decode(data.companies)
                for _, company in pairs(companies) do
                    companySubscriped[data.phone_number][company] = true
                end
            end
        end
    end

    local players = st.framework:getPlayers()
    for i=1, #players, 1 do
        local user = st.framework:getUser(players[i])
        local playerJob = user:getJobName()

        if not serverJobsPlayers[playerJob] then
            serverJobsPlayers[playerJob] = {}
        end

        local identifier = user.identifier
        serverJobsPlayers[playerJob][identifier] = true

        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(user.source)
        if IsJobValid(playerJob) then
            if not companyCounters[playerJob] then
                companyCounters[playerJob] = false
            end

            if not phoneData[playerJob] then
                phoneData[playerJob] = {}
            end

            phoneData[playerJob][user.source] = phoneNumber
        end

        local sortedSubsCompanies = {}
        local subscribedCompanies = companySubscriped[phoneNumber] or {}
        for _, company in pairs(subscribedCompanies) do
            sortedSubsCompanies[company] = true
        end
    
        playerCompanyPings[user.source] = sortedSubsCompanies
    end

    while true do
        Citizen.Wait(5 * 60 * 1000)
        saveSubscripbedUsers()
    end
end)

saveSubscripbedUsers = function()
    local updateSqls = {}
    for phoneNumber, data in pairs(subscribingSafeCache) do
        local companies = json.encode(data.companies)
        if data.insertData then
            updateSqls[#updateSqls + 1] = {
                query = "INSERT INTO phone_company_subscriptions (phone_number, companies) VALUES (@phone_number, @companies)",
                values = { 
                    phone_number = phoneNumber, 
                    companies = companies 
                }
            }
        else
            updateSqls[#updateSqls + 1] = {
                query = "UPDATE phone_company_subscriptions SET companies = @companies WHERE phone_number = @phone_number",
                values = { 
                    phone_number = phoneNumber, 
                    companies = companies 
                }
            }
        end
    end

    MySQL.transaction(updateSqls)
    subscribingSafeCache = {}
end

RegisterNetEvent("st_company_app:SendCompanyMessage", function(message, name)
    local _source = source

    local user = st.framework:getUser(_source)
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

    local phoneNumber = user:getPhoneNumber()
    local companyOnline = IsJobOnline(name)
    if not companyOnline and selectedCompany.showStatus then
        return exports["lb-phone"]:SendNotification(phoneNumber, {
            app = "company_app", 
            title = "Fejl", 
            content = "Der er ingen på arbejde.", 
        })
    end

    exports["lb-phone"]:SendNotification(phoneNumber, {
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

    -- Send your message to a UI for a list of calls.
end)

RegisterNetEvent("st_company_app:SendCompanyPost", function(image, title, message)
    local _source = source

    local user = st.framework:getUser(_source)
    local jobName = user:getJobName()
    if not IsJobValid(jobName) then
        return
    end

    local gradeName = user:getGradeName()
    if gradeName ~= "boss" then
        return
    end

    local companyName, companyIcon = "", ""
    for _, company in pairs(Config.Companies) do
        if company.job == jobName then 
            companyName = company.name 
            companyIcon = company.image 
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

    local user = st.framework:getUser(_source)
    local jobName = user:getJobName()
    for key, post in pairs(companyPosts) do
        if post.name == jobName then table.remove(companyPosts, key) end
    end

    TriggerClientEvent("st_company_app:updatePosts", -1, companyPosts)
end)

RegisterNetEvent("st_company_app:ToggleCompanyStatus", function(name)
    local _source = source

    local user = st.framework:getUser(_source)
    if not toggleStatusCooldown[_source] then
        toggleStatusCooldown[_source] = 0
    end

    if (os.time() - Config.StatusCooldown) < toggleStatusCooldown[_source] then
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

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(user.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}

    local sortedSubsCompanies = {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    local companyLabel = ""
    local companies = Config.Companies
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = user:getJobName() == company.job
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

    local user = st.framework:getUser(_source)
    if not user then return end

    local insertData = false
    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(user.source)
    if not companySubscriped[phoneNumber] then
        companySubscriped[phoneNumber] = {}
        insertData = true
    end

    local subscribedCompanies = companySubscriped[phoneNumber]
    if subscribedCompanies[name] then
        subscribedCompanies[name] = nil
    else
        subscribedCompanies[name] = true
    end

    local companies = table.clone(Config.Companies)
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = user:getJobName() == company.job
        company.hasSub = subscribedCompanies[company.job] == true
    end

    subscribingSafeCache[phoneNumber] = {
        insertData = insertData,
        companies = subscribedCompanies
    }

    playerCompanyPings[user.source] = subscribedCompanies

    TriggerClientEvent("st_company_app:updateCompanies", _source, companies)
end)

st.hook.registerAction('setJob', function(source, newJob, lastJob)
    local _source = source

    local user = st.framework:getUser(_source)
    if not user then return end

    if newJob.name == lastJob.name then 
        return 
    end

    if not serverJobsPlayers[newJob.name] then
        serverJobsPlayers[newJob.name] = {}
    end

    local identifier = user.identifier
    serverJobsPlayers[newJob.name][identifier] = true

    if IsJobValid(newJob.name) then
        if not companyCounters[newJob.name] then
            companyCounters[newJob.name] = false
        end

        if not phoneData[newJob.name] then
            phoneData[newJob.name] = {}
        end

        phoneData[newJob.name][user.source] = user.phoneNumber
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

        phoneData[lastJob.name][user.source] = nil

        if tablelength(phoneData[lastJob.name]) == 0 then
            companyCounters[lastJob.name] = false
        end
    end
end, 10)

st.hook.registerAction('playerLoaded', function(source)
    local user = st.framework:getUser(playerId)
    local jobName = user:getJobName()

    if not serverJobsPlayers[jobName] then
        serverJobsPlayers[jobName] = {}
    end

    local identifier = user.identifier
    serverJobsPlayers[jobName][identifier] = true

    if IsJobValid(jobName) then
        if not companyCounters[jobName] then
            companyCounters[jobName] = false
        end

        if not phoneData[jobName] then
            phoneData[jobName] = {}
        end

        phoneData[jobName][user.source] = user.phoneNumber
    end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(user.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}
    for _, company in pairs(subscribedCompanies) do
        sortedSubsCompanies[company] = true
    end

    playerCompanyPings[user.source] = sortedSubsCompanies
end, 10)

st.hook.registerAction('playerDropped', function(source)
    local user = st.framework:getUser(_source)
    if not user then return end

    local identifier = user.identifier
    local jobName = user:getJobName()

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

        phoneData[jobName][user.source] = nil

        if phoneData[jobName] and tablelength(phoneData[jobName]) == 0 then
            companyCounters[jobName] = false
        end
    end

    playerCompanyPings[user.source] = nil
end, 10)

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

st.callback.register('st_company_app:GetCompanies', function(source)
    local user = st.framework:getUser(source)
    if not user then return {} end

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(user.source)
    local subscribedCompanies = companySubscriped[phoneNumber] or {}

    local companies = table.clone(Config.Companies)
    for _, company in pairs(companies) do
        company.status = IsJobOnline(company.job)
        company.isWorker = user:getJobName() == company.job
        company.hasSub = subscribedCompanies[company.job] == true
    end

    return companies
end)

st.callback.register('st_company_app:GetPosts', function(source)
    return companyPosts
end)

GetUserData = function(source)
    local user = st.framework:getUser(source)
    if not user then return {} end

    local targetJob = user:getJob()
    local userData = { 
        name = targetJob.label, 
        grade = targetJob.grade_label, 
        jobs = {},
        admin = false,
    }

    -- Get your jobs here.
    -- Job Data format:
    -- table.insert(userData.jobs, {
    --     name = job.title,
    --     jobName = job.name,
    --     grade = job.grade,
    --     hasJob = false/true,
    -- })

    return userData
end

st.callback.register('st_company_app:GetUserData', function(source)
    return GetUserData(source)
end)

st.callback.register('st_company_app:HasUserJobCooldown', function(source)
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

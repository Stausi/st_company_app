local appInfo = {
    identifier = "company_app",
    name = "Firmaer",
    description = "Kontakt Et Firma"
}

local hasSetup = false

Citizen.CreateThread(function()
    while GetResourceState("lb-phone") ~= "started" do
        Wait(500)
    end

    local url = GetResourceMetadata(GetCurrentResourceName(), "ui_page", 0)
    local added, errorMessage = exports["lb-phone"]:AddCustomApp({
        identifier = appInfo.identifier,
        name = appInfo.name,
        
        description = appInfo.description,
        defaultApp = true,
        fixBlur = true,

        ui = url:find("http") and url or GetCurrentResourceName() .. "/" .. url,
        icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/web/build/icon.png",
        onUse = function()
            exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, { action = "appOpened" })
        end,
    })

    if not added then
        print("Could not add app:", errorMessage)
    end
end)

RegisterNUICallback("setupApp", function(data, cb)
    cb(st.callback.await('st_company_app:GetCompanies', false))
end)

RegisterNUICallback("setupOverview", function(data, cb)
    cb(st.callback.await('st_company_app:GetUserData', false))
end)

RegisterNUICallback("setupPosts", function(data, cb)
    local posts = st.callback.await('st_company_app:GetPosts', false)
    local jobName = st.framework:GetJobName()
    local gradeName = st.framework:GetGradeName()

    for _, post in pairs(posts) do
        local isAdmin = false
        if jobName == post.name then
            if gradeName == "boss" then 
                isAdmin = true 
            end
        end

        post.isAdmin = isAdmin
    end

    cb(posts)
end)

RegisterNUICallback("takePlayerJob", function(data, cb)
    local HasUserJobCooldown = st.callback.await('st_company_app:HasUserJobCooldown', false)
    if HasUserJobCooldown then
        local timeToGo = Config.ChangeJobCooldown / 60
        st.notify({ title = 'Fejl', description = ("Der skal gå %s min. imellem jobskifte."):format(math.floor(timeToGo+0.5)), type = 'error' })
        return cb('ok')
    end

    local newData = st.callback.await('st_company_app:GetUserData', false)
    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshUser",
        data = {
            name = newData.name,
            grade = newData.grade,
            jobs = newData.jobs,
            admin = newData.admin,
        }
    })

    local newJobData = st.callback.await('st_company_app:GetCompanies', false)
    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshCompanies",
        data = newJobData
    })

    local jobName = st.framework:GetJobName()
    local gradeName = st.framework:GetGradeName()

    local posts = st.callback.await('st_company_app:GetPosts', false)
    for _, post in pairs(posts) do
        local isAdmin = false
        if jobName == post.name then
            if gradeNamee == "boss" then 
                isAdmin = true 
            end
        end

        post.isAdmin = isAdmin
    end

    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshPosts",
        data = posts
    })

    cb('ok')
end)

RegisterNUICallback("quitPlayerJob", function(data, cb)
    local newData = st.callback.await('st_company_app:GetUserData', false)
    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshUser",
        data = {
            name = newData.name,
            grade = newData.grade,
            jobs = newData.jobs,
            admin = newData.admin,
        }
    })

    cb('ok')
end)

RegisterNUICallback("sendMessage", function(data, cb)
    TriggerServerEvent("st_company_app:SendCompanyMessage", data.message, data.job)

    cb('ok')
end)

RegisterNUICallback("sendPost", function(data, cb)
    TriggerServerEvent("st_company_app:SendCompanyPost", data.image, data.title, data.message)

    cb('ok')
end)

RegisterNUICallback("toggleStatus", function(data, cb)
    TriggerServerEvent("st_company_app:ToggleCompanyStatus", data.job)

    cb('ok')
end)

RegisterNUICallback("subscribeToggle", function(data, cb)
    TriggerServerEvent("st_company_app:ToggleCompanySubscribe", data.job)

    cb('ok')
end)

RegisterNUICallback("focusText", function(data, cb)
    cb('ok')
end)

RegisterNUICallback("deletePost", function(data, cb)
    TriggerServerEvent("st_company_app:DeleteCompanyPost")

    cb('ok')
end)

RegisterNetEvent("st_company_app:updateCompanies", function(companies)
    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshCompanies",
        data = companies
    })
end)

RegisterNetEvent("st_company_app:updatePosts", function(posts)
    local jobName = st.framework:GetJobName()
    local gradeName = st.framework:GetGradeName()

    for _, post in pairs(posts) do
        local isAdmin = false
        if jobName == post.name then
            if gradeName == "boss" then 
                isAdmin = true 
            end
        end

        post.isAdmin = isAdmin
    end

    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshPosts",
        data = posts
    })
end)

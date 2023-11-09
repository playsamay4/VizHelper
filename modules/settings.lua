local settings = {}

local json = require "lib.json"

local licenseText = love.filesystem.read("LICENSE")

local function SaveSettings(new)
    if new == true then
        settings.data = {
            Connections = {
                {
                    IP = "localhost",
                }
            }
        }
    end

    local file = love.filesystem.newFile("settings.json")
    file:open("w")
    file:write(json:encode_pretty(settings.data))
    file:close()
end

settings.shouldShow = ffi.new("bool[1]", false)

settings.show = function()
    settings.shouldShow[0] = true
end

local settingsList = {
    "Connections",
    "About",
    "Licenses",
}

local selectedSetting = "Connections"

local windowItems = {
    conIpInput = ffi.new("char[1024]", ""),
}

--LOAD IN SETTINGS
function LoadSettings()
    local settingsFile = love.filesystem.newFile("settings.json")
    settingsFile:open("r")
    settings.data = settingsFile:read()
    settingsFile:close()

    if settings.data == nil then
        SaveSettings(true)
    else
        settings.data = json:decode(settings.data)
    end

    windowItems.conIpInput = ffi.new("char[1024]", settings.data.Connections[1].IP)

end

LoadSettings()

local function connectionsWindow()
    imgui.Text("IP Address: ") imgui.SameLine()
    if imgui.InputText("###conIpInput", windowItems.conIpInput, 1024,  imgui.love.InputTextFlags("EnterReturnsTrue")) == true then
         --disconnect from current connection
         GFX:send("disconnect")
         GFX:disconnect()
         settings.data.Connections[1].IP = ffi.string(windowItems.conIpInput)
         SaveSettings()
    end

    imgui.SameLine()
    if imgui.Button("Force disconnect") then
         GFX:disconnect()
         connectedToViz = false
     end

     imgui.SameLine()
end

settings.draw = function()
    imgui.Begin("Settings", settings.shouldShow, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
        imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,350))
        
        
        imgui.BeginChild_Str("SettingsList", imgui.ImVec2_Float(200, 300), true)
            for i, v in ipairs(settingsList) do
                if imgui.Selectable_Bool(v) then
                    selectedSetting = v
                end
            end
        imgui.EndChild()
        
        imgui.SameLine()
        imgui.BeginChild_Str("SettingsWindow", imgui.ImVec2_Float(580, 300), true)
            
            imgui.SameLine()
                imgui.PushFont(TimingsFont)
                imgui.Text(selectedSetting)
            imgui.PopFont()

            if selectedSetting == "Connections" then
                connectionsWindow()
            elseif selectedSetting == "About" then
                imgui.Text("VizHelper BETA")
                imgui.Text("Version: "..Version)
                imgui.Text("Made by playsamay4")
                imgui.Text([[
                    VizHelper makes use of the following libraries / frameworks:
                    - LÖVE
                    - Dear ImGui
                    - sock.lua by camchenry
                    - bitser.lua by Jasmijn Wellner
                    - xml2lua by manoelcampos
                    - inspect.lua by kikito
                    - json.lua by Jeffrey Friedl
                    - hump/timer.lua by Matthias Richter
                    - push by Ulysse Ramage
                    - websocket.lua by flaribbit

                    - LuaJIT
            
                    Segoe UI font by Microsoft Corporation
                    
                    Gear Icon: gear-6263756 by Frank Hamaty - The Noun Project
                    
                    Viz2.0 is licensed under the GNU General Public License v3.0.
        
                ]])
            elseif selectedSetting == "Licenses" then
                imgui.InputTextMultiline("licenseText", ffi.new("char[38500]",licenseText), 38500, imgui.ImVec2_Float(560, 250), imgui.love.InputTextFlags("ReadOnly"))
            end

        imgui.EndChild()

    imgui.End()
end




return settings


local inspect = require "lib.inspect"

--Set Identity
love.filesystem.setIdentity("VizHelper")
--Save a random file to create the directory

--Check if ticker.txt exists
local tickerExists = love.filesystem.read("ticker.txt")
if tickerExists == nil then
    love.filesystem.write("ticker.txt", "!hh\n!h Edit the text in VizHelper\n!ii\n!i Edit the text in VizHelper")
end

local brandingSelectedFile = love.filesystem.read("branding_exdata.bin")
if brandingSelectedFile == nil then
    love.filesystem.write("branding_exdata.bin", "1")
    brandingSelectedFile = "1"
end
love.filesystem.createDirectory("libraries")


-- Set the file paths
local srcFilePath = love.filesystem.getSourceBaseDirectory() .. "/VizHelper/imgui.dll"
local destFilePath = love.filesystem.getSaveDirectory() .. "/libraries/cimgui.dll"

-- Copy the file from source to destination
local srcFile = assert(io.open(srcFilePath, "rb"))
local destFile = assert(io.open(destFilePath, "wb"))
destFile:write(srcFile:read("*all"))
srcFile:close()
destFile:close()


ffi = require "ffi"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
local timer = require "lib.timer"
local dllExists = love.filesystem.read("libraries/cimgui.dll")
local sock = require "lib.sock"

--fDialog = FileDialog.new("open",nil,nil,"D:\\dev\\VBN-NewsWire")



if jit.os == "Windows" then
    if dllExists == nil then
        love.window.showMessageBox("Error", "Couldn't find cImGUI dll file. Contact playsamay4#3646.", "error", true)
        love.event.quit()
    end
end

-- Make sure the shared library can be found through package.cpath before loading the module.
-- For example, if you put it in the LÖVE save directory, you could do something like this:
local lib_path = love.filesystem.getSaveDirectory() .. "/libraries"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)


local showTickerCon = ffi.new("bool[1]", false)
local showLowerThirdCon = ffi.new("bool[1]", false)
local showTileCon = ffi.new("bool[1]", false)
local showHeadlineCon = ffi.new("bool[1]", false)
local showLiveCon = ffi.new("bool[1]", false)
local showPlayoutCon = ffi.new("bool[1]", false)
local showBrandingCon = ffi.new("bool[1]", false)
local showAutomationCon = ffi.new("bool[1]", false)

local stylePicker = ffi.new("int[1]", 0)

local lowerThirdText = ffi.new("char[1024]", "")
local lowerThirdText2 = ffi.new("char[1024]", "")
local lowerThirdText3 = ffi.new("char[1024]", "")
local lowerThirdText4 = ffi.new("char[1024]", "")

local breakingTitle = ffi.new("char[1024]", "")
local breakingText = ffi.new("char[1024]", "")
local breakingText1 = ffi.new("char[1024]", "")
local breakingText2 = ffi.new("char[1024]", "")

local badgeText = ffi.new("char[1024]", "")
local badgeBGColor = ffi.new("float[3]",{0.68,0,0})
local badgeTextColor = ffi.new("float[3]",{1,1,1})

local socialBadgeText = ffi.new("char[1024]", "")
local creditBadgeText = ffi.new("char[1024]", "")

local nameStrapText1 = ffi.new("char[1024]", "")
local nameStrapText2 = ffi.new("char[1024]", "")

local headlineStrap1 = ffi.new("char[1024]", "")
local headlineStrap2 = ffi.new("char[1024]", "")
local headlineStrapComingUp = ffi.new("bool[1]", false)
local headlineStrapnoBBC = ffi.new("bool[1]", false)
local shitViz = ffi.new("bool[1]", false)

local liveBugText = ffi.new("char[1024]", "")
local liveBugLive = ffi.new("bool[1]", true)
local liveBugShowTime = ffi.new("bool[1]", false)
local liveBugTimeOffset = ffi.new("int[1]", 0)

local defaultTickerText = ffi.new("char[1024]", "bbc.co.uk/news")

local tickerText = ffi.new("char[65535]")
local tickerTextRSS = ffi.new("char[65535]", "")
local tickerUsingRSS = ffi.new("bool[1]", false)

local wires = require "wires"

local TitlesList = {
    {name = "News Channel Generic Titles", vid = "NC_Titles.ogv", aud = "TitlesE.wav"},
    {name = "World News Generic Titles", vid = "WN_Titles.ogv", aud = "WN_Titles.wav"},
    {name = "BBC News Studio B Generic Titles", vid = "ONE_TitlesB.ogv", aud = "ONE_Titles10EShort.wav"},
    {name = "BBC News at One [Studio E] (2013)", vid = "ONE_Titles1E.ogv", aud = "TitlesE.wav"},
    {name = "BBC News at Six [Studio E] (2013)", vid = "ONE_Titles6E.ogv", aud = "TitlesE.wav"},
    {name = "BBC News at Ten [Studio E] (2013)", vid = "ONE_Titles10E.ogv", aud = "TitlesE.wav"},
    {name = "BBC News at Ten [Studio E] (2021)", vid = "ONE_Titles10EShort.ogv", aud = "ONE_Titles10EShort.wav"},
    {name = "BBC News at Six [Studio B] (2022)", vid = "ONE_Titles6B.ogv", aud = "ONE_Titles10EShort.wav"},
    {name = "BBC News at Ten [Studio B (2022)", vid = "ONE_Titles10B.ogv", aud = "ONE_Titles10EShort.wav"},
}
local TitlesSelected = 0

local closeList = {
    {name = "World News Closing", vid = "WN_Close.ogv", aud = "WN_Close.wav"},
    {name = "BBC One Bulletin Trundle Close (With Tile)", vid = "NONE", aud = "CloseE.wav"},
}
local closeSelected = 0

local headlineBedList = {
    {name = "Headline Bed (NC 2013 & WN 2016)", aud = "Headlines.wav"},
    {name = "Headline Bed (Nationals 2007)", aud = "Headlines07.mp3"},
    {name = "Headline Bed (NC 2008 & WN 2013)", aud = "Headlines08.wav"},
    {name = "Headline Bed 1999", aud = "Headlines99.wav"},
    {name = "Headline Bed 1999 (3 Bongs)", aud = "Headlines99_3Bongs.wav"},
    {name = "Headline Bed 1999 (4 Bongs)", aud = "Headlines99_4Bongs.wav"},
    {name = "Headline Bed 1999 (Constant Bongs)", aud = "Headlines99_ConstantBongs.wav"},
    {name = "Headline Bed 1999 On Location", aud = "Headlines99OL.wav"},
    {name = "News 24 Headline Bed 1999 (1)", aud = "News24_99_1.wav"},
    {name = "News 24 Headline Bed 1999 (2)", aud = "News24_99_2.wav"},
    {name = "News 24 Headline Bed 2003", aud = "News24_03.wav"},
    {name = "News 24 Headline Bed 2007 (Q Head, cant find the reg one :sob:)", aud = "News24_07v1.wav"},
    {name = "World Headline Bed 2000", aud = "World00.wav"},
    {name = "World Headline Bed 2000 (3 Bongs)", aud = "World00_3Bongs.wav"},
    {name = "World Headline Bed 2000 (4 Bongs)", aud = "World00_4Bongs.wav"},
    {name = "World Headline Bed 2000 (5 Bongs)", aud = "World00_5Bongs.wav"},
    {name = "World Headline Bed 2000 (6 Bongs)", aud = "World00_6Bongs.wav"},
    {name = "World Headline Bed 2003", aud = "World03.wav"},
    {name = "World Headline Bed 2003 (2 Bongs)", aud = "World03_2Bongs.wav"},
    {name = "World Headline Bed 2003 (3 Bongs)", aud = "World03_3Bongs.wav"},
    {name = "World Headline Bed 2003 (4 Bongs)", aud = "World03_4Bongs.wav"},
    {name = "World Headline Bed 2003 (5 Bongs)", aud = "World03_5Bongs.wav"},
    {name = "World Headline Bed 2003 (6 Bongs)", aud = "World03_6Bongs.wav"},
}
local headlineBedSelected = 1

local playoutFreeze = ffi.new("bool[1]", false)

local automationList = {
    {name = "Countdown", actions = {
        {id = "SetAndRun Source (Time Sync)", data = {"CountdownVid", "D:\\Example\\A1Day.mov"}, delay = 0},
        {id = "Fade Scene", data = {"Countdown"}, delay = 500},
        {id = "Viz KILL ALL", data = {}, delay = 0}, 
    }},
    {name = "Titles", actions = {
        {id = "Set Source", data = {"TitlesVid", "D:\\Example\\Titles.mov"}, delay = 0},
        {id = "Run Source", data = {"TitlesVid"}, delay = 0},
        {id = "Fade Scene", data = {"Titles"}, delay = 1000},
        {id = "Viz Show Ticker", data = {}, delay = 10000},
    }}
}






local brandingNameBox = ffi.new("char[1024]", "News Red Straps")
local brandingThemeNameBox = ffi.new("char[1024]", "NEWS")
local brandingThemeColor = ffi.new("float[3]", {0.68,0,0})
local brandingTickerOpaque = ffi.new("bool[1]", true)
local brandingColoredStrap = ffi.new("bool[1]", true)
local clockModeBox = ffi.new("int[1]", 0)

local brandingPresets = {}
local brandingPresetSelected = tonumber(brandingSelectedFile)
if love.filesystem.getInfo("branding.dat") ~= nil then
    ---@diagnostic disable-next-line: cast-local-type
    brandingPresets = bitser.loadLoveFile("branding.dat")
else
    brandingPresets = {
        {name = "News Red Straps",channelName = "NEWS", opaque = true, coloredStrap = true, themeColor = {0.68,0,0}, mode = "Channel", clockMode = "default"},
        {name = "News Channel Original",channelName = "NEWS", opaque = false, coloredStrap = false, themeColor = {0.68,0,0}, mode = "Channel", clockMode = "default"},
        {name = "World News", channelName = "WORLD NEWS", opaque = false, coloredStrap = false, themeColor = {0.68,0,0}, mode = "World", clockMode = "off"},
        {name = "Breakfast", channelName = "BREAKFAST", opaque = false, coloredStrap = false, themeColor = {0.95,0.3,0}, mode = "Breakfast", clockMode = "breakfast"},
        {name = "Region Example (NWT)", channelName = "NORTH WEST TONIGHT", opaque = false, coloredStrap = false, themeColor = {0.68, 0, 0}, mode = "Region", clockMode = "default"},
    }
    bitser.dumpLoveFile("branding.dat", brandingPresets)
    local sendData = {
        Type = "SetBranding",
        ChannelName = "NEWS",
        Opaque = true,
        ColoredStrap = true,
        ThemeColor = {0.68,0,0},
        Mode = "Channel",
        ClockMode = "default"
    }
    GFX:send("headline", sendData)
end


--Load ticker text
local tickerFile = love.filesystem.read("ticker.txt")
if tickerFile ~= nil then
    tickerText = ffi.new("char[65535]", tickerFile)
end

local presetBadges = {}

if love.filesystem.getInfo("badges.dat") ~= nil then
    ---@diagnostic disable-next-line: cast-local-type
    presetBadges = bitser.loadLoveFile("badges.dat")
else
    presetBadges = {
        {"NEWS AT NINE", bcolor = {.7,0,0,1}, tcolor = {1,1,1,1}},
        {"NEWS AT FIVE", bcolor = {.7,0,0,1}, tcolor = {1,1,1,1}},
        {"ACROSS THE UK", bcolor = {.7,0,0,1}, tcolor = {1,1,1,1}},
        {"BUSINESS BREIFING", bcolor = {.7,0,0,1}, tcolor = {1,1,1,1}},
        {"REVIEW 2022", bcolor = {.7,0,0,1}, tcolor = {1,1,1,1}},
        {"OUTSIDE SOURCE", bcolor = {.9,0,0,1}, tcolor = {1,1,1,1}},
        {"THE BRIEFING", bcolor = {.9,0,0,1}, tcolor = {1,1,1,1}},
        {"WORLD NEWS TODAY", bcolor = {.9,0,0,1}, tcolor = {1,1,1,1}},
        {"OUTSIDE SOURCE", bcolor = {.9,0,0,1}, tcolor = {1,1,1,1}},
        {"THE CONTEXT", bcolor = {.9,0,0,1}, tcolor = {1,1,1,1}},
        {"OUTSIDE SOURCE", bcolor = {0,0.5,.8,1}, tcolor = {1,1,1,1}},
        {"NEWSROOM LIVE", bcolor = {1,1,1,1}, tcolor = {.7,0,0,0}},
        {"AFTERNOON LIVE", bcolor = {1,0.3,0,1}, tcolor = {1,1,1,1}},
        {"NEWSDAY", bcolor = {1,0.4,0,1}, tcolor = {1,1,1,1}},
        {"IMPACT", bcolor = {0.9,0.2,0,1}, tcolor = {1,1,1,1}},
        {"WORKLIFE", bcolor = {0.9,0.5,0.2,1}, tcolor = {1,1,1,1}},
        {"BEYOND 100 DAYS", bcolor = {0,0.4,0.5,1}, tcolor = {1,1,1,1}},
        {"THE CONTEXT", bcolor = {0,0.4,0.5,1}, tcolor = {1,1,1,1}},
        {"THE PAPERS", bcolor = {0,0.4,0.5,1}, tcolor = {1,1,1,1}},
        {"BUSINESS LIVE", bcolor = {0,0.3,0.6,1}, tcolor = {1,1,1,1}},
        {"GLOBAL", bcolor = {0.1,0.6,0.6,1}, tcolor = {1,1,1,1}},
        {"NICKY CAMPBELL", bcolor = {0,0.7,0.7,1}, tcolor = {0,0,0,1}},
        {"FOCUS ON AFRICA", bcolor = {0.3,0.5,0,1}, tcolor = {1,1,1,1}},
        {"G M T", bcolor = {0.6,0,0.5,1}, tcolor = {1,1,1,1}},
        {"SPORTSDAY", bcolor = {0.9,0.7,0,1}, tcolor = {0,0,0,1}},
        {"YOUR QUESTIONS ANSWERED", bcolor = {0.4,0.4,0.4,1}, tcolor = {1,1,1,1}},        
    }
    bitser.dumpLoveFile("badges.dat", presetBadges)
end
local presetBadgeSelected = 0

GFX = sock.newClient("localhost", 10655)
GFX:connect()

local connectedToViz = false

local showError = false
local errorTitle = ""
local errorMessage = ""


GFX:on("connect", function(data)
    GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(tickerText), DefaultText = ffi.string(defaultTickerText)})
    connectedToViz = true

    --This breaks figure out why \/\/\/

    -- local sendData = {Type = "Set-Branding"}
    -- sendData.channelName = brandingPresets[brandingPresetSelected].channelName
    -- sendData.opaque = brandingPresets[brandingPresetSelected].opaque
    -- sendData.coloredStrap = brandingPresets[brandingPresetSelected].coloredStrap
    -- sendData.ThemeColor = brandingPresets[brandingPresetSelected].themeColor
    -- sendData.mode = brandingPresets[brandingPresetSelected].mode
    -- sendData.clockMode = brandingPresets[brandingPresetSelected].clockMode
    -- GFX:send("headline", sendData)  

end)

GFX:on("disconnect", function(data)
    connectedToViz = false
end)

function love.load()
    imgui.love.Init() -- or imgui.love.Init("RGBA32") or imgui.love.Init("Alpha8")

    --Set imgui font
    
    local imio = imgui.GetIO()
    
    imio.ConfigWindowsMoveFromTitleBarOnly = true
    imio.ConfigDockingWithShift = true

    local config = imgui.ImFontConfig()
    config.FontDataOwnedByAtlas = false -- it's important to set this, or imgui.love.Shutdown() will crash trying to free already freed memory

    local font_size = 18
    local content, size = love.filesystem.read("fonts/segoeui/segoeui.ttf")
    local contentBold, sizeBold = love.filesystem.read("fonts/segoeui/segoeuib.ttf")
    local newfont = imio.Fonts:AddFontFromMemoryTTF(ffi.cast("void*", content), size, font_size, config)
    ScriptEditorFont = imio.Fonts:AddFontFromMemoryTTF(ffi.cast("void*", content), size, 22, config)
    NCSEditorFont = imio.Fonts:AddFontFromMemoryTTF(ffi.cast("void*", content), size, 25, config)
    TitleFont = imio.Fonts:AddFontFromMemoryTTF(ffi.cast("void*", contentBold), sizeBold, 18, config)
    TimingsFont = imio.Fonts:AddFontFromMemoryTTF(ffi.cast("void*", contentBold), sizeBold, 45, config)
    imio.FontDefault = newfont

    imgui.love.BuildFontAtlas() -- or imgui.love.BuildFontAtlas("RGBA32") or imgui.love.BuildFontAtlas("Alpha8")

    local style = imgui.GetStyle()
    local hspacing = 8
    local vspacing = 6
    imio.ConfigFlags = imgui.ImGuiConfigFlags_DockingEnable

    style.DisplaySafeAreaPadding = {0, 0}
    style.WindowPadding = {hspacing/2, vspacing}
    style.FramePadding = {hspacing, vspacing}
    style.ItemSpacing = {hspacing, vspacing}
    style.ItemInnerSpacing = {hspacing, vspacing}
    style.IndentSpacing = 20.0

    style.WindowRounding = 0
    style.FrameRounding = 0

    style.WindowBorderSize = 1
    style.FrameBorderSize = 1
    style.PopupBorderSize = 1

    style.ScrollbarSize = 20
    style.ScrollbarRounding = 0
    style.GrabMinSize = 5
    style.GrabRounding = 0

    --Light mode :barf:
    -- local white = {1, 1, 1, 1}
    -- local transparent = {0, 0, 0, 0}
    -- local dark = {0, 0, 0, 0.2}
    -- local darker = {0, 0, 0, 0.5}

    -- local background = {0.95, 0.95, 0.95, 1}
    -- local text = {0.1, 0.1, 0.1, 1}
    -- local border = {0.6, 0.6, 0.6, 1}
    -- local grab = {0.69, 0.69, 0.69, 1}
    -- local header = {0.86, 0.86, 0.86, 1}
    -- local active = {0, 0.47, 0.84, 1}
    -- local hover = {0, 0.47, 0.84, 0.2}
    -- local tab = {161/255, 196/255, 216/255,1}

    local white = {0, 0, 0, 1}
    local transparent = {1, 1, 1, 0}
    local dark = {1, 1, 1, 0.8}
    local darker = {1, 1, 1, 0.5}

    local background = {0.05, 0.05, 0.05, 1}
    local text = {0.9, 0.9, 0.9, 1}
    local border = {0.4, 0.4, 0.4, 1}
    local grab = {0.31, 0.31, 0.31, 1}
    local header = {0.14, 0.14, 0.14, 1}
    local active = {0, 0.47, 0.84, 1}
    local hover = {0, 0.47, 0.84, 0.2}
    local tab = {12/255, 20/255, 84/255,1}


    style.Colors[imgui.ImGuiCol_Text] = text
    style.Colors[imgui.ImGuiCol_WindowBg] = background
    style.Colors[imgui.ImGuiCol_ChildBg] = background
    style.Colors[imgui.ImGuiCol_PopupBg] = white
    style.Colors[imgui.ImGuiCol_TitleBg] = header
    style.Colors[imgui.ImGuiCol_TitleBgActive] = white
    style.Colors[imgui.ImGuiCol_TitleBgCollapsed] = header
    style.Colors[imgui.ImGuiCol_TableHeaderBg] = header
    style.Colors[imgui.ImGuiCol_Tab] = white
    style.Colors[imgui.ImGuiCol_TabHovered] = hover
    style.Colors[imgui.ImGuiCol_TabActive] = tab

    style.Colors[imgui.ImGuiCol_Border] = border
    style.Colors[imgui.ImGuiCol_BorderShadow] = transparent

    style.Colors[imgui.ImGuiCol_Button] = header
    style.Colors[imgui.ImGuiCol_ButtonHovered] = hover
    style.Colors[imgui.ImGuiCol_ButtonActive] = active


    style.Colors[imgui.ImGuiCol_FrameBg] = white
    style.Colors[imgui.ImGuiCol_FrameBgHovered] = hover
    style.Colors[imgui.ImGuiCol_FrameBgActive] = active

    style.Colors[imgui.ImGuiCol_MenuBarBg] = header
    style.Colors[imgui.ImGuiCol_Header] = header
    style.Colors[imgui.ImGuiCol_HeaderHovered] = hover
    style.Colors[imgui.ImGuiCol_HeaderActive] = active

    style.Colors[imgui.ImGuiCol_CheckMark] = text
    style.Colors[imgui.ImGuiCol_SliderGrab] = grab
    style.Colors[imgui.ImGuiCol_SliderGrabActive] = darker



    style.Colors[imgui.ImGuiCol_ScrollbarBg] = header
    style.Colors[imgui.ImGuiCol_ScrollbarGrab] = grab
    style.Colors[imgui.ImGuiCol_ScrollbarGrabHovered] = hover
    style.Colors[imgui.ImGuiCol_ScrollbarGrabActive] = active


    love.window.setTitle("VizHelper")
end

function love.update(dt)
    imgui.love.Update(dt)
    imgui.NewFrame()
    timer.update(dt)
    GFX:update()
    wires.Update(dt)

end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 0, 1)
    -- imgui.ShowDemoWindow()

    imgui.Begin("VizHelper Hub", nil, imgui.love.WindowFlags("MenuBar","NoMove", "NoTitleBar", "NoSavedSettings", "NoResize", "NoBringToFrontOnFocus","NoDocking","NoNavFocus"))
        imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(love.graphics.getWidth(), 1))
        imgui.SetWindowPos_Vec2(imgui.ImVec2_Float(0, 0))
        if imgui.BeginMenuBar() then
            if imgui.BeginMenu("VizHelper") then
                if imgui.MenuItem_Bool("Exit") then
                    love.event.quit()
                end
            
                imgui.EndMenu()
            end

        
            imgui.EndMenuBar()
        end
        imgui.SetNextWindowSize(imgui.ImVec2_Float(500,400))
        imgui.Begin("VizHelper Main", nil, imgui.love.WindowFlags("NoSavedSettings","NoResize", "NoTitleBar", "NoBorders", "NoMove", "NoBackground","NoBringToFrontOnFocus"))
            
            imgui.SetWindowPos_Vec2(imgui.ImVec2_Float(30, 50))

            imgui.Text("Welcome to VizHelper")
            imgui.Separator()
            if imgui.Button("Aston\nControl", imgui.ImVec2_Float(100, 100)) then
                showLowerThirdCon[0] = true
            end
            imgui.SameLine() 
            if imgui.Button("Ticker Control", imgui.ImVec2_Float(100, 100)) then
                showTickerCon[0] = true
            end
            imgui.SameLine()

  
            if imgui.Button("Playout\nControl", imgui.ImVec2_Float(100, 100)) then
                showPlayoutCon[0] = true
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip("in development - coming soon")
            end

            imgui.SameLine()
            if imgui.Button("Branding\nControl", imgui.ImVec2_Float(100,100)) then
                showBrandingCon[0] = true
            end


            if imgui.Button("Headline\nControl", imgui.ImVec2_Float(100, 100)) then
                showHeadlineCon[0] = true
            end
            imgui.SameLine()
            if imgui.Button("Tile Control", imgui.ImVec2_Float(100, 100)) then
                imgui.SetNextWindowPos(imgui.ImVec2_Float(500,120))
                showTileCon[0] = true
            end
            imgui.SameLine()
            if imgui.Button("Live Bug\nControl", imgui.ImVec2_Float(100, 100)) then
                imgui.SetNextWindowPos(imgui.ImVec2_Float(500,120))
                showLiveCon[0] = true            
            end
            imgui.SameLine()
            if imgui.Button("Automation\n    (Alpha)", imgui.ImVec2_Float(100, 100)) then
                imgui.SetNextWindowPos(imgui.ImVec2_Float(100,120))
                showAutomationCon[0] = true            
            end

            
            local text = "Connect to Viz2.0"
            if connectedToViz == true then
                text = "Connected to Viz2.0"
            end
            if connectedToViz then 
                imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, imgui.ImVec4_Float(0, 0.5, 0, 1))
            else
                imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, imgui.ImVec4_Float(0.5, 0, 0, 1))
            end
            if imgui.Button(text) then
                if connectedToViz == false then
                    GFX:connect()
                else
                    GFX:disconnect()
                end
            end
            imgui.PopStyleColor()

            imgui.SameLine()
            
            if connectedToViz == false then imgui.BeginDisabled() end


            if imgui.Button("Force disconnect") then
                GFX:disconnect()
                connectedToViz = false
            end
            
            if imgui.IsItemHovered() then
                imgui.SetTooltip("Use only if VizHelper still thinks it's connected to Viz2.0 even when it's not")
            end
            if connectedToViz == false then imgui.EndDisabled() end

            imgui.Separator()
            -- imgui.SameLine()
            
            -- if imgui.Combo_Str("###lowerThirdCombo", stylePicker, "News Channel Style\0World Style\0Breakfast Style\0Custom Style (not implemented yet)\0") then
            
            --     if stylePicker[0] == 0 then
            --         GFX:send("headline", {Type = "SetStyle", Style = "Channel"})
            --     elseif stylePicker[0] == 1 then
            --         GFX:send("headline", {Type = "SetStyle", Style = "World"})
            --     elseif stylePicker[0] == 2 then
            --         GFX:send("headline", {Type = "SetStyle", Style = "Breakfast"})
            --     end

            --     imgui.EndCombo()
            -- end
            -- if imgui.IsItemHovered() then
            --     imgui.SetTooltip("Select the style of graphics you want to use")
            -- end

            
            imgui.Text("BETA - A MUCH EASIER AND CLEANER VERSION IS IN DEVELOPMENT")
        imgui.End()

        if showTileCon[0] == true then
            
            imgui.Begin("Tile Control", showTileCon, imgui.love.WindowFlags("NoSavedSettings","NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(200,120))
                imgui.Text("Control the BBC News tile")
                imgui.Separator()
                
                if imgui.Button("Show Tile") then
                    GFX:send("headline", {Type = "Show-TitleLogo"})
                end
                imgui.SameLine()
                if imgui.Button("Hide Tile") then
                    GFX:send("headline", {Type = "Hide-TitleLogo"})
                end
            imgui.End()
        end

        if showAutomationCon[0] == true then
            
            imgui.Begin("Automation (ALPHA 0.00000000000001)", showAutomationCon, imgui.love.WindowFlags("NoSavedSettings","NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
                imgui.PushFont(TimingsFont)
                imgui.Text("Automation (alpha)")
                imgui.PopFont()
                
                imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ChildBg, imgui.ImVec4_Float(0.1,0.1,0.1,1))
                imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_ChildRounding, imgui.ImVec2_Float(5,5))

                imgui.Text("Rundown items:")
                imgui.BeginListBox("###automationList",imgui.ImVec2_Float(8000, 12 * imgui.GetTextLineHeightWithSpacing()))
                    for i,v in ipairs(automationList) do
                        if imgui.CollapsingHeader_TreeNodeFlags(v.name, nil) then
                            imgui.BeginChild_Str("###childBox"..v.name,imgui.ImVec2_Float(imgui.GetWindowWidth()-8, 100))
                                if v.actions == nil then
                                    imgui.Text("There are no actions under this item") 
                                else
                                    for i2,v2 in ipairs(v.actions) do
                                        local assembled = ""
                                        if v2.data ~= {} then
                                            for i3,v3 in ipairs(v2.data) do
                                                assembled = assembled .. " " .. v3
                                            end
                                        end
                                        imgui.Selectable_Bool(v2.id.." / "..assembled.." / Delay: "..v2.delay.."ms###selectable"..v.name)
                                    end
                                end
                            
                            imgui.EndChild()
                        end
                    end
                imgui.EndListBox()

                    
                
             imgui.End()
        end

        if showLowerThirdCon[0] == true then
            imgui.Begin("Aston Control", showLowerThirdCon, imgui.love.WindowFlags("NoSavedSettings","NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
                imgui.Text("Control the Aston")
                imgui.PushFont(TitleFont)
                imgui.Text("MAKE SURE THE ASTON IS ON BEFORE DISPLAYING TEXT")
                imgui.PopFont()
                imgui.Separator()
                
                if imgui.Button("Show Aston") then
                    GFX:send("headline", {Type = "ShowLowerThird"})
                end
                imgui.SameLine()
                if imgui.Button("Hide Aston") then
                    GFX:send("headline", {Type = "HideLowerThird"})
                end

                --Drop down
                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Text Strap")
                imgui.PopFont()
                imgui.Text("Top line text:") imgui.SameLine()
                imgui.InputText("###lowerThirdText", lowerThirdText, 1024)
                imgui.Text("Bottom line text (1/2) Leave blank for a single line strap:") imgui.SameLine()
                imgui.InputText("###lowerThirdText2", lowerThirdText2, 1024)
                imgui.Text("Bottom line (2/2) Leave blank if you don't want it to scroll:") imgui.SameLine()
                imgui.InputText("###lowerThirdText3", lowerThirdText3, 1024)

                imgui.Text("Text to appear next to logo (Ex. IN BRIEF) leave blank for none")
                imgui.SameLine()
                imgui.InputText("###lowerThirdText4", lowerThirdText4, 1024)

                if imgui.Button("Show/Update Strap") then
                    if ffi.string(lowerThirdText) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the top line"
                        return
                    -- elseif ffi.string(lowerThirdText2) == "" then
                    --     showError = true
                    --     errorTitle = "You missed a field!"
                    --     errorMessage = "You need to input text for the bottom line (1/2)"
                    --     return
                    -- elseif ffi.string(lowerThirdText3) == "" then
                    --     showError = true
                    --     errorTitle = "You missed a field!"
                    --     errorMessage = "You need to input text for the bottom line (2/2)"
                    --     return
                    end
                    
                    GFX:send("headline", {Type = "Show-LowerThirdText", Text = ffi.string(lowerThirdText).."\n"..ffi.string(lowerThirdText2).."\n"..ffi.string(lowerThirdText3), BoxText = ffi.string(lowerThirdText4)})
                end

                imgui.SameLine()

                if imgui.Button("Hide Strap") then
                    GFX:send("headline", {Type = "Hide-LowerThirdText"})
                end

                imgui.Separator()
                imgui.Separator()
                imgui.PushFont(TimingsFont)
                imgui.Text("Breaking Strap")
                imgui.PopFont()

                imgui.Text("Title of breaking news story (Appears after BREAKING)") imgui.SameLine()
                imgui.InputText("###lowerThirdText5", breakingTitle, 1024)
                imgui.Text("Text to appear on the top line") imgui.SameLine()
                imgui.InputText("###lowerThirdText6", breakingText, 1024)
                imgui.Text("Text to appear on the bottom line (1/2)") imgui.SameLine()
                imgui.InputText("###lowerThirdText7", breakingText1, 1024)
                imgui.Text("Bottom line (2/2) Type NOP if you dont want it to scroll") imgui.SameLine()
                imgui.InputText("###lowerThirdText8", breakingText2, 1024)

                imgui.Separator()
                imgui.PushFont(TitleFont)
                imgui.Text("---- IMPORTANT ----")
                imgui.Text("Needs to appear in order: Show Breaking -> Scroll Breaking (However many times you want) -> Show/Update Strap")
                imgui.Text("Breaking the flow will mess the strap up and you may have to restart Viz2.0")
                imgui.Text("Updating the strap doesn't need to follow the flow, just press update")
                imgui.PopFont()

                if imgui.Button("Show BREAKING") then
                    if ffi.string(breakingTitle) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's title"
                        return
                    elseif ffi.string(breakingText) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's top line"
                        return
                    elseif ffi.string(breakingText1) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (1/2)"
                        return
                    elseif ffi.string(breakingText2) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (2/2)"
                        return
            
                    end


                    GFX:send("headline", {Type = "Show-BreakingTitle", Text = ffi.string(breakingTitle)})
                end

                imgui.SameLine()

                if imgui.Button("Scroll BREAKING") then
                    if ffi.string(breakingTitle) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's title"
                        return
                    elseif ffi.string(breakingText) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's top line"
                        return
                    elseif ffi.string(breakingText1) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (1/2)"
                        return
                    elseif ffi.string(breakingText2) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (2/2)"
                        return
            
                    end

                    GFX:send("headline", {Type = "Advance-BreakingTitle"})
                end

                imgui.SameLine()

                if imgui.Button("Show/Update Strap###breaking") then
                    if ffi.string(breakingTitle) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's title"
                        return
                    elseif ffi.string(breakingText) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input the breaking strap's top line"
                        return
                    elseif ffi.string(breakingText1) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (1/2)"
                        return
                    elseif ffi.string(breakingText2) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need to input text for the bottom lines (2/2)"
                        return
            
                    end

                    GFX:send("headline", {Type = "Show-BreakingLowerThird", Text = ffi.string(breakingText).."\n"..ffi.string(breakingText1).."\n"..ffi.string(breakingText2)})
                end

                imgui.SameLine()

                if imgui.Button("Hide Strap###breakingHideStrap") then
                    GFX:send("headline", {Type = "Hide-BreakingLowerThird"})
                end

                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Name Strap")
                imgui.PopFont()
                
                
                imgui.Text("Text to appear on the top line") imgui.SameLine()
                imgui.InputText("##nameStrap1", nameStrapText1, 1024)
                imgui.Text("Text to appear on the bottom line, leave empty for top only") imgui.SameLine()
                imgui.InputText("##nameStrap2", nameStrapText2, 1024)

                if imgui.Button("Show Name Strap") then
                    if ffi.string(nameStrapText1) == "" then
                        showError = true
                        errorTitle = "You missed a field!"
                        errorMessage = "You need at least input text for the top line"
                        return
                    end

                    if ffi.string(nameStrapText2) == "" then
                        GFX:send("headline", {Type = "Show-PresenterName", Text = ffi.string(nameStrapText1)})
                    else
                        GFX:send("headline", {Type = "Show-PresenterName", Text = ffi.string(nameStrapText1).."\n"..ffi.string(nameStrapText2)})
                    end
                end

                imgui.SameLine()

                if imgui.Button("Hide Name Strap") then
                    GFX:send("headline", {Type = "Hide-PresenterName"})
                end

                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Programme Badge")
                imgui.PopFont()

                imgui.Text("Badge Text") imgui.SameLine()
                imgui.InputText("###lowerThirdBadgeText",badgeText, 1024)

                imgui.Text("Background Colour") imgui.SameLine()
                if imgui.ColorEdit3("###lowerThirdBadgeBGColor",badgeBGColor, imgui.love.ColorEditFlags("None")) then
                
                end

                imgui.Text("Text Colour") imgui.SameLine()
                if imgui.ColorEdit3("###lowerThirdBadgeTextColor",badgeTextColor, imgui.love.ColorEditFlags("None")) then
                    
                end
                
                if imgui.Button("Set Badge") then
                    GFX:send("headline", {Type = "Set-ProgramBadge", Text = ffi.string(badgeText), TextColor = convertTableToCondensedString({badgeTextColor[0], badgeTextColor[1], badgeTextColor[2]}), BackgroundColor = convertTableToCondensedString({badgeBGColor[0], badgeBGColor[1], badgeBGColor[2]})})
                    
                end

                imgui.SameLine()

                if imgui.Button("Remove Badge") then
                    GFX:send("headline", {Type = "Remove-ProgramBadge"})
                end

                imgui.SameLine()

                if imgui.Button("Show Badge") then
                    print(convertTableToCondensedString({badgeTextColor[0], badgeTextColor[1], badgeTextColor[2]}))
                    GFX:send("headline", {Type = "Show-ProgramBadge", Text = ffi.string(badgeText), TextColor = convertTableToCondensedString({badgeTextColor[0], badgeTextColor[1], badgeTextColor[2]}), BackgroundColor = convertTableToCondensedString({badgeBGColor[0], badgeBGColor[1], badgeBGColor[2]})})
                end

                imgui.SameLine()

                if imgui.Button("Hide Badge") then
                    GFX:send("headline", {Type = "Hide-ProgramBadge"})
                end

                imgui.SameLine()
                imgui.SetCursorPosX(400)

                imgui.BeginListBox("###programBadgeList",imgui.ImVec2_Float(300, 80))
                    ---@diagnostic disable-next-line: param-type-mismatch
                    for i, v in ipairs(presetBadges) do
                        local selected = false
                        if presetBadgeSelected == i then
                            selected = true
                        end

                        -- imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, imgui.ImVec4_Float(v.tcolor[1], v.tcolor[2], v.tcolor[3], 1))
                        -- imgui.PushStyleColor_Vec4(imgui.ImGuiCol_FrameBg, imgui.ImVec4_Float(1,0,0, 1))
                        if imgui.Selectable_Bool(v[1].."###"..i, selected) then
                            presetBadgeSelected = i
                            badgeText = ffi.new("char[1024]", v[1])
                            badgeTextColor[0] = v.tcolor[1]
                            badgeTextColor[1] = v.tcolor[2]
                            badgeTextColor[2] = v.tcolor[3]
                            badgeBGColor[0] = v.bcolor[1]
                            badgeBGColor[1] = v.bcolor[2]
                            badgeBGColor[2] = v.bcolor[3]
                            

                        end
                        imgui.SameLine()
                        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ChildBg, imgui.ImVec4_Float(v.bcolor[1], v.bcolor[2], v.bcolor[3], 1))
                            imgui.BeginChild_Str("###programBadgeColExample"..i, imgui.ImVec2_Float(30,18))
                            imgui.EndChild()
                        imgui.PopStyleColor()
                    end
                imgui.EndListBox()

                imgui.SetCursorPosX(420)

                if imgui.Button("Save badge") then
                    table.insert(presetBadges, {ffi.string(badgeText), tcolor = {badgeTextColor[0], badgeTextColor[1], badgeTextColor[2]}, bcolor = {badgeBGColor[0], badgeBGColor[1], badgeBGColor[2]}})

                end 

                imgui.SameLine()

                if imgui.Button("Remove selected badge") then
                    table.remove(presetBadges, presetBadgeSelected)
                    presetBadgeSelected = 0
                end

                imgui.Separator()   
                imgui.Separator()
                imgui.PushFont(TimingsFont)
                imgui.Text("Misc. badges")
                imgui.PopFont()

                imgui.Text("Socials badge text:")
                imgui.SameLine()
                imgui.InputText("###socialBadgeTextInput", socialBadgeText, 1024)
                imgui.SameLine()
                if imgui.Button("Show###socialBadgeButtonShow") then
                    GFX:send("headline", {Type = "Show-SocialsBadge", Text = ffi.string(socialBadgeText)})
                end
                imgui.SameLine()
                if imgui.Button("Hide###socialBadgeButtonHide") then
                    GFX:send("headline", {Type = "Hide-SocialsBadge"})
                end

                imgui.Text("Credit badge text:")
                imgui.SameLine()
                imgui.InputText("###creditBadgeTextInput", creditBadgeText, 1024)
                imgui.SameLine()
                if imgui.Button("Show###creditBadgeButtonShow") then
                    GFX:send("headline", {Type = "Show-CreditBadge", Text = ffi.string(creditBadgeText)})
                end
                imgui.SameLine()
                if imgui.Button("Hide###creditBadgeButtonHide") then
                    GFX:send("headline", {Type = "Hide-CreditBadge"})
                end

                imgui.Separator()   
                imgui.Separator()
                imgui.PushFont(TimingsFont)
                imgui.Text("Miscellaneous")
                imgui.PopFont()

                if imgui.Button("Hide clock") then
                    GFX:send("headline", {Type = "Hide-Clock"})
                end                   

            imgui.End()
        end

        if showHeadlineCon[0] == true then
            imgui.Begin("Headline Control", showHeadlineCon, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
                
                imgui.Text("Control headline straps")

                --Drop down
                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Headline Strap")
                imgui.PopFont()
                imgui.Text("Text to appear on the top line") imgui.SameLine()
                imgui.InputText("###headlineStrap1", headlineStrap1, 1024)
                imgui.Text("Text to appear on the bottom line, leave empty for single line strap") imgui.SameLine()
                imgui.InputText("###headlineStrap2", headlineStrap2, 1024)

                imgui.Text("Coming Up badge") imgui.SameLine()
                imgui.Checkbox("###headlineStrapComing", headlineStrapComingUp)

                imgui.Text("No BBC NEWS box")
                imgui.SameLine()
                imgui.Checkbox("###headlineStrapBBC", headlineStrapnoBBC)

                imgui.Text("Look North Viz Style")
                imgui.SameLine()
                imgui.Checkbox("###lookNorthViz", shitViz)
                imgui.SameLine()
                imgui.Text("(one line straps only)")


                if imgui.Button("Show Strap") then
                    local style = ""
                    if headlineStrapComingUp[0] == true then
                        style = style.."ComingUp"
                    end
                    if headlineStrapnoBBC[0] == true then
                        style = style.." ComingUpOnly"
                    end

                    if ffi.string(headlineStrap2) == "" then
                        GFX:send("headline", {Type = "Show-Headline", Text = ffi.string(headlineStrap1), Style = style, Regional = shitViz[0]})
                    else
                        GFX:send("headline", {Type = "Show-Headline", Text = ffi.string(headlineStrap1).."|"..ffi.string(headlineStrap2), Style = style, Regional = false})
                    end

                end

                imgui.SameLine()

                if imgui.Button("Hide Strap") then
                    GFX:send("headline", {Type = "Hide-Headline", Regional = shitViz[0]})
                end

                imgui.Separator()
                imgui.Separator()

                
            imgui.End()
        end

        if showLiveCon[0] == true then
            imgui.Begin("Live Control", showLiveCon, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
                
                imgui.Text("Control live straps")

                --Drop down
                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Live Bug")
                imgui.PopFont()
                imgui.Text("Location") imgui.SameLine()
                imgui.InputText("###liveBug1", liveBugText, 1024)

                imgui.Checkbox("Live###LiveCheckbox", liveBugLive)
                imgui.SameLine()
                imgui.Checkbox("Show Time###TimeLiveCheckbox", liveBugShowTime)

                if liveBugShowTime[0] == true then 
                    imgui.InputInt("Offset in hours###liveOffsetInput", liveBugTimeOffset, 1, 2)

                    if liveBugTimeOffset[0] < -12 then liveBugTimeOffset[0] = -12 end
                    if liveBugTimeOffset[0] > 12 then liveBugTimeOffset[0] = 12 end
                end

                if imgui.Button("Show Bug") then
                    local text = ""
                    if liveBugLive[0] == true then
                        text = "LIVE   "
                    end
                    text = text..ffi.string(liveBugText)
                    if liveBugShowTime[0] == false then 
                        GFX:send("headline", {Type = "Show-PlaceName", Text = text})
                    elseif liveBugShowTime[0] == true then
                        GFX:send("headline", {Type = "Show-PlaceNameWithTime", Text = text, Offset = liveBugTimeOffset[0]})
                    end
                end

                imgui.SameLine()

                if imgui.Button("Hide Bug") then
                    GFX:send("headline", {Type = "Hide-PlaceName"})
                end
             imgui.End()
        end

        if showPlayoutCon[0] == true then
            imgui.Begin("Playout Control", showPlayoutCon, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
            imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))

            imgui.PushFont(TimingsFont)
            imgui.Text("Playout")
            imgui.PopFont()                                 
            imgui.Text("Controls audio/visual playout\nYou can only load one Title/Close/Countdown at once")
            imgui.Separator()
            imgui.Separator()
            
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ChildBg, imgui.ImVec4_Float(0.1,0.1,0.1,1))
            imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_ChildRounding, imgui.ImVec2_Float(5,5))
            if imgui.CollapsingHeader_TreeNodeFlags("Headline Bed", nil) then
                imgui.BeginChild_Str("headlinebedChildBox",imgui.ImVec2_Float(imgui.GetWindowWidth()-8, 180))

                imgui.PushFont(TitleFont)
                imgui.Text("Choose headline bed to playout")
                imgui.PopFont()

                    imgui.BeginListBox("###headlineBedList",imgui.ImVec2_Float(0, 5 * imgui.GetTextLineHeightWithSpacing()))
                    for i, v in ipairs(headlineBedList) do
                        local selected = false
                        if headlineBedSelected == i then
                            selected = true
                        end
                        if imgui.Selectable_Bool(v.name, selected) then
                            headlineBedSelected = i
                            GFX:send("headline", {Type = "Set-HeadlineBong", aud = v.aud})
                        end
                    end
                    imgui.EndListBox()

                    if imgui.Button("Bong") then
                        GFX:send("headline", {Type = "Play-HeadlineBong"})
                    end

                    imgui.SameLine()

                    if imgui.Button("Kill Bed") then
                        GFX:send("headline", {Type = "Stop-HeadlineBong"})
                    end

                    imgui.SameLine()

                    if imgui.Button("Fade out bed") then
                        GFX:send("headline", {Type = "FadeOut-HeadlineBong"})
                    end

                imgui.EndChild()
            end



            if imgui.CollapsingHeader_TreeNodeFlags("Titles", nil) then
                imgui.BeginChild_Str("titlesChildBox",imgui.ImVec2_Float(imgui.GetWindowWidth()-8, 180))

                imgui.PushFont(TitleFont)
                imgui.Text("Choose a title sequence to load into playout")
                imgui.PopFont()

                    imgui.BeginListBox("###TitlesList",imgui.ImVec2_Float(0, 5 * imgui.GetTextLineHeightWithSpacing()))
                    for i, v in ipairs(TitlesList) do
                        local selected = false
                        if TitlesSelected == i then
                            selected = true
                        end
                        if imgui.Selectable_Bool(v.name, selected) then
                            TitlesSelected = i
                            GFX:send("headline", {Type = "Load-AVPlayout", vid = v.vid, aud = v.aud, freeze = playoutFreeze[0]})
                        end
                    end
                    imgui.EndListBox()


                imgui.EndChild()
            end

            if imgui.CollapsingHeader_TreeNodeFlags("Closings", nil) then
                imgui.BeginChild_Str("closingsChildBox",imgui.ImVec2_Float(imgui.GetWindowWidth()-8, 180))

                imgui.PushFont(TitleFont)
                imgui.Text("Choose a closing sequence to load into playout")
                imgui.PopFont()

                    imgui.BeginListBox("###closeList",imgui.ImVec2_Float(0, 5 * imgui.GetTextLineHeightWithSpacing()))
                    for i, v in ipairs(closeList) do
                        local selected = false
                        if closeSelected == i then
                            selected = true
                        end
                        if imgui.Selectable_Bool(v.name, selected) then
                            closeSelected = i
                            GFX:send("headline", {Type = "Load-AVPlayout", vid = v.vid, aud = v.aud, freeze = playoutFreeze[0]})
                        end
                    end
                    imgui.EndListBox()
                imgui.EndChild()
            end

            imgui.PopStyleColor()

            if imgui.Button("Play out video") then
                GFX:send("headline", {Type = "Play-AV"})
            end

            imgui.SameLine()
            imgui.Checkbox("Freeze Frame", playoutFreeze)

         imgui.End()
        end

        if showTickerCon[0] == true then
            imgui.Begin("Ticker Control", showTickerCon, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
                imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
                
                imgui.Text("Control ticker")

                --Drop down
                imgui.Separator()
                imgui.Separator()

                imgui.PushFont(TimingsFont)
                imgui.Text("Ticker")
                imgui.PopFont()
                imgui.Text("Default ticker text") imgui.SameLine()
                imgui.InputText("###defaultTickerText", defaultTickerText, 1024)

                if imgui.Checkbox("Use BBC News UK RSS Feed", tickerUsingRSS) then
                    if tickerUsingRSS[0] == true then
                        GFX:send("headline", {Type = "GetTickerTextTable", Text = wires.wireData, DefaultText = ffi.string(defaultTickerText)})
                    else
                        GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(tickerText), DefaultText = ffi.string(defaultTickerText)})
                    end
                end

                if tickerUsingRSS[0] == false then
                    imgui.Separator()
                    imgui.PushFont(TitleFont)
                    imgui.Text("--- Ticker Guide ---")
                    imgui.Text("Use this guide to learn how the ticker is filled")
                    imgui.Text("To add the HEADLINES text, type !hh")
                    imgui.Text("To add a headline, type !h followed by the headline text (ex. !h Lorem ipsum dolor sit amet)")
                    imgui.Text("To add the BREAKING text, type !bb")
                    imgui.Text("To add a breaking story, type !b followed by the story text (ex. !b Lorem ipsum dolor sit amet)")
                    imgui.Text("To add the INTERACTIVE text, type !ii")
                    imgui.Text("To add the text for it, type !i followed by the text (ex. !i Follow us XXXX)")
                    imgui.Text("A better system is coming i just made this in like 5 mins ")
                    imgui.PopFont()
                    imgui.Separator()

                    imgui.InputTextMultiline("###tickerText", tickerText,6553, imgui.ImVec2_Float(800,200), imgui.love.InputTextFlags("None"))

                    
                    imgui.Separator()
                end

                if imgui.Button("Ticker Off") then
                    GFX:send("headline", {Type = "KillTicker", Text = ffi.string(defaultTickerText)})
                end

                imgui.SameLine()

                if imgui.Button("Ticker On") then
                    GFX:send("headline", {Type = "ResumeTicker"})
                end

                imgui.SameLine()

                if tickerUsingRSS[0] == false then
                    if imgui.Button("Send Updated Ticker Text") then
                        GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(tickerText), DefaultText = ffi.string(defaultTickerText)})
                    end

                    imgui.SameLine()

                    if imgui.Button("Save current ticker text") then
                        --Get and save current ticker text
                        local saveTickerText = ffi.string(tickerText)
                        love.filesystem.write("ticker.txt", saveTickerText)

                    end

                    imgui.Separator()
                end

                


                imgui.Separator()
                imgui.Separator()
            imgui.End()
        end

        if showBrandingCon[0] == true then
            imgui.Begin("Branding Control", showBrandingCon, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
            imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))

                imgui.PushFont(TimingsFont)
                imgui.Text("Branding")
                imgui.PopFont()                                 
                imgui.Text("Controls branding of all onscreen graphics")
                imgui.Separator()
                imgui.Separator()

                imgui.Text("Branding Theme name")
                imgui.SameLine()
                imgui.InputText("###brandingThemeName", brandingNameBox, 1024)

                imgui.Text("Channel name")
                imgui.SameLine()
                imgui.InputText("###brandingNameInput", brandingThemeNameBox, 1024)

                imgui.Text("Theme colour")
                imgui.SameLine()
                imgui.ColorEdit3("###brandingColorInput",brandingThemeColor,imgui.love.ColorEditFlags("None"))

                imgui.Text("Clock mode")
                imgui.SameLine()
                if imgui.Combo_Str("###clockModeCombo", clockModeBox, "On\0Off\0Breakfast Clock\0") then
                    if clockModeBox[0] == 0 then
                        brandingPresets[brandingPresetSelected].clockMode = "default"
                    elseif clockModeBox[0] == 1 then
                        brandingPresets[brandingPresetSelected].clockMode = "off"
                    elseif clockModeBox[0] == 2 then
                        brandingPresets[brandingPresetSelected].clockMode = "breakfast"
                    end
                end

                imgui.Checkbox("Opaque ticker", brandingTickerOpaque)
                imgui.SameLine()
                imgui.Checkbox("Coloured Straps", brandingColoredStrap)
                
                
                if brandingPresets[1].name ~= "News Red Straps" then
                    table.insert(brandingPresets, 1, {name = "News Red Straps", channelName = "NEWS", opaque = true, coloredStrap = true, themeColor = {0.68,0,0}, clockMode = "default"})
                end
                

                imgui.Text("Saved brandings")
                imgui.SameLine()
                imgui.BeginListBox("###brandingPresetList",imgui.ImVec2_Float(300, 80))
                ---@diagnostic disable-next-line: param-type-mismatch
                for i, v in ipairs(brandingPresets) do
                        local selected = false
                        if brandingPresetSelected == i then
                            selected = true


                        end

                        -- imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, imgui.ImVec4_Float(v.tcolor[1], v.tcolor[2], v.tcolor[3], 1))
                        -- imgui.PushStyleColor_Vec4(imgui.ImGuiCol_FrameBg, imgui.ImVec4_Float(1,0,0, 1))
                        if imgui.Selectable_Bool(v.name.."###"..i, selected) then
                            brandingPresetSelected = i
                            love.filesystem.write("branding_exdata.bin", tostring(i))
                            brandingNameBox = ffi.new("char[1024]", v.name)
                            brandingThemeNameBox = ffi.new("char[1024]", v.channelName)
                            brandingThemeColor[0] = v.themeColor[1]
                            brandingThemeColor[1] = v.themeColor[2]
                            brandingThemeColor[2] = v.themeColor[3]
                            if v.opaque == nil then brandingTickerOpaque[0] = false else brandingTickerOpaque[0] = v.opaque end
                            if v.coloredStrap == nil then brandingColoredStrap[0] = false else brandingColoredStrap[0] = v.coloredStrap end

                            
                            if v.clockMode == "default" then
                                clockModeBox[0] = 0
                            elseif v.clockMode == "off" then
                                clockModeBox[0] = 1
                            elseif v.clockMode == "breakfast" then
                                clockModeBox[0] = 2
                            end
                            
                            GFX:send("headline", {Type = "Set-Branding", channelName = ffi.string(brandingThemeNameBox), opaque = v.opaque, coloredStrap = v.coloredStrap, ThemeColor = {brandingThemeColor[0],brandingThemeColor[1],brandingThemeColor[2]}, clockMode = v.clockMode})


                        end
                        imgui.SameLine()
                        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ChildBg, imgui.ImVec4_Float(v.themeColor[1], v.themeColor[2], v.themeColor[3], 1))
                            imgui.BeginChild_Str("###brandingPresetColExample"..i, imgui.ImVec2_Float(30,18))
                            imgui.EndChild()
                        imgui.PopStyleColor()
                    end
                imgui.EndListBox()

                imgui.SetCursorPosX(110)

                if imgui.Button("Save branding") then
                    table.insert(brandingPresets, {name = ffi.string(brandingNameBox), channelName = ffi.string(brandingThemeNameBox), themeColor = {brandingThemeColor[0], brandingThemeColor[1], brandingThemeColor[2]}, opaque = brandingTickerOpaque[0], coloredStrap = brandingColoredStrap[0]})
                end 

                imgui.SameLine()

                if imgui.Button("Remove selected branding") then
                    table.remove(brandingPresets, brandingPresetSelected)
                    brandingPresetSelected = 0
                end

                imgui.SameLine()
                
                if imgui.Button("Send Branding") then
                    local xclockMode = "default"
                    if clockModeBox[0] == 0 then
                        xclockMode = "default"
                    elseif clockModeBox[0] == 1 then
                        xclockMode = "off"
                    elseif clockModeBox[0] == 2 then
                        xclockMode = "breakfast"
                    end
                    GFX:send("headline", {Type = "Set-Branding", channelName = ffi.string(brandingThemeNameBox), opaque = brandingTickerOpaque, coloredStrap = brandingColoredStrap[0], ThemeColor = {brandingThemeColor[0],brandingThemeColor[1],brandingThemeColor[2]}})
                end

                imgui.Text("Custom logos coming soon....")

            imgui.End()

        end

        if showError == true then 
            imgui.OpenPopup_Str(errorTitle)
            local center = imgui.ImVec2_Float(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
            imgui.SetNextWindowPos(center, imgui.ImGuiCond_Appearing, imgui.ImVec2_Float(0.5, 0.5))

            if imgui.BeginPopupModal(errorTitle, nil, imgui.love.WindowFlags("AlwaysAutoResize", "NoSavedSettings", "NoMove"))then
                imgui.Text(errorMessage)
                
                imgui.Separator()
                if imgui.Button("OK", imgui.ImVec2_Float(120, 0)) then
                    imgui.CloseCurrentPopup()
                    showError = false
                end
            imgui.EndPopup()
            end
        end




    imgui.End()


-- code to render imgui
imgui.Render()
imgui.love.RenderDrawLists()

end













function love.mousemoved(x, y, ...)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

function love.mousepressed(x, y, button, ...)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

function love.mousereleased(x, y, button, ...)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

function love.wheelmoved(x, y)
    imgui.love.WheelMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

function love.keypressed(key, ...)
    --if ShowSaveDialog == true or ShowOpenDialog == true then else 
        imgui.love.KeyPressed(key)
        imgui.love.RunShortcuts(key)
        if not imgui.love.GetWantCaptureKeyboard() then
            -- your code here
        end 
    --end
end

function love.keyreleased(key, ...)
    --if ShowSaveDialog == true or ShowOpenDialog == true then else imgui.love.KeyReleased(key) end
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

function love.textinput(t)
    --if ShowSaveDialog == true or ShowOpenDialog == true then else  end
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

function love.quit()
    bitser.dumpLoveFile("badges.dat", presetBadges)
    bitser.dumpLoveFile("branding.dat", brandingPresets)
    return imgui.love.Shutdown()
end

-- for gamepad support also add the following:

function love.joystickadded(joystick)
    imgui.love.JoystickAdded(joystick)
    -- your code here 
end

function love.joystickremoved(joystick)
    imgui.love.JoystickRemoved()
    -- your code here 
end

function love.gamepadpressed(joystick, button)
    imgui.love.GamepadPressed(button)
    -- your code here 
end

function love.gamepadreleased(joystick, button)
    imgui.love.GamepadReleased(button)
    -- your code here 
end

-- choose threshold for considering analog controllers active, defaults to 0 if unspecified
local threshold = 0.2 

function love.gamepadaxis(joystick, axis, value)
    imgui.love.GamepadAxis(axis, value, threshold)
    -- your code here 
end








function convertTableToCondensedString(tbl)
    local str = ""
    for i, num in ipairs(tbl) do
        str = str .. string.format("%.1f", num)
        if i < #tbl then
            str = str .. "/"
        end
    end
    return str
end

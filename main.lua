local inspect = require "lib.inspect"

--Set Identity
love.filesystem.setIdentity("VizHelper")



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


AstonControl = require "modules.aston_control"
TickerControl = require "modules.ticker_control"
BrandingControl = require "modules.branding_control"

local showTileCon = ffi.new("bool[1]", false)
local showHeadlineCon = ffi.new("bool[1]", false)
local showLiveCon = ffi.new("bool[1]", false)
local showPlayoutCon = ffi.new("bool[1]", false)
local showBrandingCon = ffi.new("bool[1]", false)
local showAutomationCon = ffi.new("bool[1]", false)

local stylePicker = ffi.new("int[1]", 0)

local headlineStrap1 = ffi.new("char[1024]", "")
local headlineStrap2 = ffi.new("char[1024]", "")
local headlineStrapComingUp = ffi.new("bool[1]", false)
local headlineStrapnoBBC = ffi.new("bool[1]", false)
local shitViz = ffi.new("bool[1]", false)

local liveBugText = ffi.new("char[1024]", "")
local liveBugLive = ffi.new("bool[1]", true)
local liveBugShowTime = ffi.new("bool[1]", false)
local liveBugTimeOffset = ffi.new("int[1]", 0)



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
    {name = "News 24 Headline Bed 2007", aud = "News24_07v2.wav"},
    {name = "News 24 Quarter Headline Bed 2007 ", aud = "News24_07v1.wav"},
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



GFX = sock.newClient("localhost", 10655)
GFX:connect()

local connectedToViz = false

showError = false
errorTitle = ""
errorMessage = ""


GFX:on("connect", function(data)
    GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(TickerControl.tickerText), DefaultText = ffi.string(TickerControl.defaultTickerText)})
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
    TickerControl.update(dt)

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
                AstonControl.show()
            end
            imgui.SameLine() 
            if imgui.Button("Ticker Control", imgui.ImVec2_Float(100, 100)) then
                TickerControl.show()
            end
            imgui.SameLine()

  
            if imgui.Button("Playout\nControl", imgui.ImVec2_Float(100, 100)) then
                -- showPlayoutCon[0] = true
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip("in development - coming soon")
            end

            imgui.SameLine()
            if imgui.Button("Branding\nControl", imgui.ImVec2_Float(100,100)) then
                BrandingControl.show()
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
                -- showAutomationCon[0] = true            
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip("in development - coming soon")
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

        if AstonControl.shouldShow[0] == true then
            AstonControl.draw()
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

        if TickerControl.shouldShow[0] == true then
            TickerControl.draw()
        end

        if BrandingControl.shouldShow[0] == true then
            BrandingControl.draw()
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
    bitser.dumpLoveFile("badges.dat", AstonControl.presetBadges)
    bitser.dumpLoveFile("branding.dat", BrandingControl.brandingPresets)
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

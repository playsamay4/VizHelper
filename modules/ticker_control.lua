local tickerControl = {}

--Check if ticker.txt exists
local tickerExists = love.filesystem.read("ticker.txt")
if tickerExists == nil then
    love.filesystem.write("ticker.txt", "!hh\n!h Edit the text in VizHelper\n!ii\n!i Edit the text in VizHelper")
end

tickerControl.shouldShow = ffi.new("bool[1]", false)

tickerControl.defaultTickerText = ffi.new("char[1024]", "bbc.co.uk/news")

tickerControl.tickerText = ffi.new("char[65535]")
tickerControl.tickerTextRSS = ffi.new("char[65535]", "")
tickerControl.tickerUsingRSS = ffi.new("bool[1]", false)

local wires = require "wires"

--Load ticker text
local tickerFile = love.filesystem.read("ticker.txt")
if tickerFile ~= nil then
    tickerControl.tickerText = ffi.new("char[65535]", tickerFile)
end

tickerControl.show = function()
    tickerControl.shouldShow[0] = true
end

tickerControl.update = function(dt)
    wires.Update(dt)
end


tickerControl.draw = function()
    imgui.Begin("Ticker Control", tickerControl.shouldShow, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
        imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,400))
        
        imgui.Text("Control ticker")

        --Drop down
        imgui.Separator()
        imgui.Separator()

        imgui.PushFont(TimingsFont)
        imgui.Text("Ticker")
        imgui.PopFont()
        imgui.Text("Default ticker text") imgui.SameLine()
        imgui.InputText("###defaultTickerText", tickerControl.defaultTickerText, 1024)

        if imgui.Checkbox("Use BBC News UK RSS Feed", tickerControl.tickerUsingRSS) then
            if tickerControl.tickerUsingRSS[0] == true then
                GFX:send("headline", {Type = "GetTickerTextTable", Text = wires.wireData, DefaultText = ffi.string(tickerControl.defaultTickerText)})
            else
                GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(tickerControl.tickerText), DefaultText = ffi.string(tickerControl.defaultTickerText)})
            end
        end

        if tickerControl.tickerUsingRSS[0] == false then
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

            imgui.InputTextMultiline("###tickerText", tickerControl.tickerText,6553, imgui.ImVec2_Float(800,200), imgui.love.InputTextFlags("None"))

            
            imgui.Separator()
        end

        if imgui.Button("Ticker Off") then
            GFX:send("headline", {Type = "KillTicker", Text = ffi.string(tickerControl.defaultTickerText)})
        end

        imgui.SameLine()

        if imgui.Button("Ticker On") then
            GFX:send("headline", {Type = "ResumeTicker"})
        end

        imgui.SameLine()

        if tickerControl.tickerUsingRSS[0] == false then
            if imgui.Button("Send Updated Ticker Text") then
                GFX:send("headline", {Type = "GetTickerText", Text = ffi.string(tickerControl.tickerText), DefaultText = ffi.string(tickerControl.defaultTickerText)})
            end

            imgui.SameLine()

            if imgui.Button("Save current ticker text") then
                --Get and save current ticker text
                local saveTickerText = ffi.string(tickerControl.tickerText)
                love.filesystem.write("ticker.txt", saveTickerText)

            end

            imgui.Separator()
        end

        


        imgui.Separator()
        imgui.Separator()
    imgui.End()
end


return tickerControl
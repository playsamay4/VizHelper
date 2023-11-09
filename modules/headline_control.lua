local headlineControl = {}

headlineControl.shouldShow = ffi.new("bool[1]", false)

headlineControl.show = function()
    headlineControl.shouldShow[0] = true
end

headlineControl.headlineStrap1 = ffi.new("char[1024]", "")
headlineControl.headlineStrap2 = ffi.new("char[1024]", "")
headlineControl.headlineStrapComingUp = ffi.new("bool[1]", false)
headlineControl.headlineStrapnoBBC = ffi.new("bool[1]", false)
headlineControl.shitViz = ffi.new("bool[1]", false)


headlineControl.draw = function()
    imgui.Begin("Headline Control", headlineControl.shouldShow, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
        imgui.SetWindowSize_Vec2(imgui.ImVec2_Float(800,350))

        imgui.PushFont(TimingsFont)
        imgui.Text("Headline Strap")
        imgui.PopFont()
        imgui.InputTextWithHint("###headlineStrap1","Text to appear on the top line", headlineControl.headlineStrap1, 1024)
        imgui.InputTextWithHint("###headlineStrap2", "Text to appear on the bottom line, leave empty for single line strap", headlineControl.headlineStrap2, 1024)

        imgui.Text("Coming Up badge") imgui.SameLine()
        imgui.Checkbox("###headlineStrapComing", headlineControl.headlineStrapComingUp)

        imgui.Text("No BBC NEWS box")
        imgui.SameLine()
        imgui.Checkbox("###headlineStrapBBC", headlineControl.headlineStrapnoBBC)

        imgui.Text("Look North Viz Style")
        imgui.SameLine()
        imgui.Checkbox("###lookNorthViz", headlineControl.shitViz)
        imgui.SameLine()
        imgui.Text("(one line straps only)")



        imgui.SetCursorPosY(300)
        if imgui.Button("Show Strap", imgui.ImVec2_Float(400,40)) then
            local style = ""
            if headlineControl.headlineStrapComingUp[0] == true then
                style = style.."ComingUp"
            end
            if headlineControl.headlineStrapnoBBC[0] == true then
                style = style.." ComingUpOnly"
            end

            if ffi.string(headlineControl.headlineStrap2) == "" then
                GFX:send("headline", {Type = "Show-Headline", Text = ffi.string(headlineControl.headlineStrap1), Style = style, Regional = headlineControl.shitViz[0]})
            else
                GFX:send("headline", {Type = "Show-Headline", Text = ffi.string(headlineControl.headlineStrap1).."|"..ffi.string(headlineControl.headlineStrap2), Style = style, Regional = false})
            end

        end

        imgui.SameLine()

        if imgui.Button("Hide Strap",imgui.ImVec2_Float(400,40) ) then
            GFX:send("headline", {Type = "Hide-Headline", Regional = headlineControl.shitViz[0]})
        end
        
    imgui.End()
end

return headlineControl
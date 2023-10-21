local playoutControl = {}

playoutControl.shouldShow = ffi.new("bool[1]", false)

playoutControl.show = function()
    playoutControl.shouldShow[0] = true
end

playoutControl.TitlesList = {
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
playoutControl.TitlesSelected = 0

playoutControl.closeList = {
    {name = "World News Closing", vid = "WN_Close.ogv", aud = "WN_Close.wav"},
    {name = "BBC One Bulletin Trundle Close (With Tile)", vid = "NONE", aud = "CloseE.wav"},
}
playoutControl.closeSelected = 0

playoutControl.headlineBedList = {
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
playoutControl.headlineBedSelected = 1

playoutControl.playoutFreeze = ffi.new("bool[1]", false)

playoutControl.draw = function()
    imgui.Begin("Playout Control", playoutControl.shouldShow, imgui.love.WindowFlags("NoSavedSettings", "NoResize"))
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
            for i, v in ipairs(playoutControl.headlineBedList) do
                local selected = false
                if playoutControl.headlineBedSelected == i then
                    selected = true
                end
                if imgui.Selectable_Bool(v.name, selected) then
                    playoutControl.headlineBedSelected = i
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
            for i, v in ipairs(playoutControl.TitlesList) do
                local selected = false
                if TitlesSelected == i then
                    selected = true
                end
                if imgui.Selectable_Bool(v.name, selected) then
                    TitlesSelected = i
                    GFX:send("headline", {Type = "Load-AVPlayout", vid = v.vid, aud = v.aud, freeze = playoutControl.playoutFreeze[0]})
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
            for i, v in ipairs(playoutControl.closeList) do
                local selected = false
                if playoutControl.closeSelected == i then
                    selected = true
                end
                if imgui.Selectable_Bool(v.name, selected) then
                    playoutControl.closeSelected = i
                    GFX:send("headline", {Type = "Load-AVPlayout", vid = v.vid, aud = v.aud, freeze = playoutControl.playoutFreeze[0]})
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
    imgui.Checkbox("Freeze Frame", playoutControl.playoutFreeze)

    imgui.End()
end

return playoutControl
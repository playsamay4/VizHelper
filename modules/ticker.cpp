/*
    This file is part of VizHelper (https://github.com/playsamay4/VizHelper)

    by playsamay4

    Licensed under the GNU GPL v3 License
    See LICENSE for more details

*/

#include <sstream>
#include "hello_imgui/hello_imgui.h"
#include "misc/cpp/imgui_stdlib.h"
#include "imgui_toggle/imgui_toggle.h"

bool show_ticker_control = false;

std::string tickerText = "!hh\n!h Edit the text in VizHelper";
std::string defaultTickerText = "bbc.co.uk/news";

bool tickerUsingRSS = false;

void LoadTicker()
{
    tickerText = HelloImGui::LoadUserPref("TickerText");
    defaultTickerText = HelloImGui::LoadUserPref("DefaultTickerText");

    if (tickerText.empty()) {
        tickerText = "!hh\n!h Edit the text in VizHelper";
        HelloImGui::SaveUserPref("TickerText", tickerText);
    }

    if (defaultTickerText.empty()) {
		defaultTickerText = "bbc.co.uk/news";
		HelloImGui::SaveUserPref("DefaultTickerText", defaultTickerText);
	}
}

void ShowTickerControl() {
    show_ticker_control = !show_ticker_control;
}

void TickerControlWindow()
{
    if (show_ticker_control)
    {
        ImGui::Begin("Ticker Control", &show_ticker_control, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoResize);
        ImGui::SetWindowSize(ImVec2(800, 400));
            ImGui::Text("Control ticker");

            ImGui::Separator();
            ImGui::Separator();

            ImGui::InputText("Default ticker text##defaultTickerText", &defaultTickerText);

            bool changed = false;
            changed |= ImGui::Toggle("Use BBC News UK RSS feed", &tickerUsingRSS);

        ImGui::End();

    }
}
/*
    This file is part of VizHelper (https://github.com/playsamay4/VizHelper)

    by playsamay4

    Licensed under the GNU GPL v3 License
    See LICENSE for more details

*/
#include "immapp/immapp.h"

bool show_demo_window = true;

void Gui()
{
    if (ImGui::BeginMainMenuBar())
    {
        if (ImGui::BeginMenu("VizHelper"))
        {
            if (ImGui::MenuItem("Toggle ImGui debug menu"))
            {
				show_demo_window = !show_demo_window;
			}
            
            if (ImGui::MenuItem("Exit"))
            {
                exit(0);
			}
			ImGui::EndMenu();
		}
        ImGui::EndMainMenuBar();
    }

    if (show_demo_window)
		ImGui::ShowDemoWindow(&show_demo_window);


    ImGui::SetNextWindowSize(ImVec2(500, 300));
    ImGui::Begin("VizHelper Main", NULL, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoMove);

    ImGui::SetWindowPos(ImVec2(30, 50));

    /*
        Aston Control
        Ticker Control
        Playout Control
        Branding Control
        Headline Control
        Tile Control
        Live Bug Control
        Automation (alpha)

    */

    ImGui::Text("Welcome to VizHelper");
    ImGui::Separator();
    if (ImGui::Button("Aston\nControl", ImVec2(100, 100)))
        printf("aston control btn pressed"); //show aston control

    ImGui::SameLine();
    if (ImGui::Button("Ticker Control", ImVec2(100, 100)))
		printf("ticker control btn pressed"); //show aston status
  
    ImGui::SameLine();
    if (ImGui::Button("Playout\nControl", ImVec2(100, 100)))
        printf("playout control btn pressed"); //show playout control

    ImGui::SameLine();
    if (ImGui::Button("Branding\nControl", ImVec2(100, 100)))
		printf("branding control btn pressed"); //show branding control

    if (ImGui::Button("Headline\nControl", ImVec2(100, 100)))
        printf("headline control btn pressed"); //show headline control

    ImGui::SameLine();
    if (ImGui::Button("Tile Control", ImVec2(100, 100)))
        printf("tile control btn pressed"); //show tile control

    ImGui::SameLine();
    if (ImGui::Button("Live Bug\nControl", ImVec2(100, 100)))
		printf("live bug control btn pressed"); //show live bug control

    ImGui::SameLine();
    if (ImGui::Button("Automation\n(alpha)", ImVec2(100, 100)))
        printf("automation btn pressed"); //show automation control
    if (ImGui::IsItemHovered())
        ImGui::SetTooltip("coming soon");

    ImGui::End();
    
        
}


int main(int, char* [])
{
    HelloImGui::SimpleRunnerParams runnnerParams;
    runnnerParams.guiFunction = Gui;
    runnnerParams.windowSize = { 1280, 720 };
    runnnerParams.windowTitle = "VizHelper";

    ImmApp::AddOnsParams addOnsParams;

    ImmApp::Run(runnnerParams, addOnsParams);
    return 0;
}
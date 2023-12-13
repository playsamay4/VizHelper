/*
    This file is part of VizHelper (https://github.com/playsamay4/VizHelper)

    by playsamay4

    Licensed under the GNU GPL v3 License
    See LICENSE for more details

*/
#include "immapp/immapp.h"
#include "hello_imgui/hello_imgui.h"
#include "modules/aston.cpp"
#include "modules/ticker.cpp"

////
bool debug = true;
////

bool setup_style = false;

bool show_demo_window = true;
bool connected_to_viz = false;

void SetupStyle()
{
    ImGuiStyle& style = ImGui::GetStyle();
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.13f, 0.13f, 0.14f, 1.0f);
    style.Colors[ImGuiCol_TitleBg] = ImVec4(0.13f, 0.13f, 0.14f, 1.0f);
    style.Colors[ImGuiCol_TitleBgActive] = ImVec4(0, 0, 0, 1.0f);
}

void InitializePostImGuiLoad()
{
    //docking with shift
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    io.ConfigDockingWithShift = true;



    LoadTicker();
}

void Gui()
{
    if (!setup_style)
    {
		SetupStyle();
		setup_style = true;
	}

    if (ImGui::BeginMainMenuBar())
    {
        if (ImGui::BeginMenu("VizHelper"))
        {
            if (debug && ImGui::MenuItem("Toggle ImGui debug menu"))
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

    if (show_demo_window && debug)
		ImGui::ShowDemoWindow(&show_demo_window);


    ImGui::SetNextWindowSize(ImVec2(440, 300));
    ImGui::Begin("VizHelper Main", NULL, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoMove);

    ImGui::SetWindowPos(ImVec2(30, 50));
    

    ImGui::Text("Welcome to VizHelper");
    ImGui::Separator();
    if (ImGui::Button("Aston\nControl", ImVec2(100, 100)))
        printf("aston control btn pressed");

    ImGui::SameLine();
    if (ImGui::Button("Ticker Control", ImVec2(100, 100)))
        ShowTickerControl();
  
    ImGui::SameLine();
    if (ImGui::Button("Playout\nControl", ImVec2(100, 100)))
        printf("playout control btn pressed");

    ImGui::SameLine();
    if (ImGui::Button("Branding\nControl", ImVec2(100, 100)))
		printf("branding control btn pressed");

    if (ImGui::Button("Headline\nControl", ImVec2(100, 100)))
        printf("headline control btn pressed"); 

    ImGui::SameLine();
    if (ImGui::Button("Tile Control", ImVec2(100, 100)))
        printf("tile control btn pressed"); 

    ImGui::SameLine();
    if (ImGui::Button("Live Bug\nControl", ImVec2(100, 100)))
		printf("live bug control btn pressed"); 

    ImGui::SameLine();
    if (ImGui::Button("Automation\n(alpha)", ImVec2(100, 100)))
        printf("automation btn pressed"); 
    if (ImGui::IsItemHovered())
        ImGui::SetTooltip("coming soon");

    static std::string text = "Connect to Viz2.0";
    if (connected_to_viz) 
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.0f, 0.5f, 0.0f, 1.0f));
    else 
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.5f, 0.0f, 0.0f, 1.0f));
    if (ImGui::Button(text.c_str(), ImVec2(425, 50)))
    {
        if (connected_to_viz)
        {
			connected_to_viz = false;
			text = "Connect to Viz2.0";
		}
        else
        {
			connected_to_viz = true;
            text = "Connected to Viz2.0";
		}
	}
    ImGui::PopStyleColor();

    ImGui::End();


    ImGui::SetCursorPos(ImVec2(30, ImGui::GetWindowSize().y-80));
    if (HelloImGui::ImageButtonFromAsset("gear.png", ImVec2(29,25)))
        printf("settings btn pressed");


    // render other windows
    TickerControlWindow();
}


int main(int, char* [])
{
    HelloImGui::RunnerParams runnnerParams;
    runnnerParams.callbacks.ShowGui = Gui;
    runnnerParams.callbacks.PostInit = InitializePostImGuiLoad;
    runnnerParams.appWindowParams.windowTitle = "VizHelper";
    runnnerParams.appWindowParams.windowGeometry.size = { 1280, 720 };
    runnnerParams.iniFilename = "VizHelper/VizHelper.ini";
    if(debug)
        runnnerParams.iniFolderType = HelloImGui::IniFolderType::CurrentFolder;
    else
        runnnerParams.iniFolderType = HelloImGui::IniFolderType::AppUserConfigFolder;
    


    ImmApp::AddOnsParams addOnsParams;

    ImmApp::Run(runnnerParams, addOnsParams);
    return 0;
}
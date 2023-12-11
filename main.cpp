/*
    This file is part of VizHelper (https://github.com/playsamay4/VizHelper)

    by playsamay4

    Licensed under the GNU GPL v3 License
    See LICENSE for more details

*/
#include "immapp/immapp.h"

void Gui()
{
    ImGui::Text("Hellow world from vizhelper");
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
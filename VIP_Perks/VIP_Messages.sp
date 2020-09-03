#include <sourcemod>
#include <cstrike>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
    name = "[CS:GO] VIP - Messages Perk",
    author = PLUGIN_AUTHOR,
    description = "",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/s4muray"
};

public void VIP_OnPlayerLoaded(int client)
{
    SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            ShowHudText(i, 0, "VIP %N has connected", client);
    }
}

public void OnClientDisconnect(int client)
{
    if(VIP_IsPlayerVIP(client))
    {
        SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i))
                ShowHudText(i, 0, "VIP %N has disconnected", client);
        }
    }
}
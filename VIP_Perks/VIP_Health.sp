#include <sourcemod>
#include <cstrike>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

ConVar g_cvBonus = null;

public Plugin myinfo = 
{
    name = "[CS:GO] VIP - Health Perk",
    author = PLUGIN_AUTHOR,
    description = "",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/s4muray"
};

public void OnPluginStart()
{
    g_cvBonus = CreateConVar("vip_health_bonus", "10", "Amount of health to give when a vip spawn", 0, true, 0.0);
    
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action Event_PlayerSpawn(Event event, char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(event.GetInt("userid"));
    if(VIP_IsPlayerVIP(iClient) && g_cvBonus.IntValue > 0)
    {
        SetEntityHealth(iClient, GetClientHealth(iClient) + g_cvBonus.IntValue);
        PrintToChat(iClient, "%s You spawned with health bonus of \x02%d \x01hp.", PREFIX, g_cvBonus.IntValue);
    }
}
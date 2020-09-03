#include <sourcemod>
#include <cstrike>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define HELMET_ON 1
#define FULL_ARMOR 100

public Plugin myinfo = 
{
    name = "[CS:GO] VIP - Armor Perk",
    author = PLUGIN_AUTHOR,
    description = "",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/s4muray"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action Event_PlayerSpawn(Event event, char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(event.GetInt("userid"));
    if(VIP_IsPlayerVIP(iClient))
    {
        SetEntProp(iClient, Prop_Send, "m_bHasHelmet", HELMET_ON);
        SetEntProp(iClient, Prop_Data, "m_ArmorValue", FULL_ARMOR, 1); 
    }
}
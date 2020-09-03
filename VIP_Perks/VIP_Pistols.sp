#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

enum
{
	Pistol_Classname = 0, 
	Pistol_Name
}

char g_szPistols[][][] =  {
	{ "weapon_usp_silencer", "USP-S" }
};

public Plugin myinfo = 
{
	name = "[CS:GO] VIP - Pistols Perk", 
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
	if (VIP_IsPlayerVIP(iClient))
	{
		Menu menu = new Menu(Handler_Pistols);
		menu.SetTitle("%s Select a Pistol:\n ", PREFIX_MENU);
		
		for (int i = 0; i < sizeof(g_szPistols); i++)
		menu.AddItem(g_szPistols[i][Pistol_Classname], g_szPistols[i][Pistol_Name]);
		
		menu.Display(iClient, MENU_TIME_FOREVER);
	}
}

public int Handler_Pistols(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if (iWeapon != -1)
			AcceptEntityInput(iWeapon, "kill");
		
		GivePlayerItem(client, g_szPistols[itemNum][Pistol_Classname]);
		PrintToChat(client, "%s You chose to play with \x02%s\x01.", PREFIX, g_szPistols[itemNum][Pistol_Name]);
	}
} 
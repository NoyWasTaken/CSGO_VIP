#include <sourcemod>
#include <cstrike>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

Database g_dbDatabase = null;

char g_szTag[MAXPLAYERS + 1][64];
char g_szAuth[MAXPLAYERS + 1][32];

public Plugin myinfo = 
{
	name = "[CS:GO] VIP - Clantag Perk", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/s4muray"
};

public void OnPluginStart()
{
	SQL_MakeConnection();
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	RegConsoleCmd("sm_clantag", Command_ClanTag, "Set your clantag");
}

public void VIP_OnPlayerLoaded(int client)
{
	if (!GetClientAuthId(client, AuthId_Steam2, g_szAuth[client], sizeof(g_szAuth)))
	{
		KickClient(client, "Verification problem, please reconnect");
		return;
	}
	
	g_szTag[client][0] = 0; // reset old data
	SQL_LoadUser(client);
}

public void VIP_OnPlayerGiven(int client, int duration)
{
	VIP_OnPlayerLoaded(client);
}

public Action Event_PlayerSpawn(Event event, char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(iClient))
	{
		CS_SetClientClanTag(iClient, g_szTag[iClient]);
	}
}

public Action Command_ClanTag(int client, int args)
{
	if (!client)
	{
		PrintToServer("This command is for in-game only.");
		return Plugin_Handled;
	}
	
	if (!VIP_IsPlayerVIP(client))
	{
		ReplyToCommand(client, "%s This command is for vip players only.", PREFIX);
		return Plugin_Handled;
	}
	
	GetCmdArgString(g_szTag[client], sizeof(g_szTag));
	
	SQL_UpdateTag(client);
	
	PrintToChat(client, "%s You changed your clantag to \x02%s\x01.", PREFIX, g_szTag[client]);
	return Plugin_Handled;
}

/* Database */

void SQL_MakeConnection()
{
	if (g_dbDatabase != null)
		delete g_dbDatabase;
	
	char szError[512];
	g_dbDatabase = SQL_Connect(DATABASE_ENTRY, true, szError, sizeof(szError));
	if (g_dbDatabase == null)
		SetFailState("Cannot connect to datbase error: %s", szError);
	
	g_dbDatabase.Query(SQL_CheckForErrors, "CREATE TABLE IF NOT EXISTS `vips_clantags` (`auth` VARCHAR(32) NOT NULL, `clantag` VARCHAR(64) NOT NULL, UNIQUE(`auth`)");
}

void SQL_LoadUser(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "SELECT `clantag` FROM `vips_clantags` WHERE `auth` = '%s", g_szAuth[client]);
	g_dbDatabase.Query(SQL_LoadUser_CB, szQuery, GetClientSerial(client));
}

public void SQL_LoadUser_CB(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	if (results.FetchRow())
	{
		results.FetchString(0, g_szTag[iClient], sizeof(g_szTag));
		CS_SetClientClanTag(iClient, g_szTag[iClient]);
	}
}

void SQL_UpdateTag(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `vips_clantags` (`auth`, `clantag`) VALUES ('%s', '%s') ON DUPLICATE KEY UPDATE `clantag` = '%s", g_szAuth[client], g_szTag[client], g_szTag[client]);
	g_dbDatabase.Query(SQL_CheckForErrors, szQuery);
}

public void SQL_CheckForErrors(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
}

/* */
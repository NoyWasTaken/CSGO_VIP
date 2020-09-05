 // TODO: add sql support

#include <sourcemod>
#include <chat-processor>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define COLOR_TYPES 3
#define MAX_MESSAGE_LENGTH 4096

enum
{
	Color_Code = 0, 
	Color_Name
}

enum
{
	ColorType_Tag = 0, 
	ColorType_Name, 
	ColorType_Messages
}

Database g_dbDatabase = null;

char g_szColors[][][] = 
{
	{ "\x02", "Strong Red" }, 
	{ "\x03", "Team Color" }, 
	{ "\x04", "Green" }, 
	{ "\x05", "Turquoise" }, 
	{ "\x06", "Yellow Green" }, 
	{ "\x07", "Light Red" }, 
	{ "\x08", "Gray" }, 
	{ "\x09", "Light Yellow" }, 
	{ "\x10", "Orange" }, 
	{ "\x0A", "Light Blue" }, 
	{ "\x0C", "Purple" }, 
	{ "\x0E", "Pink" }
};
char g_szTag[MAXPLAYERS + 1][32];
char g_szAuth[MAXPLAYERS + 1][32];

int g_iColors[MAXPLAYERS + 1][COLOR_TYPES];

public Plugin myinfo = 
{
	name = "[CS:GO] VIP - Chat Perks", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/s4muray"
};

public void OnPluginStart()
{
	SQL_MakeConnection();
	
	RegConsoleCmd("sm_tag", Command_Tag, "Change your chat tag");
	RegConsoleCmd("sm_colors", Command_Colors, "Opens the colors menu");
}

public void VIP_OnPlayerLoaded(int client)
{
	if (!GetClientAuthId(client, AuthId_Steam2, g_szAuth[client], sizeof(g_szAuth)))
	{
		KickClient(client, "Verification problem, please reconnect");
		return;
	}
	
	for (int i = 0; i < COLOR_TYPES; i++)
	g_iColors[client][i] = -1;
	
	g_szTag[client][0] = 0;
	
	SQL_LoadPlayer(client);
}

public Action Command_Tag(int client, int args)
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
	PrintToChat(client, "%s You have changed your chat tag to \x02%s\x01.", PREFIX, g_szTag[client]);
	return Plugin_Handled;
}

public Action Command_Colors(int client, int args)
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
	
	Menus_ShowMain(client);
	return Plugin_Handled;
}

void Menus_ShowMain(int client)
{
	Menu menu = new Menu(Handler_Main);
	menu.SetTitle("%s Select a Type:\n ", PREFIX_MENU);
	menu.AddItem("tag", "Tag Color");
	menu.AddItem("name", "Name Color");
	menu.AddItem("messages", "Messages Color");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Main(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		Menus_ShowColors(client, itemNum);
	}
}

void Menus_ShowColors(int client, int type)
{
	Menu menu = new Menu(Handler_Colors);
	menu.SetTitle("%s Select a Color:\n ", PREFIX_MENU);
	
	char szIndex[10];
	IntToString(type, szIndex, sizeof(szIndex));
	menu.AddItem(szIndex, g_szColors[0][Color_Name]);
	
	for (int i = 1; i < sizeof(g_szColors); i++)
	menu.AddItem(g_szColors[i][Color_Code], g_szColors[i][Color_Name]);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Colors(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szIndex[10];
		menu.GetItem(0, szIndex, sizeof(szIndex));
		
		int iType = StringToInt(szIndex);
		g_iColors[client][iType] = itemNum;
		
		PrintToChat(client, "%s You changed your color to %s%s\x01.", PREFIX, g_szColors[itemNum][Color_Code], g_szColors[itemNum][Color_Name]);
	}
}

public Action CP_OnChatMessage(int & author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool & processcolors, bool & removecolors)
{
	if (VIP_IsPlayerVIP(author))
	{
		int iTagColor = g_iColors[author][ColorType_Tag];
		int iNameColor = g_iColors[author][ColorType_Name];
		int iChatColor = g_iColors[author][ColorType_Messages];
		
		Format(message, MAX_MESSAGE_LENGTH, "%s %s", iChatColor != -1 ? g_szColors[iChatColor][Color_Code]:"", message);
		Format(name, MAX_NAME_LENGTH, " \x01%s[%s] \x03%s%s\x01", iTagColor != -1 ? g_szColors[iTagColor][Color_Code]:"", !g_szTag[author][0] ? "V.I.P":g_szTag[author], iNameColor != -1 ? g_szColors[iNameColor][Color_Code]:"", name);
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

/* Database */

void SQL_MakeConnection()
{
	if (g_dbDatabase != null)
		delete g_dbDatabase;
	
	char szError[512];
	g_dbDatabase = SQL_Connect(DATABASE_ENTRY, true, szError, sizeof(szError));
	if (g_dbDatabase == null)
		SetFailState("Cannot connect to database error: %s", szError);
	
	g_dbDatabase.Query(SQL_CheckForErrors, "CREATE TABLE IF NOT EXISTS `vip_chat` (`auth` VARCHAR(32) NOT NULL, `tag` VARCHAR(32) NOT NULL, `tag_color` INT(10) NOT NULL DEFAULT 0, `name_color` INT(10) NOT NULL, `chat_color` INT(10) NOT NULL DEFAULT 0, UNIQUE(`auth`))");
}

void SQL_LoadPlayer(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "SELECT * FROM `vip_chat` WHERE `auth` = '%s'", g_szAuth[client]);
	g_dbDatabase.Query(SQL_LoadPlayer_CB, szQuery, GetClientSerial(client));
}

public void SQL_LoadPlayer_CB(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Databse error, %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	if (results.FetchRow())
	{
		results.FetchString(1, g_szTag[iClient], sizeof(g_szTag)); // starting from 1 because we ignore the auth column
		
		for (int i = 0; i < COLOR_TYPES; i++)
		g_iColors[iClient][i] = results.FetchInt(2 + i);
	} else {
		SQL_RegisterPlayer(iClient);
	}
}

void SQL_RegisterPlayer(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `vip_chat` (`auth`, `tag`) VALUES ('%s', '')", g_szAuth[client]);
	g_dbDatabase.Query(SQL_CheckForErrors, szQuery);
}

public void SQL_CheckForErrors(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Databse error, %s", error);
		return;
	}
}

/* */
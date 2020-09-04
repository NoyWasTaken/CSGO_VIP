 // TODO: add the chat processor hook, add sql support, add tag change

#include <sourcemod>
#include <chat-processor>
#include <VIP>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define COLOR_TYPES 3

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
		
	}
} 
/*
**
*/
#if defined _VIP_included
 #endinput
#endif
#define _VIP_included

#define DATABASE_ENTRY "VIP"

#define PREFIX " \x04[VIP]\x01"
#define PREFIX_ACTIVITY " \x04[VIP]\x01 "
#define PREFIX_MENU "[VIP]"

/**
* Check if player is a vip.
*
* @param client				client to check.
* @return whether the player is a vip or not. 
*/
native bool VIP_IsPlayerVIP(int client);

/*
* Called when a vip player has been loaded.
*
* @param client				the vip player.
* @noreturn
*/
forward void VIP_OnPlayerLoaded(int client);

/* 
* Called when a vip has been given to a player.
*
* @param client				the player who receieved the vip.
* @param item				the time of the new vip given (in days).
* @noreturn
*/
forward void VIP_OnPlayerGiven(int client, int duration);

#if !defined REQUIRE_PLUGIN
public __pl_VIP_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsPlayerVIP");
}
#endif

public SharedPlugin __pl_VIP =
{
	name = "[CS:GO] VIP System",
	file = "VIP.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

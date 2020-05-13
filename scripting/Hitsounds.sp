#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "MajesticCatDog, Sarrus"
#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>
#include <colorvariables>
#include <emitsoundany>

public Plugin myinfo =
{
	name = "Hitsounds",
	author = PLUGIN_AUTHOR,
	description = "Plays a sound when you hit the enemy",
	version = PLUGIN_VERSION,
	url = "steamcommunity.com/id/MajesticCatDog" //Feel free to add me and send me criticism/ask for help
};

Handle g_hHitsoundUserPreference = null;
Handle g_hCookieDefaultSet = null;
bool g_bEnabled[MAXPLAYERS + 1];
bool g_bAlert[MAXPLAYERS + 1];

//Hooks events and any other required information
public void OnPluginStart()
{
	LoadTranslations("hitsounds.phrases");

	RegConsoleCmd("sm_hs", Cmd_HitsoundToggle);			//]
	RegConsoleCmd("sm_hitsound", Cmd_HitsoundToggle);	//] For client ease of use
	RegConsoleCmd("sm_hitsounds", Cmd_HitsoundToggle);	//]

	g_hCookieDefaultSet = RegClientCookie("default_cookie", "Sets Hitsounds to true on client first connect", CookieAccess_Private);
	g_hHitsoundUserPreference = RegClientCookie("hitsound_cookie", "Gets if the user wants hitsounds enabled", CookieAccess_Private);

	HookEvent("player_hurt", Event_PlayerHurt);
}

//Gets the clients cookie
public void OnClientCookiesCached(int client)
{
	char strCookie[4];

	GetClientCookie(client, g_hCookieDefaultSet, strCookie, sizeof(strCookie));
	if(StringToInt(strCookie) == 0)
	{
		SetClientCookie(client, g_hCookieDefaultSet, "1");
		SetClientCookie(client, g_hHitsoundUserPreference, "1");
	}

	GetClientCookie(client, g_hHitsoundUserPreference, strCookie, sizeof(strCookie));
	g_bEnabled[client] = view_as<bool>(StringToInt(strCookie));
}


public void OnClientPutInServer(int client)
{
	CreateTimer(3.0, join_message, client);
}

public Action join_message(Handle timer, any client)
{
	if(IsClientInGame(client))
	{
		CPrintToChat(client, "%t", "Join_Message");
	}
}

//On the command find if the user has hitsounds enabled and changes the value to true/false
public Action Cmd_HitsoundToggle(int client, int args)
{
	g_bEnabled[client] = !g_bEnabled[client];
	if (g_bEnabled[client] == true)
		CPrintToChat(client, "%t", "Enabled_Message");
	else
		CPrintToChat(client, "%t", "Disabled_Message");
	if (AreClientCookiesCached(client))
	{
		char sValue[4];
		IntToString(g_bEnabled[client], sValue, 4);
		SetClientCookie(client, g_hHitsoundUserPreference, sValue);
	}
}

public void OnClientDisconnect(int client)
{
	g_bAlert[client] = false;
}

//Hooks when client takes damage and plays sound to attacker
public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(attacker > 0 && g_bEnabled[attacker])
	{
		ClientCommand(attacker, "play */buttons/button15.wav");
	}
}

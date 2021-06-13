#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\flag_shared;
#include scripts\shared\damagefeedback_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\music_shared;
#include scripts\shared\weapons\_weaponobjects;
#include scripts\shared\scene_shared;

#include scripts\zm\_util;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\_zm_bgb_machine;
#include scripts\zm\_zm_zonemgr;
#include scripts\zm\_zm;
#include scripts\zm\_zm_laststand;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_clone;
#include scripts\zm\_zm_pack_a_punch_util;
#include scripts\zm\_zm_hero_weapon;
#include scripts\zm\_zm_lightning_chain;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_stats;
#include scripts\zm\_zm_powerup_carpenter;
#include scripts\zm\_zm_powerup_nuke;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_blockers;
#include scripts\zm\_zm_equipment;
#include scripts\zm\_zm_pack_a_punch_util;
#include scripts\zm\_zm_net;
#include scripts\zm\aats\_zm_aat_blast_furnace;
#include scripts\zm\aats\_zm_aat_thunder_wall;
#include scripts\zm\aats\_zm_aat_fire_works;
#include scripts\zm\bgbs\_zm_bgb_round_robbin;
#include scripts\zm\bgbs\_zm_bgb_anywhere_but_here;
#include scripts\zm\bgbs\_zm_bgb_fear_in_headlights;
#include scripts\zm\bgbs\_zm_bgb_pop_shocks;
#include scripts\zm\bgbs\_zm_bgb_killing_time;
#include scripts\zm\bgbs\_zm_bgb_idle_eyes;
#include scripts\zm\bgbs\_zm_bgb_mind_blown;
#include scripts\zm\bgbs\_zm_bgb_disorderly_combat;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\gametypes\_hud_message;
#include scripts\zm\gametypes\_globallogic;

//required
#namespace serious;

//required
autoexec __init__system__()
{
	system::register("serious", ::__init__, undefined, undefined);
}

//required
__init__()
{
	callback::on_start_gametype(::init);
	callback::on_connect(::on_player_connect);
	callback::on_spawned(::on_player_spawned);
	callback::on_disconnect(::on_player_disconnect);
}
#define WAGER_MIN_LEVEL = 1;
#define WAGER_MAX_LEVEL = 6;
#define WAGER_GM1_GG_TIME = 10;

init_wager_totems()
{
    add_wager_tier(1, "Challenger I",   2.0);
    add_wager_tier(2, "Challenger II",  3.0);
    add_wager_tier(3, "Expert I",       4.0);
    add_wager_tier(4, "Expert II",      5.0);
    add_wager_tier(5, "Master",         10.0);
    add_wager_tier(6, "Grandmaster I",  10.0);

    add_wager_modifier(1, "earn fewer points from zombies",                                                                                                                         serious::wager_zm_points);
    add_wager_modifier(1, "take more damage from zombies",                                                                                                                          serious::wager_zm_incoming_damage);
    add_wager_modifier(1, "deal less damage to zombies",                                                                                                                            serious::wager_zm_outgoing_damage);
    add_wager_modifier(2, "earn fewer points from enemy players",                                                                                                                   serious::wager_pvp_points);
    add_wager_modifier(2, "take more damage from enemy players",                                                                                                                    serious::wager_pvp_incoming_damage);
    add_wager_modifier(2, "deal less damage to enemy players",                                                                                                                      serious::wager_pvp_outgoing_damage);
    add_wager_modifier(3, "forfeit the ability to purchase gobblegums",                                                                                                             serious::wager_bgb_pack,                serious::gums_present);
    add_wager_modifier(3, "forfeit a weapon slot (keep current weapon)",                                                                                                            serious::wager_weapon_slot);
    add_wager_modifier(3, "forfeit the ability to use grenades, tacticals, and specialist weapons",                                                                                 serious::wager_weapon_types);
    add_wager_modifier(4, "inflict no melee damage to enemy players",                                                                                                               serious::wager_pvp_melee_damage);
    add_wager_modifier(4, "forfeit the ability to grab powerups",                                                                                                                   serious::wager_powerups);
    // add_wager_modifier(4, "take 100 points of damage per second while sprinting",                                                                                                serious::wager_sprinting);
    add_wager_modifier(4, "forfeit the ability to slide",                                                                                                                           serious::wager_sliding);
    add_wager_modifier(5, "significantly increase the amount of points required for you to win.\nYou will take double damage from players while above the normal winning score.",   serious::wager_win);
    add_wager_modifier(6, "be forced to take a copy of any weapon rolled from the box",                                                                                             serious::wager_box_options,             serious::boxes_present,     "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");
    add_wager_modifier(6, "acquire a new weapon after each kill.\nLimited to once per " + WAGER_GM1_GG_TIME + " seconds",                                                           serious::wager_gun_game,                undefined,                  "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");
    add_wager_modifier(6, "acquire a new set of weapons each round",                                                                                                                serious::wager_loadout_rounds,          undefined,                  "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");


    // selects random modifiers for this game
    for(i = WAGER_MIN_LEVEL; i <= WAGER_MAX_LEVEL; i++)
    {
        if(!isdefined(level.wager_modifiers[i]) || !level.wager_modifiers[i].size) continue;
        n_index = randomint(level.wager_modifiers[i].size);
        s_tier = get_wager_tier(i);
        if(!isdefined(s_tier)) continue;
        s_tier.modifier = level.wager_modifiers[i][n_index];
    }
}

add_wager_tier(tier, text, bonus_currency)
{
    if(!isdefined(level.wager_tiers))
    {
        level.wager_tiers = [];
    }
    s_tier = spawnstruct();
    s_tier.text = text;
    s_tier.bonus_currency = bonus_currency;
    level.wager_tiers[tier] = s_tier;
    return s_tier;
}

get_wager_tier(tier = 0)
{
    return level.wager_tiers[tier];
}

add_wager_modifier(tier, text, func_accepted, func_validate, override_bonus)
{
    if(isdefined(func_validate) && !(level [[func_validate]]()))
    {
        return;
    }
    if(!isdefined(level.wager_modifiers))
    {
        level.wager_modifiers = [];
    }
    if(!isdefined(level.wager_modifiers[tier]))
    {
        level.wager_modifiers[tier] = [];
    }
    a_modifiers = level.wager_modifiers[tier];
    s_modifier = spawnstruct();
    s_modifier.tier = tier;
    s_modifier.text = text;
    s_modifier.func_accepted = func_accepted;
    s_modifier.override_bonus = override_bonus;
    a_modifiers[a_modifiers.size] = s_modifier;
    return s_modifier;
}

make_wager_text(tier = 1)
{
    s_tier = get_wager_tier(tier);
    if(!isdefined(s_tier) || !isdefined(s_tier.modifier)) 
    {
        if(IS_DEBUG) return "unknown tier: " + tier;
        return "";
    }
    s_text = "[^2" + s_tier.text + "^7] Hold ^3&&1 ^7to " + s_tier.modifier.text;
    if(isdefined(s_tier.modifier.override_bonus))
    {
        s_text += "\n" + s_tier.modifier.override_bonus;
    }
    else
    {
        s_text += "\nGrants more xp and vials. Makes elo harder to lose, and easier to gain.";
    }
    return s_text;
}

spawn_wager_totem(location, angles, owner)
{
    if(isdefined(owner.wager_totem) || level.round_number > WAGER_COMMIT_ROUND) return;
    wager_totem = create_wager_totem(location, angles, owner);
    wager_totem endon("wager_totem_exit");
    wager_totem endon("death");
    owner.wager_totem = wager_totem;
    wager_totem thread wager_totem_cleanup(owner);
    if(isdefined(owner.wager_tier))
    {
        wager_totem.wager_level = owner.wager_tier + 1;
    }
    else
    {
        wager_totem.wager_level = WAGER_MIN_LEVEL;
    }
    stub = wager_totem zm_unitrigger::create_unitrigger("", 128, serious::wager_visibility_check, serious::wager_trigger_think, "unitrigger_radius_use");
    zm_unitrigger::unitrigger_force_per_player_triggers(stub, true);
    stub.totem = wager_totem;
    wager_totem.trig = stub;
    owner thread watch_totem_respawn(wager_totem);
    while(level.round_number <= WAGER_COMMIT_ROUND)
    {
        level waittill("wager_check");
    }
    wager_totem thread wager_totem_exit();
}

watch_totem_respawn(wager_totem)
{
    self endon("disconnect");
    wager_totem endon("death");
    self waittill("bled_out");
    level thread kill_wager_totem(self);
}

kill_wager_totem(owner)
{
    if(!isdefined(owner.wager_totem)) return;
    wager_totem = owner.wager_totem;
    wager_totem thread wager_totem_exit();
    owner.wager_totem = undefined;
}

create_wager_totem(location, angles, owner)
{
    w_knife = getweapon("shotgun_pump");
    s_totem = spawnstruct();
    s_totem.challenge_playing = false;
    s_totem.owner = owner;
    s_totem.origin = location + (0,0,20);
    s_totem.angles = angles;
    s_totem.tag_origin = util::spawn_model("tag_origin", location + (0,0,55), (0,0,0));
    s_totem.tag_origin thread rotate_until_death();
    s_totem.skull = util::spawn_model("p7_zm_power_up_insta_kill", location + (0,0,55), (0,0,0));
    s_totem.skull enableLinkTo();
    s_totem.skull SetInvisibleToAll();
    s_totem.skull SetVisibleToPlayer(owner);
    s_totem.skull clientfield::set("powerup_fx", 4);
    s_totem.skull linkTo(s_totem.tag_origin);
    s_totem.skull playloopsound("zmb_spawn_powerup_loop");
    s_totem.l_shotgun = wager_make_weapon(location + (-12,0,40), (-65,180,0), w_knife, owner getbuildkitweaponoptions(w_knife, 15), owner);
    s_totem.l_shotgun setscale(1.25);
    s_totem.l_shotgun linkTo(s_totem.tag_origin, "tag_origin", (-12,0,-15), (-65,180,0));
    s_totem.r_shotgun = wager_make_weapon(location + (12,0,40), (-65,0,0), w_knife, owner getbuildkitweaponoptions(w_knife, 15), owner);
    s_totem.r_shotgun setscale(1.25);
    s_totem.r_shotgun linkTo(s_totem.tag_origin, "tag_origin", (12,0,-15), (-65,0,0));
    s_totem thread wager_await_accept_challenge();
    return s_totem;
}

wager_await_accept_challenge()
{
    self.owner endon("disconnect");
    self endon("death");
    self endon("wager_totem_exit");
    while(true)
    {
        self waittill("wager_challenge_accepted", tier);
        playsoundatposition("zmb_hellhound_spawn", self.origin);
        self.challenge_playing = true;
        self.l_shotgun thread wager_scene_shotgun_fire(self.owner);
        self.r_shotgun thread wager_scene_shotgun_fire(self.owner);
        self.tag_origin thread wager_scene_spinfast();
        self.tag_origin thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "tag_origin", 5);
        Earthquake(0.5, 3.0, self.origin, 256);
        wait 4.75;
        self.challenge_playing = false;
        self.l_shotgun notify("stop_shooting");
        self.r_shotgun notify("stop_shooting");
        self notify("scene_done");
    }
}

wager_scene_shotgun_fire(owner)
{
    self endon("death");
    self endon("stop_shooting");
    while(true)
    {
        magicbullet(self.weapon, self gettagorigin("tag_flash"), self gettagorigin("tag_flash") + vectorscale(anglestoforward(self.angles), 1000), self);
        wait 0.15;
    }
}

wager_scene_spinfast(n_spins = 10)
{
    self notify("wager_challenge_spin");
    self endon("death");
    while(n_spins > 0)
    {
        self rotateYaw(self.angles[2] + 360, 0.5, 0, 0);
        wait 0.45;
        n_spins--;
    }
    self thread rotate_until_death();
}

rotate_until_death()
{
    self endon("death");
    self endon("wager_challenge_spin");
    n_duration = 7;
    while(true)
    {
        self rotateYaw(self.angles[2] + 360, n_duration, 0, 0);
        wait n_duration - 0.05;
    }
}

wager_totem_cleanup(owner)
{
    self endon("death");
    self endon("wager_totem_exit");
    level endon("game_ended");
    owner waittill("disconnect");
    self thread wager_totem_exit();
}

wager_totem_exit()
{
    zm_unitrigger::unregister_unitrigger(self.s_unitrigger);
    wait 2;
    self notify("wager_totem_exit");
    self.challenge_playing = false;
    self.l_shotgun notify("stop_shooting");
    self.r_shotgun notify("stop_shooting");
    self.tag_origin moveTo(self.tag_origin getOrigin() + (0,0,-15), 0.25);
    wait 0.3;
    playfx(level._effect["poltergeist"], self.tag_origin.origin, anglestoup(self.tag_origin.angles), anglestoforward(self.tag_origin.angles));
    playfx(level._effect["lght_marker_flare"], self.tag_origin.origin);
    self.tag_origin moveTo(self.tag_origin getOrigin() + (0,0,5000), 1.5);
    wait 1.5;
    self.skull delete();
    self.l_shotgun delete();
    self.r_shotgun delete();
    self.tag_origin delete();
}

wager_visibility_check(player)
{
    if(!isdefined(self.stub.totem.owner)) return false;
    b_result = true;
    if(self.stub.totem.owner != player)
    {
        return false;
    }
    if(player.sessionstate != "playing")
    {
        return false;
    }
    if(isdefined(self.stub.totem.exiting) && self.stub.totem.exiting) 
    {
        return false;
    }
    if(isdefined(self.stub.totem.challenge_playing) && self.stub.totem.challenge_playing) 
    {
        return false;
    }
    self sethintstring(make_wager_text(self.stub.totem.wager_level));
    return b_result;
}

wager_trigger_think()
{
    totem = self.stub.totem;
    while(true)
    {
        self waittill("trigger", player);
        if(totem.owner != player) continue;
        if(player zm_utility::in_revive_trigger())
		{
			continue;
		}
		if(!zm_utility::is_player_valid(player, false, true))
		{
			continue;
		}
        if(totem.challenge_playing)
        {
            continue;
        }
        self TriggerEnable(false);
        totem thread wager_challenge_accepted(player);
        totem waittill("scene_done");
        self TriggerEnable(true);
    }
}

wager_challenge_accepted(player)
{
    tier = self.wager_level;
    s_tier = get_wager_tier(tier);
    if(!isdefined(s_tier.modifier.func_accepted))
    {
        return;
    }
    player.wager_tier = self.wager_level;
    player thread [[ s_tier.modifier.func_accepted ]]();
    player notify("wager_challenge_accepted");
    playfx(level._effect["teleport_splash"], player.origin);
    player playsound("zmb_bgb_fearinheadlights_start");
    player thread wager_activate_visionset();
    playsoundatposition("zmb_hellhound_bolt", player.origin);
    self notify("wager_challenge_accepted", self.wager_level);
    self.wager_level++;
    if(self.wager_level > WAGER_MAX_LEVEL) 
    {
        self thread wager_totem_exit();
    }
}

wager_activate_visionset()
{
    self notify("wager_activate_visionset");
    self endon("wager_activate_visionset");
    self endon("disconnect");
    visionset_mgr::activate("visionset", "zm_bgb_idle_eyes", self, 0.5, 4.5, 0.5);
	visionset_mgr::activate("overlay", "zm_bgb_idle_eyes", self);
    wait 4.5;
    visionset_mgr::deactivate("visionset", "zm_bgb_idle_eyes", self);
    wait(0.5);
    visionset_mgr::deactivate("overlay", "zm_bgb_idle_eyes", self);
}

wager_zm_points()
{
    self.wager_zm_points_mod = 0.85;
    self.wager_zm_points_drop = 5;
}

wager_zm_outgoing_damage()
{
    self.wager_zm_outgoing_damage = 0.75;
}

wager_zm_incoming_damage()
{
    self.wager_zm_incoming_damage = 1.25;
}

wager_pvp_points()
{
    self.wager_pvp_points_mod = 0.65;
}

wager_pvp_incoming_damage()
{
    self.wager_pvp_incoming_damage = 1.25;
}

wager_pvp_outgoing_damage()
{
    self.wager_pvp_outgoing_damage = 0.75;
}

wager_bgb_pack()
{
    self.var_e610f362 = [];
    self.var_98ba48a2 = [];
    self.wager_bgb_pack = true;
}

wager_weapon_slot()
{
    weapons = self getweaponslistprimaries();
    if(weapons.size > 1)
    {
        arrayremovevalue(weapons, self getCurrentWeapon(), false);
        self takeWeapon(weapons[weapons.size - 1]);
    }
    self.wager_weapon_slot = true;
}

wager_weapon_types()
{
    self endon("disconnect");
    while(true)
    {
        while(self.sessionstate != "playing")
        {
            wait 0.25;
        }
        foreach(weapon in self getweaponslist())
        {
            switch(true)
            {
                case zm_utility::is_hero_weapon(weapon):
                case zm_utility::is_lethal_grenade(weapon):
                case zm_utility::is_tactical_grenade(weapon):
                case zm_utility::is_placeable_mine(weapon):
                    self takeWeapon(weapon);
            }
        }
        self util::waittill_any_timeout(5, "weapon_change", "reload", "weapon_give");
    }
}

wager_pvp_melee_damage()
{
    self.wager_pvp_melee_damage = true;
}

wager_powerups()
{
    self.wager_powerups = true;
}

wager_sprinting()
{
    self endon("disconnect");
    while(true)
    {
        wait 1;
        while(self.sessionstate != "playing")
        {
            wait 0.25;
        }
        if(self issprinting())
        {
            self dodamage(100, self.origin);
        }
    }
}

wager_win()
{
    self.wager_win_dmg_scalar = 2.0;
    self.wager_win_points = int(WIN_NUMPOINTS * 1.5);
}

do_wager_character_effects()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    while(true)
    {
        tier = self.wager_tier;
        if(isdefined(tier))
        {
            if(tier >= 6)
            {
                self thread wager_fx_gm1();
                self thread wager_gm1_rewards();
            }
            if(tier >= 5)
            {
                self thread wager_fx_master();
            }
            if(tier >= 4)
            {
                self wager_fx_expert_ii();
            }
            if(tier >= 3)
            {
                self wager_fx_expert_i();
            }
            if(tier >= 2)
            {
                self wager_fx_challenger_ii();
            }
            if(tier >= 1)
            {
                self thread wager_fx_challenger_i();
            }
        }
        self waittill("wager_challenge_accepted");
    }
}

wager_fx_master()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    if(isdefined(self.wager_master_fx))
    {
        self.wager_master_fx delete();
    }
    self.wager_master_fx = spawn("script_model", self getTagOrigin("j_helmet"));
    self.wager_master_fx thread fx_kill_on_death_or_disconnect(self);
    self.wager_master_fx setmodel("tag_origin");
    self.wager_master_fx enableLinkTo();
    self.wager_master_fx linkTo(self, "j_helmet", (-2,1,0));
    self.wager_master_fx setscale(0.5);
    self.wager_master_fx SetInvisibleToPlayer(self, true);
    while(true)
    {
        playFXOnTag(level._effect["character_fire_death_torso"], self.wager_master_fx, "tag_origin");
        wait 10;
    }
}

fx_kill_on_death_or_disconnect(player)
{
    self endon("death");
    player waittill("disconnect");
    self delete();
}


wager_fx_expert_ii()
{
    if(isdefined(self.wager_fx_expert_ii))
    {
        self.wager_fx_expert_ii delete();
    }
    self.wager_fx_expert_ii = spawn("script_model", self getTagOrigin("j_helmet"));
    self.wager_fx_expert_ii thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_expert_ii setmodel("p7_zm_power_up_insta_kill");
    self.wager_fx_expert_ii enableLinkTo();
    self.wager_fx_expert_ii setscale(0.425);
    self.wager_fx_expert_ii linkto(self, "j_helmet", (-5,1,0), (-90,-30,180));
    self.wager_fx_expert_ii SetInvisibleToPlayer(self, true);
}

wager_fx_expert_i()
{
    if(isdefined(self.wager_fx_expert_i))
    {
        foreach(ent in self.wager_fx_expert_i)
            ent delete();
    }
    self.wager_fx_expert_i = [];

    //j_spineupper
    bowie_1 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_2 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_3 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_4 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_5 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_6 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_7 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_8 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_1 linkto(self, "j_spineupper", (12,-5,0), (70,0,0));
    bowie_2 linkto(self, "j_spineupper", (12,-5,0), (-70,180,0));
    bowie_3 linkto(self, "j_spineupper", (12,-5,0), (-25,180,0));
    bowie_4 linkto(self, "j_spineupper", (12,-5,0), (155,0,0));
    bowie_5 linkto(self, "j_spineupper", (12,-5,0), (25,0,0));
    bowie_6 linkto(self, "j_spineupper", (12,-5,0), (-155,180,0));
    bowie_7 linkto(self, "j_spineupper", (12,-5,0), (110,0,0));
    bowie_8 linkto(self, "j_spineupper", (12,-5,0), (-110,180,0));
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_1;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_2;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_3;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_4;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_5;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_6;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_7;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_8;
}

wager_make_bowie(location)
{
    w_knife = getweapon("bowie_knife");
    mdl = spawn("script_model", location);
    mdl useweaponmodel(w_knife, w_knife.worldmodel, self getbuildkitweaponoptions(w_knife, 15));
    mdl enableLinkTo();
    mdl setscale(1.1);
    mdl SetInvisibleToPlayer(self, true);
    mdl thread fx_kill_on_death_or_disconnect(self);
    return mdl;
}

wager_fx_challenger_ii()
{
    if(isdefined(self.wager_fx_challenger_ii))
    {
        self.wager_fx_challenger_ii delete();
    }
    self.wager_fx_challenger_ii = spawn("script_model", self getTagOrigin("tag_flash"));
    self.wager_fx_challenger_ii thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_challenger_ii setmodel("p7_zm_power_up_nuke");
    self.wager_fx_challenger_ii enableLinkTo();
    self.wager_fx_challenger_ii setscale(0.2);
    self.wager_fx_challenger_ii linkto(self, "tag_flash", (4,0,0), (0,0,0));
    self.wager_fx_challenger_ii SetInvisibleToPlayer(self, true);
}

wager_show_self_items()
{
    if(isdefined(self.wager_fx_challenger_ii))
    {
        self.wager_fx_challenger_ii SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_challenger_i))
    {
        self.wager_fx_challenger_i SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_expert_i))
    {
        foreach(obj in self.wager_fx_expert_i)
            obj SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_expert_ii))
    {
        self.wager_fx_expert_ii SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_master_fx))
    {
        self.wager_master_fx SetInvisibleToPlayer(self, false);
    }
}

wager_fx_challenger_i()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    if(isdefined(self.wager_fx_challenger_i))
    {
        self.wager_fx_challenger_i delete();
    }
    self.wager_fx_challenger_i = spawn("script_model", self getTagOrigin("j_eyeball_le"));
    self.wager_fx_challenger_i thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_challenger_i setmodel("tag_origin");
    self.wager_fx_challenger_i enableLinkTo();
    self.wager_fx_challenger_i linkTo(self, "j_eyeball_le", (0,-1,0), (0,0,0));
    self.wager_fx_challenger_i SetInvisibleToPlayer(self, true);
    playFXOnTag(level._effect["eye_glow"], self.wager_fx_challenger_i, "tag_origin");
}

#define GOLD_INDEX = 15;
wager_fx_gm1()
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");
    self.wager_fx_gm1 = true;
    list_tracked_inventory = [];
    foreach(weapon in self getWeaponsListPrimaries())
    {
        if(isdefined(weapon))
        {
            self wager_force_camo(weapon, GOLD_INDEX, weapon == (self getCurrentWeapon()));
        }
    }
    list_tracked_inventory = arraycopy(self getWeaponsListPrimaries());
    while(true)
    {
        // saves us from death machine bricks and stuff
        self bgb::function_378bff5d();
        self zm_bgb_disorderly_combat::function_8a5ef15f();
        foreach(weapon in self getWeaponsListPrimaries())
        {
            if(!isinarray(list_tracked_inventory, weapon))
            {
                self wager_force_camo(weapon, GOLD_INDEX, weapon == (self getCurrentWeapon()));
            }
        }
        list_tracked_inventory = arraycopy(self getWeaponsListPrimaries());
        self waittill("weapon_change");
    }
}

wager_force_camo(weapon, camo = 0, swap = true)
{
    if(!isdefined(weapon)) return;
    weapon_options = self CalcWeaponOptions(camo, 0, 0);
    acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, self zm_weapons::is_weapon_upgraded(weapon));
    ammo_clip = self GetWeaponAmmoClip(weapon);
    ammo_stock = self GetWeaponAmmoStock(weapon);
    self takeweapon(weapon, 1);
    self GiveWeapon(weapon, weapon_options, acvi);
    if(swap)
    {
        self switchtoweaponimmediate(weapon);
    }
    self SetWeaponAmmoClip(weapon, ammo_clip);
    self SetWeaponAmmoStock(weapon, ammo_stock);
}

wager_gm1_rewards()
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");
    save_bullet_array = [];
    self setperk("specialty_stalker");
    self.wager_gm1_rewards = true;
    while(true)
    {
        self waittill("weapon_fired", weapon);
        if(!isdefined(weapon)) continue;
        if(!isdefined(save_bullet_array[weapon]))
        {
            save_bullet_array[weapon] = false;
        }
        save_bullet_array[weapon] = !save_bullet_array[weapon];
        if(save_bullet_array[weapon])
        {
            self SetWeaponAmmoClip(weapon, self GetWeaponAmmoClip(weapon) + 1);
        }
    }
}

wager_make_weapon(location, angles, weapon, options, owner)
{
    mdl = spawn("script_model", location);
    mdl.angles = angles;
    mdl.weapon = weapon;
    mdl useweaponmodel(weapon, weapon.worldmodel, options);
    mdl enableLinkTo();
    mdl thread fx_kill_on_death_or_disconnect(owner);
    mdl SetInvisibleToAll();
    mdl SetVisibleToPlayer(owner);
    return mdl;
}

wager_make_icon()
{
    tag = spawn("script_model", self getTagOrigin("j_spineupper"));
    tag setmodel("tag_origin");
    bowie_1 = self wager_make_bowie(tag.origin);
    bowie_2 = self wager_make_bowie(tag.origin);
    bowie_3 = self wager_make_bowie(tag.origin);
    bowie_4 = self wager_make_bowie(tag.origin);
    bowie_5 = self wager_make_bowie(tag.origin);
    bowie_6 = self wager_make_bowie(tag.origin);
    bowie_7 = self wager_make_bowie(tag.origin);
    bowie_8 = self wager_make_bowie(tag.origin);
    bowie_1 linkto(tag, "tag_origin", (0,0,0), (70,0,0));
    bowie_2 linkto(tag, "tag_origin", (0,0,0), (-70,180,0));
    bowie_3 linkto(tag, "tag_origin", (0,0,0), (-25,180,0));
    bowie_4 linkto(tag, "tag_origin", (0,0,0), (155,0,0));
    bowie_5 linkto(tag, "tag_origin", (0,0,0), (25,0,0));
    bowie_6 linkto(tag, "tag_origin", (0,0,0), (-155,180,0));
    bowie_7 linkto(tag, "tag_origin", (0,0,0), (110,0,0));
    bowie_8 linkto(tag, "tag_origin", (0,0,0), (-110,180,0));

    bowie_1 SetInvisibleToPlayer(self, false);
    bowie_2 SetInvisibleToPlayer(self, false);
    bowie_3 SetInvisibleToPlayer(self, false);
    bowie_4 SetInvisibleToPlayer(self, false);
    bowie_5 SetInvisibleToPlayer(self, false);
    bowie_6 SetInvisibleToPlayer(self, false);
    bowie_7 SetInvisibleToPlayer(self, false);
    bowie_8 SetInvisibleToPlayer(self, false);

    bowie_1 setscale(0.75);
    bowie_2 setscale(0.75);
    bowie_3 setscale(0.75);
    bowie_4 setscale(0.75);
    bowie_5 setscale(0.75);
    bowie_6 setscale(0.75);
    bowie_7 setscale(0.75);
    bowie_8 setscale(0.75);

    wager_fx_expert_ii = spawn("script_model", tag.origin);
    wager_fx_expert_ii setmodel("p7_zm_power_up_insta_kill");
    wager_fx_expert_ii enableLinkTo();
    wager_fx_expert_ii setscale(0.425);
    wager_fx_expert_ii linkto(tag, "tag_origin", (-1,0,0), (0,0,0));

    tag2 = spawn("script_model", self getTagOrigin("j_spineupper"));
    tag2 setmodel("tag_origin");
    tag2 enableLinkTo();
    tag2 linkto(tag, "tag_origin", (-2.5,-4,-1), (0,180,0));
    playFXOnTag(level._effect["eye_glow"], tag2, "tag_origin");
}

wager_sliding()
{
    self endon("disconnect");
    while(true)
    {
        if(self.sessionstate != "playing")
        {
            wait 0.25;
            continue;
        }
        self AllowSlide(false);
        wait 1;
    }
}

wager_box_options()
{
    self.wager_box_options = true;
}

boxes_present()
{
    return isdefined(level.chests) && level.chests.size;
}

wager_func_magicbox_weapon_spawned(box_weapon)
{
    foreach(player in level.players)
    {
        if(player.sessionstate != "playing")
        {
            continue;
        }
        if(!isdefined(player.wager_box_options) || !player.wager_box_options)
        {
            continue;
        }
        player thread wager_transfer_weapon_give(box_weapon);
    }
    if(isdefined(level._func_magicbox_weapon_spawned))
    {
        self [[level._func_magicbox_weapon_spawned]](box_weapon);
    }
}

// awards a player the weapon provided given the same quality and AAT of their current weapon.
wager_transfer_weapon_give(weapon)
{
    self endon("disconnect");
    self endon("bled_out");
    if(!isdefined(weapon) || weapon == level.weaponnone || (isdefined(level.zombie_powerup_weapon["minigun"]) && level.zombie_powerup_weapon["minigun"] == weapon)) return;
    if(!zm_utility::is_player_valid(self)) return;

    self bgb::function_378bff5d();
    self zm_bgb_disorderly_combat::function_8a5ef15f();
    if(!self zm_magicbox::can_buy_weapon()) return;
    while(self isMeleeing())
    {
        wait 0.25;
    }

    cw = zm_weapons::get_nonalternate_weapon(self getCurrentWeapon());
    if(zm_weapons::is_weapon_upgraded(cw))
    {
        weapon_ug = zm_weapons::get_upgrade_weapon(weapon);
        if(isdefined(weapon_ug))
        {
            weapon = weapon_ug;
        }
    }

    // swap aat from old weapon to new weapon
    if(isdefined(cw) && isdefined(self.AAT[cw]))
    {
        current_aat = self.AAT[cw];
        self.AAT[cw] = undefined;
    }

    switch(true)
    {
        case zm_utility::is_hero_weapon(weapon):
            self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
            self zm_utility::set_player_hero_weapon(weapon);
        break;
        case zm_utility::is_melee_weapon(weapon):
        case zm_utility::is_lethal_grenade(weapon):
        case zm_utility::is_tactical_grenade(weapon):
        case zm_utility::is_placeable_mine(weapon):
        case zm_utility::is_offhand_weapon(weapon):
            self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
        break;
        default:
            primaryweapons = self getweaponslistprimaries();
            weapon_limit = zm_utility::get_player_weapon_limit(self);
            if(primaryweapons.size >= weapon_limit && !zm_utility::is_offhand_weapon(cw))
            {
                self takeweapon(cw);
            }
            weapon = self zm_weapons::give_build_kit_weapon(weapon);
            self switchToWeapon(weapon);
            self givestartammo(weapon);
            wait 0.1;
            GiveAAT(self, current_aat, false, weapon);
        break;
    }
}

wager_gun_game()
{
    self.wager_gun_game = true;
}

wager_gg_kill(eAttacker)
{
    if(!isdefined(eAttacker) || !isplayer(eAttacker)) return;
    if(eAttacker.sessionstate != "playing") return;
    if(!isdefined(eAttacker.wager_gun_game) || !eAttacker.wager_gun_game) return;
    eAttacker thread wager_gg_swap();
}

wager_gg_swap()
{
    self endon("disconnect");
    self endon("bled_out");

    if(!isdefined(self.wager_gg_last))
    {
        self.wager_gg_last = gettime() - (WAGER_GM1_GG_TIME * 1000);
    }
    if((gettime() - self.wager_gg_last) < (WAGER_GM1_GG_TIME * 1000))
    {
        return;
    }

    cw = zm_weapons::get_nonalternate_weapon(self getCurrentWeapon());
    switch(true)
    {
        case zm_utility::is_hero_weapon(cw):
        case zm_utility::is_melee_weapon(cw):
        case zm_utility::is_lethal_grenade(cw):
        case zm_utility::is_tactical_grenade(cw):
        case zm_utility::is_placeable_mine(cw):
        case zm_utility::is_offhand_weapon(cw):
            return;
    }

    self.wager_gg_last = gettime();

    // swap aat from old weapon to new weapon
    if(isdefined(cw) && isdefined(self.AAT[cw]))
    {
        current_aat = self.AAT[cw];
        self.AAT[cw] = undefined;
    }

    is_ug = zm_weapons::is_weapon_upgraded(cw);
    w_weapon = self wager_get_rand_weap();

    if(is_ug)
    {
        weapon_ug = zm_weapons::get_upgrade_weapon(w_weapon);
        if(isdefined(weapon_ug))
        {
            w_weapon = weapon_ug;
        }
    }

    self bgb::function_378bff5d();
    self zm_bgb_disorderly_combat::function_8a5ef15f();
    while(self isMeleeing())
    {
        wait 0.25;
    }
    primaryweapons = self getweaponslistprimaries();
    weapon_limit = zm_utility::get_player_weapon_limit(self);
    if(primaryweapons.size >= weapon_limit && !zm_utility::is_offhand_weapon(cw))
    {
        self takeweapon(cw);
    }
    self playsoundtoplayer("zmb_bgb_disorderly_weap_switch", self);
    w_weapon = self zm_weapons::give_build_kit_weapon(w_weapon);
    self switchtoweaponimmediate(w_weapon);
    self givestartammo(w_weapon);
    wait 0.1;
    GiveAAT(self, current_aat, false, w_weapon);
}

gums_present()
{
    return isdefined(level.var_5081bd63) && isdefined(level.var_5081bd63.size) && level.var_5081bd63.size;
}

wager_loadout_rounds()
{
    self.wager_loadout_rounds = true;
}

wager_loadout_rounds_activate()
{
    list = self getweaponslistprimaries();
    aat_cache = [];
    upgraded_cache = [];
    weapon_limit = zm_utility::get_player_weapon_limit(self);
    index = 0;
    foreach(cw in list)
    {
        // swap aat from old weapon to new weapon
        if(isdefined(cw) && isdefined(self.AAT[cw]))
        {
            upgraded_cache[index] = self.AAT[cw];
            self.AAT[cw] = undefined;
        }

        is_ug = zm_weapons::is_weapon_upgraded(cw);
        upgraded_cache[index] = is_ug;
        self takeWeapon(cw);
        index++;
    }

    for(i = 0; i < weapon_limit; i++)
    {
        w_weapon = self wager_get_rand_weap();
        if(isdefined(upgraded_cache[i]) && upgraded_cache[i])
        {
            weapon_ug = zm_weapons::get_upgrade_weapon(w_weapon);
            if(isdefined(weapon_ug))
            {
                w_weapon = weapon_ug;
            }
        }
        w_weapon = self zm_weapons::give_build_kit_weapon(w_weapon);
        self switchtoweaponimmediate(w_weapon);
        self givestartammo(w_weapon);
        if(isdefined(aat_cache[i]))
        {
            wait 0.1;
            GiveAAT(self, aat_cache[i], false, w_weapon);
        }
    }        
}

wager_get_rand_weap()
{
    weapons = arraycopy(level.var_8fcdc919);
    w_weapon = array::random(weapons);
    while(self zm_weapons::has_weapon_or_upgrade(w_weapon))
    {
        weapons = array::pop_front(weapons, false);
        w_weapon = array::random(weapons);
    }
    return w_weapon;
}
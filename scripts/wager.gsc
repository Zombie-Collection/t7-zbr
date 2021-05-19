#define WAGER_MIN_LEVEL = 1;
#define WAGER_MAX_LEVEL = 5;

init_wager_totems()
{
    add_wager_tier(1, "Challenger I",   2.0);
    add_wager_tier(2, "Challenger II",  3.0);
    add_wager_tier(3, "Expert I",       4.0);
    add_wager_tier(4, "Expert II",      5.0);
    add_wager_tier(5, "Master",         10.0);

    add_wager_modifier(1, "earn fewer points from zombies",                                                                             serious::wager_zm_points);
    add_wager_modifier(1, "take more damage from zombies",                                                                              serious::wager_zm_incoming_damage);
    add_wager_modifier(1, "deal less damage to zombies",                                                                                serious::wager_zm_outgoing_damage);
    add_wager_modifier(2, "earn fewer points from enemy players",                                                                       serious::wager_pvp_points);
    add_wager_modifier(2, "take more damage from enemy players",                                                                        serious::wager_pvp_incoming_damage);
    add_wager_modifier(2, "deal less damage to enemy players",                                                                          serious::wager_pvp_outgoing_damage);
    add_wager_modifier(3, "forfeit the ability to purchase gobblegums",                                                                 serious::wager_bgb_pack);
    add_wager_modifier(3, "forfeit a weapon slot (keep current weapon)",                                                                serious::wager_weapon_slot);
    add_wager_modifier(3, "forfeit the ability to use grenades, tacticals, and specialist weapons",                                     serious::wager_weapon_types);
    add_wager_modifier(4, "inflict no melee damage to enemy players",                                                                   serious::wager_pvp_melee_damage);
    add_wager_modifier(4, "forfeit the ability to grab powerups",                                                                       serious::wager_powerups);
    // add_wager_modifier(4, "take 100 points of damage per second while sprinting",                                                       serious::wager_sprinting);
    add_wager_modifier(4, "forfeit the ability to slide",                                                                               serious::wager_sliding);
    add_wager_modifier(5, "significantly increase the amount of points required for you to win.\nYou will take double damage from players while above the normal winning score.",   serious::wager_win);

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

add_wager_modifier(tier, text, func_accepted)
{
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
    s_text += "\nGrants more xp and vials. Makes elo harder to lose, and easier to gain.";
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
    self.wager_zm_points_mod = 0.75;
    self.wager_zm_points_drop = 4;
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
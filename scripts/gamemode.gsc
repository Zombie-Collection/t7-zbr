initgamemode()
{
    if(isdefined(level.game_mode_init) && level.game_mode_init) return;

    setup_environment();
    apply_aat_changes();
    apply_bgb_changes();
    apply_powerup_changes();
    apply_trap_changes();
    init_wager_totems();

    level thread zm_island_initial_fix();
    level thread octobomb_watcher();
    level thread PointAddedDispatcher();

    foreach(box in level.chests) 
    {
        box thread one_box_hit_monitor();
        box.unitrigger_stub.prompt_and_visibility_func = serious::stealable_box_vis_func;
    }

    vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
	if(vending_weapon_upgrade_trigger.size >= 1)
	{
		array::thread_all(vending_weapon_upgrade_trigger, serious::stealable_vending_weapon_upgrade);
	}

    initdev();

    if(IS_DEBUG && DEBUG_NO_GM_THREADED) return;
    level thread initgamemodethreaded();
}

initgamemodethreaded()
{
    level flag::wait_till("begin_spawning");
    level.limited_weapons = []; // clear weapon limits so all players can obtain what they want
    level.zombie_init_done = ::Event_ZombieInitDone;
    level thread zm_island_fix();
    level thread zm_round_failsafe();

    zm_moon_fixes();
    enable_power();
    apply_perk_changes();
    apply_door_prices();
    setup_weapons();

    rand = randomIntRange(0, 2);
    high = level.script == "zm_zod" ? 3 : 1;
    if(level.script == "zm_castle") high = 0;
    apply_lighting(int(rand * high));

    // start the first game mode round
    level.round_number = (IS_DEBUG ? DEBUG_START_ROUND : GM_START_ROUND);
    SetRoundsPlayed(level.round_number);
    world.var_48b0db18 = level.round_number ^ 115;
    level.skip_alive_at_round_end_xp = true;
    thread zm_bgb_round_robbin::function_8824774d(level.round_number + 1);
}

setup_weapons()
{
    if(isdefined(level.weaponriotshield) && level.weaponriotshield.name == "dragonshield")
    {
        level._riotshield_melee_power = level.riotshield_melee_power;
        level.riotshield_melee_power = ::dragon_shield_melee;
    }
    if(isdefined(getweapon("hero_gravityspikes_melee")) && isdefined(level._hero_weapons[getweapon("hero_gravityspikes_melee")].wield_fn))
    {
        level.old_gs_wield_fn = level._hero_weapons[getweapon("hero_gravityspikes_melee")].wield_fn;
        level.old_gs_unwield_fn = level._hero_weapons[getweapon("hero_gravityspikes_melee")].unwield_fn;
        level._hero_weapons[getweapon("hero_gravityspikes_melee")].wield_fn = ::wield_gravityspikes;
        level._hero_weapons[getweapon("hero_gravityspikes_melee")].unwield_fn = ::unwield_gravityspikes;
    }
    custom_weapon_init();
}

apply_lighting(setting = 0)
{
    level util::set_lighting_state(setting);
    if(isdefined(level.var_1b3f87f7))
	{
		level.var_1b3f87f7 delete();
	}
	level.var_1b3f87f7 = createstreamerhint(level.activeplayers[0].origin, 1, !setting);
	level.var_1b3f87f7 setlightingonly(1);
}

setup_environment()
{
    #region Bool
    level.b_allow_idgun_pap = true;
    level.force_solo_quick_revive = true;
    level.pack_a_punch.grabbable_by_anyone = true;
    level.wasp_rounds_enabled = false;  // fix SOE crash
    level.raps_rounds_enabled = false;  // fix SOE crash
    level.var_1821d194 = true; // zm_island anti-spider fix
    level.drawfriend = false;
    level.custom_firesale_box_leave = false;
    #endregion

    #region Scalar
    level.perk_purchase_limit = 99;
    level._random_zombie_perk_cost = 1500;
    level.chest_moves = 1; // allows firesales to be dropped by the game

    level.next_wasp_round = 999;  // fix SOE crash
    level.n_next_raps_round = 999;  // fix SOE crash
    level.solo_lives_given = -9999;
    level.max_solo_lives = 9999;
    level._race_team_double_points = undefined;
    define_zombie_vars();
    #endregion

    #region Callbacks and Overrides
    level._callbackActorDamage = level.callbackActorDamage;
    level._overridePlayerDamage = level.overridePlayerDamage;
    level._callbackPlayerLastStand = level.callbackPlayerLastStand;
    level.__black_hole_bomb_poi_override = level._black_hole_bomb_poi_override;
    level.callbackActorDamage = serious::_actor_damage_override_wrapper;
    level.overridePlayerDamage = serious::_player_damage_override;
    level.callbackPlayerLastStand = serious::PlayerDownedCallback;
    level.deathcard_spawn_func = serious::PlayerDiedCallback;
    level._check_quickrevive_hotjoin = level.check_quickrevive_hotjoin;
    level.check_quickrevive_hotjoin = serious::quick_revive_hook;
    level.custom_spectate_permissions = serious::on_joined_spectator;
    level.custom_game_over_hud_elem = serious::end_game_hud;
    level._black_hole_bomb_poi_override = serious::bhb_hook;
    level.zombie_init_done = serious::Event_ZombieInitDone;
    level.func_get_zombie_spawn_delay = serious::Calc_ZombieSpawnDelay;
    level.grenade_planted = serious::grenade_planted_override;
    level._player_score_override = level.player_score_override;
    level.player_score_override = serious::player_score_override;
    level.get_player_weapon_limit = serious::get_player_weapon_limit;
    
    level._zombiemode_check_firesale_loc_valid_func = serious::check_firesale_valid_loc;
    level.player_intersection_tracker_override = serious::true_one_arg;
    level.player_out_of_playable_area_monitor_callback = serious::nullsub;
    level._game_module_game_end_check = serious::nullsub;

    level.customSpawnLogic = undefined; //fix verruckt
    level.check_valid_spawn_override = undefined; //fix shang
    level.player_too_many_weapons_monitor = serious::nullsub; // fix bs with their weapons logic

    if(level.script != "zm_moon")
        level.zombie_round_change_custom = serious::Event_RoundNext;
    else
        level.round_start_custom_func = serious::Event_RoundNext;
    #endregion

    #region Gamemode Variables
    level.game_mode_init = true;
    level.first_spawn = true;
    level.playing_song = false;

    level.zombieDamageScalar = 1;
    level.gm_zombie_dmg_scalar = 1.0f;
    level.gm_rubber_banding_scalar = 1.0f;
    level.boxCost = 950;
    level.player_weapon_boost = 0;
    level.b_is_zod = (level.script == "zm_zod");
    level.b_is_stalingrad = (level.script == "zm_stalingrad");
    level.winning_musics = ["mus_115_riddle_oneshot_intro", "mus_abra_macabre_intro", "mus_infection_church_intro"];

    // Moon damage adjust for the bhb
    if(isdefined(level.var_453e74a0))
    {
        level.start_vortex_damage_radius = BLACKHOLEBOMB_MIN_DMG_RADIUS;
    }
    #endregion
}

define_zombie_vars()
{
    if(!isdefined(level.zombie_vars["allies"]) || !isarray(level.zombie_vars["allies"]))
        level.zombie_vars["allies"] = [];
    
    for(i = 3; i < 12; i++)
    {
        if(!isdefined(level.zombie_vars["team" + i]) || !isarray(level.zombie_vars["team" + i]))
            level.zombie_vars["team" + i] = [];
        level.zombie_vars["team" + i]["zombie_point_scalar"] = 1;
    }
    level.zombie_vars["allies"]["zombie_point_scalar"] = 1;
    level.zombie_vars["zombie_move_speed_multiplier"] = GM_ZM_SPEED_MULT;
    level.zombie_vars[ "penalty_no_revive" ] = 0;
    level.zombie_vars[ "penalty_died" ] = 0;
    level.zombie_vars[ "penalty_downed" ] = 0;
    level.zombie_vars[ "zombie_between_round_time" ] = GM_BETWEEN_ROUND_DELAY_START;
}

apply_bgb_changes()
{
    // gums with no purpose are just removed from your pack
    blacklist_bgb("zm_bgb_coagulant");
    blacklist_bgb("zm_bgb_arms_grace");
    blacklist_bgb("zm_bgb_phoenix_up");

    level.bgb["zm_bgb_fear_in_headlights"].activation_func = serious::bgb_fith_activate;
    level.bgb["zm_bgb_round_robbin"].activation_func = serious::bgb_rr_activate;
    level.bgb["zm_bgb_pop_shocks"].var_d99aa464 = serious::bgb_ps_actordamage;
    level.bgb["zm_bgb_pop_shocks"].var_bfbb61c1 = serious::bgb_ps_vehicledamage;
    level.bgb["zm_bgb_burned_out"].limit = serious::bgb_burnedout_event;
    level.bgb["zm_bgb_killing_time"].activation_func = serious::bgb_kt_activate;
    level.bgb["zm_bgb_idle_eyes"].activation_func = serious::bgb_idle_eyes_activate;
    level.bgb["zm_bgb_mind_blown"].activation_func = serious::bgb_mind_blown_activate;
    level.bgb["zm_bgb_profit_sharing"].var_e25efdfd = serious::bgb_profit_sharing_override;
    level.bgb["zm_bgb_head_drama"].limit = 1;
    level.bgb["zm_bgb_near_death_experience"].limit = 1; // this is too strong to last several rounds

    level.bgb_in_use = true;
    level.var_6cb6a683 = 99; // remove max gobble gum purchases per round
    level.var_1485dcdc = 1; // multiplier for bgb cost past 1 purchase in a round. set to 1 for hintstring caching stability
    level.var_4824bb2d = serious::player_bgb_buys_1;

    foreach(machine in level.var_5081bd63)
    {
        machine thread OneGobbleOnly();
        if(!isdefined(level.old_bgb_stub_func))
            level.old_bgb_stub_func = machine.unitrigger_stub.prompt_and_visibility_func;
        machine.var_4d6e7e5e = true;
        machine.unitrigger_stub.prompt_and_visibility_func = serious::bgb_visibility_override;
        machine thread bgb_stealable_trigger_check();
    }

    setDvar("scr_firstGumFree", false);
}

apply_aat_changes()
{
    arrayremovevalue(level.zombie_damage_override_callbacks, aat::aat_response, false);
    
    level.aat["zm_aat_dead_wire"].result_func = serious::aat_deadwire;
    level.aat["zm_aat_blast_furnace"].result_func = serious::aat_blast_furnace;
    level.aat["zm_aat_thunder_wall"].result_func = serious::thunderwall_result;
    level.aat["zm_aat_fire_works"].validation_func = serious::fw_validator;
    level.aat["zm_aat_fire_works"].result_func = serious::fw_result;

    arrayremoveindex(level.aat, "zm_aat_turned", true);
}

apply_powerup_changes()
{
    level._custom_powerups["free_perk"].grab_powerup = serious::free_perk_override;
    level._custom_powerups["carpenter"].grab_powerup = serious::carpenter_override;
    level._custom_powerups["nuke"].grab_powerup = serious::nuke_override;
    level.powerup_grab_get_players_override = serious::powerup_grab_get_players_override;
}

apply_perk_changes()
{
    level.zombie_vars["zombie_perk_juggernaut_health"] = undefined; // should make jugg not affect health whatsoever
    level.armorvest_reduction = max(min(PERK_JUGGERNAUT_REDUCTION, 1), 0);

    if(isdefined(level.perk_damage_override) && level.perk_damage_override.size > 0)
    {
        level.perk_damage_override = [serious::widows_wine_damage_callback];
    }

    foreach(perk in getentarray("zombie_vending", "targetname"))
    {
        level._custom_perks[perk.script_noteworthy].cost = 2000;
        perk.cost = level._custom_perks[perk.script_noteworthy].cost;
        perk setHintString("Press ^3&&1^7 to buy perk (Cost: " + perk.cost + ")");
    }

    level._custom_perks["specialty_additionalprimaryweapon"].player_thread_take = serious::mulekick_take;

    foreach(machine in level.perk_random_machines)
    {
        machine.unitrigger_stub.prompt_and_visibility_func = serious::stealable_perk_random_visibility_func;
        machine thread rng_perk_machine_think();
    }
}

apply_trap_changes()
{
    level._custom_traps["fire"].player_damage = serious::trap_fire_player;
}

enable_power()
{
    level flag::set("power_on");
    power_trigs = GetEntArray("use_elec_switch", "targetname");
	foreach(trig in power_trigs)
	{
		if(isdefined(trig.script_int))
		{
			level flag::set("power_on" + trig.script_int);
            level clientfield::set("zombie_power_on", trig.script_int);
		}
	}

    foreach(obj in array("elec", "power", "master")) // thanks feb
    {
        trig = getEnt("use_" + obj + "_switch", "targetname");
        if(isDefined(trig))
            trig notify("trigger", level.players[0]);
    }
}

hostdev()
{
    if(!IS_DEBUG) return;

    if(IS_DEBUG && DEBUG_WAGER_FX)
    {
        self.wager_tier = DEBUG_WAGER_FX;
    }

    if(self util::is_bot()) return;
    if(!self ishost()) return;
    if(DEV_GODMODE) self enableInvulnerability();

    if(DEV_POINTS && (!isdefined(self.max_points_earned) || self.max_points_earned < 25000))
    {
        if(!isdefined(self.max_points_earned))
            self.max_points_earned = 500;
        
        self.max_points_earned = int(max(self.max_points_earned * SPAWN_REDUCE_POINTS, 25000));
        targ_clamped = int(min(MAX_RESPAWN_SCORE, self.max_points_earned));
        self zm_score::add_to_player_score(targ_clamped - self.score, 0, "gm_zbr_admin");
        self Event_PointsAdjusted();
    }

    if(DEV_AMMO) self thread dev_ammo();

    if(DEV_HUD)
    {
        if(isdefined(self.zone_hud))
            self.zone_hud destroy();
        
        if(DEBUG_ZONE)
        {
            self.zone_hud = createText("default", 2, "CENTER", "TOP", 0, 200, 1, 1, "Active Zone: ", (1,1,1));
            self thread ZoneUpdateHUD();
        }
    }

    if(DEV_NOCLIP) thread ANoclipBind(self);
    if(DEV_SIGHT) self SetInfraredVision(0);

    if(level.script == "zm_zod")
    {
        if(DEBUG_SOE_SWORD)
        {
            self thread AdjustPlayerSword(self, "Normal", true);
        }
        else if(DEBUG_SOE_SUPERSWORD)
        {
            self thread AdjustPlayerSword(self, "Upgraded", true);
        }
    }

    if(DEBUG_CASTLE_SPIKES && (level.script == "zm_castle" || level.script == "zm_genesis"))
    {
        AwardPlayerSpikes(self);
    }

    if(DEBUG_BLACKHOLEBOMB && (level.script == "zm_moon" || level.script == "zm_cosmodrome"))
    {
        self zm_weapons::weapon_give(level.var_453e74a0, 0, 0, 1, 0);
    }

    if(DEBUG_G_STRIKE && level.script == "zm_tomb")
    {
        self zm_weapons::weapon_give(getweapon("beacon"), 0, 0, 1, 0);
    }

    if(DEBUG_ANNIHILATOR && isdefined(getweapon("hero_annihilator").name))
    {
        self zm_weapons::weapon_give(getweapon("hero_annihilator"), 0, 0, 1);
        self GadgetPowerSet(0, 100);
    }

    if(level.script == "zm_castle")
    {
        if(DEBUG_WOLF_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_wolf_howl"), 0, 0, 1);
        }
        else if(DEBUG_FIRE_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_rune_prison"), 0, 0, 1);
        }
        else if(DEBUG_STORM_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_storm"), 0, 0, 1);
        }
        else if(DEBUG_SKULL_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_demongate"), 0, 0, 1);
        }
    }

    if(DEBUG_RAYGUN)
    {
        self takeAllWeapons();
        self zm_weapons::weapon_give(getweapon("ray_gun_upgraded"), 0, 0, 1);
    }

    if(DEBUG_SHRINK_RAY && level.script == "zm_temple")
    {
        self takeAllWeapons();
        if(DEBUG_SHRINK_RAY > 1)
        {
            self zm_weapons::weapon_give(getweapon("shrink_ray_upgraded"), 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(getweapon("shrink_ray"), 0, 0, 1);
        }
    }

    if(DEBUG_GIVE_NESTING_DOLLS && isdefined(level.var_21ae0b78))
    {
        self zm_weapons::weapon_give(level.var_21ae0b78, 0, 0, 1, 0);
    }

    if(DEBUG_GIVE_MONKEYS && isdefined(level.weaponzmcymbalmonkey))
    {
        self zm_weapons::weapon_give(level.weaponzmcymbalmonkey, 0, 0, 1, 0);
    }

    if(DEBUG_GIVE_OCTOBOMB && isdefined(level.w_octobomb))
    {
        self zm_weapons::weapon_give(level.w_octobomb, 0, 0, 1, 0);
    }

    if(DEBUG_RAYGUN_MK3 && isdefined(level.w_raygun_mark3))
    {
        self takeAllWeapons();
        if(DEBUG_RAYGUN_MK3 > 1)
        {
            self zm_weapons::weapon_give(level.w_raygun_mark3_upgraded, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.w_raygun_mark3, 0, 0, 1);
        }
    }

    if(DEBUG_GIVE_MIRG && isdefined(level.var_5e75629a))
    {
        self takeAllWeapons();
        if(DEBUG_GIVE_MIRG > 1)
        {
            self zm_weapons::weapon_give(level.var_a4052592, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.var_5e75629a, 0, 0, 1);
        }
    }

    if(DEBUG_TESLA_GUN && isdefined(level.weaponzmteslagun))
    {
        self takeAllWeapons();
        if(DEBUG_TESLA_GUN > 1)
        {
            self zm_weapons::weapon_give(level.weaponzmteslagunupgraded, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.weaponzmteslagun, 0, 0, 1);
        }
        
    }

    self thread dev_util_thread();
}

debug_delayed()
{
    if(!IS_DEBUG) return;
    if(self util::is_bot() && DEBUG_BOTS_FREEZE)
    {
        self freezeControls(true);
    }
    wait 2.5;
    if(DEBUG_ALL_PERKS_ALL || (self ishost() && DEBUG_ALL_PERKS))
    {
        foreach(perk in GetArrayKeys(level._custom_perks))
        {
            self SetPerk(perk);
            self thread zm_perks::vending_trigger_post_think(self, perk);
        }
    }
}

initdev()
{
    if(!IS_DEBUG) return;
    
    level thread FastQuit();
    level flag::wait_till("begin_spawning");

    if(DEV_BOTS)
    {
        // add 3 bots
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
    }
}

AddGamemodeTestClient()
{
    bot = addTestClient();
    wait 3;
    bot [[ level.spawnplayer ]]();
    bot setOrigin(bot getOrigin() + (randomInt(30), randomInt(-30), randomFloat(40)));
    
    if(DEBUG_TEAMS)
    {
        bot SetGMTeam("allies");
        level.players[0] SetGMTeam(bot GetGMTeam());
    }
    if(IS_DEBUG && DEBUG_BOTS_FREEZE)
    {
        bot freezeControls(true);
    }
}

SetGMTeam(team)
{
    self.sessionteam = team;
    self._encounters_team = team;
    self.no_damage_points = false;
    self.team = team;
    self SetTeam(team);
    self.pers["team"] = team;
    self notify( "joined_team" );
    level notify( "joined_team" );
}

FastQuit()
{
    if(!DEV_EXIT)
        return;
    level waittill("end_game");
    wait 1; //for music
    exitlevel(0);
}

GMSpawned()
{
    self endon("bled_out");
    self endon("spawned_player");
    
    self apply_spawn_cleanup();
    self zm_cosmodrome_spawn_fix();
    self apply_pre_delay_spawn_variables();
    self notify("stop_player_too_many_weapons_monitor");
    self handle_safe_respawn(); // spawn delay is waited in this function
    self do_weapon_callbacks();
    self SetGMTeam(self GetGMTeam());
    self restore_earned_points();
    self apply_post_delay_spawn_variables();
    self apply_player_spectator_permissions();
    self remove_blacklisted_bgbs();
    self player_bgb_buys_1();
    self gm_hud_set_visible(true);
    self hostdev();

    self thread protect_from_zombies(15);
    self thread GM_HitBufferRecovery();
    self thread GM_ShowObjectives();
    self thread WatchMaxAmmo();
    self thread debug_delayed();
    self thread watch_falling_forever();

    if(!IS_DEBUG || !DEV_NO_WAGERS)
    {
        // level runs this thread so that if a player disconnects the thread doesnt crash the game.
        level thread spawn_wager_totem(groundtrace(self geteye(), self geteye() - (0,0,10000), false, self)["position"], (0,0,0), self);
    }
    if(IS_DEBUG && DEV_ICON_CAPTURE)
    {
        self thread wager_make_icon();
    }
    self thread do_wager_character_effects();
}

apply_spawn_cleanup()
{
    if(!isdefined(self.originalindex)) self.originalindex = self.characterindex;
    if(isdefined(self.spectate_obj))
    {
        self unlink();
        self.spectate_obj destroy();
    }
    if(isdefined(self.monkey_clone))
    {
        self.monkey_clone delete();
    }
    if(isdefined(self.clone_fx))
    {
        self.clone_fx delete();
    }
    self show();

    if(isdefined(level.b_use_poi_spawn_system) && level.b_use_poi_spawn_system)
    {
        self thread gm_spawn_protect(5);
    }
}

gm_spawn_protect(time)
{
    self endon("disconnect");
    self endon("spawned_player");
    self.gm_protected = true;
    self disableusability();
    self enableInvulnerability();
    wait SPAWN_DELAY + time;
    self enableusability();
    if(!self ishost() || !IS_DEBUG || !DEV_GODMODE)
    {
        self disableInvulnerability();
    }
    self.gm_protected = false;
}

apply_pre_delay_spawn_variables()
{
    if(self ishost() && (!isdefined(level.first_spawn) || level.first_spawn))
    {
        level.no_end_game_check = true;
        level.n_no_end_game_check_count = 9999999;
        level.first_spawn = false;
    }

    self.b_widows_wine_slow = false; // fix ww respawn
    self.b_widows_wine_cocoon = false; // fix ww respawn
    self.launch_magnitude_extra = 0; // remove cached magnitude for death ragdoll
    self.v_launch_direction_extra = (0,0,0); // remove cached direction vector for death ragdoll
    self.no_grab_powerup = false; // reset no grab when spawning
    
    self.var_789ebfb2 = false; // afflicted by storm bow attack
    self.zombie_tesla_hit = false; // afflicted by any tesla attack
    self.var_ca25d40c = false; // afflicted by fire bow attack
    self.var_a320d911 = false; // afflicted by fire bow attack
    self.var_4849e523 = 4; // we have the fourth skull on zetsubou
    self.var_20b8c74a = false; // afflicted by skull attack
    self.var_9b59d7f8 = false; // afflicted by skull mesmerize
    self.overridePlayerDamage = undefined; // fix revelations damage feedback breaking
    self.staff_succ = false; // fix respawn for air staff
    self.is_on_fire = false; // fix firestaff burning
    self.var_3f6ea790 = false; // fix mirg2000 aoe
    self.shrinked = false; // fix shrink ray
}

handle_safe_respawn()
{
    self.gm_objective_state = false;
    self.hud_amount = 0;
    self enableInvulnerability();
    self SetInfraredVision(1);
    self.ignoreme = 0;
    self thread ZoneCollector();
    self wait_and_return_weapon(); // blocking call, waits spawn delay.
    self.ignoreme = 0;
    self thread LoadoutRecorder();
    self setperk("specialty_fastweaponswitch");
    self setperk("specialty_loudenemies");
    self setperk("specialty_sprintfirerecovery");
    self setperk("specialty_trackerjammer");
    self SetInfraredVision(1); // keyline fix
    if(!isdefined(self.gm_protected) || !self.gm_protected)
    {
        if(!self ishost() || !IS_DEBUG || !DEV_GODMODE)
        {
            self disableInvulnerability();
        }
    }
}

restore_earned_points()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    if(self.max_points_earned < getRndMinPts())
        self.max_points_earned = getRndMinPts();

    targ_clamped = int(min(MAX_RESPAWN_SCORE, self.max_points_earned * SPAWN_REDUCE_POINTS));
    self zm_score::add_to_player_score(targ_clamped - self.score, 0, "gm_zbr_admin");

    if(IS_DEBUG && DEV_POINTS_ALL)
    {
        self.max_points_earned = 25000;
        if(self.score < self.max_points_earned)
            self zm_score::add_to_player_score(self.max_points_earned - self.score, 0, "gm_zbr_admin");
    }

    self Event_PointsAdjusted();
}

do_weapon_callbacks()
{
    self thread monitor_idgun();
    self thread monitor_thundergun_pvp();
    self thread glaive_pvp_monitor();
    self thread register_bow_callbacks();
    self thread wait_for_microwavegun_fired();
    self thread monitor_keeper_skull();
    self thread player_monitor_cherry();
    self thread monitor_staffs_tomb();
    self thread raygun_mk3_monitor();
    self thread monitor_mirg2000();
    self thread monitor_shrink_ray();
    self thread custom_weapon_callbacks();
}

apply_post_delay_spawn_variables()
{
    self.n_bleedout_time_multiplier = N_BLEEDOUT_BASE;
    level.solo_lives_given = 0;
    foreach(bgb in self.var_98ba48a2)
    {
        self.var_e610f362[bgb].var_b75c376 = -999; // remove bgb usage
    }
    if(isdefined(self.spectate_obj)) self.spectate_obj destroy();
}

apply_player_spectator_permissions()
{
    // fixes player spectator permissions
    if(self ishost())
    {
        self allowSpectateTeam("allies", 0);
        self allowSpectateTeam("axis", 0);
        for(i = 3; i < 8; i++)
            self allowSpectateTeam("team" + i, 0);
        
        self allowSpectateTeam("freelook", 1);
        self allowSpectateTeam("none", 1);
    }
    else
    {
        self allowSpectateTeam("allies", 1);
        self allowSpectateTeam("axis", 0);
        for(i = 3; i < 8; i++)
            self allowSpectateTeam("team" + i, 1);
        
        self allowSpectateTeam("freelook", 0);
        self allowSpectateTeam("none", 0);
    }
}

on_joined_spectator()
{
    self apply_player_spectator_permissions();
    if(self ishost())
    {
        self thread gm_spectator();
    }
}

protect_from_zombies(time = 5)
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");

    if(!isdefined(self.ignoreme))
    {
        self.ignoreme = 0;
    }

    while(time > 0)
    {   
        if(self.ignoreme < 1) 
        {
            self.ignoreme = 1;
        }
        time--;
        wait 1;
    }

    if(self.ignoreme > 0) 
    {
        self.ignoreme--;
    }
}

getRndMinPts()
{
    if(level.round_number < MIN_ROUND_PTR_BEGIN) return 500;
    return (level.round_number - (MIN_ROUND_PTR_BEGIN - 1)) * MIN_ROUND_PTS_MULT;
}

ZoneCollector()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");

    if(!isdefined(self.visited_zones))
        self.visited_zones = [];

    while(1)
    {
        wait 1;
        zone = self zm_zonemgr::get_player_zone();

        if(!isdefined(zone))
            continue;

        if(!isinarray(self.visited_zones, zone))
            self.visited_zones[self.visited_zones.size] = zone;
    }
}

GM_HitBufferRecovery()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");

    self.hitbuffer = HIT_BUFFER_CAPACITY;
    while(1)
    {
        if(self.hitbuffer < 0)
            self.hitbuffer = 0;

        if(self.hitbuffer > HIT_BUFFER_CAPACITY)
            self.hitbuffer = HIT_BUFFER_CAPACITY;
        
        wait 1;
        if(self.hitbuffer >= HIT_BUFFER_CAPACITY)
            continue;

        self.hitbuffer += 10;
    }
}

GetGMTeam()
{
    if(IS_DEBUG && DEBUG_ALL_FRIENDS) return "allies";
    if(self ishost()) return "allies";
    teamid = self GetSpawnTeamID();
    return "team" + teamid;
}

true_one_arg(player)
{
    return true;
}

check_firesale_valid_loc(arg0)
{
    // corrects an issue where a box that is the normal box will not be shown if hidden before a firesale
    if(level.chests[level.chest_index] == self)
    {
        if(isdefined(self.hidden) && self.hidden)
        {
            self thread zm_magicbox::show_chest();
        }
    }
    self.was_temp = undefined;
    level.disable_firesale_drop = undefined; // fixes a state where firesales can never drop
    return true;
}

nullsub()
{
    return false;
}

//thanks extinct for the callback
_actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal)
{
    if(isdefined(attacker.hud_damagefeedback))
    {
        attacker.hud_damagefeedback.color = (1,1,1);
    }

    if(isdefined(attacker.wager_zm_outgoing_damage))
    {
        damage = int(damage * attacker.wager_zm_outgoing_damage);
    }

    self [[ level._callbackActorDamage ]](inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal);
    if(isdefined(self.is_clone) && self.is_clone) return;

    if(isdefined(attacker) && isdefined(attacker._trap_type)) attacker = attacker.activated_by_player;
    if(isdefined(attacker) && isplayer(attacker) && isdefined(self.health) && isdefined(self.maxhealth))
    {
        if(!isdefined(weapon)) weapon = attacker getCurrentWeapon();
        if(!(self aat_response(self.health > 0, inflictor, attacker, damage, flags, meansOfDeath, weapon, vpoint, vdir, shitloc, psoffsettime)))
        {
            damageStage = _damage_feedback_get_stage(self);
            attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, meansOfDeath, weapon, damageStage));
            attacker thread damagefeedback::damage_feedback_growth(self, meansOfDeath, weapon);
        }
    }
}

weapon_is_ww(weapon)
{
    if(!isdefined(weapon)) return false;
    if(isdefined(level.w_widows_wine_grenade) && weapon == level.w_widows_wine_grenade) return true;
    if(isdefined(level.w_widows_wine_knife) && weapon == level.w_widows_wine_knife) return true;
    if(isdefined(level.w_widows_wine_bowie_knife) && weapon == level.w_widows_wine_bowie_knife) return true;
    if(isdefined(level.w_widows_wine_sickle_knife) && weapon == level.w_widows_wine_sickle_knife) return true;
    return false;
}

weapon_is_ds(weapon)
{
    return weapon.rootweapon.name == "launcher_dragon_fire_upgraded" || weapon.rootweapon.name == "launcher_dragon_fire";
}

_player_damage_override(eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath = "MOD_UNKNOWN", weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    if(self laststand::player_is_in_laststand()) return 0;
    
    result = self [[ level._overridePlayerDamage ]](eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    shrink_multiplier = 1.0f;

    if(isdefined(self.is_zombie) && self.is_zombie) return result;

    if(IS_DEBUG && DEV_DMG_DEBUG_FIRST && isdefined(weapon) && isdefined(weapon.rootweapon))
        level.players[0] iPrintLnBold("hasAttacker: " + isdefined(attacker) + ", " + weapon.rootweapon.name + " (^1" + (isdefined(result) ? result : "??") + "^7/^2" + iDamage + "^7) " + sMeansOfDeath);

    if(isdefined(self.shrinked) && self.shrinked && (!isdefined(self.shrink_kicked) || !self.shrink_kicked))
    {
        if(!isdefined(attacker.shrink_damage_refract)) return 0; // shrink ray damage must come from a refraction call
        attacker = attacker.attacker;
        if(!(smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE"))
        {
            shrink_multiplier = SHRINK_RAY_DAMAGE_MULT;
        }
    }

    if(isplayer(self) && isdefined(attacker) && isdefined(attacker.b_aat_fire_works_weapon) && attacker.b_aat_fire_works_weapon)
    {
        attacker = attacker.owner;
        if(attacker == self) return 0;
        result = AAT_FIREWORKS_PVP_DAMAGE * level.round_number;
        weapon = level.weaponnone;
        sMeansOfDeath = "MOD_UNKNOWN";
    }

    is_ww = weapon_is_ww(weapon);
    is_ds = weapon_is_ds(weapon);
    is_bb = isdefined(level.placeable_mines) && isinarray(level.placeable_mines, weapon);
    is_wg = weapon_is_wg(weapon);

    if(isplayer(attacker) && attacker != self && (is_ww || is_bb || is_wg)) result = iDamage;
    if(isdefined(level.var_25ef5fab) && level.var_25ef5fab == weapon) result = iDamage; // beacon fix

    if(isdefined(self.staff_succ) && smeansofdeath == "MOD_FALLING" && self.staff_succ) 
    {
        self thread Event_HealthAdjusted();
        return STAFF_AIR_DMG_PER_TICK;
    }

    if(!isdefined(result) || 
                            (
                                result <= 0 && !is_tomb_staff(weapon) && !is_ds && 
                                !is_bb
                            )
    ) return 0;

    if(!isdefined(attacker))
    {
        b_continue_logic = true;
        if(sMeansOfDeath == "MOD_FALLING" && isdefined(self.last_player_attacker) && isdefined(self.last_player_attack))
        {
            time_delta = gettime() - self.last_player_attack;
            if(time_delta >= 0 && time_delta <= MOD_FALL_GRACE_PERIOD)
            {
                attacker = self.last_player_attacker;
                sMeansOfDeath = "MOD_UNKNOWN";
                weapon = level.weaponnone;
            }
            else
            {
                b_continue_logic = false;
            }
        }
        else
        {
            // chain trap fix
            if(level.b_is_zod && (isdefined(self.trap_damage_cooldown) || result == 25))
            {
                if(!isdefined(self.cache_trap))
                {
                    traps = array::get_all_closest(self.origin, getentarray("trap_chain_damage", "targetname"), undefined, undefined, 150);
                    if(traps.size)
                    {
                        traps[0] thread zm_zod_uncache(self);
                        self.cache_trap = traps[0];
                    }
                    else
                    {
                        b_continue_logic = false;
                    }
                }
                if(b_continue_logic)
                {
                    attacker = self.cache_trap.activated_by_player;
                    if(self hasPerk("specialty_armorvest")) result = 50;
                    else result = 400 * level.round_number;
                }
            }
            else if(level.b_is_stalingrad && result == 40)
            {
                result = 2500 * level.round_number;
                b_continue_logic = false;
            }
            else
            {
                b_continue_logic = false;
            }
        }

        if(!b_continue_logic)
        {
            self thread Event_HealthAdjusted();
            return result;
        }
    }

    if(isdefined(attacker.beastmode) && attacker.beastmode) return 0;

    if(smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE")
    {
        if((!isdefined(level.var_30611368) || weapon != level.var_30611368) && !issubstr(weapon.name, "raygun"))
        {
            if(EXPLOSIVE_KNOCKBACK_SCALAR)
            {
                target_velocity = VectorScale(vectornormalize(vDir) + (0,0,1), EXPLOSIVE_KNOCKBACK_SCALAR);
                if(isdefined(self.in_low_gravity) && self.in_low_gravity)
                {
                    target_velocity = (target_velocity[0], target_velocity[1], int(min(target_velocity[2], 100)));
                }
                if(!self isonground())
                {
                    trace = groundtrace(self.origin, self.origin + vectorscale((0, 0, -1), 10000), 0, undefined)["position"];
                    if(abs(trace[2] - self.origin[2]) >= 75 || (self getVelocity()[2] > 300))
                    {
                        target_velocity = (target_velocity[0], target_velocity[1], 0);
                    }
                }
                else
                {
                    self setorigin(self getorigin() + (0,0,5));
                }
                self setVelocity(self getVelocity() + target_velocity);
            }
        }
        if(self bgb::is_enabled("zm_bgb_danger_closest")) return 0;
    }

    if(smeansofdeath == "MOD_MELEE" && self bgb::is_enabled("zmb_bgb_powerup_burnedout") && !((!isdefined(attacker.is_zombie) || !attacker.is_zombie) && attacker bgb::is_enabled("zm_bgb_pop_shocks"))) return 0;
    
    if(IS_DEBUG && DEV_HEALTH_DEBUG)
        self iprintlnbold("Health: " + self.health + ", Max: " + self.maxhealth + ", DMG: " + result + ", Score: " + self.score);
    
    if(isdefined(attacker.is_zombie) && attacker.is_zombie)
    {
        if(IS_DEBUG && DEV_BOTS_IGNORE_ZM_DMG && self util::is_bot())
        {
            self.ignoreme = true;
            return 0;
        }

        self.last_player_attacker = undefined;
        self.last_player_attack = undefined;
        if(!isdefined(self.hitbuffer))
            self.hitbuffer = 0;

        if(self hasperk("specialty_armorvest"))
        {
            result *= 1 - level.armorvest_reduction;
            result = int(result);
            self playlocalsound("prj_hatchet_impact_armor_heavy");
        }
        
        if(self.hitbuffer - result < 0)
        {
            self.hitbuffer = 0;

            if(!isdefined(level.zombieDamageScalar))
                level.zombieDamageScalar = 1;

            if(!isdefined(self.max_points_earned))
                self.max_points_earned = 500;

            // set basis scaled damage
            target = level.zombieDamageScalar * level.gm_zombie_dmg_scalar * result * level.round_number * level.gm_rubber_banding_scalar;

            if(isdefined(self.wager_zm_incoming_damage))
                target *= self.wager_zm_incoming_damage;

            // cannot be faster than 3 hit down
            target = int(min(target, self.max_points_earned * .34));
            target = int(min(target, MAX_HIT_VALUE));
            target = int(max(target, ZOMBIE_BASE_DMG));
        }
        else
        {
            self.hitbuffer -= result;
            target = int(min(100, result));
        }

        result = target;
    }

    if(is_ds) attacker = attacker.player;
    is_trap = false;
    if(isdefined(attacker) && isdefined(attacker._trap_type))
    {
        attacker = attacker.activated_by_player;
        is_trap = true;
        if(smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE")
            result = self hasperk("specialty_armorvest") ? 100 : TRAP_DEFAULT_DAMAGE;
    }

    // pretty much guaranteed to be the pendulum trap
    if(iDamage >= self.health && result == 75 && isdefined(level.var_99432870) && level.var_99432870)
    {
        if(!self hasperk("specialty_armorvest")) result = iDamage;
        else self setstance("crouch");
        foreach(trig in getentarray("pendulum_buy_trigger", "targetname"))
        {
            if(isdefined(trig.penactive) && trig.penactive)
            {
                attacker = trig.used_by;
                break;
            }
        }
    }

    if(isplayer(attacker) && attacker != self)
    {
        if(isdefined(attacker.wager_pvp_melee_damage) && isdefined(sMeansOfDeath) && sMeansOfDeath == "MOD_MELEE") return 0;
        if(attacker laststand::player_is_in_laststand() && !(attacker bgb::is_enabled("zm_bgb_self_medication"))) return 0;
        if(!isDefined(weapon)) weapon = attacker getCurrentWeapon();

        if(isdefined(sMeansOfDeath) && sMeansOfDeath != "MOD_UNKNOWN")
            result += result * level.player_weapon_boost;
        
        result = int(self GM_AdjustWeaponDamage(weapon, result, sMeansOfDeath, attacker) * shrink_multiplier);

        if(isdefined(level.zombie_vars[attacker.team]["zombie_insta_kill"]) && level.zombie_vars[attacker.team]["zombie_insta_kill"])
        {
            result = int(result * INSTAKILL_DMG_PVP_MULTIPLIER);
        }

        if(self bgb_any_frozen()) result = int(result * BGB_FROZEN_DAMAGE_REDUX);

        if(isdefined(level.var_653c9585))
        {
            switch(weapon)
            {
                case level.var_75ef78a0: // upgraded
                case level.var_653c9585: // normal
                    self thread one_inch_punch_dmg(attacker, false);
                    break;
                case level.var_4f241554: // fire
                case getweapon("staff_fire"):
                case getweapon("staff_fire_upgraded"):
                    self thread flame_damage_fx(weapon, attacker);
                    break;
                case level.var_af96dd85: // ice
                case getweapon("staff_water"):
                case getweapon("staff_water_upgraded"):
                    self thread ice_affect_zombie(weapon, attacker);
                    break;
                case level.var_e27d2514: // air
                case getweapon("staff_air"):
                case getweapon("staff_air_upgraded"):
                    self thread staff_air_knockback(weapon, attacker);
                    break;
                case level.var_590c486e: // lightning
                case getweapon("staff_lightning"):
                case getweapon("staff_lightning_upgraded"):
                    self thread staff_lightning_stun_player();
                    break;
                default: break;
            }
        }

        if(level.b_is_stalingrad)
        {
            if(weapon == level.w_raygun_mark3lh || weapon == level.w_raygun_mark3lh_upgraded)
                self thread mark3_slow(weapon == level.w_raygun_mark3lh_upgraded);
        }

        useJugg = self armor_damage_protected(weapon, smeansofdeath, shitloc);

        if(isdefined(self.wager_pvp_incoming_damage))
        {
            result = int(result * self.wager_pvp_incoming_damage);
        }
        if(isdefined(attacker.wager_pvp_outgoing_damage))
        {
            result = int(result * attacker.wager_pvp_outgoing_damage);
        }

        if(useJugg) result = int(result * (1 - level.armorvest_reduction));

        if(isdefined(weapon.isriotshield) && weapon.isriotshield)
        {
            self setorigin(self getorigin() + (0,0,5));
            self setVelocity(self getVelocity() + VectorScale(vectornormalize(vDir) + (0,0,0.5), 400));
        }

        if(is_ww) self widows_wine_zombie_damage_response(sMeansOfDeath, vPoint, attacker, result, weapon, vDir);
        mod_pointscalar = DOUBLEPOINTS_PVP_SCALAR;
        if(!isdefined(attacker.team) || !isdefined(level.zombie_vars[attacker.team]["zombie_point_scalar"]) || level.zombie_vars[attacker.team]["zombie_point_scalar"] <= 1)
        {
            mod_pointscalar = 1;
        }
        mod_pointscalar *= DMG_CONVT_EFFICIENCY;
        if(isdefined(self.wager_win_dmg_scalar) && self.score >= WIN_NUMPOINTS)
        {
            mod_pointscalar *= self.wager_win_dmg_scalar;
        }
        else if(isdefined(attacker.wager_pvp_points_mod))
        {
            mod_pointscalar *= attacker.wager_pvp_points_mod;
        }
        attacker zm_score::add_to_player_score(int(mod_pointscalar * min(result, self.maxhealth)), 1, "gm_zbr_admin");
        self.last_player_attacker = attacker;
        self.last_player_attack = gettime();
        if(!aat_response((self.health - result) <= 0, eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vpoint, vdir, shitloc, psoffsettime))
        {
            damageStage = attacker _damage_feedback_get_stage(self, result);
            if(useJugg) 
            {
                if(isdefined(attacker.hud_damagefeedback))
                {
                    attacker.hud_damagefeedback.color = self GM_GetPlayerColor(true);
                }
                attacker thread damagefeedback::update_override("damage_feedback", "prj_hatchet_impact_armor_heavy", "damage_feedback_armor");
                self playlocalsound("prj_hatchet_impact_armor_heavy");
            }
            else 
            {
                if(isdefined(attacker.hud_damagefeedback))
                {
                    attacker.hud_damagefeedback.color = (self.health - result > 0)? self GM_GetPlayerColor(true): (1,1,1);
                }
                attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansOfDeath, weapon, damageStage));
                attacker thread _damage_feedback_growth(self, sMeansOfDeath, weapon, result);
            }
        }
    }
    
    self thread Event_HealthAdjusted();
    return result;
}

armor_damage_protected(weapon, smeansofdeath = "MOD_UNKNOWN", shitloc = "none")
{
    if(!self hasperk("specialty_armorvest")) return false;
    if(shitloc == "head" || shitloc == "helmet") return false;
    switch(smeansofdeath)
    {
        case "MOD_BURNED":
		case "MOD_CRUSH":
		case "MOD_DROWN":
		case "MOD_EXPLOSIVE":
		case "MOD_FALLING":
		case "MOD_GRENADE":
		case "MOD_GRENADE_SPLASH":
        case "MOD_PROJECTILE_SPLASH":
		case "MOD_HIT_BY_OBJECT":
		case "MOD_MELEE":
		case "MOD_MELEE_WEAPON_BUTT":
		case "MOD_SUICIDE":
		case "MOD_TELEFRAG":
		case "MOD_TRIGGER_HURT":
		case "MOD_UNKNOWN":
            return false;
    }
    return true;
}

is_tomb_staff(weapon)
{
    if(!isdefined(level.a_elemental_staffs))
        return false;
    
    if(!isdefined(weapon))
        return false;

    foreach(s_staff in level.a_elemental_staffs)
        if(weapon == s_staff.w_weapon)
            return true;
    
    return is_upgraded_tomb_staff(weapon);
}

is_upgraded_tomb_staff(weapon)
{
    if(!isdefined(level.a_elemental_staffs_upgraded))
        return false;

    if(!isdefined(weapon))
        return false;
    
    foreach(s_staff in level.a_elemental_staffs_upgraded)
        if(weapon == s_staff.w_weapon)
            return true;
    return false;
}


GM_AdjustWeaponDamage(weapon, result, sMeansOfDeath = "MOD_NONE", attacker)
{
    if(!isdefined(weapon) || !isdefined(weapon.rootweapon))
        return result;
    
    if(!isdefined(weapon.rootweapon.name))
        return result;
    
    if(isdefined(sMeansOfDeath) && sMeansOfDeath == "MOD_MELEE")
    {
        switch(weapon.rootweapon.name)
        {
            case "staff_air_upgraded":
            case "staff_water_upgraded":
            case "staff_fire_upgraded":
            case "staff_lightning_upgraded":
                result = 1700;
                break;
            case "dragonshield":
            case "tomb_shield":
            case "zod_riotshield":
            case "dragonshield":
            case "island_riotshield":
                result = 1000;
                break;
            case "dragon_gauntlet":
                result = 2250;
                break;
            default:
                result = max(result, 250) * MELEE_DMG_SCALAR;
                break;
        }
        result = min(result * level.round_number, MAX_MELEE_DAMAGE);
        if(isdefined(attacker) && attacker bgb::is_enabled("zm_bgb_sword_flay")) result *= 5;
        if(attacker bgb::is_enabled("zm_bgb_pop_shocks"))
            attacker thread attempt_pop_shocks(self);
        return result;
    }

    if(IS_DEBUG && DEV_DMG_DEBUG && isdefined(weapon) && isdefined(weapon.rootweapon))
        level.players[0] iPrintLnBold(weapon.rootweapon.name + " " + result + " " + sMeansOfDeath);

    switch(weapon.rootweapon.name)
    {
        case "hero_annihilator":
            return result * (1 + (level.round_number * ANNIHILATOR_DMG_PERCENT_PER_ROUND));

        case "sniper_fastsemi_upgraded":
        case "sniper_fastsemi":
            return result * 0.75; // nerfing the drakon, which has way too much dps (still does kek)

        case "minigun":
            return int(80 * level.round_number);
        
        case "launcher_standard_upgraded":
            return result * 150;

        case "launcher_multi_upgraded":
            return result * 100;

        case "launcher_standard":
            return result * 30;

        case "launcher_multi":
            return result * 20;

        case "ray_gun":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return 400 * level.round_number;
            return 100 * level.round_number;

        case "ray_gun_upgraded":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return 1200 * level.round_number;
            return 300 * level.round_number;

        case "raygun_mark2":
            return result * level.round_number;

        case "microwavegundw":
        case "microwavegunlh":
            return 1125 * result;

        case "microwavegundw_upgraded":
        case "microwavegunlh_upgraded":
            return 5625 * result;
        
        case "pistol_c96_upgraded":
            return result * 40;
            
        case "raygun_mark2_upgraded":
            return result * 50;

        case "raygun_mark3":
            return result * 18;

        case "raygun_mark3_upgraded":
            return result * 90;

        case "frag_grenade":
            return int(7 * result * level.round_number);

        case "frag_grenade_slaughter_slide":
            return int(7 * result * level.round_number);

        case "nesting_dolls_single":
            return int(5 * result * level.round_number);

        case "pistol_m1911_upgraded":
        case "pistol_m1911h_upgraded":
        case "pistol_revolver38_upgraded":
        case "pistol_revolver38lh_upgraded":
        case "pistol_standard_upgraded":
        case "pistol_standardlh_upgraded":
            return result * 12;

        case "tesla_gun":
            if(sMeansOfDeath == "MOD_PROJECTILE")
            {
                return 5000 + (500 * level.round_number);
            }
            return 2500 + (250 * level.round_number);

        case "tesla_gun_upgraded":
            if(sMeansOfDeath == "MOD_PROJECTILE")
            {
                return 10000 + (1000 * level.round_number);
            }
            return 5000 + (500 * level.round_number);

        case "sticky_grenade_widows_wine":
            if(IS_DEBUG && DEBUG_WW_DAMAGE) return 1;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return int(100 * level.round_number);
            return result;

        case "elemental_bow":
        case "elemental_bow2":
        case "elemental_bow3":
        case "elemental_bow4":
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return result * 2.5 * level.round_number;
            return result * 6 * level.round_number;

        case "elemental_bow_rune_prison":
        case "elemental_bow_wolf_howl":
        case "elemental_bow_storm":
        case "elemental_bow_demongate":
            if(sMeansOfDeath == "MOD_UNKNOWN") return result;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return 1000 * level.round_number;
            return 2000 * level.round_number;

        case "elemental_bow_rune_prison1":
        case "elemental_bow_wolf_howl1":
        case "elemental_bow_storm1":
        case "elemental_bow_demongate1":
            if(sMeansOfDeath == "MOD_UNKNOWN") return result;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return 1100 * level.round_number;
            return 2100 * level.round_number;

        case "elemental_bow_rune_prison2":
        case "elemental_bow_wolf_howl2":
        case "elemental_bow_storm2":
        case "elemental_bow_demongate2":
            if(sMeansOfDeath == "MOD_UNKNOWN") return result;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return 1200 * level.round_number;
            return 2200 * level.round_number;

        case "elemental_bow_rune_prison3":
        case "elemental_bow_wolf_howl3":
        case "elemental_bow_storm3":
        case "elemental_bow_demongate3":
            if(sMeansOfDeath == "MOD_UNKNOWN") return result;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return 1300 * level.round_number;
            return 2300 * level.round_number;

        case "elemental_bow_rune_prison4":
        case "elemental_bow_wolf_howl4":
        case "elemental_bow_storm4":
        case "elemental_bow_demongate4":
            if(sMeansOfDeath == "MOD_UNKNOWN") return result;
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return 2500 * level.round_number;
            return 2500 * level.round_number;

        case "hero_mirg2000":
            return 500 * level.round_number;
        case "hero_mirg2000_1":
            return 750 * level.round_number;
        case "hero_mirg2000_2":
            return 1000 * level.round_number;
        
        case "hero_mirg2000_upgraded":
            return 1500 * level.round_number;
        case "hero_mirg2000_upgraded_1":
            return 2500 * level.round_number;
        case "hero_mirg2000_upgraded_2":
            return 4000 * level.round_number;

        case "octobomb":
        case "octobomb_upgraded":
            return 2500 + level.round_number * 100;

        case "launcher_dragon_fire_upgraded":
            return 10000;

        case "launcher_dragon_fire":
            return 7000;

        case "bouncingbetty_devil":
        case "bouncingbetty_holly":
        case "bouncingbetty":
            return level.round_number * result;

        case "shotgun_energy":
            return result * 50;
        case "shotgun_energy_upgraded":
            return result * 100;

        case "pistol_energy":
            return result * 2;

        case "pistol_energy_upgraded":
            return result * 5;

        default:

            if(!is_tomb_staff(weapon))
                return gm_adjust_custom_weapon(weapon, result, sMeansOfDeath, attacker);
            
            if(!is_upgraded_tomb_staff(weapon))
                return level.round_number * 1000;

            return level.round_number * 1500;
    }
}

_damage_feedback_get_stage(victim, damage = 0)
{
    if(!isdefined(victim) || !isdefined(victim.health) || !isdefined(victim.maxhealth))
        return 1;
    
    result = float(victim.health - damage);
    rval = result / victim.maxhealth;

    if(isplayer(victim) && (victim laststand::player_is_in_laststand() || victim.sessionstate != "playing"))
        return 5;

    if(rval > 0.74)
	{
		return 1;
	}
	else if(rval > 0.49)
	{
		return 2;
	}
	else if(rval > 0.24)
	{
		return 3;
	}
	else if(rval > 0)
	{
		return 4;
	}

	return 5;
}

_damage_feedback_growth(victim, mod, weapon, damage = 0, stage = undefined)
{
	if(isdefined(self.hud_damagefeedback))
	{
        if(!isdefined(stage)) 
        {
            stage = _damage_feedback_get_stage(victim, damage);
        }
		self.hud_damagefeedback.x = -11 + -1 * stage;
		self.hud_damagefeedback.y = -11 + -1 * stage;
		size_x = 22 + 2 * stage;
		size_y = size_x * 2;
		self.hud_damagefeedback SetShader("damage_feedback", size_x, size_y);
		if(stage == 5)
		{
			self.hud_damagefeedback SetShader("damage_feedback_glow_orange", size_x, size_y);
			self thread damagefeedback::kill_hitmarker_fade();
		}
		else
		{
			self.hud_damagefeedback SetShader("damage_feedback", size_x, size_y);
			self.hud_damagefeedback.alpha = 1;
			self.hud_damagefeedback fadeOverTime(1);
			self.hud_damagefeedback.alpha = 0;
		}
	}
}

PointAddedDispatcher()
{
    level thread PointRemovedDispatcher();
    while(1)
    {
        level waittill("earned_points", player);

        if(!isdefined(player))
            continue;

        player thread Event_PointsAdjusted();
    }
}

PointRemovedDispatcher()
{
    while(1)
    {
        level waittill("spent_points", player);

        if(!isdefined(player))
            continue;

        player thread Event_PointsAdjusted();
    }
}

Event_PointsAdjusted()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = self.score;
    
    if(!isdefined(self.gm_objective_state))
        self.gm_objective_state = false;
    
    self.max_points_earned = int(Max(self.max_points_earned, self.score));

    if(self.maxhealth > self.score)
        self fakedamagefrom((0,0,0));

    self.maxhealth = int(Max(1, self.score));
    self.health = self.maxhealth;

    self Check_GMObjectiveState();
}

Check_GMObjectiveState()
{
    foreach(player in level.players)
        player thread UpdateGMProgress(self);

    if(!isdefined(self.gm_objective_state)) 
        self.gm_objective_state = false;
    
    if((self.score >= self Get_Pointstowin()) != self.gm_objective_state)
    {
        self.gm_objective_state = self.score >= self Get_Pointstowin();

        if(self.gm_objective_state)
            self thread GM_BeginCountdown();
    }
}

Get_Pointstowin()
{
    if(IS_DEBUG && DEV_USE_PTW)
        return DEV_POINTS_TO_WIN;
    if(isdefined(self.wager_win_points)) return self.wager_win_points;
    return WIN_NUMPOINTS;
}

Event_HealthAdjusted()
{
    self notify("Event_HealthAdjusted");
    self endon("Event_HealthAdjusted");
    self endon("spawned_player");
    self endon("disconnect");
    self waittill("damage");

    self.score = int(self.health);
	self.pers["score"] = int(self.score);
    self.maxhealth = int(self.score);

    self Check_GMObjectiveState();
}

Round_PointScaling()
{
    zvars = 
    [
        "zombie_score_kill_4player", "zombie_score_kill_3player", "zombie_score_kill_2player",
        "zombie_score_kill_1player", "zombie_score_bonus_melee", "zombie_score_bonus_head", "zombie_score_bonus_torso"
    ];

    foreach(v in zvars)
        if(isdefined(level.zombie_vars[v]))
            level.zombie_vars[v] = int(level.zombie_vars[v] * EXPONENT_SCOREINC);

    if(!isdefined(level.zombieDamageScalar))
        level.zombieDamageScalar = 1;

    level.zombieDamageScalar = EXPONENT_DMGINC;

    if(level.script != "zm_zod")
    {
        if(level.round_number % ROUND_DELTA_SCALAR) return;
        
        foreach(perk in getentarray("zombie_vending", "targetname"))
        {
            if(!isdefined(level._custom_perks[perk.script_noteworthy].cost))
                level._custom_perks[perk.script_noteworthy].cost = 2000;
            
            if(!isdefined(perk.cost))
                perk.cost = level._custom_perks[perk.script_noteworthy].cost;
            
            for(i = 0; i < ROUND_DELTA_SCALAR; i++)
                perk.cost = int(perk.cost * EXPONENT_PURCHASE_COST_INC);
            
            level._custom_perks[perk.script_noteworthy].cost = perk.cost;
            perk setHintString("Press ^3&&1^7 to buy perk [Cost: " + perk.cost + "]");
        }

        for(i = 0; i < ROUND_DELTA_SCALAR; i++)
            level.boxCost *= EXPONENT_PURCHASE_COST_INC;

        level.zombie_treasure_chest_cost = Int(level.boxCost);
        level.var_e1dee7ba = ROUND_DELTA_SCALAR; // number of rounds between price increase
        level.var_8ef45dc2 = 30; // clamp for round exponent
        level.var_a3e3127d = 1.15; // exponent
        level.var_f02c5598 = 2500; // base cost  

        if(isdefined(level._random_zombie_perk_cost))
        {
            for(i = 0; i < ROUND_DELTA_SCALAR; i++)
                level._random_zombie_perk_cost = int(level._random_zombie_perk_cost * EXPONENT_PURCHASE_COST_INC);
        }
    }

    // rubber band correction for zombie damage
    level.gm_rubber_banding_scalar = min(1.0f, GM_ZDMG_RUBBERBAND_PERCENT + level.gm_rubber_banding_scalar);
}

Event_RoundNext()
{
    if(IS_DEBUG && DEBUG_NO_ROUNDNEXT) return;
    // scale points if we didnt restart
    if(!isdefined(level.gm_lastround))
        level.gm_lastround = level.round_number;

    if(!isdefined(level.player_weapon_boost))
        level.player_weapon_boost = 0;

    if(level.gm_lastround < level.round_number)
    {
        Round_PointScaling();
        level.player_weapon_boost += WEP_DMG_BOOST_PER_ROUND;
        level.gm_lastround = level.round_number;
    }

    if(level.perk_purchase_limit < 99)
    {
        level.perk_purchase_limit = 99; // fixes the custom maps that limit after spawning 
    }

    level.skip_alive_at_round_end_xp = false;
    level.zombie_vars[ "zombie_between_round_time" ] = (float(GM_ROUND_DELAY_FULL_RND - min(GM_ROUND_DELAY_FULL_RND, level.round_number)) / GM_ROUND_DELAY_FULL_RND * GM_BETWEEN_ROUND_DELAY_START) + 0.05;

    // reset all boxes
    level.magic_box_grab_by_anyone = true;
    level flag::clear("moving_chest_enabled");
    level.chest_min_move_usage = 999;

    foreach(chest in level.chests)
    {
        chest.hidden = 0;
        chest.zombie_cost = Int(level.boxCost);
        chest thread [[level.pandora_show_func]]();
        chest.zbarrier zm_magicbox::set_magic_box_zbarrier_state("initial");
    }   

    // reset all gobble machines
    for(i = 0; i < level.var_5081bd63.size; i++)
	{
		if(!level.var_5081bd63[i].var_4d6e7e5e) // if not already showing
		{
            level.var_5081bd63[i].var_4d6e7e5e = true;
			level.var_5081bd63[i] thread bgb_machine::func_13565590(); // show it
		}
	}

    // force all players into stage 1 of bgb purchasing
    foreach(player in level.players)
    {
        player player_bgb_buys_1();
    }

    if(isdefined(level.elo_round_next))
        level thread [[ level.elo_round_next ]]();

    level notify("wager_check");

    level flag::set("teleporter_used");
    thread zm_island_fix();
    zm_genesis_fix();
    zm_cosmodrome_fix();
    zm_dogs_fix();
    thread zm_mechz_roundNext();
}

Event_ZombieInitDone()
{
    if(level.script == "zm_island") self.var_cbbe29a9 = true;
    self thread KillOnTimeout();
}

KillOnTimeout()
{
    self endon("death");
    self endon("deleted");
    wait ZOMBIE_MAXLIFETIME;
    if(isdefined(self) && isalive(self))
        self DoDamage(self.health + 10000, self.origin);
}

Calc_ZombieSpawnDelay(n_round)
{
    if(n_round > 30)
	{
		n_round = 30;
	}

	n_multiplier = EXPONENT_SPAWN_DELAY_MULT;

	switch(level.players.size)
	{
		case 1:
		{
			n_delay = 2;
			break;
		}
		case 2:
		{
			n_delay = 1.5;
			break;
		}
		case 3:
		{
			n_delay = 0.89;
			break;
		}
		case 4:
		{
			n_delay = 0.67;
			break;
		}
	}

	for(i = 0; i < n_round; i++)
	{
		n_delay = n_delay * n_multiplier;
		if(n_delay <= 0.05)
		{
			n_delay = 0.05;
			break;
		}
	}

	return n_delay;
}

one_box_hit_monitor()
{
    level endon("end_game");
    while(1)
    {
        self waittill("chest_accessed");
        if(!isdefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) || !level.zombie_vars["zombie_powerup_fire_sale_on"])
        {
            self thread zm_magicbox::hide_chest();
        }
        level.chest_accessed = 0;
    }
}

OneGobbleOnly()
{
    level endon("end_game");
    self.base_cost = 2500;
    while(1)
    {
        self waittill(#"62124c1e");
        self.var_4d6e7e5e = 0; // showing = 0
        self thread bgb_machine::func_3f75d3b(false);
    }
}

player_bgb_buys_1()
{
    self.var_85da8a33 = 1;
	self clientfield::set_to_player("zm_bgb_machine_round_buys", self.var_85da8a33);
    return false;
}

PlayerDiedCallback()
{
    self.ignoreme++;
    self.origin = self.v_gm_cached_position;
    self setclientuivisibilityflag("hud_visible", true);
    self gm_hud_set_visible(self ishost()); // we shouldn't see other player's bars along with our own. Host will never spectate, so theirs will need to be shown
    self cameraactivate(0);
    self setclientthirdperson(0);
    if(isdefined(level.func_clone_plant_respawn) && isdefined(self.s_clone_plant)) //zetsubou plant func support
        return;

    foreach(player in level.players)
        player UpdateGMProgress(self, true);
    
    foreach(player in level.players)
    {
        if(player == self)
            continue;

        if(player.sessionstate == "playing")
            return;
    }

    level thread restart_round(self);
}

restart_round(last_player)
{
    while(1)
    {
        if(!isdefined(last_player))
            break;
        
        if(last_player.sessionstate != "playing")
            break;

        wait .1;
    }

    level.gm_rubber_banding_scalar = max(0.25f, level.gm_rubber_banding_scalar - GM_ZDMG_RUBBERBAND_PERCENT);
    wait 1;
    goto_round(level.round_number);
}

goto_round(round)
{
    playsoundatposition("zmb_bgb_round_robbin", (0, 0, 0));
    level.skip_alive_at_round_end_xp = true;
    zm_utility::zombie_goto_round(round);
	level notify("kill_round");
}

wait_and_return_weapon()
{
    self endon("disconnect");
    self endon("bled_out");
    wait SPAWN_DELAY;
    self GiveCatalystLoadout();
    self thread GM_FairRespawn();
}

GM_FairRespawn()
{
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");
    self util::waittill_any("bled_out", "spawned_spectator");
    wait PLAYER_RESPAWN_DELAY;
    foreach(player in level.players)
    {
        if(isdefined(player.gm_objective_state) && player.gm_objective_state)
        {
            self thread wait_and_revive_player();
            return;
        }
    }
}

LoadoutRecorder()
{
    self notify("loadout_record");
    self endon("loadout_record");
    self endon("spawned_player");
    self endon("disconnect");
    self endon("bled_out");
    level endon("end_game");

    if(IS_DEBUG && DEBUG_NO_LOADOUTS) return;
    while(true)
    {
        self util::waittill_any_timeout(2, "weapon_change", "weapon_give");
        if(self laststand::player_is_in_laststand())
            continue;
        
        if(self.sessionstate == "spectator")
            continue;

        self.catalyst_loadout = [];
        foreach(weapon in self GetWeaponsList())
        {
            if(!isdefined(weapon))
                continue;
            
            if(weapon.name == "minigun")
                continue;

            if(weapon.name == level.w_widows_wine_grenade.name)
                continue;
            
            struct = spawnstruct();
            struct.weapon = weapon;
            struct.aat = self.AAT[weapon];
            struct.options = self GetWeaponOptions(weapon);
            self.catalyst_loadout[self.catalyst_loadout.size] = struct;
        }
    }
}

GiveCatalystLoadout()
{  
    if(IS_DEBUG && DEBUG_NO_LOADOUTS) return;
    if(!isdefined(self.catalyst_loadout))
        return;

    if(self.sessionstate != "playing")
        return;
    
    foreach(weapon in self getWeaponsListPrimaries())
        self takeWeapon(weapon);

    num_given = 0;
    foreach(item in self.catalyst_loadout)
    {
        weapon = item.weapon;
        options = item.options;

        if(!isdefined(weapon))
            continue;

        if(weapon.name == "minigun")
            continue;
        
        switch(true)
        {
            case zm_utility::is_hero_weapon(weapon):
                if(weapon.rootweapon.name == "skull_gun")
                {
                    self flag::set("has_skull");
                }
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
                if(num_given < zm_utility::get_player_weapon_limit(self))
                {
                    acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, zm_weapons::is_weapon_upgraded(weapon));
                    self GiveWeapon(weapon, options, acvi);
                    self switchtoweaponimmediate(weapon);
                    GiveAAT(self, item.aat, false, weapon);
                    num_given++;
                }
            break;
        }
    }
}

GiveAAT(player, aat, print=true, weapon)
{
    if(!isdefined(player) || !isdefined(aat))
        return;

    if(!isdefined(weapon))
        weapon = AAT::get_nonalternate_weapon(player zm_weapons::switch_from_alt_weapon(player GetCurrentWeapon()));

    player.AAT[weapon] = aat;

    player clientfield::set_to_player("aat_current", level.AAT[ player.AAT[weapon] ].var_4851adad);
}

PlayerDownedCallback(eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    if(self hasperk("specialty_quickrevive") || self bgb::is_enabled("zm_bgb_self_medication"))
    {
        self.n_bleedout_time_multiplier = 1;
        level.solo_lives_given = 0;
        self thread fix_bleedout();
        if(!self bgb::is_enabled("zm_bgb_self_medication"))
        {
            self thread zm::wait_and_revive();
            self unlink();
            self thread zm_bgb_anywhere_but_here::activation();
        }
    }
    else
    {
        if(isdefined(eAttacker) && isdefined(eAttacker._trap_type)) eAttacker = eAttacker.activated_by_player;
        if(weapon_is_ds(weapon)) eAttacker = eAttacker.player;
        if(isdefined(eAttacker) && isplayer(eAttacker) && eAttacker != self)
        {
            eAttacker notify(#"hash_935cc366");
            eAttacker AddRankXp("kill", weapon, undefined, false, true, 100);
            if(!zm_utility::is_hero_weapon(weapon) && eattacker.sessionstate == "playing" && !zm_utility::is_hero_weapon(eattacker getCurrentWeapon()))
            {
                power = eattacker gadgetpowerget(0);
                if(isdefined(power) && power < 100)
                {
                    power = int(min(power + GADGET_PWR_PER_KILL, 100));
                    eattacker GadgetPowerSet(0, power);
                }
            }
            scoreevents::processScoreEvent("kill_mechz", eAttacker);
            eAttacker playlocalsound("prj_bullet_impact_headshot_helmet_nodie_2d");
        }

        KillHeadIcons(self);
        //self notify("bled_out");
        CleanupMusicCheck();
        self.score = 1;
        self.maxhealth = 1;
        self Check_GMObjectiveState();

        self set_death_launch_velocity(eAttacker, weapon, sMeansOfDeath, vDir);

        n_launch_magnitude = min(10, int(iDamage / 1000)) * 25;
        if(isdefined(self.launch_magnitude_extra)) 
            n_launch_magnitude += self.launch_magnitude_extra;

        v_launch_direction_extra = (0,0,0);
        if(isdefined(self.v_launch_direction_extra)) v_launch_direction_extra = self.v_launch_direction_extra;
        self wager_show_self_items();
        clone = self ClonePlayer(1, weapon, eattacker);
        self cameraactivate(1);
        self CameraSetPosition(self geteye());
        self CameraSetLookAt(clone);
        clone.ignoreme = true;
        clone.team = level.zombie_team;
        clone setteam(level.zombie_team);
        clone startragdoll(1);
        clone launchragdoll(vectornormalize(vDir + v_launch_direction_extra) * n_launch_magnitude);
        clone thread DeleteAfter30();
        self.ignoreme++;
        self.no_grab_powerup = true;
        self hide();
        self setclientuivisibilityflag("hud_visible", false);
        self gm_hud_set_visible(false);
        if(player_can_drop_powerups(self, weapon))
        {
            trace = groundtrace(self.origin + vectorscale((0, 0, 1), 5), self.origin + vectorscale((0, 0, -1), 300), 0, undefined);
			origin = trace["position"];
            level zm_spawner::zombie_delay_powerup_drop(origin);
            self widows_wine_drop_grenade(eattacker, weapon);
        }
        self.v_gm_cached_position = self.origin;
        self setorigin((0,0,30000));
    }
    self [[ level._callbackPlayerLastStand ]](eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}

set_death_launch_velocity(e_attacker, w_weapon, sMeansOfDeath, vDir)
{
    if(sMeansOfDeath == "MOD_UNKNOWN") return; // dont set up launch parameters for unk because it will be a wonder weapon or other misc damage
    if(!isdefined(w_weapon) || w_weapon == level.weaponnone) return; // dont setup launch parameters for unknown weapons or weapon none, most likely wonder weapon, etc.

    if(isdefined(level.var_653c9585))
    {
        switch(w_weapon)
        {
            case level.var_e27d2514: // air
            case getweapon("staff_air"):
            case getweapon("staff_air_upgraded"):
            case level.var_75ef78a0: // upgraded
            case level.var_653c9585: // normal
                return;
            default: break;
        }
    }
    
    self.launch_magnitude_extra = 0;
    self.v_launch_direction_extra = (0,0,0);

    if(smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE")
    {
        self.launch_magnitude_extra += 250;
    }

    if(isdefined(w_weapon.isriotshield) && w_weapon.isriotshield)
    {
        self.launch_magnitude_extra = 200;
        self.v_launch_direction_extra = (0,0,0.7);
        return;
    }

    if(w_weapon.rootweapon.name == "dragon_gauntlet" && smeansofdeath == "MOD_MELEE")
    {
        self.launch_magnitude_extra = 50;
        self.v_launch_direction_extra = (0,0,0.7);
        return;
    }
}

fix_bleedout()
{
    self endon("bled_out");
    self waittill("player_revived");
    self.n_bleedout_time_multiplier = N_BLEEDOUT_BASE;
    self zm_score::add_to_player_score(500, 0, "gm_zbr_admin");
    self Event_PointsAdjusted();
}

DeleteAfter30()
{
    self endon("death");
    self endon("deleted");
    wait 30;
    self delete();
}

GM_BeginCountdown()
{
    self endon("bled_out");
    self endon("disconnect");
    level endon("end_game");
    self.gm_objective_timesurvived = 0;

    EntityHeadKillIcon(self, self GetTagOrigin("j_head") - self GetOrigin(), (6,6,0), (1,0,0));

    // respawn players when someone reaches score limit so they can hunt them down
    foreach(player in level.players)
    {
        prefixCol = (player == self) ? "^2" : "^1";

        player thread wait_and_revive_player(prefixCol + self.name + "^7 has reached the score limit!");
    }

    GM_StartMusic();

    while(self.gm_objective_state)
    {
        wait 1;
        while(bgb::is_team_active("zm_bgb_killing_time")) wait 0.25;
        self.gm_objective_timesurvived++;

        foreach(player in level.players)
        {
            player UpdateGMProgress(self);
        }

        if(self.gm_objective_timesurvived >= OBJECTIVE_WIN_TIME)
            break;
    }

    foreach(player in level.players)
    {
        player UpdateGMProgress(self);
    }

    KillHeadIcons(self);
    CleanupMusicCheck();

    if(self.gm_objective_timesurvived >= OBJECTIVE_WIN_TIME)
    {
        if(!isdefined(level.gm_winner))
            level.gm_winner = self;

        foreach(player in level.players)
        {
            if(player == self) continue;
            player.max_points_earned = int(min(player.max_points_earned, self.max_points_earned - 1));
        }
        
        level.elo_game_finished = true;
        level notify("end_game");
        return;
    }
}

wait_and_revive_player(text) // players killed right when objective is completed will now respawn properly
{
    wait SPAWN_DELAY;
    if(self.sessionstate != "playing")
    {
        self [[ level.spawnplayer ]]();
        self thread wait_and_return_weapon();
        if(isdefined(text)) self iPrintLnBold(text);
    }
}

CleanupMusicCheck()
{
    foreach(player in level.players)
        if(player.sessionstate == "playing" && isdefined(player.gm_objective_state) && player.gm_objective_state)
            return;
    GM_KillMusic();
}

EntityHeadKillIcon(entity, offset, size, color)
{
    if(!isDefined(entity) || !isdefined(entity.sessionstate))
        return;
    
    if(entity.sessionstate != "playing")
        return;
    
    shader = "t7_hud_zm_aat_turned";
	headicon = newHudElem();
	headicon.archived = 1;
	headicon.x = offset[0];
	headicon.y = offset[1];
	headicon.z = offset[2];
    headicon.color = color;
	headicon.alpha = 0.8;
	headicon SetShader(shader, size[0], size[1]);
	headicon setWaypoint(false, shader, true, false);
	headicon SetTargetEnt(entity);

    if(!isdefined(entity.entityheadicons))
        entity.entityheadicons = [];

	entity.entityheadicons[entity.entityheadicons.size] = headicon;
}

KillHeadIcons(entity)
{
    if(!isdefined(entity.entityheadicons))
        entity.entityheadicons = [];

    foreach(icon in entity.entityheadicons)
    {
        icon destroy();
    }

    entity.entityheadicons = [];
}

end_game_hud(player, game_over, survived)
{
    player GM_DestroyHUD();
    game_over.alignX = "center";
    game_over.alignY = "middle";
    game_over.horzAlign = "center";
    game_over.vertAlign = "middle";
    game_over.y = game_over.y - 130;
    game_over.foreground = 1;
    game_over.fontscale = 3;
    game_over.alpha = 0;
    game_over.color = (1, 1, 1);
    game_over.hidewheninmenu = 1;

    tPrefix = (isdefined(level.gm_winner) && level.gm_winner == player) ? "^2" : "^1";

    if(isdefined(level.gm_winner))
        game_over setText(tPrefix + toupper(level.gm_winner.name) + " ^7WINS");
    else
        game_over setText("ROUND DRAW");
    
    game_over fadeOverTime(1);
    game_over.alpha = 1;
    if(player IsSplitscreen())
    {
        game_over.fontscale = 2;
        game_over.y = game_over.y + 40;
    }

    survived.alignX = "center";
    survived.alignY = "middle";
    survived.horzAlign = "center";
    survived.vertAlign = "middle";
    survived.y = survived.y - 100;
    survived.foreground = 1;
    survived.fontscale = 2;
    survived.alpha = 0;
    survived.color = (1, 1, 1);
    survived.hidewheninmenu = 1;
    if(player IsSplitscreen())
    {
        survived.fontscale = 1.5;
        survived.y = survived.y + 40;
    }
    if(isdefined(level.gm_winner))
    {
        nvials = player GM_MBVIALS();
        mbtext = "MATCH BONUS: ^2" + player GM_MBXP() + " ^3XP, ^2" + nvials + " ^3VIAL" + (nvials == 1 ? "" : "S");
        mbt = player createText("default", 2, "CENTER", "BOTTOM", 0, -190, 1, 1, mbtext, (1,1,1));
        mbt.hidewheninmenu = 1;
        mbt.foreground = true;
    }
    credits = player createText("default", 1.25, "CENTER", "BOTTOM", 0, -50, 1, 0.5, "Thank you for playing Zombie Blood Rush, by Serious", (1,1,1));
    credits.hidewheninmenu = 1;
    credits.foreground = true;
    mbt thread KillOnIntermission(survived);
    credits thread KillOnIntermission(survived);
}

KillOnIntermission(h)
{
    h waittill("death");
    self destroy();
}

GM_MBXP()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    if(self.max_points_earned < 0)
        self.max_points_earned = 0;
        
    max_points_earned = self.max_points_earned;
    if(max_points_earned > WIN_NUMPOINTS)
        max_points_earned = WIN_NUMPOINTS;

    n_reward = max_points_earned / 50;
    s_wager = get_wager_tier(self.wager_tier);
    if(isdefined(s_wager) && isdefined(s_wager.bonus_currency))
    {
        n_reward *= s_wager.bonus_currency;
    }

    self AddRankXp("kill", undefined, undefined, false, true, int(n_reward));
    return int(n_reward);
}

GM_MBVIALS()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    if(self.max_points_earned < 0)
        self.max_points_earned = 0;
        
    max_points_earned = self.max_points_earned;
    if(max_points_earned > WIN_NUMPOINTS)
        max_points_earned = WIN_NUMPOINTS;

    numvials = int(max_points_earned / int(WIN_NUMPOINTS / 5));
    s_wager = get_wager_tier(self.wager_tier);
    if(isdefined(s_wager) && isdefined(s_wager.bonus_currency))
    {
        numvials = int(numvials * s_wager.bonus_currency);
    }

    self ReportLootReward("3", numvials);
    for(i = 0; i < numvials; i++)
        self incrementbgbtokensgained();

    self.var_f191a1fc += numvials;
    return numvials;
}

gm_spectator()
{
    self notify("gm_spectator");
    self endon("gm_spectator");
    self endon("disconnect");
    self endon("spawned_player");
    level endon("end_game");
    self waittill("spawned_spectator");
    
    wait 1;
    if(self.sessionstate == "playing") return;

    if(isdefined(self.spectate_obj))
        self.spectate_obj destroy();

    self.spectate_obj = spawn("script_origin", self.origin, 1);
    self PlayerLinkTo(self.spectate_obj, undefined);
    self enableweapons();
}

#define BASE_OFFSET = 110;
#define CLIENT_WHITE = 0;
#define CLIENT_BLUE = 1;
#define CLIENT_YELLOW = 2;
#define CLIENT_GREEN = 3;
GM_CreateHUD()
{
    self notify("GM_CreateHUD");
    self endon("GM_CreateHUD");
    if(!isdefined(self.objectives_shown_finished) && self.objectives_shown_finished)
        return;

    if(IS_DEBUG && DEBUG_NO_GM_HUD) return;
    
    if(self util::is_bot())
        return;

    if(!isdefined(self.sessionstate) || self.sessionstate != "playing")
        return;

    if(!isdefined(self._bars))
        self._bars = [];

    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;

    if(!isdefined(self._bars[self GetEntityNumber()]))
    {
        self._bars[self GetEntityNumber()] = self CreateProgressBar("LEFT", "LEFT", 15, BASE_OFFSET + 0, 50, 8, self GM_GetPlayerColor(), 0);
        self._bars[self GetEntityNumber()].player = self;
        self._bars[self GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 67, BASE_OFFSET + 0, 8, self GM_GetPlayerColor(true), 0);
    }
    
    self UpdateGMProgress(self);

    i = -10;
    foreach(player in level.players)
    {
        if(player == self) continue;
        if(!isdefined(self._bars[player GetEntityNumber()]))
        {
            self._bars[player GetEntityNumber()] = self CreateProgressBar("LEFT", "LEFT", 15, BASE_OFFSET + i, 50, 8, player GM_GetPlayerColor(), 0);
            self._bars[player GetEntityNumber()].player = player;
            self._bars[player GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 67, BASE_OFFSET + i, 8, player GM_GetPlayerColor(true), 0);
        }
        i -= 10;
        self UpdateGMProgress(player);
    }
}

gm_hud_set_visible(visible = true)
{
    if(IS_DEBUG && DEBUG_NO_GM_HUD) return;
    
    if(self util::is_bot())
        return;

    if(!isdefined(self._bars))
        return;
    
    self.gm_hud_hide = !visible;
    foreach(bar in self._bars) self UpdateGMProgress(bar);
}

GM_GetPlayerColor(nored = false)
{
    if(!isdefined(self.score))
        self.score = 0;
    
    if(!nored && self.score >= self Get_PointsToWin())
        return color(0xc90e0e);
    
    switch(self getEntityNumber())
    {
        case CLIENT_BLUE:
            return color(0x59a7e3);

        case CLIENT_GREEN:
            return color(0x83e683);

        case CLIENT_YELLOW:
            return color(0xe6da83);
        
        default:
            return color(0xAAAAAA);
    }
}

UpdateGMProgress(player_or_bar, dead = false)
{
    self endon("disconnect");

    if(self util::is_bot())
    {
        return;
    }

    if(!isdefined(player_or_bar))
    {
        return;
    }

    if(!isdefined(self._bars))
    {
        self._bars = [];
    }

    if(isplayer(player_or_bar))
    {
        player = player_or_bar;
        bar = self._bars[player GetEntityNumber()];
    }
    else
    {
        bar = player_or_bar;
        player = bar.player;
    }

    if(!isdefined(bar))
    {
        return;
    }

    score = 0;
    ptw = WIN_NUMPOINTS;
    alive = false;
    objective_state = undefined;
    if(isdefined(player))
    {
        player endon("disconnect");
        if(!isdefined(player.gm_objective_state))
        {
            player.gm_objective_state = false;
        }
        if(!isdefined(player.score))
        {
            player.score = 0;
        }
        bar.dimmed = player.gm_objective_state;
        bar.primarycolor = player GM_GetPlayerColor(true);
        bar.secondarycolor = player GM_GetPlayerColor();
        score = player.score;
        ptw = player Get_PointsToWin();
        alive = player.sessionstate == "playing";
        objective_state = player.gm_objective_state;
    }

    SetProgressbarPercent(bar, float(score) / ptw);

    if(isdefined(bar.box))
    {
        SetChecked(bar.box, alive && !dead);
    }

    if(!isdefined(objective_state) || !objective_state)
    {
        SetProgressbarSecondaryPercent(bar, 0);
        return;
    }

    // player will be defined here because objective_state is undefined otherwise, which returns in the previous check
    if(!isdefined(player.gm_objective_timesurvived))
    {
        player.gm_objective_timesurvived = 0;
    }
    SetProgressbarSecondaryPercent(bar, player.gm_objective_timesurvived / OBJECTIVE_WIN_TIME);
}

on_player_disconnect()
{
    ent = self getEntityNumber();
    foreach(player in level.players)
    {
        if(player == self) continue;
        if(!isdefined(player._bars)) continue;
        bar = player._bars[ent];
        if(!isdefined(bar)) continue;
        bar.dimmed = false;
        bar.primarycolor = (0,0,0);
        bar.secondarycolor = (0,0,0);
        player SetProgressbarSecondaryPercent(bar, 0);
        player thread SetProgressbarPercent(bar, 0);
        if(isdefined(bar.box))
        {
            player thread SetChecked(bar.box, false);
        }
    }
}

color(value)
{
    return
    (
    (value & 0xFF0000) / 0xFF0000,
    (value & 0x00FF00) / 0x00FF00,
    (value & 0x0000FF) / 0x0000FF
    );
}

GM_DestroyHUD()
{
    if(self util::is_bot())
        return;
    
    if(!isdefined(self._bars))
        self._bars = [];

    foreach(hud in self._bars)
    {
        if(isdefined(hud.bg))
        {
            hud.bg destroy();
        }
        
        if(isdefined(hud.fill))
        {
            hud.fill destroy();
        }
        
        if(isdefined(hud.bgfill))
            hud.bgfill destroy();

        if(isdefined(hud.box))
        {
            if(isdefined(hud.box.bg))
                hud.box.bg destroy();

            if(isdefined(hud.box.fill))
                hud.box.fill destroy();
        }
    }
    self._bars = [];
}

#define OBJECTIVE_HUD_OFF_Y = 50;
#define OBJECTIVE_Y_SPACE = 20;
GM_ShowObjectives()
{
    if(isdefined(self.objectives_shown))
    {
        self GM_CreateHUD();
        return;
    } 
    
    self.objectives_shown = true;

    level flag::wait_till("initial_blackscreen_passed");
    
    obj = 
    [
        "Your points are now your health",
        "Kill zombies and other players to gain points",
        "Hold 100,000 points for 2 minutes to win"
    ];

    i = 0;
    foreach(o in obj)
    {
        hud = self createText("objective", 2, "TOPLEFT", "TOPLEFT", 25, OBJECTIVE_HUD_OFF_Y + i * OBJECTIVE_Y_SPACE, 1, 1, o, (.75,.75,1));
        hud setCOD7DecodeFX(int(OBJECTIVE_DECODE_TIME * 1000 / o.size), (OBJECTIVE_SHOW_TIME - 1) * 1000, 500);
        hud thread KillObjective();
        wait .5;
        i++;
    }

    wait OBJECTIVE_SHOW_TIME;
    self.objectives_shown_finished = true;
    wait .1;
    self GM_CreateHUD();
}

KillObjective()
{
    wait OBJECTIVE_SHOW_TIME;
    self destroy();
}

apply_door_prices()
{
    a_door_buys = getentarray("zombie_door", "targetname");
    array::thread_all(a_door_buys, serious::door_price_reduction);
    a_debris_buys = getentarray("zombie_debris", "targetname");
    array::thread_all(a_debris_buys, serious::door_price_reduction);
}

door_price_reduction()
{
	if(self.zombie_cost >= DOOR_REDUCE_MIN_PRICE)
	{
		if(self.zombie_cost >= DOOR_REDUCE_TWICE_MIN_PRICE) // do it twice for doors which are this expensive
		{
			self.zombie_cost = self.zombie_cost - DOOR_REDUCE_AMOUNT;
		}
        self.zombie_cost = self.zombie_cost - DOOR_REDUCE_AMOUNT;
		if(self.targetname == "zombie_door")
		{
			self zm_utility::set_hint_string(self, "default_buy_door", self.zombie_cost);
		}
		else
		{
			self zm_utility::set_hint_string(self, "default_buy_debris", self.zombie_cost);
		}
	}
}

// fixes an issue where the game resets players health to 100 each round
quick_revive_hook()
{
    if(isdefined(level._check_quickrevive_hotjoin))
    {
        self [[ level._check_quickrevive_hotjoin ]]();
    }

	foreach(player in getplayers())
    {
        player thread Event_PointsAdjusted();
    }
}

player_score_override(damage_weapon, n_score)
{
    if(isdefined(level._player_score_override))
    {
        n_score = self [[level._player_score_override]](damage_weapon, n_score);
    }
    if(isdefined(n_score) && isdefined(self.wager_zm_points_mod) && isdefined(self.wager_zm_points_drop))
    {
        if(n_score == 10 || n_score == 20)
        {
            self.wager_zm_points_drop = (self.wager_zm_points_drop + 1) % 4;
            if(!self.wager_zm_points_drop)
            {
                return 0;
            }
        }
        n_score = int(n_score * self.wager_zm_points_mod);
    }
    return n_score;
}

get_player_weapon_limit(player, no_perk = false)
{
    weapon_limit = 2;
    if(isdefined(player.wager_weapon_slot))
    {
        weapon_limit--;
    }
	if(!no_perk && (player hasperk("specialty_additionalprimaryweapon")))
	{
		weapon_limit++;
	}
    return weapon_limit;
}

mulekick_take(b_pause, str_perk, str_result)
{
    if(b_pause || str_result == str_perk)
	{
		self take_additionalprimaryweapon();
	}
}

take_additionalprimaryweapon()
{
	weapon_to_take = level.weaponnone;
	if(isdefined(self._retain_perks) && self._retain_perks || (isdefined(self._retain_perks_array) && (isdefined(self._retain_perks_array["specialty_additionalprimaryweapon"]) && self._retain_perks_array["specialty_additionalprimaryweapon"])))
	{
		return weapon_to_take;
	}
	primary_weapons_that_can_be_taken = [];
	primaryweapons = self getweaponslistprimaries();
	for(i = 0; i < primaryweapons.size; i++)
	{
		if(zm_weapons::is_weapon_included(primaryweapons[i]) || zm_weapons::is_weapon_upgraded(primaryweapons[i]))
		{
			primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryweapons[i];
		}
	}
	self.weapons_taken_by_losing_specialty_additionalprimaryweapon = [];
	pwtcbt = primary_weapons_that_can_be_taken.size;
	while(pwtcbt > get_player_weapon_limit(self))
	{
		weapon_to_take = primary_weapons_that_can_be_taken[pwtcbt - 1];
		self.weapons_taken_by_losing_specialty_additionalprimaryweapon[weapon_to_take] = zm_weapons::get_player_weapondata(self, weapon_to_take);
		pwtcbt--;
		if(weapon_to_take == self getcurrentweapon())
		{
			self switchtoweapon(primary_weapons_that_can_be_taken[0]);
		}
		self takeweapon(weapon_to_take);
	}
	return weapon_to_take;
}

watch_falling_forever()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");

    while(true)
    {
        wait 1;
        origin = self.origin;
        if(!isdefined(origin)) continue;
        if(origin[2] <= -20000)
        {
            self doDamage(int(self.maxhealth + 1), self.origin);
        }
    }
}

zm_round_failsafe()
{
    level endon("game_ended");
    while(true)
    {
        i = 0;
        while(getaiteamarray(level.zombie_team).size < 5 && i < ROUND_NO_AI_TIMEOUT)
        {
            i++;
            wait 1;
        }
        if(ROUND_NO_AI_TIMEOUT <= i)
        {
            goto_round(level.round_number + 1);
            wait 25;
        }
        wait 5;
    }
}
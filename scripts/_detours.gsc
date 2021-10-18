#ifdef DETOURS

#region Axis AI Assumption Fixes

detour sys::getaiteamarray(team)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    return getaiteamarray(team);
}

detour sys::getvehicleteamarray(team)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    return getvehicleteamarray(team);
}

detour sys::getaispeciesarray(team, species)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    if(isdefined(species))
    {
        return getaispeciesarray(team, species);
    }
    return getaispeciesarray(team);
}

detour sys::getaiarchetypearray(archetype, team)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    if(isdefined(team))
    {
        return getaiarchetypearray(archetype, team);
    }
    return getaiarchetypearray(archetype);
}

detour spawner<scripts\shared\spawner_shared.gsc>::add_global_spawn_function(team, spawn_func, param1, param2, param3, param4, param5)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    spawner::add_global_spawn_function(team, spawn_func, param1, param2, param3, param4, param5);
}

#endregion

#region Allies Team Assumption Fixes

detour util<scripts\shared\util_shared.gsc>::any_player_is_touching(ent, str_team)
{
    foreach(player in getplayers())
	{
		if(isalive(player) && player istouching(ent))
		{
			return true;
		}
	}
    return false;
}

detour sys::playsoundtoteam(sound, team)
{
    if(isdefined(team) && team == "allies" && isdefined(level.gm_teams))
    {
        foreach(str_team in level.gm_teams)
        {
            self playsoundtoteam(sound, str_team);
        }
        return;
    }
    self playsoundtoteam(sound, team);
}

#endregion

// this enables detours on map scripts by doing a post link detour
detour system<scripts\shared\system_shared.gsc>::register(str_system, func_preinit, func_postinit, reqs = [])
{
    if(isdefined(str_system))
    {
        switch(str_system)
        {
            case "zm_island_side_ee_spore_hallucinations":
                clientfield::register("toplayer", "hallucinate_bloody_walls", 9000, 1, "int");
	            clientfield::register("toplayer", "hallucinate_spooky_sounds", 9000, 1, "int");
                return;
            case "zm_island_side_ee_secret_maxammo":
            case "zm_island_side_ee_doppleganger":
                return;
            case "zm_island_side_ee_good_thrasher":
                var_d1cfa380 = getminbitcountfornum(7);
                var_a15256dd = getminbitcountfornum(3);
                clientfield::register("scriptmover", "side_ee_gt_spore_glow_fx", 9000, 1, "int");
                clientfield::register("scriptmover", "side_ee_gt_spore_cloud_fx", 9000, var_d1cfa380, "int");
                clientfield::register("actor", "side_ee_gt_spore_trail_enemy_fx", 9000, 1, "int");
                clientfield::register("allplayers", "side_ee_gt_spore_trail_player_fx", 9000, var_a15256dd, "int");
                clientfield::register("actor", "good_thrasher_fx", 9000, 1, "int");
                return;
            case "controllable_spider":
            case "zm_castle_weap_quest_upgrade":
            case "zm_zod_robot":
            case "zm_ai_spiders":
            case "zm_genesis_companion":
            case "zm_trap_electric":
            case "zm_island_skullquest":
                compiler::relinkdetours();
            break;
        }
    }
    system::register(str_system, func_preinit, func_postinit, reqs);
}

#region zm_island fixes

// disable activating rounds
detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d2716ad8()
{
}

// disable activating rounds
detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_2a424152()
{
}

detour zm_island_spiders<scripts\zm\zm_island_spiders.gsc>::function_33aa4940()
{
    return 0;
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_f4bd92a2(n_to_spawn, s_spawn_point)
{
    return undefined;
}

detour zm_island<scripts\zm\zm_island.gsc>::on_player_spawned()
{
    if(!isdefined(self.zm_island_on_player_spawned))
    {
        self.zm_island_on_player_spawned = true;
        self thread [[ @zm_island<scripts\zm\zm_island.gsc>::on_player_spawned ]]();
    }
    if(level flag::get("flag_play_outro_cutscene"))
	{
		if(self.characterindex != 2)
		{
			wait(0.1);
			self setcharacterbodystyle(1);
		}
	}
	self.is_ziplining = 0;
	self.no_revive_trigger = 0;
	self.var_90f735f8 = 0;
    self.tesla_network_death_choke = 0;
	self.var_7149fc41 = 0;
	if(isdefined(self.thrasher))
	{
		self.thrasher kill();
	}
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_85773a07()
{
    // do nothing
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_aeef1178()
{
    // do nothing
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_df4d1d4()
{
    // do nothing
}

detour namespace_d9f30fb4<scripts\zm\zm_island_side_ee_golden_bucket.gsc>::function_e6cfa209()
{
    // do nothing
}

detour zm_island_side_ee_spore_hallucinations<scripts\zm\zm_island_side_ee_spore_hallucinations.gsc>::on_player_spawned()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::on_player_spawned()
{
    if(!isdefined(self.zm_island_skullquest_onplayerspawned))
    {
        self.zm_island_skullquest_onplayerspawned = true;
        self thread [[ @zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::on_player_spawned ]]();
    }
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_940267cd()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_ba04e236()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_e0075c9f()
{
    // do nothing
}

detour zm_island_vo<scripts\zm\zm_island_vo.gsc>::on_player_spawned()
{
    // do nothing
    if(!isdefined(self.zm_island_vo_on_player_spawned))
    {
        self.zm_island_vo_on_player_spawned = true;
        self thread [[ @zm_island_vo<scripts\zm\zm_island_vo.gsc>::on_player_spawned ]]();
    }
}

detour zm_island_ww_quest<scripts\zm\zm_island_ww_quest.gsc>::function_598781a4()
{
    // do nothing
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d3c8090f()
{
    if(!isdefined(self.zm_ai_spiders_function_d3c8090f))
    {
        self.zm_ai_spiders_function_d3c8090f = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d3c8090f ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_eb951410()
{
    if(!isdefined(self.zm_ai_spiders_function_eb951410))
    {
        self.zm_ai_spiders_function_eb951410 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_eb951410 ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_7d50634d()
{
    if(!isdefined(self.zm_ai_spiders_function_7d50634d))
    {
        self.zm_ai_spiders_function_7d50634d = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_7d50634d ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_83a70ec3()
{
    if(!isdefined(self.zm_ai_spiders_function_83a70ec3))
    {
        self.zm_ai_spiders_function_83a70ec3 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_83a70ec3 ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d717ef02()
{
    if(!isdefined(self.zm_ai_spiders_function_d717ef02))
    {
        self.zm_ai_spiders_function_d717ef02 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d717ef02 ]]();
    }
}

detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_b2a01f79()
{
    if(!isdefined(self.controllable_spider_function_b2a01f79))
    {
        self.controllable_spider_function_b2a01f79 = true;
        self thread [[ @controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_b2a01f79 ]]();
    }
}

// detour flag<scripts\shared\flag_shared.gsc>::init(str_flag, b_val = 0, b_is_trigger = 0)
// {
//     if(isdefined(str_flag) && str_flag == "flag_init_challenge_pillars")
//     {
//         compiler::relinkdetours();
//     }
//     self flag::init(str_flag, b_val, b_is_trigger);
// }

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::on_player_disconnect()
{

}

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::on_player_connect()
{

}

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::main()
{
    array::run_all(getentarray("t_lookat_challenge_1", "targetname"), sys::delete);
    array::run_all(getentarray("t_lookat_challenge_2", "targetname"), sys::delete);
    array::run_all(getentarray("t_lookat_challenge_3", "targetname"), sys::delete);
    array::thread_all(struct::get_array("s_challenge_trigger"), struct::delete);
    struct::get("s_challenge_altar") struct::delete();
}

#endregion

#region zm_castle changes

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::elemental_storm_wallrun()
{
    // storm bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_be03e13e()
{
    // storm bow step 3
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_292ad7f1()
{
    // fire bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_fd254a35()
{
    // fire bow step 3
    e_ball = getent("aq_rp_magma_ball_tag", "targetname");
    fn_monitor_progress = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_5f8f4823;
    e_ball thread [[ fn_monitor_progress ]]();
    wait 10;
    e_ball notify("final");
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_5170090a()
{
    // void bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::demon_gate_crawlers()
{
    // void bow step 3
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::demon_gate_runes()
{
    // void bow step 4
    level [[ @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_b9fe51c7 ]]();
    level [[ @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_695d82fd ]]();
	level.var_ca3b8551 = undefined;
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_37acbc24()
{
    // wolf bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::wolf_howl_escort()
{
    // wolf bow step 3
}

#endregion

#region misc fixes

// fixes an issue where between rounds, you can get 1 shot killed during the health reset
detour zm_perks<scripts\zm\_zm_perks.gsc>::perk_set_max_health_if_jugg(str_perk, set_premaxhealth, clamp_health_to_max_health)
{
    // do nothing, because juggernog works differently in our mode
}

#endregion

#endif
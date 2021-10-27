#define V_PAP_ANGLE_OFFSET = (0,-90,0);
#define V_BOX_ANGLE_OFFSET = (0,90,0);
#define V_WALL_ANGLE_OFFSET = (0,90,0);
#define V_PERK_ANGLE_OFFSET = (0,-90,0);
#define V_GUM_ANGLE_OFFSET = (0,-90,0);

#define MAX_DOOR_POIS = 10;
#define MAX_WALL_POIS = 10;
#define MAX_BOX_POIS = 10;
#define MAX_PERK_POIS = 10;
#define MAX_GUM_POIS = 8;
#define MAX_PAP_POIS = 2;
#define MAX_POIS = 50; // extra clamp to reduce performance impact.

initmaps()
{
    gm_maps_val = isdefined(level.gm_init_maps) && level.gm_init_maps;

    if(gm_maps_val)
    {
        while(!isdefined(level.gm_locked) || level.gm_locked) // this lock prevents async spawn operations from failing
        {
            wait 0.05;
        }
        return;
    }

    level.gm_init_maps = true;
    level.gm_locked = true;

    foreach(k, v in level.zones)
    {
        thread zm_zonemgr::enable_zone(k);
    }

    if(!isdefined(level.b_use_poi_spawn_system))
    {
        level.b_use_poi_spawn_system = IS_DEBUG && DEV_FORCE_POI_SPAWNS;
    }
    
    level.gm_spawns = [];
    level.gm_blacklisted = [];
    index = 0;

    auto_blacklist_zones();
    switch(level.script)
    {
        case "zm_zod":
            level.gm_spawns[level.gm_spawns.size] = "zone_slums_D";
            level.gm_spawns[level.gm_spawns.size] = "zone_start";
            level.gm_spawns[level.gm_spawns.size] = "zone_canal_D";
            level.gm_spawns[level.gm_spawns.size] = "zone_theater_C";
            level.gm_oob_monitors = [   
                                        serious::zm_zod_oob_check1,
                                        serious::zm_zod_oob_check2,
                                        serious::zm_zod_oob_check3
                                    ];
            thread zm_zod_pap();
            break;

        case "zm_factory":
            level.gm_spawns[level.gm_spawns.size] = "receiver_zone";
            level.gm_spawns[level.gm_spawns.size] = "tp_south_zone";
            level.gm_spawns[level.gm_spawns.size] = "tp_west_zone";
            level.gm_spawns[level.gm_spawns.size] = "tp_east_zone";
            thread zm_factory_pap();
            break;

        case "zm_castle":
            level.gm_spawns[level.gm_spawns.size] = "zone_start";
            level.gm_spawns[level.gm_spawns.size] = "zone_rooftop";
            level.gm_spawns[level.gm_spawns.size] = "zone_undercroft";
            level.gm_spawns[level.gm_spawns.size] = "zone_lower_courtyard_back";

            level.gm_blacklisted[level.gm_blacklisted.size] = "zone_v10_pad";
            level.gm_blacklisted[level.gm_blacklisted.size] = "zone_v10_pad_door";
            level.gm_blacklisted[level.gm_blacklisted.size] = "zone_v10_pad_exterior";
            level.gm_oob_monitors = [   
                                        serious::zm_castle_oob_check1,
                                        serious::zm_castle_oob_check2
                                    ];
            thread zm_castle_pap();
            break;

        case "zm_island":
            level.gm_spawns[level.gm_spawns.size] = "zone_start_water";
            level.gm_spawns[level.gm_spawns.size] = "zone_bunker_left";
            level.gm_spawns[level.gm_spawns.size] = "zone_operating_rooms";
            level.gm_spawns[level.gm_spawns.size] = "zone_meteor_site_2";
            thread zm_island_pap();
            break;
        
        case "zm_stalingrad":
            level.gm_spawns[level.gm_spawns.size] = "start_A_zone";
            level.gm_spawns[level.gm_spawns.size] = "judicial_A_zone";
            level.gm_spawns[level.gm_spawns.size] = "library_B_zone";
            level.gm_spawns[level.gm_spawns.size] = "factory_B_zone";

            level.gm_blacklisted[level.gm_blacklisted.size] = "boss_arena_zone";
            level.gm_blacklisted[level.gm_blacklisted.size] = "pavlovs_B_zone";
            level.gm_oob_monitors = [   
                                        serious::zm_stalingrad_oob_check1,
                                        serious::zm_stalingrad_oob_check2
                                    ];
            level.zbr_wager_exclude_weapons = [
                                                getweapon("launcher_dragon_fire"),
                                                getweapon("launcher_dragon_strike"),
                                                getweapon("launcher_gauntlet_flamethrower")
                                              ];
            thread zm_stalingrad_pap();
        break;

        case "zm_genesis":
            level.gm_spawns[level.gm_spawns.size] = "start_zone";
            level.gm_spawns[level.gm_spawns.size] = "zm_prison_mess_hall_zone";
            level.gm_spawns[level.gm_spawns.size] = "zm_asylum_kitchen2_zone";
            level.gm_spawns[level.gm_spawns.size] = "zm_theater_stage_zone";
            
            level.gm_blacklisted[level.gm_blacklisted.size] = "zm_prototype_outside_zone";
            thread zm_genesis_map();
            break;

        case "zm_prototype":
            gm_generate_spawns(); // this map is just too small, so we can populate more spawn points and use POI spawns
        break;

        case "zm_asylum":
            level.gm_spawns[level.gm_spawns.size] = "west2_downstairs_zone";
            level.gm_spawns[level.gm_spawns.size] = "south2_upstairs_zone";
            level.gm_spawns[level.gm_spawns.size] = "kitchen_upstairs_zone";
            level.gm_spawns[level.gm_spawns.size] = "north_upstairs_zone";
        break;

        case "zm_sumpf":
            level.gm_spawns[level.gm_spawns.size] = "center_building_upstairs";
            level.gm_spawns[level.gm_spawns.size] = "northwest_building";
            level.gm_spawns[level.gm_spawns.size] = "southwest_building";
            level.gm_spawns[level.gm_spawns.size] = "southeast_building";
        break;

        case "zm_theater":
            level.gm_spawns[level.gm_spawns.size] = "foyer_zone";
            level.gm_spawns[level.gm_spawns.size] = "stage_zone";
            level.gm_spawns[level.gm_spawns.size] = "alleyway_zone";
            level.gm_spawns[level.gm_spawns.size] = "dining_zone";
        break;

        case "zm_cosmodrome":
            level.gm_spawns[level.gm_spawns.size] = "centrifuge_zone";
            level.gm_spawns[level.gm_spawns.size] = "north_catwalk_zone3";
            level.gm_spawns[level.gm_spawns.size] = "storage_lander_zone";
            level.gm_spawns[level.gm_spawns.size] = "storage_zone2";
            level.gm_oob_monitors = [   
                                        serious::zm_cosmodrome_oob_check1, 
                                        serious::zm_cosmodrome_oob_check2, 
                                        serious::zm_cosmodrome_oob_check3 
                                    ];
            thread zm_cosmodrome_pap();
        break;

        case "zm_temple":
            level.gm_spawns[level.gm_spawns.size] = "temple_start_zone";
            level.gm_spawns[level.gm_spawns.size] = "waterfall_lower_zone";
            level.gm_spawns[level.gm_spawns.size] = "cave_tunnel_zone";
            level.gm_spawns[level.gm_spawns.size] = "caves2_zone";

            level.gm_oob_monitors = [   
                                        serious::zm_temple_oob_check1,
                                        serious::zm_temple_oob_check2,
                                        serious::zm_temple_oob_check3,
                                        serious::zm_temple_oob_check4,
                                        serious::zm_temple_oob_check5
                                    ];
            thread zm_temple_pap();
        break;

        case "zm_moon":
            level.gm_spawns[level.gm_spawns.size] = "bridge_zone";
            level.gm_spawns[level.gm_spawns.size] = "cata_right_start_zone";
            level.gm_spawns[level.gm_spawns.size] = "forest_zone";
            level.gm_spawns[level.gm_spawns.size] = "generator_exit_east_zone";

            level.gm_blacklisted[level.gm_blacklisted.size] = "nml_zone";

            thread zm_moon_pap();
        break;

        case "zm_tomb":
            level.gm_spawns[level.gm_spawns.size] = "zone_start";
            level.gm_spawns[level.gm_spawns.size] = "zone_ice_stairs";
            level.gm_spawns[level.gm_spawns.size] = "zone_nml_farm";
            level.gm_spawns[level.gm_spawns.size] = "zone_nml_11";

            for(i = 0; i < 9; i++)
            {
                level.gm_blacklisted[level.gm_blacklisted.size] = "zone_chamber_" + i;
            }
            thread zm_tomb_pap();
        break;

        default:
            custom_maps();
            break;
    }

    level.gm_locked = false;
    if(level.gm_spawns.size < 1)
        return;

    level.gm_spawns = array::randomize(level.gm_spawns);
}

//should only be used at game start
GetRandomMapSpawn(player, return_struct = false, ignore_poi = false)
{
    initmaps();

    player on_player_connect();

    if(isdefined(player.gmspawn) && is_zbr_teambased())
    {
        teammates = player get_zbr_teammates(true);
        if(isdefined(teammates) && isdefined(teammates.size) && teammates.size > 0)
        {
            if(isdefined(teammates[0].initial_spawn_fix) && teammates[0].initial_spawn_fix && !(isdefined(teammates[0].gm_in_combat) && teammates[0].gm_in_combat))
            {
                spawn = get_player_spawnable_point(teammates[0], return_struct, ignore_poi);
                if(isdefined(spawn))
                {
                    return spawn;
                }
            }
        }
    }

    if(!ignore_poi && (isdefined(level.b_use_poi_spawn_system) && level.b_use_poi_spawn_system))
        return gm_select_poi_spawn(player, return_struct);

    if(!isdefined(level.gm_spawns) || level.gm_spawns.size < 1)
    {
        player.last_spawn_succeeded = false;
        return undefined;
    }

    if(isdefined(player.gmspawn))
        spawn = GetGMSpawn(player, return_struct);
    
    if(!isdefined(spawn))
        spawn = GetRandStartZone(player, return_struct);
    
    player.last_spawn_succeeded = isdefined(spawn);
    
    return spawn;
}

get_player_spawnable_point(player, return_struct = false, ignore_poi = false)
{
    if(!isdefined(player))
    {
        return undefined;
    }
    
    // 1: check if poi spawns are enabled, if so, find one close to here
    if(!ignore_poi && isdefined(level.b_use_poi_spawn_system) && level.b_use_poi_spawn_system)
    {
        gm_generate_poi_spawns();

        v_closest = undefined;
        n_closest = undefined;
        foreach(v_spawn in level.a_v_poi_spawns)
        {
            n_dist = distance2d(v_spawn, player.origin);
            if(!isdefined(n_closest) || n_closest > n_dist)
            {
                n_closest = n_dist;
                v_closest = v_spawn;
            }
        }

        if(isdefined(v_closest))
        {
            return return_struct ? gm_poi_get_best_spawn(v_closest) : v_closest;
        }
    }

    // 2: if not, return a zone spawn in the same zone (if it exists)
    zone = player zm_utility::get_current_zone(false);
    if(isdefined(zone))
    {
        spawns = GetAllSpawnsFromZone(zone);
        if(isdefined(spawns) && isdefined(spawns.size) && spawns.size > 0)
        {
            return return_struct ? gm_poi_get_best_spawn(spawns[0].origin) : spawns[0].origin;
        }
    }

    // 3: finally, if still no spawn, return the player's origin, only if it is within the playable space
    if(!zm_utility::check_point_in_playable_area(player getorigin()))
    {
        return GetGMSpawn(self, true, true);
    }

    return return_struct ? gm_poi_get_best_spawn(player getorigin()) : (player getorigin());
}

Try_Respawn(no_initial = false)
{
    if(IS_DEBUG && DEBUG_REVERT_SPAWNS) return;
    if(no_initial)
    {
        spawn = GetGMSpawn(self, true).origin;
    }
    else
    {
        spawn = GetRandomMapSpawn(self);
    }
    
    if(isdefined(spawn))
        self SetOrigin(spawn);
}

GetRandStartZone(player, return_struct)
{
    if(!isdefined(level.gm_spawns))
        level.gm_spawns = [];

    if(!isdefined(player.gm_id))
    {
        player on_player_connect();
    }
    
    if(level.gm_spawns.size < 1 && !isdefined(player.gmspawn))
        return GetGMSpawn(player, return_struct, true);
    
    spawn_zone = level.gm_spawns[player.gm_id % level.gm_spawns.size];
    player.gmspawn = spawn_zone;
    player.visited_zones = [];

    return GetSpawnFromZone(player, return_struct, spawn_zone);
}

GetAllSpawnsFromZone(player, zone = "none")
{
    respawn_points = struct::get_array("player_respawn_point", "targetname");
    target_zone = level.zones[zone];
    target_point = undefined;

    if(!isdefined(target_zone))
    {
        return [];
    }

    final_array = [];
    foreach(point in respawn_points)
    {
        if(!isdefined(point) || !isdefined(point.target))
            continue;
        
        spawn_array = struct::get_array(point.target, "targetname");

        foreach(spawn in spawn_array)
        {
            if(!isdefined(spawn))
                continue;
            
            if(is_point_inside_zone(spawn.origin, target_zone))
            {
                final_array[final_array.size] = spawn;
            }
        }
    }

    final_array = array::randomize(final_array);
    return final_array;
}

GetSpawnFromZone(player, return_struct, spawn_zone)
{
    spawn_array = GetAllSpawnsFromZone(player, spawn_zone);
    if(return_struct) return spawn_array[0];
    return spawn_array[0].origin;
}

GetGMSpawn(player, return_struct, no_start = false)
{
    ideal_spawns = [];
    if(isdefined(player.visited_zones) && player.visited_zones.size > 0)
    {
        foreach(zone in player.visited_zones)
        {
            spot = get_ideal_spawn_location(player, zone);
            if(isdefined(spot)) ideal_spawns[ideal_spawns.size] = spot;
        }
    }
    if(ideal_spawns.size > 1) // if they have only been in their spawn zone there is no reason to do this logic
    {
        ideal_spawns = array::randomize(ideal_spawns);
        ideal_spawn = undefined;
        foreach(spawn in ideal_spawns)
        {
            if(!isdefined(spawn)) continue;
            spawn.score = 0;
            foreach(enemy in level.players)
            {
                if(enemy == player) continue;
                if(enemy.sessionstate != "playing") continue;
                if(is_zbr_teambased() && (enemy.team == player.team)) continue;
                spawn.score += int(min(distanceSquared(enemy.origin, spawn.origin), 10000000)); //dsqrd faster than d2d or d due to alg
            }

            if(!isdefined(ideal_spawn))
            {
                ideal_spawn = spawn;
                continue;
            }

            if(ideal_spawn.score < spawn.score) 
                ideal_spawn = spawn;
        }

        if(!isdefined(ideal_spawn)) ideal_spawn = ideal_spawns[randomInt(ideal_spawns.size)];
        return (isdefined(return_struct) && return_struct) ? ideal_spawn : ideal_spawn.origin;
    }

    // if player start zone is safe, return start zone
    if(isdefined(player.gmspawn))
    {
        spot = get_ideal_spawn_location(player, player.gmspawn);
        if(isdefined(spot))
            return (isdefined(return_struct) && return_struct) ? spot : spot.origin;
    }

    // random spawn that is safe
    foreach(zone in getArrayKeys(level.zones))
    {
        spot = get_ideal_spawn_location(player, zone);
        if(isdefined(spot))
            return (isdefined(return_struct) && return_struct) ? spot : spot.origin;
    }

    // return start zone
    if(!no_start) return GetRandStartZone(player, return_struct); 
    return undefined;
}

get_ideal_spawn_location(player, zone)
{
    if(!isdefined(zone))
    {
        return undefined;
    }

    if(isdefined(level.gm_blacklisted) && isinarray(level.gm_blacklisted, zone))
    {
        return undefined;
    }
    
    // are there any players in this zone?
    players = zm_zonemgr::get_players_in_zone(zone, true);
    if(!isarray(players)) return undefined; // inactive zone

    if(players.size > 0)
    {
        foreach(plr in players)
        {
            if(is_zbr_teambased() && (plr.team == player.team)) continue;
            return undefined;
        }
    }
    
    spawns = GetAllSpawnsFromZone(player, zone);
    if(!isdefined(spawns) || spawns.size < 1) return undefined;

    // foreach spawn in the location, if a bullet trace to a player succeeds, continue
    foreach(spawn in spawns)
    {
        spawn_ok = true;
        foreach(_player in level.players)
        {
            if(_player.sessionstate != "playing" || _player == player)
            {
                continue;
            }
            
            if(is_zbr_teambased() && (_player.team == player.team))
            {
                continue;
            }
            
            ent = BulletTrace(spawn.origin + (0,0,70), _player.origin + (0,0,70), true, undefined)["entity"];
            if(isdefined(ent) && ent == _player)
            {
                spawn_ok = false;
                break;
            }
        }
        
        if(spawn_ok) return spawn;
    }
    
    // if no spot is safe, return undefined
    return undefined;
}

is_point_inside_zone(v_origin, target_zone)
{
    if(!isdefined(target_zone) || !isdefined(v_origin) || !isdefined(target_zone.Volumes))
        return false;
    
	temp_ent = spawn("script_origin", v_origin);
	foreach(e_volume in target_zone.Volumes)
    {
        if(temp_ent istouching(e_volume))
        {
            temp_ent delete();
            return 1;
        }
    }

	temp_ent delete();
	return 0;
}

zm_zod_pap()
{
    level thread zm_zod_companion_monitor();
    level flag::wait_till("initial_blackscreen_passed"); //thx feb
    level.pack_a_punch_camo_index = 124; //fun
    if(isdefined(level.var_c0091dc4) && isdefined(level.var_c0091dc4["pap"]) && isdefined(level.var_c0091dc4["pap"].var_46491092))
    {
        foreach(person in Array("boxer", "detective", "femme", "magician"))
            level thread [[ level.var_c0091dc4[person].var_46491092 ]](person);

        foreach(var_c8d6ad34 in Array("pap_basin_1", "pap_basin_2", "pap_basin_3", "pap_basin_4"))
            level flag::set(var_c8d6ad34);

        level flag::set("pap_altar");
        level thread [[ level.var_c0091dc4["pap"].var_46491092 ]]("pap");
    }

    level flag::set("second_idgun_time");
    level flag::set("idgun_up_for_grabs");

    level.zombie_weapons[getweapon("idgun_0")].is_in_box = 1;
    level.zombie_weapons[getweapon("idgun_0")].upgrade = getweapon("idgun_upgraded_0");

    level.zombie_include_weapons[getweapon("tesla_gun")] = 1;
    zm_weapons::add_zombie_weapon("tesla_gun", "tesla_gun_upgraded", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("tesla_gun")] = 1;
    level.zombie_weapons[getweapon("tesla_gun")].is_in_box = 1;
    level.zombie_weapons[getweapon("tesla_gun")].upgrade = getweapon("tesla_gun_upgraded");
    level.zombie_weapons_upgraded[getweapon("tesla_gun_upgraded")] = getweapon("tesla_gun");
    
    if(isdefined(level.content_weapons))
        arrayremovevalue(level.content_weapons, getweapon("tesla_gun"));

    locker = level.var_ca7eab3b;
    locker.var_116811f0 = 3;
    foreach(var_22f3c343 in locker.var_5475b2f6) var_22f3c343 ghost();
    for(i = 0; i < 10; i++)
    {
        if(isdefined(locker.var_2c51c4a[i]))
            [[locker.var_2c51c4a[i]]]();
    }
    foreach(correct in locker.var_75a61704) correct notify("trigger", level.players[0]);

    killed = 0;
    while(level.round_number < (GM_START_ROUND + 2) && killed < 2)
    {
        ais = GetAIArchetypeArray("margwa", level.zombie_team);
        foreach(ai in ais)
        {
            wait 5;
            ai kill();
            killed++;
        }
        wait 1;
    }
}

zm_zod_uncache(player)
{
    player endon("disconnect");
    self waittill("trap_done");
    player.cache_trap = undefined;
}

zm_stalingrad_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("dragon_wings_items_aquired");
	level flag::set("dragon_platforms_all_used");
    level flag::set("dragon_shield_used");
    level flag::set("dragon_gauntlet_acquired");
    level flag::set("dragon_strike_acquired");

    level.zombie_include_weapons[getweapon("melee_sword")] = 1;
    zm_weapons::add_zombie_weapon("melee_sword", "melee_sword", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("melee_sword")] = 1;

    level.zombie_include_weapons[getweapon("melee_wrench")] = 1;
    zm_weapons::add_zombie_weapon("melee_wrench", "melee_wrench", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("melee_wrench")] = 1;

    level.var_a78effc7 = 999; //fix stalingrad hang
    
    // disable drones
    level._achievement_monitor_func = level.achievement_monitor_func;
    level.achievement_monitor_func = ::Kill_Sentinels;

    ctrl = struct::get("dragon_strike_controller");
    level flag::set("dragon_strike_unlocked");
    level flag::set("dragon_strike_acquired");
    level flag::set("dragon_strike_quest_complete");
    if(IS_DEBUG && DEBUG_STALINGRAD_UG_DS) level flag::set("draconite_available");

    thread zm_stalingrad_award_gauntlet();

    // disable riding dragon
    level.var_583e4a97.var_caa5bc3e = 999;
}

zm_stalingrad_award_gauntlet()
{
    while(level.round_number < DRAGON_GAUNTLET_UNLOCK_ROUND)
    {
        level waittill("between_round_over");
    }
    level flag::set("dragon_egg_acquired");
	level flag::set("egg_bathed_in_flame");
	level flag::set("egg_cooled_hazard");
	level flag::set("egg_awakened");
    wait .05;
    level notify(#"hash_68bf9f79");
    wait .05;
    level notify(#"hash_b227a45b");
    wait .05;
    level notify(#"hash_9b46a273");
	level flag::set("gauntlet_step_2_complete");
	level flag::set("gauntlet_step_3_complete");
	level flag::set("gauntlet_step_4_complete");
	level flag::clear("egg_placed_incubator");
	level flag::clear("egg_cooled_incubator");
	level flag::clear("egg_placed_in_hazard");
	level flag::clear("basement_sentinel_wait");
	level flag::set("gauntlet_quest_complete");
    
    foreach(player in level.players)
	{
		player flag::set("flag_player_completed_challenge_4");
	}
}

Kill_Sentinels()
{
    if(self.targetname == "zombie_sentinel")
    {
        wait 3;
        self kill();
    }
    else if(isdefined(level._achievement_monitor_func))
        self thread [[level._achievement_monitor_func]]();
}

zm_cosmodrome_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("lander_power");
    level flag::set("lander_a_used");
	level flag::set("lander_b_used");
	level flag::set("lander_c_used");
	level flag::set("launch_activated");
	level flag::set("launch_complete");
}

zm_cosmodrome_spawn_fix()
{
    if(level.script == "zm_cosmodrome")
    {
        self unlink();
        self.lander = 0;
        self Try_Respawn();
    }
}

zm_temple_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("pap_active");
	level flag::set("pap_open");
	level flag::set("pap_enabled");
    level.pack_a_punch_round_time = 999999;
    level.pap_active_time = 999999;
    
    for(i = 0; i < 4; i++)
        foreach(trig in GetEnt("pap_blocker_trigger" + i + 1, "targetname"))
            trig delete();
    
    GetEnt("pap_stairs_player_clip", "targetname") delete();

    if(isdefined(level.pap_stairs_clip))
	{
		level.pap_stairs_clip MoveZ(level.pap_stairs_clip.zMove, 2, 0.5, 0.5);
	}

    // thx extinct for method, and feb for trying
    for(i = 0; i < level.pap_stairs.size; i++)
    {
        stairs = level.pap_stairs[i];
        stairs moveto(stairs.up_origin, stairs.movetime);
    }

    if(isdefined(level.brush_pap_traversal))
	{
		a_nodes = GetNodeArray("node_pap_jump_bottom", "targetname");
		foreach(node in a_nodes)
		{
			UnlinkTraversal(node);
		}
		level.brush_pap_traversal notsolid();
		level.brush_pap_traversal connectpaths();
	}

	if(isdefined(level.brush_pap_side_l))
		level.brush_pap_side_l _pap_brush_connect_paths();
	
	if(isdefined(level.brush_pap_side_r))
		level.brush_pap_side_r _pap_brush_connect_paths();
}

_pap_brush_connect_paths()
{
	self solid();
	self connectpaths();
	self notsolid();
}

zm_quadrotor_init()
{
    self [[ level.old_quadrotor_init ]]();
    self thread watch_for_owner_team();
}

watch_for_owner_team()
{
    self endon("death");
    while(!isdefined(self.player_owner))
    {
        wait 0.1;
    }
    self.team = self.player_owner.team;
	self.vteam = self.team;
	self setteam(self.team);
    self.maxhealth = int(level.round_number * 250);
    self.health = int(self.maxhealth);
    self setCanDamage(true);
    self.dmg_trigger = spawn("trigger_damage", self.origin, 0, 32, 32);
    self.dmg_trigger thread fakelinkto(self, (0,0,32));
    self.dmg_trigger thread kill_dragon_trig_on_death(self);
    self.dmg_trigger thread watch_quadrotor_damage(self, int(level.round_number * 250));
}

watch_quadrotor_damage(e_quad, health)
{
    e_quad endon("death");
    self endon("death");
    e_quad.maxhealth = health;
    while(isdefined(self) && isdefined(e_quad))
    {
        self waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
        if(e_quad == attacker) continue;
        if(isdefined(attacker) && isplayer(attacker) && attacker.team != e_quad.team)
        {
            health -= damagetaken;
            e_quad.health = health;
            damageStage = dragon_damage_feedback_get_stage(e_quad);
            attacker.hud_damagefeedback.color = (1,1,1);
            attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, health <= 0);
            attacker thread damagefeedback::damage_feedback_growth(e_quad, dmg_type, weapon);
        }
        if(health <= 0)
        {
            e_quad notify("death", attacker);
            return;
        }
    }
}

quadrotor_cb_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
    if(isdefined(eattacker) && isplayer(eattacker) && eattacker.team != self.team)
    {
        damageStage = dragon_damage_feedback_get_stage(self);
        eattacker.hud_damagefeedback.color = (1,1,1);
        eattacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansofdeath, weapon, damageStage));
        eattacker thread damagefeedback::damage_feedback_growth(self, smeansofdeath, weapon);
        return idamage;
    }
	return 0;
}

zm_tomb_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::wait_till("capture_zones_init_done");
    level clientfield::set("packapunch_anim", 6);
    level.gm_zombie_dmg_scalar = ORIGINS_ZOMBIE_DAMAGE;
    level.mechz_min_round_fq = 5;
	level.mechz_max_round_fq = 6;
    level.a_e_slow_areas = [];
    level.old_quadrotor_init = level.vehicle_main_callback["zm_quadrotor"];
    level.vehicle_main_callback["zm_quadrotor"] = serious::zm_quadrotor_init;
    unlock_all_debris();
    open_all_doors();

    // power the generators permanently
    level.zone_capture.spawn_func_recapture_zombie = serious::killzomb_tomb;
    level.total_capture_zones = 6;

    a_s_generator = struct::get_array("s_generator", "targetname");
    foreach(s_zone in level.zone_capture.zones)
        s_zone flag::set("player_controlled"); //deadlock it

    foreach(generator in a_s_generator)
	{
        level clientfield::set("zone_capture_hud_generator_" + generator.script_int, 1);
	    level clientfield::set("zone_capture_monolith_crystal_" + generator.script_int, 0);
		if(!isdefined(generator.perk_fx_func) || generator [[generator.perk_fx_func]]())
        {
            level clientfield::set("zone_capture_perk_machine_smoke_fx_" + generator.script_int, 1);
        }
        level clientfield::set("state_" + generator.script_noteworthy, 1);
        level flag::set("power_on" + generator.script_int);
        level clientfield::set(generator.script_noteworthy, 1);
        generator tomb_enable_perk_machines_in_zone();
        generator tomb_enable_random_perk_machines_in_zone();
        generator tomb_enable_mystery_boxes_in_zone();        
	}

    // trick the game into setting the next teleporter round to 1000+
    level flag::set("all_zones_captured");
    wait .5;

    old_rn = level.round_number;
    level.round_number = 999;
    level notify("force_recapture_start");

    wait .05;
    
    level.round_number = old_rn;
    level flag::set("recapture_zombies_cleared");
	level flag::clear("generator_under_attack");
    level flag::clear("recapture_event_in_progress");

    level flag::set("any_crystal_picked_up");
    staffs = array::randomize(array("elemental_staff_air", "elemental_staff_fire", "elemental_staff_lightning", "elemental_staff_water"));
    
    foreach(staff in staffs)
    {
        craftable = level.zombie_include_craftables[staff];
        foreach(piece in craftable.a_piecestubs)
        {
            if(piece.pieceName != "gem") continue;
            piece._piecespawn = piece.piecespawn;
            piece.piecespawn = undefined;
        }
    }
    
    // gsc vm cannot handle duplicate notify calls on the same frame, so you have to wait.
    for(i = 1; i < 5; i++)
    {
        level notify("player_teleported", level.players[0], i);
        wait .025;
        waittillframeend;
    }
    wait 1;

    foreach(staff in staffs)
    {
        craftable = level.zombie_include_craftables[staff];
        foreach(piece in craftable.a_piecestubs)
        {
            if(piece.pieceName != "gem") continue;
            piece.piecespawn = piece._piecespawn;
        }
    }
    
    plr = randomint(4);
    foreach(staff in staffs)
    {
        craftable = level.zombie_include_craftables[staff];
        foreach(piece in craftable.a_piecestubs)
        {
            if(piece.pieceName != "gem")
                level.players[0] zm_craftables::player_get_craftable_piece(piece.craftablename, piece.pieceName);
            else
                level.players[plr % level.players.size] zm_craftables::player_get_craftable_piece(piece.craftablename, piece.pieceName);
        }
        plr++;
    }

    a_s_teleporters = struct::get_array("trigger_teleport_pad", "targetname");
    level flag::wait_till("start_zombie_round_logic");
    wait .025;

    foreach(teleporter in a_s_teleporters)
    {
        level flag::set("enable_teleporter_" + teleporter.script_int);
    }

    craftable = level.zombie_include_craftables["gramophone"];
    foreach(piece in craftable.a_piecestubs)
    {
        switch(piece.pieceName)
        {
            case "vinyl_air":
            case "vinyl_ice":
            case "vinyl_fire":
            case "vinyl_elec":
                piece.piecespawn.model.origin = (10000,10000,10000);
                piece.piecespawn.origin = (10000,10000,10000);
                break;
            default:
                break;
        }
    }

    // foreach(piece in level.zombie_include_craftables["equip_dieseldrone"].a_piecestubs)
    // {
    //     piece.piecespawn.model.origin = (10000,10000,10000);
    //     piece.piecespawn.origin = (10000,10000,10000);
    // }

    if(IS_DEBUG && DEBUG_OIP)
    {
        foreach(box in getentarray("foot_box", "script_noteworthy"))
        {
            box.n_souls_absorbed = 29;
            box notify("soul_absorbed", level.players[0]);
        }
    }

    if(IS_DEBUG && DEBUG_UPGRADED_STAFFS)
    {
        foreach(staff in level.a_elemental_staffs)
        {
            level flag::set(staff.weapname + "_upgrade_unlocked");
            staff.charger.charges_received = 20;
		    staff.charger.is_inserted = 1;
        }

        foreach(staff_upgraded in level.a_elemental_staffs_upgraded)
        {
            staff_upgraded.charger.charges_received = 20;
            staff_upgraded.charger.is_inserted = 1;
            staff_upgraded.charger.is_charged = 1;
        }

        for(i = 1; i < 5; i++)
        {
            level flag::set("charger_ready_" + i);
        }
    }

    // override staff callbacks
    level.custom_craftable_validation = serious::tomb_custom_craftable_validation;
    level.zombie_craftable_persistent_weapon = serious::tomb_check_crafted_weapon_persistence;

    foreach(staff in level.a_elemental_staffs)
    {
        e_staff_standard = get_staff_info_from_element_index(staff.enum);
        e_staff_standard_upgraded = e_staff_standard.upgrade;
        e_staff_standard_upgraded thread fix_other_calls_stwr();
    }
}

tomb_teleport_penalty()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    if(level.script != "zm_tomb")
    {
        return;
    }
    while(true)
    {
        if(isdefined(self.teleport_origin))
        {
            self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - GM_TELEPORT_STRAT_PENALTY));
            wait 6.25; // time of teleport
        }
        wait 0.25;
    }
}

tomb_check_crafted_weapon_persistence(player)
{
    if
    (
        !(
            self.stub.weaponname == level.a_elemental_staffs["staff_air"].w_weapon || 
            self.stub.weaponname == level.a_elemental_staffs["staff_fire"].w_weapon || 
            self.stub.weaponname == level.a_elemental_staffs["staff_lightning"].w_weapon || 
            self.stub.weaponname == level.a_elemental_staffs["staff_water"].w_weapon
        )
    )
    {
        return false;
    }
	if(!(isdefined(level.var_b79a2c38[self.stub.equipname]) && level.var_b79a2c38[self.stub.equipname]))
    {
        level thread tomb_staff_pickup_cooldown(self.stub.equipname);
        s_elemental_staff = get_staff_info_from_weapon_name(self.stub.weaponname, 0);
        player zm_weapons::weapon_give(s_elemental_staff.w_weapon, 0, 0);
        if(isdefined(s_elemental_staff.prev_ammo_stock) && isdefined(s_elemental_staff.prev_ammo_clip))
        {
            player setweaponammostock(s_elemental_staff.w_weapon, s_elemental_staff.prev_ammo_stock);
            player setweaponammoclip(s_elemental_staff.w_weapon, s_elemental_staff.prev_ammo_clip);
        }
        if(isdefined(level.zombie_craftablestubs[self.stub.equipname].str_taken))
        {
            self.stub.hint_string = level.zombie_craftablestubs[self.stub.equipname].str_taken;
        }
        else
        {
            self.stub.hint_string = "";
        }
        self sethintstring(self.stub.hint_string);
        str_name = "craftable_" + self.stub.weaponname.name + "_zm";
        model = getent(str_name, "targetname");
        model ghost();
        self.stub thread tomb_track_crafted_staff_trigger();
        self.stub thread track_staff_weapon_respawn(player);
        set_player_staff(self.stub.weaponname, player);
    }
    else
    {
        self.stub.hint_string = "";
        self sethintstring(self.stub.hint_string);
    }
    return true;
}

set_player_staff(staff, e_player)
{
	s_staff = get_staff_info_from_weapon_name(staff);
	s_staff.e_owner = e_player;
	n_player = e_player getentitynumber() + 1;
	e_player.staff_enum = s_staff.enum;
	level clientfield::set(s_staff.element + "_staff.holder", e_player.characterindex + 1);
	e_player update_staff_accessories(s_staff.enum);
}

fix_other_calls_stwr()
{
    self notify("fix_other_calls_stwr");
    self endon("fix_other_calls_stwr");
    while(true)
    {
        self waittill("kill_track_staff_weapon_respawn");
        waittillframeend;
        wait 0.05;
        self notify("kill_track_staff_weapon_respawn");
        if(isdefined(self.owner))
        {
            self thread track_staff_weapon_respawn(self.owner);
        }
    }
}

track_staff_weapon_respawn(player)
{
    player endon("disconnect");
	self notify("kill_track_staff_weapon_respawn_" + player.name);
	self endon("kill_track_staff_weapon_respawn_" + player.name);
    self thread fix_other_calls_stwr();
	s_elemental_staff = undefined;
	if(issubstr(self.targetname, "prop_"))
	{
		s_elemental_staff = get_staff_info_from_weapon_name(self.w_weapon, 1);
	}
	else
	{
		s_elemental_staff = get_staff_info_from_weapon_name(self.weaponname, 1);
	}
	s_upgraded_staff = s_elemental_staff.upgrade;
	if(!isdefined(self.base_weaponname))
	{
		self.base_weaponname = s_elemental_staff.weapname;
	}
	// level flag::clear(self.base_weaponname + "_zm_enabled");
	has_weapon = 0;
	while(isalive(player))
	{
		if(isdefined(s_elemental_staff.charger.is_inserted) && s_elemental_staff.charger.is_inserted || (isdefined(s_upgraded_staff.charger.is_inserted) && s_upgraded_staff.charger.is_inserted) || (isdefined(s_upgraded_staff.ee_in_use) && s_upgraded_staff.ee_in_use))
		{
			has_weapon = 1;
		}
		else
		{
			weapons = player getweaponslistprimaries();
			foreach(var_46fe82d7, weapon in weapons)
			{
				n_melee_element = 0;
				if(weapon.name == self.base_weaponname)
				{
					s_elemental_staff.prev_ammo_stock = player getweaponammostock(weapon);
					s_elemental_staff.prev_ammo_clip = player getweaponammoclip(weapon);
					has_weapon = 1;
				}
				else if(weapon.name == s_upgraded_staff.weapname)
				{
					s_upgraded_staff.prev_ammo_stock = player getweaponammostock(weapon);
					s_upgraded_staff.prev_ammo_clip = player getweaponammoclip(weapon);
					has_weapon = 1;
					n_melee_element = s_upgraded_staff.enum;
				}
				if(player hasweapon(level.var_2b2f83e5))
				{
					s_upgraded_staff.revive_ammo_stock = player getweaponammostock(level.var_2b2f83e5);
					s_upgraded_staff.revive_ammo_clip = player getweaponammoclip(level.var_2b2f83e5);
				}
				if(has_weapon && (!(isdefined(player.one_inch_punch_flag_has_been_init) && player.one_inch_punch_flag_has_been_init)) && n_melee_element != 0 && !player hasperk("specialty_widowswine"))
				{
					cur_weapon = player getcurrentweapon();
					if(cur_weapon != weapon && (isdefined(player.use_staff_melee) && player.use_staff_melee))
					{
						player update_staff_accessories(0);
						continue;
					}
					if(cur_weapon == weapon && (!(isdefined(player.use_staff_melee) && player.use_staff_melee)))
					{
						player update_staff_accessories(n_melee_element);
					}
				}
			}
		}
		if(!has_weapon && !player laststand::player_is_in_laststand())
		{
			break;
		}
		wait(0.5);
		has_weapon = 0;
	}
	b_staff_in_use = 0;
	a_players = getplayers();
	foreach(var_c5db81b6, check_player in a_players)
	{
		if(check_player.sessionstate == "playing")
		{
			weapons = check_player getweaponslistprimaries();
			foreach(var_d3a8ad26, weapon in weapons)
			{
				if(weapon.name == self.base_weaponname || weapon.name == s_upgraded_staff.weapname)
				{
					b_staff_in_use = 1;
				}
			}
		}
	}
	if(!b_staff_in_use)
	{
		str_name = "craftable_" + self.base_weaponname + "_zm";
		model = getent(str_name, "targetname");
		model show();
		// level flag::set(self.base_weaponname + "_zm_enabled");
	}
	if(isweapon(self.weaponname))
	{
		clear_player_staff(self.weaponname, player);
	}
	else
	{
		clear_player_staff(self.w_weapon, player);
	}
}

clear_player_staff(staff, e_owner)
{
	s_staff = get_staff_info_from_weapon_name(staff);
	if(isdefined(e_owner) && isdefined(s_staff.e_owner) && e_owner != s_staff.e_owner)
	{
		return;
	}
	if(!isdefined(e_owner))
	{
		e_owner = s_staff.e_owner;
	}
	if(isdefined(e_owner))
	{
		if(level clientfield::get(s_staff.element + "_staff.holder") == e_owner.characterindex + 1)
		{
			n_player = e_owner getentitynumber() + 1;
			e_owner.staff_enum = 0;
			level clientfield::set(s_staff.element + "_staff.holder", 0);
			e_owner update_staff_accessories(0);
		}
	}
	s_staff.e_owner = undefined;
}

update_staff_accessories(n_element_index)
{
	if(!(isdefined(self.one_inch_punch_flag_has_been_init) && self.one_inch_punch_flag_has_been_init) && !self hasperk("specialty_widowswine"))
	{
		cur_weapon = self zm_utility::get_player_melee_weapon();
		weapon_to_keep = getweapon("knife");
		self.use_staff_melee = 0;
		if(n_element_index != 0)
		{
			staff_info = get_staff_info_from_element_index(n_element_index);
			if(staff_info.charger.is_charged)
			{
				staff_info = staff_info.upgrade;
			}
			if(isdefined(staff_info.var_8f5a8751))
			{
				weapon_to_keep = staff_info.var_8f5a8751;
				self.use_staff_melee = 1;
			}
		}
		melee_changed = 0;
		if(cur_weapon != weapon_to_keep)
		{
			self takeweapon(cur_weapon);
			self giveweapon(weapon_to_keep);
			self zm_utility::set_player_melee_weapon(weapon_to_keep);
			melee_changed = 1;
		}
	}
	has_revive = self hasweapon(level.var_2b2f83e5);
	has_upgraded_staff = 0;
	a_weapons = self getweaponslistprimaries();
	staff_info = get_staff_info_from_element_index(n_element_index);
	foreach(var_4878f495, str_weapon in a_weapons)
	{
		if(is_weapon_upgraded_staff(str_weapon))
		{
			has_upgraded_staff = 1;
		}
	}
	if(has_revive && !has_upgraded_staff)
	{
		self setactionslot(3, "altmode");
		self takeweapon(level.var_2b2f83e5);
	}
	else if(!has_revive && has_upgraded_staff)
	{
		self setactionslot(3, "weapon", level.var_2b2f83e5);
		self giveweapon(level.var_2b2f83e5);
		if(isdefined(staff_info))
		{
			if(isdefined(staff_info.upgrade.revive_ammo_stock))
			{
				self setweaponammostock(level.var_2b2f83e5, staff_info.upgrade.revive_ammo_stock);
				self setweaponammoclip(level.var_2b2f83e5, staff_info.upgrade.revive_ammo_clip);
			}
		}
	}
}

is_weapon_upgraded_staff(w_weapon)
{
	switch(w_weapon.name)
	{
		case "staff_air_upgraded":
		case "staff_fire_upgraded":
		case "staff_lightning_upgraded":
		case "staff_water_upgraded":
		    return true;
		default:
		    return false;
	}
}

tomb_track_crafted_staff_trigger()
{
	s_elemental_staff = get_staff_info_from_weapon_name(self.weaponname, 1);
	if(!isdefined(self.base_weaponname))
	{
		self.base_weaponname = s_elemental_staff.weapname;
	}
	level flag::clear(self.base_weaponname + "_picked_up");
}

tomb_staff_pickup_cooldown(str_equipname)
{
	level.var_b79a2c38[str_equipname] = 1;
	wait(0.2);
	level.var_b79a2c38[str_equipname] = 0;
}

tomb_custom_craftable_validation(player)
{
    if(self.stub.equipname == "equip_dieseldrone")
	{
		level.quadrotor_status.pickup_trig = self.stub;
		if(level.quadrotor_status.crafted)
		{
			quadrotor = getweapon("equip_dieseldrone");
			return !players_has_quadrotor_weapon(quadrotor) && !level flag::get("quadrotor_cooling_down");
		}
	}
	return true;
}

players_has_quadrotor_weapon(weaponname)
{
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] hasweapon(weaponname))
		{
			return true;
		}
	}
	quadrotors = getentarray("quadrotor_ai", "targetname");
	if(quadrotors.size >= 1)
	{
		return true;
	}
	return false;
}

tomb_enable_perk_machines_in_zone()
{
	if(isdefined(self.perk_machines) && IsArray(self.perk_machines))
	{
		a_keys = getArrayKeys(self.perk_machines);
		for(i = 0; i < a_keys.size; i++)
		{
			level notify(a_keys[i] + "_on");
		}
		for(i = 0; i < a_keys.size; i++)
		{
			e_perk_trigger = self.perk_machines[a_keys[i]];
			e_perk_trigger.is_locked = 0;
		}
	}
}

tomb_enable_random_perk_machines_in_zone()
{
	if(isdefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
	{
		foreach(random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 0;
			if(isdefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine tomb_set_perk_random_machine_state("idle");
				continue;
			}
			random_perk_machine tomb_set_perk_random_machine_state("away");
		}
	}
}

tomb_set_perk_random_machine_state(State)
{
	wait(0.1);
	for(i = 0; i < self GetNumZBarrierPieces(); i++)
	{
		self HideZBarrierPiece(i);
	}
	self notify("zbarrier_state_change");
	self [[level.perk_random_machine_state_func]](State);
}

tomb_enable_mystery_boxes_in_zone()
{
	foreach(mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 0;
		mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("player_controlled");
		mystery_box.zbarrier clientfield::set("magicbox_runes", 1);
	}
}

killzomb_tomb(a, b)
{
    self DoDamage(self.health + 100, (0, 0, 0));
}

zm_factory_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    level.pack_a_punch_camo_index = 124;
    level flag::set("power_on");
    // this leaves some proper fuckery to be had, but i think its hilarious
    level flag::set("teleporter_pad_link_1");
	level flag::set("teleporter_pad_link_2");
	level flag::set("teleporter_pad_link_3");
    for(i = 0; i < level.teleport.size; i++)
        level.teleport[i] = "timer_on";
    GetEnt("trigger_teleport_core", "targetname") notify("trigger");
}

zm_castle_pap()
{
    level flag::wait_till("initial_blackscreen_passed");
    foreach(m in struct::get_array("s_pap_tp"))
    {
        the_stub = undefined;
        level.var_54cd8d06 = m;
        foreach(stub in level._unitriggers.trigger_stubs)
            if(stub.parent_struct == m)
                the_stub = stub;
            
        if(!isdefined(the_stub))
            continue;

        the_stub notify("trigger", level.players[0]);
    }

    foreach(catcher in level.soul_catchers)
    {
        catcher.var_98730ffa = 8;
        level clientfield::set(catcher.script_parameters, 6);
    }

    level.zombie_include_weapons[getweapon("hk416")] = 1;
    zm_weapons::add_zombie_weapon("hk416", "hk416_upgraded", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("hk416")] = 1;
    level.zombie_weapons[getweapon("hk416")].is_in_box = 1;
    level.zombie_weapons[getweapon("hk416")].upgrade = getweapon("hk416_upgraded");
    level.zombie_weapons_upgraded[getweapon("hk416_upgraded")] = getweapon("hk416");

    level.zombie_include_weapons[getweapon("knife_plunger")] = 1;
    zm_weapons::add_zombie_weapon("knife_plunger", "knife_plunger", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("knife_plunger")] = 1;
    
    if(isdefined(level.content_weapons))
        arrayremovevalue(level.content_weapons, getweapon("hk416"));

    old_origin = level.var_54cd8d06.origin;
    level.var_54cd8d06 setorigin(level.players[0]);
    level flag::wait_till("pap_reformed");
    level.var_54cd8d06 setorigin(old_origin);
}

widows_wine_knife_override_castle()
{
    if(self hasweapon(getweapon("knife_plunger")))
    {
        return;
    }
    self takeweapon(self.w_widows_wine_prev_knife);
    if(self.w_widows_wine_prev_knife.name == "bowie_knife")
    {
        self giveweapon(level.w_widows_wine_bowie_knife);
        self zm_utility::set_player_melee_weapon(level.w_widows_wine_bowie_knife);
    }
    else if(self.w_widows_wine_prev_knife.name == "sickle_knife")
    {
        self giveweapon(level.w_widows_wine_sickle_knife);
        self zm_utility::set_player_melee_weapon(level.w_widows_wine_sickle_knife);
    }
    else
    {
        self giveweapon(level.w_widows_wine_knife);
        self zm_utility::set_player_melee_weapon(level.w_widows_wine_knife);
    }
}

spider_lair_entrance_webs()
{
    self setCanDamage(0);
}

// update_valid_players
zm_island_pap()
{
    if(IS_DEBUG && DEBUG_ISLAND_NOCHANGES) return;
    level flag::wait_till("initial_blackscreen_passed");
    level.vehicle_initializer_cb = serious::zm_island_vehicle_spider;
    level.gm_override_downed_spot = (-1619, 2509, -1730); // teleport to the takeo boss fight room because undefined zone is probably causing a crash
    level.var_5ccd3661 = 999;

    level.zombie_include_weapons[getweapon("hk416")] = 1;
    zm_weapons::add_zombie_weapon("hk416", "hk416_upgraded", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("hk416")] = 1;
    level.zombie_weapons[getweapon("hk416")].is_in_box = 1;
    level.zombie_weapons[getweapon("hk416")].upgrade = getweapon("hk416_upgraded");
    level.zombie_weapons_upgraded[getweapon("hk416_upgraded")] = getweapon("hk416");

    level.zombie_include_weapons[getweapon("controllable_spider")] = 1;
    zm_weapons::add_zombie_weapon("controllable_spider", "controllable_spider", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("controllable_spider")] = 1;

    array::thread_all(getentarray("spider_lair_entrance_webs", "targetname"), serious::spider_lair_entrance_webs);

    #region SKULL SHIT
    level flag::set("skullquest_ritual_complete1");
	level flag::set("skullquest_ritual_complete2");
	level flag::set("skullquest_ritual_complete3");
	level flag::set("skullquest_ritual_complete4");
    level.var_b10ab148 = 1;
    level flag::set("skull_quest_complete");
    player = level.players[0];
    for(i = 1; i <= 4; i++)
    {
        skull_struct =  level.var_a576e0b9[i];
        skull_struct.str_state = "skull_p_picked_up";
        skull_struct.mdl_skull_s ghost();
        player.var_4849e523 = i;

        trig_stub = skull_struct.s_utrig_pillar;
        trig = spawnstruct();
        trig.stub = trig_stub;
        trig thread [[ trig_stub.trigger_func ]]();
        wait .025;
        trig notify("trigger", player);
        wait 0.1;
    }
    #endregion

    level flag::set("valve1_found");
	level flag::set("valve2_found");
	level flag::set("valve3_found");
	level flag::set("defend_success");
    level flag::set("pap_gauge");
	level flag::set("pap_whistle");
	level flag::set("pap_wheel");
    level flag::set("pap_water_drained");

    level flag::set("pool_filled");
	level flag::set("ww_obtained");
	level flag::set("ww3_found");
	level flag::set("wwup1_found");
	level flag::set("wwup2_found");
	level flag::set("wwup3_found");
	level flag::set("wwup_ready");
	level flag::set("wwup1_placed");
	level flag::set("wwup2_placed");
	level flag::set("wwup3_placed");

    // put kt4 in box
    level flag::set("ww_obtained");
    level flag::set("players_lost_ww");
    level.var_2cb8e184 = 0;
    level clientfield::set("add_ww_to_box", 1);
    level.zombie_weapons[GetWeapon("hero_mirg2000")].is_in_box = 1;
    level.CustomRandomWeaponWeights = serious::zm_island_boxweight;
    thread zm_island_byethrashers();
    wait .25;
    level.var_2aacffb1 = undefined;
    level notify(#"hash_d8d0f829");

    //setdvar("scr_zm_use_code_enemy_selection", 1);
}

zm_island_vehicle_spider(spider)
{
    if(isdefined(spider))
    {
        spider.team = level.zombie_team;
        spider setteam(level.zombie_team);
    }
    if(IS_DEBUG)
    {
        compiler::nprintln("Spider spawned");
    }
}

spider_initialize()
{
    level.zombie_total++;
    self kill();
    self delete();
}

zm_island_fix()
{
}

zm_island_initial_fix()
{
    if(level.script != "zm_island") return;
    if(IS_DEBUG && DEBUG_ISLAND_NOCHANGES) return;
    array::run_all(getentarray("mdl_mushroom_spore", "targetname"), ::delete);
    array::run_all(getentarray("t_spore_explode", "script_noteworthy"), ::delete);
    array::run_all(getentarray("t_spore_damage", "script_noteworthy"), ::delete);
    array::thread_all(struct::get_array("spore_fx_org", "script_noteworthy"), struct::delete);
    array::thread_all(struct::get_array("spore_cloud_org_stage_01", "script_noteworthy"), struct::delete);
    array::thread_all(struct::get_array("spore_cloud_org_stage_02", "script_noteworthy"), struct::delete);
    array::thread_all(struct::get_array("spore_cloud_org_stage_03", "script_noteworthy"), struct::delete);
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_rock_stage_01_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_rock_stage_02_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_rock_stage_02_rapid_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_rock_stage_03_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_wall_stage_01_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_wall_stage_02_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_wall_stage_02_rapid_bundle");
    struct::delete_script_bundle("scene", "p7_fxanim_zm_island_spores_wall_stage_03_bundle");
}

zm_island_byethrashers()
{
    level waittill("spawn_bunker_thrasher");
    foreach(ai in GetAISpeciesArray(level.zombie_team, "all")) ai kill();
}

zm_island_boxweight(a_keys)
{
	var_b45fbf8c = zm_pap_util::get_triggers();
	if(level flag::get("players_lost_ww"))
	{
		level.var_2cb8e184++;
		switch(level.var_2cb8e184)
		{
			case 1:
			{
				n_chance = 10;
				break;
			}
			case 2:
			{
				n_chance = 10;
				break;
			}
			case 3:
			{
				n_chance = 30;
				break;
			}
			case 4:
			{
				n_chance = 60;
				break;
			}
			default:
			{
				n_chance = 10;
				break;
			}
		}
		if(RandomInt(100) <= n_chance && zm_magicbox::treasure_chest_CanPlayerReceiveWeapon(self, level.var_5e75629a, var_b45fbf8c) && !self HasWeapon(level.var_a4052592))
		{
			ArrayInsert(a_keys, level.var_5e75629a, 0);
		}
		else
		{
			ArrayRemoveValue(a_keys, level.var_5e75629a);
		}
	}
	else if(self HasWeapon(level.var_5e75629a) || self HasWeapon(level.var_a4052592))
	{
		ArrayRemoveValue(a_keys, level.var_5e75629a);
	}
	return a_keys;
}

zm_genesis_map()
{
    level flag::wait_till("initial_blackscreen_passed");
    vehicle::add_main_callback("spider", serious::spider_initialize);
    level.wasp_enabled = 0;
    level.wasp_rounds_enabled = 0;
    level.next_wasp_round = 999;
    level.var_783db6ab = 999;
    level.var_256b19d4 = 1; // some kind of counter, disables ai spawning for bugs or something
    level.var_ba0d6d40 = 999; // next boss spawn
    for(i = 0; i < 4; i++)
    {
        level.zombie_weapons[getweapon("idgun_" + i)].is_in_box = 1;
    }    
    turrets = zm_genesis_collect_turrets();
    array::thread_all(turrets, serious::zm_genesis_turret_pvp);
    spawner::add_archetype_spawn_function("keeper_companion", serious::keeper_init);
    fn_pow = @zm_power<scripts\zm\_zm_power.gsc>::turn_power_on_and_open_doors;
    foreach(pow in getentarray("power_volume", "targetname"))
    {
        level thread [[ fn_pow ]](pow.script_int);
    }

    level.zombie_include_weapons[getweapon("melee_katana")] = 1;
    zm_weapons::add_zombie_weapon("melee_katana", "melee_katana", undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon("melee_katana")] = 1;
}

// hacky way to collect all the turrets by using their triggers
zm_genesis_collect_turrets()
{
    turrets = [];
    if(isdefined(level._unitriggers.dynamic_stubs) && isarray(level._unitriggers.dynamic_stubs))
    {
        foreach(s_trigger in level._unitriggers.dynamic_stubs)
        {
            if(isdefined(s_trigger.vh_turret))
            {
                turrets[turrets.size] = s_trigger.vh_turret;
            }
        }
    }
    foreach(s_zone in level.zones)
    {
        if(!isdefined(s_zone.unitrigger_stubs) || !isarray(s_zone.unitrigger_stubs))
        {
            continue;
        }
        foreach(s_trigger in s_zone.unitrigger_stubs)
        {
            if(isdefined(s_trigger.vh_turret))
            {
                turrets[turrets.size] = s_trigger.vh_turret;
            }
        }
    }
    return turrets;
}

zm_genesis_turret_pvp()
{
    level endon("game_ended");
    while(true)
    {
        self waittill("weapon_fired");
        e_player = self getvehicleowner();
		self thread zm_genesis_beam_damage_think();
		while(zm_utility::is_player_valid(e_player) && e_player attackbuttonpressed() && isdefined(self getvehicleowner()) && e_player == self getvehicleowner())
        {
            wait(0.05);
        }
    }
}

zm_genesis_beam_damage_think()
{
    self endon("stop_damage");
    n_wait_time = 0.1;
	while(true)
	{
        wait(n_wait_time);
		e_player = self getvehicleowner();
		should_damage = 1;
		v_position = self gettagorigin("tag_aim");
		v_forward = anglestoforward(self gettagangles("tag_aim"));
		a_trace = beamtrace(v_position, v_position + v_forward * 20000, 1, self);
		v_hit_location = a_trace["position"];
		if(!isdefined(a_trace["entity"])) continue;
        if(!isplayer(a_trace["entity"])) continue;
        player = a_trace["entity"];
        if(player.sessionstate != "playing") continue;
        if(player == e_player) continue;
        player doDamage(int(GENESIS_TURRET_DPS * level.round_number * n_wait_time), v_hit_location, e_player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
	}
}

zm_genesis_apothicon_monitor()
{
    self endon("spawned_player");
    self endon("disconnect");
    self endon("bled_out");

    while(true)
    {
        // catch exiting apothicon
        if(isdefined(self.var_5aef0317) && self.var_5aef0317)
        {   
            self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - GM_TELEPORT_STRAT_PENALTY));
            while(isdefined(self.var_5aef0317) && self.var_5aef0317)
            {
                wait 0.1;
            }
        }

        // catch entering opothicon
        if(isdefined(self.var_a393601c) && self.var_a393601c)
        {
            self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - GM_TELEPORT_STRAT_PENALTY));
            while(isdefined(self.var_a393601c) && self.var_a393601c)
            {
                wait 0.1;
            }

            // protect briefly when entering apothicon
            self thread gm_spawn_protect(2.5);
        }
        wait 1;
    }
}

zm_moon_pap()
{
    level flag::wait_till("initial_blackscreen_passed");

    // due to triggers being team locked on AI, we have to simulate trigger logic for the doors.
    thread zm_moon_door_fix();

    ArrayRemoveValue(level.diggers, "teleporter");
    ArrayRemoveValue(level.diggers, "hangar");

    pap_spot = (37.23, 3943, -155);

    foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        pap.origin = pap_spot;
    }
    
    foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        pap.origin = pap_spot;
    }

    if(IS_DEBUG && DEBUG_WAVE_GUN)
    {
        weapon = getweapon("microwavegundw");
        level.players[0] takeAllWeapons();
        level.players[0] giveweapon(weapon);
        level.players[0] giveMaxAmmo(weapon);
        level.players[0] switchToWeapon(weapon);
        level.players[0] notify("weapon_give", weapon);
    }
}

zm_moon_door_fix()
{
    level endon("end_game");
    while(true)
    {
        all = getentarray("zombie_door_airlock", "script_noteworthy");
        i = 0;
        foreach(trig in all)
        {
            if(i % 2)
            {
                wait 0.05;
            }
            if(!isdefined(trig))
            {
                continue;
            }
            if(!(trig IsTriggerEnabled()))
            {
                continue;
            }
            if(isdefined(trig._door_open) && trig._door_open)
            {
                continue;
            }
            e_occupied = undefined;
            foreach(zombie in getaiteamarray(level.zombie_team))
            {
                if(!isdefined(zombie))
                {
                    continue;
                }
                if(!isalive(zombie))
                {
                    continue;
                }
                if(zombie isTouching(trig))
                {
                    e_occupied = zombie;
                    break;
                }
            }
            if(!isdefined(e_occupied))
            {
                i++;
                continue;
            }
            trig notify("trigger", e_occupied);
        }
        wait 0.05;
    }
}

zm_moon_fixes()
{
    if(level.script != "zm_moon") return;

    wait 5;
    level flag::clear("enter_nml"); // moon fix
    level flag::clear("teleported_to_nml");
    level.on_the_moon = true;
    level.ever_been_on_the_moon = true;
    level notify("stop_ramp");
    level flag::clear("start_supersprint");
    level.on_the_moon = 1;
    level.ignore_distance_tracking = 1;
    level.chalk_override = undefined;
    level.zombie_health = level.zombie_vars["zombie_health_start"];
    level.zombie_total = 0;
    level notify("restart_round");
    level._from_nml = 1;
    zombies = GetAISpeciesArray(level.zombie_team, "all");
    if(isdefined(zombies))
    {
        for(i = 0; i < zombies.size; i++)
        {
            if(isdefined(zombies[i].ignore_nml_delete) && zombies[i].ignore_nml_delete)
            {
                continue;
            }
            if(zombies[i].isdog)
            {
                zombies[i] DoDamage(zombies[i].health + 10, zombies[i].origin);
                continue;
            }
            if(isdefined(zombies[i].fx_quad_trail))
            {
                zombies[i].fx_quad_trail delete();
            }
            zombies[i] notify("zombie_delete");
            zombies[i] delete();
        }
    }

    level._zombiemode_check_firesale_loc_valid_func = serious::check_firesale_valid_loc; // fixes a hackables thing
    level flag::set("zombie_drop_powerups");
    level.round_spawn_func = zm::round_spawning;
    level flag::set("teleporter_used");
    getent("generator_teleporter", "targetname").origin = (99999,99999,-99999);
    wait 10;
    level.speed_cola_ents[1].origin = (225, 2395, -566);
    level.speed_cola_ents[1] triggerenable(1);
    level.speed_cola_ents[0].origin = (225, 2395, -566);
    level.speed_cola_ents[0].angles = (0,-90,0);
    level.speed_cola_ents[0] show();
    level.jugg_ents[1].origin = (-673, 1681, -469);
    level.jugg_ents[1] triggerenable(1);
    level.jugg_ents[0].origin = (-673, 1681, -469);
    level.jugg_ents[0].angles = (0,180,0);
    level.jugg_ents[0] show();
}

// called each round
zm_genesis_fix()
{
    if(level.script != "zm_genesis") return;
    level.var_783db6ab = 999;
    level.wasp_enabled = 0;
    level.wasp_rounds_enabled = 0;
    level.wasp_round_count = 0;
    level.next_wasp_round = 999;
    level.var_256b19d4 = 1; // some kind of counter, disables ai spawning for bugs or something
    level.var_ba0d6d40 = 999; // next boss spawn
    level.var_3013498 = 999;
    level.fn_custom_round_ai_spawn = serious::genesis_nospecials;
    level flag::set("mega_round_end_abcd_talking");
}

genesis_nospecials()
{
    return 0;
}

zm_cosmodrome_fix()
{
    if(level.script != "zm_cosmodrome") return;
    level.next_monkey_round = 9999;
    level.max_monkey_zombies = 0;
}

zm_dogs_fix()
{
    level.next_dog_round = 9999;
}

zm_mechz_roundNext()
{
    if(!isdefined(level.mechz_round_count)) return;
    level.mechz_round_count = 1;
}

// CUSTOM MAPS SPAWN LOGIC

// Automatically detects bad zones, and populates the gm_spawns array to the best of its ability.
// Algorithm is just a simple furthest neightbor implementation. Far from perfect, but will at least hopefully allow support for custom maps.
gm_generate_spawns()
{
    /*
    zones = [];
    foreach(k, v in level.zones)
    {
        if(isinarray(level.gm_blacklisted, k)) continue;
        zones[zones.size] = k;
    }
    spawns = CollectAllSpawns(zones);
    a_s_furthest = gm_search_spawns(spawns, 4);

    // Now locate the zone each point chosen is in
    foreach(point in a_s_furthest)
    {
        foreach(zone in zones)
        {
            if(is_point_inside_zone(point.origin, zone))
            {
                level.gm_spawns[level.gm_spawns.size] = zone;
                break;
            }
        }
    }
    */
    /*
    if(level.gm_spawns.size < 4)
    {
        foreach(zone in level.gm_spawns)
        {
            arrayremovevalue(zones, zone, false);
        }

        zones = array::randomize(zones);
        foreach(zone in zones)
        {
            spawns = GetAllSpawnsFromZone(level.players[0], zone);
            if(!spawns.size) continue;
            level.gm_spawns[level.gm_spawns.size] = zone;
            if(level.gm_spawns.size >= 4) return;
        }
    }
    */
    
    if(level.gm_spawns.size < 4)
    {
        gm_generate_poi_spawns();
        level.b_use_poi_spawn_system = true;
    }
}

gm_search_spawns(a_s_spawns = [], n_max = 4)
{
    remaining_points = array::randomize(arraycopy(a_s_spawns));
    solution_set = [array::pop_front(remaining_points, false)];

    while(n_max > 1)
    {
        a_n_distances = [];

        foreach(spawn in remaining_points)
        {
            a_n_distances[a_n_distances.size] = int(distance2d(solution_set[0].origin, spawn.origin));
        }

        foreach(k_point, v_point in remaining_points)
        {
            foreach(k_ans, v_ans in solution_set)
            {
                a_n_distances[k_point] = int(min(a_n_distances[k_point], distance2d(v_point.origin, v_ans.origin)));
            }
        }

        i_max = 0;
        v_max = 0;
        foreach(k, v in a_n_distances)
        {
            if(v > v_max)
            {
                v_max = v;
                i_max = k;
            }
        }

        array::add(solution_set, array::pop(remaining_points, i_max, false));
        n_max--;
    }

    return solution_set;
}

CollectAllSpawns(zones)
{
    spawns = [];
    foreach(k in zones)
    {
        spawns = arraycombine(spawns, GetAllSpawnsFromZone(level.players[0], k), false, false);
    }
    return spawns;
}

gm_select_poi_spawn(player, return_struct = false)
{
    gm_generate_poi_spawns();

    // 1. Select furthest, non-visible spawn from all players on the map, via the POI cache array
    position = gm_search_pois(level.a_v_poi_spawns, player);

    if(!isdefined(position))
    {
        return GetRandomMapSpawn(player, return_struct, true);
    }

    return gm_poi_get_best_spawn(position);
}

gm_poi_get_best_spawn(position)
{
    // Do 8 bullet traces in a pitch circle, from origin + 70 and take the furthest result as the angles for the spawner
    // This should automatically make the player look away from walls, etc.

    s_spawn = spawnStruct();
    s_spawn.origin = position;
    
    i_max = 0;
    d_max = 0;
    for(i = 0; i < 8; i++)
    {
        n_angle = (i * (360 / 8)) - 180;
        trace = bullettrace(position + (0, 0, 70), position + (0, 0, 70) + VectorScale(anglesToForward((0, n_angle, 0)), 10000), 0, undefined);
        n_dist = distance2d(trace["position"], position + (0, 0, 70));
        if(n_dist > d_max)
        {
            d_max = n_dist;
            i_max = i;
        }
    }

    n_angle = (i_max * (360 / 8)) - 180;
    s_spawn.angles = (0, n_angle, 0);
    
    return s_spawn;
}

//GetClosestPointOnNavMesh
//ispointonnavmesh
//positionquery_source_navigation
gm_generate_poi_spawns()
{
    if(isdefined(level.a_v_poi_spawns)) return;
    // 1. Locate all points of player interest
        // A. Perk Machines
        // B. Mystery Boxes
        // C. Gobblegum Machines
        // D. Doors
        // E. Wall buys
    
    a_v_poi = [];
    a_v_poi = arraycombine(a_v_poi, gm_find_pap_origins(), false, false);
    a_v_poi = arraycombine(a_v_poi, gm_find_perk_origins(), false, false);
    a_v_poi = arraycombine(a_v_poi, gm_find_box_origins(), false, false);
    a_v_poi = arraycombine(a_v_poi, gm_find_gum_origins(), false, false);
    a_v_poi = arraycombine(a_v_poi, gm_find_door_origins(), false, false);
    a_v_poi = arraycombine(a_v_poi, gm_find_wallbuy_origins(), false, false);
    a_v_poi = array::remove_undefined(a_v_poi, false);
    a_v_poi = gm_limit_poi_set(a_v_poi, MAX_POIS);

    // 2. For each poi, positionquery_source_navigation
        // Foreach returned point, check ispointonnavmesh
        // when one is, this is a spawn point.

    if(!isdefined(level.struct_class_names["targetname"]["poi_spawn_point"]))
    {
        level.struct_class_names["targetname"]["poi_spawn_point"] = [];
    }
    if(!isdefined(level.struct_class_names["targetname"]["player_respawn_point"]))
    {
        level.struct_class_names["targetname"]["player_respawn_point"] = [];
    }
    level.a_v_poi_spawns = [];
    foreach(v_point in a_v_poi)
    {
        if(is_point_in_bad_zone(v_point)) continue;
        if(point_bad_by_location(v_point)) continue;
        points = util::positionquery_pointarray(v_point, 0, 100, 150, 50); // tightening these parameters produces less variance, but it also makes sure people dont spawn in weird spots.
        if(!isdefined(points)) continue;
        points = array::randomize(points);
        foreach(potential in points)
        {
            if(ispointonnavmesh(potential, level.players[0]) && zm_utility::check_point_in_playable_area(potential))
            {
                level.a_v_poi_spawns[level.a_v_poi_spawns.size] = potential;
                s_spawn = spawnStruct();
                s_spawn.origin = potential;
                s_spawn.targetname = "poi_spawn_point";
                array::add(level.struct_class_names["targetname"]["poi_spawn_point"], s_spawn, false);
                break;
            }
        }
    }
    s_respawner = spawnStruct();
    s_respawner.targetname = "player_respawn_point";
    s_respawner.target = "poi_spawn_point";
    s_respawner.origin = (0,0,0);
    array::add(level.struct_class_names["targetname"]["player_respawn_point"], s_respawner, false);
}

gm_find_pap_origins()
{
    a_v_paps = [];
    foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
        {
            continue;
        }

        angles = ent.angles + V_PAP_ANGLE_OFFSET;
        origin = gm_calc_poi_offset(ent.origin, angles);
        if(IS_DEBUG && DEBUG_PAP_ANGLES)
        {
            dev_actor(origin, angles);
        }

        a_v_paps[a_v_paps.size] = origin;
    }
    
    foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
        {
            continue;
        }

        angles = ent.angles + V_PAP_ANGLE_OFFSET;
        origin = gm_calc_poi_offset(ent.origin, angles);
        if(IS_DEBUG && DEBUG_PAP_ANGLES)
        {
            dev_actor(origin, angles);
        }

        a_v_paps[a_v_paps.size] = origin;
    }
    return gm_limit_poi_set(a_v_paps, MAX_PAP_POIS);
}

gm_find_perk_origins()
{
    if(level.script == "zm_moon") 
    {
        return []; // prevents spawning on area 51
    }
    a_v_perks = [];
    foreach(perk in level._custom_perks)
    {
        if(!isdefined(perk.radiant_machine_name)) continue;
        ent_array = getentarray(perk.radiant_machine_name, "targetname");
        if(ent_array.size < 1) continue;
        foreach(ent in ent_array)
        {
            if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
            {
                continue;
            }
            angles = ent.angles + V_PERK_ANGLE_OFFSET;
            origin = gm_calc_poi_offset(ent.origin, angles);
            if(IS_DEBUG && DEBUG_PERK_ANGLES)
            {
                dev_actor(origin, angles);
            }
            array::add(a_v_perks, origin, 0);
        }
    }
    return gm_limit_poi_set(a_v_perks, MAX_PERK_POIS);
}

gm_find_box_origins()
{
    a_v_boxes = [];
    foreach(box in level.chests)
    {
        v_position = isdefined(box.orig_origin) ? box.orig_origin : box.origin;
        if(!isdefined(box.angles) || !isdefined(v_position)) 
        {
            continue;
        }
        angles = box.angles + V_BOX_ANGLE_OFFSET;
        origin = gm_calc_poi_offset(v_position, angles);
        if(IS_DEBUG && DEBUG_BOX_ANGLES)
        {
            dev_actor(origin, angles);
        }
        a_v_boxes[a_v_boxes.size] = origin;
    }
    return gm_limit_poi_set(a_v_boxes, MAX_BOX_POIS);
}

gm_find_gum_origins()
{
    a_v_gums = [];
    foreach(trig in getentarray("bgb_machine_use", "targetname"))
    {
        if(!isdefined(trig.angles) || !isdefined(trig.origin)) 
        {
            continue;
        }
        angles = trig.angles + V_GUM_ANGLE_OFFSET;
        origin = gm_calc_poi_offset(trig.origin, angles);
        if(IS_DEBUG && DEBUG_GUM_ANGLES)
        {
            dev_actor(origin, angles);
        }
        a_v_gums[a_v_gums.size] = origin;
    }
    return gm_limit_poi_set(a_v_gums, MAX_GUM_POIS);
}

gm_find_door_origins()
{
    a_v_doors = [];
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    foreach(type in types)
    {
        zombie_doors = GetEntArray(type, "targetname");
        foreach(door in zombie_doors)
        {
            if(!isdefined(door.origin)) 
            {
                continue;
            }
            a_v_doors[a_v_doors.size] = door.origin;
        }
    }
    return gm_limit_poi_set(a_v_doors, MAX_DOOR_POIS);
}

gm_find_wallbuy_origins()
{
    a_v_weapons = [];
    spawnable_weapon_spawns = struct::get_array("weapon_upgrade", "targetname");
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("bowie_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("sickle_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("tazer_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("buildable_wallbuy", "targetname"), 1, 0);
	if(isdefined(level.use_autofill_wallbuy) && level.use_autofill_wallbuy)
	{
		spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, level.active_autofill_wallbuys, 1, 0);
	}
    foreach(weapon in spawnable_weapon_spawns)
    {
        if(!isdefined(weapon.angles) || !isdefined(weapon.origin)) 
        {
            continue;
        }
        angles = weapon.angles + V_WALL_ANGLE_OFFSET;
        origin = gm_calc_poi_offset(weapon.origin, angles);
        origin = groundtrace(origin, origin + (0,0,-1000), 0, undefined)["position"];
        if(!isdefined(origin)) continue;
        if(IS_DEBUG && DEBUG_WALL_ANGLES)
        {
            dev_actor(origin, angles);
        }
        a_v_weapons[a_v_weapons.size] = origin;
    }
    return gm_limit_poi_set(a_v_weapons, MAX_WALL_POIS);
}

gm_search_pois(a_v_spawns = [], target_player)
{
    if(a_v_spawns.size < 1) return undefined;
    remaining_points = a_v_spawns;
    solution_set = [];
    foreach(player in array::randomize(getplayers()))
    {
        if(player == target_player) continue;
        if(player.sessionstate != "playing") continue;
        solution_set[solution_set.size] = player.origin;
    }
    if(solution_set.size < 1)
    {
        solution_set[0] = remaining_points[randomint(remaining_points.size)];
    }
    a_n_distances = [];
    foreach(spawn in remaining_points)
    {
        a_n_distances[a_n_distances.size] = int(distance2d(solution_set[0], spawn));
    }
    foreach(k_point, v_point in remaining_points)
    {
        foreach(k_ans, v_ans in solution_set)
        {
            a_n_distances[k_point] = int(min(a_n_distances[k_point], distance2d(v_point, v_ans)));
        }
    }
    i_max = 0;
    v_max = 0;
    foreach(k, v in a_n_distances)
    {
        if(v > v_max)
        {
            v_max = v;
            i_max = k;
        }
    }
    return remaining_points[i_max];
}

gm_calc_poi_offset(origin, angles)
{
    return VectorScale(anglesToForward(angles), 50) + origin;
}

// uses a blacklist of zones to check against every possible POI spawn generated.
is_point_in_bad_zone(v_point)
{
    // prevents a scenario where the only zones in the map meet auto-blacklist criteria, which would generate no spawns
    if(!single_check_enough_zones()) return false;
    foreach(target_zone in level.gm_blacklisted)
    {
        if(is_point_inside_zone(v_point, level.zones[target_zone])) // thats annoying. bug with blacklisting cause i passed str_zone instead of level.zones[str_zone]. :lemonsadge
        {
            return true;
        }
    }
    return false;
}

single_check_enough_zones()
{
    if(isdefined(level.gm_single_check_enough_zones))
    {
        return level.gm_single_check_enough_zones;
    }
    level.gm_single_check_enough_zones = true;
    foreach(k, v in level.zones)
    {
        if(!isinarray(level.gm_blacklisted, k)) return true;
    }
    level.gm_single_check_enough_zones = false;
    return false;
}

auto_blacklist_zones()
{
    terms = get_blacklist_zone_terms();
    foreach(k, v in level.zones)
    {
        foreach(term in terms)
        {
            if(issubstr(k, term))
            {
                level.gm_blacklisted[level.gm_blacklisted.size] = k;
                break;
            }
        }
    }
    level.gm_blacklisted = arraycombine(level.gm_blacklisted, get_additional_blacklist(), 0, 0);
}

gm_limit_poi_set(a_poi_set = [], count = 0)
{
    if(a_poi_set.size <= count)
    {
        return a_poi_set;
    }
    a_poi_set = array::randomize(a_poi_set);
    a_v_copy = [];
    for(i = 0; i < count; i++)
    {
        a_v_copy[i] = a_poi_set[i];
    }
    return a_v_copy;
}

gm_oob_fix()
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");
    initmaps();
    if(!isdefined(level.gm_oob_monitors) || !isarray(level.gm_oob_monitors))
    {
        return;
    }
    while(true)
    {
        wait 0.1;
        if(isdefined(self.lander) && self.lander)
        {
            continue;
        }
        if(isdefined(self.beastmode) && self.beastmode)
        {
            continue;
        }
        if(isdefined(self._padded) && self._padded)
        {
            continue;
        }
        if(isdefined(self.var_122a2dda) && self.var_122a2dda)
        {
            continue;
        }
        self.oob_zone_cache = self zm_zonemgr::get_player_zone();
        foreach(callback in level.gm_oob_monitors)
        {
            if(self [[ callback ]]())
            {
                self playsound("zmb_bgb_plainsight_start");
                playfx(level._effect["teleport_splash"], self.origin);
                self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - GM_TELEPORT_STRAT_PENALTY));
                self Try_Respawn(true);
                break;
            }
        }
    }
}

zm_cosmodrome_oob_check1()
{
    if(self.origin[2] < 200)
    {
        return false;
    }
    if(self.origin[0] > -1500)
    {
        return false;
    }
    return distance2D(self.origin, (-1782, 1641, 200)) < 2500;
}

zm_cosmodrome_oob_check2()
{
    if(self.origin[2] < 25)
    {
        return false;
    }
    return distance2D(self.origin, (-964, -54, 28)) < 250;
}

zm_cosmodrome_oob_check3()
{
    if(self.origin[2] < 0)
    {
        return false;
    }
    if(self.origin[1] < 1980)
    {
        return false;
    }
    if(self.origin[0] < 170)
    {
        return false;
    }
    return self.origin[0] < 1400;
}

zm_zod_oob_check1()
{
    if(self.origin[2] < 512)
    {
        return false;
    }
    if(distance2D(self.origin, (4387, -4187, 546)) > 1000)
    {
        return false;
    }
    if(!isdefined(self.oob_zone_cache) || self.oob_zone_cache == "zone_theater_high_A")
    {
        return true;
    }
    return false;
}

zm_zod_oob_check2()
{
    if(self.origin[2] < 350)
    {
        return false;
    }
    if(distance2D(self.origin, (2758, -5969, 275)) > 2500)
    {
        return false;
    }
    if(!isdefined(self.oob_zone_cache))
    {
        return true;
    }
    return false;
}

zm_zod_oob_check3()
{
    if(self.origin[2] < 625)
    {
        return false;
    }
    if(distance2D(self.origin, (5440, -3303, 248)) > 1000)
    {
        return false;
    }
    if(!isdefined(self.oob_zone_cache))
    {
        return true;
    }
    return false;
}

zm_castle_oob_check1()
{
    if(self.origin[2] < 800)
    {
        return false;
    }
    if(distance2D(self.origin, (1431, 2463, 839)) > 1000)
    {
        return false;
    }
    if(distance2D(self.origin, (182, 2195, 912)) < 450)
    {
        return false;
    }
    return !isdefined(self.oob_zone_cache);
}

zm_castle_oob_check2()
{
    if(self.origin[2] < 980)
    {
        return false;
    }
    if(isdefined(self.oob_zone_cache) && self.oob_zone_cache == "zone_clocktower")
    {
        return false;
    }
    if(distance2D(self.origin, (182, 2195, 912)) < 450)
    {
        return false;
    }
    return true;
}

zm_temple_oob_check1()
{
    if(self.origin[2] < 480)
    {
        return false;
    }
    return distance2d(self.origin, (-2, 520, 496)) < 300;
}

zm_temple_oob_check2()
{
    if(self.origin[2] < 58)
    {
        return false;
    }
    return distance2d(self.origin, (1444, -757, 143)) < 200;
}

zm_temple_oob_check3()
{
    if(self.origin[2] < -295)
    {
        return false;
    }
    return !isdefined(self.oob_zone_cache) && distance2d(self.origin, (1385, -136, -293)) < 150;
}

zm_temple_oob_check4()
{
    if(self.origin[2] < -150)
    {
        return false;
    }
    return !isdefined(self.oob_zone_cache) && distance2d(self.origin, (529, -401, -142)) < 100;
}

zm_temple_oob_check5()
{
    if(self.origin[2] < -325)
    {
        return false;
    }
    return !isdefined(self.oob_zone_cache) && distance2d(self.origin, (-433, -901, -208)) < 1000;
}

zm_stalingrad_oob_check1()
{
    if(isdefined(self.oob_zone_cache) && self.oob_zone_cache == "boss_arena_zone")
    {
        return true;
    }
    return false;
}

zm_stalingrad_oob_check2()
{
    if(isdefined(self.var_a0a9409e) && self.var_a0a9409e)
    {
        return false;
    }
    if(!isdefined(self.oob_zone_cache))
    {
        if(!isdefined(self.zm_stalingrad_oob_check2))
        {
            self.zm_stalingrad_oob_check2 = 0;
        }
        self.zm_stalingrad_oob_check2 += 0.1;
        if(self.zm_stalingrad_oob_check2 > 5) // oob for 5 seconds
        {
            self.zm_stalingrad_oob_check2 = 0;
            return true;
        }
        return false;
    }
    self.zm_stalingrad_oob_check2 = 0;
    return false;
}

#region ZM_ISLAND

#endregion
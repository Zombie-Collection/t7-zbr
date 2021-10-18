init()
{
    if(isdefined(level.__init_gm))
    {
        return;
    }
    if(DISABLE_ISLAND && level.script == "zm_island")
    {
        killserver();
    }
    level.__init_gm = true;
    level.gm_teams = array::randomize(array("allies", "axis", "neutral", "free"));
    level.gm_team_colors = [];
    if(STABILITY_PASS) SetDvar("developer", "2");
    level.gm_id = randomint(level.gm_teams.size); // randomint(level.gm_teams.size)
    level.spectatetype = 2;
    if(!IS_DEBUG || !DEBUG_REVERT_SPAWNS)
    level.check_for_valid_spawn_near_team_callback = serious::GetRandomMapSpawn;
    level.player_too_many_weapons_monitor = serious::nullsub; // fix bs with their weapons logic
}

on_player_connect()
{ 
    init();
    if(isdefined(self.gm_id))
    {
        return;
    }
    self.gm_id = int(level.gm_id / (is_zbr_teambased() ? get_zbr_teamsize() : 1));
    level.gm_id = int((level.gm_id + 1) % level.gm_teams.size);
    self.noHitMarkers = false;

    if(!isdefined(level.gm_team_colors[self.gm_id]))
    {
        level.gm_team_colors[self.gm_id] = self getEntityNumber();
    }

    if(level.players.size > 4)
    {
        level.b_use_poi_spawn_system = true;
    }
    
    if(self ishost())
    {
        initgamemode();
    }
}

GetSpawnTeamID()
{
    return self.gm_id + 3;
}

get_fixed_team_name()
{
    return level.gm_teams[self.gm_id % level.gm_teams.size];
}

on_player_spawned()
{
    self on_player_connect();
    if(FORCE_HOST && self ishost())
    {
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 0);
        SetDvar("party_neverJoinRecent", 1);
        SetDvar("party_readyPercentRequired", 0.25);
        SetDvar("partyMigrate_disabled", 1);
        SetDvar("party_connectToOthers" , "0");
        SetDvar("partyMigrate_disabled" , "1");
        SetDvar("party_mergingEnabled" , "0");
    }

    if(!self ishost())
    {
        while(!isdefined(level.game_mode_init) || !level.game_mode_init)
        {
            wait 0.5;
        }
    }

    if(level.script == "zm_cosmodrome" && !isdefined(level.cosmodrome_lander_initial_wait))
    {
        level flag::wait_till("lander_grounded");
        level.cosmodrome_lander_initial_wait = true;
    }

    self thread GMSpawned();

    if(!isdefined(self.initial_spawn_fix))
    {
        waittillframeend;
        wait 0.05;
        self Try_Respawn();
        self.initial_spawn_fix = true;
    }

    wait 0.1;
    self notify("stop_player_too_many_weapons_monitor");
    self notify("stop_player_out_of_playable_area_monitor");
    foreach(player in level.players) player GM_CreateHUD();
}
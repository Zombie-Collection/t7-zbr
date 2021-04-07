init()
{
    if(STABILITY_PASS) SetDvar("developer", "2");
    level.gm_id = 0;
    if(!IS_DEBUG || !DEBUG_REVERT_SPAWNS)
    level.check_for_valid_spawn_near_team_callback = ::GetRandomMapSpawn;
}

on_player_connect()
{ 
    self.gm_id = level.gm_id;
    level.gm_id++;
    self.noHitMarkers = false;
    if(self ishost())
    {
        initgamemode();
    }
}

GetSpawnTeamID()
{
    return self.gm_id + 3;
}

on_player_spawned()
{
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

    if(level.script == "zm_cosmodrome")
    {
        level flag::wait_till("lander_grounded");
    }

    self thread GMSpawned();

    if(!isdefined(self.initial_spawn_fix))
    {
        self Try_Respawn();
        self.initial_spawn_fix = true;
    }

    wait 0.1;
    self notify("stop_player_out_of_playable_area_monitor");
    foreach(player in level.players) player GM_CreateHUD();
}
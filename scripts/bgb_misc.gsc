blacklist_bgb(bgb)
{
    if(!isdefined(level.bgb_blacklist))
        level.bgb_blacklist = [];
    arrayremoveindex(level.bgb, bgb, true);
    level.bgb_blacklist[level.bgb_blacklist.size] = bgb;
}

fix_bgb_pack()
{
	if(self util::is_bot()) return;
    if(!isdefined(level.bgb_blacklist))
    {
		level.bgb_blacklist = [];
	}
	
	// first, purge blacklisted gums from our pack
    foreach(bgb in level.bgb_blacklist)
    {
		if(isdefined(self.var_e610f362[bgb]))
		{
			arrayremoveindex(self.var_e610f362, bgb, true);
		}
        if(isinarray(self.var_98ba48a2, bgb))
		{
			arrayremovevalue(self.var_98ba48a2, bgb, false);
		}
    }

	// next, purge non-consumable gums from our pack
	bad_gums = [];
	good_gums = [];
	foreach(bgb in self.var_98ba48a2)
	{
		if(!isdefined(level.bgb[bgb]))
		{
			bad_gums[bad_gums.size] = bgb;
			continue;
		}
		if(isinarray(good_gums, bgb)) // duplicate
		{
			continue;
		}
		good_gums[good_gums.size] = bgb;
	}

	self.var_98ba48a2 = arraycopy(good_gums);
	foreach(bgb in bad_gums)
	{
		if(isdefined(self.var_e610f362[bgb]))
		{
			arrayremoveindex(self.var_e610f362, bgb, true);
		}
        if(isinarray(self.var_98ba48a2, bgb))
		{
			arrayremovevalue(self.var_98ba48a2, bgb, false);
		}
	}

	// next, determine suitable fillers for our pack
	possible_fillers = arraycopy(level.bgb);
	bad_gums = [];
	foreach(gum in arraycombine(good_gums, bad_gums, 0, 0))
	{
		arrayremoveindex(possible_fillers, gum, true);
	}

	a_keys = array::randomize(arraycopy(getArrayKeys(possible_fillers)));
	i = 0;
	// next, fill our pack back to 5 gums
	while(self.var_98ba48a2.size < 5)
	{
		bgb = a_keys[i];
		s_key = possible_fillers[bgb];
		self.var_e610f362[bgb] = spawnstruct();
		self.var_e610f362[bgb].var_e0b06b47 = 999; // quantity of this gum
		self.var_e610f362[bgb].var_b75c376 = -999; // number of times we used it this game
		array::add(self.var_98ba48a2, bgb, false);
		i++;
	}
}

free_perk_override(player)
{
	foreach(_player in level.players)
	{
		if(_player.sessionstate != "playing")
		{
			continue;
		}
		if(_player.team != player.team)
		{
			continue;
		}
		free_perk = _player zm_perks::give_random_perk();
		if(isdefined(free_perk) && isdefined(level.perk_bought_func))
		{
			_player [[level.perk_bought_func]](free_perk);
		}
	}
}

bgb_fith_activate()
{
	self endon("disconnect");
	self thread bgb_watch_fith();
	self playsound("zmb_bgb_fearinheadlights_start");
	self playloopsound("zmb_bgb_fearinheadlights_loop");
	self thread zm_bgb_fear_in_headlights::kill_fear_in_headlights();
	self bgb::run_timer(BGB_FITH_ACTIVE_TIME);
	self notify("kill_fear_in_headlights");
	foreach(player in level.players)
	{
		player.should_bgb_freeze = false;
	}
	players = getplayers();
	arrayremovevalue(players, self);
	bgb_fith_playersync(players);
}

bgb_watch_fith()
{
	self endon("disconnect");
	self endon("kill_fear_in_headlights");
	n_d_squared = 1200 * 1200;
	while(1)
	{
		allai = getaiarray();
		foreach(ai in allai)
		{
			if(isdefined(ai.var_48cabef5) && ai [[ai.var_48cabef5]]()) continue;
			if(isalive(ai) && !ai ispaused() && ai.team == level.zombie_team && !ai ishidden() && (!(isdefined(ai.bgbignorefearinheadlights) && ai.bgbignorefearinheadlights)))
			{
				pause_ai(ai);
			}
		}
		ai_out_of_range = [];
		ai_valid = [];
		foreach(ai in allai)
		{
			if(isdefined(ai.aat_turned) && ai.aat_turned && ai ispaused())
			{
				unpause_ai(ai);
				continue;
			}
			if(distance2dsquared(ai.origin, self.origin) >= n_d_squared)
			{
				ai_out_of_range[ai_out_of_range.size] = ai;
				continue;
			}
			ai_valid[ai_valid.size] = ai;
		}
		self check_fith(ai_out_of_range, 1);
		self check_fith(ai_valid, 0, 75);
		self check_player_fith(n_d_squared);
		wait(0.05);
	}
}

pause_ai(ai)
{
	ai notify(#"hash_4e7f43fc");
	ai thread pause_cleanup();
	ai setentitypaused(1);
	ai.var_70a58794 = ai.b_ignore_cleanup;
	ai.b_ignore_cleanup = 1;
	ai.var_7f7a0b19 = ai.is_inert;
	ai.is_inert = 1;
}

pause_cleanup()
{
	self endon(#"hash_4e7f43fc");
	self waittill("death");
	if(isdefined(self) && self ispaused())
	{
		self setentitypaused(0);
		if(!self isragdoll())
		{
			self startragdoll();
		}
	}
}

unpause_ai(ai)
{
	ai notify(#"hash_4e7f43fc");
	ai setentitypaused(0);
	if(isdefined(ai.var_7f7a0b19))
	{
		ai.is_inert = ai.var_7f7a0b19;
	}
	if(isdefined(ai.var_70a58794))
	{
		ai.b_ignore_cleanup = ai.var_70a58794;
	}
	else
	{
		ai.b_ignore_cleanup = 0;
	}
}

check_fith(allai, trace, degree = 45)
{
	a_e_ignore = allai;
	n_cos = cos(degree);
	a_e_ignore = self cantseeentities(a_e_ignore, n_cos, trace);
	foreach(ai in a_e_ignore)
	{
		if(isai(ai) && isalive(ai)) unpause_ai(ai);
	}
}

bgb_rr_activate()
{
    level.var_dfd95560 = 1;
	zm_bgb_round_robbin::function_8824774d(level.round_number + 1);
	foreach(player in level.players)
	{
		if(zm_utility::is_player_valid(player) && player.team == self.team)
		{
			multiplier = zm_score::get_points_multiplier(player);
			player zm_score::add_to_player_score(multiplier * 1600, 1, "gm_zbr_admin");
		}
	}
}

attempt_pop_shocks(target)
{
	if(isdefined(self.beastmode) && self.beastmode) return;
    if(!isdefined(self.var_69d5dd7c) || self.var_69d5dd7c <= 0) return;
	self bgb::do_one_shot_use();
	self.var_69d5dd7c = self.var_69d5dd7c - 1;
	self bgb::set_timer(self.var_69d5dd7c, 5);
	self playsound("zmb_bgb_popshocks_impact");
	zombie_list = getaiteamarray(level.zombie_team);
	foreach(ai in zombie_list)
	{
		if(!isdefined(ai) || !isalive(ai)) continue;
		test_origin = ai getcentroid();
		dist_sq = distancesquared(target.origin, test_origin);
		if(dist_sq < 16384)
		{
			self thread zm_bgb_pop_shocks::electrocute_actor(ai);
		}
	}
    foreach(enemy in level.players)
    {
        if(enemy == self) continue;
		if(enemy.team == self.team) continue;
        if(enemy.sessionstate != "playing") continue;
        dist_sq = distancesquared(target.origin, enemy.origin + (0,0,50));
        if(dist_sq < 16384)
        {
            self thread pop_shocks_damage(enemy);
        }
    }
}

pop_shocks_damage(player)
{
    player thread electric_cherry_stun();
    player thread electric_cherry_shock_fx();
    player dodamage(BGB_POPSHOCKS_PVP_DAMAGE * level.round_number, self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, getweapon("pistol_burst"));
}

bgb_ps_actordamage(inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
	if(isdefined(meansofdeath) && meansofdeath == "MOD_MELEE")
	{
		attacker attempt_pop_shocks(self);
	}
	return damage;
}

bgb_ps_vehicledamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
	if(isdefined(smeansofdeath) && smeansofdeath == "MOD_MELEE")
	{
		eattacker attempt_pop_shocks(self);
	}
	return idamage;
}

bgb_burnedout_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	bgb_uses_remaing = BGB_BURNEDOUT_MAX;
	self thread bgb::set_timer(BGB_BURNEDOUT_MAX, BGB_BURNEDOUT_MAX);
	for(;;)
	{
		self waittill("damage", amount, attacker, direction_vec, point, type);
		if("MOD_MELEE" != type) continue;
		self thread bgb_burnedout_result();
		self playsound("zmb_bgb_powerup_burnedout");
		bgb_uses_remaing--;
		self thread bgb::set_timer(bgb_uses_remaing, BGB_BURNEDOUT_MAX);
		self bgb::do_one_shot_use();
		if(!bgb_uses_remaing) return;
		wait(1.5);
	}
}

bgb_burnedout_result()
{
	self clientfield::increment_to_player("zm_bgb_burned_out" + "_1p" + "toplayer");
	self clientfield::increment("zm_bgb_burned_out" + "_3p" + "_allplayers");
	zombies = array::get_all_closest(self.origin, getaiteamarray(level.zombie_team), undefined, undefined, 720);
    players = array::get_all_closest(self.origin, getplayers(), undefined, undefined, 400);
    arrayremovevalue(self, players, false);
    foreach(zombie in zombies)
    {
        if(isdefined(zombie.ignore_nuke) && zombie.ignore_nuke) continue;
        if(isdefined(zombie.marked_for_death) && zombie.marked_for_death) continue;
        if(zm_utility::is_magic_bullet_shield_enabled(zombie)) continue;
        zombie.marked_for_death = 1;
        zombie clientfield::increment("zm_bgb_burned_out" + "_fire_torso" + (isvehicle(zombie) ? "_vehicle" : "_actor"));
        zombie dodamage(zombie.health + 666, zombie.origin, self, self);
        util::wait_network_frame();
    }
    w_weapon = self getCurrentWeapon();
    foreach(player in players)
    {
        if(player.sessionstate != "playing") continue;
        player thread blast_furnace_player_burn(self, w_weapon, BGB_BURNEDOUT_PVP_DAMAGE);
        util::wait_network_frame();
    }
}

bgb_kt_activate()
{
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		if(player == self) continue;
		if(player.team == self.team) continue;
		player thread bgb_kt_freeze(self);
	}
	self zm_bgb_killing_time::activation();
	level notify("kt_end");
}

bgb_kt_freeze(attacker)
{
	self endon("disconnect");
	self.bgb_kt_frozen = true;
	self bgb_freeze_player(true);
	level waittill("kt_end");
	self.bgb_kt_frozen = false;
	if(isdefined(self.bgb_kt_marked) && self.bgb_kt_marked)
	{
		self.bgb_frozen = false;
		self dodamage(int(self.maxhealth * BGB_KILLINGTIME_MARKED_PCT), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		self.bgb_frozen = true;
	}
	self bgb_freeze_player(false);
	self.bgb_kt_marked = false;
}

// delay unset is the buffer window between unfreezing a player and removing their damage reduction
bgb_freeze_player(result, delay_unset = 1)
{
	self notify("bgb_freeze_update");
	if(result)
	{
		if(isdefined(self.freeze_obj))
		{
			self unlink();
			self.freeze_obj delete();
		}
		self freezeControls(true);
		self setentitypaused(true);
		self.bgb_freeze_dmg_protect = false;
		self.bgb_frozen = true;
		self setstance("stand");
		self setvelocity((0,0,0));
		wait 0.05;
		self.freeze_obj = spawn("script_origin", self.origin);
		self.freeze_obj.angles = self getPlayerAngles();
		self linkto(self.freeze_obj);
	}
	else 
	{
		self unlink();
		self.bgb_frozen = false;
		self freezeControls(false);
		self setentitypaused(false);
		self thread bgb_unset_frozen_timed(delay_unset);
	}
}

bgb_unset_frozen_timed(time)
{
	self endon("disconnect");
	self endon("bgb_freeze_update");
	self endon("bled_out");
	self.bgb_freeze_dmg_protect = true;
	wait time;
	self.bgb_freeze_dmg_protect = false;
}

bgb_player_frozen()
{
	return isdefined(self.bgb_frozen) && self.bgb_frozen;
}

check_player_fith(distance)
{
	a_p_tofreeze = [];
	players = getplayers();
	arrayremovevalue(players, self);
	foreach(player in players)
	{
		if(player.sessionstate != "playing") continue;
		if(player.team == self.team) continue;
		player.should_bgb_freeze = true;
		if(distance2dsquared(player.origin, self.origin) >= distance) player.should_bgb_freeze = false;
		else a_p_tofreeze[a_p_tofreeze.size] = player;
	}

	group_1 = self cantseeentities(players, cos(45), true);
	group_2 = self cantseeentities(players, cos(75), false);

	foreach(player in arraycombine(group_1, group_2, 0, 0))
	{
		player.should_bgb_freeze = false;
	}
	bgb_fith_playersync(players);
}

bgb_fith_playersync(players)
{
	foreach(player in players)
	{
		if(isdefined(player.bgb_kt_frozen) && player.bgb_kt_frozen) continue;
		res = isdefined(player.should_bgb_freeze) && player.should_bgb_freeze;
		if(res != player bgb_player_frozen())
			player bgb_freeze_player(res);
	}
}

bgb_any_frozen()
{
	return self bgb_player_frozen() || (isdefined(self.bgb_kt_frozen) && self.bgb_kt_frozen);
}

bgb_idle_eyes_activate()
{
	self endon("disconnect");
	players = [self];
	self thread zm_utility::increment_ignoreme();
	self.bgb_idle_eyes_active = 1;
	if(!bgb::function_f345a8ce("zm_bgb_idle_eyes"))
	{
		if(isdefined(level.no_target_override))
		{
			if(!isdefined(level.var_4effcea9))
			{
				level.var_4effcea9 = level.no_target_override;
			}
			level.no_target_override = undefined;
		}
	}
	level thread zm_bgb_idle_eyes::function_1f57344e(self, players);
	self playsound("zmb_bgb_idleeyes_start");
	self playloopsound("zmb_bgb_idleeyes_loop", 1);
	self thread bgb::run_timer(31);
	visionset_mgr::activate("visionset", "zm_bgb_idle_eyes", self, 0.5, 30, 0.5);
	visionset_mgr::activate("overlay", "zm_bgb_idle_eyes", self);
	ret = self util::waittill_any_timeout(30.5, "bgb_about_to_take_on_bled_out", "end_game", "bgb_update", "disconnect");
	self stoploopsound(1);
	self playsound("zmb_bgb_idleeyes_end");
	if("timeout" != ret)
	{
		visionset_mgr::deactivate("visionset", "zm_bgb_idle_eyes", self);
	}
	else
	{
		wait(0.5);
	}
	visionset_mgr::deactivate("overlay", "zm_bgb_idle_eyes", self);
	self.bgb_idle_eyes_active = undefined;
	self notify(#"hash_16ab3604");
	zm_bgb_idle_eyes::deactivate(players);
}

bgb_profit_sharing_override(n_points = 0, str_awarded_by = "none", var_1ed9bd9b = false)
{
	if(!isdefined(n_points))
	{
		return n_points;
	}
	if(str_awarded_by == "zm_bgb_profit_sharing")
	{
		return n_points;
	}
	switch(str_awarded_by)
	{
		case "bgb_machine_ghost_ball":
		case "gm_zbr_admin":
		case "equip_hacker":
		case "magicbox_bear":
		case "reviver":
		{
			return n_points;
		}
		default:
		{
			break;
		}
	}
	if(!var_1ed9bd9b)
	{
		foreach(e_player in getplayers())
		{
			if(e_player.sessionstate != "playing")
			{
				continue;
			}
			if(isdefined(e_player) && isdefined(e_player bgb::get_enabled()) && "zm_bgb_profit_sharing" == (e_player bgb::get_enabled()))
			{
				if(isdefined(e_player.var_6638f10b) && isarray(e_player.var_6638f10b) && array::contains(e_player.var_6638f10b, self))
				{
					e_player thread zm_score::add_to_player_score(n_points, 1, "zm_bgb_profit_sharing");
				}
			}
		}
	}
	else if(isdefined(self.var_6638f10b) && self.var_6638f10b.size > 0)
	{
		foreach(e_player in self.var_6638f10b)
		{
			if(e_player.sessionstate != "playing")
			{
				continue;
			}
			if(isdefined(e_player) && e_player.team == self.team)
			{
				e_player thread zm_score::add_to_player_score(n_points, 1, "zm_bgb_profit_sharing");
			}
		}
	}
	return n_points;
}

bgb_mind_blown_activate()
{
	self endon("disconnect");
	self thread bgb_mind_blown_watch();
	self zm_bgb_mind_blown::activation();
}

bgb_mind_blown_watch()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("spawned_player");
	self endon(#"hash_7946ded7");

	n_d_squared = 1200 * 1200;
	targets = [];
	a_e_players = getplayers();
	arrayremovevalue(a_e_players, self, false);
	foreach(player in a_e_players)
	{
		if(player.sessionstate != "playing") continue;
		if(distance2dsquared(player.origin, self.origin) >= n_d_squared)
		{
			continue;
		}
		array::add(targets, player);
	}
	self blow_mind_of_players(targets, 0, 75);
}

blow_mind_of_players(a_e_players, trace, degree = 45)
{
	a_e_ignore = a_e_players;
	players = getplayers();
	n_cos = cos(degree);
	a_e_ignore = self cantseeentities(a_e_ignore, n_cos, trace);
	foreach(player in a_e_players)
	{
		if(isinarray(a_e_ignore, player)) continue;
		self thread blow_mind(player);
	}
}

blow_mind(player)
{
	player shellshock("flashbang", 1.0, 0);
	player arc_damage_ent(self, 1, level.zm_aat_dead_wire_lightning_chain_params);
}

anywhere_but_here_activation()
{
	b_callback_set = false;
	if(level.b_use_poi_spawn_system && (!isdefined(level.var_2c12d9a6) || (level.var_2c12d9a6 != serious::bgb_get_poi_spawn)))
	{
		old_callback = level.var_2c12d9a6;
		level.var_2c12d9a6 = serious::bgb_get_poi_spawn;
		b_callback_set = true;
	}
	self zm_bgb_anywhere_but_here::activation();
	if(b_callback_set)
	{
		level.var_2c12d9a6 = old_callback;
	}
}

bgb_get_poi_spawn()
{
	possible_spawns = arraycopy(level.struct_class_names["targetname"]["poi_spawn_point"]);
	closest_spawns = array::get_all_closest(self.origin, possible_spawns, undefined, undefined, 10000);
	if(closest_spawns.size < 1)
	{
		return array::random(possible_spawns);
	}
	to_remove = int(min(possible_spawns.size * 0.2, closest_spawns.size));
	if(to_remove < 1 && (possible_spawns.size > 1))
	{
		to_remove = 1;
	}
	for(i = 0; i < to_remove; i++)
	{
		arrayremovevalue(possible_spawns, closest_spawns[i], false);
	}
	return array::random(possible_spawns);
}

bgb_armamental_disable()
{
	if(!isdefined(self.wager_gm3_goldknife) || !self.wager_gm3_goldknife)
	{
		self unsetperk("specialty_fastmeleerecovery");
	}
	self unsetperk("specialty_fastequipmentuse");
	self unsetperk("specialty_fasttoss");
}

bgb_crawl_space_activate()
{
	a_ai = getaiarray();
	for(i = 0; i < a_ai.size; i++)
	{
		if(isdefined(a_ai[i]) && isalive(a_ai[i]) && isdefined(a_ai[i].archetype) && a_ai[i].archetype == "zombie" && isdefined(a_ai[i].gibdef))
		{
			var_5a3ad5d6 = distancesquared(self.origin, a_ai[i].origin);
			if(var_5a3ad5d6 < 360000)
			{
				a_ai[i] zombie_utility::makezombiecrawler();
			}
		}
	}

	a_players = getplayers();
	foreach(player in a_players)
	{
		if(player == self) continue;
		if(player.team == self.team) continue;
		if(player.sessionstate != "playing") continue;
		if(distanceSquared(self.origin, player.origin) > 360000) continue;
		player thread prone_for_time(BGB_CRAWL_SPACE_TIME);
		player dodamage(1000, player.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
	}
}

prone_for_time(time = 3)
{
	self endon("disconnect");
	self endon("bled_out");
	self notify("prone_for_time");
	self endon("prone_for_time");
	self allowStand(0);
	self allowCrouch(0);
	self allowprone(1);
	self disableusability();
	self.gm_forceprone = true;
	self setstance("prone");
	wait time;
	self.gm_forceprone = false;
	self enableusability();
	self allowStand(1);
	self allowCrouch(1);
}

bgb_phoenix_up_activate()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self.lives = 1;
	self waittill("player_downed");
	while(!isdefined(self.laststandpistol) || (self getcurrentweapon() != self.laststandpistol))
	{
		wait(0.05);
	}
	if(isdefined(self.revivetrigger) && isdefined(self.revivetrigger.beingrevived))
	{
		self.revivetrigger setinvisibletoall();
		self.revivetrigger.beingrevived = 0;
	}
	self bgb::do_one_shot_use();
	self thread bgb::function_7d63d2eb();
	self zm_laststand::auto_revive(self, false);
	playsoundatposition("zmb_bgb_phoenix_activate", (0, 0, 0));
	self.gm_override_reduce_pts = BGB_PHOENIX_SPAWN_REDUCE_POINTS;
	self restore_earned_points();
	self.gm_override_reduce_pts = 0;
	self.lives = 0;
}

bgb_pup_lost_perk(perk, var_2488e46a = undefined, var_24df4040 = undefined)
{
	self thread bgb::revive_and_return_perk_on_bgb_activation(perk);
	return false;
}

bgb_impatient_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	self waittill("bgb_about_to_take_on_bled_out");
	self thread bgb_impatient_respawn();
}

bgb_impatient_respawn()
{
	self endon("disconnect");
	wait(1);
	self zm::spectator_respawn_player();
	self bgb::do_one_shot_use();
}

bgb_extra_credit_activate()
{
	origin = self bgb::function_c219b050();
	self thread spawn_extra_credit(origin);
}

spawn_extra_credit(origin)
{
	self endon("disconnect");
	self endon("bled_out");
	powerup = zm_powerups::specific_powerup_drop("bonus_points_player", origin, undefined, undefined, 0.1);
	powerup.bonus_points_powerup_override = serious::bgb_extra_credit_value;
	level thread powerup_fixup(powerup);
	return powerup;
}

powerup_fixup(powerup)
{
	wait(1);
	if(isdefined(powerup) && (!powerup zm::in_enabled_playable_area() && !powerup zm::in_life_brush()))
	{
		level thread bgb::function_434235f9(powerup);
	}
}

bgb_extra_credit_value()
{
	return BGB_EXTRA_CREDIT_VALUE;
}

bgb_coagulant_activate()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self.lives = 1;
	self waittill("player_downed");
	while(!isdefined(self.laststandpistol) || (self getcurrentweapon() != self.laststandpistol))
	{
		wait(0.05);
	}
	if(isdefined(self.revivetrigger) && isdefined(self.revivetrigger.beingrevived))
	{
		self.revivetrigger setinvisibletoall();
		self.revivetrigger.beingrevived = 0;
	}
	self bgb::do_one_shot_use();
	self zm_laststand::auto_revive(self, false);
	self.gm_override_reduce_pts = BGB_COAGULANT_SPAWN_REDUCE_POINTS;
	self restore_earned_points();
	self.gm_override_reduce_pts = 0;
	self.lives = 0;
}

bgb_arms_grace_loadout()
{
	self.bgb_arms_grace_activation = false;
	if(isdefined(self.var_e445bfc6) && self.var_e445bfc6)
	{
		self.var_e445bfc6 = false;
		self bgb::give("zm_bgb_arms_grace");
		self thread bgb_arms_grace_dmg();
	}
	else if(isdefined(level.givecustomloadout))
	{
		self [[level.givecustomloadout]]();
	}
}

bgb_arms_grace_dmg()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self.bgb_arms_grace_activation = true;
	self thread bgb_arms_grace_deactivate();
	self bgb::run_timer(BGB_ARMS_GRACE_DURATION);
	self thread bgb_arms_grace_cleanup();
}

bgb_arms_grace_deactivate()
{
	self notify("bgb_arms_grace_deactivate");
	self endon("bgb_arms_grace_deactivate");
	self endon("disconnect");
	self util::waittill_any_timeout(BGB_ARMS_GRACE_DURATION, "bgb_update");
	self.bgb_arms_grace_activation = false;
}

bgb_ag_active()
{
	return isdefined(self.bgb_arms_grace_activation) && self.bgb_arms_grace_activation;
}

bgb_arms_grace_cleanup()
{
	self bgb::take();
	self clientfield::set_player_uimodel("bgb_display", 0);
	self clientfield::set_player_uimodel("bgb_activations_remaining", 0);
	self bgb::clear_timer();
}

bgb_always_done_swiftly_disable()
{
	self unsetperk("specialty_fastads");
	if(!isdefined(self.wager_gm1_rewards) || !self.wager_gm1_rewards)
	{
		self unsetperk("specialty_stalker");
	}
}

bgb_unquenchable_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	self endon("bled_out");
	while(true)
	{
		result = self util::waittill_any_return("perk_purchased", "player_downed");
		if(result == "player_downed")
		{
			self bgb::do_one_shot_use(1);
			return;
		}
		self zm_score::add_to_player_score(int(BGB_UNQUENCHABLE_CASHBACK_RD * level.round_number));
	}
}

bgb_ips_activate()
{
	self endon("disconnect");
	self SetInvisibleToAll();
    self SetInvisibleToPlayer(self, false);
	self thread show_owner_on_attack(self);
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
    self.invis_glow = spawn("script_model", self.origin);
    self.invis_glow linkto(self);
    self.invis_glow setmodel("tag_origin");
    self.invis_glow thread clone_fx_cleanup(self.invis_glow);
    playfxontag(level._effect["monkey_glow"], self.invis_glow, "tag_origin");
	zm_bgb_in_plain_sight::activation();
	self notify("show_owner");
	self setvisibletoall();
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
	self show();
	self thread delayed_deactivate_ips();
}

delayed_deactivate_ips()
{
	wait 2;
	self stoploopsound(1);
	self playsound("zmb_bgb_plainsight_end");
	visionset_mgr::deactivate("visionset", "zm_bgb_in_plain_sight", self);
	visionset_mgr::deactivate("overlay", "zm_bgb_in_plain_sight", self);
}

bgb_td_activate()
{
	if(!isdefined(level.bgb_td_pvp_prefix))
	{
		return;
	}
	self.__voiceprefix = self.voiceprefix;
	self.voiceprefix = level.bgb_td_pvp_prefix;
    level zm_audio::zmbaivox_playvox(self, "death_whimsy", 1, 10);
	self.voiceprefix = self.__voiceprefix;
}

bgb_btd_enable()
{
	zm_bgb_board_to_death::enable();
	self thread bgb_btd_enable_thread();
}

bgb_btd_enable_thread()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	while(true)
	{
		self waittill("boarding_window", s_window);
		self thread bgb_btd_explode(s_window);
	}
}

bgb_btd_explode(s_window)
{
	wait(0.3);
	a_ai = getplayers();
	a_closest = arraysortclosest(a_ai, s_window.origin, a_ai.size, 0, 180);
	for(i = 0; i < a_closest.size; i++)
	{
		if(a_closest[i] == self) continue;
		if(a_closest[i].sessionstate != "playing") continue;
		a_closest[i] dodamage(int(a_closest[i].health + 100), a_closest[i].origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		a_closest[i] playsound("zmb_bgb_boardtodeath_imp");
		wait(randomfloatrange(0.05, 0.2));
	}
}

bgb_umw_speedthread()
{
	self endon("bled_out");
	self endon("disconnect");
	self notify("bgb_umw_speedthread");
	self endon("bgb_umw_speedthread");
	if(!self bgb_opposing_umw())
	{
		return;
	}
	while(self bgb_opposing_umw())
	{
		self setMoveSpeedScale(0.5);
		wait 1;
	}
	self update_gm_speed_boost(self, 1, true);
}

bgb_umw_enable()
{
	self __bgb_umw_enable();
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		if(player == self) continue;
		if(player.team == self.team) continue;
		player thread bgb_umw_speedthread();
	}
}

__bgb_umw_enable()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self thread __function_40e95c74();
	if(bgb::function_f345a8ce("zm_bgb_undead_man_walking"))
	{
		return;
	}
	zm_bgb_undead_man_walking::function_b41dc007(1);
	spawner::add_global_spawn_function(level.zombie_team, zm_bgb_undead_man_walking::function_f3d5076d);
}

__function_40e95c74()
{
	self util::waittill_any("disconnect", "bled_out", "bgb_update");
	if(bgb::function_72936116("zm_bgb_undead_man_walking"))
	{
		return;
	}
	spawner::remove_global_spawn_function(level.zombie_team, zm_bgb_undead_man_walking::function_f3d5076d);
	zm_bgb_undead_man_walking::function_b41dc007(0);
}

bgb_opposing_umw()
{
	foreach(player in level.players)
	{
		if(player == self) continue;
		if(player.team == self.team) continue;
		if(player.sessionstate != "playing") continue;
		if(player bgb::is_enabled("zm_bgb_undead_man_walking"))
		{
			return true;
		}
	}
	return false;
}

alchemical_add_to_player_score_override(points = 0, str_awarded_by, var_1ed9bd9b)
{
	if(!(isdefined(self.var_3244073f) && self.var_3244073f))
	{
		return points;
	}

	var_4375ef8a = int(points / 10);
	current_weapon = self getcurrentweapon();
	if(!isdefined(current_weapon))
	{
		return points;
	}

	if(zm_utility::is_offhand_weapon(current_weapon))
	{
		return points;
	}

	if(isdefined(self.is_drinking) && self.is_drinking)
	{
		return points;
	}

	if(current_weapon == level.weaponrevivetool)
	{
		return points;
	}

	var_b8f62d73 = self getweaponammostock(current_weapon);
	var_b8f62d73 = var_b8f62d73 + var_4375ef8a;
	self setweaponammostock(current_weapon, var_b8f62d73);
	self thread alchemical_grant_ammo();
	return 0;
}

alchemical_grant_ammo()
{
	if(!isdefined(self.var_82764e33))
	{
		self.var_82764e33 = 0;
	}
	if(!self.var_82764e33)
	{
		self.var_82764e33 = 1;
		self playsoundtoplayer("zmb_bgb_alchemical_ammoget", self);
		wait(0.5);
		if(isdefined(self))
		{
			self.var_82764e33 = 0;
		}
	}
}
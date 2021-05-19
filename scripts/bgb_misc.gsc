blacklist_bgb(bgb)
{
    if(!isdefined(level.bgb_blacklist))
        level.bgb_blacklist = [];
    arrayremoveindex(level.bgb, bgb, true);
    level.bgb_blacklist[level.bgb_blacklist.size] = bgb;
}

remove_blacklisted_bgbs()
{
    if(!isdefined(level.bgb_blacklist))
        level.bgb_blacklist = [];
    foreach(bgb in level.bgb_blacklist)
    {
        arrayremoveindex(self.var_e610f362, bgb, true);
        arrayremovevalue(self.var_98ba48a2, bgb, true);
    }
}

free_perk_override(player)
{
	free_perk = player zm_perks::give_random_perk();
    if(isdefined(free_perk) && isdefined(level.perk_bought_func))
    {
        player [[level.perk_bought_func]](free_perk);
    }
}

bgb_fith_activate()
{
	self endon("disconnect");
	self thread bgb_watch_fith();
	self playsound("zmb_bgb_fearinheadlights_start");
	self playloopsound("zmb_bgb_fearinheadlights_loop");
	self thread zm_bgb_fear_in_headlights::kill_fear_in_headlights();
	self bgb::run_timer(120);
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
	if(zm_utility::is_player_valid(self))
    {
        multiplier = zm_score::get_points_multiplier(self);
        self zm_score::add_to_player_score(multiplier * 1600, 1, "gm_zbr_admin");
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
		player thread bgb_kt_freeze();
	}
	self zm_bgb_killing_time::activation();
	level notify("kt_end");
}

bgb_kt_freeze()
{
	self endon("disconnect");
	self.bgb_kt_frozen = true;
	self bgb_freeze_player(true);
	level waittill("kt_end");
	self.bgb_kt_frozen = false;
	self bgb_freeze_player(false);
}

bgb_freeze_player(result)
{
	if(result)
	{
		if(isdefined(self.freeze_obj))
		{
			self unlink();
			self.freeze_obj delete();
		}
		self.freeze_obj = spawn("script_origin", self.origin);
		self linkTo(self.freeze_obj);
	}
	else self unlink();
	self freezeControls(result);
	self setentitypaused(result);
	self.bgb_frozen = result;
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

bgb_profit_sharing_override(n_points, str_awarded_by, var_1ed9bd9b)
{
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
		foreach(e_player in level.players)
		{
			if(isdefined(e_player) && "zm_bgb_profit_sharing" == (e_player bgb::get_enabled()))
			{
				if(isdefined(e_player.var_6638f10b) && array::contains(e_player.var_6638f10b, self))
				{
					e_player thread zm_score::add_to_player_score(n_points, 1, "zm_bgb_profit_sharing");
				}
			}
		}
	}
	return n_points;
}

//self shellshock("flashbang", self.flashduration, 0);

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
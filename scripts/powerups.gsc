WatchMaxAmmo()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    while(true)
    {
        self waittill("zmb_max_ammo");
        foreach(weapon in self getweaponslist(1))
            if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
                self setWeaponAmmoClip(weapon, weapon.clipsize);
    }
}

carpenter_override(player)
{
	self thread zm_powerup_carpenter::grab_carpenter(player);
	foreach(_player in level.players)
	{
		if(_player.team != player.team)
		{
			continue;
		}
		if(_player.sessionstate != "playing")
		{
			continue;
		}
		if(!isdefined(_player.hasriotshield) || !_player.hasriotshield)
		{
			continue;
		}
		damagemax = level.weaponriotshield.weaponstarthitpoints;
		if(isdefined(_player.weaponriotshield))
		{
			damagemax = _player.weaponriotshield.weaponstarthitpoints;
		}
		current_health = _player damageriotshield(0);
		_player damageriotshield(-1 * (damagemax - current_health));
		_player updateriotshieldmodel();
		_player clientfield::set_player_uimodel("zmInventory.shield_health", 1.0f);
	}
}

updateriotshieldmodel()
{
	wait(0.05);
	self.hasriotshield = 0;
	self.weaponriotshield = level.weaponnone;
	foreach(weapon in self getweaponslist(1))
	{
		if(weapon.isriotshield)
		{
			self.hasriotshield = 1;
			self.weaponriotshield = weapon;
		}
	}
	current = self getcurrentweapon();
	self.hasriotshieldequipped = current.isriotshield;
	if(self.hasriotshield)
	{
		self clientfield::set_player_uimodel("hudItems.showDpadDown", 1);
		if(self.hasriotshieldequipped)
		{
			self zm_weapons::clear_stowed_weapon();
		}
		else
		{
			self zm_weapons::set_stowed_weapon(self.weaponriotshield);
		}
	}
	else
	{
		self clientfield::set_player_uimodel("hudItems.showDpadDown", 0);
		self setstowedweapon(level.weaponnone);
	}
	self refreshshieldattachment();
}

nuke_override(player)
{
    self thread zm_powerup_nuke::grab_nuke(player);
    foreach(person in level.players)
    {
        if(person.sessionstate != "playing") continue;
        if(person == player) continue;
		if(person.team == player.team) continue;
        person dodamage(int(person.maxhealth * 0.05), person.origin, player, player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
    }
}

player_can_drop_powerups(player, weapon)
{
	if(zm_utility::is_tactical_grenade(weapon) || !level flag::get("zombie_drop_powerups"))
	{
		return false;
	}
	if(isdefined(level.no_powerups) && level.no_powerups)
	{
		return false;
	}
	if(isdefined(level.use_powerup_volumes) && level.use_powerup_volumes)
	{
		volumes = getentarray("no_powerups", "targetname");
		foreach(volume in volumes)
		{
			if(player istouching(volume)) return false;
		}
	}
	return true;
}

powerup_grab_get_players_override()
{
    players = getplayers();
    final = [];
    foreach(player in players)
    {
        if(player.sessionstate != "playing") continue;
		if(isdefined(player.gm_forceprone) && player.gm_forceprone) continue;
        if(!isdefined(player.team) || player.team == level.zombie_team) continue;
        if(isdefined(player.no_grab_powerup) && player.no_grab_powerup) continue;
		if(isdefined(self.blood_hunter_points))
		{
			if(self.bh_owner.team == player.team)
			{
				continue;
			}
		}
		else
		{
			if(isdefined(player.wager_powerups) && player.wager_powerups)
			{
				continue;
			}
		}
		if(player is_in_altbody()) continue;
        final[final.size] = player;
        if(isalive(player.var_4bd1ce6b))
		{
			final[final.size] = player.var_4bd1ce6b;
		}
    }

    if(isdefined(level.ai_robot))
	{
		final[final.size] = level.ai_robot;
	}

    if(isdefined(level.ai_companion))
	{
		final[final.size] = level.ai_companion;
	}

    return final;
}

zombie_death_animscript_override()
{
	level.gm_last_killed_ent = self;
}

custom_zombie_powerup_drop(drop_point = (0,0,0))
{
	b_drop_nade = isdefined(level.gm_last_killed_ent) && !isplayer(level.gm_last_killed_ent) && isdefined(level.gm_last_killed_ent.wager_zomb_nades) && level.gm_last_killed_ent.wager_zomb_nades;
	b_drop_nade = b_drop_nade && isdefined(level.gm_last_killed_ent.attacker) && isplayer(level.gm_last_killed_ent.attacker);

	if(b_drop_nade && (randomIntRange(0, 100) <= WAGER_DROPNADE_CHANCE))
	{
		grenade = getweapon("frag_grenade");
		grenade = level.gm_last_killed_ent.attacker magicgrenadetype(grenade, drop_point, vectorscale((0, 0, 1), 300), 2);
		grenade.is_wager_grenade = true;
		grenade.wager_owner = level.gm_last_killed_ent.attacker;
	}

	if(isdefined(level._custom_zombie_powerup_drop))
	{
		b_result = [[level._custom_zombie_powerup_drop]](drop_point);
	}

	if(isdefined(b_result) && b_result) return true;
	if(level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"])
	{
		return true;
	}

	if(!isdefined(level.zombie_include_powerups) || level.zombie_include_powerups.size == 0)
	{
		return true;
	}

	use_pv = isdefined(level.gm_last_killed_ent) && isdefined(level.gm_last_killed_ent.power_vacuum) && level.gm_last_killed_ent.power_vacuum;
	rand_drop = randomint(100);
	if(use_pv && rand_drop < 20)
	{
		debug = "zm_bgb_power_vacuum";
	}
	else if(rand_drop > 2)
	{
		if(!level.zombie_vars["zombie_drop_item"])
		{
			return true;
		}
		debug = "score";
	}
	else
	{
		debug = "random";
	}
	playable_area = getentarray("player_volume", "script_noteworthy");
	level.powerup_drop_count++;
	powerup = zm_net::network_safe_spawn("powerup", 1, "script_model", drop_point + vectorscale((0, 0, 1), 40));
	valid_drop = 0;
	for(i = 0; i < playable_area.size; i++)
	{
		if(powerup istouching(playable_area[i]))
		{
			valid_drop = 1;
			break;
		}
	}
	if(valid_drop && level.rare_powerups_active)
	{
		pos = (drop_point[0], drop_point[1], drop_point[2] + 42);
		if(zm_powerups::check_for_rare_drop_override(pos))
		{
			level.zombie_vars["zombie_drop_item"] = 0;
			valid_drop = 0;
		}
	}
	if(!valid_drop)
	{
		level.powerup_drop_count--;
		powerup delete();
		return true;
	}

	powerup zm_powerups::powerup_setup();
	powerup thread zm_powerups::powerup_timeout();
	powerup thread zm_powerups::powerup_wobble();
	powerup thread zm_powerups::powerup_grab();
	powerup thread zm_powerups::powerup_move();
	powerup thread zm_powerups::powerup_emp();
	level.zombie_vars["zombie_drop_item"] = 0;
	level notify("powerup_dropped", powerup);
	return true;
}

watch_zombieblood()
{
	level endon("end_game");
	
	while(true)
	{
		level waittill("player_zombie_blood", player);
		player thread pvp_zombie_blood_invis();
	}
}

pvp_zombie_blood_invis()
{
	self endon("bled_out");
	self endon("disconnect");

	self SetInvisibleToAll();
    self SetInvisibleToPlayer(self, false);
	self thread show_owner_on_attack(self, true);
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
    self.invis_glow = spawn("script_model", self.origin);
    self.invis_glow linkto(self);
    self.invis_glow setmodel("tag_origin");
    self.invis_glow thread clone_fx_cleanup(self.invis_glow);
    playfxontag(level._effect["monkey_glow"], self.invis_glow, "tag_origin");
	self waittill("zombie_blood_over");
	self notify("show_owner");
	self setvisibletoall();
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
	self show();
	wait 2;
	self stoploopsound(1);
	visionset_mgr::deactivate("visionset", "zm_tomb_in_plain_sight", self);
	visionset_mgr::deactivate("overlay", "zm_tomb_in_plain_sight", self);
}
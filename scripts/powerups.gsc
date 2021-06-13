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
	if(!isdefined(player.hasriotshield) || !player.hasriotshield) return;
	damagemax = level.weaponriotshield.weaponstarthitpoints;
	if(isdefined(player.weaponriotshield))
	{
		damagemax = player.weaponriotshield.weaponstarthitpoints;
	}
	current_health = player damageriotshield(0);
	player damageriotshield(-1 * (damagemax - current_health));
    player updateriotshieldmodel();
	player clientfield::set_player_uimodel("zmInventory.shield_health", 1.0f);
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
		if(isdefined(player.wager_powerups) && player.wager_powerups) continue;
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
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
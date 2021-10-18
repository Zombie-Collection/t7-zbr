dragon_whelp_init()
{
    if(level.script != "zm_stalingrad")
    {
        return;
    }
    level.zbr_dragon_whelps = [];
    level.old_dragon_whelp_cb = level.vehicle_main_callback["dragon"];
    level.vehicle_main_callback["dragon"] = serious::dragon_whelp_main;
}

dragon_whelp_main()
{
    if(isdefined(level.old_dragon_whelp_cb))
    {
        self [[ level.old_dragon_whelp_cb ]]();
    }
    array::add(level.zbr_dragon_whelps, self, false);
    level thread cleanup_dead_whelp(self);
    self.targetname = "dragon_whelp";
    self.overridevehicledamage = serious::dragon_callback_damage;
    self.maxhealth = DRAGON_WHELP_HEALTH;
    self.health = DRAGON_WHELP_HEALTH;
    self setCanDamage(true);
    self notsolid();
    self.dmg_trigger = spawn("trigger_damage", self.origin, 0, 32, 32);
    self.dmg_trigger thread fakelinkto(self, (0,0,16));
    self.dmg_trigger thread kill_dragon_trig_on_death(self);
    self.dmg_trigger thread watch_dragon_damage(self);
    self thread dragon_target_selection();
    self thread dragon_prox_detonators();
}

cleanup_dead_whelp(dragon)
{
    level endon("end_game");
    dragon waittill("death");
    if(isdefined(dragon))
    {
        arrayremovevalue(level.zbr_dragon_whelps, dragon, 0);
    }
    else
    {
        level.zbr_dragon_whelps = array::remove_undefined(level.zbr_dragon_whelps, false);
    }
}

dragon_target_selection()
{
    self endon("death");
	while(true)
	{
		if(!isdefined(self.owner))
		{
			wait 0.25;
			continue;
		}
		if(isdefined(self.ignoreall) && self.ignoreall)
		{
			wait(0.25);
			continue;
		}
		target = get_dragon_enemy();
		if(!isdefined(target))
		{
			self.dragonenemy = undefined;
            wait 0.25;
            continue;
		}
		else
		{
            for(i = 0; i < 3; i++)
            {
                self.dragonenemy = target;
                wait 0.1;
            }
		}
	}
}

get_dragon_enemy()
{
	dragon_enemies = getaiteamarray(level.zombie_team); // treyarch why couldnt you use level.zombie_team :(
    player_enemies = getplayers();
    enemy_dragons = arraycopy(level.zbr_dragon_whelps);
    arrayremovevalue(enemy_dragons, self, false);
	distsqr = 10000 * 10000;
	best_enemy = undefined;

    foreach(enemy in enemy_dragons)
    {
        newdistsqr = distance2dsquared(enemy.origin, self.origin);
        if(is_dragon_enemy_valid(enemy) && newdistsqr < distsqr)
        {
            distsqr = newdistsqr;
			best_enemy = enemy;
        }
    }

    // dragons fight dragons first
    if(isdefined(best_enemy))
    {
        return best_enemy;
    }
    
    foreach(enemy in player_enemies)
    {
        newdistsqr = distance2dsquared(enemy.origin, self.origin);
        if(is_dragon_enemy_valid(enemy) && newdistsqr < distsqr)
        {
            distsqr = newdistsqr;
			best_enemy = enemy;
        }
    }

    // dragons fight players second
    if(isdefined(best_enemy))
    {
        return best_enemy;
    }

	foreach(enemy in dragon_enemies)
	{
		newdistsqr = distance2dsquared(enemy.origin, self.owner.origin);
		if(is_dragon_enemy_valid(enemy))
		{
            if(isdefined(enemy.archetype))
            {
                if(enemy.archetype == "raz")
                {
                    newdistsqr = max(distance2d(enemy.origin, self.owner.origin) - 700, 0);
                    newdistsqr = newdistsqr * newdistsqr;
                }
                else if(enemy.archetype == "sentinel_drone")
                {
                    newdistsqr = max(distance2d(enemy.origin, self.owner.origin) - 500, 0);
                    newdistsqr = newdistsqr * newdistsqr;
                }
                else if(enemy == self.dragonenemy)
                {
                    newdistsqr = max(distance2d(enemy.origin, self.owner.origin) - 300, 0);
                    newdistsqr = newdistsqr * newdistsqr;
                }
            }
			if(newdistsqr < distsqr)
			{
				distsqr = newdistsqr;
				best_enemy = enemy;
			}
		}
	}

    // dragons fight players third
	return best_enemy;
}

is_dragon_enemy_valid(target)
{
	if(!isdefined(target))
	{
		return false;
	}
	if(!isalive(target))
	{
		return false;
	}
	if(isdefined(self.intermission) && self.intermission)
	{
		return false;
	}
    if(isdefined(target.targetname) && target.targetname == "dragon_whelp" && target.owner.team != self.owner.team)
    {
        return true;
    }
	if(isdefined(target.ignoreme) && target.ignoreme)
	{
		return false;
	}
	if(target isnotarget())
	{
		return false;
	}
	if(isdefined(target._dragon_ignoreme) && target._dragon_ignoreme)
	{
		return false;
	}
    if(isplayer(target))
    {
        if(target.team == self.owner.team)
        {
            return false;
        }
        if(target.sessionstate != "playing")
        {
            return false;
        }
    }
	if(isplayer(target))
    {
        if((distancesquared(self.owner.origin, target.origin) > (self.settings.guardradius * self.settings.guardradius)) && distancesquared(self.origin, target.origin) > (self.settings.guardradius * self.settings.guardradius))
        {
            return false;
        }
    }
    else
    {
        if(distancesquared(self.owner.origin, target.origin) > (self.settings.guardradius * self.settings.guardradius))
        {
            return false;
        }
    }
	if(self vehcansee(target))
	{
		return true;
	}
	if(isactor(target) && target cansee(self.owner))
	{
		return true;
	}
	if(isvehicle(target) && target vehcansee(self.owner))
	{
		return true;
	}
    if(isplayer(target) && bullettracepassed(self.origin, target geteye(), 0, self))
    {
        return true;
    }
	return false;
}

dragon_callback_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
    if(isdefined(eattacker) && isdefined(eattacker.targetname) && eattacker.targetname == "dragon_whelp" && eattacker != self)
    {
        eattacker = eattacker.owner;
        idamage = 500;
    }
    if(isdefined(eattacker) && isplayer(eattacker) && eattacker.team != self.owner.team)
    {
        damageStage = dragon_damage_feedback_get_stage(self);
        eattacker.hud_damagefeedback.color = (1,1,1);
        eattacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansofdeath, weapon, damageStage));
        eattacker thread damagefeedback::damage_feedback_growth(self, smeansofdeath, weapon);
        // if((self.health - idamage) <= 0)
        // {
        //     self.owner.var_8afc8427 = 0;
        //     self.owner.hero_power = 0;
        //     self.owner.var_fd007e55 = 0;
        //     self.owner gadgetpowerset(0, 0);
        //     self.owner switchToWeapon(self.owner getWeaponsListPrimaries()[0]);
        // }
        return idamage;
    }
	if(!isdefined(self.dragon_recall_death) || self.dragon_recall_death != 1)
	{
		return 0;
	}
	return idamage;
}

dragon_damage_feedback_get_stage(victim, damage = 0)
{
    if(!isdefined(victim) || !isdefined(victim.health) || !isdefined(victim.maxhealth))
        return 1;
    
    result = float(victim.health - damage);
    rval = result / victim.maxhealth;
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

watch_dragon_damage(e_dragon)
{
    e_dragon endon("death");
    self endon("death");
    
    while(isdefined(self) && isdefined(e_dragon))
    {
        self waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
        if(e_dragon == attacker) continue;
        self.health += damagetaken;
        self.attacker = attacker;
        e_dragon dodamage(damagetaken, self.origin, attacker, attacker, "none", dmg_type, flags, weapon);
    }
}

kill_dragon_trig_on_death(e_dragon)
{
    self endon("death");
    e_dragon waittill("death");
    self delete();
}

dragon_prox_detonators()
{
    self endon("death");
    while(true)
    {
        self waittill("missile_fire", projectile, weapon);
        projectile.enemy = self.dragonenemy;
        if(!isdefined(projectile.enemy))
        {
            continue;
        }
        projectile thread dragon_detonate_near(projectile.enemy, self);
    }
}

dragon_detonate_near(enemy, dragon)
{
    if(!isdefined(enemy))
    {
        return;
    }
    self endon("death");
    enemy endon("disconnect");
    while(distanceSquared(self.origin, enemy.origin) > (25 * 25))
    {
        wait 0.05;
    }
    self detonate();
}
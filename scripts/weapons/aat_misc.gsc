aat_response(death, inflictor, attacker, damage, flags, mod, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
	if(!isplayer(attacker)) return false;
	if(mod != "MOD_PISTOL_BULLET" && mod != "MOD_RIFLE_BULLET" && mod != "MOD_GRENADE" && mod != "MOD_PROJECTILE" && mod != "MOD_EXPLOSIVE" && mod != "MOD_IMPACT")
	{
		return false;
	}
	weapon = aat::get_nonalternate_weapon(weapon);
    if(!isdefined(attacker.aat) || !isarray(attacker.aat)) return false;
	name = attacker.aat[weapon];
	if(!isdefined(name)) return false;
    if(!isdefined(level.aat[name])) return false;
	if(death && !level.aat[name].occurs_on_death) return false;
	if(!isdefined(self.archetype) && !isplayer(self)) return false;
	if(!isplayer(self) && isdefined(level.aat[name].immune_trigger[self.archetype]) && level.aat[name].immune_trigger[self.archetype]) return false;
	now = gettime() / 1000;
	if(isdefined(self.aat_cooldown_start) && isdefined(self.aat_cooldown_start[name]) && now <= (self.aat_cooldown_start[name] + level.aat[name].cooldown_time_entity))
	{
		return false;
	}
	if(isdefined(attacker.aat_cooldown_start) && isdefined(attacker.aat_cooldown_start[name]) && now <= (attacker.aat_cooldown_start[name] + level.aat[name].cooldown_time_attacker))
	{
		return false;
	}
	if(isdefined(level.aat[name].cooldown_time_global_start) && now <= level.aat[name].cooldown_time_global_start + level.aat[name].cooldown_time_global)
	{
		return false;
	}
	if(isdefined(level.aat[name].validation_func) && !(self [[level.aat[name].validation_func]]())) 
    {
        return false;
    }
	success = 0;
	reroll_icon = undefined;
	percentage = level.aat[name].percentage;
	if(percentage >= randomfloat(1)) success = 1;
	if(!success)
	{
		keys = getarraykeys(level.aat_reroll);
		keys = array::randomize(keys);
		foreach(key in keys)
		{
			if(attacker [[level.aat_reroll[key].active_func]]())
			{
				for(i = 0; i < level.aat_reroll[key].count; i++)
				{
					if(percentage >= randomfloat(1))
					{
						success = 1;
						reroll_icon = level.aat_reroll[key].damage_feedback_icon;
						break;
					}
				}
			}
			if(success) break;
		}
	}
	if(!success) return false;
	level.aat[name].cooldown_time_global_start = now;
	attacker.aat_cooldown_start[name] = now;
	self thread [[level.aat[name].result_func]](death, attacker, mod, weapon);
	attacker thread damagefeedback::update_override(level.aat[name].damage_feedback_icon, level.aat[name].damage_feedback_sound, reroll_icon);
    return true;
}

aat_deadwire(death, attacker, mod, weapon)
{
    attacker.tesla_enemies = undefined;
	attacker.tesla_enemies_hit = 1;
	attacker.tesla_powerup_dropped = 0;
	attacker.tesla_arc_count = 0;
    level.zm_aat_dead_wire_lightning_chain_params.weapon = weapon;
    if(!isplayer(self) && !isdefined(level.zombie_vars["tesla_head_gib_chance"]))
    {
        zombie_utility::set_zombie_var("tesla_head_gib_chance", 50);
    }
    if(!isplayer(self))
    {
        self lightning_chain::arc_damage(self, attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        foreach(player in level.players)
        {
            if(player.sessionstate != "playing") continue;
            if(player == attacker) continue;
            if(distance2d(player.origin, self.origin) < 300)
			{
				if(!BulletTracePassed(self geteye(), player geteye(), true, player))
				{
					continue;
				}
				player arc_damage_ent(attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
			} 
        }
    }
    else
    {
        self arc_damage_ent(attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        foreach(zombie in GetAISpeciesArray(level.zombie_team, "all"))
        {
            if(!isdefined(zombie) || !isalive(zombie)) continue;
            if(distance2d(zombie.origin, self.origin) >= 300) continue;
            zombie lightning_chain::arc_damage(zombie, attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        }
    }
}

aat_blast_furnace(death, e_attacker, mod, w_weapon)
{
    a_e_blasted_players = array::get_all_closest(self.origin, getplayers(), undefined, undefined, 120);
	playsoundatposition("wpn_aat_blastfurnace_explo", self.origin);
    foreach(player in a_e_blasted_players)
    {
        if(player == e_attacker) continue;
        if(player.sessionstate != "playing") continue;
		if(!BulletTracePassed(self geteye(), player geteye(), true, player)) continue;
        player thread blast_furnace_player_burn(e_attacker, w_weapon);
    }
    self zm_aat_blast_furnace::result(death, e_attacker, mod, w_weapon);
}

blast_furnace_player_burn(e_attacker, w_weapon, damage_base = AAT_BLASTFURNACE_PVP_DAMAGE)
{
	self endon("bled_out");
    self endon("disconnect");
    level endon("game_ended");
	self clientfield::increment_to_player("zm_bgb_burned_out" + "_1p" + "toplayer");
	self clientfield::increment("zm_bgb_burned_out" + "_3p" + "_allplayers");
	n_damage = damage_base * level.round_number / 6;
	i = 0;
	self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_SpineLower", 3);
	self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_Spine1", 3);
	while(i <= 6)
	{
		self dodamage(n_damage, self.origin, e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		self setburn(0.5);
		i++;
		wait(0.5);
	}
}

thunderwall_result(death, attacker, mod, weapon)
{
    v_thunder_wall_blast_pos = self.origin;
    v_attacker_facing_forward_dir = vectortoangles(v_thunder_wall_blast_pos - attacker.origin);
	v_attacker_facing = attacker getweaponforwarddir();
	v_attacker_orientation = attacker.angles;
    f_thunder_wall_range_sq = 32400;
	f_thunder_wall_effect_area_sq = 291600;
	end_pos = v_thunder_wall_blast_pos + vectorscale(v_attacker_facing, 180);
	a_e_players = array::get_all_closest(v_thunder_wall_blast_pos, getplayers(), undefined, undefined, 360);
    arrayremovevalue(a_e_players, attacker, false);
    foreach(player in a_e_players)
    {
        if(player.sessionstate != "playing") continue;
        player dodamage(AAT_THUNDERWALL_PVP_DAMAGE * level.round_number, player.origin, attacker, attacker, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        n_random_x = randomfloatrange(-3, 3);
        n_random_y = randomfloatrange(-3, 3);
		final_velocity = player getVelocity() + (650 * vectornormalize(player.origin - v_thunder_wall_blast_pos + (n_random_x, n_random_y, 15)));
		self.launch_magnitude_extra = 100;
    	self.v_launch_direction_extra = vectorNormalize(final_velocity);
        player setOrigin(player getOrigin() + (0,0,1));
        player setVelocity(final_velocity);
    }
    self zm_aat_thunder_wall::result(death, attacker, mod, weapon);
}

fw_validator()
{
    if(isplayer(self))
	{
		return true;
	}
	if(isdefined(self.barricade_enter) && self.barricade_enter)
	{
		return false;
	}
	if(isdefined(self.is_traversing) && self.is_traversing)
	{
		return false;
	}
	if(!(isdefined(self.completed_emerging_into_playable_area) && self.completed_emerging_into_playable_area) && !isdefined(self.first_node))
	{
		return false;
	}
	if(isdefined(self.is_leaping) && self.is_leaping)
	{
		return false;
	}
	return true;
}

fw_result(death, e_player, mod, w_weapon)
{
    w_summoned_weapon = e_player getcurrentweapon();
	v_target_zombie_origin = self.origin;
	if(!isplayer(self) && !(isdefined(level.aat["zm_aat_fire_works"].immune_result_direct[self.archetype]) && level.aat["zm_aat_fire_works"].immune_result_direct[self.archetype]))
	{
		self thread zm_aat_fire_works::zombie_death_gib(e_player, w_weapon, e_player);
	}
	v_firing_pos = v_target_zombie_origin + vectorscale((0, 0, 1), 56);
	v_start_yaw = vectortoangles(v_firing_pos - v_target_zombie_origin);
	v_start_yaw = (0, v_start_yaw[1], 0);
	mdl_weapon = zm_utility::spawn_weapon_model(w_summoned_weapon, undefined, v_target_zombie_origin, v_start_yaw);
	mdl_weapon.owner = e_player;
	mdl_weapon.b_aat_fire_works_weapon = 1;
	mdl_weapon.allow_zombie_to_target_ai = 1;
	mdl_weapon thread clientfield::set("zm_aat_fire_works", 1);
	mdl_weapon moveto(v_firing_pos, 0.5);
	mdl_weapon waittill("movedone");

    a_ai_zombies = getaiteamarray(level.zombie_team);
    a_players = getplayers();
    arrayremovevalue(a_players, e_player, false);
	foreach(player in level.players)
	{
		if(player.team == e_player.team)
		{
			arrayremovevalue(a_players, player, false);
			continue;
		}
		if(player.sessionstate != "playing")
		{
			arrayremovevalue(a_players, player, false);
			continue;
		}
	}
    a_ai_zombies = ArrayCombine(a_ai_zombies, a_players, 0, 0);
    a_ai_zombies = array::get_all_closest(v_target_zombie_origin, a_ai_zombies);
	n_shotatplayer = 0;
	for(i = 0; i < 20; i++)
	{
        los_checks = 0;
        for(j = 0; j < a_ai_zombies.size; j++)
        {
            zombie = a_ai_zombies[j];
            test_origin = isai(zombie) ? zombie getcentroid() : (zombie.origin + (0,0,50));
            if(distancesquared(mdl_weapon.origin, test_origin) > 360000) continue;
            if(los_checks < 3 && !zombie damageconetrace(mdl_weapon.origin))
            {
                los_checks++;
                continue;
            }
            break;
        }

        if(!isdefined(zombie) && a_ai_zombies.size) zombie = a_ai_zombies[0];
        if(isdefined(zombie))
		{
			if(isplayer(zombie))
			{
				if(zombie.sessionstate != "playing" || n_shotatplayer > 2)
				{
					n_shotatplayer = 0;
					arrayremovevalue(a_ai_zombies, zombie, false);
					i--;
					continue;
				}
				n_shotatplayer++;
			}
			else
			{
				arrayremovevalue(a_ai_zombies, zombie, false);
			}
		}
		if(!isdefined(zombie))
		{
			v_curr_yaw = (0, randomintrange(0, 360), 0);
			v_target_pos = mdl_weapon.origin + vectorscale(anglestoforward(v_curr_yaw), 40);
		}
		else
		{
			v_target_pos = isai(zombie) ? zombie getcentroid() : (zombie.origin + (0,0,50));
		}
		mdl_weapon.angles = vectortoangles(v_target_pos - mdl_weapon.origin);
		v_flash_pos = mdl_weapon gettagorigin("tag_flash");
		mdl_weapon dontinterpolate();
		magicbullet(w_summoned_weapon, v_flash_pos, v_target_pos, mdl_weapon);
		util::wait_network_frame();
	}
	mdl_weapon moveto(v_target_zombie_origin, 0.5);
	mdl_weapon waittill("movedone");
	mdl_weapon clientfield::set("zm_aat_fire_works", 0);
	util::wait_network_frame();
	util::wait_network_frame();
	util::wait_network_frame();
	mdl_weapon delete();
	wait(0.25);
}
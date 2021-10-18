AdjustPlayerSword(player, type, noprint=false)
{
    if(!isdefined(level.var_15954023.weapons)) level.var_15954023.weapons = [];
    if(!isDefined(level.var_15954023.weapons[player.originalindex])) return;
    
    weapon = level.var_15954023.weapons[player.originalindex][1];
    switch(type)
    {
        case "Normal":
             weapon = level.var_15954023.weapons[player.originalindex][1];
        break;

        case "Upgraded":
            weapon = level.var_15954023.weapons[player.originalindex][2];
        break;

        default:
            player takeWeapon(level.var_15954023.weapons[player.originalindex][1]);
            player takeWeapon(level.var_15954023.weapons[player.originalindex][2]);
            return;
    }

    player.sword_power = 1;
    player notify(#"hash_b29853d8");
    if(isdefined(player.var_c0d25105))
    {
        player.var_c0d25105 notify("returned_to_owner");
    }
    player.var_86a785ad = 1;
    player notify(#"hash_b29853d8");
    player zm_weapons::weapon_give(weapon, 0, 0, 1);
    player GadgetPowerSet(0, 100);
    player.current_sword = player.current_hero_weapon;
}

glaive_pvp_monitor()
{
	if(!isdefined(level.glaive_excalibur_aoe_range)) return;
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    self.wpn_excalibur = self get_correct_sword_for_player_character_at_level(1);
	self.wpn_autokill = self get_correct_sword_for_player_character_at_level(2);
    while(1)
	{
		self waittill("weapon_change", wpn_cur, wpn_prev);
        if(wpn_cur == self.wpn_excalibur || wpn_cur == self.wpn_autokill)
        {
            self thread watch_pvp_sword_swipe(wpn_cur, wpn_cur == self.wpn_autokill);
            if(wpn_cur != self.wpn_autokill)
                self thread watch_pvp_sword_slam(wpn_cur, wpn_cur == self.wpn_autokill);
        }
	}
}

get_correct_sword_for_player_character_at_level(n_upgrade_level)
{
	str_wpnname = undefined;
	if(n_upgrade_level == 1)
	{
		str_wpnname = "glaive_apothicon";
	}
	else
	{
		str_wpnname = "glaive_keeper";
	}
	str_wpnname = str_wpnname + "_" + self.characterindex;
	wpn = getweapon(str_wpnname);
	return wpn;
}

watch_pvp_sword_swipe(sword, upgraded = false)
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self endon("weapon_change");
    self notify("watch_pvp_sword_swipe");
    self endon("watch_pvp_sword_swipe");
	level endon("game_ended");
    while(1)
    {
        self util::waittill_any("weapon_melee_power", "weapon_melee");
		sword thread swordarc_swipe_pvp(self, upgraded);
    }
}

watch_pvp_sword_slam(sword, upgraded = false)
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self endon("weapon_change");
    self notify("watch_pvp_sword_slam");
    self endon("watch_pvp_sword_slam");
	level endon("game_ended");
    while(1)
    {
        self waittill("weapon_melee_power_left", weapon);
		if(!upgraded) self thread do_excalibur_pvp(weapon);
    }
}

swordarc_swipe_pvp(player, upgraded)
{
	player thread chop_players(1, upgraded, 1, self);
	wait(0.3);
	player thread chop_players(0, upgraded, 1, self);
	wait(0.5);
	player thread chop_players(0, upgraded, 0, self);
}

chop_players(first_time, upgraded, leftswing, weapon = level.weaponnone)
{
	view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		if(first_time) player.chopped = 0;
		else if(isdefined(player.chopped) && player.chopped) continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = level.glaive_chop_cone_range_sq;
		if(upgraded) dist_to_check = level.var_42894cb8;
		if(dist_sq > dist_to_check) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) continue;
		if(0 == player damageconetrace(view_pos, self)) continue;
		player.chopped = 1;
		self thread chop_player(player, upgraded, leftswing, weapon);
	}
}

chop_player(player, upgraded, leftswing, weapon = level.weaponnone)
{
	self endon("disconnect");
	if(player.sessionstate != "playing") return;
	if(isdefined(upgraded) && upgraded)
	{
		if(9317 >= player.health) player.ignoremelee = 1;
		player dodamage(9317, self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	}
	else if(3594 >= player.health)
	{
		player.ignoremelee = 1;
	}
	player dodamage(3594, self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	util::wait_network_frame();
}

do_excalibur_pvp(wpn_excalibur)
{
	view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
    foreach(player in level.players) lc_flag_hit(player, 0);
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		if(dist_sq < level.glaive_excalibur_aoe_range_sq)
		{
			self thread electrocute_player(player, wpn_excalibur);
			continue;
		}
		if(dist_sq > level.glaive_excalibur_cone_range_sq) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0.707 > dot) continue;
		if(!(player damageconetrace(view_pos, self))) continue;
		self thread electrocute_player(player, wpn_excalibur);
	}
}

electrocute_player(player, wpn_excalibur)
{
	self endon("disconnect");
    player endon("disconnect");
	if(player.sessionstate != "playing") return;
	if(!isdefined(self.tesla_enemies_hit)) self.tesla_enemies_hit = 1;
	player notify("bhtn_action_notify", "electrocute");
	player.tesla_death = 0;
    create_default_lp();
	player thread arc_lightning(player.origin, player.origin, self);
}

create_default_lp()
{
	if(isdefined(level.var_ba84a05b)) return;
    level.var_ba84a05b = create_lightning_chain_params(1);
	level.var_ba84a05b.head_gib_chance = 100;
	level.var_ba84a05b.network_death_choke = 4;
	level.var_ba84a05b.should_kill_enemies = 0;
}

arc_lightning(hit_location, hit_origin, player)
{
	player endon("disconnect");
	if(isdefined(self.zombie_tesla_hit) && self.zombie_tesla_hit) return;
	self arc_damage_ent(player, 1, level.var_ba84a05b);
}

create_lightning_chain_params(max_arcs = 5, max_enemies_killed = 10, radius_start = 300, radius_decay = 20, head_gib_chance = 75, arc_travel_time = 0.11, 
kills_for_powerup = 10, min_fx_distance = 128, network_death_choke = 4, should_kill_enemies = 1, clientside_fx = 1, arc_fx_sound = undefined, no_fx = 0, prevent_weapon_kill_credit = 0)
{
	lcp = spawnstruct();
	lcp.max_arcs = max_arcs;
	lcp.max_enemies_killed = max_enemies_killed;
	lcp.radius_start = radius_start;
	lcp.radius_decay = radius_decay;
	lcp.head_gib_chance = head_gib_chance;
	lcp.arc_travel_time = arc_travel_time;
	lcp.kills_for_powerup = kills_for_powerup;
	lcp.min_fx_distance = min_fx_distance;
	lcp.network_death_choke = network_death_choke;
	lcp.should_kill_enemies = should_kill_enemies;
	lcp.clientside_fx = clientside_fx;
	lcp.arc_fx_sound = arc_fx_sound;
	lcp.no_fx = no_fx;
	lcp.prevent_weapon_kill_credit = prevent_weapon_kill_credit;
	return lcp;
}

arc_damage_ent(player, arc_num, params = level.default_lightning_chain_params)
{
	lc_flag_hit(self, 1);
	self thread lc_do_damage(self, arc_num, player, params);
}

lc_flag_hit(enemy, hit)
{
	if(isdefined(enemy))
	{
		if(isarray(enemy))
		{
			for(i = 0; i < enemy.size; i++)
			{
				if(isdefined(enemy[i]))
				{
					enemy[i].zombie_tesla_hit = hit;
				}
			}
		}
		else if(isdefined(enemy))
		{
			enemy.zombie_tesla_hit = hit;
		}
	}
}

lc_do_damage(source_enemy, arc_num, player, params)
{
	player endon("disconnect");
	player endon("bled_out");
	self endon("bled_out");
    self endon("disconnect");
	if(arc_num > 1) wait(randomfloatrange(0.2, 0.6) * arc_num);
	if(self.sessionstate != "playing") return;
	if(params.clientside_fx)
	{
		if(arc_num > 1) clientfield::set("lc_fx", 2);
		else clientfield::set("lc_fx", 1);
	}
	if(isdefined(source_enemy) && source_enemy != self)
	{
		if(player.tesla_arc_count > 3)
		{
			util::wait_network_frame();
			player.tesla_arc_count = 0;
		}
		player.tesla_arc_count++;
		if(params != level.zm_aat_dead_wire_lightning_chain_params)
			source_enemy lc_play_arc_fx(self, params);
	}
	if(self.sessionstate != "playing") return;
	if(params != level.zm_aat_dead_wire_lightning_chain_params)
	{
		self lc_play_death_fx(arc_num, params);
	}
	else
	{
		self electric_cherry_shock_fx();
		self thread electric_cherry_stun();
	}
	//self.tesla_death = params.should_kill_enemies;
	origin = player.origin;
	if(isdefined(source_enemy) && source_enemy != self) origin = source_enemy.origin;
	if(self.sessionstate != "playing") return;
	weapon = level.weaponnone;
	if(params != level.zm_aat_dead_wire_lightning_chain_params)
    	self dodamage(ZM_ZOD_SWORD_SHOCK_DMG * level.round_number, origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
	else
		self dodamage(AAT_DEADWIRE_PVP_DAMAGE * level.round_number, origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
}

lc_play_arc_fx(target, params)
{
	if(!isdefined(self) || !isdefined(target))
	{
		wait(params.arc_travel_time);
		return;
	}
	tag = "tag_origin";
	target_tag = "J_SpineUpper";
	origin = self gettagorigin(tag);
	target_origin = target gettagorigin(target_tag);
	distance_squared = params.min_fx_distance * params.min_fx_distance;
	if(distancesquared(origin, target_origin) < distance_squared) return;
	fxorg = util::spawn_model("tag_origin", origin);
	fx = playfxontag(level._effect["tesla_bolt"], fxorg, "tag_origin");
	if(isdefined(params.arc_fx_sound)) playsoundatposition(params.arc_fx_sound, fxorg.origin);
	fxorg moveto(target_origin, params.arc_travel_time);
	fxorg waittill("movedone");
	fxorg delete();
}

lc_play_death_fx(arc_num, params)
{
	tag = "J_SpineUpper";
	fx = "tesla_shock";
	n_fx = 1;
	if(isdefined(self.teslafxtag))
	{
		tag = self.teslafxtag;
	}
	else tag = "tag_origin";
	if(arc_num > 1)
	{
		fx = "tesla_shock_secondary";
		n_fx = 2;
	}
	if(!params.should_kill_enemies)
	{
		fx = "tesla_shock_nonfatal";
		n_fx = 3;
	}
    self thread playFXTimedOnTag(level._effect[fx], tag, 3);
}
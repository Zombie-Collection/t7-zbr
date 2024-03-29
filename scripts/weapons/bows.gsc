register_bow_callbacks()
{
	if(!isdefined(level.var_e93874ed)) return;
    self.var_a320d911 = 0;
	self.var_98056717 = 0;
    self.var_ca25d40c = 0;
    self thread register_projectile_fired_callback("elemental_bow_wolf_howl", "elemental_bow_wolf_howl4", serious::missile_fire_bow_wolf);
    self thread register_proj_impact_callback("elemental_bow_rune_prison", "elemental_bow_rune_prison4", serious::missile_impact_bow_fire);
    self thread register_proj_impact_callback("elemental_bow_storm", "elemental_bow_storm4", serious::missile_impact_bow_storm);
    self thread register_proj_impact_callback("elemental_bow_demongate", "elemental_bow_demongate4", serious::missile_impact_bow_demongate);
}

register_projectile_fired_callback(weapon_prefix, weapon_name, callback)
{
	self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
	if(!isdefined(callback)) return;
	while(true)
	{
		self waittill("missile_fire", projectile, weapon);
		if(!issubstr(weapon.name, weapon_prefix)) continue;
		self thread [[callback]](projectile, weapon);
	}
}

register_proj_impact_callback(weapon_prefix, weapon_name, callback)
{
    if(!isdefined(callback)) return;
	self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
	while(true)
	{
		self waittill("projectile_impact", weapon, v_position, radius, e_projectile, normal);
		root_weapon = parse_bow_root(weapon.name);
		if(root_weapon != weapon_prefix && root_weapon != weapon_name) continue;
        self thread [[callback]](weapon, v_position, radius, e_projectile, normal);
	}
}

parse_bow_root(str_weapon_name)
{
	w_name = str_weapon_name;
	if(issubstr(w_name, "ricochet"))
	{
		tokens = strtok2(w_name, "_ricochet");
		w_name = tokens[0];
	}
	if(issubstr(w_name, "2"))
	{
		w_name = strtok(w_name, "2")[0];
	}
	if(issubstr(w_name, "3"))
	{
		w_name = strtok(w_name, "3")[0];
	}
	return w_name;
}

missile_fire_bow_wolf(projectile, weapon)
{
	self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
	if(weapon.name != "elemental_bow_wolf_howl4") return;
    end_vec = projectile.origin + (0, 0, 0) + anglestoforward(projectile.angles) * 64;
    forward = anglestoforward(self getplayerangles());
	v_up = anglestoup(self getplayerangles());
	a_trace = bullettrace(self geteye(), end_vec, 0, self);
	if(a_trace["fraction"] < 1) return;

    while(!isdefined(self.var_ce6323c7)) util::wait_network_frame();
    for(i = 0; i < 2; i++) util::wait_network_frame();

    target_index = 0;
    foreach(wolf_projectile in self.var_ce6323c7) // modified, n_index was not present in decompiled file.
    {
        if(!wolf_projectile.in_use) break;
        target_index++;
    }

    target_index--;

    if(target_index < 0 || target_index >= self.var_ce6323c7.size) return;
    target_array = array(self.var_ce6323c7[target_index], self.var_7222627b[target_index], self.var_1af340[target_index]);
    level thread do_wolfbow_knockback(self, target_array, forward);
}

do_wolfbow_knockback(e_player, projectile_array, v_forward)
{
    e_player endon("disconnect");
	e_player endon("bled_out");
    e_player endon("spawned_player");
    base_projectile = projectile_array[0];
	base_projectile endon("movedone");
	base_projectile endon("mechz_impact");
	v_forward_angles = vectortoangles(v_forward);
	max_range = 500;
	n_time = 0;
	while(n_time < 5)
	{
		players = getplayers();
        arrayremovevalue(players, e_player, false);
		enemy_targets = array::get_all_closest(base_projectile.origin, players, undefined, undefined, max_range);
		enemy_targets = array::filter(enemy_targets, 0, serious::is_valid_bow_enemy);
		if(enemy_targets.size)
		{
			root_origin = base_projectile.origin;
			seg_b = root_origin + v_forward * max_range;
			traveled_range = distance(base_projectile.origin, base_projectile.v_start_pos);
			if(traveled_range < 512)
			{
				effective_range = 64 - (32 * (traveled_range / 512));
			}
			else
			{
				effective_range = 32;
			}
			foreach(enemy_player in enemy_targets)
			{
				v_enemy_origin = enemy_player.origin + (0,0,50);
				seg_point = pointonsegmentnearesttopoint(root_origin, seg_b, v_enemy_origin);
				seg_inverse = seg_point - v_enemy_origin;
				if(abs(seg_inverse[2]) > 72) continue;
				seg_inverse = (seg_inverse[0], seg_inverse[1], 0);
				n_length = length(seg_inverse);
				if(n_length > effective_range) continue;
				launch_vector = 75 * n_length / effective_range;
                target_forward = vectortoangles(enemy_player.origin - base_projectile.origin);
                vector_direction = ((target_forward[1] - v_forward_angles[1] > 0) ? 1 : -1);
                launch_vector = launch_vector * vector_direction;
                v_launch = vectornormalize(anglestoforward((0, v_forward_angles[1] + launch_vector, 0)));
                enemy_player setOrigin(enemy_player.origin + (0,0,1));
                v_launch_base = v_launch + (0, 0, randomfloatrange(2, 4));
                v_launch_final = 150 * v_launch_base;
                enemy_player setvelocity(enemy_player getvelocity() + v_launch_final);
				enemy_player dodamage(BOW_WOLF_PUSH_DAMAGE * level.round_number, enemy_player.origin, e_player, e_player, undefined, "MOD_UNKNOWN", 0, level.var_30611368);
                enemy_player.launch_magnitude_extra = 150;
                enemy_player.v_launch_direction_extra = v_launch_base + (0,0,6);
			}
		}
		n_time += 0.1;
		wait(0.1);
	}
}

is_valid_bow_enemy(player)
{
	return isdefined(player) && player.sessionstate == "playing";
}

missile_impact_bow_fire(weapon, position, radius, attacker, normal)
{
    if(issubstr(weapon.name, "elemental_bow_rune_prison4"))
	{
		level thread bow_fire_trap_enemies(self, position, weapon.name, attacker, 1, 0);
	}
	else
	{
		level thread lava_geyser(self, position, weapon.name, attacker);
	}
}

bow_fire_filter_targets(player, spawn_origin)
{
	return !(isdefined(player.var_a320d911) && player.var_a320d911) && bullettracepassed(player.origin + (0,0,50), spawn_origin, 0, undefined) || bullettracepassed(player.origin + (0,0,50), spawn_origin + (0, 0, 50), 0, undefined);
}

bow_fire_trap_enemies(e_player, v_hit_origin, str_weapon_name, w_weapon, first_projectile, n_burn_duration)
{
    self endon("bled_out");
    self endon("disconnect");
    e_player endon("disconnect");
	if(first_projectile)
	{
		spawn_origin = (isdefined(v_spawn_pos) ? v_spawn_pos : v_hit_origin);
        e_players = getplayers();
        arrayremovevalue(e_players, e_player, false);
        e_players = array::get_all_closest(spawn_origin, e_players, undefined, undefined, 256);
        e_players = array::filter(e_players, 0, serious::is_valid_bow_enemy);
        e_players = array::filter(e_players, 0, serious::bow_fire_filter_targets, spawn_origin);
        n_index = 0;
        foreach(enemy in e_players)
        {
            enemy thread bow_fire_trap_enemies(e_player, v_hit_origin, str_weapon_name, w_weapon, 0, n_index);
            n_index++;
        }
        if(e_players.size) return;
	}
	else
	{
		v_spawn_pos = get_resting_position(self);
	}
	if(!isdefined(v_spawn_pos)) return;
	if(isdefined(v_spawn_pos))
	{
		model = util::spawn_model("tag_origin", v_spawn_pos, (0, randomintrange(0, 360), 0));
		if(isplayer(self) && isalive(self))
		{
			self.var_a320d911 = 1;
			self.var_98056717 = 1;
			self linkto(model);
			self thread player_struggle_and_burn(e_player, (1.8 + 0.07 * n_burn_duration + 2));
		}
	}
	model clientfield::set("runeprison_rock_fx", 1);
	wait(1.8 + 0.07 * n_burn_duration);
	model clientfield::set("runeprison_explode_fx", 1);
	wait(2);
	if(isdefined(self) && isplayer(self) && self.sessionstate == "playing")
	{
		self unlink();
	}
    e_players = getplayers();
    arrayremovevalue(e_players, e_player, false);
	e_players = array::get_all_closest(model.origin, e_players, undefined, undefined, 196);
	e_players = array::filter(e_players, 0, serious::is_valid_bow_enemy);
	e_players = array::filter(e_players, 0, serious::bow_fire_filter_targets, spawn_origin);
	foreach(enemy in e_players)
	{
		enemy dodamage(BOW_FIRE_ROCK_BREAK_DMG * level.round_number, model.origin, e_player, e_player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
	}
	model clientfield::set("runeprison_rock_fx", 0);
    self.var_a320d911 = 0;
	self.var_98056717 = 0;
	wait(6);
	model delete();
}

get_resting_position(player)
{
    player endon("disconnect");
	n_z_diff = 12 * 2;
	while(isdefined(player) && player.sessionstate == "playing" && (!(isdefined(player.var_98056717) && player.var_98056717)) && !(player isOnGround()))
    {
        wait 0.1;
    }
	if(isdefined(player) && player.sessionstate == "playing" && (!(isdefined(player.var_98056717) && player.var_98056717)))
	{
		return player.origin;
	}
	return undefined;
}

player_struggle_and_burn(e_attacker, n_duration = 0)
{
    self endon("disconnect");
    self endon("bled_out");
    e_attacker endon("disconnect");
    self setburn(n_duration);
    while(n_duration > 0)
    {
        n_duration -= 0.1;
        self dodamage(BOW_FIRE_DMG_PER_TICK * level.round_number, self.origin, e_attacker, e_attacker, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
        wait 0.1;
    }
    self.var_a320d911 = 0;
	self.var_98056717 = 0;
}

lava_geyser(e_player, v_hit_origin, str_weapon_name, var_3fee16b8)
{
    e_player endon("disconnect");
	v_spawn_pos = e_player get_nav_point_or_refire(v_hit_origin, str_weapon_name, var_3fee16b8, 32);
	if(!isdefined(v_spawn_pos)) return;
	n_timer = 0;
	while(n_timer < 3)
	{
        e_players = getplayers();
        arrayremovevalue(e_players, e_player, false);
		e_players = array::get_all_closest(v_hit_origin, e_players, undefined, undefined, 48);
		e_players = array::filter(e_players, 0, serious::is_valid_bow_enemy);
		e_players = array::filter(e_players, 0, serious::is_bow_pool_not_damaging);
		array::thread_all(e_players, serious::lava_geyser_burn, e_player);
		wait(0.05);
		n_timer = n_timer + 0.05;
	}
}

is_bow_pool_not_damaging(player)
{
	return !(isdefined(player.var_ca25d40c) && player.var_ca25d40c);
}

lava_geyser_burn(e_player)
{
	self endon("disconnect");
    self endon("bled_out");
    e_player endon("disconnect");
	self.var_ca25d40c = 1;
	n_timer = 0;
	n_max_damage = BOW_GEYSER_FIRE_TOTAL;
	str_mod = "MOD_BURNED";
	n_total_damage = n_max_damage * 0.3;
	self dodamage(n_total_damage, self.origin, e_player, e_player, undefined, str_mod, 0, level.weaponnone);
	n_fractional_damage = n_max_damage * 0.1;
	while(n_timer < 6 && n_total_damage < n_max_damage)
	{
		n_wait_time = randomfloatrange(0.4, 1);
        self setBurn(n_wait_time);
        self clientfield::increment("zm_bgb_burned_out" + "_3p" + "_allplayers");
		wait(n_wait_time);
		n_timer = n_timer + n_wait_time;
		self dodamage(n_fractional_damage, self.origin, e_player, e_player, undefined, str_mod, 0, level.weaponnone);
		n_total_damage = n_total_damage + n_fractional_damage;
	}
	self.var_ca25d40c = 0;
}

get_nav_point_or_refire(v_hit_origin, str_weapon_name, var_3fee16b8, var_a5018155, variable_not_used)
{
	var_980aeb4e = anglestoforward(var_3fee16b8.angles);
	if(var_980aeb4e[2] != -1)
	{
		var_3e878400 = vectornormalize(var_980aeb4e * -1);
		var_75181c09 = v_hit_origin + var_3e878400 * var_a5018155;
	}
	else
	{
		var_75181c09 = v_hit_origin + (0, 0, 1);
	}
	var_c6f6381a = bullettrace(var_75181c09, var_75181c09 - vectorscale((0, 0, 1), 1000), 0, undefined);
	var_58c16abb = var_75181c09[2] - var_c6f6381a["position"][2];
	var_2679aa6b = parse_bow_root(str_weapon_name);
	if(!ispointonnavmesh(var_c6f6381a["position"])) return undefined;
	if(var_58c16abb > 72) return undefined;
	return var_c6f6381a["position"];
}

missile_impact_bow_storm(weapon, v_position, radius, attacker, normal)
{
    v_position = self get_nav_point_or_refire(v_position, weapon.name, attacker, 64, self.var_a51c6ff2);
    if(!isdefined(v_position)) return;
	if(issubstr(weapon.name, "elemental_bow_storm4"))
	{
		self thread storm_impact_ug(v_position + vectorscale((0, 0, 1), 48));
	}
	else
	{
		self thread storm_impact_regular(v_position + vectorscale((0, 0, 1), 32), 3.6, attacker, 0);
	}
}

storm_impact_ug(v_hit_pos)
{
    self endon("disconnect");
    while(!isdefined(self.var_3b7b1ee) || !self.var_3b7b1ee.size) util::wait_network_frame();
    target_storm_projectile = self.var_3b7b1ee[0];
    if(!isdefined(target_storm_projectile)) return;
	while(!isdefined(target_storm_projectile.b_in_use) || !target_storm_projectile.b_in_use) 
	{
		util::wait_network_frame();
	}
	util::wait_network_frame();
    self thread storm_impact_regular((0, 0, 0), 7.8, target_storm_projectile, 1);
}

storm_impact_regular(v_hit_pos, n_lifetime, attacking_bolt, b_upgraded = false)
{
    self endon("disconnect");
	n_projectile_count = (b_upgraded ? 4 : 1);
	if(!(isdefined(b_upgraded) && b_upgraded))
	{
		attacking_bolt = util::spawn_model("tag_origin", v_hit_pos);
		attacking_bolt.b_in_use = 1;
		attacking_bolt.var_ff541a23 = 1;
	}
	if(!isdefined(attacking_bolt.seekers))
	{
		attacking_bolt.seekers = [];
		for(i = 0; i < n_projectile_count; i++)
		{
			attacking_bolt.seekers[i] = util::spawn_model("tag_origin", attacking_bolt.origin);
			util::wait_network_frame();
		}
	}
	foreach(bolt in attacking_bolt.seekers)
	{
		bolt.var_83cc6f07 = 0;

	}
	if(!b_upgraded) attacking_bolt.n_lifetime = n_lifetime;
	n_wtf = n_lifetime + 1;
	n_distance = 125;
	var_c48d320e = 0.6;
	if(b_upgraded)
	{
		n_distance = 200;
		var_c48d320e = 0.233;
	}
	while(attacking_bolt.n_lifetime > 0 && (isdefined(attacking_bolt.b_in_use) && attacking_bolt.b_in_use))
	{
		if(attacking_bolt.n_lifetime < n_wtf)
		{
			free_bolt = undefined;
			free_bolt = attacking_bolt locate_unused_seeker();
			if(isdefined(free_bolt))
			{
				free_bolt = attacking_bolt locate_storm_targets(n_distance, self);
				foreach(e_player in free_bolt)
				{
					if(bullettracepassed(e_player.origin + (0,0,50), attacking_bolt.origin, 0, attacking_bolt))
					{
						e_player thread storm_seeker_attack(self, attacking_bolt, free_bolt, b_upgraded);
						break;
					}
				}
			}
			if(!b_upgraded)
			{
				n_wtf = attacking_bolt.n_lifetime - var_c48d320e;
			}
		}
		wait(0.05);
		if(!b_upgraded)
		{
			attacking_bolt.n_lifetime = attacking_bolt.n_lifetime - 0.05;
		}
	}
	if(isdefined(attacking_bolt.var_ff541a23) && attacking_bolt.var_ff541a23)
	{
		util::wait_network_frame();
		attacking_bolt delete();
		array::run_all(attacking_bolt.seekers, sys::delete);
		if(isdefined(attacking_bolt.var_627f5ce9))
		{
			attacking_bolt.var_627f5ce9 delete();
		}
	}
	else
	{
		foreach(bolt in attacking_bolt.seekers)
		{
			bolt clientfield::set("elem_storm_bolt_fx", 0);
		}
	}
}

storm_seeker_attack(e_player, attacking_bolt, e_bolt, b_upgraded)
{
    self endon("disconnect");
    self endon("bled_out");
    e_player endon("disconnect");
	if(b_upgraded)
	{
		bolt_origin = attacking_bolt.origin + (0, 0, randomintrange(0, 96));
	}
	else
	{
		bolt_origin = attacking_bolt.origin;
	}
	self.var_789ebfb2 = 1;
	e_bolt.var_83cc6f07 = 1;
	b_upgraded_2 = 0;
	e_bolt.origin = bolt_origin;
	v_bolt_origin = bolt_origin;
	v_start = self.origin + (0,0,50);
	normalized_direction = vectornormalize(v_start - v_bolt_origin);
	direction_angles = vectortoangles(normalized_direction);
	direction_angles = (direction_angles[0], direction_angles[1], randomint(360));
	e_bolt.angles = direction_angles;
	e_bolt linkto(attacking_bolt);
	wait(0.05);
	e_bolt clientfield::set("elem_storm_bolt_fx", 1);
	wait(0.2);
	if(!isdefined(self) || self.sessionstate != "playing") return;
	n_damage = BOW_STORM_SHOCK_DAMAGE * level.round_number;
    str_damage_mod = "MOD_UNKNOWN";
    self dodamage(n_damage * (1 + b_upgraded), self.origin, e_player, e_player, undefined, str_damage_mod, 0, level.weaponnone);
    self thread storm_bolt_do_shock(e_player, bolt_origin, attacking_bolt);
	wait(0.5);
    self.var_789ebfb2 = 0;
	e_bolt clientfield::set("elem_storm_bolt_fx", 0);
	e_bolt.var_83cc6f07 = 0;
	e_bolt unlink();
}


locate_unused_seeker()
{
	foreach(seeker in self.seekers)
	{
		if(isdefined(seeker) && isdefined(seeker.var_83cc6f07) && !seeker.var_83cc6f07)
		{
			return seeker;
		}
	}
	return undefined;
}

locate_storm_targets(n_distance, e_player)
{
	a_players = getplayers();
    arrayremovevalue(a_players, e_player, false);
	a_players = array::get_all_closest(self.origin, a_players, undefined, undefined, n_distance);
	a_players = array::filter(a_players, 0, serious::is_valid_bow_enemy);
	a_players = array::filter(a_players, 0, serious::is_valid_storm_enemy);
	return a_players;
}

is_valid_storm_enemy(player)
{
	return !(isdefined(player.var_789ebfb2) && player.var_789ebfb2);
}

storm_bolt_do_shock(e_player, bolt_origin, attacking_bolt)
{
	self endon("disconnect");
    self endon("bled_out");
	n_lifetime = 2.166;
    if(!isdefined(attacking_bolt.n_lifetime))
    {
        attacking_bolt.n_lifetime = n_lifetime;
    } 
	n_lifetime = min(n_lifetime, attacking_bolt.n_lifetime);
    self thread playFXTimedOnTag(level._effect["tesla_shock"], "j_head", n_lifetime);
    self playsound("zmb_elec_jib_zombie");
    self set_move_speed_scale(.5);
    self.zombie_tesla_hit = 1;
    if(!self util::is_bot()) self SetElectrified(n_lifetime);
	wait n_lifetime;
    self.zombie_tesla_hit = 0;
    self set_move_speed_scale(1);
}

missile_impact_bow_demongate(weapon, position, radius, attacker, normal)
{
	if(weapon.name == "elemental_bow_demongate4")
	{
		self thread spawn_demon_gate(weapon, position, attacker, normal);
	}
	else
	{
		self thread spawn_demon_skull_wrap(position, attacker);
	}
}


spawn_demon_gate(weapon, position, attacker, normal)
{
	position = acquire_demon_position(position, normal);
	demon_portal_pos = vectortoangles(normal);
	demon_portal_pos = demon_portal_pos + vectorscale((0, 1, 0), 90);
	demon_portal_pos = demon_portal_pos * (0, 1, 0);
	wait(0.25);
	num_chompers = BOW_DEMONGATE_SKULL_COUNT;
	n_total_waited = 0;
    demon_skulls = [];
	for(i = 0; i < num_chompers; i++)
	{
		demon_skulls[i] = create_demon_chomper(position, demon_portal_pos - vectorscale((0, 1, 0), 90), i);
		demon_skulls[i] thread chomper_think(self, position);
		n_wait_time = 0.1;
		n_total_waited = n_total_waited + n_wait_time;
		wait(n_wait_time);
	}
}

acquire_demon_position(v_position, v_normal)
{
	if(abs(v_normal[2]) < 0.2)
	{
		v_position = v_position + v_normal * 16;
		a_trace = bullettrace(v_position, v_position + vectorscale((0, 0, 1), 64), 0, undefined);
		if(a_trace["fraction"] < 1)
		{
			v_position = a_trace["position"] - vectorscale((0, 0, 1), 64);
		}
		a_trace = bullettrace(v_position, v_position - vectorscale((0, 0, 1), 64), 0, undefined);
		if(a_trace["fraction"] < 1)
		{
			v_position = a_trace["position"] + vectorscale((0, 0, 1), 64);
		}
	}
	else
	{
		v_normal_scaled = v_normal[2] * 64;
		v_position = v_position + (0, 0, v_normal_scaled);
	}
	return v_position;
}

create_demon_chomper(position, v_angles, n_count = 1)
{
	if(!isdefined(level.demon_chopper_id))
	{
		level.demon_chopper_id = -1;
	}

	level.demon_chopper_id++;

	chomper = util::spawn_model("c_zom_chomper", position, v_angles);
	chomper clientfield::set("demongate_chomper_fx", 1);
	chomper flag::init("chomper_attacking");
	chomper flag::init("demongate_chomper_despawning");
	chomper.var_fcd07456 = level.round_number * BOW_DEMONGATE_SKULL_TOTALDAMAGE;
	chomper.var_603f1f19 = 1;
	chomper.demon_chopper_id = level.demon_chopper_id;
	chomper thread chomper_lifetime();
	level notify("new_chomper", chomper);
	return chomper;
}


chomper_think(e_player, position)
{
	self.var_e3146903 = 1;
	self.origin = self.origin + (0, 0, randomintrange(int(-51.2), int(51.2)));
	self.angles = (self.angles[0] + randomintrange(-30, 30), self.angles[1] + randomintrange(-45, 45), self.angles[2]);
	v_target_location = self.origin + anglestoforward(self.angles) * 96;
	self.angles = (0, self.angles[1], 0);
	self moveto(v_target_location, 0.4);
	wait(0.4);
	self.var_e3146903 = 0;
	self chomper_begin_attack(e_player);
}

chomper_begin_attack(e_player)
{
	self chomper_acquire_target(e_player);
	if(isdefined(self.target_enemy))
	{
		self chomper_attack(e_player);
	}
	else
	{
		self thread chomper_wander(e_player);
	}
}

chomper_acquire_target(e_player)
{
	if(self flag::get("demongate_chomper_despawning")) return;
	self.target_enemy = undefined;
	v_target_pos = self.origin;
	n_max_distance = 1024;
	if(isdefined(self.var_603f1f19) && self.var_603f1f19)
	{
		if(zm_utility::is_player_valid(e_player))
		{
			v_target_pos = e_player.origin;
		}
		n_max_distance = 1024;
	}
	a_players = getplayers();
    arrayremovevalue(a_players, e_player, false);
	a_players = arraysortclosest(a_players, v_target_pos, a_players.size, 0, n_max_distance);
	a_players = array::filter(a_players, 0, serious::is_valid_bow_enemy);
    a_players = array::randomize(a_players);
	if(a_players.size)
	{
		e_enemy = a_players[0];
		self.target_enemy = e_enemy;
		self notify("demongate_chomper_found_target");
	}
}

chomper_lifetime()
{
    level endon("game_ended");
	self endon("demongate_chomper_despawning");
	self.n_timer = 0;
	while((self.n_timer < 3) && ((level.demon_chopper_id - self.demon_chopper_id) < MAX_DEMON_CHOMPERS))
	{
		if(!self flag::get("chomper_attacking") && (!(isdefined(self.var_e3146903) && self.var_e3146903)))
		{
			self.n_timer = self.n_timer + 0.05;
		}
		wait(0.05);
	}
	while(self flag::get("chomper_attacking") && ((level.demon_chopper_id - self.demon_chopper_id) < MAX_DEMON_CHOMPERS))
	{
		wait(0.1);
	}

	// quick kill cause of resources
	if(!((level.demon_chopper_id - self.demon_chopper_id) < MAX_DEMON_CHOMPERS))
	{
		self flag::set("demongate_chomper_despawning");
		self clientfield::set("demongate_chomper_fx", 0);
		self notify("hash_16664ab4");
		self delete();
		return;
	}

	self thread chomper_death();
}

chomper_death()
{
	self flag::set("demongate_chomper_despawning");
	if(!(isdefined(self.var_dd49270d) && self.var_dd49270d))
	{
		self.var_dd49270d = 1;
		if(!isdefined(level.var_a9ac7b97))
		{
			level.var_a9ac7b97 = gettime();
		}
		else if(level.var_a9ac7b97 == gettime())
		{
			wait(randomfloatrange(0.1, 0.2));
		}
		level.var_a9ac7b97 = gettime();
		self moveto(self.origin + vectorscale((0, 0, 1), 96), 1.4);
		self rotatepitch(-90, 0.4);
		wait(1.4);
		self moveto(self.origin, 0.1);
		self clientfield::set("demongate_chomper_fx", 0);
		wait(3);
		self notify("hash_16664ab4");
		self delete();
	}
}

chomper_attack(e_player)
{
    if(isdefined(self.target_enemy))
        self.target_enemy endon("disconnect");
	n_enemy_health = self.target_enemy.health;
	self chomper_seek_target();
	if(serious::is_valid_bow_enemy(self.target_enemy))
	{
		self.var_603f1f19 = 0;
        n_damage = self.var_fcd07456;
		self.var_fcd07456 = self.var_fcd07456 - n_enemy_health;
		self clientfield::increment("demongate_chomper_bite_fx", 1);
		self thread chomper_do_damage(e_player, n_damage);
		n_wait_time = randomfloatrange(2, 3);
        self.target_enemy thread chomper_slow_player(n_wait_time + 1);
		self.target_enemy util::waittill_notify_or_timeout("bled_out", n_wait_time);
		self notify(#"hash_368634cd");
		if(self.var_fcd07456 < 1)
		{
			self thread chomper_death();
			return;
		}
	}
	else if(isdefined(self.target_enemy))
	{
		self.target_enemy.var_bc9b5fbd = 0;
	}
	self flag::clear("chomper_attacking");
    util::wait_network_frame();
	self thread chomper_begin_attack(e_player);
}

chomper_seek_target()
{
    self.target_enemy endon("disconnect");
	self flag::set("chomper_attacking");
	target_eye = self.target_enemy geteye();
	n_dist = distance(self.origin, target_eye);
	n_loop_count = 1;
	n_head_side = (math::cointoss() ? 1 : -1);
	self clientfield::set("demongate_attack_locomotion_anim", 1);
	while(n_dist > 32 && isdefined(self.target_enemy) && self.target_enemy.sessionstate == "playing")
	{
		target_eye = self.target_enemy geteye();
		n_time = n_dist / 640;
		n_pull_intensity = 1 / n_loop_count;
		v_down_influence = vectorscale((0, 0, 1), 160) * n_pull_intensity;
		v_float_offset = anglestoright(vectortoangles(target_eye - self.origin)) * 256;
		v_float_offset = v_float_offset * n_pull_intensity;
		v_float_offset = v_float_offset * n_head_side;
		v_float_position = target_eye + v_float_offset + v_down_influence;
		v_lookat = v_float_position - self.origin;
		v_lookat = (0, v_lookat[1], 0);
		if(!isdefined(level.var_a9ac7b97))
		{
			level.var_a9ac7b97 = gettime();
		}
		else if(level.var_a9ac7b97 == gettime())
		{
			wait(randomfloatrange(0.1, 0.2));
		}
		level.var_a9ac7b97 = gettime();
		self moveto(v_float_position, n_time);
		self rotateto(vectortoangles(v_lookat), n_time * 0.5);
		n_time = n_time * 0.3;
		n_time = (n_time < 0.1 ? 0.1 : n_time);
		wait(n_time);
		n_loop_count++;
		n_dist = distance(self.origin, target_eye);
	}
	self clientfield::set("demongate_attack_locomotion_anim", 0);
	if(isdefined(self.target_enemy) && self.target_enemy.sessionstate == "playing")
	{
		self.origin = target_eye;
	}
}

chomper_slow_player(n_wait_time = 2)
{
    self notify("chomper_slow_player");
    self endon("chomper_slow_player");
    self endon("disconnect");
    self endon("bled_out");
	self set_move_speed_scale(0.1);
    if(!self util::is_bot()) self shellshock("pain_zm", n_wait_time * 0.75);
    wait n_wait_time;
	self set_move_speed_scale(1);
}

chomper_do_damage(e_player, n_damage)
{
    e_player endon("disconnect");
	e_target = self.target_enemy;
	e_target endon("disconnect");
    e_target endon("bled_out");
    level endon("game_ended");
	n_damage = int(max(1, min(e_target.health, n_damage)));
	self waittill(#"hash_368634cd");
	e_target.var_bc9b5fbd = 0;
	e_target.var_98056717 = 0;
	e_target dodamage(n_damage, e_target.origin, e_player, e_player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
}

chomper_wander(e_player)
{
	self endon("demongate_chomper_despawning");
	self endon("death");
    e_player endon("disconnect");
	if(!isdefined(self)) return;
	if(self flag::get("demongate_chomper_despawning")) return;
	self flag::clear("chomper_attacking");
	self clientfield::set("demongate_wander_locomotion_anim", 1);
	n_random_x = randomfloatrange(5, 15);
	n_random_y = randomfloatrange(15, 45);
	n_random_z = randomfloatrange(15, 45);
	n_random_x = (randomint(100) < 50 ? n_random_x : n_random_x * -1);
	n_random_y = (randomint(100) < 50 ? n_random_y : n_random_y * -1);
	n_random_z = (randomint(100) < 50 ? n_random_z : n_random_z * -1);
	if(zm_utility::is_player_valid(e_player))
	{
		v_root_angles = e_player.angles;
		v_root_position = e_player geteye();
	}
	else
	{
		v_root_angles = self.angles;
		v_root_position = self.origin;
	}
	v_delta = (v_root_angles[0] + n_random_x, v_root_angles[1] + n_random_y, v_root_angles[2] + n_random_z);
	v_delta_normalized = vectornormalize(anglestoforward(v_delta));
	a_trace = physicstraceex(v_root_position, v_root_position + v_delta_normalized * 512, vectorscale((-1, -1, -1), 16), vectorscale((1, 1, 1), 16));
	v_target_location = a_trace["position"] + v_delta_normalized * -32;
	n_dist = distance(self.origin, v_target_location);
	n_time = n_dist / 48;
	v_forward_pitch_delta = v_target_location - self.origin;
	v_forward_pitch_delta = (0, v_forward_pitch_delta[1], 0);
	if(!isdefined(level.var_a9ac7b97))
	{
		level.var_a9ac7b97 = gettime();
	}
	else if(level.var_a9ac7b97 == gettime())
	{
		wait(randomfloatrange(0.1, 0.2));
	}
	level.var_a9ac7b97 = gettime();
	self moveto(v_target_location, n_time);
	self rotateto(vectortoangles(v_forward_pitch_delta), n_time * 0.5);
	self thread chomper_search_player(e_player);
	self util::waittill_any_timeout(n_time * 2, "movedone", "demongate_chomper_found_target", "demongate_chomper_despawning", "death");
	if(isdefined(self.target_enemy))
	{
		self clientfield::set("demongate_wander_locomotion_anim", 0);
		self chomper_attack(e_player);
	}
	else
	{
        util::wait_network_frame();
		self thread chomper_wander(e_player);
	}
}

chomper_search_player(e_player)
{
	self endon("demongate_chomper_despawning");
	self endon("demongate_chomper_found_target");
	self endon("movedone");
	self endon("death");
    e_player endon("disconnect");
	while(!isdefined(self.target_enemy))
	{
		wait(0.2);
		self chomper_acquire_target(e_player);
	}
}

spawn_demon_skull_wrap(position, attacker)
{
	v_angles = anglestoforward(attacker.angles) * -1;
	chomper = create_demon_chomper(position, v_angles);
	wait(0.1);
	chomper thread chomper_begin_attack(self);
}

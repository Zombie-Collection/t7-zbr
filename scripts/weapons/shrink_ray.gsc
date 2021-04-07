monitor_shrink_ray()
{
    if(!isdefined(level.var_f812085)) return;
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

    while(true)
	{
		self waittill("weapon_fired", w_weapon);
        if(!isdefined(w_weapon)) continue;
		if(w_weapon == level.var_f812085 || w_weapon == level.var_953f69a0)
		{
			self thread fired_shrink_ray(w_weapon == level.var_953f69a0);
		}
	}
}

fired_shrink_ray(upgraded)
{
	a_e_players = self collect_shrinkable_players(upgraded);
	foreach(player in a_e_players)
    {
        player thread shrink_me(upgraded, self);
    }
}

collect_shrinkable_players(upgraded)
{
	range = 480;
	radius = 60;
	if(upgraded)
	{
		range = 1200;
		radius = 84;
	}
	shrinks = [];
	view_pos = self getweaponmuzzlepoint();
	test_list = getplayers();
    final_list = [];
    foreach(player in test_list)
    {
        if(player.sessionstate != "playing") continue;
        if(player == self) continue;
        final_list[final_list.size] = player;
    }
	players = util::get_array_of_closest(view_pos, test_list, undefined, undefined, range * 1.1);
	if(!isdefined(players)) return;
	range_squared = range * range;
	radius_squared = radius * radius;
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, range);
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i]) || players[i] == self) continue;
		if(isdefined(players[i].shrinked) && players[i].shrinked) continue;
		test_origin = players[i].origin + (0,0,50);
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > range_squared) break;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0 > dot) continue;
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > radius_squared)
		{
			continue;
		}
		if(!(players[i] damageconetrace(view_pos, self)))
		{
			continue;
		}
		shrinks[shrinks.size] = players[i];
	}
	return shrinks;
}

shrink_me(b_upgraded, e_attacker)
{
    self endon("disconnect");
    self endon("bled_out");
    self notify("shrink_me");
    self endon("shrink_me");

    self.shrink_kicked = false;
    if(!isdefined(self.shrinked) || !self.shrinked)
    {
        self.shrinked = true;
        self.ignoreme++;
        playfx(level._effect["teleport_splash"], self.origin);
	    playfx(level._effect["teleport_aoe"], self.origin);
        self ghost();
        self.shrink_model = spawn("script_model", self.origin);
        self.shrink_model setmodel(level.cymbal_monkey_model);
        self.shrink_model thread kill_shrink_on_death(self);
        self.shrink_model.angles = self.angles;
        self.shrink_model setscale(1.5);
        self.shrink_model thread fakelinkto(self);
        self.shrink_trigger = spawn("trigger_damage", self.origin, 0, 32, 32);
	    self.shrink_trigger thread fakelinkto(self, (0,0,16));
        self.shrink_trigger thread kill_shrink_on_death(self);
        self.shrink_trigger thread watch_shrink_damage(self);
        self disableWeapons();
        self thread watch_when_kicked();
        self setMoveSpeedScale(2.5);
        playfxontag(level._effect["monkey_glow"], self.shrink_model, "tag_origin_animate");
    }
    
    self util::waittill_any_timeout(SHRINK_RAY_SHRINK_TIME, "kicked");
    if(self.shrink_kicked)
    {
        self dodamage(int(self.health * 0.5), self.origin, self.shrink_killer, undefined, "none", "MOD_IMPACT", 0, level.weaponnone);
        wait 1;
        self.shrink_kicked = false;
    }
    if(self.ignoreme > 0)
    {
        self.ignoreme--;
    }
    self.shrinked = false;
    if(!self laststand::player_is_in_laststand())
    {
        self show();
        playfx(level._effect["teleport_splash"], self.origin);
	    playfx(level._effect["teleport_aoe"], self.origin);
    }
    self setMoveSpeedScale(1);
    self enableWeapons();
    self notify("unshrink");
}

kill_shrink_on_death(player)
{
    self endon("death");
    player util::waittill_any_timeout(SHRINK_RAY_SHRINK_TIME, "disconnect", "bled_out", "shrink_me", "unshrink");
    self delete();
}

fakelinkto(linkee, v_offset_origin = (0,0,0))
{
	self notify("fakelinkto");
	self endon("fakelinkto");
    self endon("death");
	self.backlinked = 1;
	while(isdefined(self) && isdefined(linkee))
	{
		self.origin = linkee.origin + v_offset_origin;
		self.angles = linkee.angles;
		wait(0.05);
	}
}

watch_shrink_damage(e_player)
{
    e_player endon("bled_out");
    e_player endon("disconnect");
    self endon("death");

    self.owning_player = e_player;
    self.shrink_damage_refract = true;
    while(isdefined(self))
    {
        self waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
        self.health += damagetaken;
        self.attacker = attacker;
        self.owning_player dodamage(damagetaken, self.origin, self, self, "none", dmg_type, flags, weapon);
    }
}

watch_when_kicked()
{
	self endon("death");
    self endon("disconnect");
    self endon("bled_out");
	self endon("unshrink");
    self endon("shrink_me");
	self.shrink_bump = spawn("trigger_radius", self.origin, 0, 30, 24);
	self.shrink_bump sethintstring("");
	self.shrink_bump setcursorhint("HINT_NOICON");
	self.shrink_bump enablelinkto();
	self.shrink_bump linkto(self);
	self.shrink_bump thread kill_shrink_on_death(self);
	self.shrink_bump endon("death");
	while(1)
	{
		self.shrink_bump waittill("trigger", who);
		if(!isplayer(who)) continue;
        if(who == self) continue;
		movement = who getnormalizedmovement();
		if(length(movement) < 0.1) continue;
		toenemy = self.origin - who.origin;
		toenemy = (toenemy[0], toenemy[1], 0);
		toenemy = vectornormalize(toenemy);
		forward_view_angles = anglestoforward(who.angles);
		dot_result = vectordot(forward_view_angles, toenemy);
		if(dot_result > 0.5 && movement[0] > 0)
		{
            self.shrink_kicked = true;
            self.shrink_killer = who;
			self notify("kicked");
			self thread player_kicked_shrinked(who);
		}
	}
}

player_kicked_shrinked(killer)
{
    killer endon("disconnect");
    self endon("disconnect");
    playsoundatposition("zmb_mini_kicked", self.origin);
    kickangles = killer.angles;
	kickangles = kickangles + (randomfloatrange(-30, -20), randomfloatrange(-5, 5), 0);
	launchdir = anglestoforward(kickangles);
	if(killer issprinting())
	{
		launchforce = randomfloatrange(350, 400);
	}
	else
	{
		vel = killer getvelocity();
		speed = length(vel);
		scale = math::clamp(speed / 190, 0.1, 1);
		launchforce = randomfloatrange(1250 * scale, 1500 * scale);
	}
    self setOrigin(self getOrigin() + (0,0,5));
	self setVelocity(self getvelocity() + (launchdir * launchforce));
    if(isdefined(self.shrink_bump))
    {
        self.shrink_bump delete();
    }
}
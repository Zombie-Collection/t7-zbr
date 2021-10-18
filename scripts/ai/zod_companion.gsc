zm_zod_companion_monitor()
{
    // level._behaviortreescriptfunctions["zodCompanionTargetService"] = serious::zodcompaniontargetservice;
    while(true)
    {
        level waittill(#"hash_10a36fa2");
        if(isdefined(level.ai_robot))
        {
            level.ai_robot.team = level.var_bfd9ed83.team;
            level.ai_robot.maxhealth = int(level.round_number * 1000);
            level.ai_robot.health = int(level.round_number * 1000);
            level.ai_robot setcandamage(true);
        }
    }
}

zodcompanionabletoshootcondition(entity)
{
	return entity.weapon.name != level.weaponnone.name && !gibserverutils::isgibbed(entity, 16);
}

zodcompaniontargetservice(entity)
{
	if(zodcompanionabletoshootcondition(entity))
	{
		return false;
	}
	if(isdefined(entity.ignoreall) && entity.ignoreall)
	{
		return false;
	}
	aienemies = [];
	playerenemies = [];
	ai = getaiarray();
	players = getplayers();
	positiononnavmesh = getclosestpointonnavmesh(entity.origin, 200);
	if(!isdefined(positiononnavmesh))
	{
		return;
	}
	foreach(index, value in ai)
	{
		if(value.team != entity.team && isactor(value) && !isdefined(entity.favoriteenemy))
		{
			enemypositiononnavmesh = getclosestpointonnavmesh(value.origin, 200);
			if(isdefined(enemypositiononnavmesh) && entity findpath(positiononnavmesh, enemypositiononnavmesh, 1, 0))
			{
				aienemies[aienemies.size] = value;
			}
		}
	}
	foreach(index, value in players)
	{
		if(zod_companion_isvalidplayer(value) && level.ai_robot.team != value.team)
		{
			enemypositiononnavmesh = getclosestpointonnavmesh(value.origin, 200);
			if(isdefined(enemypositiononnavmesh) && entity findpath(positiononnavmesh, enemypositiononnavmesh, 1, 0))
			{
				playerenemies[playerenemies.size] = value;
			}
		}
	}
	closestplayer = zod_companion_findclosest(entity, playerenemies);
	closestai = zod_companion_findclosest(entity, aienemies);
	if(!isdefined(closestplayer.entity) && !isdefined(closestai.entity))
	{
		return;
	}
	if(isdefined(closestplayer.entity))
    {
        entity.favoriteenemy = closestplayer.entity;
        entity SetEntityTarget(entity.favoriteenemy, 1, "j_head");
        entity.enemy = closestplayer.entity;
        return entity.enemy;
    }
    else
    {
        entity.favoriteenemy = closestai.entity;
        if(isdefined(entity.favoriteenemy))
        {
            entity SetEntityTarget(entity.favoriteenemy, 1, "j_head");
        }
        entity.enemy = closestai.entity;
    }
}

zod_companion_findclosest(entity, entities)
{
	closest = spawnstruct();
	if(entities.size > 0)
	{
		closest.entity = entities[0];
		closest.distancesquared = distancesquared(entity.origin, closest.entity.origin);
		for(index = 1; index < entities.size; index++)
		{
			distancesquared = distancesquared(entity.origin, entities[index].origin);
			if(distancesquared < closest.distancesquared)
			{
				closest.distancesquared = distancesquared;
				closest.entity = entities[index];
			}
		}
	}
	return closest;
}

zod_companion_isvalidplayer(player)
{
	if(!isdefined(player) || !isalive(player) || !isplayer(player) || player.sessionstate == "spectator" || player.sessionstate == "intermission" || player laststand::player_is_in_laststand() || player.ignoreme)
	{
		return false;
	}
	return true;
}

detour zodcompanionbehavior<scripts\zm\archetype_zod_companion.gsc>::manage_companion_movement(entity)
{
	self endon("death");
	if(isdefined(level.var_bfd9ed83) && level.var_bfd9ed83.eligible_leader)
	{
		self.leader = level.var_bfd9ed83;
	}
	if(!isdefined(entity.var_57e708f6))
	{
		entity.var_57e708f6 = 0;
	}
	if(entity.bulletsinclip < entity.weapon.clipsize)
	{
		entity.bulletsinclip = entity.weapon.clipsize;
	}
	if(isdefined(entity.reviving_a_player) && entity.reviving_a_player == 1)
	{
		return;
	}
	if(isdefined(entity.time_expired) && entity.time_expired == 1)
	{
		return;
	}
	if(isdefined(entity.var_53ce2a4e) && entity.var_53ce2a4e == 1 || isdefined(entity.teleporting) && entity.teleporting == 1)
	{
		return;
	}
	if(isdefined(entity.leader.teleporting) && entity.leader.teleporting == 1)
	{
		if(!isdefined(level.fn_34117adf))
		{
			level.fn_34117adf = @zodcompanionbehavior<scripts\zm\archetype_zod_companion.gsc>::function_34117adf;
		}
		entity thread [[ level.fn_34117adf ]](entity.leader.teleport_location);
		return;
	}
	if(isdefined(entity.var_c0e8df41) && entity.var_c0e8df41 == 1)
	{
		return;
	}
	if(isdefined(entity.leader.var_122a2dda) && entity.leader.var_122a2dda == 1)
	{
		if(!isdefined(level.fn_3463b8c2))
		{
			level.fn_3463b8c2 = @zodcompanionbehavior<scripts\zm\archetype_zod_companion.gsc>::function_3463b8c2;
		}
		entity thread [[ level.fn_3463b8c2 ]](entity.leader.var_fa1ecd39);
	}
	if(!isdefined(entity.var_a0c5deb2))
	{
		entity.var_a0c5deb2 = gettime();
	}
	if(gettime() >= entity.var_a0c5deb2 && isdefined(level.active_powerups) && level.active_powerups.size > 0)
	{
		if(!isdefined(entity.var_34a9f1ad))
		{
			entity.var_34a9f1ad = 0;
		}
		foreach(var_757f815e, powerup in level.active_powerups)
		{
			if(isinarray(entity.var_fb400bf7, powerup.powerup_name))
			{
				dist = distancesquared(entity.origin, powerup.origin);
				if(dist <= 147456 && randomint(100) < 50 + 10 * entity.var_34a9f1ad)
				{
					entity setgoal(powerup.origin, 1);
					entity.var_a0c5deb2 = gettime() + randomintrange(2500, 3500);
					entity.next_move_time = gettime() + randomintrange(2500, 3500);
					entity.var_34a9f1ad = 0;
					return;
				}
				entity.var_34a9f1ad = entity.var_34a9f1ad + 1;
			}
		}
		entity.var_a0c5deb2 = gettime() + randomintrange(333, 666);
	}
	follow_radius_squared = 256 * 256;
	if(isdefined(entity.leader))
	{
		entity.companion_anchor_point = entity.leader.origin;
	}
	if(isdefined(entity.pathgoalpos))
	{
		dist_check_start_point = entity.pathgoalpos;
	}
	else
	{
		dist_check_start_point = entity.origin;
	}
	if(!isdefined(level.fn_zcpnmp))
	{
		level.fn_zcpnmp = @zodcompanionbehavior<scripts\zm\archetype_zod_companion.gsc>::pick_new_movement_point;
	}
	if(isdefined(entity.enemy) && entity.enemy.archetype == "parasite")
	{
		height_difference = abs(entity.origin[2] - entity.enemy.origin[2]);
		var_3b804002 = 1.5 * height_difference * 1.5 * height_difference;
		if(distancesquared(dist_check_start_point, entity.enemy.origin) < var_3b804002)
		{
			entity [[ level.fn_zcpnmp ]]();
		}
	}
	if(distancesquared(dist_check_start_point, entity.companion_anchor_point) > follow_radius_squared || distancesquared(dist_check_start_point, entity.companion_anchor_point) < 4096)
	{
		entity [[ level.fn_zcpnmp ]]();
	}
	if(gettime() >= entity.next_move_time)
	{
		entity [[ level.fn_zcpnmp ]]();
	}
}
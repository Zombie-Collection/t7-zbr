createText(font, fontScale, align, relative, x, y, sort, alpha, text, color, isLevel = false)
{
    if(islevel)
        textelem = hud::createServerFontString(font, fontscale);
    else
        textElem = self hud::createFontString(font, fontScale);
    
    textElem hud::setPoint(align, relative, x, y);
    
    textElem.hideWhenInMenu = true;
    
    textElem.archived = true;

    if(!isdefined(self.hud_amount))
        self.hud_amount = 0;

    if( self.hud_amount >= 19 ) 
        textElem.archived = false;
    
    textElem.sort           = sort;
    textElem.alpha          = alpha;
    textElem.color          = color;
    textElem SetText(text);
    textElem thread watchDeletion( self );

    self.hud_amount++;  
    return textElem;
}

debugbox(color = (1,0,0))
{
    if(!isdefined(self.devoffset))
        self.devoffset = 0;
    
    if(DEV_HUD)
        self createRectangle("center", "center", self.devoffset, self.devoffset, 100, 100, color, "white", 99, 1);
    
    self.devoffset += 25;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, server)
{
    boxElem = newClientHudElem(self);

    boxElem.elemType = "icon";
    boxElem.color = color;
    if(!level.splitScreen)
    {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.hideWhenInMenu = true;
    
    boxElem.archived = true;

    if(!isdefined(self.hud_amount))
        self.hud_amount = 0;
    
    if(self.hud_amount >= 19) 
        boxElem.archived = false;
    
    boxElem.width          = width;
    boxElem.height         = height;
    boxElem.align          = align;
    boxElem.relative       = relative;
    boxElem.xOffset        = 0;
    boxElem.yOffset        = 0;
    boxElem.children       = [];
    boxElem.sort           = sort;
    boxElem.alpha          = alpha;
    boxElem.shader         = shader;
    boxElem hud::setParent(level.uiParent);
    boxElem setShader(shader, width, height);
    boxElem.hidden = false;
    boxElem hud::setPoint(align, relative, x, y);
    boxElem thread watchDeletion( self );
    
    self.hud_amount++;
    return boxElem;
}

watchDeletion(player)
{
    player endon("disconnect"); //lmfao
    self waittill("death");
    
    if(!isdefined(player.hud_amount))
        player.hud_amount = 0;
    
    if( player.hud_amount > 0 )
        player.hud_amount--;
}

ZoneUpdateHUD()
{
    self notify("ZoneUpdateHUD");
    self endon("ZoneUpdateHUD");
    level endon("end_game");

    if(DEV_ZONE_SPAWNERS && !isdefined(self._zone_debug_spawned))
    {
        self._zone_debug_spawned = true;
        spawners = struct::get_array("player_respawn_point", "targetname");

        foreach(spawner in spawners)
        {
            spawn_array = struct::get_array(spawner.target, "targetname");
            foreach(spawn in spawn_array)
            {
                model = spawn("script_model", spawn.origin);
                model SetModel(self GetCharacterBodyModel());
            }
        }

    }

    while(true)
    {   
        wait 1;
        if(self.sessionstate != "playing")
        {
            continue;
        }
        zone = self zm_zonemgr::get_player_zone();
        z_text = level.script + ": " + zone;
        if(isinarray(level.gm_blacklisted, zone))
        {
            z_text += " (^1BLACKLISTED^7)";
        }
        self.zone_hud SetText(z_text);
        if(self useButtonPressed())
        {
            if(self adsButtonPressed())
            {
                if(DEBUG_POI_SPAWNER)
                {
                    self dev_print_spawn_badloc();
                }
            }
            else
            {
                self iPrintLnBold(self getOrigin() + "|" + self getPlayerAngles());
            }
        }
    }
}

dev_ammo()
{
    self endon("spawned_player");
    self endon("bled_out");
    self endon("disconnect");
    while(true)
    {
        self util::waittill_any_timeout(0.25, "weapon_fired", "grenade_fire", "missile_fire", "weapon_change", "reload");
        weapon = self getcurrentweapon();
        if(!isdefined(weapon)) continue;
        if(weapon != "none")
        {
            self setWeaponAmmoClip(weapon, 1337);
            self giveMaxAmmo(weapon);
        }
        if(self getCurrentOffHand() != "none")
            self giveMaxAmmo(self getCurrentOffHand());
    }
}

ANoclipBind(player)
{
    level endon("game_ended");
    level endon("end_game");
    player endon("disconnect");
    player endon("bled_out");

    if(!isdefined(player))
        return;
    
	player iprintlnbold("^2Press [{+frag}] ^3to ^2Toggle No Clip");

	normalized = undefined;
	scaled = undefined;
	originpos = undefined;
	player unlink();
	player.originObj delete();

	while(true)
	{
		if( player fragbuttonpressed())
		{
			player.originObj = spawn( "script_origin", player.origin, 1 );
    		player.originObj.angles = player.angles;
			player PlayerLinkTo( player.originObj, undefined );

			while( player fragbuttonpressed() )
				wait .1;
			
            player iprintlnbold("No Clip ^2Enabled");
            player iPrintLnBold("[{+breath_sprint}] to move");

			player enableweapons();
			while(true)
			{
				if( player fragbuttonpressed() )
					break;
                
				if( player SprintButtonPressed() )
				{
					normalized = AnglesToForward(player getPlayerAngles());
					scaled = vectorScale( normalized, 60 );
					originpos = player.origin + scaled;
					player.originObj.origin = originpos;
				}
				wait .05;
			}

			player unlink();
			player.originObj delete();

			player iprintlnbold("No Clip ^1Disabled");

			while( player fragbuttonpressed() )
				wait .1;
		}
		wait .1;
	}
}

CreateCheckBox(align, relative, x, y, height, primaryColor, baseSort, checked = false)
{
    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;
    
    box = spawnStruct();
    box.checked = checked;
    box.bg = self createRectangle(align, relative, x, y, height, height, (0,0,0), "white", baseSort, !self.gm_hud_hide);
    box.fill = self createRectangle("TOPLEFT", "TOPLEFT", 2, 2, height - 4, height - 4, primaryColor, "white", baseSort + 1, self.gm_hud_hide ? 0 : box.filled);
    box.fill hud::SetParent(box.bg);
    box.primaryColor = primaryColor;
    box.maxheight = height - 4;
    return box;
}

SetChecked(box, checked = false)
{
    if(!isdefined(box))
        return;

    if(!isdefined(box.fill))
        return;

    if(box.checked == checked)
    {
        box.bg.alpha = !self.gm_hud_hide;
        box.fill.alpha = self.gm_hud_hide ? 0 : checked;
        return;
    }
    
    box.checked = checked;

    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;
    
    box.bg.alpha = !self.gm_hud_hide;
    box.fill.color = (1,1,1);
    box.fill fadeOverTime(.2);
    box.fill.alpha = self.gm_hud_hide ? 0 : checked;
    box.fill.color = box.primaryColor;
}

CreateProgressBar(align, relative, x, y, width, height, primaryColor, baseSort)
{
    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;
    
    bar = spawnStruct();
    bar.dimmed = false;
    bar.bg = self createRectangle(align, relative, x, y, width, height, (0,0,0), "white", baseSort, !self.gm_hud_hide);
    bar.bgfill = self createRectangle("TOPLEFT", "TOPLEFT", 2, 2, width - 4, height - 4, primaryColor, "white", baseSort + 2, !self.gm_hud_hide);
    bar.fill = self createRectangle("TOPLEFT", "TOPLEFT", 2, 2, width - 4, height - 4, primaryColor, "white", baseSort + 1, !self.gm_hud_hide);
    bar.fill hud::SetParent(bar.bg);
    bar.bgfill hud::SetParent(bar.bg);
    bar.primaryColor = primaryColor;
    bar.secondaryColor = primaryColor;
    bar.maxwidth = width - 4;
    bar.maxheight = height - 4;
    return bar;
}

SetProgressbarPercent(bar, percent = 0.0)
{   
    if(!isdefined(bar))
        return;
    
    if(percent > 1)
        percent = 1;

    if(percent < 0.01)
        percent = 0.01;

    if(!isdefined(bar.fill))
        return;

    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;
    
    bar.fill.alpha = !self.gm_hud_hide;
    bar.bg.alpha = !self.gm_hud_hide;
    bar.fill.color = (1,1,1);
    bar.fill fadeOverTime(.2);
    bar.fill setShader("white", int(max(bar.maxwidth * percent, 1)), bar.maxheight);
    bar.fill.color = bar.primaryColor * ((isdefined(bar.dimmed) && bar.dimmed) ? (.5,.5,.5) : (1,1,1));
}

SetProgressbarSecondaryPercent(bar, percent = 0.0)
{   
    if(!isdefined(bar))
        return;
    
    if(percent > 1)
        percent = 1;

    if(percent < 0.01)
        percent = 0.01;

    if(!isdefined(bar.bgfill))
        return;

    if(percent <= 0.01)
    {
        bar.bgfill.alpha = 0;
        return;
    }

    if(!isdefined(self.gm_hud_hide))
        self.gm_hud_hide = false;
    
    bar.bgfill.alpha = !self.gm_hud_hide;
    bar.bgfill.color = (1,1,1);
    bar.bgfill fadeOverTime(.2);
    bar.bgfill setShader("white", int(max(bar.maxwidth * percent, 1)), bar.maxheight);
    bar.bgfill.color = bar.secondaryColor;
}

NextSong(value)
{
    if(!isdefined(level.nextsong))
        level.nextsong = "";
    
    if(!isdefined(value) || level.nextsong == value)
    {
        level.playing_song = false;
        level.nextsong = "none";
        level.musicSystem.currentPlaytype = 0;
	    level.musicSystem.currentState = undefined;
        level notify("end_mus");
        return;
    }

    level.nextsong = value;
    level.playing_song = true;
    self thread PlayMusicSafe(level.nextsong);
}

PlayMusicSafe(music)
{
    level notify("new_mus");
    level zm_audio::sndMusicSystem_StopAndFlush();
    
    wait .1;
    self thread CustomPlayState(music);
}

CustomPlayState(music)
{
	level endon("sndStateStop");

	level.musicSystem.currentPlaytype = 4;
	level.musicSystem.currentState = music;

	wait .1;
    music::setmusicstate(music);
    
    wait .1;

    ent = spawn("script_origin", self.origin);
    ent thread DieOnNewMus(music);

    ent PlaySound(music);

	playbackTime = soundgetplaybacktime(music);
	if(!isdefined(playbackTime) || playbackTime <= 0)
	{
		waitTime = 1;
	}
	else
	{
		waitTime = playbackTime * 0.001;
	}

	wait waitTime;
	level.musicSystem.currentPlaytype = 0;
	level.musicSystem.currentState = undefined;
    level notify("end_mus");
}

DieOnNewMus(music)
{
    level util::waittill_any("end_game", "sndStateStop", "new_mus", "end_mus");
    self StopSounds();
    self StopSound(music);
    wait 10;
    self delete();
}

GM_KillMusic()
{
    NextSong();
}

GM_StartMusic()
{
    if(isdefined(level.playing_song) && level.playing_song)
        return;
    music = level.winning_musics[randomint(level.winning_musics.size)];
    thread NextSong(music);
}

playFXTimedOnTag(fx, tag, timeout)
{
    e_fx = spawn("script_model", self getTagOrigin(tag));
    e_fx setmodel("tag_origin");
    playFXOnTag(fx, e_fx, "tag_origin");
    e_fx enableLinkTo();
    e_fx linkTo(self, tag, (0,0,0), (0,0,90));
    wait timeout;
    e_fx delete();
}

dev_util_thread()
{
    if(isdefined(level.elo_debug_thread))
        self thread [[level.elo_debug_thread]]();

    if(DEBUG_BOT_TELEPORT)
    {
        self thread dev_bot_teleport();
    }
    else if(DEBUG_BOT_KICK)
    {
        self thread dev_bot_kick();
    }
}

dev_bot_teleport()
{
    self endon("spawned_player");
    self endon("bled_out");
    self endon("disconnect");
    while(true)
    {
        if(self adsButtonPressed() && self meleeButtonPressed())
        {
            foreach(player in array::randomize(getplayers()))
            {
                if(player == self) continue;
                if(player.sessionstate != "playing") continue;
                if(!player util::is_bot()) continue;
                player setOrigin(self getorigin());
                player freezeControls(true);
                break;
            }
            while(self adsButtonPressed() || self meleeButtonPressed())
            {
                wait 0.25;
            }
        }
        wait 0.25;
    }
}

dev_bot_kick()
{
    self endon("spawned_player");
    self endon("bled_out");
    self endon("disconnect");
    while(true)
    {
        if(self adsButtonPressed() && self meleeButtonPressed())
        {
            foreach(player in array::randomize(getplayers()))
            {
                if(player == self) continue;
                if(player.sessionstate != "playing") continue;
                if(!player util::is_bot()) continue;
                kick(player getEntityNumber());
                break;
            }
            while(self adsButtonPressed() || self meleeButtonPressed())
            {
                wait 0.25;
            }
        }
        wait 0.25;
    }
}

dev_actor(origin, angles)
{
    if(!IS_DEBUG) 
    {
        return undefined;
    }
    mdl = spawn("script_model", origin);
    mdl.angles = angles;
    mdl setModel("defaultactor");
    return mdl;
}

dev_pickup()
{

}

dev_bind()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    ads_ent = undefined;
    while(true)
    {
        while(self adsButtonPressed())
        {
            while(!isdefined(ads_ent) && self adsButtonPressed())
            {
                ads_ent = self get_looked_at_entity();
                if(isdefined(ads_ent))
                {
                    if(isdefined(ads_ent.targetname))
                        self iPrintLnBold(ads_ent.targetname + " picked up");
                    else
                        self iPrintLnBold("ent picked up");
                }
                wait 0.1;
            }
            if(!isdefined(ads_ent)) continue;
            v_direction = anglestoforward(self getplayerangles());
            v_forward = vectorscale(v_direction, 100);
            if(isplayer(ads_ent))
                ads_ent setOrigin(self geteye() + v_forward);
            else
                ads_ent.origin = self geteye() + v_forward;
            if(self useButtonPressed())
            {
                if(isplayer(ads_ent))
                {
                    self iPrintLnBold("cannot delete players");
                }
                else
                {
                    if(isdefined(ads_ent.targetname))
                        self iPrintLnBold(ads_ent.targetname + " deleted");
                    else
                        self iPrintLnBold("deleted");
                    ads_ent delete();
                }
                ads_ent = undefined;
                while(self useButtonPressed() || self adsButtonPressed())
                {
                    wait 0.025;
                }
            }

            if(self meleeButtonPressed())
            {
                if(isdefined(ads_ent.targetname))
                    self iPrintLnBold(ads_ent.targetname + " in hand");
                else
                    self iPrintLnBold("Ent in hand");
                while(self meleeButtonPressed() && self adsButtonPressed())
                {
                    wait 0.025;
                }
            }
            wait 0.025;
        }
        ads_ent = undefined;
        wait 0.025;
    }
}

#define MAX_ACCEPTIBLE_RANGE = 150;
get_looked_at_entity()
{
  v_direction = anglestoforward(self getplayerangles());
  v_forward = vectorscale(v_direction, 10000);
  v_start = self geteye();
  v_end = v_start + v_forward;
  v_hit = bullettrace(v_start, v_end, true, self, true, true)["position"];
  a_ents = getentarray();
  arrayremovevalue(a_ents, self, false);
  possible = array::get_all_closest(v_hit, a_ents, undefined, undefined, MAX_ACCEPTIBLE_RANGE);
  return possible.size ? possible[0] : undefined;
}

unlock_all_debris()
{
    setdvar("zombie_unlock_all", 1);
    zombie_doors = GetEntArray("zombie_debris", "targetname");
    foreach(door in zombie_doors)
    {
        door notify("trigger", level.players[0], 1);
    }
    wait 0.1;
    setdvar("zombie_unlock_all", 0);
}

dev_print_spawn_badloc()
{
    result = array::get_all_closest(self.origin, level.a_v_poi_spawns, undefined, undefined, 150);
    if(result.size < 1) return;
    self iPrintLnBold(result.origin + " - " + is_point_in_bad_zone(result.origin));
}

set_move_speed_scale(n_value = 1)
{
    self setMoveSpeedScale(n_value);
    self update_gm_speed_boost(undefined, n_value);
}
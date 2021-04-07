bhb_hook()
{
    if(isdefined(level.__black_hole_bomb_poi_override))
        self thread [[level.__black_hole_bomb_poi_override]]();
    if(!isdefined(self._black_hole_bomb_player) || !isdefined(self._black_hole_bomb_player.sessionstate) || self._black_hole_bomb_player.sessionstate != "playing") return;
    owner = self._black_hole_bomb_player;
    owner thread start_timed_pvp_vortex(self getorigin(), 4227136, 10, undefined, undefined, owner, level.var_453e74a0, 0, undefined, 0, 0, 0);
}
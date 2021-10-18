trap_fire_player()
{
    self endon("bled_out");
	self endon("disconnect");
    if(isdefined(self.is_burning) && self.is_burning) return;
    if(self laststand::player_is_in_laststand()) return;
	self.is_burning = 1;
    self setburn(0.1);
    self dodamage(TRAP_DEFAULT_DAMAGE, self.origin);
    wait(0.1);
    self playsound("zmb_ignite");
    self.is_burning = undefined;
}

trap_electric_watch_zm()
{
    self endon("trap_done");
    self endon("trap_deactivate");
    while(isdefined(self))
    {
        foreach(zombie in getaiteamarray(level.zombie_team))
        {
            if(zombie istouching(self))
            {
                self notify("trigger", zombie);
            }
        }
        wait 0.05;
    }
}

detour zm_trap_electric<scripts\zm\_zm_trap_electric.gsc>::trap_activate_electric()
{
    self thread trap_electric_watch_zm();
    fn_original = @zm_trap_electric<scripts\zm\_zm_trap_electric.gsc>::trap_activate_electric;
    self [[ fn_original ]]();
}
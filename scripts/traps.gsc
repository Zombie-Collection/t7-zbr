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
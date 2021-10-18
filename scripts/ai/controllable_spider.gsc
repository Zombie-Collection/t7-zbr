detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_4e8bb77d()
{
    self endon("death");
    self thread find_owner_and_watch_damage();
	wait(60);
	self dodamage(self.health + 1000, self.origin);
}

detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_a21f0b74()
{
    self.var_59bd3c5a endon("death");
	self endon("disconnect");
	while(true)
	{
		if(self util::use_button_held())
		{
            if(isdefined(self.var_59bd3c5a))
            {
                self.var_59bd3c5a.takedamage = 1;
                self.var_59bd3c5a.owner = undefined;
                self.var_59bd3c5a dodamage(self.var_59bd3c5a.health + 1000, self.var_59bd3c5a.origin);
                self.var_59bd3c5a kill();
                return;
            }
		}
		wait(0.05);
	}
}

find_owner_and_watch_damage()
{
    wait 1;
    owner = undefined;
    foreach(player in getplayers())
    {
        if(isdefined(player.var_59bd3c5a) && player.var_59bd3c5a == self)
        {
            owner = player;
            break;
        }
    }
    if(!isdefined(owner))
    {
        return;
    }
    self setCanDamage(true);
    self setteam(owner.team);
}
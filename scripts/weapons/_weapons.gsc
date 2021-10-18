generate_weapons_table()
{
    level.weapon_scalars_table = [];
    register_weapon_scalar("sniper_fastsemi", "sniper_fastsemi_upgraded", 0.55);
    register_weapon_scalar("launcher_standard", "launcher_standard_upgraded", 30, 100);
    register_weapon_scalar("launcher_multi", "launcher_multi_upgraded", 20, 40);
    register_weapon_scalar("microwavegundw", "microwavegundw_upgraded", 1125, 2625);
    register_weapon_scalar("microwavegunlh", "microwavegunlh_upgraded", 1125, 2625);
    register_weapon_scalar("pistol_c96_upgraded", undefined, 40);
    register_weapon_scalar("raygun_mark2", "raygun_mark2_upgraded", 20, 40);
    register_weapon_scalar("raygun_mark3", "raygun_mark3_upgraded", 18, 65);
    register_weapon_scalar("pistol_m1911_upgraded", "pistol_m1911h_upgraded", 12);
    register_weapon_scalar("pistol_revolver38_upgraded", "pistol_revolver38lh_upgraded", 12);
    register_weapon_scalar("pistol_standard_upgraded", "pistol_standardlh_upgraded", 12);
    register_weapon_scalar("shotgun_energy", "shotgun_energy_upgraded", 50, 100);
    register_weapon_scalar("pistol_energy", "pistol_energy_upgraded", 2, 5);
    register_weapon_scalar("pistol_burst", "pistol_burst_upgraded", 3, 2);
    register_weapon_scalar("pistol_fullauto", "pistol_fullauto_upgraded", 1.5, 1.5);
    register_weapon_scalar("smg_standard", "smg_standard_upgraded", 1.6, 1.6);
    register_weapon_scalar("smg_ak74u", "smg_ak74u_upgraded", 2, 2);
    register_weapon_scalar("ar_damage", "ar_damage_upgraded", 2.5, 2.5);
    register_weapon_scalar("ar_longburst", "ar_longburst_upgraded", 2.5, 2.5);
    register_weapon_scalar("ar_marksman", "ar_marksman_upgraded", 9, 6.0);
    register_weapon_scalar("shotgun_precision", "shotgun_precision_upgraded", 3, 3);
    register_weapon_scalar("shotgun_fullauto", "shotgun_fullauto_upgraded", 0.7, 0.7);
}

register_weapon_scalar(str_weapon, str_upgrade, scalar_base = 1.0f, scalar_upgrade = scalar_base)
{
    if(!isdefined(level.weapon_scalars_table))
    {
        level.weapon_scalars_table = [];
    }
    if(isdefined(str_weapon))
    {
        level.weapon_scalars_table[str_weapon] = scalar_base;
    }
    if(isdefined(str_upgrade))
    {
        level.weapon_scalars_table[str_upgrade] = scalar_upgrade;
    }
}
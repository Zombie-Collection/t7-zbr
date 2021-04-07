/////////////
// Credits //
/////////////
// Serious - Creator. https://www.youtube.com/anthonything
// NOTE: If you use any of these functions in your project, please credit me. Thanks!
// Extinct: Misc code snippets, testing.
// ItsFebiven: Misc code snippets, testing.
// SyGnUs: Gameplay testing, chatting.
// Candy, Snowy, CF499, Daltax, Leaf: Gameplay testing
// My youtube subs, and anyone else I forgot about at this current point in time.

/////////////////////////////////
// Tuneable Gameplay Variables //
/////////////////////////////////
#region Tunables

// When set to true, forces you to gain host in public matches
// default value: true
#define FORCE_HOST = true;

// The delay, in seconds, before applying any game mode logic to a player once spawned
// default value: 2
#define SPAWN_DELAY = 2;

// Maximum time, in seconds, that a zombie may walk the earth
// default value: 45
#define ZOMBIE_MAXLIFETIME = 45;

// Base value to start zm damage at, only if the zombie damage is defaulted.
// default value: 45
#define ZOMBIE_BASE_DMG = 45;

// Capactity for the player hit buffer, which prevents exponential damage from kicking in and regenerates over time.
// default value: 90
#define HIT_BUFFER_CAPACITY = 90;

// Maximum damage a zombie can do to a player
// default value: 5000
#define MAX_HIT_VALUE = 5000;

// Exponent used to adjust zombie death award values, raised to the power of the round number, times the round number
// default value: 1.1
#define EXPONENT_SCOREINC = 1.1;

// Round number times this number, times the zombie melee damage (ZOMBIE_BASE_DMG) will be the final damage
// default value: 4
#define EXPONENT_DMGINC = 4;

// Exponent used to calculate the spawn delay for a zombie, used as input to the original 3arc algorithm
// default value: 0.85
#define EXPONENT_SPAWN_DELAY_MULT = 0.85;

// Speed at which zombie move speed increases per round
// default value: 5
#define GM_ZM_SPEED_MULT = 5;

// Defines the round at which between round time approaches 0
// default value: 15
#define GM_ROUND_DELAY_FULL_RND = 15;

// Time in seconds, that the game should wait between rounds, when the round delay is at its longest.
// default value: 5
#define GM_BETWEEN_ROUND_DELAY_START = 8;

// Global scalar for zombie damage on origins
// default value: 0.8
#define ORIGINS_ZOMBIE_DAMAGE = 0.8;

// Exponent used to calculate the price of objects, raised to the power of the round.
// default value: 1.08
#define EXPONENT_PURCHASE_COST_INC = 1.08;

// Number of points a player must have to win the game
// default value: 100000
#define WIN_NUMPOINTS = 100000;

// Maximum number of points a player can respawn with
// default value: 80000
#define MAX_RESPAWN_SCORE = 80000;

// Multiplier to use when respawning a player and granting their max points
// default value: 0.8
#define SPAWN_REDUCE_POINTS = 0.8;

// Efficiency operand used against the net damage done to a player when converting to point awards
// default value: 0.7
#define DMG_CONVT_EFFICIENCY = 0.7;

// The amount of hero weapon energy to give the player per kill
// default value: 20
#define GADGET_PWR_PER_KILL = 20;

// Damage multiplier used against the round number to scale PvP damage. This is also known as standard boost. Does not apply to all weapons.
// default value: 0.1
#define WEP_DMG_BOOST_PER_ROUND = 0.1;

// Defines the maximum melee damage a player can do in one hit, excluding pop shocks and sword flay.
// default value: 20000
#define MAX_MELEE_DAMAGE = 20000;

// Time in seconds that a player must hold (at least) the points to win as their score to win the game.
// default value: 120
#define OBJECTIVE_WIN_TIME = 120;

// Round to start the game mode at. Does not affect buy power scalars.
// default value: 3
#define GM_START_ROUND = 3; 

// number of rounds between point changes (helps with saving hintstring space)
// default value: 5
#define ROUND_DELTA_SCALAR = 5;

// Multiplier to use against level.round_number when giving trailing players points
// default value: 1250
#define MIN_ROUND_PTS_MULT = 1250;

// Lowest round to start giving minimum points to trailing players
// default value: 5
#define MIN_ROUND_PTR_BEGIN = 5;

// Time in seconds for which the objective text will remain visible
// default value: 15
#define OBJECTIVE_SHOW_TIME = 15;

// Time in seconds for which the objective text will remain decoding
// default value: 2
#define OBJECTIVE_DECODE_TIME = 2;

// Time between player dying and respawning when a player has objective state set
// default value: 20
#define PLAYER_RESPAWN_DELAY = 20;

// Thundergun velocity at minimum
// default value: 500
#define TGUN_LAUNCH_MIN_VELOCITY = 500;

// Thundergun velocity at maximum
// default value: 5000
#define TGUN_LAUNCH_MAX_VELOCITY = 5000;

// Thundergun max damage at base
// default value: 1000
#define TGUN_BASE_DMG_PER_ROUND = 1000;

// Damage from thundergun when the player impacts a surface at a high velocity, per hundred units per second (velocity)
// default value: 100
#define TGUN_IMPACT_DMG_PER_HUNDRED_U_S = 100;

// Damage done by the explosion of the idgun to other players
// default value: 450
#define IDGUN_PVP_EXPLODE_DMG_PER_ROUND = 450;

// Damage done by the idgun per frame to other players inside the vortex
// default value: 30
#define IDGUN_DMG_PER_FRAME = 30;

// Pull velocity done by the idgun per frame to other players at the center of the vortex
// default value: 30
#define IDGUN_PULL_VELOCITY_PER_FRAME = 30;

// Damage scalar applied to the upgraded idgun
// default value: 1.5
#define IDGUN_SCALAR_UPGRADED = 1.5;

// The amount of shock damage to do to a player when they are affected by the SOE ground slam (or grav spikes on zm_castle) from the blue sword, multiplied by the round number
// default value: 500
#define ZM_ZOD_SWORD_SHOCK_DMG = 500;

// The distance players get thrown when affected by major damage from the grav spikes
// default value: 1000
#define ZM_CASTLE_THROWBACK_MAJOR = 500;

// The distance players get thrown when affected by minor damage from the grav spikes
// default value: 300
#define ZM_CASTLE_THROWBACK_MINOR = 100;

// Damage inflicted per second by the placed spikes trap
// default value: 10000
#define ZM_SPIKES_DPS = 20000;

// Time to wait between ticks of the placed trap
// default value: 0.1
#define ZM_SPIKES_TICKDELAY = 0.1;

// Defines the slam damage for grav spikes, scaled by round number
// default value: 1000
#define ZM_SPIKES_SLAM_DMG = 2000;

// Damage that the dragonshield projectile does, multiplied by the round number.
// default value: 1000
#define ZM_DRAGSHIELD_DMG = 1000;

// Damage scaled by round number done to players, linear mapped by cherry power
// default value: 1000
#define PVP_ELECTRIC_CHERRY_DMG = 1000;

// Damage that the wavegun alt fire does, scaled by the round number
// default value: 1000
#define MOON_WAVEGUN_ALTFIRE_DMG = 1000;

// Radius to start doing damage to players with bhb
// default value: 1000
#define BLACKHOLEBOMB_MIN_DMG_RADIUS = 1000;

// AAT deadwire damage scaled by the round number
// default value: 1000
#define AAT_DEADWIRE_PVP_DAMAGE = 1000;

// AAT blast furnace damage scaled by the round (in total)
// default value: 1000
#define AAT_BLASTFURNACE_PVP_DAMAGE = 1000;

// AAT thunderwall damage scaled by the round
// default value: 1000
#define AAT_THUNDERWALL_PVP_DAMAGE = 1000;

// AAT fireworks damage scaled by the round
// default value: 1000
#define AAT_FIREWORKS_PVP_DAMAGE = 1000;

// pop shocks pvp damage scaled by the round
// default value: 2500
#define BGB_POPSHOCKS_PVP_DAMAGE = 2500;

// maximum activations for the burned out gobblegum
// default value: 4
#define BGB_BURNEDOUT_MAX = 4;

// damage done over time by the burned out gobblegum to players, scaled by the round number
// default value: 1500
#define BGB_BURNEDOUT_PVP_DAMAGE = 1500;

// One inch punch velocity at minimum
// default value: 500
#define OIP_LAUNCH_MIN_VELOCITY = 500;

// One inch punch velocity at maximum
// default value: 5000
#define OIP_LAUNCH_MAX_VELOCITY = 5000;

// Applied globally across all melee types that are not explicitly overriden
// default value: 3
#define MELEE_DMG_SCALAR = 3;

// Defines the duration, in seconds, of the fire staff burn duration
// default value: 8
#define STAFF_FIRE_DMG_DURATION = 8;

// Defines the percent reduction for zombie damage when a round resets, and inversely, the percent to increase zombie damage when the global scalar is not 100%
// default value: 0.25
#define GM_ZDMG_RUBBERBAND_PERCENT = 0.25;

// Defines the percent value that the damage for the annihilator is increased, per round.
// default value: 0.07
#define ANNIHILATOR_DMG_PERCENT_PER_ROUND = 0.07;

// Defines the multiplier that double points will apply to pvp related points
// default value: 1.35
#define DOUBLEPOINTS_PVP_SCALAR = 1.35;

// Defines the damage multiplier for pvp when instakill is active
// default value: 1.5
#define INSTAKILL_DMG_PVP_MULTIPLIER = 1.5;

// Defines the damage scalar for the lightning staff damage per tick
// default value: 1.0f
#define STAFF_LIGHTNING_DMG_SCALAR = 1.0f;

// Defines the water staff's damage per second, scaled by round. Upgraded staff does 2x
// default value: 125
#define STAFF_WATER_DPS = 125;

// Defines the radius that the air staff tornado will succ players.
// default value: 225
#define STAFF_AIR_SUCC_RADIUS = 225;

// Pull velocity done by the air staff per frame to other players at the center of the vortex
// default value: 70
#define STAFF_AIR_PULL_VELOCITY_PER_FRAME = 70;

// Damage done by the air staff per tick (.1s) to other players inside the vortex
// default value: 50
#define STAFF_AIR_DMG_PER_TICK = 20;

// Damage percent added to the air staff damage per round
// default value: 0.05
#define STAFF_AIR_DMG_BONUS_PER_ROUND = 0.05;

// Defines the damage done to nearby players when a fire rune breaks, scaled by the round number
// default value: 200
#define BOW_FIRE_ROCK_BREAK_DMG = 200;

// Defines the damage done to the player trapped by a fire rune, scaled by the round number, done in ticks of 0.1s, for 3.8 seconds
// default value: 15
#define BOW_FIRE_DMG_PER_TICK = 15;

// Defines the damage done to the player who walks over a fire rune geyser, scaled by the round number, in total.
// default value: 1000
#define BOW_GEYSER_FIRE_TOTAL = 1000;

// Defines the damage done to players within radius of a storm bow shot, scaled by the round
// default value: 1000
#define BOW_STORM_SHOCK_DAMAGE = 500;

// Defines the damage done per round as push damage when hit by the wolf bow push
// default value: 500
#define BOW_WOLF_PUSH_DAMAGE = 500;

// Defines the percent of health taken from all enemy players when a nuke is grabbed
// default value: 0.05
#define NUKE_HEALTH_PERCENT = 0.05;

// Damage multiplier for when a player is frozen by a bgb, multiplied by final damage result.
// default value: 0.5
#define BGB_FROZEN_DAMAGE_REDUX = 0.5;

// Time in ms that a player will receive credit for damage inflicted by a fall after attacking their victim.
// default value: 7500
#define MOD_FALL_GRACE_PERIOD = 7500;

// Total damage a single skull from the bow can do, scaled by the round number.
// default value: 250
#define BOW_DEMONGATE_SKULL_TOTALDAMAGE = 250;

// Number of skulls to spawn for pvp damage per shot
// default value: 4
#define BOW_DEMONGATE_SKULL_COUNT = 4;

// Scalar for explosive knockback
// default value: 200
#define EXPLOSIVE_KNOCKBACK_SCALAR = 200;

// Damage done per 0.25s tick for the skull, scaled by the round number
// default value: 250
#define SKULL_DMG_PER_TICK = 500;

// Score awarded to a player who mesmerizes another player, given every 0.25s
// default value: 100
#define SKULL_MESMERIZE_SCORE_PER_TICK = 100;

// Reduction to damage done by juggernaut perk. Cannot be greater than 1, nor less than 0.
// default value: 0.25
#define PERK_JUGGERNAUT_REDUCTION = 0.25;

// default damage a trap does, per hit
// default value: 10000
#define TRAP_DEFAULT_DAMAGE = 10000;

// Defines the minimum door price to get the automatic door price reduction
// default value: 500
#define DOOR_REDUCE_MIN_PRICE = 500;

// Defines the minimum door price to get a second reduction to price. A door may only get up to two reductions in price.
// default value: 2500
#define DOOR_REDUCE_TWICE_MIN_PRICE = 2500;

// Defines the amount to reduce a door's price by if it meets the minimum price requirements
// default value: 250
#define DOOR_REDUCE_AMOUNT = 250;

// Time scalar to auto-bleedout. (Duration of the deathcam)
// default value: 0.07
#define N_BLEEDOUT_BASE = 0.07;

// Time in seconds that a player is slowed by widows wine effects when not cocooned
// default value: 5
#define WIDOWS_WINE_SLOW_TIME = 5;

// Time in seconds that a player is slowed by widows wine effects when cocooned
// default value: 7
#define WIDOWS_WINE_COCOON_TIME = 7;

// Velocity applied to players when wind staff hits them
// default value: 5000
#define WIND_STAFF_LAUNCH_VELOCITY = 5000;

// Mirg2000 damage per tick of AOE (.25s), scaled by round number
// default value: 500
#define MIRG_2000_AOE_TICK_DMG = 500;

// Time in seconds that a player shrinks for when attacked by shrink ray.
// default value: 5
#define SHRINK_RAY_SHRINK_TIME = 5;

// Multiplier for damage done by a player who has been affected by shrink ray. Does not apply to explosives.
// default value: 5
#define SHRINK_RAY_DAMAGE_MULT = 5;

// The round when wager modifiers may no longer be obtained.
// default value: 5
#define WAGER_COMMIT_ROUND = 5;

#endregion

////////////////////////////////
// Development only variables //
////////////////////////////////
#region Development Variables

// When false, disables all development features
// default value: false
#define IS_DEBUG = false;

// When true, sets developer dvar to 2
// default value: false
#define STABILITY_PASS = false;

// When true, exits the game immediately after ending instead of waiting for outro cutscene 
// default value: false
#define DEV_EXIT = false;

// When true, sets the host player to become invulnerable
// default value: false
#define DEV_GODMODE = false;

// When true, gives the host player 25000 starting points
// default value: false
#define DEV_POINTS = true;

// When true, gives all players 25000 starting points
// default value: false
#define DEV_POINTS_ALL = false;

// When true, spawns in 3 test clients. NOTE: on any map with spiders, this option will cause a fatal crash within 3 rounds.
// default value: false
#define DEV_BOTS = true;

// When true, dev bots are ignored by zombies and take no damage from them
// default value: false
#define DEV_BOTS_IGNORE_ZM_DMG = false;

// When true, enables development hud features
// default value: false
#define DEV_HUD = false;

// When true, creates a dev hud for the current zone
// default value: false
#define DEBUG_ZONE = false;

// When true, allows the host to fly with the grenade button and sprint
// default value: false
#define DEV_NOCLIP = true;

// When true, allows the host player to see enemy players through walls
// default value: false
#define DEV_SIGHT = false;

// When true, forces the host player to be on a team which is not allies
// default value: false
#define DEBUG_TEAMS = false;

// When true, uses the DEV_POINTS_TO_WIN variable instead of WIN_NUMPOINTS for objective logic
// default value: false
#define DEV_USE_PTW = false;

// The number of points to win when DEV_USE_PTW is true
// default value: 50000
#define DEV_POINTS_TO_WIN = 50000;

// When enabled, prints the weapon used to damage a player
// default value: false
#define DEV_DMG_DEBUG = false;

// When enabled, prints the weapon used to damage a player
// default value: false
#define DEV_DMG_DEBUG_FIRST = false;

// When enabled, prints the damage, score, health, and maxhealth of the victim, to the victim
// default value: false
#define DEV_HEALTH_DEBUG = false;

// Award the host a thundergun when they spawn
// default value: false
#define DEBUG_THUNDERGUN = false;

// Award the host an idgun when they spawn
// default value: false
#define DEBUG_IDGUN = false;

// When true, a host player can pull themself with the servant
// default value: false
#define DEBUG_SELF_PULL = false;

// When true, the host player is awarded a wave gun on spawn
// default value: false
#define DEBUG_WAVE_GUN = false;

// When true, the host player is awarded all the perks on spawn
// default value: false
#define DEBUG_ALL_PERKS = false;

// When true, host player will have unlimited ammo
// default value: false
#define DEV_AMMO = false;

// When true, widows wine grenades will do 1 damage (for testing the slow effect)
// default value: false
#define DEBUG_WW_DAMAGE = false;

// When true, awards the host player a soe sword by default
// default value: false
#define DEBUG_SOE_SWORD = false;

// When true, awards the host player a soe upgraded sword by default
// default value: false
#define DEBUG_SOE_SUPERSWORD = false;

// When true, awards the host player grav spikes on zm_castle
// default value: false
#define DEBUG_CASTLE_SPIKES = false;

// if true, upgrades stalingrad dragon strike
// default value: false
#define DEBUG_STALINGRAD_UG_DS = false;

// if true, will award the host with black hole bombs when they spawn.
// default value: false
#define DEBUG_BLACKHOLEBOMB = false;

// adjusts the start round for development
// default value: 3
#define DEBUG_START_ROUND = 3;

// delete all the spawn adjusting logic temporarily
// default value: false
#define DEBUG_REVERT_SPAWNS = false;

// disable all changes to zm_island
// default value: false
#define DEBUG_ISLAND_NOCHANGES = false;

// if true, all players are on the allies team
// default value: false
#define DEBUG_ALL_FRIENDS = false;

// if true, the game mode hud will not be drawn
// default value: false
#define DEBUG_NO_GM_HUD = false;

// if true, the game mode will not initialize roundNext logic
// default value: false
#define DEBUG_NO_ROUNDNEXT = false;

// if true, ignores critical game logic. Only used for last resort debugging
// default value: false
#define DEBUG_NO_GM_THREADED = false;

// if true, will not attempt to return loadouts when a player respawns
// default value: false
#define DEBUG_NO_LOADOUTS = false;

// if true, when on zm_tomb, awards the host player g strike grenades on spawn
// default value: false
#define DEBUG_G_STRIKE = false;

// if true, when on zm_tomb, completes the one inch punch box challenge
// default value: false
#define DEBUG_OIP = false;

// if true, all staffs will be upgraded by default.
// default value: false
#define DEBUG_UPGRADED_STAFFS = false;

// if true, the host will acquire an annihilator on spawn automatically
// default value: false
#define DEBUG_ANNIHILATOR = false;

// if true, the host will acquire the wolf bow on spawn automatically
// default value: false
#define DEBUG_WOLF_BOW = false;

// if true, the host will acquire the fire bow on spawn automatically
// default value: false
#define DEBUG_FIRE_BOW = false;

// if true, the host will acquire the storm bow on spawn automatically
// default value: false
#define DEBUG_STORM_BOW = false;

// if true, the host will acquire the raygun on spawn automatically
// default value: false;
#define DEBUG_RAYGUN = false;

// if true, the host will acquire the raygun mk.3 on spawn automatically. Set to > 1 for upgraded mark 3.
// default value: false;
#define DEBUG_RAYGUN_MK3 = false;

// if true, the host will acquire the skull bow on spawn automatically
// default value: false
#define DEBUG_SKULL_BOW = false;

// if true, awards host shrink ray on spawn (shang only), if 2, awards upgraded
// default value: false
#define DEBUG_SHRINK_RAY = false;

// When true, all players are awarded all the perks on spawn
// default value: false
#define DEBUG_ALL_PERKS_ALL = false;

// When true, the host player is awarded nesting dolls on spawn
// default value: false
#define DEBUG_GIVE_NESTING_DOLLS = false;

// When true, the host player is awarded monkeys on spawn
// default value: false
#define DEBUG_GIVE_MONKEYS = false;

// When true, the host player is awarded octobombs on spawn
// default value: false
#define DEBUG_GIVE_OCTOBOMB = false;

// When true, allows elo application in debug environment. No use in open source release.
// default value: false
#define DEBUG_ALLOW_ELO = false;

// When true, gives the host player a mirg2000 on spawn. If greater than 1, awards an upgraded mirg2000.
// default value: false
#define DEBUG_GIVE_MIRG = false;

// Bots will spawn with this level of wager tier completed automatically.
// default value: 0
#define DEBUG_WAGER_FX = 0;

// When true, bots may not move
// default value: false
#define DEBUG_BOTS_FREEZE = false;

// When true, spawns the ZBR icon in game on the host player
// default value: false
#define DEV_ICON_CAPTURE = false;

// When true, forces wagers to be disabled
// default value: false
#define DEV_NO_WAGERS = false;

#endregion

// add your custom maps here
custom_maps()
{
    switch(level.script)
    {
        case "zm_custom_map_name":
            // Fill in your spawn locations here. 
            // Entries should be zones with player spawners. 
            // Number of entries must be >= level.players.size, or things will get weird.
            level.gm_spawns[level.gm_spawns.size] = "zone_1";
            level.gm_spawns[level.gm_spawns.size] = "zone_2";
            level.gm_spawns[level.gm_spawns.size] = "zone_3";
            level.gm_spawns[level.gm_spawns.size] = "zone_4";

            // blacklist any zones you dont want players to spawn in here
            level.gm_blacklisted[level.gm_blacklisted.size] = "boss_arena_zone";
            level.gm_blacklisted[level.gm_blacklisted.size] = "bad_zone";
            
            // implement any gameplay scripting related to the map (ie: enabling PAP, unlocking places, etc.)
            // thread zm_custom_map_name_init();
            break;
        default:
            // TODO: autogenerate spawn locations per map
            return;
    }
}

// runs on player spawn, intented to be used for custom weapon monitors.
custom_weapon_callbacks()
{
    switch(level.script)
    {
        case "my_custom_map":
            // implement any special weapon callbacks here
            break;
        default:
            return;
    }
}
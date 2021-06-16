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

// Defines the percent reduction for zombie damage when a round resets, and inversely, the percent to increase zombie damage when the global scalar is not 100%. This is also the damage increase players receive against zombies when a round resets, etc.
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
// default value: 0.1
#define BGB_FROZEN_DAMAGE_REDUX = 0.1;

// Percent of health to do as damage to anyone marked during killing time
// default value: 0.2
#define BGB_KILLINGTIME_MARKED_PCT = 0.2;

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

// Number of seconds that the round may have fewer than 5 AI active before all ai will die and the round will advance.
// default value: 60
#define ROUND_NO_AI_TIMEOUT = 60;

// Damage per second of the genesis turret, scaled by the round number
// default value: 5000
#define GENESIS_TURRET_DPS = 5000;

// Defines the root damage percent taken from lightning staff damage
// default value: 0.0
#define STAFF_LIGHTNING_NERF_PCT_MIN = 0.0;

// Defines the max damage percent taken from lightning staff damage, after rapid shots.
// default value: 0.60
#define STAFF_LIGHTNING_NERF_PCT_MAX = 0.60;

// Defines the number of lightning staff shots to achieve max nerf percent
// default value: 3
#define STAFF_LIGHTNING_NERF_NUMSHOTS = 3;

// Defines the number of seconds to wait before restoring lightning staff damage. Only resets when a player is not firing.
// default value: 1.0
#define STAFF_LIGHTNING_NERF_REGEN_DELAY = 1.0;

// Defines the movement speed boost given to players in a losing state against an objective holder
// default value: 1.15
#define GM_MOVESPEED_BOOSTER_MP = 1.15;

// Time, in seconds, that fear in the headlights is active
// default value: 30
#define BGB_FITH_ACTIVE_TIME = 30;

// If true, will enable early spawns for players who are defeated during a round
// default value: false
#define USE_MIDROUND_SPAWNS = true;

// Defines the time in seconds to wait before attempting to respawn a player mid round. Requires USE_MIDROUND_SPAWNS = true
// default value: 120
#define PLAYER_MIDROUND_RESPAWN_DELAY = 120;

// Defines the percent of range forgiveness given to a thundergun shot when calculating its expected damage
// default value: 0.05
#define THUNDERGUN_FORGIVENESS_PCT = 0.05;

// Time in seconds that a player will be forced to prone when bgb crawlspace is used.
// default value: 3
#define BGB_CRAWL_SPACE_TIME = 3;

// Percent to reduce spawn points by when a player dies with phoenix up
// default value: 0.35
#define BGB_PHOENIX_SPAWN_REDUCE_POINTS = 0.35;

// Amount of points to give per activation of extra credit
// default value: 2500
#define BGB_EXTRA_CREDIT_VALUE = 2500;

// Percent to reduce spawn points by when a player goes down with coagulant
// default value: 0.5
#define BGB_COAGULANT_SPAWN_REDUCE_POINTS = 0.5;

// Scalar to apply for damage done to zombies when a player has the arms grace effect active
// default value: 5.0
#define BGB_ARMS_GRACE_ZM_DMG = 5.0;

// Time in seconds that the arms grace effect will be active after respawning
// default value: 60
#define BGB_ARMS_GRACE_DURATION = 60;

// Scalar to apply for damage done to players when a player has the arms grace effect active
// default value: 1.25
#define BGB_ARMS_GRACE_PVP_DMG = 1.25;

// Defines the amount of points, scaled by the round number, to award players who purchase a perk with unquenchable
// default value: 250
#define BGB_UNQUENCHABLE_CASHBACK_RD = 250;

#endregion

///////////////////////////
// Static Math variables //
///////////////////////////
#region NONTUNABLES

// linear calculation of step delta for lightning nerf
#define STAFF_LIGHTNING_NERF_PCT_STEP = (STAFF_LIGHTNING_NERF_PCT_MAX - STAFF_LIGHTNING_NERF_PCT_MIN) / max(STAFF_LIGHTNING_NERF_NUMSHOTS, 1);

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
#define DEV_EXIT = true;

// When true, sets the host player to become invulnerable
// default value: false
#define DEV_GODMODE = false;

// When true, gives the host player 25000 starting points
// default value: false
#define DEV_POINTS = true;

// When true, gives all players 25000 starting points
// default value: false
#define DEV_POINTS_ALL = true;

// When true, spawns in 3 test clients. NOTE: on any map with spiders, this option will cause a fatal crash within 3 rounds.
// default value: false
#define DEV_BOTS = true;

// When true, dev bots are ignored by zombies and take no damage from them
// default value: false
#define DEV_BOTS_IGNORE_ZM_DMG = true;

// When true, enables development hud features
// default value: false
#define DEV_HUD = true;

// When true, creates a dev hud for the current zone
// default value: false
#define DEBUG_ZONE = true;

// When true, iprints the closes poi spawn to the player's origin and blacklist status
// default value: false
#define DEBUG_POI_SPAWNER = false;

// When true, spawns a model at each spawn location in the map
// default value: false
#define DEV_ZONE_SPAWNERS = false;

// When true, allows the host to fly with the grenade button and sprint
// default value: false
#define DEV_NOCLIP = true;

// When true, allows the host player to see enemy players through walls
// default value: false
#define DEV_SIGHT = true;

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
#define DEBUG_BOTS_FREEZE = true;

// When true, spawns the ZBR icon in game on the host player
// default value: false
#define DEV_ICON_CAPTURE = false;

// When true, forces wagers to be disabled
// default value: false
#define DEV_NO_WAGERS = false;

// When true, forces host to spawn with a tesla gun
// default value: false
#define DEBUG_TESLA_GUN = false;

// When true, the host can hold ads and melee to teleport a random bot to them.
// default value: false
#define DEBUG_BOT_TELEPORT = false;

// When true, the host can hold ads and melee to kick a random bot
// default value: false
#define DEBUG_BOT_KICK = false;

// When true, poi spawn system will be enabled by default
// default value: false
#define DEV_FORCE_POI_SPAWNS = false;

// When true, all PAP machines will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_PAP_ANGLES = false;

// When true, all mystery boxes will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_BOX_ANGLES = false;

// When true, all wall weapons will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_WALL_ANGLES = false;

// When true, all perks will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_PERK_ANGLES = false;

// When true, all gum machines will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_GUM_ANGLES = false;

// When true, the host can pickup entities by using their ads button
// default value: false
#define DEV_FORGEMODE = false;

// When true, the host player will see normal spectator screen
// default: false;
#define DEV_DISABLE_HOST_SPEC_FIX = false;

#endregion

// add your custom maps here
// NOTE: Most custom maps are made by devs who only add 1 zone, or only put spawns in 1 zone.
//       this means that to generate spawns on this map, I have to do some really annoying nav query stuff that produces 
//       weird artifacts sometimes and may not be 100% reliable. 
//       If you are a map creator and enjoy this game mode,
//       make sure you take the time to place player spawns. They are kind of important.
//       
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

            // if your map needs a POI spawn generation (auto-spawns), invoke this.
            // gm_generate_spawns();
        break;

        case "zm_kyassuruz":
            // blocks the pap room which is locked behind quest objectives on this map
            level.gm_blacklisted[level.gm_blacklisted.size] = "third_zoneb";

            // auto open PAP
            arr = [
                getent("pap_door_dragon", "targetname"),
                getent("pap_door", "targetname"),
                getent("pap_door_clip", "targetname")
            ];
            if(isdefined(arr))
            {
                foreach(ent in arr)
                {
                    if(!isdefined(ent)) continue;
                    ent connectPaths();
                    ent delete();
                }
            }

            // open the shield room
            shield_room_door = getent("door_shield", "targetname");
            if(isdefined(shield_room_door))
            {
                shield_room_door delete();
            } 
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_diner":
            arr = getentarray("ee_pap_gen_reward_door", "targetname");
            if(isdefined(arr))
            {
                foreach(ent in arr)
                {
                    ent connectPaths();
                    ent delete();
                }
            }
            unlock_all_debris();
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_testlevel":
            // blocks an out of map spot where cherry is at.
            level.gm_blacklisted[level.gm_blacklisted.size] = "teleporter_zone";
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_terminal":
            ents = ["auto374", "auto373", "grow_soul2_door"];
            foreach(ent in ents)
            {
                _ent = getent(ent, "targetname");
                if(isdefined(_ent))
                {
                    _ent delete();
                }
            }
            unlock_all_debris();
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_loweffortkappa":
            ent = getent("pap_door", "targetname");
            if(isdefined(ent))
            {
                ent delete();
            }
            unlock_all_debris();
            open_all_doors();
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_pdp_dungeon":
            open_all_doors();
            str_prefix = "electric_door_";
            a_str_values = ["a", "b", "c", "d"];
            for(i = 0; i < a_str_values.size; i++)
            {
                str_value = str_prefix + a_str_values[i];
                ents = getentarray(str_value, "targetname");
                for(j = 0; j < ents.size; j++)
                {
                    ents[j] delete();
                }
            }
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_spring_breakers":
            unlock_all_debris();
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;

        case "zm_family_guy":
            unlock_all_debris();
            gm_generate_spawns(); // generate spawn points for this map, using the POI system
        break;
        
        default:
            gm_generate_spawns();
        return;
    }
}

// a list of terms, which if found in a zone name, automatically blacklists the zone from allowing spawns
// Note: due to performance reasons, you probably dont want to make this list too big.
get_blacklist_zone_terms()
{
    return array
    (
        "boss",
        "arena",
        "egg",
        "secret",
        "fight"
    );
}

// a list of zone names, that when encountered, are automatically blacklisted
get_additional_blacklist()
{
    return [];
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

// runs after blackscreen is passed, one time.
custom_weapon_init()
{
    switch(level.script)
    {
        case "zm_xmas_rust":
        arrayremoveindex(level.zombie_weapons, getweapon("h1_ranger"), true);
        break;
    }
}

// runs after default roundnext
custom_round_next()
{

}

gm_adjust_custom_weapon(w_weapon, f_result, n_mod_dmg, i_originalDamage, str_meansofdeath = "MOD_NONE", e_attacker = undefined)
{
    // implement any additional weapon weapon damage scalars here
    // you can return a float because the damage callback will automatically 
    if(level.script == "zm_kyassuruz")
    {
        if(issubstr(w_weapon.rootweapon.name, "bow"))
        {
            if(str_meansofdeath == "MOD_PROJECTILE_SPLASH")
            {
                return 1100 * level.round_number;
            }
            return 2100 * level.round_number;
        }
    }

    if(level.script == "zm_xmas_rust")
    {
        // tune stac/m82 because it fires shotgun like shots when pap'd. 3 projectiles, 6 w/ doubletap.
        if(w_weapon.rootweapon.name == "h1_stac_up" || w_weapon.rootweapon.name == "h1_m82a1_up")
        {
            return f_result / 6;
        }
    }
    
    // correction heuristic for explosives in custom maps. This is not perfect.
    is_explosive = str_meansofdeath == "MOD_PROJECTILE" || str_meansofdeath == "MOD_PROJECTILE_SPLASH" || str_meansofdeath == "MOD_GRENADE" || str_meansofdeath == "MOD_GRENADE_SPLASH" || str_meansofdeath == "MOD_EXPLOSIVE";
    if(is_explosive && n_mod_dmg == 75)
    {
        return i_originalDamage * (f_result / n_mod_dmg);
    }

    return f_result; // return a float or an int, representing the final damage to do. Only applies to players.
}
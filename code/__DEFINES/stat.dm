/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS 0
#define SOFT_CRIT 1
#define UNCONSCIOUS 2
#define HARD_CRIT 3
#define DEAD 4

//Health Defines
#define HEALTH_THRESHOLD_CRIT 0 //! Soft crit
#define HEALTH_THRESHOLD_FULLCRIT -100 //! Hard crit
#define HEALTH_THRESHOLD_DEAD -200

/// The amount of damage a mob can take past that which would kill it, per damage type.
#define HEALTH_OVERKILL_DAMAGE_PER_TYPE 0
/// The maximum amount of damage a mob can take per damage type (carbon brute/burn excluded). This will always result in just enough to kill you if overkill is 0.
#define HEALTH_LOSS_PER_TYPE_CAP(mob) (mob.maxHealth + ((-1 * HEALTH_THRESHOLD_DEAD) + HEALTH_OVERKILL_DAMAGE_PER_TYPE))

#define HEALTH_THRESHOLD_NEARDEATH -150 //Not used mechanically, but to determine if someone is so close to death they hear the other side

//Maximum healthiness an individual can have
#define MAX_SATIETY 600
///The rate at which satiation decays per second.
#define SATIETY_DECAY 0.2 //Max satiety lasts 25 minutes, 600 * 5
///The rate at which satiation decays per second.
#define HUNGER_DECAY 0.04
///How much hunger is lost on moving (walk)
#define HUNGER_LOSS_WALK 0.005
///How much hunger is lost on moving (run)
#define HUNGER_LOSS_RUN 0.01

#define ETHEREAL_CHARGE_FACTOR 0.8 //factor at which ethereal's charge decreases per second
#define REAGENTS_METABOLISM 0.2 //How many units of reagent are consumed per second, by default.
// bitflags for machine stat variable
#define BROKEN (1<<0)
#define NOPOWER (1<<1)
#define MAINT (1<<2) // under maintaince
#define EMPED (1<<3) // temporary broken by EMP pulse

//ai power requirement defines
#define POWER_REQ_ALL 1

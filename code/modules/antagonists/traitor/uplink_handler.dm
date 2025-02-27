/**
 * Uplink Handler
 *
 * The uplink handler, used to handle a traitor's TC and experience points and the uplink UI.
**/
/datum/uplink_handler
	/// The owner of this uplink handler.
	var/datum/mind/owner
	/// The amount of telecrystals contained in this traitor has
	var/telecrystals = 0
	/// The current uplink flag of this uplink
	var/uplink_flag = NONE
	/// This uplink has progression
	var/has_progression = FALSE //PARIAH EDIT
	/// The amount of experience points this traitor has
	var/progression_points = 0
	/// The purchase log of this uplink handler
	var/datum/uplink_purchase_log/purchase_log
	/// Associative array of uplink item = stock left
	var/list/item_stock = list()
	/// Extra stuff that can be purchased by an uplink, regardless of flag.
	var/list/extra_purchasable = list()
	/// Whether this uplink handler has objectives.
	var/has_objectives = FALSE
	/// Whether this uplink handler can TAKE objectives.
	var/can_take_objectives = FALSE
	/// The maximum number of objectives that can be taken
	var/maximum_active_objectives = 2
	/// The maximum number of potential objectives that can exist.
	var/maximum_potential_objectives = 6
	/// Current objectives taken
	var/list/active_objectives = list()
	/// Potential objectives that can be taken
	var/list/potential_objectives = list()
	/// Objectives that have been completed.
	var/list/completed_objectives = list()
	/// All objectives assigned by type to handle any duplicates
	var/list/potential_duplicate_objectives = list()
	/// The role that this uplink handler is associated to.
	var/assigned_role
	/// The species this uplink handler is associated to.
	var/assigned_species
	/// Whether this is in debug mode or not. If in debug mode, allows all purchases
	var/debug_mode = FALSE

/datum/uplink_handler/New()
	. = ..()
	maximum_potential_objectives = CONFIG_GET(number/maximum_potential_objectives)

/// Called whenever an update occurs on this uplink handler. Used for UIs
/datum/uplink_handler/proc/on_update()
	SEND_SIGNAL(src, COMSIG_UPLINK_HANDLER_ON_UPDATE)
	return

/// Checks if traitor has enough reputation to purchase an item
/datum/uplink_handler/proc/not_enough_reputation(datum/uplink_item/to_purchase)
	return has_progression && progression_points < to_purchase.progression_minimum

/// Checks for uplink flags as well as items restricted to roles and species
/datum/uplink_handler/proc/check_if_restricted(datum/uplink_item/to_purchase)
	if((to_purchase in extra_purchasable))
		return TRUE
	if(!(to_purchase.purchasable_from & uplink_flag))
		return FALSE
	if(length(to_purchase.restricted_roles) && !(assigned_role in to_purchase.restricted_roles))
		return FALSE
	if(length(to_purchase.restricted_species) && !(assigned_species in to_purchase.restricted_species))
		return FALSE
	return TRUE

/datum/uplink_handler/proc/can_purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(debug_mode)
		return TRUE

	if(!check_if_restricted(to_purchase))
		return FALSE

	var/current_stock = item_stock[to_purchase]
	var/stock = current_stock != null? current_stock : INFINITY
	if(telecrystals < to_purchase.cost || stock <= 0 || (has_progression && progression_points < to_purchase.progression_minimum))
		return FALSE

	return TRUE

/datum/uplink_handler/proc/purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(!can_purchase_item(user, to_purchase))
		return

	if(to_purchase.limited_stock != -1 && !(to_purchase in item_stock))
		item_stock[to_purchase] = to_purchase.limited_stock

	telecrystals -= to_purchase.cost
	to_purchase.purchase(user, src)

	if(to_purchase in item_stock)
		item_stock[to_purchase] -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(to_purchase.name)]", "[to_purchase.cost]"))
	on_update()
	return TRUE

/// Generates objectives for this uplink handler
/datum/uplink_handler/proc/generate_objectives()
	var/potential_objectives_left = maximum_potential_objectives - (length(potential_objectives) + length(active_objectives))
	var/list/objectives = SStraitor.category_handler.get_possible_objectives(progression_points)
	if(!length(objectives))
		return
	while(length(objectives) && potential_objectives_left > 0)
		var/objective_typepath = pick_weight(objectives)
		var/list/target_list = objectives
		while(islist(objective_typepath))
			if(!length(objective_typepath))
				// Need to wrap this in a list or else it list unrolls and the list doesn't actually get removed.
				// Thank you byond, very cool!
				target_list -= list(objective_typepath)
				break
			target_list = objective_typepath
			objective_typepath = pick_weight(objective_typepath)
		if(islist(objective_typepath) || !objective_typepath)
			continue
		if(!try_add_objective(objective_typepath))
			target_list -= objective_typepath
			continue
		potential_objectives_left--
	on_update()

/datum/uplink_handler/proc/try_add_objective(datum/traitor_objective/objective_typepath)
	var/datum/traitor_objective/objective = new objective_typepath(src)
	var/should_abort = SEND_SIGNAL(objective, COMSIG_TRAITOR_OBJECTIVE_PRE_GENERATE, owner, potential_duplicate_objectives[objective_typepath]) & COMPONENT_TRAITOR_OBJECTIVE_ABORT_GENERATION
	if(should_abort || !objective.generate_objective(owner, potential_duplicate_objectives[objective_typepath]))
		qdel(objective)
		return
	if(!handle_duplicate(objective))
		qdel(objective)
		return
	log_traitor("[key_name(owner)] has received a potential objective: [objective.to_debug_string()]")
	objective.original_progression = objective.progression_reward
	objective.update_progression_reward()
	potential_objectives += objective
	return objective

/datum/uplink_handler/proc/handle_duplicate(datum/traitor_objective/potential_duplicate)
	if(!istype(potential_duplicate))
		return FALSE

	var/datum/traitor_objective/current_type = potential_duplicate.type
	var/list/added_types = list()
	while(current_type != /datum/traitor_objective)
		if(!potential_duplicate_objectives[current_type])
			potential_duplicate_objectives[current_type] = list(potential_duplicate)
		else
			for(var/datum/traitor_objective/duplicate_checker as anything in potential_duplicate_objectives[current_type])
				if(duplicate_checker.is_duplicate(potential_duplicate))
					for(var/typepath in added_types)
						potential_duplicate_objectives[typepath] -= potential_duplicate
					return FALSE
			potential_duplicate_objectives[current_type] += potential_duplicate

		added_types += current_type
		current_type = type2parent(current_type)
	return TRUE

/datum/uplink_handler/proc/get_completion_count(datum/traitor_objective/type)
	var/amount_completed = 0
	for(var/datum/traitor_objective/objective as anything in potential_duplicate_objectives[type])
		if(objective.objective_state == OBJECTIVE_STATE_COMPLETED)
			amount_completed += 1
	return amount_completed

/datum/uplink_handler/proc/get_completion_progression(datum/traitor_objective/type)
	var/total_progression = 0
	for(var/datum/traitor_objective/objective as anything in completed_objectives)
		if(objective.objective_state == OBJECTIVE_STATE_COMPLETED)
			total_progression += objective.progression_reward
	return total_progression

/// Used to complete objectives, failed or successful.
/datum/uplink_handler/proc/complete_objective(datum/traitor_objective/to_remove)
	if(to_remove in completed_objectives)
		return

	potential_objectives -= to_remove
	active_objectives -= to_remove
	completed_objectives += to_remove
	update_objectives()
	generate_objectives()

/// Updates the objectives on the uplink and deletes
/datum/uplink_handler/proc/update_objectives()
	var/list/objectives_copy = potential_objectives + active_objectives
	for(var/datum/traitor_objective/objective as anything in objectives_copy)
		if(progression_points > objective.progression_maximum && !objective.forced && objective.objective_state != OBJECTIVE_STATE_ACTIVE)
			objective.fail_objective(trigger_update = FALSE)
			continue
		objective.update_progression_reward()

/datum/uplink_handler/proc/abort_objective(datum/traitor_objective/to_abort)
	if(istype(to_abort, /datum/traitor_objective/final))
		return
	if(to_abort.objective_state != OBJECTIVE_STATE_ACTIVE)
		return
	to_abort.fail_objective(penalty_cost = to_abort.telecrystal_penalty)

/datum/uplink_handler/proc/take_objective(mob/user, datum/traitor_objective/to_take)
	if(!(to_take in potential_objectives))
		return

	user.playsound_local(get_turf(user), 'sound/traitor/objective_taken.ogg', vol = 100, vary = FALSE, channel = CHANNEL_TRAITOR)
	to_take.on_objective_taken(user)
	to_take.objective_state = OBJECTIVE_STATE_ACTIVE
	potential_objectives -= to_take
	active_objectives += to_take
	on_update()

/datum/uplink_handler/proc/ui_objective_act(mob/user, datum/traitor_objective/to_act_on, action)
	if(!(to_act_on in active_objectives))
		return
	if(to_act_on.objective_state != OBJECTIVE_STATE_ACTIVE)
		return

	to_act_on.ui_perform_action(user, action)

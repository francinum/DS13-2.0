/obj/item/clothing/head/mod
	name = "RIG helmet"
	desc = "A helmet for a RIG."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "helmet"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 0)
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	obj_flags = IMMUTABLE_SLOW
	var/alternate_layer = NECK_LAYER

/obj/item/clothing/suit/mod
	name = "RIG chestplate"
	desc = "A chestplate for a RIG."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "chestplate"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 0)
	body_parts_covered = CHEST|GROIN
	heat_protection = CHEST|GROIN
	cold_protection = CHEST|GROIN
	obj_flags = IMMUTABLE_SLOW

/obj/item/clothing/gloves/mod
	name = "RIG gauntlets"
	desc = "A pair of gauntlets for a RIG."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "gauntlets"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 0)
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	obj_flags = IMMUTABLE_SLOW

/obj/item/clothing/shoes/mod
	name = "RIG boots"
	desc = "A pair of boots for a RIG."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "boots"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 0)
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	obj_flags = IMMUTABLE_SLOW
	item_flags = IGNORE_DIGITIGRADE
	can_be_tied = FALSE

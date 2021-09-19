local mod_name = "arkhan_scrap_upgrades";

local All_Upgrades = {
	"tmb_balefire_magics_ethereal_frostbite_attacks",
	"tmb_balefire_magics_skeleton_nehekharan_tomb_weapons",
	"tmb_balefire_magics_skeleton_nehekharan_tomb_armour",
	"tmb_balefire_magics_skeleton_nehekharan_tomb_relics",
	"tmb_balefire_magics_skeleton_nehekharan_tomb_banners",
	"tmb_balefire_magics_necro_warsphinx_heirotitan_weapons",
	"tmb_balefire_magics_necro_warsphinx_heirotitan_armour",
	"tmb_balefire_magics_necro_warsphinx_heirotitan_relics",
	"tmb_balefire_magics_tier_1_unending_quivers",
	"tmb_balefire_magics_tier_2_enchanted_arrows",
	"tmb_balefire_magics_bats_carrion_dire_weapons",
	"tmb_balefire_magics_bats_carrion_dire_armour",
	"tmb_balefire_magics_bats_carrion_dire_relics",
	"tmb_balefire_magics_tier_1_enchanted_arrows",
	"tmb_balefire_magics_screaming_skull_tier_1",
	"tmb_balefire_magics_screaming_skull_tier_2",
	"tmb_balefire_magics_screaming_skull_tier_3",
	"tmb_balefire_magics_casket_of_souls_tier_1",
	"tmb_balefire_magics_casket_of_souls_tier_2",
	"tmb_balefire_magics_casket_of_souls_tier_3",
	"tmb_balefire_magics_cavalry_tier_1",
	"tmb_balefire_magics_cavalry_tier_2",
	"tmb_balefire_magics_cavalry_tier_3",
	"tmb_balefire_magics_archers_tier_1",
	"tmb_balefire_magics_archers_tier_2",
	"tmb_balefire_magics_archers_tier_3",
	"tmb_balefire_magics_ushabti_tier_1",
	"tmb_balefire_magics_ushabti_tier_2",
	"tmb_balefire_magics_ushabti_tier_3",
	"tmb_balefire_magics_ushabti_missile_tier_1",
	"tmb_balefire_magics_ushabti_missile_tier_2",
	"tmb_balefire_magics_scorpion_tier_1",
	"tmb_balefire_magics_scorpion_tier_2",
	"tmb_balefire_magics_scorpion_tier_3",
	"tmb_balefire_magics_sepulchral_tier_1",
	"tmb_balefire_magics_sepulchral_tier_2",
	"tmb_balefire_magics_sepulchral_tier_3",
	"tmb_balefire_magics_necropolis_tier_1",
	"tmb_balefire_magics_necropolis_tier_2",
	"tmb_balefire_magics_necropolis_tier_3"
};

local tomb_king_subc = "wh2_dlc09_sc_tmb_tomb_kings";

local faction_exclusive_available = {
	"wh2_dlc09_tmb_followers_of_nagash",
	"wh2_dlc09_tmb_khemri",
	"wh2_dlc09_tmb_lybaras",
	"wh2_dlc09_tmb_exiles_of_nehek"

};

local faction_exclusive_upgrade_index = {
	["wh2_dlc09_tmb_followers_of_nagash"] = "tmb_balefire_magics_arkhan_unique",
	["wh2_dlc09_tmb_khemri"] = "tmb_balefire_magics_settra_unique",
	["wh2_dlc09_tmb_lybaras"] = "tmb_balefire_magics_khalida_unique",
	["wh2_dlc09_tmb_exiles_of_nehek"] = "tmb_balefire_magics_khatep_unique"
};

local locked_upgrades = {};

--this defines the interval we check and apply upgrade to AI
local cooldown = 15

local function tomb_king_scrap_upgrades()
	out("#### Adding Unit Upgrade Listeners ####");
	--locks everything at beginning of campaign, this only applies to	player now, we are giving AI free scrap upgrades every now and then
	core:add_listener(
		"STEPHEN_upgrade_lock_techs",
		"FactionTurnStart",
		function(context)
			return context:faction():subculture() == tomb_king_subc and context:faction():is_human();
		end,
		function(context)
			local faction = context:faction();
			local faction_key = faction:name();

			if not check_element_in_table(faction_key, locked_upgrades) then
				for i = 1, #Upgrade_tech_keys do
					for j = 1, #Upgrade_techs[Upgrade_tech_keys[i]] do
						cm:faction_set_unit_purchasable_effect_lock_state(faction, Upgrade_techs[Upgrade_tech_keys[i]][j],
						Upgrade_techs[Upgrade_tech_keys[i]][j], true);
					end
				end
				table.insert(locked_upgrades, faction_key);
			end
			--lock faction specific upgrades
			for i = 1, #faction_exclusive_available do
				if faction_key ~= faction_exclusive_available[i] then
					cm:faction_set_unit_purchasable_effect_lock_state(faction, faction_exclusive_upgrade_index[faction_exclusive_available[i]], "", true);
				end
			end
			if faction:has_technology("tech_dlc09_tmb_legions_of_legend") then
				cm:faction_add_pooled_resource(faction_key, "tmb_canopic_jars", "canopic_jars_mortuary_cult", 10);
			end
		end,
		true
	);

	--unlocks the upgrade based on faction
	core:add_listener(
		"STEPHEN_unit_upgrade_tech_tmb",
		"ResearchCompleted",
		function(context)
			return context:faction():subculture() == tomb_king_subc and context:faction():is_human();
		end,
		function(context)
			local tech = context:technology();
			if Upgrade_techs[tech] then
				for i = 1 , #Upgrade_techs[tech] do
					cm:faction_set_unit_purchasable_effect_lock_state(context:faction(), Upgrade_techs[tech][i], Upgrade_techs[tech][i], false);
				end
			end
		end,
		true
	);

	-- Automatically Upgrade AI Units at set intervals
	core:add_listener(
		"STEPHEN_turn_start_upgrade_units",
		"FactionTurnStart",
		function(context)
			return context:faction():subculture() == tomb_king_subc and context:faction():is_human() == false;
		end,
		function(context)
			local turn = cm:model():turn_number();
			local tmb_interface = context:faction();
			local tmb_force_list = tmb_interface:military_force_list();

			if turn % cooldown == 0 then

				for l = 1, #faction_exclusive_available do
					if tmb_interface:name() ~= faction_exclusive_available[l] then
						cm:faction_set_unit_purchasable_effect_lock_state(context:faction(), faction_exclusive_upgrade_index[faction_exclusive_available[l]], "", true);
					end
				end
				for i = 0, tmb_force_list:num_items() - 1 do
					local tmb_force = tmb_force_list:item_at(i);
					local unit_list = tmb_force:unit_list();

					for j = 0, unit_list:num_items() - 1 do
						local unit_interface = unit_list:item_at(j);
						local unit_purchasable_effect_list = unit_interface:get_unit_purchasable_effects();
						if unit_purchasable_effect_list:num_items() ~=0 then
							local rand = cm:random_number(unit_purchasable_effect_list:num_items()) -1;
							local effect_interface = unit_purchasable_effect_list:item_at(rand);
							-- Upgrade the unit
							if tmb_force:is_armed_citizenry() == false then
								cm:faction_purchase_unit_effect(context:faction(), unit_interface, effect_interface);
							end
						end
					end

				end
			end

		end,
		true
	);

end


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value(mod_name .. "locked_upgrades", locked_upgrades, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			locked_upgrades = cm:load_named_value(mod_name .. "locked_upgrades", locked_upgrades, context);
		end
	end
);

cm:add_first_tick_callback(
		function(context)
			tomb_king_scrap_upgrades();
		end
);
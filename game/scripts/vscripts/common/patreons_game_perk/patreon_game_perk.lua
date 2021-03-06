local perksTierPatreon = {
	["patreon_perk_mp_regen_t0"] = 0,
	["patreon_perk_mp_regen_t1"] = 1,
	["patreon_perk_mp_regen_t2"] = 2,
	["patreon_perk_hp_regen_t0"] = 0,
	["patreon_perk_hp_regen_t1"] = 1,
	["patreon_perk_hp_regen_t2"] = 2,
	["patreon_perk_bonus_movespeed_t0"] = 0,
	["patreon_perk_bonus_movespeed_t1"] = 1,
	["patreon_perk_bonus_movespeed_t2"] = 2,
	["patreon_perk_bonus_agi_t0"] = 0,
	["patreon_perk_bonus_agi_t1"] = 1,
	["patreon_perk_bonus_agi_t2"] = 2,
	["patreon_perk_bonus_str_t0"] = 0,
	["patreon_perk_bonus_str_t1"] = 1,
	["patreon_perk_bonus_str_t2"] = 2,
	["patreon_perk_bonus_int_t0"] = 0,
	["patreon_perk_bonus_int_t1"] = 1,
	["patreon_perk_bonus_int_t2"] = 2,
	["patreon_perk_bonus_all_stats_t0"] = 0,
	["patreon_perk_bonus_all_stats_t1"] = 1,
	["patreon_perk_bonus_all_stats_t2"] = 2,
	["patreon_perk_attack_range_t0"] = 0,
	["patreon_perk_attack_range_t1"] = 1,
	["patreon_perk_attack_range_t2"] = 2,
	["patreon_perk_bonus_hp_pct_t0"] = 0,
	["patreon_perk_bonus_hp_pct_t1"] = 1,
	["patreon_perk_bonus_hp_pct_t2"] = 2,
	["patreon_perk_cast_range_t0"] = 0,
	["patreon_perk_cast_range_t1"] = 1,
	["patreon_perk_cast_range_t2"] = 2,
	["patreon_perk_cooldown_reduction_t0"] = 0,
	["patreon_perk_cooldown_reduction_t1"] = 1,
	["patreon_perk_cooldown_reduction_t2"] = 2,
	["patreon_perk_damage_t0"] = 0,
	["patreon_perk_damage_t1"] = 1,
	["patreon_perk_damage_t2"] = 2,
	["patreon_perk_evasion_t0"] = 0,
	["patreon_perk_evasion_t1"] = 1,
	["patreon_perk_evasion_t2"] = 2,
	["patreon_perk_lifesteal_t0"] = 0,
	["patreon_perk_lifesteal_t1"] = 1,
	["patreon_perk_lifesteal_t2"] = 2,
	["patreon_perk_mag_resist_t0"] = 0,
	["patreon_perk_mag_resist_t1"] = 1,
	["patreon_perk_mag_resist_t2"] = 2,
	["patreon_perk_spell_amp_t0"] = 0,
	["patreon_perk_spell_amp_t1"] = 1,
	["patreon_perk_spell_amp_t2"] = 2,
	["patreon_perk_spell_lifesteal_t0"] = 0,
	["patreon_perk_spell_lifesteal_t1"] = 1,
	["patreon_perk_spell_lifesteal_t2"] = 2,
	["patreon_perk_status_resistance_t0"] = 0,
	["patreon_perk_status_resistance_t1"] = 1,
	["patreon_perk_status_resistance_t2"] = 2,
	["patreon_perk_outcomming_heal_amplify_t0"] = 0,
	["patreon_perk_outcomming_heal_amplify_t1"] = 1,
	["patreon_perk_outcomming_heal_amplify_t2"] = 2,
	["patreon_perk_debuff_time_t0"] = 0,
	["patreon_perk_debuff_time_t1"] = 1,
	["patreon_perk_debuff_time_t2"] = 2,
	["patreon_perk_bonus_gold_t0"] = 0,
	["patreon_perk_bonus_gold_t1"] = 1,
	["patreon_perk_bonus_gold_t2"] = 2,
	["patreon_perk_gpm_t0"] = 0,
	["patreon_perk_gpm_t1"] = 1,
	["patreon_perk_gpm_t2"] = 2,
};

for name in pairs(perksTierPatreon) do
	LinkLuaModifier( name, "common/patreons_game_perk/modifier_lib/"..name ,LUA_MODIFIER_MOTION_NONE )
end

_G.PlayersPatreonsPerk = {}

RegisterCustomEventListener("check_patreon_level_and_perks", function(data)
	local patreon = Patreons:GetPlayerSettings(data.PlayerID)
	local patreonLvl = patreon.level
	local currentPerk = _G.PlayersPatreonsPerk[data.PlayerID]
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "return_patreon_level_and_perks", {
		patreonLevel = patreonLvl,
		patreonCurrentPerk = currentPerk
	})
end)

RegisterCustomEventListener("set_patreon_game_perk", function(data)
	local playerID = data.PlayerID
	if not playerID then return end
	local player = PlayerResource:GetPlayer(playerID)
	local newModifierName = data.newPerkName
	local patreon = Patreons:GetPlayerSettings(playerID)
	local correctPerk = perksTierPatreon[newModifierName] and perksTierPatreon[newModifierName] <= patreon.level
	if not correctPerk then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "reload_patreon_perk_setings_button", {})
		return
	end
	local hero = player:GetAssignedHero()
	_G.PlayersPatreonsPerk[playerID] = newModifierName
	if hero then
		if hero:IsAlive() then
			hero:AddNewModifier(hero, nil, newModifierName, {duration = -1})
		else
			Timers:CreateTimer(0.5, function()
				if hero:IsAlive() then
					hero:AddNewModifier(hero, nil, newModifierName, {duration = -1})
					return nil
				end
				return 0.5
			end)
		end
	else
		Timers:CreateTimer(3, function()
			hero = player:GetAssignedHero()
			hero:AddNewModifier(hero, nil, newModifierName, {duration = -1})
		end)
	end
end)
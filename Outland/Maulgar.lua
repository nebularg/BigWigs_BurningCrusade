--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("High King Maulgar", 776)
if not mod then return end
--Maulgar, Krosh Firehand (Mage), Olm the Summoner (Warlock), Kiggler the Crazed (Shaman), Blindeye the Seer (Priest)
mod:RegisterEnableMob(18831, 18832, 18834, 18835, 18836)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Gronn are the real power in Outland!"

	L.heal_message = "Blindeye casting Prayer of Healing!"
	L.heal_bar = "<Healing!>"

	L.shield_message = "Shield on Blindeye!"

	L.spellshield_message = "Spell Shield on Krosh!"

	L.summon_message = "Felhunter being summoned!"
	L.summon_bar = "~Felhunter"

	L.whirlwind_message = "Maulgar - Whirlwind for 15sec!"
	L.whirlwind_warning = "Maulgar Engaged - Whirlwind in ~60sec!"

	L.mage = "Krosh Firehand (Mage)"
	L.warlock = "Olm the Summoner (Warlock)"
	L.priest = "Blindeye the Seer (Priest)"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		33152, 33147, 33054, 33131, 39144, 33238, 33232, "bosskill",
	}, {
		[33152] = L["priest"],
		[33054] = L["mage"],
		[33131] = L["warlock"],
		[39144] = self.displayName,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Shield", 33147)
	self:Log("SPELL_AURA_APPLIED", "SpellShield", 33054)
	self:Log("SPELL_AURA_APPLIED", "Whirlwind", 33238)
	self:Log("SPELL_CAST_START", "Summon", 33131)
	self:Log("SPELL_CAST_START", "Prayer", 33152)
	self:Log("SPELL_CAST_SUCCESS", "Smash", 39144)
	self:Log("SPELL_CAST_SUCCESS", "Flurry", 33232)

	self:Yell("Engage", L["engage_trigger"])
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 18831)
end

function mod:OnEngage()
	self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", nil, "target", "focus")

	self:Message(33238, L["whirlwind_warning"], "Attention", 33238)
	local ww = self:SpellName(33238)
	self:DelayedMessage(33238, 54, CL["soon"]:format(ww), "Urgent")
	self:Bar(33238, "~"..ww, 59, 33238)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Shield(args)
	self:Message(args.spellId, L["shield_message"], "Important", args.spellId)
end

function mod:SpellShield(args)
	if self:GetCID(args.destGUID) == 18832 then
		self:Message(args.spellId, L["spellshield_message"], "Attention", args.spellId, "Info")
		self:Bar(args.spellId, args.spellName, 30, args.spellId)
	end
end

function mod:Whirlwind(args)
	self:Message(args.spellId, L["whirlwind_message"], "Important", args.spellId)
	self:Bar(args.spellId, CL["cast"]:format(args.spellName), 15, args.spellId)
	self:DelayedMessage(args.spellId, 55, CL["soon"]:format(args.spellName), "Urgent")
	self:Bar(args.spellId, "~"..args.spellName, 60, args.spellId)
end

function mod:Summon(args)
	self:Message(args.spellId, L["summon_message"], "Attention", args.spellId, "Long")
	self:Bar(args.spellId, L["summon_bar"], 50, args.spellId)
end

function mod:Prayer(args)
	self:Message(args.spellId, L["heal_message"], "Important", args.spellId, "Alarm")
end

function mod:Smash(args)
	self:Bar(args.spellId, "~"..args.spellName, 10, args.spellId)
end

function mod:Flurry(args)
	self:Message(args.spellId, "50% - "..args.spellName, "Important", args.spellId)
end

function mod:UNIT_HEALTH_FREQUENT(unit)
	if self:GetCID(UnitGUID(unit)) == 18831 then
		local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
		if hp > 50 and hp < 57 then
			local flurry = self:SpellName(33232)
			self:Message(33232, CL["soon"]:format(flurry), "Positive", 33232)
			self:UnregisterUnitEvent("UNIT_HEALTH_FREQUENT", "target", "focus")
		end
	end
end


--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Kaz'rogal", 775)
if not mod then return end
mod:RegisterEnableMob(17888)

local count = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.mark_bar = "Mark (%d)"
	L.mark_warn = "Mark in 5 sec!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{31447, "PROXIMITY", "FLASH"}, "bosskill"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "MarkCast", 31447)
	self:Log("SPELL_AURA_APPLIED", "Mark", 31447)
	self:Log("SPELL_AURA_REMOVED", "MarkRemoved", 31447)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:Death("Win", 17888)
end

function mod:OnEngage()
	count = 1
	self:Bar(31447, L["mark_bar"]:format(count), 45, 31447)
	self:DelayedMessage(31447, 40, L["mark_warn"], "Positive")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MarkCast(args)
	local time = 45 - (count * 5)
	if time < 5 then time = 5 end
	self:Message(args.spellId, ("%s (%d)"):format(args.spellName, count), "Attention", args.spellId)
	count = count + 1
	self:Bar(args.spellId, L["mark_bar"]:format(count), time, args.spellId)
	self:DelayedMessage(args.spellId, time - 5, L["mark_warn"], "Positive")
end

function mod:Mark(args)
	if UnitIsUnit(args.destName, "player") then
		local power = UnitPower("player", 0)
		if power > 0 and power < 4000 then
			self:OpenProximity(args.spellId, 15)
			self:Flash(args.spellId)
		end
	end
end

function mod:MarkRemoved(args)
	if UnitIsUnit(args.destName, "player") then
		self:CloseProximity(args.spellId)
	end
end


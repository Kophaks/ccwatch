CCWatchLoaded = false

CCWatchObject = nil

CCWATCH_MAXBARS = 5

CCW_EWARN_FADED = 1
CCW_EWARN_APPLIED = 2
CCW_EWARN_BROKEN = 4
CCW_EWARN_LOWTIME = 8

CCWATCH_SCHOOL = {
	FIRE = { 1, 0, 0 },
	FROST = { 0, 0, 1 },
	NATURE = { 0, 1, 0 },
	SHADOW = { RAID_CLASS_COLORS.WARLOCK.r, RAID_CLASS_COLORS.WARLOCK.g, RAID_CLASS_COLORS.WARLOCK.b },
	ARCANE = { 1, 1, 1 },
	HOLY = { 1, 1, 0 },
	PHYSICAL = { RAID_CLASS_COLORS.DRUID.r, RAID_CLASS_COLORS.DRUID.g, RAID_CLASS_COLORS.DRUID.b },
	MAGIC = { 0, 1, 1 },
	NONE = { 1, 1, 1 },
}

-- CCWATCH_SCHOOL = {
-- 	NONE = {1, 1, 1},
-- 	PHYSICAL = {1, 1, 0},
-- 	HOLY = {1, .9, .5},
-- 	FIRE = {1, .5, 0},
-- 	NATURE = {.3, 1, .3},
-- 	FROST = {.5, 1, 1},
-- 	SHADOW = {.5, .5, 1},
-- 	ARCANE = {1, .5, 1},
-- }

local bars = {}

local function create_bar(name)
	local bar = {}
	bars[name] = bar

	local color = bar.color or {1, 0, 1}
	local bgcolor = {0, .5, .5, .5}
	local icon = bar.icon or nil
	local iconpos = 'LEFT'
	local texture = [[Interface\Addons\CCWatch\Textures\BantoBar]] -- [[Interface\TargetingFrame\UI-StatusBar]]
	local width = 200
	local height = 16
	local point = 'CENTER'
	local rframe = UIParent
	local rpoint = 'CENTER'
	local xoffset = 0
	local yoffset = 0
	local text = bar.text
	local fontsize = 11
	local textcolor = {1, 1, 1}
	local timertextcolor = {1, 1, 1}
	local scale = 1

	local timertextwidth = fontsize * 3.6
	local font, _, style = GameFontHighlight:GetFont()

	bar.fadetime = 1
	bar.width = 200
	bar.bgcolor = bgcolor
	bar.textcolor = textcolor
	bar.timertextcolor = timertextcolor

	local f = CreateFrame('Button', nil, UIParent)

	f:Hide()
	f.owner = name

	f:SetWidth(width + height)
	f:SetHeight(height)
	f:ClearAllPoints()
	f:SetPoint(point, rframe, rpoint, xoffset, yoffset)

	f:EnableMouse(false)
	f:RegisterForClicks()
	f:SetScript('OnClick', nil)
	f:SetScale(scale)

	f.icon = CreateFrame('Button', nil, f)
	f.icon:ClearAllPoints()
	f.icon.owner = name
	f.icon:EnableMouse(false)
	f.icon:RegisterForClicks()
	f.icon:SetScript('OnClick', nil)
	f.icon:SetHeight(height)
	f.icon:SetWidth(height)
	f.icon:SetPoint('LEFT', f, iconpos, 0, 0)
	f.icon:SetNormalTexture[[Interface\Icons\INV_Misc_QuestionMark]]
	f.icon:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
	f.icon:SetAlpha(1)
	f.icon:Show()

	f.statusbarbg = CreateFrame('StatusBar', nil, f)
	f.statusbarbg:SetFrameLevel(f.statusbarbg:GetFrameLevel() - 1)
	f.statusbarbg:ClearAllPoints()
	f.statusbarbg:SetHeight(height)
	f.statusbarbg:SetWidth(width)
	f.statusbarbg:SetPoint('TOPLEFT', f, 'TOPLEFT', height, 0)
	f.statusbarbg:SetStatusBarTexture(texture)
	f.statusbarbg:SetStatusBarColor(bgcolor[1], bgcolor[2], bgcolor[3], bgcolor[4])
	f.statusbarbg:SetMinMaxValues(0, 100)
	f.statusbarbg:SetValue(100)

	f.statusbar = CreateFrame('StatusBar', nil, f)
	f.statusbar:ClearAllPoints()
	f.statusbar:SetHeight(height)
	f.statusbar:SetWidth(width)
	f.statusbar:SetPoint('TOPLEFT', f, 'TOPLEFT', height, 0)
	f.statusbar:SetStatusBarTexture(texture)
	f.statusbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
	f.statusbar:SetMinMaxValues(0, 1)
	f.statusbar:SetValue(1)

	f.spark = f.statusbar:CreateTexture(nil, 'OVERLAY')
	f.spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
	f.spark:SetWidth(16)
	f.spark:SetHeight(height + 25)
	f.spark:SetBlendMode'ADD'
	f.spark:Show()

	f.timertext = f.statusbar:CreateFontString(nil, 'OVERLAY')
	f.timertext:SetFontObject(GameFontHighlight)
	f.timertext:SetFont(font, fontsize, style)
	f.timertext:SetHeight(height)
	f.timertext:SetWidth(timertextwidth)
	f.timertext:SetPoint('LEFT', f.statusbar, 'LEFT', 0, 0)
	f.timertext:SetJustifyH'RIGHT'
	f.timertext:SetText''
	f.timertext:SetTextColor(timertextcolor[1], timertextcolor[2], timertextcolor[3], timertextcolor[4])

	f.text = f.statusbar:CreateFontString(nil, 'OVERLAY')
	f.text:SetFontObject(GameFontHighlight)
	f.text:SetFont(font, fontsize, style)
	f.text:SetHeight(height)
	f.text:SetWidth((width - timertextwidth) * .9)
	f.text:SetPoint('RIGHT', f.statusbar, 'RIGHT', 0, 0)
	f.text:SetJustifyH'LEFT'
	f.text:SetText(text)
	f.text:SetTextColor(textcolor[1], textcolor[2], textcolor[3], textcolor[4])

	if bar.onclick then
		f:EnableMouse(true)
		f:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
		f:SetScript('OnClick', function()
			CandyBar:OnClick()
		end)
		f.icon:EnableMouse(true)
		f.icon:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
		f.icon:SetScript('OnClick', function()
			CandyBar:OnClick()
		end)
	end

	bar.frame = f	
	return f
end

local function fade_bar(name)
	local bar = bars[name]

	if bar.fadeelapsed > bar.fadetime then
		bar.frame:Hide()
		bar.frame:SetAlpha(0)
	else
		local t = bar.fadetime - bar.fadeelapsed
		local a = t / bar.fadetime
		bar.frame:SetAlpha(a)
	end
end

local function format_time(t)
	local h = floor(t / 3600)
	local m = floor((t - h * 3600) / 60)
	local s = t - (h * 3600 + m * 60)
	if h > 0 then
		return format('%d:%02d', h, m)
	elseif m > 0 then
		return format('%d:%02d', m, floor(s))
	elseif s < 10 then
		return format('%1.1f', s)
	else
		return format('%.0f', floor(s))
	end
end

function CCWatchWarn(msg, effect, target, time)
	local ncc = 0;
	local cc = CCWATCH.WARNTYPE;
	-- Emote, Say, Party, Raid, Yell, Custom:<ccname>
	if cc == "RAID" and UnitInRaid'player' == nil then
		cc = "PARTY";
	end
	if cc == "PARTY" and GetNumPartyMembers() == 0 then
		return;
	end
	if cc == "CHANNEL" then
		ncc = GetChannelName(CCWATCH.WARNCUSTOMCC);
	end
	if time ~= nil then
		msg = format(msg, target, effect, time);
	else
		msg = format(msg, target, effect);
	end
	if cc == "EMOTE" then
		msg = CCWATCH_WARN_EMOTE..msg;
	end
	SendChatMessage(msg, cc, nil, ncc);
end

function CCWatch_Config()
	CCWATCH.CCS = {}

	CCWatch_ConfigCC()
	CCWatch_ConfigDebuff()
	CCWatch_ConfigBuff()

	for _, cc in CCWATCH.CCS do
		cc.TARGET = ''
		cc.PLAYER = nil
		cc.TIMER_START = 0
		cc.TIMER_END = 0
	end
end

function CCWatch_OnLoad()
	for _, type in {'CC', 'Buff', 'Debuff'} do
		for i = 1, CCWATCH_MAXBARS do
			local name = 'CCWatchBar' .. type .. i
			local f = create_bar(name)
			f:SetParent(getglobal('CCWatch' .. type))
			f:SetPoint('TOPLEFT', 0, -100 + i * 20)
			f:SetScript('OnShow', getglobal(name .. '_OnShow'))
			setglobal(name, f)
		end
	end

	CCWatch_Globals()
	CCWatch_Config()

	CCWatchObject = this;

	this:RegisterEvent("UNIT_AURA")
	this:RegisterEvent("UNIT_COMBAT")

	if UnitLevel'player' < 60 then
		this:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
-- TODO : add this
--		this:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
 	end
-- register this also for < 60 (pvp)
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	this:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")

	this:RegisterEvent("SPELLCAST_START")
	this:RegisterEvent("SPELLCAST_STOP")
	this:RegisterEvent("SPELLCAST_FAILED")
	this:RegisterEvent("SPELLCAST_INTERRUPTED")

	this:RegisterEvent("PLAYER_TARGET_CHANGED")

	SLASH_CCWATCH1 = "/ccwatch"
	SLASH_CCWATCH2 = "/ccw"
	SlashCmdList.CCWATCH = CCWatch_SlashCommandHandler

	CCWatch_AddMessage(CCWATCH_FULLVERSION..CCWATCH_LOADED)
end

function CCWatch_BarUnlock()
	CCWATCH.STATUS = 2
	CCWatchCC:EnableMouse(1)
	CCWatchDebuff:EnableMouse(1)
	CCWatchBuff:EnableMouse(1)

	for i = 1, CCWATCH_MAXBARS do
		getglobal("CCWatchBarCC"..i):Show()
		getglobal("CCWatchBarDebuff"..i):Show()
		getglobal("CCWatchBarBuff"..i):Show()
	end
end

function CCWatch_BarLock()
	CCWATCH.STATUS = 1
	CCWatchCC:EnableMouse(0)
	CCWatchDebuff:EnableMouse(0)
	CCWatchBuff:EnableMouse(0)

	for i = 1, CCWATCH_MAXBARS do
		getglobal("CCWatchBarCC"..i):Hide()
		getglobal("CCWatchBarDebuff"..i):Hide()
		getglobal("CCWatchBarBuff"..i):Hide()
	end
end

function CCWatch_SlashCommandHandler(msg)
	if msg then
		local command = string.lower(msg)
		if command == "on" then
			if CCWATCH.STATUS == 0 then
				CCWATCH.STATUS = 1
				CCWatch_Save[CCWATCH.PROFILE].status = CCWATCH.STATUS
				CCWatch_AddMessage(CCWATCH_ENABLED)
			end
		elseif command == "off" then
			if CCWATCH.STATUS ~= 0 then
				CCWATCH.STATUS = 0
				CCWatch_Save[CCWATCH.PROFILE].status = CCWATCH.STATUS
				CCWatch_AddMessage(CCWATCH_DISABLED)
			end
		elseif command == "unlock" then
			CCWatch_BarUnlock()
			CCWatch_AddMessage(CCWATCH_UNLOCKED)
			CCWatchOptionsFrameUnlock:SetChecked(true)
		elseif command == "lock" then
			CCWatch_BarLock()
			CCWatch_AddMessage(CCWATCH_LOCKED)
			CCWatchOptionsFrameUnlock:SetChecked(false)
		elseif command == "invert" then
			CCWATCH.INVERT = not CCWATCH.INVERT
			CCWatch_Save[CCWATCH.PROFILE].invert = CCWATCH.INVERT
			if CCWATCH.INVERT then
				CCWatch_AddMessage(CCWATCH_INVERSION_ON)
			else
				CCWatch_AddMessage(CCWATCH_INVERSION_OFF)
			end
			CCWatchOptionsFrameInvert:SetChecked(CCWATCH.INVERT)
		elseif command == "timers off" then
			CCWatch_Save[CCWATCH.PROFILE].timers = 0
			CCWATCH.TIMERS = CCWatch_Save[CCWATCH.PROFILE].timers
			CCWatch_AddMessage(CCWATCH_TIMERS_OFF)
			CCWatchTimersDropDownText:SetText(CCWATCH_OPTION_TIMERS_OFF)
		elseif command == "timers on" then
			CCWatch_Save[CCWATCH.PROFILE].timers = 1
			CCWATCH.TIMERS = CCWatch_Save[CCWATCH.PROFILE].timers
			CCWatch_AddMessage(CCWATCH_TIMERS_ON)
			CCWatchTimersDropDownText:SetText(CCWATCH_OPTION_TIMERS_ON)
		elseif command == "timers rev" then
			CCWatch_Save[CCWATCH.PROFILE].timers = 2
			CCWATCH.TIMERS = CCWatch_Save[CCWATCH.PROFILE].timers
			CCWatch_AddMessage(CCWATCH_TIMERS_REVERSE)
			CCWatchTimersDropDownText:SetText(CCWATCH_OPTION_TIMERS_REVERSE)
		elseif command == "grow off" then
			CCWatch_Save[CCWATCH.PROFILE].growth = 0
			CCWATCH.GROWTH = CCWatch_Save[CCWATCH.PROFILE].growth
			CCWatch_AddMessage(CCWATCH_GROW_OFF)
			CCWatchGrowthDropDownText:SetText(CCWATCH_OPTION_GROWTH_OFF)
		elseif command == "grow up" then
			CCWatch_Save[CCWATCH.PROFILE].growth = 1
			CCWATCH.GROWTH = CCWatch_Save[CCWATCH.PROFILE].growth
			CCWatch_AddMessage(CCWATCH_GROW_UP)
			CCWatchGrowthDropDownText:SetText(CCWATCH_OPTION_GROWTH_UP)
		elseif command == "grow down" then
			CCWatch_Save[CCWATCH.PROFILE].growth = 2
			CCWATCH.GROWTH = CCWatch_Save[CCWATCH.PROFILE].growth
			CCWatch_AddMessage(CCWATCH_GROW_DOWN)
			CCWatchGrowthDropDownText:SetText(CCWATCH_OPTION_GROWTH_DOWN)
		elseif command == "clear" then
			CCWatch_Save[CCWATCH.PROFILE] = nil
			CCWatch_Globals()
			CCWatch_Config()
			CCWatch_LoadVariables()
		elseif command == "u" then
			CCWatch_Config()
			CCWatch_LoadConfCCs()
			CCWatch_LoadCustomCCs()
			CCWatch_UpdateClassSpells(true)
		elseif( command == "config" ) then
			CCWatchOptionsFrame:Show()
		elseif string.sub(command, 1, 5) == "scale" then
			local scale = tonumber(string.sub(command, 7))
			if scale <= 3 and scale >= .25 then
				CCWatch_Save[CCWATCH.PROFILE].scale = scale
				CCWATCH.SCALE = scale
				CCWatchCC:SetScale(CCWATCH.SCALE)
				CCWatchDebuff:SetScale(CCWATCH.SCALE)
				CCWatchBuff:SetScale(CCWATCH.SCALE)
				CCWatch_AddMessage(CCWATCH_SCALE..scale)
				CCWatchSliderScale:SetValue(CCWATCH.SCALE)
			else
				CCWatch_Help()
			end
		elseif string.sub(command, 1, 5) == "width" then
			local width = tonumber(string.sub(command, 7))
			if width <= 300 and width >= 50 then
				CCWatch_Save[CCWATCH.PROFILE].width = width
				CCWATCH.WIDTH = width
				CCWatch_SetWidth(CCWATCH.WIDTH)
				CCWatch_AddMessage(CCWATCH_WIDTH..width)
				CCWatchSliderWidth:SetValue(CCWATCH.WIDTH)
			else
				CCWatch_Help()
			end
		elseif string.sub(command, 1, 5) == "alpha" then
			local alpha = tonumber(string.sub(command, 7))
			if alpha <= 1 and alpha >= 0 then
				CCWatch_Save[CCWATCH.PROFILE].alpha = alpha
				CCWATCH.ALPHA = alpha
				CCWatch_AddMessage(CCWATCH_ALPHA..alpha)
				CCWatchSliderAlpha:SetValue(CCWATCH.ALPHA)
			else
				CCWatch_Help()
			end
		elseif command == "print" then
			CCWatch_AddMessage(CCWATCH_PROFILE_TEXT..CCWATCH.PROFILE);
			if CCWATCH.STATUS == 0 then
				CCWatch_AddMessage(CCWATCH_DISABLED)
			elseif CCWATCH.STATUS == 2 then
				CCWatch_AddMessage(CCWATCH_UNLOCKED)
			else
				CCWatch_AddMessage(CCWATCH_ENABLED)
			end
			if CCWATCH.INVERT then
				CCWatch_AddMessage(CCWATCH_INVERSION_ON);
			else
				CCWatch_AddMessage(CCWATCH_INVERSION_OFF);
			end
			if CCWATCH.TIMERS == 0 then
				CCWatch_AddMessage(CCWATCH_TIMERS_OFF);
			elseif CCWATCH.TIMERS == 1 then
				CCWatch_AddMessage(CCWATCH_TIMERS_ON);
			else
				CCWatch_AddMessage(CCWATCH_TIMERS_REVERSE);
			end
			if CCWATCH.GROWTH == 0 then
				CCWatch_AddMessage(CCWATCH_GROW_OFF)
			elseif CCWATCH.GROWTH == 1 then
				CCWatch_AddMessage(CCWATCH_GROW_UP)
			else
				CCWatch_AddMessage(CCWATCH_GROW_DOWN)
			end
			CCWatch_Config()
			CCWatch_LoadConfCCs()
			CCWatch_LoadCustomCCs()
			CCWatch_UpdateClassSpells(true) -- Update at the same time

			CCWatch_AddMessage(CCWATCH_SCALE..CCWATCH.SCALE)
			CCWatch_AddMessage(CCWATCH_WIDTH..CCWATCH.WIDTH)
			CCWatch_AddMessage(CCWATCH_ALPHA..CCWATCH.ALPHA)
		elseif string.sub(command, 1, 6) == "warncc" then
			local cc = string.sub(command, 8);
			if cc ~= "EMOTE" or cc ~= "SAY" or cc ~= "PARTY" or cc ~= "RAID"
				or cc ~= "YELL" or cc ~= "CHANNEL" then
				CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC = cc
				CCWATCH.WARNCUSTOMCC = cc;
				CCWatch_Save[CCWATCH.PROFILE].WarnType = "CHANNEL"
				CCWatch_AddMessage(CCWATCH_WARNCC_CUSTOM..cc)
			else
				CCWatch_Save[CCWATCH.PROFILE].WarnType = cc
				CCWatch_AddMessage(CCWATCH_WARNCC_SETTO..cc)
			end
			CCWATCH.WARNTYPE = CCWatch_Save[CCWATCH.PROFILE].WarnType
		elseif command == "warn" then
			if CCWATCH.WARNMSG then
				CCWATCH.WARNMSG = 0
				CCWatch_AddMessage(CCWATCH_WARN_DISABLED)
			else
				CCWATCH.WARNMSG = bit.bor(CCW_EWARN_FADED, CCW_EWARN_APPLIED, CCW_EWARN_BROKEN, CCW_EWARN_LOWTIME)
				CCWatch_AddMessage(CCWATCH_WARN_ENABLED)
				UpdateWarnUIPage()
			end
			CCWatch_Save[CCWATCH.PROFILE].WarnMsg = CCWATCH.WARNMSG
		else
			CCWatch_Help()
		end
	end
end

function CCWatch_OnEvent(event)
	if CCWATCH.STATUS == 0 then
		return
	end
	CCWatch_EventHandler[event](arg1, arg2, arg3, arg4, arg5)
end

CCWatch_EventHandler = {}

do
	local function find_effect(effect, group, etype)
		if etype == ETYPE_BUFF then
			for i, v in CCWATCH.GROUPSBUFF[group].EFFECT do
				if v == effect then return i end
			end
		elseif etype == ETYPE_DEBUFF then
			for i, v in CCWATCH.GROUPSDEBUFF[group].EFFECT do
				if v == effect then return i end
			end
		else
			for i, v in CCWATCH.GROUPSCC[group].EFFECT do
				if v == effect then return i end
			end
		end
	end

	local effect, applied_effect, old_starttime, old_endtime

	function CCWatch_EventHandler.SPELLCAST_START()
		effect = arg1
		old_endtime = 0
	--	duration = arg2;	-- might wanna play with it to deduce the used rank
	end

	function CCWatch_EventHandler.SPELLCAST_STOP()
		local target = UnitName'target'
		if effect and target then
			if CCWATCH.CCS[effect] then
				applied_effect = effect
				old_starttime = CCWATCH.CCS[effect].TIMER_START
				old_endtime = CCWATCH.CCS[effect].TIMER_END

				local group = CCWATCH.CCS[effect].GROUP
				local etype = CCWATCH.CCS[effect].ETYPE

				if find_effect(effect, group, etype) then
					-- no UNIT_AURA event if it's already active
					CCWATCH.UNIT_AURA.TIME = GetTime()
					CCWATCH.UNIT_AURA.TARGET = target
					CCWatch_QueueEvent(effect, target, GetTime(), 1)
					CCWatch_EffectHandler[1]()
				end
			end
		end
		effect = nil
	end

	function CCWatch_EventHandler.SPELLCAST_FAILED()
		if applied_effect and CCWATCH.CCS[applied_effect] then
			CCWATCH.CCS[applied_effect].TIMER_START = old_starttime
			CCWATCH.CCS[applied_effect].TIMER_END = old_endtime
		end
		applied_effect = nil
	end

	function CCWatch_EventHandler.SPELLCAST_INTERRUPTED()
		if applied_effect and CCWATCH.CCS[applied_effect] then
			CCWATCH.CCS[applied_effect].TIMER_START = old_starttime
			CCWATCH.CCS[applied_effect].TIMER_END = old_endtime
		end
		applied_effect = nil
	end
end

function CCWatch_EventHandler.UNIT_AURA()
	if arg1 == 'target' then
		CCWATCH.UNIT_AURA.TARGET = UnitName'target'
		CCWATCH.UNIT_AURA.TIME = GetTime()

		-- get rid of any old events so they don't clutter the queue
		while getn(CCWATCH.EFFECT) > 0 and (CCWATCH.UNIT_AURA.TIME - CCWATCH.EFFECT[1].TIME) > CCWATCH.THRESHOLD do
			CCWatch_UnqueueEvent()
		end

		if getn(CCWATCH.EFFECT) > 0 then
			CCWatch_EffectHandler[CCWATCH.EFFECT[1].STATUS]()
		end
	end
end

function CCWatch_EventHandler.PLAYER_TARGET_CHANGED()
	if not UnitCanAttack("player", "target") then
		return
	end
	local index = 0
	local target = UnitName'target'
-- 1. Check if current target is present in the list
	table.foreach(CCWATCH.LASTTARGETS, function(k,v) if v.TARGET == target then index = k end end)
	local ltime = GetTime()
	if index == 0 then
-- 2. add it
		CCWatch_AddLastTarget(target, ltime)
	else
-- or update target time effect
		CCWATCH.LASTTARGETS[index].TIME = ltime
	end
end

function CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE()
	for mobname, effect in string.gfind(arg1, CCWATCH_TEXT_ON) do
		if CCWATCH.STYLE > 1 or CCWatch_CheckRecentTargets(mobname) then
			if CCWATCH.CCS[effect] and CCWATCH.CCS[effect].MONITOR and bit.band(CCWATCH.CCS[effect].ETYPE, CCWATCH.MONITORING) ~= 0 then
				CCWatch_QueueEvent(effect, mobname, GetTime(), 1)
				CCWatch_EffectHandler[1]()
			end
		end
	end
end

function CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS()
	for mobname, effect in string.gfind(arg1, CCWATCH_TEXT_BUFF_ON) do
		if CCWATCH.STYLE > 1 or CCWatch_CheckRecentTargets(mobname) then
			if CCWATCH.CCS[effect] and CCWATCH.CCS[effect].MONITOR and bit.band(CCWATCH.CCS[effect].ETYPE, CCWATCH.MONITORING) ~=0 then
				CCWatch_QueueEvent(effect, mobname, GetTime(), 1)
				CCWatch_EffectHandler[1]()
			end
		end
	end
end

CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS = CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE

function CCWatch_EventHandler.CHAT_MSG_SPELL_AURA_GONE_OTHER()
	for effect, mobname in string.gfind(arg1, CCWATCH_TEXT_OFF) do
		if CCWATCH.CCS[effect] then
			if CCWATCH.CCS[effect].TARGET == mobname then
				CCWatch_QueueEvent(effect, mobname, GetTime(), 2)
				CCWatch_EffectHandler[2]()
			end
		end
	end
end

function CCWatch_EventHandler.CHAT_MSG_SPELL_BREAK_AURA()
	for mobname, effect in string.gfind(arg1, CCWATCH_TEXT_BREAK) do
		if CCWATCH.CCS[effect] then
			if CCWATCH.CCS[effect].TARGET == mobname then
				CCWatch_QueueEvent(effect, mobname, GetTime(), 3)
				CCWatch_EffectHandler[3]()
			end
		end
	end
end

do
	local DeadMob = ''
	local function CCWHandleTargetDeath(k, v)
		if v then
			if v.TARGET == DeadMob then
				CCWATCH.CCS[k].TIMER_END = GetTime()
				CCWatch_RemoveEffect(k, false)
			end
		end
	end

	function CCWatch_EventHandler.CHAT_MSG_COMBAT_HOSTILE_DEATH()
		for mobname in string.gfind(arg1, CCWATCH_TEXT_DIE) do
			DeadMob = mobname
			table.foreach(CCWATCH.CCS, CCWHandleTargetDeath)
		end
	end

	function CCWatch_EventHandler.CHAT_MSG_COMBAT_XP_GAIN()
		for mobname in string.gfind(arg1, CCWATCH_TEXT_DIEXP) do
			DeadMob = mobname
			table.foreach(CCWATCH.CCS, CCWHandleTargetDeath)
		end
	end
end

function CCWatch_EventHandler.UNIT_COMBAT()
	if GetComboPoints() > 0 then
		CCWATCH.COMBO = GetComboPoints()
	end
end

CCWatch_EffectHandler = {}

CCWatch_EffectHandler[0] = function()
-- no effect

end

CCWatch_EffectHandler[1] = function()
-- applied
	if CCWATCH.STYLE ~= 0 or math.abs( CCWATCH.UNIT_AURA.TIME - CCWATCH.EFFECT[1].TIME ) < CCWATCH.THRESHOLD then
		local effect = CCWATCH.EFFECT[1].TYPE
		local mobname = CCWATCH.EFFECT[1].TARGET

		if GetTime() > ( CCWATCH.CCS[effect].TIMER_END + 15 ) or mobname ~= CCWATCH.CCS[effect].TARGET then
-- quick & dirty hack for shared DR between Seduce & Fear)
			if effect == CCWATCH_FEAR or effect == CCWATCH_SEDUCE then
				CCWATCH.CCS[CCWATCH_FEAR].DIMINISH = 1
				CCWATCH.CCS[CCWATCH_SEDUCE].DIMINISH = 1
			else
				CCWATCH.CCS[effect].DIMINISH = 1
			end
		end

		CCWATCH.CCS[effect].TARGET = mobname
		CCWATCH.CCS[effect].PLAYER = UnitIsPlayer'target'
		CCWATCH.CCS[effect].TIMER_START = GetTime()
		if CCWATCH.CCS[effect].PVPCC and CCWATCH.CCS[effect].PLAYER then
			CCWATCH.CCS[effect].TIMER_END = CCWATCH.CCS[effect].TIMER_START + (CCWATCH.CCS[effect].PVPCC / CCWATCH.CCS[effect].DIMINISH)
		else
			CCWATCH.CCS[effect].TIMER_END = CCWATCH.CCS[effect].TIMER_START + (CCWATCH.CCS[effect].LENGTH / CCWATCH.CCS[effect].DIMINISH)
		end
		if CCWATCH.CCS[effect].COMBO then
			CCWATCH.CCS[effect].TIMER_END = CCWATCH.CCS[effect].TIMER_END + CCWATCH.CCS[effect].A * CCWATCH.COMBO
		end

		CCWatch_AddEffect(effect)

		CCWatch_UnqueueEvent()
		if CCWATCH.CCS[effect].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_APPLIED) then
			CCWatchWarn(CCWATCH_WARN_APPLIED, effect, mobname)
		end
	end
end

CCWatch_EffectHandler[2] = function()
-- faded
	local effect = CCWATCH.EFFECT[1].TYPE
	local target = CCWATCH.CCS[effect].TARGET
	local bUnqueueDone = false;
	if target == CCWATCH.EFFECT[1].TARGET then
	-- target and CC target names match, wait for UNIT_AURA to ensure target match
		if CCWATCH.STYLE ~= 0 or math.abs( CCWATCH.UNIT_AURA.TIME - CCWATCH.EFFECT[1].TIME ) < CCWATCH.THRESHOLD then
			CCWATCH.CCS[effect].TIMER_END = GetTime()
			-- CCWatch_RemoveEffect(effect, false)
			CCWatch_UnqueueEvent()
			bUnqueueDone = true
	-- unless the debuff is gone from the target, then no need for UNIT_AURA to confirm it
		elseif CCWATCH.STYLE == 0 and CCWatch_EffectGone(effect) then
			CCWATCH.CCS[effect].TIMER_END = GetTime()
			-- CCWatch_RemoveEffect(effect, false)
			CCWatch_UnqueueEvent()
			bUnqueueDone = true
		end
	else
	-- target and CC target names don't match, retargetting has occured, no need to wait for UNIT_AuRA
		CCWATCH.CCS[effect].TIMER_END = GetTime()
		-- CCWatch_RemoveEffect(effect, false)
		CCWatch_UnqueueEvent()
		bUnqueueDone = true
	end

	-- another hack, to avoid spamming, because when the effect is broken, SOMETIME, WoW also send a faded message (see combat log)
	if bUnqueueDone and CCWATCH.CCS[effect].WARN > 0 and CCWATCH.CCS[effect].WARN ~= 3 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_FADED) then
		CCWatchWarn(CCWATCH_WARN_FADED, effect, target)
	end
end

CCWatch_EffectHandler[3] = function()
-- broken
	local effect = CCWATCH.EFFECT[1].TYPE
	local target = CCWATCH.CCS[effect].TARGET
	local bUnqueueDone = false
	if target == CCWATCH.EFFECT[1].TARGET then
	-- target and CC target names match, wait for UNIT_AURA to ensure target match
		if CCWATCH.STYLE ~= 0 or math.abs(CCWATCH.UNIT_AURA.TIME - CCWATCH.EFFECT[1].TIME) < CCWATCH.THRESHOLD then
			CCWATCH.CCS[effect].TIMER_END = GetTime()
			CCWatch_RemoveEffect(effect, false)
			CCWatch_UnqueueEvent()
			bUnqueueDone = true
	-- unless the debuff is gone from the target, then no need for UNIT_AURA to confirm it
		elseif CCWATCH.STYLE == 0 and CCWatch_EffectGone(effect) then
			CCWATCH.CCS[effect].TIMER_END = GetTime()
			CCWatch_RemoveEffect(effect, false)
			CCWatch_UnqueueEvent()
			bUnqueueDone = true
		end
	else
	-- target and CC target names don't match, retargetting has occured, no need to wait for UNIT_AuRA
		CCWATCH.CCS[effect].TIMER_END = GetTime()
		CCWatch_RemoveEffect(effect, false)
		CCWatch_UnqueueEvent()
		bUnqueueDone = true
	end
	if bUnqueueDone and CCWATCH.CCS[effect].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_BROKEN) then
		CCWatchWarn(CCWATCH_WARN_BROKEN, effect, target)
		CCWATCH.CCS[effect].WARN = 3
	end
end


function CCWatch_QueueEvent(effect, mobname, time, status)
	local effect_structure = {}
	effect_structure.TYPE = effect
	effect_structure.TARGET = mobname
	effect_structure.TIME = time
	effect_structure.STATUS = status
	tinsert(CCWATCH.EFFECT, effect_structure)
end

function CCWatch_UnqueueEvent()
	tremove(CCWATCH.EFFECT, 1)
end

function CCWatch_EffectGone(effect)
	local effectgone = false -- assume effect is gone unless we find it
	for i = 1, 16 do
		if UnitDebuff("target", i) == CCWATCH.CCS[effect].TEXTURE then
			effectgone = true
		end
	end
	return effectgone
end

function CCWatch_AddEffect(effect)
	-- first remove any old copies of this effect, to avoid nasty overlap and properly set diminishing returns for multi-CC
	local group = CCWATCH.CCS[effect].group
	local GROUPS
	CCWatch_RemoveEffect(effect, true)

	if CCWATCH.CCS[effect].ETYPE == ETYPE_BUFF then
		GROUPS = CCWATCH.GROUPSBUFF
	elseif CCWATCH.CCS[effect].ETYPE == ETYPE_DEBUFF then
		GROUPS = CCWATCH.GROUPSDEBUFF
	else
		GROUPS = CCWATCH.GROUPSCC
	end
	if CCWATCH.GROWTH == 1 then
		group = 1
		-- start at the bottom and find the first available bar, otherwise queue to #CCWATCH_MAXBARS
		while group < CCWATCH_MAXBARS and getn(GROUPS[group].EFFECT) > 0 do
			group = group + 1
		end
		CCWATCH.CCS[effect].GROUP = group
	elseif CCWATCH.GROWTH == 2 then
		group = CCWATCH_MAXBARS
		-- start at the top and find the first available bar, otherwise queue to #1
		while group > 1 and getn(GROUPS[group].EFFECT) > 0 do
			group = group - 1
		end
		CCWATCH.CCS[effect].GROUP = group
	end

	-- new effect goes at the head of the queue... always displaying newest effect
	CCWatch_QueueEffect(effect)
end

function CCWatch_RemoveEffect(effect, dr)
	local group = CCWATCH.CCS[effect].GROUP
	local GROUPS
	CCWatch_UnqueueEffect(effect)

	if CCWATCH.CCS[effect].ETYPE == ETYPE_BUFF then
		GROUPS = CCWATCH.GROUPSBUFF
	elseif CCWATCH.CCS[effect].ETYPE == ETYPE_DEBUFF then
		GROUPS = CCWATCH.GROUPSDEBUFF
	else
		GROUPS = CCWATCH.GROUPSCC
	end

	if CCWATCH.GROWTH == 1 then
		while group < CCWATCH_MAXBARS and getn(GROUPS[group].EFFECT) == 0 and getn(GROUPS[group+1].EFFECT) > 0 do
			local move_effect = GROUPS[group+1].EFFECT[1]
			CCWatch_UnqueueEffect(move_effect)
			CCWATCH.CCS[move_effect].GROUP = group
			CCWatch_QueueEffect(move_effect)
			group = group + 1
		end
	elseif CCWATCH.GROWTH == 2 then
		while group > 1 and getn(GROUPS[group].EFFECT) == 0 and getn(GROUPS[group-1].EFFECT) > 0 do
			local move_effect = GROUPS[group-1].EFFECT[1]
			CCWatch_UnqueueEffect(move_effect)
			CCWATCH.CCS[move_effect].GROUP = group
			CCWatch_QueueEffect(move_effect)
			group = group - 1
		end
	end

	-- set diminishing returns based on CCS[effect].DIMINISHES (documented in CCWatch_ConfigXX.lua)
	if dr and ((CCWATCH.CCS[effect].PLAYER and CCWATCH.CCS[effect].DIMINISHES > 0) or CCWATCH.CCS[effect].DIMINISHES == 1) then
-- quick & dirty hack for shared DR between Seduce & Fear)
		if effect == CCWATCH_FEAR or effect == CCWATCH_SEDUCE then
			CCWATCH.CCS[CCWATCH_FEAR].DIMINISH = 2 * CCWATCH.CCS[CCWATCH_FEAR].DIMINISH
			CCWATCH.CCS[CCWATCH_SEDUCE].DIMINISH = 2 * CCWATCH.CCS[CCWATCH_SEDUCE].DIMINISH
		else
			CCWATCH.CCS[effect].DIMINISH = 2 * CCWATCH.CCS[effect].DIMINISH
		end
	end

	-- ensure if warnable, that WARN is set back to 1
	-- 2 = warn at low time already sent
	-- 3 = broken message seen so no faded message to send if any received
	if CCWATCH.CCS[effect].WARN > 0 then
		CCWATCH.CCS[effect].WARN = 1
	end
end

function CCWatch_QueueEffect(effect)
	local group = CCWATCH.CCS[effect].GROUP
	local GROUPS
	local ext = ''

	if CCWATCH.CCS[effect].ETYPE == ETYPE_BUFF then
		GROUPS = CCWATCH.GROUPSBUFF
		ext = "Buff"
	elseif CCWATCH.CCS[effect].ETYPE == ETYPE_DEBUFF then
		GROUPS = CCWATCH.GROUPSDEBUFF
		ext = "Debuff"
	else
		GROUPS = CCWATCH.GROUPSCC
		ext = "CC"
	end

	tinsert(GROUPS[group].EFFECT, 1, effect)

	local activebarText = bars["CCWatchBar"..ext..group].frame.text
	activebarText:SetText(effect..": "..CCWATCH.CCS[effect].TARGET)

	-- if queue was empty show bar
	if getn(GROUPS[group].EFFECT) == 1 then
		local activebar = getglobal("CCWatchBar"..ext..group)
		activebar:Show();
		if CCWATCH.CCS[effect].COLOR then
			getglobal("CCWatchBar"..ext..group.."StatusBar"):SetStatusBarColor(CCWATCH.CCS[effect].COLOR.r, CCWATCH.CCS[effect].COLOR.g, CCWATCH.CCS[effect].COLOR.b)
		end
	end
end

function CCWatch_UnqueueEffect(effect)
	local group = CCWATCH.CCS[effect].GROUP
	local GROUPS
	local ext = ""

	if CCWATCH.CCS[effect].ETYPE == ETYPE_BUFF then
		GROUPS = CCWATCH.GROUPSBUFF
		ext = "Buff"
	elseif CCWATCH.CCS[effect].ETYPE == ETYPE_DEBUFF then
		GROUPS = CCWATCH.GROUPSDEBUFF
		ext = "Debuff"
	else
		GROUPS = CCWATCH.GROUPSCC
		ext = "CC"
	end

	local index
	-- find the effect in the queue, if it's not there index stays 0
	table.foreach(GROUPS[group].EFFECT, function(k,v) if( v == effect ) then index = k end end)
	if index then
--		CCWATCH.CCS[GROUPS[group].EFFECT[index]].TARGET = ""; -- resetting target for mob death removal
-- commented because of conflict with DR requiring to keep the target name.
-- the name resetting was an unneeded attempt to avoid extra unqueue
		tremove(GROUPS[group].EFFECT, index)
	end

	-- if queue isn't empty set new name
	if getn(GROUPS[group].EFFECT) > 0 then
		local activebarText = bars["CCWatchBar" .. ext .. group].frame.text
		local effect = GROUPS[group].EFFECT[1]
		activebarText:SetText(effect .. ": " .. CCWATCH.CCS[effect].TARGET)
	else
		-- local activebarText = bars["CCWatchBar" .. ext .. group].frame.text
		-- activebarText:SetText("CCWatch " .. ext .. " Bar " .. group)
	end
end

function CCWatchBarCC_OnShow(group)
	CCWatchBar_OnShow(group, CCWATCH.GROUPSCC, "CC")
end

function CCWatchBarDebuff_OnShow(group)
	CCWatchBar_OnShow(group, CCWATCH.GROUPSDEBUFF, "Debuff")
end

function CCWatchBarBuff_OnShow(group)
	CCWatchBar_OnShow(group, CCWATCH.GROUPSBUFF, "Buff")
end

function CCWatchBar_OnShow(group, GROUPS, ext)
	getglobal('CCWatch' .. ext):SetScale(CCWATCH.SCALE)
	getglobal('CCWatchBar' .. ext .. group):SetAlpha(CCWATCH.ALPHA)
	-- getglobal(barname.."StatusBar"):SetStatusBarColor(CCWATCH.COTNORMALCOLOR.r, CCWATCH.COTNORMALCOLOR.g, CCWATCH.COTNORMALCOLOR.b)
	if getn(GROUPS[group].EFFECT) == 0 then
		bars[barname].frame.text:SetText('CCWatch Bar '..ext..' '..group)
	end
	-- getglobal(barname.."StatusBarSpark"):SetPoint("CENTER", barname.."StatusBar", "LEFT", 0, 0)
end


function CCWatchBarCC1_OnShow() CCWatchBarCC_OnShow(1) end
function CCWatchBarCC2_OnShow() CCWatchBarCC_OnShow(2) end
function CCWatchBarCC3_OnShow() CCWatchBarCC_OnShow(3) end
function CCWatchBarCC4_OnShow() CCWatchBarCC_OnShow(4) end
function CCWatchBarCC5_OnShow() CCWatchBarCC_OnShow(5) end

function CCWatchBarDebuff1_OnShow() CCWatchBarDebuff_OnShow(1) end
function CCWatchBarDebuff2_OnShow() CCWatchBarDebuff_OnShow(2) end
function CCWatchBarDebuff3_OnShow() CCWatchBarDebuff_OnShow(3) end
function CCWatchBarDebuff4_OnShow() CCWatchBarDebuff_OnShow(4) end
function CCWatchBarDebuff5_OnShow() CCWatchBarDebuff_OnShow(5) end

function CCWatchBarBuff1_OnShow() CCWatchBarBuff_OnShow(1) end
function CCWatchBarBuff2_OnShow() CCWatchBarBuff_OnShow(2) end
function CCWatchBarBuff3_OnShow() CCWatchBarBuff_OnShow(3) end
function CCWatchBarBuff4_OnShow() CCWatchBarBuff_OnShow(4) end
function CCWatchBarBuff5_OnShow() CCWatchBarBuff_OnShow(5) end

function CCWatch_OnUpdate()
	if CCWATCH.STATUS == 0 then
		return
	end
	table.foreach(CCWATCH.GROUPSCC, CCWatch_GroupCCUpdate)
	table.foreach(CCWATCH.GROUPSDEBUFF, CCWatch_GroupDebuffUpdate)
	table.foreach(CCWATCH.GROUPSBUFF, CCWatch_GroupBuffUpdate)
end

function CCWatch_GroupCCUpdate(group)
	CCWatch_GroupUpdate(group, CCWATCH.GROUPSCC, 'CC')
end

function CCWatch_GroupDebuffUpdate(group)
	CCWatch_GroupUpdate(group, CCWATCH.GROUPSDEBUFF, 'Debuff')
end

function CCWatch_GroupBuffUpdate(group)
	CCWatch_GroupUpdate(group, CCWATCH.GROUPSBUFF, 'Buff')
end

function CCWatch_GroupUpdate(group, GROUPS, type)
	local bar = bars['CCWatchBar' .. type .. group]
	local frame = bar.frame

	if getn(GROUPS[group].EFFECT) > 0 then
		bar.stopped = nil
		local effect = GROUPS[group].EFFECT[1]

		frame:SetAlpha(CCWATCH.ALPHA)

		local t = GetTime()

		if t < CCWATCH.CCS[effect].TIMER_END then -- TODO why needed
			local duration = CCWATCH.CCS[effect].TIMER_END - CCWATCH.CCS[effect].TIMER_START
			local remaining = CCWATCH.CCS[effect].TIMER_END - t
			local fraction = remaining / duration

			local frame = bars['CCWatchBar' .. type .. group].frame

			frame.statusbar:SetValue(CCWATCH.INVERT and 1 - fraction or fraction)

			local sparkPosition = bar.width * fraction
			frame.spark:Show()
			frame.spark:SetPoint('CENTER', bar.frame.statusbar, CCWATCH.INVERT and 'RIGHT' or 'LEFT', CCWATCH.INVERT and -sparkPosition or sparkPosition, 0)

			frame.timertext:SetText(format_time(remaining))

			local f = fraction > 1/3 and 1 or fraction / (1/3)
			local r, g, b = unpack(CCWATCH.CCS[effect].SCHOOL or {1, 0, 1})
			frame.statusbar:SetStatusBarColor(f*r + 1-f, f*g, f*b)

			frame.icon:SetNormalTexture([[Interface\Icons\]] .. (CCWATCH.CCS[effect].ICON or 'INV_Misc_QuestionMark'))

			if CCWATCH.CCS[effect].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_LOWTIME) then
				if CCWATCH.CCS[effect].TIMER_END - CCWATCH.CCS[effect].TIMER_START > CCWATCH.WARNLOW and CCWATCH.WARNLOW > remaining then
					if CCWATCH.CCS[effect].WARN == 1 then 
						CCWatchWarn(CCWATCH_WARN_LOWTIME, effect, CCWATCH.CCS[effect].TARGET, CCWATCH.WARNLOW)
						CCWATCH.CCS[effect].WARN = 2
					end
				elseif CCWATCH.CCS[effect].WARN == 2 then -- reset if ever disconnected while fighting
					CCWATCH.CCS[effect].WARN = 1
				end
			end
		else
			frame.statusbar:SetValue(0)
			CCWatch_RemoveEffect(effect, false)
		end
	elseif frame:GetAlpha() > 0 then
		-- frame.statusbar:SetValue(0)
		frame.statusbar:SetStatusBarColor(1, 0, 0)
		frame.spark:Hide()
		bar.stopped = bar.stopped or GetTime()
		bar.fadeelapsed = GetTime() - bar.stopped
		fade_bar('CCWatchBar' .. type .. group)
	else
		frame:Hide()
	end
end

local function GetConfCC(k, v)
--CCWatch_AddMessage("Updating conf for : "..k);
	if CCWATCH.CCS[k] then
		CCWATCH.CCS[k].MONITOR = v.MONITOR;
		CCWATCH.CCS[k].WARN = v.WARN;
		CCWATCH.CCS[k].COLOR = v.COLOR;
	end
end

local function GetSavedCC(k, v)
	if v == nil then
--CCWatch_AddMessage("Removing "..k);
		CCWATCH.CCS[k] = nil;
		return;
	end
	if v.GROUP == nil or v.ETYPE == nil or v.LENGTH == nil or v.DIMINISHES == nil then
		CCWATCH.CCS[k] = nil;
		return;
	end
--CCWatch_AddMessage("Adding "..k.." ("..type(k)..")");
	CCWATCH.CCS[k] = {
		GROUP = v.GROUP,
		ETYPE = v.ETYPE,
		LENGTH = v.LENGTH,
		DIMINISHES = v.DIMINISHES,
		WARN = v.WARN,
		COLOR = v.COLOR,

		TARGET = "",
		PLAYER = nil,
		TIMER_START = 0,
		TIMER_END = 0,
		DIMINISH = 1,
		MONITOR = true
	}
end


function CCWatch_LoadConfCCs()
-- update array with CC conf
	table.foreach(CCWatch_Save[CCWATCH.PROFILE].ConfCC, GetConfCC);
end

function CCWatch_LoadCustomCCs()
-- update array with saved CCs
	table.foreach(CCWatch_Save[CCWATCH.PROFILE].SavedCC, GetSavedCC);
end

function CCWatch_LoadVariablesOnUpdate(arg1)
	if not CCWATCH.LOADEDVARIABLES then
		CCWatch_LoadVariables();
		CCWATCH.LOADEDVARIABLES = true;
	end
end

function CCWatch_LoadVariables()
	CCWATCH.PROFILE = UnitName("player").." of "..GetCVar("RealmName");

	if CCWatch_Save[CCWATCH.PROFILE] == nil then
		CCWatch_Save[CCWATCH.PROFILE] = {};
	end

	if CCWatch_Save[CCWATCH.PROFILE].SavedCC == nil then
		CCWatch_Save[CCWATCH.PROFILE].SavedCC = {};
	end

	if CCWatch_Save[CCWATCH.PROFILE].ConfCC == nil then
		CCWatch_Save[CCWATCH.PROFILE].ConfCC = {};
	end

	if CCWatch_Save[CCWATCH.PROFILE].status == nil then
		CCWatch_Save[CCWATCH.PROFILE].status = CCWATCH.STATUS;
	end

	if CCWatch_Save[CCWATCH.PROFILE].invert == nil then
		CCWatch_Save[CCWATCH.PROFILE].invert = false;
	end

	if CCWatch_Save[CCWATCH.PROFILE].growth == nil then
		CCWatch_Save[CCWATCH.PROFILE].growth = 0;
	end

	if CCWatch_Save[CCWATCH.PROFILE].scale == nil then
		CCWatch_Save[CCWATCH.PROFILE].scale = 1;
	end

	if CCWatch_Save[CCWATCH.PROFILE].width == nil then
		CCWatch_Save[CCWATCH.PROFILE].width = 160;
	end

	if CCWatch_Save[CCWATCH.PROFILE].alpha == nil then
		CCWatch_Save[CCWATCH.PROFILE].alpha = 1;
	end

	if CCWatch_Save[CCWATCH.PROFILE].arcanist == nil then
		CCWatch_Save[CCWATCH.PROFILE].arcanist = false;
	end

	if CCWatch_Save[CCWATCH.PROFILE].timers == nil then
		CCWatch_Save[CCWATCH.PROFILE].timers = 2;
	end

	if CCWatch_Save[CCWATCH.PROFILE].style == nil then
		CCWatch_Save[CCWATCH.PROFILE].style = 0;
	end

	if CCWatch_Save[CCWATCH.PROFILE].Monitoring == nil then
		CCWatch_Save[CCWATCH.PROFILE].Monitoring = bit.bor(ETYPE_CC, ETYPE_DEBUFF, ETYPE_BUFF);
	end

	if CCWatch_Save[CCWATCH.PROFILE].WarnType == nil then
		CCWatch_Save[CCWATCH.PROFILE].WarnType = "PARTY"
	end

	if CCWatch_Save[CCWATCH.PROFILE].WarnLow == nil then
		CCWatch_Save[CCWATCH.PROFILE].WarnLow = 10;
	end

	if CCWatch_Save[CCWATCH.PROFILE].WarnMsg == nil then
		CCWatch_Save[CCWATCH.PROFILE].WarnMsg = bit.bor(CCW_EWARN_FADED, CCW_EWARN_APPLIED, CCW_EWARN_BROKEN, CCW_EWARN_LOWTIME);
	end

	if CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC == nil then
		CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC = ""
	end

	if CCWatch_Save[CCWATCH.PROFILE].ColorOverTime == nil then
		CCWatch_Save[CCWATCH.PROFILE].ColorOverTime = false;
	end

	if CCWatch_Save[CCWATCH.PROFILE].CoTUrgeColor == nil then
		CCWatch_Save[CCWATCH.PROFILE].CoTUrgeColor = { r=1, g=0, b=0 }
	end

	if CCWatch_Save[CCWATCH.PROFILE].CoTLowColor == nil then
		CCWatch_Save[CCWATCH.PROFILE].CoTLowColor = { r=1, g=0.5, b=0 }
	end

	if CCWatch_Save[CCWATCH.PROFILE].CoTNormalColor == nil then
		CCWatch_Save[CCWATCH.PROFILE].CoTNormalColor = { r=1, g=1, b=0 }
	end

	if CCWatch_Save[CCWATCH.PROFILE].CoTUrgeValue == nil then
		CCWatch_Save[CCWATCH.PROFILE].CoTUrgeValue = 1
	end

	if CCWatch_Save[CCWATCH.PROFILE].CoTLowValue == nil then
		CCWatch_Save[CCWATCH.PROFILE].CoTLowValue = 5
	end

	CCWATCH.ARCANIST = CCWatch_Save[CCWATCH.PROFILE].arcanist

	CCWatch_LoadConfCCs()
	CCWatch_LoadCustomCCs()
	CCWatch_UpdateTextures()
	CCWatch_UpdateClassSpells(false)

	CCWATCH.STATUS = CCWatch_Save[CCWATCH.PROFILE].status
	CCWATCH.INVERT = CCWatch_Save[CCWATCH.PROFILE].invert
	CCWATCH.TIMERS = CCWatch_Save[CCWATCH.PROFILE].timers
	CCWATCH.GROWTH = CCWatch_Save[CCWATCH.PROFILE].growth
	CCWATCH.SCALE = CCWatch_Save[CCWATCH.PROFILE].scale
	CCWATCH.WIDTH = CCWatch_Save[CCWATCH.PROFILE].width
	CCWATCH.ALPHA = CCWatch_Save[CCWATCH.PROFILE].alpha

	CCWATCH.MONITORING = CCWatch_Save[CCWATCH.PROFILE].Monitoring
	CCWATCH.WARNTYPE = CCWatch_Save[CCWATCH.PROFILE].WarnType
	CCWATCH.WARNLOW = CCWatch_Save[CCWATCH.PROFILE].WarnLow
	CCWATCH.WARNMSG = CCWatch_Save[CCWATCH.PROFILE].WarnMsg
	CCWATCH.WARNCUSTOMCC = CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC
	CCWATCH.COLOROVERTIME = CCWatch_Save[CCWATCH.PROFILE].ColorOverTime
	CCWATCH.COTURGECOLOR = CCWatch_Save[CCWATCH.PROFILE].CoTUrgeColor
	CCWATCH.COTLOWCOLOR = CCWatch_Save[CCWATCH.PROFILE].CoTLowColor
	CCWATCH.COTNORMALCOLOR = CCWatch_Save[CCWATCH.PROFILE].CoTNormalColor
	CCWATCH.COTURGEVALUE = CCWatch_Save[CCWATCH.PROFILE].CoTUrgeValue
	CCWATCH.COTLOWVALUE = CCWatch_Save[CCWATCH.PROFILE].CoTLowValue

	if bit.band(CCWATCH.MONITORING, ETYPE_CC) ~= 0 or bit.band(CCWATCH.MONITORING, ETYPE_DEBUFF) ~= 0 then
		CCWatchObject:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
		CCWatchObject:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
	end
	if bit.band(CCWATCH.MONITORING, ETYPE_BUFF) ~= 0 then
		CCWatchObject:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
		CCWatchObject:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
	end

	CCWATCH.STYLE = CCWatch_Save[CCWATCH.PROFILE].style;

	CCWatchCC:SetScale(CCWATCH.SCALE);
	CCWatchDebuff:SetScale(CCWATCH.SCALE);
	CCWatchBuff:SetScale(CCWATCH.SCALE);
	CCWatch_SetWidth(CCWATCH.WIDTH);

	if CCWATCH.STATUS == 2 then
		CCWatch_BarUnlock()
	end

	CCWatchOptions_Init()

	CCWatch_BarLock()

-- Pure cosmetic for Unlock move
	for i = 1, CCWATCH_MAXBARS do
		-- getglobal("CCWatchBarCC"..i.."StatusBarText"):SetText("0.00")
		-- getglobal("CCWatchBarDebuff"..i.."StatusBarText"):SetText("0.00")
		-- getglobal("CCWatchBarBuff"..i.."StatusBarText"):SetText("0.00")
	end
end

function CCWatch_UpdateTextures()
	local i = 1
	while true do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then return end
		if CCWATCH.CCS[name] then
			CCWATCH.CCS[name].TEXTURE = GetSpellTexture(i, BOOKTYPE_SPELL)
		elseif CCWATCH_SPELLS[name] then
			if CCWATCH_SPELLS[name].EFFECTNAME then
				CCWATCH.CCS[CCWATCH_SPELLS[name].EFFECTNAME].TEXTURE = GetSpellTexture(i, BOOKTYPE_SPELL);
			else
				CCWatch_AddMessage("Warning : ranked spell '"..name.."' has a different name from its effect, but no effect name in its definition.");
			end
		end
		i = i + 1
	end
end

function CCWatch_UpdateImpGouge(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 2, 1 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_GOUGE].LENGTH = 4 + rank * 0.5;
		end
	elseif CCWATCH.CCS[CCWATCH_GOUGE].LENGTH == nil then
		CCWATCH.CCS[CCWATCH_GOUGE].LENGTH = 4
	end
end

function CCWatch_UpdateImpGarotte(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 3, 8 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH = 18 + rank * 3
		end
	elseif CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH == nil then
		CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH = 18
	end
end

function CCWatch_UpdateKidneyShot(bPrint)
	local i = 1
	while true do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then
			if CCWATCH.CCS[CCWATCH_KS].LENGTH == nil then
				CCWATCH.CCS[CCWATCH_KS].LENGTH = 1
			end
			return
		end

		if name == CCWATCH_KS then
			if bPrint then
				CCWatch_AddMessage(name.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
			end
			if string.sub(rank,string.len(rank)) == "1" then
				CCWATCH.CCS[CCWATCH_KS].LENGTH = 0
			else
				CCWATCH.CCS[CCWATCH_KS].LENGTH = 1
			end
			return
		end

		i = i + 1
	end
end

function CCWatch_UpdateImpTrap(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 3, 7 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
-- Freezing Trap is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_FREEZINGTRAP].LENGTH = CCWATCH.CCS[CCWATCH_FREEZINGTRAP].LENGTH * (1 + rank * 0.15)
		end
	end
end

function CCWatch_UpdateImpSeduce(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 2, 7 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_SEDUCE].LENGTH = 15 * (1 + rank * 0.10)
		end
	end
end

function CCWatch_UpdateBrutalImpact(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 2, 4 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
-- Bash is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_POUNCE].LENGTH = 2 + rank * 0.50;
			CCWATCH.CCS[CCWATCH_BASH].LENGTH = CCWATCH.CCS[CCWATCH_BASH].LENGTH + rank * 0.50
		end
	end
end

function CCWatch_UpdatePermafrost(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 3, 2 )
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
-- Frostbolt is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_CONEOFCOLD].LENGTH = 8 + .50 + rank * .50
			CCWATCH.CCS[CCWATCH_FROSTBOLT].LENGTH = CCWATCH.CCS[CCWATCH_FROSTBOLT].LENGTH + .50 + rank * .50
		end
	end
end

function CCWatch_UpdateImpShadowWordPain(bPrint)
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(3, 4)
	if texture then
		if bPrint then
			CCWatch_AddMessage(talentname.." "..CCWATCH_RANK.." "..rank.." "..CCWATCH_DETECTED)
		end
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_SHADOWWORDPAIN].LENGTH = 18 + rank * 3;
		end
	end
end

function CCWatch_GetSpellRank(spellname, spelleffect, bPrint)
	local i = 1
	local gotone = false
	local maxrank = CCWATCH_SPELLS[spellname].RANKS

	while true do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)

		if not name then
			if not gotone then
				if bPrint then
					CCWatch_AddMessage(spellname.." "..CCWATCH_NOTDETECTED)
				end
				if CCWATCH.CCS[spelleffect].LENGTH == nil then
					CCWATCH.CCS[spelleffect].LENGTH = CCWATCH_SPELLS[spellname].DURATION[maxrank]
				end
			end
			return
		end

		if name == spellname then
			local currank = 1
			while currank <= maxrank do
				if tonumber(string.sub(rank,string.len(rank))) == currank then
					if bPrint then
						CCWatch_AddMessage(spellname.." "..CCWATCH_RANK.." "..currank.." "..CCWATCH_DETECTED)
					end

					CCWATCH.CCS[spelleffect].LENGTH = CCWATCH_SPELLS[spellname].DURATION[currank]
					gotone = true
				end
				currank = currank + 1
			end
		end

		i = i + 1
	end
end

function CCWatch_UpdateClassSpells(bPrint)
	local _, eclass = UnitClass'player'
	CCWatchOptionsFrameArcanist:Hide()
	if eclass == "ROGUE" then
		CCWatch_GetSpellRank(CCWATCH_SAP, CCWATCH_SAP, bPrint)
		CCWatch_UpdateImpGouge(bPrint)
		CCWatch_UpdateKidneyShot(bPrint)
		if CCWatch_ConfigBuff ~= nil then
			CCWatch_UpdateImpGarotte(bPrint)
		end
	elseif eclass == "WARLOCK" then
		CCWatch_GetSpellRank(CCWATCH_FEAR, CCWATCH_FEAR, bPrint)
		CCWatch_GetSpellRank(CCWATCH_BANISH, CCWATCH_BANISH, bPrint)
		CCWatch_UpdateImpSeduce(bPrint)
	elseif eclass == "PALADIN" then
		CCWatch_GetSpellRank(CCWATCH_HOJ, CCWATCH_HOJ, bPrint)
		if CCWatch_ConfigBuff ~= nil then
			CCWatch_GetSpellRank(CCWATCH_DIVINESHIELD, CCWATCH_DIVINESHIELD, bPrint)
		end
	elseif eclass == "HUNTER" then
		CCWatch_GetSpellRank(CCWATCH_FREEZINGTRAP_SPELL, CCWATCH_FREEZINGTRAP, bPrint)
		CCWatch_GetSpellRank(CCWATCH_SCAREBEAST, CCWATCH_SCAREBEAST, bPrint)
		CCWatch_UpdateImpTrap(bPrint)
	elseif eclass == "PRIEST" then
		CCWatch_GetSpellRank(CCWATCH_SHACKLE, CCWATCH_SHACKLE, bPrint)
		if CCWatch_ConfigDebuff ~= nil then
			CCWatch_UpdateImpShadowWordPain(bPrint)
		end
	elseif eclass == "MAGE" then
		CCWatch_GetSpellRank(CCWATCH_POLYMORPH, CCWATCH_POLYMORPH, bPrint)
		if CCWatch_ConfigDebuff ~= nil then
			CCWatch_GetSpellRank(CCWATCH_FROSTBOLT, CCWATCH_FROSTBOLT, bPrint)
			CCWatch_GetSpellRank(CCWATCH_FIREBALL, CCWATCH_FIREBALL, bPrint)
			CCWatch_UpdatePermafrost(bPrint)
		end
		CCWatchOptionsFrameArcanist:Show()
		if CCWATCH.ARCANIST then
			CCWATCH.CCS[CCWATCH_POLYMORPH].LENGTH = CCWATCH.CCS[CCWATCH_POLYMORPH].LENGTH + 15
		end
	elseif eclass == "DRUID" then
		CCWatch_GetSpellRank(CCWATCH_ROOTS, CCWATCH_ROOTS, bPrint)
		CCWatch_GetSpellRank(CCWATCH_HIBERNATE, CCWATCH_HIBERNATE, bPrint)
		CCWatch_GetSpellRank(CCWATCH_BASH, CCWATCH_BASH, bPrint)
		CCWatch_UpdateBrutalImpact(bPrint)
	end
end

function CCWatch_Help()
	CCWatch_AddMessage(CCWATCH_FULLVERSION..CCWATCH_HELP1)
	CCWatch_AddMessage(CCWATCH_HELP2)
	CCWatch_AddMessage(CCWATCH_HELP3)
	CCWatch_AddMessage(CCWATCH_HELP4)
	CCWatch_AddMessage(CCWATCH_HELP5)
	CCWatch_AddMessage(CCWATCH_HELP6)
	CCWatch_AddMessage(CCWATCH_HELP7)
	CCWatch_AddMessage(CCWATCH_HELP8)
	CCWatch_AddMessage(CCWATCH_HELP9)
	CCWatch_AddMessage(CCWATCH_HELP10)
	CCWatch_AddMessage(CCWATCH_HELP11)
	CCWatch_AddMessage(CCWATCH_HELP12)
	CCWatch_AddMessage(CCWATCH_HELP13)
	CCWatch_AddMessage(CCWATCH_HELP14)
	CCWatch_AddMessage(CCWATCH_HELP15)
	CCWatch_AddMessage(CCWATCH_HELP16)
	CCWatch_AddMessage(CCWATCH_HELP17)
end

function CCWatch_SetWidth(width)
	for _, k in {'CC', 'Debuff', 'Buff'} do
		for i = 1, CCWATCH_MAXBARS do
			getglobal("CCWatchBar" .. k .. i):SetWidth(width + 10)
			-- getglobal("CCWatchBar"..k..i.."Text"):SetWidth(width);
			-- getglobal("CCWatchBar"..k..i.."StatusBar"):SetWidth(width);
		end
		getglobal("CCWatch" .. k):SetWidth(width + 10)
	end
end

function CCWatch_CheckRecentTargets(mobname)
	local target = UnitName'target'
-- Simple compare if using current target monitoring
	if CCWATCH.STYLE == 0 then
		return mobname == target
	end
	local index = 0
-- Check mobname against the list
	table.foreach(CCWATCH.LASTTARGETS, function(k,v) if v.TARGET == mobname then index = k end end)
	if index ~= 0 then
		return true
	end

-- return false if target not found
	return false
end

function CCWatch_AddLastTarget(mobname, time)
	local lt_struct = {}
	lt_struct.TARGET = mobname
	lt_struct.TIME = time

--	CCWatch_AddMessage("Adding "..mobname);

-- if the array is full
	if getn(CCWATCH.LASTTARGETS) >= 5 then
-- remove the oldest target
		local oldest = 0
		local index = 0
		table.foreach(CCWATCH.LASTTARGETS, function(k,v) if oldest == 0 then oldest = v.TIME; index = k; elseif v.TIME < oldest then oldest = v.TIME; index = k; end end)
--		CCWatch_AddMessage("Removing old target : "..CCWATCH.LASTTARGETS[index].TARGET);
		tremove(CCWATCH.LASTTARGETS, index)
	end
	tinsert(CCWATCH.LASTTARGETS, lt_struct)
end

function CCWatch_AddMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage('<CCWatch> ' .. msg)
end
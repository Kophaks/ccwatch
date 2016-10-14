CCWatchLoaded = false

CCWatchObject = nil

CCWATCH_MAXBARS = 5

CCW_EWARN_FADED = 1
CCW_EWARN_APPLIED = 2
CCW_EWARN_BROKEN = 4
CCW_EWARN_LOWTIME = 8

CCWATCH_SCHOOL = {
	NONE = {1, 1, 1},
	PHYSICAL = {1, 1, 0},
	HOLY = {1, .9, .5},
	FIRE = {1, .5, 0},
	NATURE = {.3, 1, .3},
	FROST = {.5, 1, 1},
	SHADOW = {.5, .5, 1},
	ARCANE = {1, .5, 1},
}

do
	local DR_CLASS = {
		["Bash"] = 1,
		["Hammer of Justice"] = 1,
		["Cheap Shot"] = 1,
		["Charge Stun"] = 1,
		["Intercept Stun"] = 1,
		["Concussion Blow"] = 1,

		["Fear"] = 2,
		["Howl of Terror"] = 2,
		["Seduction"] = 2,
		["Intimidating Shout"] = 2,
		["Psychic Scream"] = 2,

		["Polymorph"] = 3,
		["Sap"] = 3,
		["Gouge"] = 3,

		["Entangling Roots"] = 4,
		["Frost Nova"] = 4,

		["Freezing Trap"] = 5,
		["Wyvern String"] = 5,

		["Blind"] = 6,

		["Hibernate"] = 7,

		["Mind Control"] = 8,

		["Kidney Shot"] = 9,

		["Death Coil"] = 10,

		["Frost Shock"] = 11,
	}

	local dr = {}

	local function diminish(key, seconds)
		return 1 / 2^(dr[key].level - 1) * seconds
	end

	function CCWatch_DiminishedDuration(target, effect, full_duration)
		local class = DR_CLASS[effect]
		if class then
			local key = target .. '|' .. class
			if not dr[key] or dr[key].timeout < GetTime() then
				dr[key] = {level=1, timeout=GetTime() + full_duration + 15}
			elseif dr[key].level < 3 then
				dr[key].level = dr[key].level + 1
				dr[key].timeout = GetTime() + diminish(key, full_duration) + 15
			else
				return 0
			end
			return diminish(key, full_duration)
		else
			return full_duration
		end
	end
end

local bars = {}

local function create_bar(name)
	local bar = {}
	bars[name] = bar

	local color = bar.color or {1, 0, 1}
	local bgcolor = {0, .5, .5, .5}
	local icon = bar.icon or nil
	local iconpos = 'LEFT'
	local texture = [[Interface\Addons\CCWatch\Textures\BantoBar]]
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

	bar.fadetime = .5
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
	f.icon:Show()

	f.statusbar = CreateFrame('StatusBar', nil, f)
	f.statusbar:ClearAllPoints()
	f.statusbar:SetHeight(height)
	f.statusbar:SetWidth(width)
	f.statusbar:SetPoint('TOPLEFT', f, 'TOPLEFT', height, 0)
	f.statusbar:SetStatusBarTexture(texture)
	f.statusbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
	f.statusbar:SetMinMaxValues(0, 1)
	f.statusbar:SetValue(1)
	f.statusbar:SetBackdrop{ bgFile=texture }
	f.statusbar:SetBackdropColor(bgcolor[1], bgcolor[2], bgcolor[3], bgcolor[4])

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
	local cc = CCWATCH.WARNTYPE
	-- Emote, Say, Party, Raid, Yell, Custom:<ccname>
	if cc == "RAID" and UnitInRaid'player' == nil then
		cc = "PARTY"
	end
	if cc == "PARTY" and GetNumPartyMembers() == 0 then
		return
	end
	if cc == "CHANNEL" then
		ncc = GetChannelName(CCWATCH.WARNCUSTOMCC)
	end
	if time ~= nil then
		msg = format(msg, target, effect, time)
	else
		msg = format(msg, target, effect)
	end
	if cc == "EMOTE" then
		msg = CCWATCH_WARN_EMOTE .. msg
	end
	SendChatMessage(msg, cc, nil, ncc)
end

function CCWatch_Config()
	CCWATCH.CCS = {}

	CCWatch_ConfigCC()
	CCWatch_ConfigDebuff()
	CCWatch_ConfigBuff()
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

	CCWatchObject = this

	this:RegisterEvent'UNIT_AURA'
	this:RegisterEvent'UNIT_COMBAT'

	if UnitLevel'player' < 60 then
		this:RegisterEvent'CHAT_MSG_COMBAT_XP_GAIN'
-- TODO : add this
--		this:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
 	end
-- register this also for < 60 (pvp)
	this:RegisterEvent'CHAT_MSG_COMBAT_HOSTILE_DEATH'

	this:RegisterEvent'CHAT_MSG_SPELL_AURA_GONE_OTHER'
	this:RegisterEvent'CHAT_MSG_SPELL_BREAK_AURA'

	this:RegisterEvent'SPELLCAST_STOP'
	this:RegisterEvent'SPELLCAST_INTERRUPTED'
	this:RegisterEvent'CHAT_MSG_SPELL_SELF_DAMAGE'
	this:RegisterEvent'CHAT_MSG_SPELL_FAILED_LOCALPLAYER'

	this:RegisterEvent'PLAYER_TARGET_CHANGED'

	SLASH_CCWATCH1 = "/ccwatch"
	SLASH_CCWATCH2 = "/ccw"
	SlashCmdList.CCWATCH = CCWatch_SlashCommandHandler

	CCWatch_AddMessage(CCWATCH_FULLVERSION .. CCWATCH_LOADED)
end

function CCWatch_BarUnlock()
	CCWATCH.STATUS = 2
	for _, type in {'CC', 'Buff', 'Debuff'} do
		getglobal('CCWatch' .. type):EnableMouse(1)
		for i = 1, CCWATCH_MAXBARS do
			local f = getglobal('CCWatchBar' .. type .. i)
			f:SetAlpha(CCWATCH.ALPHA)
			f.statusbar:SetStatusBarColor(1, 1, 1)
			f.statusbar:SetValue(1)
			f.icon:SetNormalTexture[[Interface\Icons\INV_Misc_QuestionMark]]
			f.text:SetText('CCWatch ' .. type .. ' Bar ' .. i)
			f.timertext:SetText''
			f.spark:Hide()
			-- getglobal(barname.."StatusBarSpark"):SetPoint("CENTER", barname.."StatusBar", "LEFT", 0, 0)
			f:Show()
		end
	end
end

function CCWatch_BarLock()
	CCWATCH.STATUS = 1
	CCWatchCC:EnableMouse(0)
	CCWatchDebuff:EnableMouse(0)
	CCWatchBuff:EnableMouse(0)

	for i = 1, CCWATCH_MAXBARS do
		getglobal("CCWatchBarCC" .. i):Hide()
		getglobal("CCWatchBarDebuff" .. i):Hide()
		getglobal("CCWatchBarBuff" .. i):Hide()
	end
end

function CCWatch_SlashCommandHandler(msg)
	if msg then
		local command = strlower(msg)
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
		elseif command == "color school" then
			CCWatch_Save[CCWATCH.PROFILE].color = CTYPE_SCHOOL
			CCWatch_AddMessage'School color enabled.'
		elseif command == "color progress" then
			CCWatch_Save[CCWATCH.PROFILE].color = CTYPE_PROGRESS
			CCWatch_AddMessage'Progress color enabled.'
		elseif command == "color custom" then
			CCWatch_Save[CCWATCH.PROFILE].color = CTYPE_CUSTOM
			CCWatch_AddMessage'Custom color enabled.'
		elseif command == "clear" then
			CCWatch_Save[CCWATCH.PROFILE] = nil
			CCWatch_Globals()
			CCWatch_Config()
			CCWatch_LoadVariables()
		elseif command == "u" then
			CCWatch_Config()
			CCWatch_LoadConfCCs()
			CCWatch_UpdateClassSpells(true)
		elseif command == "config" then
			CCWatchOptionsFrame:Show()
		elseif strsub(command, 1, 5) == "scale" then
			local scale = tonumber(strsub(command, 7))
			if scale <= 3 and scale >= .25 then
				CCWatch_Save[CCWATCH.PROFILE].scale = scale
				CCWATCH.SCALE = scale
				CCWatchCC:SetScale(CCWATCH.SCALE)
				CCWatchDebuff:SetScale(CCWATCH.SCALE)
				CCWatchBuff:SetScale(CCWATCH.SCALE)
				CCWatch_AddMessage(CCWATCH_SCALE .. scale)
				CCWatchSliderScale:SetValue(CCWATCH.SCALE)
			else
				CCWatch_Help()
			end
		elseif strsub(command, 1, 5) == "width" then
			local width = tonumber(strsub(command, 7))
			if width <= 300 and width >= 50 then
				CCWatch_Save[CCWATCH.PROFILE].width = width
				CCWATCH.WIDTH = width
				CCWatch_SetWidth(CCWATCH.WIDTH)
				CCWatch_AddMessage(CCWATCH_WIDTH .. width)
				CCWatchSliderWidth:SetValue(CCWATCH.WIDTH)
			else
				CCWatch_Help()
			end
		elseif strsub(command, 1, 5) == "alpha" then
			local alpha = tonumber(strsub(command, 7))
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
				CCWatch_AddMessage(CCWATCH_INVERSION_ON)
			else
				CCWatch_AddMessage(CCWATCH_INVERSION_OFF)
			end
			if CCWATCH.GROWTH == 1 then
				CCWatch_AddMessage(CCWATCH_GROW_UP)
			else
				CCWatch_AddMessage(CCWATCH_GROW_DOWN)
			end
			CCWatch_Config()
			CCWatch_LoadConfCCs()
			CCWatch_UpdateClassSpells(true)

			CCWatch_AddMessage(CCWATCH_SCALE..CCWATCH.SCALE)
			CCWatch_AddMessage(CCWATCH_WIDTH..CCWATCH.WIDTH)
			CCWatch_AddMessage(CCWATCH_ALPHA..CCWATCH.ALPHA)
		elseif strsub(command, 1, 6) == "warncc" then
			local cc = strupper(strsub(command, 8))
			if cc ~= "EMOTE" and cc ~= "SAY" and cc ~= "PARTY" and cc ~= "RAID"
				and cc ~= "YELL" and cc ~= "CHANNEL" then
				CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC = cc
				CCWATCH.WARNCUSTOMCC = cc
				CCWatch_Save[CCWATCH.PROFILE].WarnType = "CHANNEL"
				CCWatch_AddMessage(CCWATCH_WARNCC_CUSTOM .. cc)
			else
				CCWatch_Save[CCWATCH.PROFILE].WarnType = cc
				CCWatch_AddMessage(CCWATCH_WARNCC_SETTO .. cc)
			end
			CCWATCH.WARNTYPE = CCWatch_Save[CCWATCH.PROFILE].WarnType
		elseif command == "warn" then
			if CCWATCH.WARNMSG ~= 0 then
				CCWATCH.WARNMSG = 0
				CCWatch_AddMessage(CCWATCH_WARN_DISABLED)
			else
				CCWATCH.WARNMSG = bit.bor(CCW_EWARN_FADED, CCW_EWARN_APPLIED, CCW_EWARN_BROKEN, CCW_EWARN_LOWTIME)
				CCWatch_AddMessage(CCWATCH_WARN_ENABLED)
				-- UpdateWarnUIPage()
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
	CCWatch_EventHandler[event]()
end

CCWatch_EventHandler = {}

do
	local casting = {}
	local last_cast
	local pending = {}

	function CCWatch_AbortRefresh(target)
		for k, v in casting do
			if v == target then
				casting[k] = nil
			end
		end
		for k, v in pending do
			if v.target == target then
				pending[k] = nil
			end
		end
	end

	function CCWatch_EventHandler.CHAT_MSG_SPELL_FAILED_LOCALPLAYER()
		for effect in string.gfind(arg1, 'You fail to %a+ (.*):.*') do
			casting[effect] = nil
		end
	end

	function CCWatch_EventHandler.SPELLCAST_INTERRUPTED()
		if last_cast then
			pending[last_cast] = nil
		end
	end

	function CCWatch_EventHandler.CHAT_MSG_SPELL_SELF_DAMAGE()
		for effect in string.gfind(arg1, 'is immune to your (.*)%.') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'resists your (.*)%.') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) was evaded') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) is reflected') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) was deflected') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) was dodged') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) missed') do
			pending[effect] = nil
		end
		for effect in string.gfind(arg1, 'Your (.*) is parried') do
			pending[effect] = nil
		end
	end

	do
		CreateFrame('GameTooltip', 'CCWatch_Tooltip', nil, 'GameTooltipTemplate')
		local orig = UseAction
		function UseAction(slot, clicked, onself)
			if HasAction(slot) and not GetActionText(slot) and not onself then
				CCWatch_Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
				CCWatch_Tooltip:SetAction(slot)
				casting[CCWatch_TooltipTextLeft1:GetText()] = UnitName'target'
			end
			return orig(slot, clicked, onself)
		end
	end

	do
		local orig = CastSpell
		function CastSpell(index, booktype)
			casting[GetSpellName(index, booktype)] = UnitName'target'
			return orig(index, booktype)
		end
	end

	do
		local orig = CastSpellByName
		function CastSpellByName(text, onself)
			if not onself then
				casting[text] = UnitName'target'
			end
			return orig(text, onself)
		end
	end

	function CCWatch_EventHandler.SPELLCAST_STOP()
		for effect, target in casting do
			if CCWatch_EffectActive(effect, target) then
				if pending[effect] then
					last_cast = nil
				else
					pending[effect] = {target=target, time=GetTime() + .5}
					last_cast = effect
				end
			end
		end
		casting = {}
	end

	CreateFrame'Frame':SetScript('OnUpdate', function()
		for effect, info in pending do
			if GetTime() >= info.time then
				CCWatch_QueueEvent(effect, info.target, GetTime() - .5, 1)
				CCWatch_EffectHandler[1]()
				pending[effect] = nil
			end
		end
	end)
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
		if CCWATCH.STYLE == 2 or CCWatch_TrackedTarget(mobname) then
			if CCWATCH.CCS[effect] and CCWATCH.CCS[effect].MONITOR and bit.band(CCWATCH.CCS[effect].ETYPE, CCWATCH.MONITORING) ~= 0 then
				CCWatch_QueueEvent(effect, mobname, GetTime(), 1)
				CCWatch_EffectHandler[1]()
			end
		end
	end
end

function CCWatch_EventHandler.CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS()
	for mobname, effect in string.gfind(arg1, CCWATCH_TEXT_BUFF_ON) do
		if CCWATCH.STYLE == 2 or CCWatch_TrackedTarget(mobname) then
			if CCWATCH.CCS[effect] and CCWATCH.CCS[effect].MONITOR and bit.band(CCWATCH.CCS[effect].ETYPE, CCWATCH.MONITORING) ~= 0 then
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
			CCWatch_QueueEvent(effect, mobname, GetTime(), 2)
			CCWatch_EffectHandler[2]()
		end
	end
end

function CCWatch_EventHandler.CHAT_MSG_SPELL_BREAK_AURA()
	for mobname, effect in string.gfind(arg1, CCWATCH_TEXT_BREAK) do
		if CCWATCH.CCS[effect] then
			CCWatch_QueueEvent(effect, mobname, GetTime(), 3)
			CCWatch_EffectHandler[3]()
		end
	end
end

function CCWatch_EventHandler.CHAT_MSG_COMBAT_HOSTILE_DEATH()
	for mobname in string.gfind(arg1, CCWATCH_TEXT_DIE) do
		CCWatch_RemoveTarget(mobname)
	end
end

function CCWatch_EventHandler.CHAT_MSG_COMBAT_XP_GAIN()
	for mobname in string.gfind(arg1, CCWATCH_TEXT_DIEXP) do
		CCWatch_RemoveTarget(mobname)
	end
end

function CCWatch_EventHandler.UNIT_COMBAT()
	if GetComboPoints() > 0 then
		CCWATCH.COMBO = GetComboPoints()
	end
end

CCWatch_EffectHandler = {}

CCWatch_EffectHandler[1] = function()
-- applied
	local effect = CCWATCH.EFFECT[1].TYPE
	local target = CCWATCH.EFFECT[1].TARGET
	CCWatch_UnqueueEvent()

	CCWatch_AddEffect(effect, target)

	if CCWATCH.CCS[effect].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_APPLIED) ~= 0 then
		CCWatchWarn(CCWATCH_WARN_APPLIED, effect, target)
	end
end

CCWatch_EffectHandler[2] = function()
-- faded
	local effect = CCWATCH.EFFECT[1].TYPE
	local target = CCWATCH.EFFECT[1].TARGET
	CCWatch_UnqueueEvent()

	CCWatch_RemoveEffect(effect, target)

	-- another hack, to avoid spamming, because when the effect is broken, SOMETIME, WoW also send a faded message (see combat log)
	if CCWATCH.CCS[effect].WARN > 0 and CCWATCH.CCS[effect].WARN ~= 3 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_FADED) ~= 0 then
		CCWatchWarn(CCWATCH_WARN_FADED, effect, target)
	end
end

CCWatch_EffectHandler[3] = function()
-- broken
	local effect = CCWATCH.EFFECT[1].TYPE
	local target = CCWATCH.EFFECT[1].TARGET
	CCWatch_UnqueueEvent()

	CCWatch_RemoveEffect(effect, target)

	if CCWATCH.CCS[effect].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_BROKEN) ~= 0 then
		CCWatchWarn(CCWATCH_WARN_BROKEN, effect, target)
		CCWATCH.CCS[effect].WARN = 3
	end
end

function CCWatch_QueueEvent(effect, target, time, status)
	tinsert(CCWATCH.EFFECT, {
		TYPE = effect,
		TARGET = target,
		TIME = time,
		STATUS = status,
	})
end

function CCWatch_UnqueueEvent()
	tremove(CCWATCH.EFFECT, 1)
end

do
	local unconfirmed = {'', '', 0}

	function CCWatch_EventHandler.UNIT_AURA()
		local operation, name, target, time = unpack(unconfirmed)
		if arg1 == 'target' and target == UnitName'target' and GetTime() - time < .5 then
			if operation == 'ADD' then
				CCWatch_AddEffect(name, target, true)
			elseif operation == 'REMOVE' then
				CCWatch_RemoveEffect(name, target, true)
			end
		end
	end

	function CCWatch_EffectActive(name, target)
		for _, group in {CCWATCH.GROUPSBUFF, CCWATCH.GROUPSDEBUFF, CCWATCH.GROUPSCC} do
			for _, bar in group do
				if bar.EFFECT and bar.EFFECT.NAME == name and bar.EFFECT.TARGET == target then
					return true
				end
			end
		end
		return false
	end

	function CCWatch_AddEffect(name, target, confirmed)
		if CCWATCH.STYLE == 0 and not CCWatch_EffectActive(name, target) and not confirmed then
			unconfirmed = {'ADD', name, target, GetTime()}
			return
		end

		local effect = {
			NAME = name,
			TARGET = target,
			PLAYER = UnitIsPlayer'target',
			TIMER_START = GetTime(),
		}

		if CCWATCH.CCS[name].PVPCC and effect.PLAYER then
			effect.TIMER_END = effect.TIMER_START + CCWatch_DiminishedDuration(mobname, name, CCWATCH.CCS[name].PVPCC)
		else
			effect.TIMER_END = effect.TIMER_START + CCWATCH.CCS[name].LENGTH -- TODO some stuns have pve DRs
		end
		if CCWATCH.CCS[name].COMBO then
			effect.TIMER_END = effect.TIMER_END + CCWATCH.CCS[name].A * CCWATCH.COMBO
		end

		local group, ext
		if CCWATCH.CCS[name].ETYPE == ETYPE_BUFF then
			group = CCWATCH.GROUPSBUFF
			ext = 'Buff'
		elseif CCWATCH.CCS[name].ETYPE == ETYPE_DEBUFF then
			group = CCWATCH.GROUPSDEBUFF
			ext = 'Debuff'
		else
			group = CCWATCH.GROUPSCC
			ext = 'CC'
		end

		local index
		if CCWATCH.GROWTH == 1 then
			index = 1
			while index < CCWATCH_MAXBARS and group[index].EFFECT and (name ~= group[index].EFFECT.NAME or target ~= group[index].EFFECT.TARGET) do
				index = index + 1
			end
		else
			index = CCWATCH_MAXBARS
			while index > 1 and group[index].EFFECT and (name ~= group[index].EFFECT.NAME or target ~= group[index].EFFECT.TARGET) do
				index = index - 1
			end
		end

		group[index].EFFECT = effect

		if CCWATCH.STATUS ~= 1 then
			return
		end

		local activebarText = bars['CCWatchBar' .. ext .. index].frame.text
		activebarText:SetText(effect.TARGET .. ' : ' .. effect.NAME)

		getglobal('CCWatchBar' .. ext .. index):Show()
	end

	function CCWatch_RemoveEffect(name, target, confirmed)
		if CCWATCH.STYLE == 0 and UnitName'target' == target and not confirmed then
			unconfirmed = {'REMOVE', name, target, GetTime()}
			return
		end

		-- ensure if warnable, that WARN is set back to 1
		-- 2 = warn at low time already sent
		-- 3 = broken message seen so no faded message to send if any received
		if CCWATCH.CCS[name].WARN > 0 then
			CCWATCH.CCS[name].WARN = 1
		end

		for _, group in {CCWATCH.GROUPSBUFF, CCWATCH.GROUPSDEBUFF, CCWATCH.GROUPSCC} do
			for _, bar in group do
				if bar.EFFECT and bar.EFFECT.NAME == name and bar.EFFECT.TARGET == target then
					bar.EFFECT = nil
				end
			end
		end
	end

	function CCWatch_RemoveTarget(target)
		for _, group in {CCWATCH.GROUPSBUFF, CCWATCH.GROUPSDEBUFF, CCWATCH.GROUPSCC} do
			for _, bar in group do
				if bar.EFFECT and bar.EFFECT.TARGET == target then
					bar.EFFECT = nil
				end
			end
		end
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
	if CCWATCH.STATUS ~= 1 then
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

	local effect = GROUPS[group].EFFECT
	if effect then
		bar.stopped = nil
		
		frame:SetAlpha(CCWATCH.ALPHA)

		local t = GetTime()
		if t < effect.TIMER_END then
			local duration = effect.TIMER_END - effect.TIMER_START
			local remaining = effect.TIMER_END - t
			local fraction = remaining / duration

			frame.statusbar:SetValue(CCWATCH.INVERT and 1 - fraction or fraction)

			local sparkPosition = bar.width * fraction
			frame.spark:Show()
			frame.spark:SetPoint('CENTER', bar.frame.statusbar, CCWATCH.INVERT and 'RIGHT' or 'LEFT', CCWATCH.INVERT and -sparkPosition or sparkPosition, 0)

			frame.timertext:SetText(format_time(remaining))

			local r, g, b
			if CCWatch_Save[CCWATCH.PROFILE].color == CTYPE_SCHOOL then
				r, g, b = unpack(CCWATCH.CCS[effect.NAME].SCHOOL or {1, 0, 1})
			elseif CCWatch_Save[CCWATCH.PROFILE].color == CTYPE_PROGRESS then
				r, g, b = 1 - fraction, fraction, 0
			elseif CCWatch_Save[CCWATCH.PROFILE].color == CTYPE_CUSTOM then
				if CCWATCH.CCS[effect.NAME].COLOR then
					r, g, b = CCWATCH.CCS[effect.NAME].COLOR.r, CCWATCH.CCS[effect.NAME].COLOR.g, CCWATCH.CCS[effect.NAME].COLOR.b
				else
					r, g, b = 1, 1, 1
				end
			end
			frame.statusbar:SetStatusBarColor(r, g, b)
			frame.statusbar:SetBackdropColor(r, g, b, .3)

			frame.icon:SetNormalTexture([[Interface\Icons\]] .. (CCWATCH.CCS[effect.NAME].ICON or 'INV_Misc_QuestionMark'))

			if CCWATCH.CCS[effect.NAME].WARN > 0 and bit.band(CCWATCH.WARNMSG, CCW_EWARN_LOWTIME) ~= 0 then
				if effect.TIMER_END - effect.TIMER_START > CCWATCH.WARNLOW and CCWATCH.WARNLOW > remaining then
					if CCWATCH.CCS[effect.NAME].WARN == 1 then 
						CCWatchWarn(CCWATCH_WARN_LOWTIME, effect.NAME, effect.TARGET, CCWATCH.WARNLOW)
						CCWATCH.CCS[effect.NAME].WARN = 2
					end
				elseif CCWATCH.CCS[effect.NAME].WARN == 2 then -- reset if ever disconnected while fighting
					CCWATCH.CCS[effect.NAME].WARN = 1
				end
			end
		else
			frame.statusbar:SetValue(0)
			CCWatch_RemoveEffect(effect.NAME, effect.TARGET)
		end
	elseif frame:GetAlpha() > 0 then
		-- frame.statusbar:SetValue(0)
		frame.spark:Hide()
		bar.stopped = bar.stopped or GetTime()
		bar.fadeelapsed = GetTime() - bar.stopped
		fade_bar('CCWatchBar' .. type .. group)
	else
		frame:Hide()
	end
end

local function GetConfCC(k, v)
	if CCWATCH.CCS[k] then
		CCWATCH.CCS[k].MONITOR = v.MONITOR
		CCWATCH.CCS[k].WARN = v.WARN
		CCWATCH.CCS[k].COLOR = v.COLOR
	end
end

function CCWatch_LoadConfCCs()
	table.foreach(CCWatch_Save[CCWATCH.PROFILE].ConfCC, GetConfCC)
end

function CCWatch_LoadVariablesOnUpdate(arg1)
	if not CCWATCH.LOADEDVARIABLES then
		CCWatch_LoadVariables()
		CCWATCH.LOADEDVARIABLES = true
	end
end

function CCWatch_LoadVariables()
	local default_settings = {
		SavedCC = {},
		ConfCC = {},
		status = CCWATCH.STATUS,
		invert = false,
		growth = 1,
		color = CTYPE_SCHOOL,
		scale = 1,
		width = 160,
		alpha = 1,
		arcanist = false,
		style = 0,
		Monitoring = bit.bor(ETYPE_CC, ETYPE_DEBUFF, ETYPE_BUFF),
		WarnType = 'PARTY',
		WarnLow = 10,
		WarnMsg = bit.bor(CCW_EWARN_FADED, CCW_EWARN_APPLIED, CCW_EWARN_BROKEN, CCW_EWARN_LOWTIME),
		WarnCustomCC = '',
	}

	CCWATCH.PROFILE = UnitName'player' .. '@' .. GetCVar'RealmName'

	CCWatch_Save[CCWATCH.PROFILE] = CCWatch_Save[CCWATCH.PROFILE] or {}

	for k, v in default_settings do
		if CCWatch_Save[CCWATCH.PROFILE][k] == nil then
			CCWatch_Save[CCWATCH.PROFILE][k] = v
		end
	end

	CCWATCH.ARCANIST = CCWatch_Save[CCWATCH.PROFILE].arcanist

	CCWatch_LoadConfCCs()
	CCWatch_UpdateClassSpells(false)

	CCWATCH.STATUS = CCWatch_Save[CCWATCH.PROFILE].status
	CCWATCH.INVERT = CCWatch_Save[CCWATCH.PROFILE].invert
	CCWATCH.GROWTH = CCWatch_Save[CCWATCH.PROFILE].growth
	CCWATCH.SCALE = CCWatch_Save[CCWATCH.PROFILE].scale
	CCWATCH.WIDTH = CCWatch_Save[CCWATCH.PROFILE].width
	CCWATCH.ALPHA = CCWatch_Save[CCWATCH.PROFILE].alpha

	CCWATCH.MONITORING = CCWatch_Save[CCWATCH.PROFILE].Monitoring
	CCWATCH.WARNTYPE = CCWatch_Save[CCWATCH.PROFILE].WarnType
	CCWATCH.WARNLOW = CCWatch_Save[CCWATCH.PROFILE].WarnLow
	CCWATCH.WARNMSG = CCWatch_Save[CCWATCH.PROFILE].WarnMsg
	CCWATCH.WARNCUSTOMCC = CCWatch_Save[CCWATCH.PROFILE].WarnCustomCC

	if bit.band(CCWATCH.MONITORING, ETYPE_CC) ~= 0 or bit.band(CCWATCH.MONITORING, ETYPE_DEBUFF) ~= 0 then
		CCWatchObject:RegisterEvent'CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE'
		CCWatchObject:RegisterEvent'CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE'
	end
	if bit.band(CCWATCH.MONITORING, ETYPE_BUFF) ~= 0 then
		CCWatchObject:RegisterEvent'CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS'
		CCWatchObject:RegisterEvent'CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS'
	end

	CCWATCH.STYLE = CCWatch_Save[CCWATCH.PROFILE].style

	CCWatchCC:SetScale(CCWATCH.SCALE)
	CCWatchDebuff:SetScale(CCWATCH.SCALE)
	CCWatchBuff:SetScale(CCWATCH.SCALE)
	CCWatch_SetWidth(CCWATCH.WIDTH)

	if CCWATCH.STATUS == 2 then
		CCWatch_BarUnlock()
	end

	CCWatchOptions_Init()
	CCWatch_BarLock()
end

function CCWatch_UpdateImpGouge()
	local talentname, texture, _, _, rank = GetTalentInfo( 2, 1 )
	if texture then
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_GOUGE].LENGTH = 4 + rank * .5
		end
	elseif CCWATCH.CCS[CCWATCH_GOUGE].LENGTH == nil then
		CCWATCH.CCS[CCWATCH_GOUGE].LENGTH = 4
	end
end

function CCWatch_UpdateImpGarotte()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo( 3, 8 )
	if texture then
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH = 18 + rank * 3
		end
	elseif CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH == nil then
		CCWATCH.CCS[CCWATCH_GAROTTE].LENGTH = 18
	end
end

function CCWatch_UpdateKidneyShot()
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
			if strsub(rank,string.len(rank)) == "1" then
				CCWATCH.CCS[CCWATCH_KS].LENGTH = 0
			else
				CCWATCH.CCS[CCWATCH_KS].LENGTH = 1
			end
			return
		end

		i = i + 1
	end
end

function CCWatch_UpdateImpTrap()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(3, 7)
	if texture then
		if rank ~= 0 then
-- Freezing Trap is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_FREEZINGTRAP].LENGTH = CCWATCH.CCS[CCWATCH_FREEZINGTRAP].LENGTH * (1 + rank * .15)
		end
	end
end

function CCWatch_UpdateImpSeduce()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(2, 7)
	if texture then
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_SEDUCE].LENGTH = 15 * (1 + rank * .10)
		end
	end
end

function CCWatch_UpdateBrutalImpact()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(2, 4)
	if texture then
		if rank ~= 0 then
-- Bash is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_POUNCE].LENGTH = 2 + rank * .50
			CCWATCH.CCS[CCWATCH_BASH].LENGTH = CCWATCH.CCS[CCWATCH_BASH].LENGTH + rank * .50
		end
	end
end

function CCWatch_UpdatePermafrost()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(3, 2)
	if texture then
		if rank ~= 0 then
-- Frostbolt is a true multi rank, hence already updated
			CCWATCH.CCS[CCWATCH_CONEOFCOLD].LENGTH = 8 + .50 + rank * .50
			CCWATCH.CCS[CCWATCH_FROSTBOLT].LENGTH = CCWATCH.CCS[CCWATCH_FROSTBOLT].LENGTH + .50 + rank * .50
		end
	end
end

function CCWatch_UpdateImpShadowWordPain()
	local talentname, texture, _, _, rank, _, _, _ = GetTalentInfo(3, 4)
	if texture then
		if rank ~= 0 then
			CCWATCH.CCS[CCWATCH_SHADOWWORDPAIN].LENGTH = 18 + rank * 3
		end
	end
end

function CCWatch_GetSpellRank(spellname, spelleffect)
	local i = 1
	local gotone = false
	local maxrank = CCWATCH_SPELLS[spellname].RANKS

	while true do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)

		if not name then
			if not gotone then
				if CCWATCH.CCS[spelleffect].LENGTH == nil then
					CCWATCH.CCS[spelleffect].LENGTH = CCWATCH_SPELLS[spellname].DURATION[maxrank]
				end
			end
			return
		end

		if name == spellname then
			local currank = 1
			while currank <= maxrank do
				if tonumber(strsub(rank,string.len(rank))) == currank then
					CCWATCH.CCS[spelleffect].LENGTH = CCWATCH_SPELLS[spellname].DURATION[currank]
					gotone = true
				end
				currank = currank + 1
			end
		end

		i = i + 1
	end
end

function CCWatch_UpdateClassSpells()
	local _, eclass = UnitClass'player'
	CCWatchOptionsFrameArcanist:Hide()
	if eclass == "ROGUE" then
		CCWatch_GetSpellRank(CCWATCH_SAP, CCWATCH_SAP)
		CCWatch_UpdateImpGouge()
		CCWatch_UpdateKidneyShot()
		if CCWatch_ConfigBuff ~= nil then
			CCWatch_UpdateImpGarotte()
		end
	elseif eclass == "WARRIOR" then
		CCWatch_GetSpellRank(CCWATCH_REND, CCWATCH_REND)
	elseif eclass == "WARLOCK" then
		CCWatch_GetSpellRank(CCWATCH_FEAR, CCWATCH_FEAR)
		CCWatch_GetSpellRank(CCWATCH_BANISH, CCWATCH_BANISH)
		CCWatch_GetSpellRank(CCWATCH_CORRUPTION, CCWATCH_CORRUPTION)
		CCWatch_UpdateImpSeduce()
	elseif eclass == "PALADIN" then
		CCWatch_GetSpellRank(CCWATCH_HOJ, CCWATCH_HOJ)
		if CCWatch_ConfigBuff ~= nil then
			CCWatch_GetSpellRank(CCWATCH_DIVINESHIELD, CCWATCH_DIVINESHIELD)
		end
	elseif eclass == "HUNTER" then
		CCWatch_GetSpellRank(CCWATCH_FREEZINGTRAP_SPELL, CCWATCH_FREEZINGTRAP)
		CCWatch_GetSpellRank(CCWATCH_SCAREBEAST, CCWATCH_SCAREBEAST)
		CCWatch_UpdateImpTrap()
	elseif eclass == "PRIEST" then
		CCWatch_GetSpellRank(CCWATCH_SHACKLE, CCWATCH_SHACKLE)
		if CCWatch_ConfigDebuff ~= nil then
			CCWatch_UpdateImpShadowWordPain()
		end
	elseif eclass == "MAGE" then
		CCWatch_GetSpellRank(CCWATCH_POLYMORPH, CCWATCH_POLYMORPH)
		if CCWatch_ConfigDebuff ~= nil then
			CCWatch_GetSpellRank(CCWATCH_FROSTBOLT, CCWATCH_FROSTBOLT)
			CCWatch_GetSpellRank(CCWATCH_FIREBALL, CCWATCH_FIREBALL)
			CCWatch_UpdatePermafrost()
		end
		CCWatchOptionsFrameArcanist:Show()
		if CCWATCH.ARCANIST then
			CCWATCH.CCS[CCWATCH_POLYMORPH].LENGTH = CCWATCH.CCS[CCWATCH_POLYMORPH].LENGTH + 15
		end
	elseif eclass == "DRUID" then
		CCWatch_GetSpellRank(CCWATCH_ROOTS, CCWATCH_ROOTS)
		CCWatch_GetSpellRank(CCWATCH_HIBERNATE, CCWATCH_HIBERNATE)
		CCWatch_GetSpellRank(CCWATCH_BASH, CCWATCH_BASH)
		CCWatch_UpdateBrutalImpact()
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
		end
		getglobal("CCWatch" .. k):SetWidth(width + 10)
	end
end

function CCWatch_TrackedTarget(mobname)
	if CCWATCH.STYLE == 2 then
		return true
	end

	local target = UnitName'target'

	if CCWATCH.STYLE == 0 then
		return mobname == target
	end

	for k, v in CCWATCH.LASTTARGETS do
		if v.TARGET == mobname then
			return true
		end
	end

	return false
end

function CCWatch_AddLastTarget(mobname, time)
	local lt_struct = {}
	lt_struct.TARGET = mobname
	lt_struct.TIME = time

	if getn(CCWATCH.LASTTARGETS) >= 5 then
	-- remove the oldest target
		local oldest = 0
		local index = 0
		for k, v in CCWATCH.LASTTARGETS do
			if oldest == 0 then oldest = v.TIME; index = k; elseif v.TIME < oldest then oldest = v.TIME; index = k; end
		end
		tremove(CCWATCH.LASTTARGETS, index)
	end
	tinsert(CCWATCH.LASTTARGETS, lt_struct)
end

function CCWatch_AddMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage('<CCWatch> ' .. msg)
end
script_name = "[SAMPFixer]"
script_author = "riverya4life."
script_version(0.85)
script_properties('work-in-pause')

--==================================== [ Information for Users or scripters ] ====================================--
--[[ Thanks to Black Jesus for cleo GameFixer 2.0 and Gorskin for lua GameFixer 3.1 (memory addresses) 
Script author: riverya4life.
The author is not responsible for your data, the script is completely clean.
The script has an update system! THE UPDATE WILL BE DOWNLOADED ONLY AFTER CLICKING THE "DOWNLOAD UPDATE" BUTTON
All rights reserved!
When posting on the Internet, please indicate a link to the author, public VK, Github profile, discord. 
After editing the script code by anyone other than the author, if something does not work, it crashes, crashes. 
Please do not write to the author for help.
]]
--==================================== [ Information for Users and scripters ] ====================================--

local samp = require("lib.samp.events")
local memory = require("memory")
local ev = require("samp.events")
local rkeys = require 'rkeys'
local imgui = require("mimgui")
local mimgui_blur = require 'mimgui_blur'
local wm = require("windows")
local encoding = require("encoding")
local fa = require("fAwesome6")
local ffi = require("ffi")
local ffiStr = require('ffi').string
local hook = require("hooks")
-- rp guns by Gorskin --
local weapons = require ('lib.game.weapons')
-- rp guns by Gorskin --
--require('lib.riverya.huy', 'https://google.com')

encoding.default = 'CP1251'
u8 = encoding.UTF8

-- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
local active = nil
local pool = {}
-- Message if the description does not exist:
no_description_text = "* Îïèñàíèå îòñóòñòâóåò *"

--- Config fastmap by Gorskin
reduceZoom = true
imgui.HotKey = require("mimhot").HotKey

------------------------[ êîíôèã íàõóé áëÿòü ] -------------------
local inicfg = require "inicfg"
local directIni = "samp.ini"

local ini = inicfg.load(inicfg.load({
    main = {
        shownicks = false,
        showhp = false,
        noradio = false,
        delgun = false,
        showchat = true,
        showhud = true,
        bighpbar = false,
        weather = 1,
        time = 12,
        drawdist = 250,
        drawdistair = 1000,
        drawdistpara = 500,
        fog = 30,
        lod = 280,
        blockweather = false,
        blocktime = false,
        givemedist = false,
		postfx = true,
		autoclean = false,
		animmoney = 3,
		noeffects = false,
		alphamap = 255,
        separate_msg = false,
        vsync = false,
		recolorer = false,
		language = 1,
		moneyfontstyle = 3,
		menufontstyle = 0,
		menuallfontstyle = 2,
		separate_msg = true,
		bindkeys = false,
		smilesystem = false,
		gender = 0,
		camhack = false,
		riveryahellomsg = true,
		rpguns = false,
    },
    hphud = {
        active = false,
		text = 3,
		style = 1,
		pos = 2,
        mode = 1,
    },
	fixes = {
		fixbloodwood = true,
		nolimitmoneyhud = true,
		sunfix = false,
		grassfix = false,
		moneyfontfix = false,
		starsondisplay = false,
        antiblockedplayer = true,
        sensfix = true,
        fixblackroads = true,
        longarmfix = false,
		placename = false,
		animidle = false,
		intrun = true,
		fixcrosshair = true,
		patchduck = true,
		blurreturn = true,
		forceaniso = true,
	},
	themesetting = {
		theme = 6,
		rounded = 4.0,
		roundedcomp = 2.0,
		dialogstyle = false,
		windowborder = true,
		centeredmenu = false,
		iconstyle = 1,
		blurmode = true,
		blurradius = 0.500,
	},
    cleaner = {
        limit = 512,
        autoclean = true,
        cleaninfo = true,
    },
	nop_samp_keys = {
        key_F1 = false,
        key_F4 = false,
        key_F7 = false,
        key_T = false,
        key_ALTENTER = false,
    },
	commands = {
		openmenu = "/riverya",	
		animmoney = "/animmoney",
		shownicks = "/shownicks",
		showhp = "/showhp",
		gameradio = "/gameradio",
		delgun = "/delgun",
		clearchat = "/clearchat",
		showchat = "/showchat",
		showhud = "/showhud",
		dialogstyle = "/dialogstyle",
	},
	hotkeys = {
		openmenukey = "[113]",
	},
}, directIni))
inicfg.save(ini, directIni)

local renderWindow, renderWindowTWS, new, str, sizeof = imgui.new.bool(), imgui.new.bool(), imgui.new, ffi.string, ffi.sizeof

if not doesFileExist("moonloader/config/samp.ini") then  inicfg.save(ini, "samp.ini") end

--== HotKeys ==--
local tLastKeys = {} -- ïðåäûäóùèå õîòêåè àêòèâàöèè

local ActOpenMenuKey = {
	v = decodeJson(ini.hotkeys.openmenukey)
}
--== HotKeys ==--

function save()
    inicfg.save(ini, directIni)
end

--==[CONFIG DIALOG MOOVE]==--
local dragging = false
local dragX, dragY = 0, 0
local CDialog, CDXUTDialog = 0, 0

-- Îñòàëüíîå
local onspawned = false
local offspawnchecker = true
local gscreen = false
local bscreen = false
local bcontrol = false
local showtextdraw = false
local updatesavaliable = false
local MAX_SAMP_MARKERS = 63
local fcrash = false
local unload = false

local sw, sh = getScreenResolution()

local sliders = {
	weather = new.int(ini.main.weather),
	time = new.int(ini.main.time),
	roundtheme = new.float(ini.themesetting.rounded),
	roundthemecomp = new.float(ini.themesetting.roundedcomp),
	drawdist = new.int(ini.main.drawdist),
    drawdistair = new.int(ini.main.drawdistair),
    drawdistpara = new.int(ini.main.drawdistpara),
    fog = new.int(ini.main.fog),
    lod = new.int(ini.main.lod),
	alphamap = new.int(ini.main.alphamap),
	moneyfontstyle = new.int(ini.main.moneyfontstyle),
	menufontstyle = new.int(ini.main.menufontstyle),
	menuallfontstyle = new.int(ini.main.menuallfontstyle),
	blurradius = new.float(ini.themesetting.blurradius),
    ------------------------------------------------
    limitmem = new.int(ini.cleaner.limit),
}

local checkboxes = {
	blockweather = new.bool(ini.main.blockweather),
	blocktime = new.bool(ini.main.blocktime),
	givemedist = new.bool(ini.main.givemedist),
	fixbloodwood = new.bool(ini.fixes.fixbloodwood),
	nolimitmoneyhud = new.bool(ini.fixes.nolimitmoneyhud),
	sunfix = new.bool(ini.fixes.sunfix),
	grassfix = new.bool(ini.fixes.grassfix),
	postfx = new.bool(ini.main.postfx),
	dialogstyle = new.bool(ini.themesetting.dialogstyle),
	noeffects = new.bool(ini.main.noeffects),
	moneyfontfix = new.bool(ini.fixes.moneyfontfix),
	starsondisplay = new.bool(ini.fixes.starsondisplay),
    antiblockedplayer = new.bool(ini.fixes.antiblockedplayer),
    sensfix = new.bool(ini.fixes.sensfix),
    fixblackroads = new.bool(ini.fixes.fixblackroads),
    blurreturn = new.bool(ini.fixes.blurreturn),
    longarmfix = new.bool(ini.fixes.longarmfix),
    vsync = new.bool(ini.main.vsync),
	windowborder = new.bool(ini.themesetting.windowborder),
	centeredmenu = new.bool(ini.themesetting.centeredmenu),
	blurmode = new.bool(ini.themesetting.blurmode),
	placename = new.bool(ini.fixes.placename),
	animidle = new.bool(ini.fixes.animidle),
	intrun = new.bool(ini.fixes.intrun),
	fixcrosshair = new.bool(ini.fixes.fixcrosshair),
	patchduck = new.bool(ini.fixes.patchduck),
	riveryahellomsg = new.bool(ini.main.riveryahellomsg),
	forceaniso = new.bool(ini.fixes.forceaniso),
    --------------------------------------------------
	nop_samp_keys_F1 = new.bool(ini.nop_samp_keys.key_F1),
    nop_samp_keys_F4 = new.bool(ini.nop_samp_keys.key_F4),
    nop_samp_keys_F7 = new.bool(ini.nop_samp_keys.key_F7),
    nop_samp_keys_T = new.bool(ini.nop_samp_keys.key_T),
    nop_samp_keys_ALTENTER = new.bool(ini.nop_samp_keys.key_ALTENTER),
    --------------------------------------------------
    cleaninfo = new.bool(ini.cleaner.cleaninfo),
    autoclean = new.bool(ini.cleaner.autoclean),
}

local buffers = {
	search_cmd = new.char[64](),
	cmd_openmenu = new.char[64](ini.commands.openmenu),
	cmd_animmoney = new.char[64](ini.commands.animmoney),
	cmd_shownicks = new.char[64](ini.commands.shownicks),
	cmd_showhp = new.char[64](ini.commands.showhp),
	cmd_clearchat = new.char[64](ini.commands.clearchat),
	cmd_showchat = new.char[64](ini.commands.showchat),
	cmd_showhud = new.char[64](ini.commands.showhud),
	cmd_dialogstyle = new.char[64](ini.commands.dialogstyle),
}

-- Language
--[[local languageNames = {'English', u8'Óêðà¿íñüêà', u8'Ðóññêèé'}
local languageIndex = new.int(ini.main.languageIndex)
local language = {
	[1] = {
		------------------------------------ [Menu] --------------------------------------------
		tab1 = fa.HOUSE..u8' Home',
		tab2 = fa.DESKTOP..u8' Boost FPS', 
		tab3 = fa.GEAR..u8' Fixes', 
		tab4 = fa.GAMEPAD..u8' Ïðî÷åå', 
		tab5 = fa.BARS..u8' Other',
		------------------------------------ [Settings] --------------------------------------------
		switchoff = u8'Switch off',
		switchon = u8'Turn on',
		switchoffchat = u8'off',
		switchonchat = u8'enabled',
		------------------------------------ [Themes] --------------------------------------------
		theme1 = u8'Blue',
		theme2 = u8'Red',
		theme3 = u8'Brown',
		theme4 = u8'Aqua',
		theme5 = u8'Black',
		theme6 = u8'Violet',
		theme7 = u8'Dark-orange',
		theme8 = u8'Grey',
		theme9 = u8'Cherrish',
		theme10 = u8'Green',
		theme11 = u8'Purple',
		theme12 = u8'Dark-green',
		theme13 = u8'Orange',
		------------------------------------ [Menu Home] --------------------------------------------
		slidersetweather = u8'Weather',
		slidersetweatherquestext = u8'Changes the game weather to its own.',
		slidersettime = u8'Time',
		slidersettimequestext = u8'Changes the game time to your own.',
		checkboxblockweather = u8' Block weather change by the server',
		checkboxblocktime = u8' Block the server from changing the time',
		comboanimationmoney = fa.CIRCLE_DOLLAR_TO_SLOT..u8' Animation of adding / decreasing money:',
		slideralphamap = fa.CLOUD_SUN_RAIN..u8' Transparency of the map on the radar:',
		slideralphamapquestext = u8'Changes the transparency of the map on the radar. The map itself in the ESC menu will be normal (value from 0 to 255).',
		buttonvsync = u8'vertical sync',
		buttonvsynctextchat = u8'Vertical Sync',
		------------------------------------ [Boost FPS] --------------------------------------------
		checkboxpostfx = u8' Disable post-processing',
		checkboxpostfxquestext = u8' Disables post-processing if you have a weak PC.',
		checkboxdisableeffects = u8' Disable effects',
		checkboxdisableeffectsquestext = u8' Disables effects in the game if you have a weak PC.',
		collapsingheaderdrawdist = fa.EYE..u8' Render distance',
		checkboxgivemedist = u8' Enable the ability to change the rendering',
		sliderdrawdist = fa.EYE..u8' Main draw distance:',
		sliderdrawdistquestext = u8'Changes the main draw distance.',
		sliderdrawdistair = fa.PLANE_UP..u8' Draw distance in air transport:',
		sliderdrawdistairquestext = u8'Changes the draw distance in air transport.',
		sliderdrawdistpara = fa.PARACHUTE_BOX..u8' Draw distance when using a parachute:',
		sliderdrawdistparaquestext = u8'Changes the draw distance when using a parachute.',
		sliderfog = fa.SMOG..u8' Fog rendering distance:',
		sliderfogquestext = u8'Changes the fog rendering distance',
		sliderlod = fa.MOUNTAIN..u8' Lod draw distance:',
		sliderlodquestext = u8'Changes the draw distance of lods.',
		collapsingheadercleanmemory = fa.EYE..u8' Clearing memory',
		checkboxautoclean = u8' Enable auto clear memory',
		checkboxclearinfo = u8' Show memory clear message',
		sliderlimitmemory = u8'Auto clear limit: %d MB',
		buttonclearmemory = u8'Clear memory',
		------------------------------------ [Fixes] --------------------------------------------
		checkboxfixbloodwood = u8' Fixing blood when wood is damaged',
		checkboxfixbloodwoodquestext = u8'Correction of blood when a tree is damaged.',
		checkboxnolimitmoneyhud = u8' Remove the limit on limiting money in the HUD',
		checkboxnolimitmoneyhudquestext = u8'Removes the limit on the amount of money in the HUD if you have more than $999.999.999',
		checkboxsunfix = u8' Bring back the sun',
		checkboxsunfixquestext = u8'Brings back the sun from single player.',
		checkboxgrassfix = u8' Bring back the grass',
		checkboxgrassfixquestext = u8'Returns the grass from the single player game (effects in the settings should be medium +). After shutting down, you must restart the game to remove the grass completely!',
		checkboxmoneyfontfix = u8' Removing Zeros in HUD',
		checkboxmoneyfontfixquestext = u8'Removes zeros in HUD, instead of 000.000.350$ there will be 350$',
		checkboxstarsondisplay = u8' Stars on the screen',
		checkboxstarsondisplayquestext = u8'After enabling this feature, you must restart the game for the stars to appear on the screen.',
		checkboxsensfix = u8' Mouse sensitivity fix',
		checkboxsensfixquestext = u8'Corrects the sensitivity of the mouse along the X and Y axes.',
		checkboxfixblackroads = u8' Fix black roads',
		checkboxfixblackroadsquestext = u8'Fixes the display of black roads at low game settings.',
		checkboxlongarmfix = u8' Fix long arms',
		checkboxlongarmfixquestext = u8'Corrects stretching of the arms on two-wheeled vehicles.',
		------------------------------------ [Other] --------------------------------------------
		buttonclearchat = fa.ERASER..u8' Clear chat',
		buttonclearchatitemhovered = u8'To quickly clear a chat\nenter the following command into the chat: ',
		buttonssmode = fa.CAMERA..u8' SS Mode: ',
		buttonssmodeitemhovered = u8'The function turns on the green screen\nConvenient when you take a screenshot of the situation',
		buttonantiafk = fa.KEYBOARD..u8' AntiAFK: ',
		buttonantiafkitemhovered = fa.EXCLAMATION..u8' The function turns on Anti-AFK\nif you don't need the game not to pause after\ncursing\n(Dangerous, because you can get banned!)',
		buttongivebeer1 = fa.FIRE..u8' Get a bottle of beer',
		buttongivebeer2 = fa.FIRE..u8' Get a bottle of beer 2',
		buttongivesprunk = fa.FIRE..u8' Get Sprunk',
		buttongivecigarette = fa.FIRE..u8' Get a cigarette',
		buttonpiss = fa.WATER..u8' Piss',
		buttonhidetextdraws = fa.EYE_SLASH..u8' Hide textdraws: ',
		buttonhidetextdrawsitemhovered = u8'This function hides all textdraws\nNote: when this function is turned off, not all textdraws will be returned\nOnly those that are redrawn will be returned.'
		------------------------------------ [Settings] --------------------------------------------
		combochangetheme = fa.HOUSE..u8' Changing Theme:',
		sliderroundthemequestext = u8'Changes the window's rounding value (default value is 4.0).',
		sliderroundcompquestext = u8'Changes the rounding value of other window components such as buttons and so on (default value is 2.0).',
		sliderroundmenuquestext = u8'Changes the rounding value of menu selections and childs (default value is 4.0).',
		checkboxdialogstyle = u8' New dialog color',
		checkboxdialogstylequestext = u8' Changes the color of dialog boxes similar to those on the Arizona RP launcher.',
		buttonreloadscript = u8'Reload script ',
		buttonturnoffscript = u8'Turn off script ',
		
	}
}]]

-- Language
local lang_int = new.int(ini.main.language-1)
local lang_list = {u8'English', u8'Óêðà¿íñüêà', u8'Ðóññêèé'}
local lang_items = new['const char*'][#lang_list](lang_list)

local languagebuffer = {
	[1] = {
		------------------------------------ [Menu] --------------------------------------------
		textTab1 = u8' Home',
		textTab2 = u8' Boost FPS', 
		textTab3 = u8' Fixes', 
		textTab4 = u8' Ïðî÷åå', 
		textTab5 = u8' Other',
		------------------------------------ [Settings] --------------------------------------------
		textSwitchOff = u8'Switch off',
		textSwitchOn = u8'Turn on',
		textSwitchOffChat = u8'off',
		textSwitchOnChat = u8'enabled',
		------------------------------------ [Themes] --------------------------------------------
		textTheme1 = u8'Blue',
		textTheme2 = u8'Red',
		textTheme3 = u8'Brown',
		textTheme4 = u8'Aqua',
		textTheme5 = u8'Black',
		textTheme6 = u8'Violet',
		textTheme7 = u8'Dark-orange',
		textTheme8 = u8'Grey',
		textTheme9 = u8'Cherrish',
		textTheme10 = u8'Green',
		textTheme11 = u8'Purple',
		textTheme12 = u8'Dark-green',
		textTheme13 = u8'Orange',
		------------------------------------ [Menu Home] --------------------------------------------
		textSliderSetWeather = u8'Weather',
		textSliderSetSeatherHintText = u8'Changes the game weather to its own.',
		textSliderSetTime = u8'Time',
		textSliderSetTimeHintText = u8'Changes the game time to your own.',
		textCheckboxBlockWeather = u8' Block weather change by the server',
		textCheckboxBlockTime = u8' Block the server from changing the time',
		textComboAnimationMoney = u8' Animation of adding / decreasing money:',
		textSliderAlphaMap = u8' Transparency of the map on the radar:',
		textSliderAlphaMapHintText = u8'Changes the transparency of the map on the radar. The map itself in the ESC menu will be normal (value from 0 to 255).',
		textButtonVsync = u8'vertical sync',
		textVuttonVsyncTextChat = u8'Vertical Sync',
		------------------------------------ [Boost FPS] --------------------------------------------
		textCheckboxPostFX = u8' Disable post-processing',
		textCheckboxPostFXHintText = u8' Disables post-processing if you have a weak PC.',
		textCheckboxDisableEffects = u8' Disable effects',
		textCheckboxDisableEffectsHintText = u8' Disables effects in the game if you have a weak PC.',
		textCollapsingHeaderDrawdist = u8' Render distance',
		textCheckboxGivemedist = u8' Enable the ability to change the rendering',
		textSliderDrawdist = u8' Main draw distance:',
		textSliderDrawdistHintText = u8'Changes the main draw distance.',
		textSliderDrawdistAir = u8' Draw distance in air transport:',
		textSliderDrawdistAirHintText = u8'Changes the draw distance in air transport.',
		textSliderDrawdistPara = u8' Draw distance when using a parachute:',
		textSliderDrawdistParaHintText = u8'Changes the draw distance when using a parachute.',
		textSliderFog = u8' Fog rendering distance:',
		textSliderFogHintText = u8'Changes the fog rendering distance',
		textSliderLod = u8' Lod draw distance:',
		textSliderLodHintText = u8'Changes the draw distance of lods.',
		textCollapsingHeaderCleanMemory = u8' Clearing memory',
		textCheckboxAutoClean = u8' Enable auto clear memory',
		textCheckboxClearInfo = u8' Show memory clear message',
		textSliderLimitMemory = u8'Auto clear limit: %d MB',
		textButtonClearMemory = u8'Clear memory',
		------------------------------------ [Fixes] --------------------------------------------
		textCheckboxFixBloodWood = u8' Fixing blood when wood is damaged',
		textCheckboxFixBloodWoodHintText = u8'Correction of blood when a tree is damaged.',
		textCheckboxNoLimitMoneyHud = u8' Remove the limit on limiting money in the HUD',
		textCheckboxNoLimitMoneyHudHintText = u8'Removes the limit on the amount of money in the HUD if you have more than $999.999.999',
		textCheckboxsunfix = u8' Bring back the sun',
		textCheckboxsunfixquestext = u8'Brings back the sun from single player.',
		textCheckboxgrassfix = u8' Bring back the grass',
		textCheckboxgrassfixquestext = u8'Returns the grass from the single player game (effects in the settings should be medium +). After shutting down, you must restart the game to remove the grass completely!',
		textCheckboxmoneyfontfix = u8' Removing Zeros in HUD',
		textCheckboxmoneyfontfixquestext = u8'Removes zeros in HUD, instead of 000.000.350$ there will be 350$',
		textCheckboxstarsondisplay = u8' Stars on the screen',
		textCheckboxstarsondisplayquestext = u8'After enabling this feature, you must restart the game for the stars to appear on the screen.',
		textCheckboxsensfix = u8' Mouse sensitivity fix',
		textCheckboxsensfixquestext = u8'Corrects the sensitivity of the mouse along the X and Y axes.',
		textCheckboxfixblackroads = u8' Fix black roads',
		textCheckboxfixblackroadsquestext = u8'Fixes the display of black roads at low game settings.',
		textCheckboxlongarmfix = u8' Fix long arms',
		textCheckboxlongarmfixquestext = u8'Corrects stretching of the arms on two-wheeled vehicles.',
		------------------------------------ [Other] --------------------------------------------
		textButtonClearChat = u8' Clear chat',
		textButtonClearChatItemHovered = u8'To quickly clear a chat\nenter the following command into the chat: ',
		textButtonSSmode = u8' SS Mode: ',
		buttonssmodeitemhovered = u8'The function turns on the green screen\nConvenient when you take a screenshot of the situation',
		buttonantiafk = u8' AntiAFK: ',
		buttonantiafkitemhovered = u8' The function turns on Anti-AFK\nif you dont need the game not to pause after\ncursing\n(Dangerous, because you can get banned!)',
		buttongivebeer1 = u8' Get a bottle of beer',
		buttongivebeer2 = u8' Get a bottle of beer 2',
		buttongivesprunk = u8' Get Sprunk',
		buttongivecigarette = u8' Get a cigarette',
		buttonpiss = u8' Piss',
		buttonhidetextdraws = u8' Hide textdraws: ',
		buttonhidetextdrawsitemhovered = u8'This function hides all textdraws\nNote: when this function is turned off, not all textdraws will be returned\nOnly those that are redrawn will be returned.',
		------------------------------------ [Settings] --------------------------------------------
		combochangetheme = u8' Changing Theme:',
		sliderroundthemequestext = u8'Changes the windows rounding value (default value is 4.0).',
		sliderroundcompquestext = u8'Changes the rounding value of other window components such as buttons and so on (default value is 2.0).',
		sliderroundmenuquestext = u8'Changes the rounding value of menu selections and childs (default value is 4.0).',
		textCheckboxdialogstyle = u8' New dialog color',
		textCheckboxdialogstylequestext = u8' Changes the color of dialog boxes similar to those on the Arizona RP launcher.',
		buttonreloadscript = u8'Reload script ',
		buttonturnoffscript = u8'Turn off script ',
		textChooseLanguage = u8'Choose language',
	},
	[2] = {
		------------------------------------ [Menu] --------------------------------------------
		tab1 = u8' Ãîëîâíà',
		tab2 = u8' Ïîêðàù. FPS', 
		tab3 = u8' Âèïðàâëåííÿ', 
		tab4 = u8' ²íøå', 
		tab5 = u8' Íàëàøòóâàííÿ',
		------------------------------------ [Settings] --------------------------------------------
		switchoff = u8'Âèìêíóòè',
		switchon = u8'Óâ³ìêíóòè',
		switchoffchat = u8'âèìê.',
		switchonchat = u8'óâ³ìê.',
		------------------------------------ [Themes] --------------------------------------------
		theme1 = u8'Áëàêèòíà',
		theme2 = u8'×åðâîíà',
		theme3 = u8'Êîðè÷íåâà',
		theme4 = u8'Àêâàìàðèíîâà',
		theme5 = u8'Òåìíà',
		theme6 = u8'Ô³îëåòîâà',
		theme7 = u8'Òåìíî-ïîìàðàí÷åâà',
		theme8 = u8'Ñ³ðà',
		theme9 = u8'Âèøíåâà',
		theme10 = u8'Çåëåíà',
		theme11 = u8'Ïóðïóðíà',
		theme12 = u8'Òåìíî-çåëåíà',
		theme13 = u8'Ïîìàðàí÷åâà',
		------------------------------------ [Menu Home] --------------------------------------------
		slidersetweather = u8'Ïîãîäà',
		slidersetweatherquestext = u8'Çì³íþº ïîãîäó íà âëàñíó.',
		slidersettime = u8'×àñ',
		slidersettimequestext = u8'Çì³íþº ÷àñ íà âëàñíèé.',
		checkboxblockweather = u8'Çàáîðîíÿº ñåðâåðó çì³íþâàòè ïîãîäó.',
		checkboxblocktime = u8'Çàáîðîíÿº ñåðâåðó çì³íþâàòè ÷àñ.',
		comboanimationmoney = u8' Àí³ìàö³ÿ çì³íè ê³ëüêîñò³ ãðîøåé:',
		slideralphamap = u8' Ïðîçîð³ñòü ìàïè íà ðàäàð³:',
		slideralphamapquestext = u8'Çì³íþº ïðîçîð³ñòü ìàïè íà ðàäàð³. Ìàïà â ìåíþ áóäå ìàòè íîðìàëüíèé âèãëÿä (çíà÷åííÿ 0-255).',
		buttonvsync = u8'âåðòèêàëüíà ñèíõð',
		buttonvsynctextchat = u8'Âåðòèêàëüíà ñèõíðîí³çàö³ÿ.',
		------------------------------------ [Boost FPS] --------------------------------------------
		checkboxpostfx = u8'Âèìêíóòè ïîñò-ïðîöåññ³íã',
		checkboxpostfxquestext = u8' Âèìêíóòè ïîñò-ïðîöåññ³íã (ÿêùî ó âàñ ñëàáêèé ÏÊ)',
		checkboxdisableeffects = u8' Âìêíóòè åôôåêòè',
		checkboxdisableeffectsquestext = u8'Âèìêíóòè åôôåêòè (ÿêùî ó âàñ ñëàáêèé ÏÊ).',
		collapsingheaderdrawdist = u8' Äàëüí³ñòü ïðîðèñîâêè',
		checkboxgivemedist = u8' Âìèêàº ìîæëèâ³òü çì³íþâàòè ïðîðèñîâêó.',
		sliderdrawdist = u8' Äèñòàíö³ÿ îñíîâíîãî draw:',
		sliderdrawdistquestext = u8'Çì³íþº äèñòàíö³þ îñíîâíîãî draw.',
		sliderdrawdistair = u8' Äàëüí³ñòü ïðîðèñîâêè â ïîâ. òðàíñïîðò³:',
		sliderdrawdistairquestext = u8'Çì³íþº äàëüí³ñòü ïðîðèñîâêè â ïîâ³òðÿííîìó òðàíñïîðò³.',
		sliderdrawdistpara = u8' Äàëüí³ñòü ïðîðèñîâêè ç ïàðàøóòîì:',
		sliderdrawdistparaquestext = u8'Çì³íþº äàëüí³ñòü ïðîðèñîâêè, ïîêè âèêîðèñòîâóºòå ïàðàøóò.',
		sliderfog = u8' Äàëüí³ñòü ïðîðèñîâêè òóìàíó:',
		sliderfogquestext = u8'Çì³íþº äèñòàíö³þ ïðîðèñîâêè òóìàíó.',
		sliderlod = u8' Äàëüí³ñòü ïðîðèñîâêè ëîä³â:',
		sliderlodquestext = u8'Çì³íþº äèñòàíö³þ ïðîðèñîâêè ëîä³â.',
		collapsingheadercleanmemory = u8' Î÷èñòêà ïàìÿò³.',
		checkboxautoclean = u8' Óâ³ìêíóòè àâòîî÷èùåííÿ ïàìÿò³',
		checkboxclearinfo = u8' Ïîêàçóâàòè ïîâ³äîìëåííÿ ïðî î÷èùåííÿ ïàìÿò³.',
		sliderlimitmemory = u8'Ë³ì³ò àâòîî÷èùåííÿ: %d MB',
		buttonclearmemory = u8'Î÷èñòèòè ïàìÿòü.',
		------------------------------------ [Fixes] --------------------------------------------
		checkboxfixbloodwood = u8' Ïðèáðàòè êðîâ â³ä äåðåâà',
		checkboxfixbloodwoodquestext = u8'Ïðèáèðàº êðîâ ï³ñëÿ "ïîðàíåííÿ äåðåâà".',
		checkboxnolimitmoneyhud = u8' Ïðèáðàòè ë³ì³ò ãðîøåé â HUD',
		checkboxnolimitmoneyhudquestext = u8'Ïðèáèðàº ë³ì³ò ãðîøåé, ÿê³ â³äîáðàæàþòüñÿ íà õóä³ (ë³ì³ò äî: $999.999.999)',
		checkboxsunfix = u8' Ïîâåðíóòè ñîíöå.',
		checkboxsunfixquestext = u8'Ïîâåðòàº ñîíöå ç ñ³íãëïëåºðó.',
		checkboxgrassfix = u8' Ïîâåðíóòè òðàâó.',
		checkboxgrassfixquestext = u8'Ïîâåðòàº òðàâó ç ñ³íãëïëåºðó (åôôåêòè ïîâèíí³ áóòè ì³í³ìóì ñåðåäí³). Ï³ñëÿ âèìêíåííÿ, ïåðåçàïóñò³òü ãðó ùîá îñòàòî÷íî âèìêíóòè òðàâó.',
		checkboxmoneyfontfix = u8' Ïðèáðàòè íóë³ ç HUD',
		checkboxmoneyfontfixquestext = u8'Ïðèáèðàº íóë³ ç HUD, áóëî 000.000.350$, íàòîì³ñòü áóäå 350$',
		checkboxstarsondisplay = u8' Ç³ðêè íà åêðàí³.',
		checkboxstarsondisplayquestext = u8'Ï³ñëÿ óâ³ìêíåííÿ ö³º¿ ôóíêö³¿, ïåðåçàïóñò³òü ãðó, ùîá ç³ðêè ç`ÿâèëèñü..',
		checkboxsensfix = u8' Âèïðàâëåííÿ ÷óòëèâîñò³ ìèø³.',
		checkboxsensfixquestext = u8'Êîðåêòóº ÷óòëèâ³ñòü ìèø³ ïî Õ òà Y â³ñÿì.',
		checkboxfixblackroads = u8' Âèïðàâëåííÿ ÷îðíèõ äîð³ã',
		checkboxfixblackroadsquestext = u8'Âèïðàâëÿº â³äîáðàæåííÿ ÷îðíèõ äîð³ã íà ì³í³àëüíèõ íàëàøòóâàííÿõ.',
		checkboxlongarmfix = u8' Âèïðàâëåííÿ äîâãèõ ðóê',
		checkboxlongarmfixquestext = u8'Êîðåêòóº æàõ ç ðóêàìè íà äâîêîë³ñíîìó òðàíñïîðò³.',
		------------------------------------ [Other] --------------------------------------------
		buttonclearchat = u8' Î÷èñòèòè ÷àò',
		buttonclearchatitemhovered = u8'Ùîá øâèäêî î÷èñòèòè ÷àò\nââåä³òü ñë³äóþ÷ó êîìàíäó â ÷àò: ',
		buttonssmode = u8' ÑÑ ðåæèì: ',
		buttonssmodeitemhovered = u8'Ôóíêö³ÿ âìèêàº çåëåíèé åêðàí\nÇðó÷íî äëÿ ñêð³íøîò-ñèòóàö³é.',
		buttonantiafk = u8' Àíòè-AFK: ',
		buttonantiafkitemhovered = u8' Ôóíêö³ÿ âìèêàº àíòè-AFK\nÿêùî âè õî÷åòå, ùîá ãðà íå âèìèêàëàñü, êîëè çâåðíóòà\n(Ìîæåòå áóòè ïîêàðàíèìè!)',
		buttongivebeer1 = u8' Îòðèìàòè ïëÿøêó ïèâàñèêó.',
		buttongivebeer2 = u8' Îòðèìàòè ïëÿøêó ïèâàñèêó 2.',
		buttongivesprunk = u8' Îòðèìàòè ñïðàíêó.',
		buttongivecigarette = u8' Îòðèìàòè öèãàðêó.',
		buttonpiss = u8' Ïîï³ñÿòè.',
		buttonhidetextdraws = u8' Çàõîâàòè òåêñòäðàâè: ',
		buttonhidetextdrawsitemhovered = u8'Öÿ ôóíêö³ÿ ïðèõîâóº âñ³ òåêñòäðàâè\nÏðèì³òêà: êîëè ôóíêö³ÿ âèìêíåíà, íå âñ³ òåêñòäðàâè ïîâåðíóòüñÿ.\nÏîâåðíóòüñÿ ò³ëüêè ò³, ùî ïåðåìàëþþòüñÿ.',
		------------------------------------ [Settings] --------------------------------------------
		combochangetheme = u8' Çì³íà òåìè:',
		sliderroundthemequestext = u8'Çì³íà çàîêðóãëåííÿ â³êíà (çà çàìîâ÷óâàííÿì 4.0).',
		sliderroundcompquestext = u8'Çì³íà çàîêðóãëåííÿ åëåìåíò³â â³êíà (çà çàìîâ÷óâàííÿì 2.0).',
		sliderroundmenuquestext = u8'Çì³íà çàîêðóãëåííÿ ÷àéëä³â òà ìåíþ âèáîðó (çà çàìîâ÷óâàííÿì 4.0).',
		checkboxdialogstyle = u8' Íîâèé êîë³ð ä³àëîãó',
		checkboxdialogstylequestext = u8' Çì³íþº êîë³ð ä³àëîã³â, êîë³ð ÿêèõ ñõîæèé íà ä³àëîãè ëàóí÷åðà Arizona RP.',
		buttonreloadscript = u8'Ïåðåçàïóñê ñêðèïòó ',
		buttonturnoffscript = u8'Âèìêíóòè ñêðèïò ',
		textChooseLanguage = u8'Îáåð³òü ìîâó',
	},
	[3] = {
		textChooseLanguage = u8'Âûáåðèòå ÿçûê',
	}
}

function translate(str)
	return languagebuffer[ini.main.language][str]
end

local created = false
-----------------------------------------------------------------------
chatcommands = {'c', 's', 'b', 'w', 'r', 'm', 'd', 'f', 'rb', 'fb', 'rt', 'pt', 'ft', 'cs', 'ct', 'fam', 'vr', 'al', 'me', 'do', 'todo', 'seeme', 'fc', 'u', 'jb', 'j', 'jf', 'a', 'o'}
bi = false
-----------------------------------------------------------------------
antiafk = false
local fps = '-'


local item_list = {
	u8"Ñèíÿÿ", 
	u8"Êðàñíàÿ", 
	u8"Êîðè÷íåâàÿ", 
	u8"Àêâà", 
	u8"×åðíàÿ", 
	u8"Ôèîëåòîâàÿ", 
	u8"×åðíî-îðàíæåâàÿ", 
	u8"Ñåðàÿ", 
	u8"Âèøíåâàÿ", 
	u8"Çåëåíàÿ", 
	u8"Ïóðïóðíàÿ", 
	u8"Òåìíî-çåëåíàÿ", 
	u8"Îðàíæåâàÿ"
}
local ImItems = new['const char*'][#item_list](item_list)
local int_item = new.int(ini.themesetting.theme-1)

local tab = new.int(1)
local tabs = {
	fa.HOUSE..u8'\tÃëàâíàÿ', 
	fa.DESKTOP..u8'\tBoost FPS', 
	fa.GEAR..u8'\tÈñïðàâëåíèÿ', 
	fa.LEAF..u8'\tÏðî÷åå', 
	fa.BARS..u8'\tÍàñòðîéêè',
}

local ivar = new.int(ini.main.animmoney-1)
local tbmtext = {
    u8"Áûñòðàÿ",
    u8"Áåç àíèìàöèè",
    u8"Ñòàíäàðòíàÿ",
}
local tmtext = new['const char*'][#tbmtext](tbmtext)

local textscount = 0
local texts = {
	"Òû íàõóÿ íà ìåíÿ íàæàë?", 
	"Ïî åáàëó äàâíî íå ïîëó÷àë?", 
	"Ùà òåáÿ êàê ïèçäàíó íàõóé!", 
	"Ìðàçü áëÿòü, ïåðåñòàâàé!!!",
	"Ñóêà íó âñå, åùå îäèí ðàç è ÿ òåáÿ ïî åáàëó áóäó áèòü!", 
	"*Áü¸ò òåáÿ ïî åáàëó*",
}

local gender = new.int(ini.main.gender)
local arr_gender = {
	u8"Ìóæñêîé", 
	u8"Æåíñêèé",
}
local genders = new['const char*'][#arr_gender](arr_gender)
local book_text = {}

bike = {[481] = true, [509] = true, [510] = true}
moto = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}

local ICON_STYLE = { "solid", "thin", "regular", "light" }
local iconstyle = new.int(ini.themesetting.iconstyle)

local chars = {
	["é"] = "q", ["ö"] = "w", ["ó"] = "e", ["ê"] = "r", ["å"] = "t", ["í"] = "y", ["ã"] = "u", ["ø"] = "i", ["ù"] = "o", ["ç"] = "p", ["õ"] = "[", ["ú"] = "]", ["ô"] = "a",
	["û"] = "s", ["â"] = "d", ["à"] = "f", ["ï"] = "g", ["ð"] = "h", ["î"] = "j", ["ë"] = "k", ["ä"] = "l", ["æ"] = ";", ["ý"] = "'", ["ÿ"] = "z", ["÷"] = "x", ["ñ"] = "c", ["ì"] = "v",
	["è"] = "b", ["ò"] = "n", ["ü"] = "m", ["á"] = ",", ["þ"] = ".", ["É"] = "Q", ["Ö"] = "W", ["Ó"] = "E", ["Ê"] = "R", ["Å"] = "T", ["Í"] = "Y", ["Ã"] = "U", ["Ø"] = "I",
	["Ù"] = "O", ["Ç"] = "P", ["Õ"] = "{", ["Ú"] = "}", ["Ô"] = "A", ["Û"] = "S", ["Â"] = "D", ["À"] = "F", ["Ï"] = "G", ["Ð"] = "H", ["Î"] = "J", ["Ë"] = "K", ["Ä"] = "L",
	["Æ"] = ":", ["Ý"] = "\"", ["ß"] = "Z", ["×"] = "X", ["Ñ"] = "C", ["Ì"] = "V", ["È"] = "B", ["Ò"] = "N", ["Ü"] = "M", ["Á"] = "<", ["Þ"] = ">"
}

------------------------------------ [Êëèíåð ¸áàíûé áëÿòü] --------------------------------------------
local function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function get_memory()
    return round(memory.read(0x8E4CB4, 4, true) / 1048576, 1)
end
-------------------------------------------------------------------------------------------------

local imguiCheckboxesFixesAndPatches = {
    [u8"Èñïðàâëåíèå êðîâè ïðè ïîâðåæäåíèè äåðåâà"] = {var = checkboxes.fixbloodwood, cfg = "fixbloodwood", fnc = "FixBloodWood"},
    [u8"Cíÿòü ëèìèò íà îãðàíè÷åíèå äåíåã â õóäå"] = {var = checkboxes.nolimitmoneyhud, cfg = "nolimitmoneyhud", fnc = "NoLimitMoneyHud"},
    [u8"Âåðíóòü ñîëíöå"] = {var = checkboxes.sunfix, cfg = "sunfix", fnc = "SunFix"},
    [u8"Âåðíóòü òðàâó"] = {var = checkboxes.grassfix, cfg = "grassfix", fnc = "GrassFix"},
    [u8"Âåðíóòü íàçâàíèÿ ðàéîíîâ"] = {var = checkboxes.placename, cfg = "placename", fnc = "PlaceName"},
    [u8"Óäàëåíèå íóëåé â õóäå"] = {var = checkboxes.moneyfontfix, cfg = "moneyfontfix", fnc = "MoneyFontFix"},
    [u8"Çâ¸çäû íà ýêðàíå"] = {var = checkboxes.starsondisplay, cfg = "starsondisplay", fnc = "StarsOnDisplay"},
    [u8"Ôèêñ ÷óâñòâèòåëüíîñòè ìûøêè"] = {var = checkboxes.sensfix, cfg = "sensfix", fnc = "FixSensitivity"},
    [u8"Àíèìàöèè ïðè áåçäåéñòâèè"] = {var = checkboxes.animidle, cfg = "animidle", fnc = "_"},
    [u8"Ôèêñ ÷¸ðíûõ äîðîã"] = {var = checkboxes.fixblackroads, cfg = "fixblackroads", fnc = "FixBlackRoads"},
    [u8"Ôèêñ äëèííûõ ðóê"] = {var = checkboxes.longarmfix, cfg = "longarmfix", fnc = "FixLongArm"},
	[u8"Èñïðàâëåíèå áåãà â èíòåðüåðàõ"] = {var = checkboxes.intrun, cfg = "intrun", fnc = "InteriorRun"},
	[u8"Èñïðàâëåíèå áåëîé òî÷êè íà ïðèöåëå"] = {var = checkboxes.fixcrosshair, cfg = "fixcrosshair", fnc = "FixCrosshair"},
	[u8"Ïàò÷ àíèìàöèè ïðèñåäà ñ îðóæèåì"] = {var = checkboxes.patchduck, cfg = "patchduck", fnc = "PatchDuck"},
	[u8"Âåðíóòü ðàçìûòèå ïðè åçäå"] = {var = checkboxes.blurreturn, cfg = "blurreturn", fnc = "BlurReturn"},
	[u8"Âåðíóòü ðàçìûòèå ïðè åçäå"] = {var = checkboxes.forceaniso, cfg = "forceaniso", fnc = "ForceAniso"},
}

local imguiInputsCmdEditor = {
    [u8"Îòêðûòü ìåíþ ñêðèïòà"] = {var = buffers.cmd_openmenu, cfg = "openmenu"},
    [u8"Ïîêàçàòü íèêè"] = {var = buffers.cmd_shownicks, cfg = "shownicks"},
    [u8"Ïîêàçàòü ÕÏ èãðîêîâ"] = {var = buffers.cmd_showhp, cfg = "showhp"},
    [u8"Î÷èñòèòü ÷àò"] = {var = buffers.cmd_clearchat, cfg = "clearchat"},
    [u8"Ïîêàçàòü/ñêðûòü ÷àò"] = {var = buffers.cmd_showchat, cfg = "showchat"},
    [u8"Ïîêàçàòü/ñêðûòü HUD"] = {var = buffers.cmd_showhud, cfg = "showhud"},
    [u8"Íîâûé öâåò äèàëîãîâûõ îêîí"] = {var = buffers.cmd_dialogstyle, cfg = "dialogstyle"},
}

local listUpdate = {

	{
        v = 'Beta v. 0.83',
        context = "- Äîáàâëåí ïàò÷, êîòîðûé ïîçâîëÿåò ñàäèòñÿ íà êîðòî÷êè ñ ëþáûì îðóæèåì\n- Èñïðàâëåíèå ñèñòåìû îáíîâëåíèÿ\n- Ñèñòåìà ñìàéëîâ è áèíäîâ ïîìåùåíû â îòäåëüíûå îêíà\n- Äîáàâëåíà ñèñòåìà îòûãðîâîê îðóæèÿ\n- Äîáàâëåí ïàò÷ ñ ôîòîàïïàðàòîì ïðè îòêëþ÷åííîé ïîñò-îáðàáîòêå\n- Óáðàí ëèøíèé ìóñîð ñ êîäà"
    },

    {
        v = 'Beta v. 0.8',
        context = "- Äîáàâëåíû àíèìàöèè 2-õ ìèíóòíîãî áåçäåéñòâèÿ êàê â îäèíî÷íîé èãðå\n- Äîáàâëåíà ïàñõàëêà â ñàìîì ìåíþ\n- Äîáàâëåíà ñèñòåìà ñìàéëîâ, áèíäû, íåìíîãî èçìåíåíà êàñòîìèçàöèÿ\n- Âîçâðàùåíû íàçâàíèÿ óëèö è ðàéîíîâ\n- Îáíîâëåíà ñèñòåìà àâòîîáíîâëåíèé (òåïåðü îáíîâëåíèå áóäåò ñêà÷àíî ïîñëå òîãî êàê íàæìåòå êíîïêó 'Îáíîâèòü')\n- Äîáàâëåí ëîã îáíîâëåíèé\n- Ôèêñû ìåëêèõ áàãîâ"
    },

    {
        v = 'Beta v. 0.7',
        context = "- Ñêðèïò ïåðåïèñàí ñ Imgui íà Mimgui äëÿ îïòèìèçàöèè\n- Äîáàâëåíî óäîáíîå ìåíþ ñ ôóíêöèÿìè, ïî òèïó FPS UP, êàñòîìèçàöèÿ èíòåðôåéñà, èçìåíåíèå êîìàíä ñêðèïòà è ò.ä.\n- Áûëà ïðîâåäåíà ÷èñòêà êîäà\n- Äîáàâëåí gotofunc by Gorskin\n- Äîáàâëåíà ôóíêöèÿ ðàçäåëåíèÿ äëèííîãî ñîîáùåíèÿ â ÷àò íà äâà by Gorskin\n- Ìíîãî ôèêñîâ"
    },

    {
        v = 'Beta v. 0.6',
        context = "- Äîáàâëåíî ñêðûòèå îïèñàíèÿ by Cosmo\n- Àâòîîáíîâëåíèå\n- Äîáàâëåíà ïðîâåðêà íà àâòîðà\n- Âûâîä òåêñòà â ÷àò òîëüêî ïîñëå òîãî, êàê èãðîê ïîäêëþ÷èòñÿ ê ñåðâåðó\n- Ñêðèïò ïåðåïèñàí íà Imgui"
    },

    {
        v = 'Beta v. 0.5',
        context = "- Ôèêñ êîíôèãóðàöèè v.2\n- Äîáàâëåíà âîçìîæíîñòü èçìåíÿòü öâåò äèàëîãîâûõ îêîí\n- Áûë äîáàâëåí ïàò÷ ðàäàðà â ñëåæêå\n- Äèàëîãîâûå îêíà òåïåðü ìîæíî ïåðåìåùàòü ïî ýêðàíó\n- Áûëî äîáàâëåíî ñêðûòèå ïàðîëÿ îò áàíêîâñêîé êàðòû è êîäà ñêëàäñêèõ ïîìåùåíèé"
    },

    {
        v = 'Beta v. 0.4',
        context = "- Ôèêñ êîíôèãóðàöèè"
    },

    {
        v = 'Beta v. 0.3',
        context = "- Èñïðàâëåíèå áëîê. êëàâèø Alt + Enter, êîòîðûé âûçûâàë êðàø ó ìíîãèõ\n- Äîáàâëåíèå ïàò÷à, êîòîðûé ïîçâîëÿë çàïóñêàòü èãðó çà ñ÷èòàííûå ñåêóíäû"
    },

    {
        v = 'Beta v. 0.2',
        context = "- Èñïðàâëåíû äèàëîãè\n- Èçìåíåíû àäðåñà ïàìÿòè\n- Îïòèìèçàöèÿ\n- Åùå ôèêñû ÷åãî-òî"
    },

    {
        v = 'Beta v. 0.1',
        context = "- Çàïóñê áåòà-òåñòà ñêðèïòà"
    },
}

function get_samp_version()
    if samp_base == nil or samp_base == 0 then
        samp_base = getModuleHandle("samp.dll")
    end

    if samp_base ~= 0 then
        local e_lfanew = ffi.cast("long*", samp_base + 60)[0]
        local nt_header = samp_base + e_lfanew
        local entry_point_addr = ffi.cast("unsigned int*", nt_header + 40)[0]
        if entry_point_addr == 0x31DF13 then
            return "r1"
        elseif entry_point_addr == 0x3195DD then
            return "r2"
        elseif entry_point_addr == 0xCC4D0 then
            return "r3"
       	elseif entry_point_addr == 0xCBCB0 then
            return "r4"
        elseif entry_point_addr == 0xFDB60 then
            return "dl"
        end
    end

    return "unknown"
end

function setDialogColor(l_up, r_up, l_low, r_bottom) --by stereoliza (Heroku) (https://www.blast.hk/threads/13380/post-621933)
	local memhuy = { ["r1"] = 0x21A0B8, ["r2"] = 0x21A0B8, ["r3"] = 0x26E898, ["r4"] = 0x26E9C8, ["dl"] = 0x2AC9E0 }
	for k,v in pairs(memhuy) do
		if get_samp_version() == k then memhuy = v end
	end
	local CDialog = memory.getuint32(getModuleHandle("samp.dll") + memhuy)
	local CDXUTDialog = memory.getuint32(CDialog + 0x1C)
	memory.setuint32(CDXUTDialog + 0x12A, l_up, true) -- Ëåâûé óãîë
	memory.setuint32(CDXUTDialog + 0x12E, r_up, true) -- Ïðàâûé âåðõíèé óãîë
	memory.setuint32(CDXUTDialog + 0x132, l_low, true) -- Íèæíèé ëåâûé óãîë
	memory.setuint32(CDXUTDialog + 0x136, r_bottom, true) -- Ïðàâûé íèæíèé óãîë
end

function SetClassSelectionColors(lt, rt, lb, rb) -- by ARMOR (https://www.blast.hk/threads/13380/post-1104630)
	memhuy = { ["r1"] = 0x21A18C, ["r2"] = 0x21A194, ["r3"] = 0x26E974, ["r4"] = 0x26EAA4, ["dl"] = 0x2ACABC }
	for k,v in pairs(memhuy) do
		if get_samp_version() == k then memhuy = v end
	end
    local class_selection_ptr = memory.getuint32(sampGetBase() + memhuy, true)
    memory.setuint32(class_selection_ptr + 0x12A, rb, true)
    memory.setuint32(class_selection_ptr + 0x12E, lb, true)
    memory.setuint32(class_selection_ptr + 0x132, rt, true)
    memory.setuint32(class_selection_ptr + 0x136, lt, true)
end

function OffChatBack()
	memhuy = { ["r1"] = 0x65E88, ["r2"] = 0x65F58, ["r3"] = 0x693B8, ["r4"] = 0x69AE8, ["dl"] = 0x69568 }
	for k,v in pairs(memhuy) do
		if get_samp_version() == k then
			memhuy = v
		end
	end
	memory.fill(getModuleHandle("samp.dll") + memhuy, 0x90, 5, true)
end
OffChatBack()
------------------------------------------ [àíèìàöèÿ áåçäåéñòâèÿ by vegas~ (https://www.blast.hk/threads/151523/)]
local player = {
    mainTime = 0,
    time = 0,
    pos = {x = 0, y = 0, z = 0},
    anims = {
        {file = "PLAYIDLES", name = "SHIFT"},
        {file = "PLAYIDLES", name = "SHLDR"},
        {file = "PLAYIDLES", name = "STRETCH"},
        {file = "PLAYIDLES", name = "STRLEG"},
        {file = "PLAYIDLES", name = "TIME"},
        {file = "BENCHPRESS", name = "GYM_BP_CELEBRATE"},
        {file = "PED", name = "XPRESSSCRATCH"},
    },
}

local waitForIdle = 120

player.thePlayerUpdate = function()
    player.time = os.clock() + waitForIdle
end

player.thePlayer = function()
    if not isCharOnFoot(1) then
        return
    end

    local speed = getCharSpeed(1)
    local x, y, z = getActiveCameraCoordinates()

    if speed > 0 or x ~= player.pos.x or y ~= player.pos.y or z ~= player.pos.z then

        if player.mainTime ~= 0 and player.mainTime < os.clock() then
            clearCharTasksImmediately(1)
        end

        player.mainTime = os.clock() + waitForIdle
        player.thePlayerUpdate()
    end

    player.pos.x, player.pos.y, player.pos.z = x, y, z

    if player.time < os.clock() then
        player.thePlayerUpdate()

        local choosedAnim = player.anims[math.random(#player.anims)]

        if choosedAnim.file ~= "PED" then
            requestAnimation(choosedAnim.file)
        end
        taskPlayAnim(1, choosedAnim.name, choosedAnim.file, 1, false, false, false, false, -1)
        taskPlayAnim(1, choosedAnim.name, choosedAnim.file, 1, false, false, false, false, -1)
    end

end

------------------------------------------ [àíèìàöèÿ áåçäåéñòâèÿ by vegas~ (https://www.blast.hk/threads/151523/)]
local ui_meta = {
    __index = function(self, v)
        if v == "switch" then
            local switch = function()
                if self.process and self.process:status() ~= "dead" then
                    return false -- // Ïðåäûäóùàÿ àíèìàöèÿ åù¸ íå çàâåðøèëàñü!
                end
                self.timer = os.clock()
                self.state = not self.state

                self.process = lua_thread.create(function()
                    local bringFloatTo = function(from, to, start_time, duration)
                        local timer = os.clock() - start_time
                        if timer >= 0.00 and timer <= duration then
                            local count = timer / (duration / 100)
                            return count * ((to - from) / 100)
                        end
                        return (timer > duration) and to or from
                    end

                    while true do wait(0)
                        local a = bringFloatTo(0.00, 1.00, self.timer, self.duration)
                        self.alpha = self.state and a or 1.00 - a
                        if a == 1.00 then break end
                    end
                end)
                return true -- // Ñîñòîÿíèå îêíà èçìåíåíî!
            end
            return switch
        end
 
        if v == "alpha" then
            return self.state and 1.00 or 0.00
        end
    end
}

local riverya = { state = false, duration = 0.4555 }
setmetatable(riverya, ui_meta)

local riveryabook = { state = false, duration = 0.4555 }
setmetatable(riveryabook, ui_meta)

CloseButton = function(str_id, value, rounding) -- by Gorskin (edit) (https://www.blast.hk/members/157398/)
	size = size or 20
	rounding = rounding or 5
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	
	local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size, size))
	if result then
		value[0] = false
	end
	local hovered = imgui.IsItemHovered()

    local col = imgui.GetColorU32Vec4(hovered and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
	local col_bg = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
	local offs = (size / 4.2)
	--DL:AddRectFilled(p, imgui.ImVec2(p.x + size+1, p.y + size), col_bg, rounding, 5)
	
	DL:AddLine(
		imgui.ImVec2(p.x + offs, p.y + offs), 
		imgui.ImVec2(p.x + size - offs, p.y + size - offs), 
		col,
		size / 10
	)
	DL:AddLine(
		imgui.ImVec2(p.x + size - offs, p.y + offs), 
		imgui.ImVec2(p.x + offs, p.y + size - offs),
		col,
		size / 10
	)
	return result
end
-----------------------------------------------------------------------------------------------------

function update() -- by chapo (https://www.blast.hk/threads/114312/)
    local raw = 'https://raw.githubusercontent.com/riverya4life/SAMPFixer/main/sampfixerautoupd.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                --print('Ñêà÷èâàþ '..decodeJson(response.text)['url']..' â '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
					sampAddChatMessage(script_name.."{FFFFFF} Ñêðèïò {42B166}óñïåøíî îáíîâëåí{ffffff}! Ïåðåçàãðóçêà...", 0x73b461)
                    thisScript():reload()
                end
            end)
        else
			sampAddChatMessage(script_name.."{dc4747}[Îøèáêà]{ffffff} Íåâîçìîæíî óñòàíîâèòü îáíîâëåíèå! Êîä îøèáêè: {dc4747}"..response.status_code, 0x73b461)
        end
    end
    return f
end

function onSystemInitialized()
    memory.fill(0x5557CF, 0x90, 7, true) -- binthesky by DK
    writeMemory(0x5B8E55, 4, 0x15F90, true)--flickr
    writeMemory(0x5B8EB0, 4, 0x15F90, true)--flickr
    memory.setfloat(0xB5FCC8, 0.20, true)--AudioFix, fixes a bug due to which the sounds of the audio stream were not heard if the user had the radio turned off in the game settings and after changing the sound settings there was still no sound, it was necessary to re-enter the game.
    writeMemory(0x5EFFE7, 1, 0xEB, true)-- disable talking
    writeMemory(0x53E94C, 1, 1, true) --del fps delay 14 ms
    writeMemory(0x745BC9, 2, 0x9090, true) --SADisplayResolutions(1920x1080// 16:9)
    memory.fill(0x47C8CA, 0x90, 5, true) -- fix cj bug
    memory.write(12761548, 1051965045, 4, true) --car speed fps fix
    memory.fill(0x555854, 0x90, 5, true) --InterioRreflections
	memory.fill(0x460773, 0x90, 7, false) --CJFix
	memory.setint8(0x58D3DA, 1, true) -- Ìåíÿåò ðàçìåð îáâîäêè displayGameText
	memory.fill(0x00531155, 0x90, 5, true) -- Ôèêñ ïðûæêà â ôîíîâîì ðåæèìå ñ AntiAFK
	writeMemory(0x460500, 1, 0xC3, true) -- no replay
	memory.fill(0x748E6B, 0x90, 5, true) -- CGame::Shutdown
	memory.fill(0x748E82, 0x90, 5, true) -- RsEventHandler rsRWTERMINATE
	memory.fill(0x748E75, 0x90, 5, true) -- CAudioEngine::Shutdown
	writeMemory(7547174, 4, 8753112, true) -- limit lod veh
	memory.setuint8(0x588550, 0xEB, true) -- enable this-blip
	memory.setuint32(0x58A4FE + 0x1, 0x0, true) -- disable arrow
	memory.setuint32(0x586A71 + 0x1, 0x0, true) -- disable green rect 
	memory.setuint8(0x58A5D2 + 0x1, 0x0, true) -- disable height indicator
	memory.setuint32(0x58A73B + 0x1, 0x0, true) -- disable height indicator
	
	memory.copy(0x8D0444, memory.strptr("\x36\x46\x45\x50\x5F\x52\x45\x53\x00\x0B\x00\x00\x40\x01\xAA\x00\x03\x00\x05\x46\x45\x48\x5F\x4D\x41\x50\x00\x0B\x05\x00\x40\x01\xC8\x00\x03\x00\x05\x46\x45\x50\x5F\x4F\x50\x54\x00\x0B\x21\x00\x40\x01\xE6\x00\x03\x00\x05\x46\x45\x50\x5F\x51\x55\x49\x00\x0B\x23\x00\x40\x01\x04\x01\x03\x00"), 72)
	memory.fill(0x8D048C, 0, 144)
	memory.write(0x8CE47B, 1, 1)
	memory.write(0x8CFD33, 2, 1)
	memory.write(0x8CFEF7, 3, 1)
	
	if memory.getuint8(0x748C2B) == 0xE8 then
		memory.fill(0x748C2B, 0x90, 5, true)
	elseif memory.getuint8(0x748C7B) == 0xE8 then
		memory.fill(0x748C7B, 0x90, 5, true)
	end
	if memory.getuint8(0x5909AA) == 0xBE then
		memory.write(0x5909AB, 1, 1, true)
	end
	if memory.getuint8(0x590A1D) == 0xBE then
		memory.write(0x590A1D, 0xE9, 1, true)
		memory.write(0x590A1E, 0x8D, 4, true)
	end
	if memory.getuint8(0x748C6B) == 0xC6 then
		memory.fill(0x748C6B, 0x90, 7, true)
	elseif memory.getuint8(0x748CBB) == 0xC6 then
		memory.fill(0x748CBB, 0x90, 7, true)
	end
	if memory.getuint8(0x590AF0) == 0xA1 then
		memory.write(0x590AF0, 0xE9, 1, true)
		memory.write(0x590AF1, 0x140, 4, true)
	end
end

ffi.cdef [[
	typedef unsigned long HANDLE;
	typedef HANDLE HWND;
	typedef struct _RECT {
		long left;
		long top;
		long right;
		long bottom;
	} RECT, *PRECT;

	HWND GetActiveWindow(void);

	bool GetWindowRect(
		HWND   hWnd,
		PRECT lpRect
	);

	bool ClipCursor(const RECT *lpRect);

	bool GetClipCursor(PRECT lpRect);
]]

local rcClip, rcOldClip = ffi.new('RECT'), ffi.new('RECT')

function riveryahello()
	if ini.main.riveryahellomsg then
		sampAddChatMessage(script_name.."{FFFFFF} Çàãðóæåí! Îòêðûòü ìåíþ: {dc4747}"..table.concat(rkeys.getKeysName(ActOpenMenuKey.v), " + ").."{ffffff} èëè {dc4747}"..ini.commands.openmenu..". {FFFFFF}Àâòîð: {dc4747}"..script_author, 0x73b461)
	end
	local lastver = update():getLastVersion()
    if thisScript().version < lastver then
		updatesavaliable = true
        sampRegisterChatCommand('riveryaupd', function()
            update():download()
        end)
		sampAddChatMessage(script_name..'{ffffff} Âûøëî îáíîâëåíèå ñêðèïòà ({dc4747}'..thisScript().version..'{ffffff} -> {42B166}'..lastver..'{ffffff}), ââåäèòå {dc4747}/riveryaupd{ffffff} äëÿ îáíîâëåíèÿ...', 0x73b461)
		sampAddChatMessage(script_name..'{ffffff} ...èëè ïî íàæàòèþ êíîïêè â ìåíþ!', 0x73b461)
		addOneOffSound(0, 0, 0, 1058)
	end
	if thisScript().version > lastver then
		updatesavaliable = false
	end
end

function main()
    repeat wait(100) until isSampAvailable()
	gotofunc("all") -- load all func
	updatefps()
	if sampIsLocalPlayerSpawned() then unload = true end
	
	--------------------- [ dual monitor fix] --------------
	ffi.C.GetWindowRect(ffi.C.GetActiveWindow(), rcClip);
	ffi.C.ClipCursor(rcClip);
	--------------------------------------------------------
	
	_, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) -- íàø íèê êð÷
	
	-- rp guns by Gorskin --------------------
	rp_thread = lua_thread.create_suspended(rp_weapons)
    rp_thread:run()
	-- rp guns by Gorskin --------------------
	
	local duration = 0.3 -- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
	local max_alpha = 255 -- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
	local start = os.clock() -- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
	local finish = nil -- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
	
	flymode = 0 -- Êàìõàê by sanek a.k.a Maks_Fender, edited by ANIKI
	speed = 1.0 -- Êàìõàê by sanek a.k.a Maks_Fender, edited by ANIKI
	radarHud = 0 -- Êàìõàê by sanek a.k.a Maks_Fender, edited by ANIKI
	time = 0 -- Êàìõàê by sanek a.k.a Maks_Fender, edited by ANIKI
	keyPressed = 0 -- Êàìõàê by sanek a.k.a Maks_Fender, edited by ANIKI
	
	gotofunc("all")--load all func
	
	sampRegisterChatCommand('fcrash', function()
        fcrash = not fcrash
		printStringNow(fcrash and '~g~ON' or '~r~OFF',1000)
    end)

	---=== HotKeys ===---
	bindOpenmenu = rkeys.registerHotKey(ActOpenMenuKey.v, true, function()
        if not sampIsCursorActive() then
            riverya.switch()
        end
    end)
    ---=== HotKeys ===---
	book()
	
	-- àíèìàöèÿ áåçäåéñòâèÿ by vegas~ (https://www.blast.hk/threads/151523/)
	for i, k in pairs(player.anims) do
        if k.file ~= "PED" then
            requestAnimation(k.file)
        end
    end
	
	addEventHandler('onWindowMessage', function(msg, wparam, lparam)
		if riverya.state or riveryabook.state then
			if msg == 0x100 or msg == 0x101 then
				if (wparam == VK_ESCAPE and riverya.state) and not isPauseMenuActive() then
					consumeWindowMessage(true, false) if msg == 0x101 then riverya.switch() end
				elseif (wparam == VK_ESCAPE and riveryabook.state) and not isPauseMenuActive() then
					consumeWindowMessage(true, false) if msg == 0x101 then riveryabook.switch() end
				end
			end
		end
		
		if ini.nop_samp_keys.key_ALTENTER and msg == 261 and wparam == 13 then
			consumeWindowMessage(true, true)
		end

		if not sampIsDialogActive() then
			return
		end

		if msg == wm.msg.WM_LBUTTONDOWN then
			local curX, curY = getCursorPos()
			local x, y = sampGetDialogPos()
			local w = sampGetDialogSize()
			local h = sampGetDialogCaptionHeight()
			if (curX >= x and curX <= x + w and curY >= y and curY <= y + h) then
				dragging = true
				dragX = x - curX
				dragY = y - curY
			end
		elseif msg == wm.msg.WM_LBUTTONUP then
			dragging = false
		elseif msg == wm.msg.WM_MOUSEMOVE and dragging then
			local curX, curY = getCursorPos()
			local _, scrY = getScreenResolution()
			local nextX, nextY = curX + dragX, curY + dragY

			nextY = math.min(math.max(nextY, -15), scrY - 15)

			sampSetDialogPos(nextX, nextY)
		end
	end)

    while true do
        wait(0)
		
		if fcrash == true then
		    for angle = 1, 10, 1 do
			    ShowMessage("Îøèáêà âûïîëíåíèÿ! \n \nÏðîãðàììà: " ..getGameDirectory().. "\\gta_sa.exe \n \nÝòî ïðèëîæåíèå çàïðîñèëî ó ñðåäû âûïîëíåíèÿ íåîáû÷íîå çàâåðøåíèå åãî ðàáîòû. \nÏîæàëóéñòà, ñâÿæèòåñü ñî ñëóæáîé ïîääåðæêè ïðèëîæåíèÿ äëÿ ïîëó÷åíèÿ äîïîëíèòåëüíîé èíôîðìàöèè.", "Microsoft Visual C++ Runtime Library", 0x10)
            end
			fcrash = not fcrash
		end
		
		if ini.fixes.animidle then
			player.thePlayer() -- àíèìàöèÿ áåçäåéñòâèÿ by vegas~ (https://www.blast.hk/threads/151523/)
		end
		
		local car = storeCarCharIsInNoSave(playerPed)
		if car > 0 then
			setCarDrivingStyle(car, 5)
		end
		
		onspawned = sampGetGamestate() == 3
		if onspawned then
			if offspawnchecker == true then			
				riveryahello()
				welcome_text = 'WelCUM to the gym'
				printStyledString("~n~~n~~n~~n~~n~~n~~w~"..welcome_text.."~n~~b~", 500, 2)
			offspawnchecker = false
			end
		end
		
		if script_author ~= 'riverya4life.' then
			--for angle = 1, 10, 1 do
			ShowMessage("Îøèáêà âûïîëíåíèÿ! \n \nÏðîãðàììà: " ..getGameDirectory().. "\\moonloader\\samp.lua \n \nÝòî ïðèëîæåíèå çàïðîñèëî ó ñðåäû âûïîëíåíèÿ íåîáû÷íîå çàâåðøåíèå åãî ðàáîòû. \nÏîæàëóéñòà, ñâÿæèòåñü ñî ñëóæáîé ïîääåðæêè ïðèëîæåíèÿ äëÿ ïîëó÷åíèÿ äîïîëíèòåëüíîé èíôîðìàöèè.\n\nÍó à âîîáùå, ðèâåðÿ ïèäîðàñ áëÿòü ¸áàíûé.", "Microsoft Visual C++ Runtime Library", 0x10)
			--end
			--thisScript():unload()
			callFunction(0x823BDB , 3, 3, 0, 0, 0)
		end
		
		local chatstring = sampGetChatString(99)
        if chatstring == "Server closed the connection." or chatstring == "You are banned from this server." or chatstring == "Ñåðâåð çàêðûë ñîåäèíåíèå." or chatstring == "Âû çàáàíåíû íà ýòîì ñåðâåðå." then
	    sampDisconnectWithReason(false)
            sampAddChatMessage("Ïåðåïîäêëþ÷åíèå...", 0xa9c4e4)
            wait(15000) -- çàäåðæêà
            sampSetGamestate(1)
        end
		
		if ini.fixes.blurreturn then
			car = storeCarCharIsInNoSave(PLAYER_PED)
			if isCharInCar(PLAYER_PED, car) then
				speed = getCarSpeed(car)
				if speed >= 120.0 then
					shakeCam(1.0)
				end
			end
		end
		
		
		--------------------- [ dual monitor fix] --------------
		if msg == wm.WM_KILLFOCUS then
			ffi.C.GetClipCursor(rcOldClip);
			ffi.C.ClipCursor(rcOldClip);
		elseif msg == wm.WM_SETFOCUS then
			ffi.C.GetWindowRect(ffi.C.GetActiveWindow(), rcClip);
			ffi.C.ClipCursor(rcClip);
		end
		--------------------------------------------------------
        ---------------- -- ïðèöåë íà òðàíñïîðòå by Cosmo (https://www.blast.hk/threads/72683/)
		if isCharInAnyCar(playerPed) then
			local car = storeCarCharIsInNoSave(playerPed)
			local cX, cY, cZ = getCarCoordinates(car)
			if vehHaveGun() then
				fX, fY, fZ = getOffsetFromCarInWorldCoords(car, 0, 128, 0)
				local result, tPoint = processLineOfSight(cX, cY, cZ, fX, fY, fZ, true, false, true, true, false, false, false, true)
				if result then fX, fY, fZ = tPoint.pos[1], tPoint.pos[2], tPoint.pos[3] end
				local _, gx, gy, z, _, _ = convert3DCoordsToScreenEx(fX, fY, fZ)
				if z > 1 then renderCrosshair(gx, gy) end
			elseif isCharInModel(playerPed, 432) then
				local oX, oY, oZ = getOffsetFromCarInWorldCoords(car, 0, 0, 1.1)
		        if not rail then rail = createObject(1551, oX, oY, oZ) end
		        if rail then
		        	local x, y = getRhinoCannonCorner(car)
			        attachObjectToCar(rail, car, 0.0, 0.0, 1.1, y, 0.0, x)
			        local x1, y1, z1 = getOffsetFromObjectInWorldCoords(rail, 0.0, 6.5, 0.0)
			        local x2, y2, z2 = getOffsetFromObjectInWorldCoords(rail, 0.0, 67.0, .0)
			        local result, tPoint = processLineOfSight(x1, y1, z1, x2, y2, z2, true, false, true, true, false, false, false, true)
					if result then x2, y2, z2 = tPoint.pos[1], tPoint.pos[2], tPoint.pos[3] end
					local _, gx, gy, z, _, _ = convert3DCoordsToScreenEx(x2, y2, z2)
					if z > 1 then renderCrosshair(gx, gy) end
				end
			end
		else
			if rail then deleteObject(rail); rail = nil end
		end
        ----------------
		
		if ini.main.camhack then
			time = time + 1
			if isKeyDown(VK_C) and isKeyDown(VK_1) then
				if flymode == 0 then
					--setPlayerControl(playerchar, false)
					displayRadar(false)
					displayHud(false)	    
					posX, posY, posZ = getCharCoordinates(playerPed)
					angZ = getCharHeading(playerPed)
					angZ = angZ * -1.0
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
					angY = 0.0
					--freezeCharPosition(playerPed, false)
					--setCharProofs(playerPed, 1, 1, 1, 1, 1)
					--setCharCollision(playerPed, false)
					lockPlayerControl(true)
					flymode = 1
				--	sampSendChat('/anim 35')
				end
			end
			if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
				offMouX, offMouY = getPcMouseMovement()  
				  
				offMouX = offMouX / 4.0
				offMouY = offMouY / 4.0
				angZ = angZ + offMouX
				angY = angY + offMouY

				if angZ > 360.0 then angZ = angZ - 360.0 end
				if angZ < 0.0 then angZ = angZ + 360.0 end

				if angY > 89.0 then angY = 89.0 end
				if angY < -89.0 then angY = -89.0 end   

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)

				curZ = angZ + 180.0
				curY = angY * -1.0      
				radZ = math.rad(curZ) 
				radY = math.rad(curY)                   
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 10.0     
				cosZ = cosZ * 10.0       
				sinY = sinY * 10.0                       
				posPlX = posX + sinZ 
				posPlY = posY + cosZ 
				posPlZ = posZ + sinY              
				angPlZ = angZ * -1.0
				--setCharHeading(playerPed, angPlZ)

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)

				if isKeyDown(VK_W) then      
					radZ = math.rad(angZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed  
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0         
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)

				if isKeyDown(VK_S) then  
					curZ = angZ + 180.0
					curY = angY * -1.0      
					radZ = math.rad(curZ) 
					radY = math.rad(curY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed                       
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)
				  
				if isKeyDown(VK_A) then  
					curZ = angZ - 90.0
					radZ = math.rad(curZ)
					radY = math.rad(angY)
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)
					sinZ = sinZ * speed
					cosZ = cosZ * speed
					posX = posX + sinZ
					posY = posY + cosZ
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY
				pointCameraAtPoint(poiX, poiY, poiZ, 2)       

				if isKeyDown(VK_D) then  
					curZ = angZ + 90.0
					radZ = math.rad(curZ)
					radY = math.rad(angY)
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed
					cosZ = cosZ * speed
					posX = posX + sinZ
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)   

				if isKeyDown(VK_SPACE) then  
					posZ = posZ + speed
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2) 

				if isKeyDown(VK_SHIFT) then  
					posZ = posZ - speed
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				end 

				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2) 

				if keyPressed == 0 and isKeyDown(VK_F10) then
					keyPressed = 1
					if radarHud == 0 then
						displayRadar(true)
						displayHud(true)
						radarHud = 1
					else
						displayRadar(false)
						displayHud(false)
						radarHud = 0
					end
				end

				if wasKeyReleased(VK_F10) and keyPressed == 1 then keyPressed = 0 end

				if isKeyDown(187) then 
					speed = speed + 0.01
					printStringNow(speed, 1000)
				end 
							   
				if isKeyDown(189) then 
					speed = speed - 0.01 
					if speed < 0.01 then speed = 0.01 end
					printStringNow(speed, 1000)
				end   

				if isKeyDown(VK_C) and isKeyDown(VK_2) then
					--setPlayerControl(playerchar, true)
					displayRadar(true)
					displayHud(true)
					radarHud = 0	    
					angPlZ = angZ * -1.0
					--setCharHeading(playerPed, angPlZ)
					--freezeCharPosition(playerPed, false)
					lockPlayerControl(false)
					--setCharProofs(playerPed, 0, 0, 0, 0, 0)
					--setCharCollision(playerPed, true)
					restoreCameraJumpcut()
					setCameraBehindPlayer()
					flymode = 0     
				end
			end
		end
        ----------------
		if ini.main.bindkeys then
			if isCharOnAnyBike(playerPed) and isKeyCheckAvailable() and isKeyDown(0xA0) then	-- onBike&onMoto SpeedUP [[LSHIFT]] by checkdasound --
				if bike[getCarModel(storeCarCharIsInNoSave(playerPed))] then
					setGameKeyState(16, 255)
					wait(10)
					setGameKeyState(16, 0)
				elseif moto[getCarModel(storeCarCharIsInNoSave(playerPed))] then
					setGameKeyState(1, -128)
					wait(10)
					setGameKeyState(1, 0)
				end
			end
			
			if isCharOnFoot(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then -- onFoot&inWater SpeedUP [[1]] by checkdasound --
				setGameKeyState(16, 256)
				wait(10)
				setGameKeyState(16, 0)
			elseif isCharInWater(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then
				setGameKeyState(16, 256)
				wait(10)
				setGameKeyState(16, 0)
			end
			
			if isKeyJustPressed(VK_L) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/lock") 
			end

			if isKeyJustPressed(VK_K) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/key") 
			end

			if isKeyJustPressed(VK_X) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/style") 
			end
			
			if isKeyJustPressed(VK_P) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/phone") 
			end

			if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/mask") 
			end

			if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/armour") 
			end
			
			if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/anim 3") 
			end
					   
			if isKeyJustPressed(VK_Z) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/usedrugs 1") 
			end
			 
			if isKeyDown(VK_MENU) and isKeyJustPressed(VK_NUMPAD3) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/eat") 
			end

			if isKeyDown(VK_MENU) and isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/repcar") 
			end

			if isKeyDown(VK_MENU) and isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
				sampSendChat("/fillcar") 
			end
		end
        ----------------
        if ini.hphud.active == true then
            if sampIsLocalPlayerSpawned() and not created and sampIsChatVisible() and ini.main.showhud == true then
                if ini.hphud.mode == 1 then
                    sampTextdrawCreate(2029, "_", getposhphud(), 66.500)
                    created = true
                elseif ini.hphud.mode == 2 then
                    sampTextdrawCreate(2029, "_", getposhphud(), 66.500)
                    created = true
                end
            elseif sampIsLocalPlayerSpawned() and created and not sampIsChatVisible() or ini.main.showhud ~= true then
                sampTextdrawDelete(2029)
            end
            if created and not sampTextdrawIsExists(2029) then
                created = false
            end
			local car = storeCarCharIsInNoSave(playerPed)
			if car > 0 then
				setCarDrivingStyle(car, 5)
			end
            if created then
                sampTextdrawSetLetterSizeAndColor(2029, 0.270, 0.900, 4294967295)
                if ini.hphud.mode == 1 then
                    sampTextdrawSetPos(2029, getposhphud(), 66.500)
                elseif ini.hphud.mode == 2 then
                    sampTextdrawSetPos(2029, getposhphud(), 76.500)
                end
                sampTextdrawSetStyle(2029, ini.hphud.text)
                sampTextdrawSetAlign(2029, ini.hphud.pos)
                sampTextdrawSetOutlineColor(2029, 1, 4278190080)
                if ini.hphud.active and not sampIsScoreboardOpen() then
                    local hp = getCharHealth(playerPed)
                    sampTextdrawSetString(2029, hp..""..stringhphud('hp'))
                else
                    sampTextdrawSetString(2029, "_")
                end
            end
        end
        ---------------- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if result then
			finish = nil
			local id = select(2, sampGetPlayerIdByCharHandle(ped))
			if pool[id] ~= nil then
				if active == nil then start = os.clock() end
				local alpha = saturate(((os.clock() - start) / duration) * max_alpha)
				local color = join_argb((os.clock() - start) <= duration and alpha or max_alpha, 204, 204, 204)
				active = pool[id]
				sampCreate3dTextEx(pool[id].id, pool[id].text, color, pool[id].pos.x, pool[id].pos.y, pool[id].pos.z, pool[id].dist, pool[id].wall, pool[id].PID, -1)
			else
				if active == nil then start = os.clock() end
				local alpha = saturate(((os.clock() - start) / duration) * max_alpha)
				local color = join_argb((os.clock() - start) <= duration and alpha or max_alpha, 204, 204, 204)
				active = {id = 13, text = no_description_text, col = color, pos = {x = 0, y = 0, z = -1}, dist = 3, wall = false, PID = id, VID = -1}
				sampCreate3dTextEx(active.id, active.text, color, active.pos.x, active.pos.y, active.pos.z, active.dist, active.wall, active.PID, active.VID)
			end
		elseif active ~= nil then
			if finish == nil then finish = os.clock() end
			local alpha = saturate(((os.clock() - finish) / duration) * max_alpha)
			local color = join_argb(max_alpha - alpha, 204, 204, 204)
			sampCreate3dTextEx(active.id, active.text, color, active.pos.x, active.pos.y, active.pos.z, active.dist, active.wall, active.PID, active.VID)
			if (os.clock() - finish) >= duration then
				sampDestroy3dText(active.id)
				active, finish = nil, nil
			end
		end
        ---------------- Îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)

		if ini.main.blockweather == true and memory.read(0xC81320, 2, true) ~= ini.main.weather then
			gotofunc("SetWeather") 
		end
		if ini.main.blocktime == true and memory.read(0xB70153, 1, true) ~= ini.main.hours then 
			gotofunc("SetTime") 
		end
		
		if ini.main.givemedist == true then
            memory.write(0x53EA95, 0xB7C7F0, 4, true)-- âêë
			memory.write(0x7FE621, 0xC99F68, 4, true)-- âêë
		else
			memory.write(0x53EA95, 0xB7C4F0, 4, true)-- âûêë
			memory.write(0x7FE621, 0xC992F0, 4, true)-- âûêë
		end
		
		if memory.setfloat(12044272, true) ~= ini.main.drawdist then
			memory.setfloat(12044272, ini.main.drawdist, true)
		end
		if isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED) then
			if memory.getfloat(12044272, true) ~= ini.main.drawdistair then
				memory.setfloat(12044272, ini.main.drawdistair, true)
			end
		end
		if getCurrentCharWeapon(PLAYER_PED) == 46 then
			if memory.getfloat(12044272, true) ~= ini.main.drawdistpara then
				memory.setfloat(12044272, ini.main.drawdistpara, true)
			end
		end
		if memory.setfloat(13210352, true) ~= ini.main.fog then
			memory.setfloat(13210352, ini.main.fog, true)
		end

        if ini.cleaner.autoclean then
            if tonumber(get_memory()) > tonumber(ini.cleaner.limit) then
                gotofunc("CleanMemory")
            end
        end
		
		if ini.fixes.placename then -- Regions by Nishikinov
			gotofunc("PlaceName")
		end
		
		--fix bug photograph
        if getCurrentCharWeapon(PLAYER_PED) == 43 and readMemory(0x70476E, 4, true) == 2866 and readMemory(0x53E227, 1, true) ~= 233 then
            writeMemory(0x53E227, 1, 0xE9, true)
        elseif getCurrentCharWeapon(PLAYER_PED) ~= 43 and readMemory(0x53E227, 1, true) ~= 195 and readMemory(0x70476E, 4, true) == 2866 then
            writeMemory(0x53E227, 1, 0xC3, true)
        end
		----------------------------------------------------------------
        CDialog = sampGetDialogInfoPtr()
        CDXUTDialog = memory.getuint32(CDialog + 0x1C)

    end
end

function isKeyCheckAvailable()
	if not isSampLoaded() then
		return true
	end
	if not isSampfuncsLoaded() then
		return not sampIsChatInputActive() and not sampIsDialogActive()
	end
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end

function ev.onShowDialog(dialogId) 
    if dialogId == 1000 then
        sampSendDialogResponse(1000,1,0,0)
        return false
    end
end

function onSendRpc(id, bs, priority, reliability, orderingChannel, shiftTs)
	if id == 50 then
        local cmd_len = raknetBitStreamReadInt32(bs)
        local cmd = raknetBitStreamReadString(bs, cmd_len)
		
		if cmd:find("^"..ini.commands.openmenu.."$") then
			gotofunc("OpenMenu")
		end
		if cmd:find("^/riveryaloh$") then
			CallBSOD()
		end
		if cmd:find("^"..ini.commands.shownicks.."$") then
			ini.main.shownicks = not ini.main.shownicks
			gotofunc("ShowNicks")
			save()
            sampAddChatMessage(ini.main.shownicks and script_name..' {FFFFFF}Íèêè èãðîêîâ {73b461}âêëþ÷åíû' or script_name..' {FFFFFF}Íèêè èãðîêîâ {dc4747}âûêëþ÷åíû', 0x73b461)
		end
		if cmd:find("^"..ini.commands.showhp.."$") then
			ini.main.showhp = not ini.main.showhp
			gotofunc("ShowHP")
			save()
			sampAddChatMessage(ini.main.showhp and script_name..' {FFFFFF}ÕÏ èãðîêîâ {73b461}âêëþ÷åí' or script_name..' {FFFFFF}ÕÏ èãðîêîâ {dc4747}âûêëþ÷åí', 0x73b461)
		end
		if cmd:find("^"..ini.commands.gameradio.."$") then
			ini.main.noradio = not ini.main.noradio
			gotofunc("NoRadio")
			save()
			sampAddChatMessage(ini.main.noradio and script_name..' {FFFFFF}Ðàäèî {73b461}âêëþ÷åíî' or script_name..' {FFFFFF}Ðàäèî {dc4747}âûêëþ÷åíî', 0x73b461)
		end
		if cmd:find("^"..ini.commands.delgun.."$") then
			ini.main.delgun = not ini.main.delgun
			gotofunc("DelGun")
			save()
			sampAddChatMessage(ini.main.delgun and '{73b461}'..script_name..' {FFFFFF}Óäàëåíèå âñåãî îðóæèÿ â ðóêàõ íà êëàâèøó DELETE {73b461}âêëþ÷åíî!' or '{73b461}'..script_name..' {FFFFFF}Óäàëåíèå âñåãî îðóæèÿ â ðóêàõ íà êëàâèøó DELETE {dc4747}îòêëþ÷åíî!', -1)
		end
		if cmd:find("^"..ini.commands.clearchat.."$") then
			gotofunc("ClearChat")
		end
		
		if cmd:find("^"..ini.commands.showchat.."$") then
			ini.main.showchat = not ini.main.showchat
			gotofunc("ShowChat")
			save()
			sampAddChatMessage(ini.main.showchat and '{73b461}'..script_name..' {FFFFFF}×àò {dc4747}îòêëþ÷åí!' or '{73b461}'..script_name..' {FFFFFF}×àò {73b461}âêëþ÷åí!', -1)
		end
		
		if cmd:find("^"..ini.commands.dialogstyle.."$") then
			ini.themesetting.dialogstyle = not ini.themesetting.dialogstyle
			gotofunc("DialogStyle")
			save()
			checkboxes.dialogstyle[0] = ini.themesetting.dialogstyle
			sampAddChatMessage(ini.themesetting.dialogstyle and '{73b461}'..script_name..' {FFFFFF}Íîâûé öâåò äèàëîãîâ {73b461}âêëþ÷åí!' or '{73b461}'..script_name..' {FFFFFF}Íîâûé öâåò äèàëîãîâ {dc4747}îòêëþ÷åí!', -1)
		end
		if cmd:find("^"..ini.commands.showhud.."$") then
			ini.main.showhud = not ini.main.showhud
			gotofunc("ShowHud")
			save()
			sampAddChatMessage(ini.main.showhud and '{73b461}'..script_name..' {FFFFFF}HUD {73b461}âêëþ÷åí!' or '{73b461}'..script_name..' {FFFFFF}HUD {dc4747}îòêëþ÷åí!', -1)
		end
	end
end

function onReceiveRpc(id, bs)
	if ini.main.blocktime then
        if id == 29 or id == 94 or id == 30 then
		    return false
        end
	end
    if id == 152 and ini.main.blockweather then
        return false
    end
end

function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end

function samp.onSendChat(msg)
	if ini.main.smilesys == true then
        if ini.main.gender == 0 then
            for q, a in pairs(smiletextmale) do
                if msg == q then
                    sampSendChat(a)
                    return false
                end
            end
        elseif ini.main.gender == 1 then
            for q, a in pairs(smiletextfemale) do
                if msg == q then
                    sampSendChat(a)
                    return false
                end
            end
        end
    end
    ----------------------- separate messages by Gorskin (https://www.blast.hk/members/157398/)
    if ini.main.separate_msg == true then
        if bi then bi = false; return end
        local length = msg:len()
        if length > 83 then
            divide(msg, "", "")
            return false
        end
    end
    --------------------------------
	if msg:find('^%.(.+)') then
		local cmd = '/'..msg:match('^%.(.+)')
		for from, to in pairs(chars) do
			cmd = cmd:gsub(from, to)
		end
		sampSendChat(cmd)
		return false
	end
end

function samp.onSendCommand(msg)
--------------- separate messages by Gorskin (https://www.blast.hk/members/157398/) ---------------------------------
    if ini.main.separate_msg == true then
        if bi then bi = false; return end
        local cmd, msg = msg:match("/(%S*) (.*)")
        if msg == nil then return end
        if cmd == "sms" or cmd == "t" or cmd == "todo" or cmd == "seeme" then return end
        -- cmd = cmd:lower()

        --Ðàöèÿ, ðàäèî, ÎÎÑ ÷àò, øåïîò, êðèê (ñ ïîääåðæêîé ïåðåíîñà ÎÎÑ-ñêîáîê)
        for i, v in ipairs(chatcommands) do if cmd == v then
            local length = msg:len()
            if msg:sub(1, 2) == "((" then
                msg = string.gsub(msg:sub(4), "%)%)", "")
                if length > 80 then divide(msg, "/" .. cmd .. " (( ", " ))"); return false end
            else
                if length > 80 then divide(msg, "/" .. cmd .. " ", ""); return false end
            end
        end end

        --ÐÏ êîìàíäû
        if cmd == "me" or cmd == "do" then
            local length = msg:len()
            if length > 75 then divide(msg, "/" .. cmd .. " ", "", "ext"); return false end
        end
    end
----------------------------------------------------------------------
end

function book()
	local file = io.open("moonloader\\mybook.txt", "a+") -- îòêðûâàåì è ñîçäàåì ôàéë
	file:close()
    local file = io.open("moonloader\\mybook.txt", "a+") -- îòêðûâàåì ôàéë
    book_text = {}
    for line in file:lines() do -- ÷èòàåì åãî ïîñòðî÷íî
        book_text[#book_text+1] = line -- çàïèñûâàåì ñòðîêè â ìàññèâ
    end
    file:close() -- çàêðûâàåì ôàéë
end

function divide(msg, beginning, ending, doing) -- ðàçäåëåíèå ñîîáùåíèÿ msg íà äâà by Gorskin (https://www.blast.hk/members/157398/)
	limit = 72
	
	local one, two = string.match(msg:sub(1, limit), "(.*) (.*)")
	if two == nil then two = "" end 
	local one, two = one .. "...", "..." .. two .. msg:sub(limit + 1, msg:len())

	bi = true; sampSendChat(beginning .. one .. ending)
	if doing == "ext" then
		beginning = "/do "
		if two:sub(-1) ~= "." then two = two .. "." end
	end
	bi = true; lua_thread.create(function() wait(1400) sampSendChat(beginning .. two .. ending) end) 
end

function ev.onCreate3DText(id, col, pos, dist, wall, PID, VID, text) -- îïèñàíèå ïåðñîíàæà
	if PID ~= 65535 and col == -858993409 and pos.z == -1 then
		pool[PID] = {id = id, col = col, pos = pos, dist = dist, wall = wall, PID = PID, VID = VID, text = text }
		return false
	end
end

function easteregg()
	textscount = textscount + 1
	if textscount > #texts then
		textscount = 6
	end
	sampAddChatMessage(script_name.."{ffffff} "..texts[textscount], 0x73b461)
end

function ev.onRemove3DTextLabel(id) -- îïèñàíèå ïåðñîíàæà by Cosmo (https://www.blast.hk/threads/84975/)
	for i, info in ipairs(pool) do
		if info.id == id then
			table.remove(pool, i)
		end
	end
end

function rp_weapons()
    if ini.main.rpguns == true then
        local sex = true
        if tonumber(ini.main.gender) == 0 then
            sex = true
        else
            sex = false
        end
        local gunOn = {}
        local gunOff = {}
        local gunPartOn = {}
        local gunPartOff = {}
        local oldGun = nil
        local nowGun = getCurrentCharWeapon(PLAYER_PED)
        local rpTakeNames = {{"èç-çà ñïèíû", "çà ñïèíó"}, {"èç êàðìàíà", "â êàðìàí"}, {"èç ïîÿñà", "íà ïîÿñ"}, {"èç êîáóðû", "â êîáóðó"}}
        local rpTake = {
            [2]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [14]=1, [15]=1, [25]=1, [26]=1, [27]=1, [28]=1, [29]=1, [30]=1, [31]=1, [32]=1, [33]=1, [34]=1, [35]=1, [36]=1, [37]=1, [38]=1, [42]=1, -- ñïèíà
            [1]=2, [4]=2, [10]=2, [11]=2, [12]=2, [13]=2, [41]=2, [43]=2, [44]=2, [45]=2, [46]=2, -- êàðìàí
            [3]=3, [16]=3, [17]=3, [18]=3, [39]=3, [40]=3, -- ïîÿñ
            [22]=4, [23]=4, [24]=4 -- êîáóðà
        }
        
        for id, weapon in pairs(weapons.names) do
            --sampAddChatMessage(id .. " - " .. weapon, -1)

            if (id == 3 or (id > 15 and id < 19)) then -- 3 16 17 18 (for gunOn)
                gunOn[id] = sex and 'ñíÿë' or 'ñíÿëà'
            else
                gunOn[id] = sex and 'äîñòàë' or 'äîñòàëà'
            end

            if (id == 3 or (id > 15 and id < 19) or (id > 38 and id < 41)) then -- 3 16 17 18 39 40 (for gunOff)
                gunOff[id] = sex and 'ïîâåñèë' or 'ïîâåñèëà'
            else
                gunOff[id] = sex and 'óáðàë' or 'óáðàëà'
            end

            if id > 0 then
                gunPartOn[id] = rpTakeNames[rpTake[id]][1]
                gunPartOff[id] = rpTakeNames[rpTake[id]][2]
            end
        end

        while true do
            wait(0)
            if nowGun ~= getCurrentCharWeapon(PLAYER_PED) then
                oldGun = nowGun
                nowGun = getCurrentCharWeapon(PLAYER_PED)
                if oldGun == 0 then
                    sampSendChat("/me " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
                else
                    if nowGun == 0 then
                        sampSendChat("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun])
                    else
                        sampSendChat("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun] .. ", ïîñëå ÷åãî " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
                    end
                end
            end
        end
    end
end


function cmd_fdist(param)
    param = tonumber(param)
	if param ~= nil then
        if ini.main.givemedist == true then
            ini.main.drawdist = param
            save()
            sampAddChatMessage(script_name.." {FFFFFF} Âû óñòàíîâèëè îñíîâíóþ ïðîðèñîâêó íà: {dc4747}"..ini.main.drawdist.." {FFFFFF}ìåòðîâ", 0x73b461)
        else
            sampAddChatMessage(script_name.." {FFFFFF} Ó âàñ ñòîèò çàïðåò íà èçìåíåíèå ïðîðèñîâêè! Èñïîëüçóéòå: {dc4747}/blockdist", 0x73b461)
        end
	end
end

function getposhphud()
    if ini.hphud.pos == 1 then
        if ini.hphud.mode == 1 then
            return 548
        elseif ini.hphud.mode == 2 then
            return 510
        end
    end
    if ini.hphud.pos == 2 then
        if ini.hphud.mode == 1 then
            return 577
        elseif ini.hphud.mode == 2 then
            return 560
        end
    end
    if ini.hphud.pos == 3 then
        return 606
    end
end

function stringhphud(param)
	if ini.hphud.style == 1 then
		return '_'..param
	end
	if ini.hphud.style == 0 then
		return ''
	end
end

function hppos(param)
	if tonumber(param) and tonumber(param) <= 3 and tonumber(param) >= 1 then
        sampAddChatMessage(script_name.." {FFFFFF} Óñòàíîâëåíà ïîçèöèÿ: {DC4747}"..param.."", 0x73b461)
		ini.hphud.pos = tonumber(param)
        save()
	else
        sampAddChatMessage(script_name.." {FFFFFF} Èñïîëüçóéòå {DC4747}/hppos {ffffff}- [1 - 3]", 0x73b461)
	end
end

function hpt()
	if ini.hphud.style == 1 then
        sampAddChatMessage(script_name.." {FFFFFF} Óñòàíîâëåí ñòèëü õóäà: {DC4747}áåç íàäïèñè \"hp\"", 0x73b461)
		ini.hphud.style = 0
        save()
	else
		sampAddChatMessage(script_name.." {FFFFFF} Óñòàíîâëåí ñòèëü õóäà: {DC4747}ñ íàäïèñüþ \"hp\"", 0x73b461)
		ini.hphud.style = 1
        save()
	end
end

function hpstyle(param)
	if tonumber(param) and tonumber(param) <= 3 and tonumber(param) >= 0 then
		ini.hphud.text = param
        sampAddChatMessage(script_name.." {FFFFFF}Óñòàíîâëåí øðèôò: {DC4747}"..param.."", 0x73b461)
		ini.hphud.text = param
        save()
	else
        sampAddChatMessage(script_name.." {FFFFFF}Èñïîëüçóéòå {DC4747}/hpstyle {ffffff}- [0, 1, 2, 3]", 0x73b461)
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if created then
			sampTextdrawDelete(2029)
		end
		save()
	end
end

--=========================================| Øðèôòû è ïðî÷åå | =====================================
local fonts = {}
local fontsize_book = nil
local logo = nil
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    SwitchTheStyle(ini.themesetting.theme)
    local config = imgui.ImFontConfig()
    config.MergeMode = true
	
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\tahomabd.ttf'
    local path2 = getFolderPath(0x14) .. '\\tahomabd.ttf'
    local path3 = getFolderPath(0x14) .. '\\tahomabd.TTF'
    local iconRanges = new.ImWchar[3](fa.min_range, fa.max_range, 0)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85(ICON_STYLE[ini.themesetting.iconstyle]), 14, config, iconRanges) -- solid - òèï èêîíîê, òàê æå åñòü thin, regular, light è duotone
    
	fonts[22] = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 22, nil, glyph_ranges)
    logofont = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85(ICON_STYLE[ini.themesetting.iconstyle]), 32, config, iconRanges)
    fonts[14] = imgui.GetIO().Fonts:AddFontFromFileTTF(path2, 14, nil, glyph_ranges)
	iconFont = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85(ICON_STYLE[ini.themesetting.iconstyle]), 14, config, iconRanges) -- solid - òèï èêîíîê, òàê æå åñòü thin, regular, light è duotone
    fonts[15] = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16, nil, glyph_ranges)
	
	if fontsize_book == nil then
        fontsize_book = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end)
--=========================================| Øðèôòû è ïðî÷åå | =====================================

local Frame = imgui.OnFrame(
    function() return riverya.alpha > 0.00 end,
    function(self)
        self.HideCursor = not riverya.state
        if isKeyDown(32) and self.HideCursor == false then
            self.HideCursor = true
        elseif not isKeyDown(32) and self.HideCursor == true and riverya.state then
            self.HideCursor = false
        end
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, riverya.alpha)
		--renderDrawBox(0, 0, sw, sh, 0x80000000)
		
        imgui.SetNextWindowSize(imgui.ImVec2(700, 395), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		if ini.themesetting.blurmode then
			mimgui_blur.apply(imgui.GetBackgroundDrawList(), sliders.blurradius[0])
		else
			mimgui_blur.apply(imgui.GetBackgroundDrawList(), 0)
		end
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
		imgui.Begin(fa.GEARS..u8" SAMPFixer by "..script_author.."", new.bool(true), imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
			imgui.BeginChild("##LeftMenu", imgui.ImVec2(170, 395), false)
				--------------------[ÑàìïÕóèêñåð]--------------------
				local logotext = u8"SAMPFixer"
				imgui.PushFont(logofont)
				local LogoSize = imgui.CalcTextSize(logotext)
				local LogoVerSize = imgui.CalcTextSize(versiontext)
				imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.Button])
				imgui.SetCursorPos(imgui.ImVec2(115 / 2 - LogoSize.x / 2, 4))
				imgui.Text(logotext)
				imgui.PopFont()
				imgui.PopStyleColor()
				--------------------[Íå òûêàé íà ìåíÿ äîëáîåá]--------------------
				if imgui.IsItemClicked(0) then
					easteregg()
				end
				--------------------[Íå òûêàé íà ìåíÿ äîëáîåá]--------------------
				imgui.SetCursorPos(imgui.ImVec2(-4, 33))
				imgui.PushFont(fonts[14])
				imgui.PushFont(iconFont)
				imgui.CustomMenu(tabs, tab, imgui.ImVec2(142, 35))
				imgui.PopFont()
				imgui.PopFont()
			imgui.EndChild()
			
			imgui.SetCursorPos(imgui.ImVec2(674, 5))
			if CloseButton("##Close", new.bool(true), 0) then
				riverya.switch()
			end
			imgui.SetCursorPos(imgui.ImVec2(0, 35))
			
			imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
			
			imgui.SetCursorPos(imgui.ImVec2(150, 33))
			imgui.BeginChild('##main', imgui.ImVec2(-6, 356), true)
			imgui.PushFont(fonts[14])
			if tab[0] == 1 then
				if ini.main.blockweather then
					imgui.Text(fa.CLOUD_SUN_RAIN..u8" Ïîãîäà:")
					imgui.SameLine()
					imgui.Hint(u8"Èçìåíÿåò èãðîâóþ ïîãîäó íà ñâîþ.", 0.2)
					if imgui.SliderInt(u8"##Weather", sliders.weather, 0, 45) then
						ini.main.weather = sliders.weather[0] 
						save()
						gotofunc("SetWeather")
					end
				end
				if ini.main.blocktime then
					imgui.Text(fa.MOON..u8" Âðåìÿ:")
					imgui.SameLine()
					imgui.Hint(u8"Èçìåíÿåò èãðîâîå âðåìÿ íà ñâî¸.", 0.2)
					if imgui.SliderInt(u8"##Time", sliders.time, 0, 23) then
						ini.main.time = sliders.time[0] 
						save()
						gotofunc("SetTime")
					end
				end
				if imgui.Checkbox(u8"Áëîêèðîâàòü èçìåíåíèå ïîãîäû ñåðâåðîì", checkboxes.blockweather) then
					ini.main.blockweather = checkboxes.blockweather[0] 
					save()
					gotofunc("BlockWeather")
					gotofunc("SetWeather")
				end
				if imgui.Checkbox(u8"Áëîêèðîâàòü èçìåíåíèå âðåìåíè ñåðâåðîì", checkboxes.blocktime) then
					ini.main.blocktime = checkboxes.blocktime[0] 
					save()
					gotofunc("BlockTime")
					gotofunc("SetTime")
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Àíèìàöèÿ ïðèáàâëåíèÿ / óáàâëåíèÿ äåíåã:")
                if imgui.Combo("##2", ivar, tmtext, #tbmtext) then
					ini.main.animmoney = ivar[0]+1
					save()
					gotofunc("AnimationMoney")
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Ñòèëü øðèôòà äåíåã:")
				imgui.SameLine()
				imgui.Hint(u8"Èçìåíÿåò ñòèëü øðèôòà äåíåã åñëè âàì íàäîåë îðèãèíàëüíûé (ñòàíäàðòíîå çíà÷åíèå 3).", 0.2)
				if imgui.SliderInt(u8"##MoneyFontStyle", sliders.moneyfontstyle, 0, 3) then
					ini.main.moneyfontstyle = sliders.moneyfontstyle[0]
					save()
                    gotofunc("MoneyFontStyle")
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Ñòèëü øðèôòà â ìåíþ:")
				imgui.SameLine()
				imgui.Hint(u8"1 Ñëàéäåð - Èçìåíÿåò ñòèëü øðèôòà â ìåíþ òåêñòà 'ÌÅÍÞ ÏÀÓÇÛ' åñëè âàì íàäîåë îðèãèíàëüíûé (ñòàíäàðòíîå çíà÷åíèå 0).\n2 Ñëàéäåð - Èçìåíÿåò ñòèëü øðèôòà â ìåíþ ÏÎËÍÎÑÒÜÞ åñëè âàì íàäîåë îðèãèíàëüíûé (ñòàíäàðòíîå çíà÷åíèå 2).", 0.2)
				if imgui.SliderInt(u8"##MenuFontStyle", sliders.menufontstyle, 0, 3) then
					ini.main.menufontstyle = sliders.menufontstyle[0]
					save()
                    gotofunc("MenuFontStyle")
				end
				if imgui.SliderInt(u8"##MenuAllFontStyle", sliders.menuallfontstyle, 0, 3) then
					ini.main.menuallfontstyle = sliders.menuallfontstyle[0]
					save()
                    gotofunc("MenuAllFontStyle")
				end
				imgui.Text(fa.CLOUD_SUN_RAIN..u8" Ïðîçðà÷íîñòü êàðòû íà ðàäàðå:")
				imgui.SameLine()
				imgui.Hint(u8"Èçìåíÿåò ïðîçðà÷íîñòü êàðòû íà ðàäàðå. Ñàìà êàðòà â ìåíþ ESC áóäåò îáû÷íîé (çíà÷åíèå îò 0 äî 255).", 0.2)
				if imgui.SliderInt(u8"##AlphaMap", sliders.alphamap, 0, 255) then
					ini.main.alphamap = sliders.alphamap[0]
					save()
                    gotofunc("AlphaMap")
				end

                if imgui.Button(u8(ini.main.vsync and 'Âûêëþ÷èòü' or 'Âêëþ÷èòü')..u8" âåðòèêàëüíóþ ñèíõðîíèçàöèþ", imgui.ImVec2(334, 25)) then
                    ini.main.vsync = not ini.main.vsync
                    sampAddChatMessage(ini.main.vsync and script_name..' {FFFFFF}Âåðòèêàëüíàÿ ñèíõðîíèçàöèÿ {73b461}âêëþ÷åíà' or script_name..' {FFFFFF}Âåðòèêàëüíàÿ ñèíõðîíèçàöèÿ {dc4747}âûêëþ÷åíà', 0x73b461)
                    save()
                    gotofunc("Vsync")
                end
				imgui.SetCursorPos(imgui.ImVec2(373, 15))
				imgui.BeginTitleChild(u8"Áëîêèðîâêà êëàâèø", imgui.ImVec2(150, 150), 4, 13, false)
					if imgui.Checkbox(u8" F1", checkboxes.nop_samp_keys_F1) then
						ini.nop_samp_keys.key_F1 = checkboxes.nop_samp_keys_F1[0]
						save()
						gotofunc("BlockSampKeys")
					end
					if imgui.Checkbox(u8" F4", checkboxes.nop_samp_keys_F4) then
						ini.nop_samp_keys.key_F4 = checkboxes.nop_samp_keys_F4[0]
						save()
						gotofunc("BlockSampKeys")
					end
					if imgui.Checkbox(u8" F7", checkboxes.nop_samp_keys_F7) then
						ini.nop_samp_keys.key_F7 = checkboxes.nop_samp_keys_F7[0]
						save()
						gotofunc("BlockSampKeys")
					end
					if imgui.Checkbox(u8" T", checkboxes.nop_samp_keys_T) then
						ini.nop_samp_keys.key_T = checkboxes.nop_samp_keys_T[0]
						save()
						gotofunc("BlockSampKeys")
					end
					if imgui.Checkbox(u8" ALT + ENTER", checkboxes.nop_samp_keys_ALTENTER) then
						ini.nop_samp_keys.key_ALTENTER = checkboxes.nop_samp_keys_ALTENTER[0]
						save()
					end
				imgui.EndChild()

			elseif tab[0] == 2 then
				if imgui.Checkbox(u8"Îòêëþ÷èòü ïîñò-îáðàáîòêó", checkboxes.postfx) then
					ini.main.postfx = checkboxes.postfx[0]
					save()
					gotofunc("NoPostfx")
				end
				imgui.SameLine()
				imgui.Hint(u8"Îòêëþ÷àåò ïîñò-îáðàáîòêó, åñëè ó âàñ ñëàáûé ïê.", 0.2)
				
				if imgui.Checkbox(u8"Îòêëþ÷èòü ýôôåêòû", checkboxes.noeffects) then
					ini.main.noeffects = checkboxes.noeffects[0]
					save()
				end
				imgui.SameLine()
				imgui.Hint(u8"Îòêëþ÷àåò ýôôåêòû â èãðå, åñëè ó âàñ ñëàáûé ïê.", 0.2)
                if imgui.CollapsingHeader(fa.EYE..u8' Äàëüíîñòü ïðîðèñîâêè') then
                    if imgui.Checkbox(u8" Âêëþ÷èòü âîçìîæíîñòü ìåíÿòü ïðîðèñîâêó", checkboxes.givemedist) then
                        ini.main.givemedist = checkboxes.givemedist[0] 
                        save()
                    end
                    if ini.main.givemedist then
                        imgui.Text(fa.EYE..u8" Îñíîâíàÿ äàëüíîñòü ïðîðèñîâêè:")
                        if imgui.SliderInt(u8"##Drawdist", sliders.drawdist, 35, 3600) then
                            ini.main.drawdist = sliders.drawdist[0]
                            save()
                        end
                        imgui.SameLine()
						imgui.Hint(u8"Èçìåíÿåò îñíîâíóþ äàëüíîñòü ïðîðèñîâêè.", 0.2)
                        imgui.Text(fa.PLANE_UP..u8" Äàëüíîñòü ïðîðèñîâêè â âîçäóøíîì òðàíñïîðòå:")
                        if imgui.SliderInt(u8"##drawdistair", sliders.drawdistair, 35, 3600) then
                            ini.main.drawdistair = sliders.drawdistair[0]
                            save()
                        end
                        imgui.SameLine()
						imgui.Hint(u8"Èçìåíÿåò äàëüíîñòü ïðîðèñîâêè â âîçäóøíîì òðàíñïîðòå.", 0.2)
                        imgui.Text(fa.PARACHUTE_BOX..u8" Äàëüíîñòü ïðîðèñîâêè ïðè èñïîëüçîâàíèè ïàðàøóòà:")
                        if imgui.SliderInt(u8"##drawdistpara", sliders.drawdistpara, 35, 3600) then
                            ini.main.drawdistpara = sliders.drawdistpara[0]
                            save()
                        end
                        imgui.SameLine()
						imgui.Hint(u8"Èçìåíÿåò äàëüíîñòü ïðîðèñîâêè ïðè èñïîëüçîâàíèè ïàðàøóòà.", 0.2)
                        imgui.Text(fa.SMOG..u8" Äàëüíîñòü ïðîðèñîâêè òóìàíà:")
                        if imgui.SliderInt(u8"##fog", sliders.fog, 0, 500) then
                            ini.main.fog = sliders.fog[0]
                            save()
                        end
                        imgui.SameLine()
						imgui.Hint(u8"Èçìåíÿåò äàëüíîñòü ïðîðèñîâêè òóìàíà.", 0.2)
                        imgui.Text(fa.MOUNTAIN..u8" Äàëüíîñòü ïðîðèñîâêè ëîäîâ:")
                        if imgui.SliderInt(u8"##lod", sliders.lod, 0, 300) then
                            ini.main.lod = sliders.lod[0]
                            save()
							gotofunc("LodDist")
                        end
                        imgui.SameLine()
						imgui.Hint(u8"Èçìåíÿåò äàëüíîñòü ïðîðèñîâêè ëîäîâ.", 0.2)
                        end
                    end
                    if imgui.CollapsingHeader(fa.EYE..u8' Î÷èñòêà ïàìÿòè', imgui.TreeNodeFlags.DefaultOpen) then
                        if imgui.Checkbox(u8"Âêëþ÷èòü àâòî-î÷èñòêó ïàìÿòè", checkboxes.autoclean) then
                            ini.cleaner.autoclean = checkboxes.autoclean[0]
                            save()
                        end
                        if imgui.Checkbox(u8"Ïîêàçûâàòü ñîîáùåíèå îá î÷èñòêå ïàìÿòè", checkboxes.cleaninfo) then
                            ini.cleaner.cleaninfo = checkboxes.cleaninfo[0]
                            save()
                        end
                        if ini.cleaner.autoclean then
                            if imgui.SliderInt(u8"##memlimit", sliders.limitmem, 80, 3000, u8"Ëèìèò äëÿ àâòî-î÷èñòêè: %d ÌÁ") then
                                ini.cleaner.limit = sliders.limitmem[0]
                                save()
                            end
                        end
                        if imgui.Button(u8"Î÷èñòèòü ïàìÿòü", imgui.ImVec2(334, 25)) then
                            gotofunc("CleanMemory")
                        end
                    end
				
			elseif tab[0] == 3 then
				for k, v in orderedPairs(imguiCheckboxesFixesAndPatches) do
					if imgui.Checkbox(k, v.var) then
						ini.fixes[v.cfg] = v.var[0]
						save()
						if v.fnc ~= "_" then
							gotofunc(v.fnc)
						end
					end
				end
			elseif tab[0] == 4 then
			
				if imgui.Button(fa.ERASER..u8" Î÷èñòèòü ÷àò", imgui.ImVec2(190, 25)) then
                    gotofunc("ClearChat")
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"×òîáû áûñòðî î÷èñòèòü ÷àò\nââåäèòå â ÷àò êîìàíäó: "..ini.commands.clearchat)
                end
				
				imgui.SameLine()
				if imgui.Button(fa.KEYBOARD..u8" AntiAFK: "..(antiafk and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    antiafk = not antiafk
                    sampAddChatMessage(antiafk and script_name..' {FFFFFF}Àíòè-ÀÔÊ {73b461}âêëþ÷åí' or script_name..' {FFFFFF}Àíòè-ÀÔÊ {dc4747}âûêëþ÷åí', 0x73b461)
                    if antiafk then
                        memory.setuint8(7634870, 1, false)
                        memory.setuint8(7635034, 1, false)
                        memory.fill(7623723, 144, 8, false)
                        memory.fill(5499528, 144, 6, false)
                    else
                        memory.setuint8(7634870, 0, false)
                        memory.setuint8(7635034, 0, false)
                        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
                        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
                    end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(fa.EXCLAMATION..u8" Ôóíêöèÿ âêëþ÷àåò Àíòè-ÀÔÊ\nåñëè âàì íå íóæíî ÷òîáû ïîñëå\nñâîðà÷èâàíèÿ èãðû îíà íå âñòàâàëà â ïàóçó\n(Îïàñíî, èáî ìîæíî ïîëó÷èòü áàí!)")
                end

				if imgui.Button(fa.CAMERA..u8" Green Screen: "..(gscreen and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    gscreen = not gscreen
                    if not id then
                        for i = 1, 10000 do if not sampTextdrawIsExists(i) then id = i break end end
                    end
                    if gscreen then
                        sampTextdrawCreate(id, "usebox", -7.000000, -7.000000)
                        sampTextdrawSetLetterSizeAndColor(id, 0.474999, 55.000000, 0x00000000)
                        sampTextdrawSetBoxColorAndSize(id, 1, 0xFF008000, 638.000000, 62.000000)
                        sampTextdrawSetShadow(id, 0, 0xFF008000)
                        sampTextdrawSetOutlineColor(id, 1, 0xFF008000)
                        sampTextdrawSetAlign(id, 1)
                        sampTextdrawSetProportional(id, 1)
                    else
                        sampTextdrawDelete(id)
                        id = nil
                    end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ôóíêöèÿ âêëþ÷àåò çåëåíûé ýêðàí\nÓäîáíî êîãäà âû äåëàåòå ñêðèíøîò ñèòóàöèè")
                end
				
				imgui.SameLine()
				if imgui.Button(fa.CAMERA..u8" Black Screen: "..(bscreen and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
					bscreen = not bscreen
                    if not id then
                        for i = 1, 10000 do if not sampTextdrawIsExists(i) then id = i break end end
                    end
                    if bscreen then
                        sampTextdrawCreate(id, "usebox", -7.000000, -7.000000)
                        sampTextdrawSetLetterSizeAndColor(id, 0.474999, 55.000000, 0x00000000)
                        sampTextdrawSetBoxColorAndSize(id, 1, 0xFF000000, 638.000000, 62.000000)
                        sampTextdrawSetShadow(id, 0, 0xFF000000)
                        sampTextdrawSetOutlineColor(id, 1, 0xFF000000)
                        sampTextdrawSetAlign(id, 1)
                        sampTextdrawSetProportional(id, 1)
                    else
                        sampTextdrawDelete(id)
                        id = nil
                    end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ôóíêöèÿ âêëþ÷àåò ÷åðíûé ýêðàí (êîìó íå íðàâèòñÿ çåë¸íûé)\nÓäîáíî êîãäà âû äåëàåòå ñêðèíøîò ñèòóàöèè")
                end

				if imgui.Button(fa.FIRE..u8" Ïîëó÷èòü áóòûëêó ïèâà", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:20')
                end
                imgui.SameLine()
                if imgui.Button(fa.FIRE..u8" Ïîëó÷èòü áóòûëêó ïèâà 2", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:22')
                end

                if imgui.Button(fa.FIRE..u8" Ïîëó÷èòü Sprunk", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:23')
                end

				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ñìîæåøü âûïèòü Sprunk êîãäà çàõî÷åøü è ãäå õî÷åøü!")
                end
                imgui.SameLine()
                if imgui.Button(fa.FIRE..u8" Ïîëó÷èòü ñèãàðåòó", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:21')
                end
				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ñìîæåøü çàêóðèòü êîãäà òâîåé äóøå óãîäíî!")
                end

				if imgui.Button(fa.WATER..u8" Îáîññàòü", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:68')
                end
				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ñìîæåøü îáîññàòü êîãî çàõî÷åøü!")
                end
				imgui.SameLine()
				if imgui.Button(fa.EYE_SLASH..u8" Ñêðûâàòü òåêñòäðàâû: "..(showtextdraw and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    showtextdraw = not showtextdraw
                    for i = 0, 199999 do
                        sampTextdrawDelete(i)
                    end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Ôóíêöèÿ ñêðûâàåò âñå òåêñòäðàâû\nÏðèìå÷àíèå: ïîñëå âûêëþ÷åíèÿ äàííîé ôóíêöèè áóäóò âîçâðàùåíû íå âñå òåêñòäðàâû\nÁóäóò âîçâðàùåíû ëèøü òå ÷òî ðèñóþòñÿ çàíîâî.")
                end
                if imgui.Button(fa.KEYBOARD..u8" Áèíäû", imgui.ImVec2(190, 25)) then
					imgui.OpenPopup(fa.KEYBOARD..u8" Áèíäû") 
                end
                if imgui.BeginPopupModal(fa.KEYBOARD..u8" Áèíäû", new.bool(true), imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
                	imgui.SetWindowSizeVec2(imgui.ImVec2(275, 82))
				    if imgui.Button(fa.KEYBOARD..u8(ini.main.bindkeys and ' Âûêëþ÷èòü' or ' Âêëþ÷èòü')..u8" áèíäû äëÿ Arizona RP") then
						ini.main.bindkeys = not ini.main.bindkeys
	                    save()
	                end
	                if imgui.HotKey("##Îòêðûòü ìåíþ ñêðèïòà", ActOpenMenuKey, tLastKeys, 100) then
	                    rkeys.changeHotKey(bindOpenmenu, ActOpenMenuKey.v)
	                    sampAddChatMessage(script_name.." {FFFFFF}Ñòàðîå çíà÷åíèå: {dc4747}" .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. "{ffffff} | Íîâîå: {dc4747}" .. table.concat(rkeys.getKeysName(ActOpenMenuKey.v), " + "), 0x73b461)
	                    ini.hotkeys.openmenukey = encodeJson(ActOpenMenuKey.v)
	                    save()
	                end
	                imgui.SameLine()
	                imgui.Text(u8" Îòêðûòü ìåíþ ñêðèïòà")
	                if ini.main.bindkeys then
	                	imgui.SetWindowSizeVec2(imgui.ImVec2(275, 240))
	                	imgui.Text(u8(bindkeysinfo))
	                end
					imgui.EndPopup()
			    end

                imgui.SameLine()
                if imgui.Button(fa.FACE_SMILE..u8" Role Play", imgui.ImVec2(190, 25)) then
					imgui.OpenPopup(fa.FACE_SMILE..u8" Role Play") 
                end
                if imgui.BeginPopupModal(fa.FACE_SMILE..u8" Role Play", new.bool(true), imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
            	 	if ini.main.smilesys then
						imgui.SetWindowSizeVec2(imgui.ImVec2(393, 108))
					else
						imgui.SetWindowSizeVec2(imgui.ImVec2(393, 82))
					end
				    imgui.Text(u8"Âàø ïîë:")
		            imgui.SameLine()
		            imgui.PushItemWidth(100)
		            if imgui.Combo("##1", gender, genders, #arr_gender) then
		            	ini.main.gender = gender[0]
		            	save()
		            end
		            imgui.PopItemWidth()
		            imgui.SameLine()
		            if imgui.Button(fa.FACE_SMILE..u8(ini.main.smilesys and ' Âûêëþ÷èòü' or ' Âêëþ÷èòü')..u8" ñèñòåìó ñìàéëîâ") then
						ini.main.smilesys = not ini.main.smilesys
	                    save()
	                end
	                imgui.SetCursorPosX(171)
	                if imgui.Button(fa.GUN..u8(ini.main.rpguns and ' Âûêëþ÷èòü' or ' Âêëþ÷èòü')..u8" îòûãðîâêó îðóæèÿ") then
						ini.main.rpguns = not ini.main.rpguns
						rp_thread:terminate()
						rp_thread:run()
						save()
	                end
	                if ini.main.smilesys then
			            if imgui.CollapsingHeader(u8"Äîñòóïíûå ñìàéëû") then
			            	imgui.SetWindowSizeVec2(imgui.ImVec2(393, 335))
			                if ini.main.gender == 0 then
			                    imgui.PushTextWrapPos(imgui.GetWindowSize().x - 40 );
			                    imgui.Text(u8(dostupsmiletext0))
			                elseif ini.main.gender == 1 then
			                    imgui.PushTextWrapPos(imgui.GetWindowSize().x - 40 );
			                    imgui.Text(u8(dostupsmiletext1))
			                end
			            end
			        end
					imgui.EndPopup()
			    end

			    if imgui.Button(fa.COMMENTS..u8(ini.main.separate_msg and ' Âûêëþ÷èòü' or ' Âêëþ÷èòü')..u8" ðàçäåëåíèå ñîîáùåíèÿ íà äâà", imgui.ImVec2(385, 25)) then
                    ini.main.separate_msg = not ini.main.separate_msg
                    save()
                end
				if imgui.Button(fa.CAMERA..u8" CamHack: "..(ini.main.camhack and 'ON' or 'OFF').."", imgui.ImVec2(385, 25)) then
                    ini.main.camhack = not ini.main.camhack
					save()
                end
				
				if imgui.Button(fa.BOOK..u8" Êíèãà", imgui.ImVec2(190, 25)) then
                    if ini.main.gender == 0 then
                        sampSendChat("/me äîñòàë êíèãó è íà÷àë ÷èòàòü å¸")
                    elseif ini.main.gender == 1 then
                        sampSendChat("/me äîñòàëà êíèãó è íà÷àëà ÷èòàòü å¸")
                    end
					gotofunc("OpenBook")
                end
				
				imgui.Separator()
				imgui.SetCursorPosX(95)
				imgui.NewInputText('##SearchBar', buffers.search_cmd, 300, u8'Ïîèñê ïî ñïèñêó', 2)
				imgui.Separator()
				imgui.PushItemWidth(130)
				
				for k, v in orderedPairs(imguiInputsCmdEditor) do
					if str(buffers.search_cmd) ~= "" then
						if k:find(str(buffers.search_cmd)) or str(v.var):find(str(buffers.search_cmd)) then
							if imgui.InputText(k, v.var, sizeof(v.var)) then
								ini.commands[v.cfg] = str(v.var)
								save()
							end
						end
					else
						if imgui.InputText(k, v.var, sizeof(v.var)) then
							ini.commands[v.cfg] = str(v.var)
							save()
						end
					end
				end
				
			elseif tab[0] == 5 then
				imgui.Text(fa.PALETTE..u8" Èçìåíåíèå òåìû:")
				--[[if imgui.Combo("##1", int_item, ImItems, #item_list) then
					ini.themesetting.theme = int_item[0]+1
					save()
					SwitchTheStyle(ini.themesetting.theme) 
				end]]
				local clrs = {
					imgui.ImVec4(0.26, 0.59, 0.98, 1.00),
					imgui.ImVec4(1.00, 0.28, 0.28, 1.00),
					imgui.ImVec4(0.98, 0.43, 0.26, 1.00),
					imgui.ImVec4(0.26, 0.98, 0.85, 1.00),
					imgui.ImVec4(0.10, 0.09, 0.12, 1.00),
					imgui.ImVec4(0.41, 0.19, 0.63, 1.00),
					imgui.ImVec4(0.10, 0.09, 0.12, 1.00),
					imgui.ImVec4(0.20, 0.25, 0.29, 1.00),
					imgui.ImVec4(0.457, 0.200, 0.303, 1.00),
					imgui.ImVec4(0.00, 0.69, 0.33, 1.00),
					imgui.ImVec4(0.46, 0.11, 0.29, 1.00),
					imgui.ImVec4(0.13, 0.75, 0.55, 1.00),
					imgui.ImVec4(0.73, 0.36, 0.00, 1.00),
				}
				for i = 1, #item_list do
					imgui.PushStyleColor(imgui.Col.CheckMark, clrs[i])
					if ini.themesetting.theme == i then imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.80, 0.80, 0.80, 1.00)) end
					
					if imgui.RadioButtonBool(u8"##òåìàáëÿòü"..i, ini.themesetting.theme == i and false or true) then
						ini.themesetting.theme = i
						save()
						SwitchTheStyle(ini.themesetting.theme)
					end
					
					if ini.themesetting.theme == i then imgui.PopStyleColor() end
					imgui.SameLine()
				end
				imgui.NewLine()
				
				if imgui.SliderFloat(u8"##Rounded", sliders.roundtheme, 0, 10, '%.1f') then
					ini.themesetting.rounded = sliders.roundtheme[0]
					imgui.GetStyle().WindowRounding = sliders.roundtheme[0]
					imgui.GetStyle().ChildRounding = sliders.roundtheme[0]
					imgui.GetStyle().FrameRounding = sliders.roundtheme[0]
					imgui.GetStyle().GrabRounding = sliders.roundtheme[0]
					imgui.GetStyle().PopupRounding = sliders.roundtheme[0]
					imgui.GetStyle().ScrollbarRounding = sliders.roundtheme[0]
					imgui.GetStyle().TabRounding = sliders.roundtheme[0]
					save()
				end
				imgui.SameLine()
				imgui.Hint(u8"Èçìåíÿåò çíà÷åíèå çàêðóãëåíèÿ îêíà, ÷àéëäîâ, ïóíêòîâ ìåíþ è êîìïîíåíòîâ (ñòàíäàðòíîå çíà÷åíèå 4.0).", 0.2)
				
				if imgui.Combo(translate('textChooseLanguage'), lang_int, lang_items, #lang_list) then
					ini.main.language = lang_int[0]+1
					save()
				end

				if imgui.Checkbox(u8"Îáâîäêà îêíà è êîìïîíåíòîâ", checkboxes.windowborder) then
					ini.themesetting.windowborder = checkboxes.windowborder[0]
					if ini.themesetting.windowborder then
						imgui.GetStyle().WindowBorderSize = 1
						imgui.GetStyle().FrameBorderSize = 1
						imgui.GetStyle().PopupBorderSize = 1
						imgui.GetStyle().TabBorderSize = 1
					else
						imgui.GetStyle().WindowBorderSize = 0
						imgui.GetStyle().FrameBorderSize = 0
						imgui.GetStyle().PopupBorderSize = 0
						imgui.GetStyle().TabBorderSize = 0
					end
					save()
				end
				imgui.SameLine()
				imgui.Hint(u8"Âêëþ÷àåò è âûêëþ÷àåò ëåãêóþ îáâîäêó îêíà è êîìïîíåíòîâ (êíîïêè, ñëàéäåðû è ò.ä.).", 0.2)
				if imgui.Checkbox(u8"Öåíòðèðîâàíèå òåêñòà ïóíêòîâ ìåíþ", checkboxes.centeredmenu) then
					ini.themesetting.centeredmenu = checkboxes.centeredmenu[0]
					save()
				end
				imgui.SameLine()
				imgui.Hint(u8"Âû ìîæåòå âûðîâíÿòü òåêñò â ìåíþ ïî ñâîåìó æåëàíèþ.", 0.2)
				
				if imgui.Checkbox(u8"Ðàçìûòèå çàäíåãî ôîíà", checkboxes.blurmode) then
					ini.themesetting.blurmode = checkboxes.blurmode[0]
					save()
				end
				imgui.SameLine()
				imgui.Hint(u8"Âû ìîæåòå âûðîâíÿòü òåêñò â ìåíþ ïî ñâîåìó æåëàíèþ.", 0.2)
				if ini.themesetting.blurmode then
					if imgui.SliderFloat("##BlurRadius", sliders.blurradius, 0.500, 100.0) then
						ini.themesetting.blurradius = sliders.blurradius[0]
						save()
					end
				end

				if imgui.Checkbox(u8"Íîâûé öâåò äèàëîãîâ", checkboxes.dialogstyle) then
					ini.themesetting.dialogstyle = checkboxes.dialogstyle[0]
					save()
					gotofunc("DialogStyle")
				end
				imgui.SameLine()
				imgui.Hint(u8"Èçìåíÿåò öâåò äèàëîãîâûõ îêîí ïîõîæèõ êàê íà ëàóí÷åðå Arizona RP.", 0.2)
				
				if imgui.Checkbox(u8"Ñîîáùåíèå ñêðèïòà ïðè çàãðóçêå", checkboxes.riveryahellomsg) then
					ini.main.riveryahellomsg = checkboxes.riveryahellomsg[0]
					save()
					if ini.main.riveryahellomsg then
						sampAddChatMessage(script_name..'{FFFFFF} Ïðèâåòñòâåííîå ñîîáùåíèå ñêðèïòà {73b461}âêëþ÷åíî!', 0x73b461)
					else
						sampAddChatMessage(script_name..'{FFFFFF} Ïðèâåòñòâåííîå ñîîáùåíèå ñêðèïòà {DC4747}îòêëþ÷åíî!', 0x73b461)
					end
				end
				imgui.SameLine()
				imgui.Hint(u8"Âêëþ÷àåò èëè âûêëþ÷àåò ñîîáùåíèå ñêðèïòà ïðè çàãðóçêå", 0.2)
				
				if imgui.Button(u8'Ïåðåçàãðóçèòü ñêðèïò '..fa.ARROWS_ROTATE..'') then
					showCursor(false, false)
					sampAddChatMessage(script_name..'{FFFFFF} Ñêðèïò áûë ïåðåçàãðóæåí èç-çà íàæàòèÿ êíîïêè {DC4747}"Ïåðåçàãðóçèòü ñêðèïò"{FFFFFF}!', 0x73b461)
					thisScript():reload()
				end
				if imgui.Button(u8'Âûêëþ÷èòü ñêðèïò '..fa.POWER_OFF..'', imgui.SameLine()) then 
					showCursor(false, false)
					sampAddChatMessage(script_name..'{FFFFFF} Ñêðèïò áûë âûãðóæåí èç-çà íàæàòèÿ êíîïêè {DC4747}"Âûêëþ÷èòü ñêðèïò"{FFFFFF}!', 0x73b461)
					thisScript():unload() 
				end
				
				if updatesavaliable then
					versionold = u8'(íå àêòóàëüíàÿ)'
					imgui.SameLine()
					if imgui.Button(u8'Ïðîâåðèòü îáíîâëåíèå '..fa.DOWNLOAD..'', imgui.ImVec2(165, 0)) then
						imgui.OpenPopup(fa.DOWNLOAD..u8" Äîñòóïíî îáíîâëåíèå!")
					end
					if imgui.BeginPopupModal(fa.DOWNLOAD..u8" Äîñòóïíî îáíîâëåíèå!", new.bool(true), imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
						imgui.SetWindowSizeVec2(imgui.ImVec2(305, 135))
						imgui.Text(u8"Âàì äîñòóïíî îáíîâëåíèå ñ GitHub!")
						imgui.Text(u8"Æåëàåòå îáíîâèòüñÿ ñ "..thisScript().version..u8" äî àêòóàëüíîé?")
						imgui.NewLine()
						imgui.SetCursorPosX(5)
						if imgui.Button(u8"Îáíîâèòü", imgui.ImVec2(295, 20)) then
							sampAddChatMessage(script_name.."{FFFFFF} Ñêðèïò {42B166}îáíîâëÿåòñÿ...", 0x73b461)
							update():download()
						end
						if imgui.Button(u8"Çàêðûòü", imgui.ImVec2(295, 20)) then 
							imgui.CloseCurrentPopup() 
						end
						imgui.EndPopup()
					end
				else
					versionold = u8'(àêòóàëüíàÿ)'
					imgui.SameLine()
					if imgui.Button(u8'Ïðîâåðèòü îáíîâëåíèå '..fa.DOWNLOAD..'', imgui.ImVec2(165, 0)) then
						sampAddChatMessage(script_name.."{FFFFFF} Ó âàñ óñòàíîâëåíà ñàìàÿ ïîñëåäíÿÿ âåðñèÿ ñêðèïòà!", 0x73b461)
					end
				end
				imgui.SameLine()
				if imgui.Button(fa.CLOCK) then
					imgui.OpenPopup(fa.CLOCK..u8" Ëîã îáíîâëåíèé") 
                end
                if imgui.BeginPopupModal(fa.CLOCK..u8" Ëîã îáíîâëåíèé", new.bool(true), imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
                	imgui.SetWindowSizeVec2(imgui.ImVec2(475, 300))
					for k,v in pairs(listUpdate) do
						local header = v.v
						if k == 1 then header = fa.FIRE .. u8(' ' .. header .. ' | Àêòóàëüíàÿ âåðñèÿ') end
						if imgui.CollapsingHeader(header) then
							imgui.TextWrapped(u8(v.context))
						end
					end
					imgui.EndPopup()
			    end
				
				imgui.Separator()
				
				local _, myid = sampGetPlayerIdByCharHandle(playerPed)
				local mynick = sampGetPlayerNickname(myid) -- íàø íèê êð÷
				local myping = sampGetPlayerPing(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				local framerate = imgui.GetIO().Framerate
				
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1))
				imgui.Text(fa.USER..u8' Ïîëüçîâàòåëü: '..mynick..'['..myid..u8'] ('..fa.SIGNAL..u8' Ïèíã: '..myping..')')
				imgui.Text(fa.CLOCK..u8(string.format(' Òåêóùàÿ äàòà: %s', os.date("%d.%m.%Y %H:%M:%S"))))
				imgui.Text(fa.IMAGES..u8(string.format(" FPS: "..fps.."")))
				imgui.Text(fa.FOLDER..u8' Âåðñèÿ: '..thisScript().version..' '..versionold..'')
				imgui.Text(fa.ADDRESS_CARD..u8' Àâòîð:')
				imgui.SameLine() 
				imgui.Link('https://github.com/riverya4life', script_author)
				imgui.SameLine() 
				if imgui.Button(fa.CLOUD) then 
					imgui.OpenPopup(u8"Àâòîð: riverya4life") 
				end
				imgui.PopStyleColor()
				if imgui.BeginPopupModal(u8"Àâòîð: riverya4life", new.bool(true), imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
					imgui.SetWindowSizeVec2(imgui.ImVec2(170, 85))
					imgui.SetCursorPosX(5)
					if imgui.Button('Discord', imgui.ImVec2(50, 50)) then 
						link = 'https://discord.gg/Q69xQnzR6m'
						os.execute('explorer "'..link..'"')
					end
					imgui.SameLine()
					imgui.SetCursorPosX(60)
					if imgui.Button('GitHub', imgui.ImVec2(50, 50)) then 
						link = 'https://github.com/riverya4life'
						os.execute('explorer "'..link..'"')
					end
					imgui.SameLine()
					imgui.SetCursorPosX(115)
					if imgui.Button(u8'TG', imgui.ImVec2(50, 50)) then 
						link = 'https://t.me/riverya4lifeoff'
						os.execute('explorer "'..link..'"')
					end
					imgui.SetCursorPosX(5)
					if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(160, 20)) then 
						imgui.CloseCurrentPopup() 
					end
					imgui.EndPopup()
				end
				
				imgui.SetCursorPos(imgui.ImVec2(435, 10))
				imgui.BeginChild("##iconstyles", imgui.ImVec2(100, 135), true)
					imgui.Text(fa.INFO..u8" Òèï èêîíîê:")
					for k, v in ipairs(ICON_STYLE) do
						if imgui.RadioButtonBool(v, ini.themesetting.iconstyle == k) then
							ini.themesetting.iconstyle = k
							save()
							sampAddChatMessage(script_name.."{FFFFFF} Ñòèëü èêîíîê èçìåíåí íà {dc4747}"..v.."!", 0x73b461)
							sampAddChatMessage(script_name.."{FFFFFF} Òàê êàê Âû âíåñëè èçìåíåíèÿ â ñòèëü èêîíîê ñêðèïòà, åìó ïîòðåáóåòñÿ ïåðåçàãðóçêà (Êíîïêà 'Ïåðåçàãðóçèòü ñêðèïò')!", 0x73b461)
						end
					end
				imgui.EndChild()
			end
			imgui.PopFont()
			imgui.PopStyleColor()
			imgui.EndChild()
        imgui.End()
    end
)

local BookFrame = imgui.OnFrame(
    function() return riveryabook.alpha > 0.00 end,
    function(self)
        self.HideCursor = not riveryabook.state
        if isKeyDown(32) and self.HideCursor == false then
            self.HideCursor = true
        elseif not isKeyDown(32) and self.HideCursor == true and riveryabook.state then
            self.HideCursor = false
        end
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, riveryabook.alpha)
		
        imgui.SetNextWindowSize(imgui.ImVec2(460, 280), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
		imgui.Begin(fa.BOOK..u8" Book", new.bool(true), imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
			imgui.SetCursorPos(imgui.ImVec2(5, 5))
			if CloseButton("##Close", new.bool(true), 0) then
				riveryabook.switch()
			end
			imgui.SetCursorPos(imgui.ImVec2(30, 5))
			if imgui.Button(u8"Îáíîâèòü") then
				if doesFileExist("moonloader\\mybook.txt") then
					book_text = {}
					local file = io.open("moonloader\\mybook.txt", "a+") -- îòêðûâàåì ôàéë
					for line in file:lines() do -- ÷èòàåì åãî ïîñòðî÷íî
						book_text[#book_text+1] = line -- çàïèñûâàåì ñòðîêè â ìàññèâ
					end
					file:close() -- çàêðûâàåì ôàéë
				end
			end
			imgui.SameLine()
			imgui.Hint(u8"Âàøà êíèãà íàõîäèòñÿ ïî ïóòè: \"âàøà ñáîðêà/moonloader/mybook.txt\"\nÂû ìîæåòå èçìåíÿòü ñîäåðæèìîå ôàéëà\nP.S ñîõðàíÿéòå ôàéë â êîäèðîâêå UTF-8 ÷òîáû ó âàñ íå áûëî èåðîãëèôîâ èëè âîïðîñîâ!", 0.2)
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(103, 5))
			imgui.Text(fa.BOOK..u8" Êíèãà by "..script_author.."")
			imgui.Separator()
			imgui.PushTextWrapPos(imgui.GetWindowSize().x - 40 );
			for _,v in ipairs(book_text) do
				imgui.PushFont(fontsize_book)
					imgui.Text(v)
				imgui.PopFont()
			end
		--end
		imgui.End()
	end
)

function onReceivePacket(id) -- áóäåò ôëóäèòü wrong server password äî òåõ ïîð, ïîêà ñåðâåð íå îòêðîåòñÿ
	if id == 37 then
		sampSetGamestate(1)
	end
end

function samp.onPlayerChatBubble(id, col, dist, dur, msg)
	if flymode == 1 then
		return {id, col, 1488, dur, msg}
	end
end

function updatefps()
    lua_thread.create(function()
        while true do
			wait(150)
            fps = ("%.0f"):format(memory.getfloat(0xB7CB50, true))
        end
    end)
end

function ev.onSendPlayerSync(data) -- áàííè õîï
	if data.keysData == 40 or data.keysData == 42 then sendOnfootSync(); data.keysData = 32 end
end

function sendOnfootSync()
	local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local data = allocateMemory(68)
	sampStorePlayerOnfootData(myId, data)
	setStructElement(data, 4, 1, 0, false)
	sampSendOnfootData(data)
	freeMemory(data)
end -- òóò êîíåö óæå

function ev.onSetVehicleVelocity(turn, velocity)
    if velocity.x ~= velocity.x or velocity.y ~= velocity.y or velocity.z ~= velocity.z then
        sampAddChatMessage("[Warning] ignoring invalid SetVehicleVelocity", 0x00FF00)
        return false
    end
end

function ev.onServerMessage(color, text)
	if text:find("%[Îøèáêà%] {FFFFFF}Äîñòóïíî òîëüêî ñ ìîáèëüíîãî èëè PC ëàóí÷åðà!") then
		return false
	end
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Ñêðûòèå ïàðîëÿ áàíêîâñêîé êàðòû by chapo
    return {id, text == '{929290}Âû äîëæíû ïîäòâåðäèòü ñâîé PIN-êîä ê êàðòî÷êå.\nÂâåäèòå ñâîé êîä â íèæå óêàçàíóþ ñòðîêó.' and 3 or style, title, button1, button2, text}
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Ñêðûòèå êîäà ñêëàäñêèõ ïîìåùåíèé by õóé åãî çíàåò, íî îðèãèíàë chapo
    return {id, text == '{ffffff}×òîáû îòêðûòü ýòîò ñêëàä, ââåäèòå ñïåöèàëüíûé' and 3 or style, title, button1, button2, text}
end

-- Functions Mooving Dialog by õóé åãî çíàåò íå ïîìíþ óæå
function sampGetDialogSize()
    return memory.getint32(CDialog + 0xC, true),
    memory.getint32(CDialog + 0x10, true)
end

function sampGetDialogCaptionHeight()
    return memory.getint32(CDXUTDialog + 0x126, true)
end

function sampGetDialogPos()
    return memory.getint32(CDialog + 0x04, true),
    memory.getint32(CDialog + 0x08, true)
end

function sampSetDialogPos(x, y)
    memory.setint32(CDialog + 0x04, x, true)
    memory.setint32(CDialog + 0x08, y, true)

    memory.setint32(CDXUTDialog + 0x116, x, true)
    memory.setint32(CDXUTDialog + 0x11A, y, true)
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function vehHaveGun() -- ïðèöåí íà òðàíñïîðòå by Cosmo (https://www.blast.hk/threads/72683/)
	for _, v in ipairs({425, 447, 464, 476, 520}) do
		if isCharInModel(playerPed, v) then 
			return true 
		end
	end
	return false
end

function renderCrosshair(x, y) -- ïðèöåí íà òðàíñïîðòå by Cosmo (https://www.blast.hk/threads/72683/)
	renderDrawPolygon(x, y, 5, 5, 8, 0, 0xFF606060)
	renderDrawPolygon(x, y, 3, 3, 8, 0, 0xFFFFFFFF)
end

function getRhinoCannonCorner(carHandle) -- ïðèöåí íà òðàíñïîðòå by Cosmo (https://www.blast.hk/threads/72683/)
	local ptr = getCarPointer(carHandle)
	local x = memory.getfloat(ptr + 0x94C, false) * 180.0 / math.pi
	local y = memory.getfloat(ptr + 0x950, false) * 180.0 / math.pi
	return x, y
end

function samp.onShowTextDraw(id, data)
    if showtextdraw then
        return false
    end
end

function ev.onSetMapIcon(iconId, position, type, color, style)
    if type > MAX_SAMP_MARKERS then
        return false
    end
end

--[[function patch()
	if memory.getuint8(0x748C2B) == 0xE8 then
		memory.fill(0x748C2B, 0x90, 5, true)
	elseif memory.getuint8(0x748C7B) == 0xE8 then
		memory.fill(0x748C7B, 0x90, 5, true)
	end
	if memory.getuint8(0x5909AA) == 0xBE then
		memory.write(0x5909AB, 1, 1, true)
	end
	if memory.getuint8(0x590A1D) == 0xBE then
		memory.write(0x590A1D, 0xE9, 1, true)
		memory.write(0x590A1E, 0x8D, 4, true)
	end
	if memory.getuint8(0x748C6B) == 0xC6 then
		memory.fill(0x748C6B, 0x90, 7, true)
	elseif memory.getuint8(0x748CBB) == 0xC6 then
		memory.fill(0x748CBB, 0x90, 7, true)
	end
	if memory.getuint8(0x590AF0) == 0xA1 then
		memory.write(0x590AF0, 0xE9, 1, true)
		memory.write(0x590AF1, 0x140, 4, true)
	end
end
patch()]]

--[[ffi.cdef('int MessageBoxA(void* hWnd, const char* lpText, const char* lpCaption, unsigned int uType);')
local _require = require
local require = function(moduleName, url)
    local status, module = pcall(_require, moduleName)
    if status then return module end
    local response = ffi.C.MessageBoxA(ffi.cast('void*', readMemory(0x00C8CF88, 4, false)), ('Áèáëèîòåêà "%s" íå íàéäåíà.%s'):format(moduleName, url and '\n\nÎòêðûòü ñòðàíèöó çàãðóçêè?' or ''), thisScript().name, url and 4 or 0)
    if response == 6 then
        os.execute(('explorer "%s"'):format(url))
    end
end]]

function gotofunc(fnc) -- by Gorskin (https://www.blast.hk/members/157398/) (ïðîñòî óäîáíî þçàòü ïèçäåö)
    ------------------------------------Ôèêñû è ïðî÷åå-----------------------------
    if fnc == "all" then
        callFunction(0x7469A0, 0, 0) --mousefix in pause
        --------[ôèêñ ñïàâíà ñ áóòûëêîé è ñèãàðîé]----------
        memory.setuint32(0x736F88, 0, false) --âåðòîëåò íå âçðûâàåòñÿ ìíîãî ðàç
        memory.fill(0x4217F4, 0x90, 21, false) --èñïðàâëåíèå ñïàâíà ñ áóòûëêîé
        memory.fill(0x4218D8, 0x90, 17, false) --èñïðàâëåíèå ñïàâíà ñ áóòûëêîé
        memory.fill(0x5F80C0, 0x90, 10, false) --èñïðàâëåíèå ñïàâíà ñ áóòûëêîé
        memory.fill(0x5FBA47, 0x90, 10, false) --èñïðàâëåíèå ñïàâíà ñ áóòûëêîé
        ---------------------------------------------
        if get_samp_version() == "r1" then
            memory.write(sampGetBase() + 0x64ACA, 0xFB, 1, true) --Min FontSize -5
            memory.write(sampGetBase() + 0x64ACF, 0x07, 1, true) --Max FontSize 7
            memory.write(sampGetBase() + 0xD7B00, 0x7420352D, 4, true) --FontSize StringInfo
            memory.write(sampGetBase() + 0xD7B04, 0x37206F, 4, true) --FontSize StringInfo
            memory.write(sampGetBase() + 0x64A51, 0x32, 1, true) --PageSize MAX
            memory.write(sampGetBase() + 0xD7AD5, 0x35, 1, true) --PageSize StringInfo
        elseif get_samp_version() == "r3" then
            memory.write(sampGetBase() + 0x67F2A, 0xFB, 1, true) --Min FontSize -5 (ìèíèìàëüíîå çíà÷åíèå äëÿ êîìàíäû /fontsize)
            memory.write(sampGetBase() + 0x67F2F, 0x07, 1, true) --Max FontSize 7 (ìàêñèìàëüíîå çíà÷åíèå äëÿ êîìàíäû /fontsize)
            memory.write(sampGetBase() + 0xE9DE0, 0x7420352D, 4, true) --FontSize StringInfo (âûâîäèò èíôó î ìèíèìàëüíîì çíà÷åíèè ïðè ââîäå /fontsize)
            memory.write(sampGetBase() + 0xE9DE4, 0x37206F, 4, true) --FontSize StringInfo (âûâîäèò èíôó î ìàêñèìàëüíîì çíà÷åíèè ïðè ââîäå /fontsize)
            memory.write(sampGetBase() + 0x67EB1, 0x32, 1, true) --PageSize MAX (ìàêñèìàëüíîå ÷èñëî äëÿ /pagesize)
            memory.write(sampGetBase() + 0xE9DB5, 0x35, 1, true) --PageSize StringInfo (âûâîäèò èíôó î ìàêñèìàëüíîì çíà÷åíèè ïðè ââîäå /pagesize)
        end
        ----------------------------------------------------------------------------
    end
    -----------------------------------------------------------------------
	if fnc == "OpenMenu" then
        riverya.switch()
	end
	if fnc == "OpenBook" then
        riveryabook.switch()
	end
	-----------------------Ãëàâíàÿ-----------------------
	if fnc == "BlockWeather" or fnc == "all" then
        if get_samp_version() == "r1" then
            if ini.main.blockweather then
                writeMemory(sampGetBase() + 0x9C130, 4, 0x0004C2, true)
            else
                writeMemory(sampGetBase() + 0x9C130, 4, 0x5D418B, true)
            end
        elseif get_samp_version() == "r3" then
            if ini.main.blockweather then
                writeMemory(sampGetBase() + 0xA0430, 4, 0x0004C2, true)
            else
                writeMemory(sampGetBase() + 0xA0430, 4, 0x5D418B, true)
            end
        end
    end
    
    if fnc == "SetTime" or fnc == "all" then
        setTimeOfDay(ini.main.time)
	end
    if fnc == "SetWeather" or fnc == "all" then
        forceWeatherNow(ini.main.weather)
	end
    
    if fnc == "BlockTime" or fnc == "all" then
        if get_samp_version() == "r1" then
            if ini.main.blocktime then
                writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
            else
                writeMemory(sampGetBase() + 0x9C0A0, 4, 0x0824448B, true)
            end
        elseif get_samp_version() == "r3" then
            if ini.main.blocktime then
                writeMemory(sampGetBase() + 0xA03A0, 4, 0x000008C2, true)
            else
                writeMemory(sampGetBase() + 0xA03A0, 4, 0x0824448B, true)
            end
        end
    end
	
	if fnc == "AnimationMoney" or fnc == "all" then
        if ini.main.animmoney == 1 then
            memory.write(5707667, 138, 1, true)
        elseif ini.main.animmoney == 2 then
            memory.write(5707667, 137, 1, true)
        elseif ini.main.animmoney == 3 then
            memory.write(5707667, 139, 1, true)
        end
	end
	if fnc == "MoneyFontStyle" or fnc == "all" then
        if ini.main.moneyfontstyle then
            memory.setint8(0x58F57F, ini.main.moneyfontstyle, true)
        end
    end
	if fnc == "MenuFontStyle" or fnc == "all" then
        if ini.main.menufontstyle then
            memory.setuint8(0x57958B, ini.main.menufontstyle, true)-- 2 çàìåíèòå íà ÷èñëî 0 - 3
        end
    end
	if fnc == "MenuAllFontStyle" or fnc == "all" then
        if ini.main.menuallfontstyle then
            memory.setuint8(0x5799AD, ini.main.menuallfontstyle, true)-- 2 çàìåíèòå íà ÷èñëî 0 - 3
        end
    end
    if fnc == "AlphaMap" or fnc == "all" then
		memory.setuint8(0x5864BD, ini.main.alphamap, true)
    end
	if fnc == "BlockSampKeys" or fnc == "all" then
        if ini.nop_samp_keys.key_F1 then
            writeMemory(sampGetBase() + ((get_samp_version() == "r1") and 0x713DF+1 or 0x752CF+1), 1, 0, true)--disa f1 0.3.7 R1 original byte 0x70
        else
            writeMemory(sampGetBase() + ((get_samp_version() == "r1") and 0x713DF+1 or 0x752CF+1), 1, 0x70, true)--disa f1 0.3.7 R1 original byte 0x70
        end
        if ini.nop_samp_keys.key_F4 then
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x797E or 0x79A4), 0, true)
        else
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x797E or 0x79A4), 115, true)
        end
        if ini.nop_samp_keys.key_F7 then
            memory.fill(sampGetBase() + ((get_samp_version() == "r1") and 0x5D8AD or 0x60C4D), 0xC3, 1, true)
        else
            memory.write(sampGetBase() + ((get_samp_version() == "r1") and 0x5D8AD or 0x60C4D), 0x8B, 1, true)
        end
        if ini.nop_samp_keys.key_T then
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x5DB04 or 0x60EA4), 0xC3, true)
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x5DAFA or 0x60E9A), 0xC3, true)
        else
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x5DB04 or 0x60EA4), 0x852F7574, true)
            memory.setint8(sampGetBase() + ((get_samp_version() == "r1") and 0x5DAFA or 0x60E9A), 0x900A7490, true)
        end
	end
	-----------------------Boost FPS-----------------------
	if fnc == "NoPostfx" or fnc == "all" then
        if ini.main.postfx then
            memory.write(7358318, 2866, 4, true)--postfx off
            memory.write(7358314, -380152237, 4, true)--postfx off
            writeMemory(0x53E227, 1, 0xC3, true)
        else
            memory.write(7358318, 1448280247, 4, true)--postfx on
            memory.write(7358314, -988281383, 4, true)--postfx on
            writeMemory(0x53E227, 1, 0xE9, true)
        end
	end
	if fnc == "NoEffect" or fnc == "all" then
		if ini.main.noeffects then
			memory.write(4891712, 8386, 4, false)
        else
            memory.write(4891712, 1443425411, 4, false)
        end
	end
    if fnc == "CleanMemory" then
        local oldram = ("%d"):format(tonumber(get_memory()))
        callFunction(0x53C500, 2, 2, 1, 1)
        callFunction(0x40D7C0, 1, 1, -1)
        callFunction(0x53C810, 1, 1, 1)
        callFunction(0x40CF80, 0, 0)
        callFunction(0x4090A0, 0, 0)
        callFunction(0x5A18B0, 0, 0)
        callFunction(0x707770, 0, 0)
        callFunction(0x40CFD0, 0, 0)
        local newram = ("%d"):format(tonumber(get_memory()))
        if ini.cleaner.cleaninfo then
            sampAddChatMessage(script_name.."{FFFFFF} Ïàìÿòè äî: {dc4747}"..oldram.." ÌÁ. {FFFFFF}Ïàìÿòè ïîñëå: {dc4747}"..newram.." ÌÁ. {FFFFFF}Î÷èùåíî: {dc4747}"..oldram - newram.." ÌÁ.", 0x73b461)
        end
    end
	if fnc == "LodDist" or fnc == "all" then
        memory.setfloat(0xCFFA11, ini.main.lod, true)
        local aWrites = {
            [1] = 0x555172+2, [2] = 0x555198+2, [3] = 0x5551BB+2, [4] = 0x55522E+2, [5] = 0x555238+2,
            [6] = 0x555242+2, [7] = 0x5552F4+2, [8] = 0x5552FE+2, [9] = 0x555308+2, [10] = 0x555362+2,
            [11] = 0x55537A+2, [12] = 0x555388+2, [13] = 0x555A95+2, [14] = 0x555AB1+2, [15] = 0x555AFB+2,
            [16] = 0x555B05+2, [17] = 0x555B1C+2, [18] = 0x555B2A+2, [19] = 0x555B38+2, [20] = 0x555B82+2,
            [21] = 0x555B8C+2, [22] = 0x555B9A+2, [23] = 0x5545E6+2, [24] = 0x554600+2, [25] = 0x55462A+2,
            [26] = 0x5B527A+2,
        }
        for i = 0, #aWrites do
            writeMemory(aWrites[i], 4, 0xCFFA11, true)
        end
    end
	-----------------------Èñïðàâëåíèÿ áëÿòü-----------------------
	if fnc == "FixBloodWood" or fnc == "all" then
        if ini.fixes.fixbloodwood then
            writeMemory(0x49EE63+1, 4, 0, true)--fix blood wood
        else
            writeMemory(0x49EE63+1, 4, 0x3F800000, true)--fix blood wood
        end
    end
	if fnc == "NoLimitMoneyHud" or fnc == "all" then
        if ini.fixes.nolimitmoneyhud then
            writeMemory(0x571784, 4, 0x57C7FFF, true)
            writeMemory(0x57179C, 4, 0x57C7FFF, true)
        else
            writeMemory(0x571784, 4, 0x57C3B9A, true)
            writeMemory(0x57179C, 4, 0x57C3B9A, true)
        end
    end
	if fnc == "SunFix" or fnc == "all" then
		if ini.fixes.sunfix then 
			memory.hex2bin("E865041C00", 0x53C136, 5) 
			memory.protect(0x53C136, 5, memory.unprotect(0x53C136, 5))
		else 
			memory.fill(0x53C136, 0x90, 5, true)
		end
	end
	if fnc == "GrassFix" or fnc == "all" then
		if ini.fixes.grassfix then 
			memory.hex2bin("E8420E0A00", 0x53C159, 5) 
			memory.protect(0x53C159, 5, memory.unprotect(0x53C159, 5)) 
		else 
			memory.fill(0x53C159, 0x90, 5, true)
        end
	end
	if fnc == "MoneyFontFix" or fnc == "all" then
		if ini.fixes.moneyfontfix then
			memory.setint32(0x866C94, 0x6430302524, true) -- Ïîçèòèâíûå äåíüãè ñ óäàëåíèåì íóëåé
			memory.setint64(0x866C8C, 0x64303025242D, true) -- Íåãàòèâíûå äåíüãè ñ óäàëåíèåì íóëåé
        else
            memory.setint32(0x866C94, 0x6438302524, true) -- Ïîçèòèâíûå äåíüãè ñòàíäàðòíîå çíà÷åíèå
			memory.setint64(0x866C8C, 0x64373025242D, true) -- Íåãàòèâíûå äåíüãè ñòàíäàðòíîå çíà÷åíèå
        end
	end
	if fnc == "StarsOnDisplay" or fnc == "all" then
		if ini.fixes.starsondisplay then
			memory.fill(0x58DD1B, 0x90, 2, true)
		else
			memory.fill(0x58DFD3, 0x90, 5, true)
        end
	end
    if fnc == "Vsync" or fnc == "all" then
        if ini.main.vsync then
            memory.write(0xBA6794, 1, 1, true)
        else
            memory.write(0xBA6794, 0, 1, true)
        end
    end
    if fnc == "FixSensitivity" or fnc == "all" then
        if ini.fixes.sensfix then
            memory.write(5382798, 11987996, 4, true)
            memory.write(5311528, 11987996, 4, true)
            memory.write(5316106, 11987996, 4, true)
        else
            memory.write(5382798, 11987992, 4, true)
            memory.write(5311528, 11987992, 4, true)
            memory.write(5316106, 11987992, 4, true)
        end
	end
    if fnc == "FixBlackRoads" or fnc == "all" then
        if ini.fixes.fixblackroads then
            memory.write(8931716, 0, 4, true)
        else
            memory.write(8931716, 2, 4, true)
        end
	end
    if fnc == "FixLongArm" or fnc == "all" then
        if ini.fixes.longarmfix then
            memory.write(7045634, 33807, 2, true)
            memory.write(7046489, 33807, 2, true)
        else
            memory.write(7045634, 59792, 2, true)
            memory.write(7046489, 59792, 2, true)
        end
	end
	if fnc == "InteriorRun" or fnc == "all" then
        if ini.fixes.intrun then
            memory.write(5630064, -1027591322, 4, true)
            memory.write(5630068, 4, 2, true)
        else
            memory.write(5630064, 69485707, 4, true)
            memory.write(5630068, 1165, 2, true)
        end
        checkboxes.intrun[0] = ini.fixes.intrun
	end
	if fnc == "FixCrosshair" or fnc == "all" then
        if ini.fixes.fixcrosshair then
            memory.write(0x058E280, 0xEB, 1, true)
        else
            memory.write(0x058E280, 0x7A, 1, true)
        end
        checkboxes.fixcrosshair[0] = ini.fixes.fixcrosshair
	end
	if fnc == "PlaceName" or fnc == "all" then
		if ini.fixes.placename then
			location = getGxtText(getNameOfZone(getCharCoordinates(PLAYER_PED)))
			if location ~= plocation then
				printStyledString("~w~"..location, 500, 2)
				plocation = location
			end
		end
	end
	if fnc == "PatchDuck" or fnc == "all" then
        if ini.fixes.patchduck then
            writeMemory(0x692649+1, 1, 6, true)--patch anim duck
        else
            writeMemory(0x692649+1, 1, 8, true)--patch anim duck
        end
    end
	if fnc == "BlurReturn" or fnc == "all" then
		if ini.fixes.blurreturn then
			memory.fill(0x704E8A, 0xE8, 1, true)
			memory.fill(0x704E8B, 0x11, 1, true)
			memory.fill(0x704E8C, 0xE2, 1, true)
			memory.fill(0x704E8D, 0xFF, 1, true)
			memory.fill(0x704E8E, 0xFF, 1, true)
		else
			memory.fill(0x704E8A, 0x90, 1, true)
			memory.fill(0x704E8B, 0x90, 1, true)
			memory.fill(0x704E8C, 0x90, 1, true)
			memory.fill(0x704E8D, 0x90, 1, true)
			memory.fill(0x704E8E, 0x90, 1, true)
		end
	end
	if fnc == "ForceAniso" or fnc == "all" then
        if ini.fixes.forceaniso then
            if readMemory(0x730F9C, 1, true) ~= 0 then
                memory.write(0x730F9C, 0, 1, true)-- force aniso
                loadScene(20000000, 20000000, 20000000)
                callFunction(0x40D7C0, 1, 1, -1)
            end
        else
            if readMemory(0x730F9C, 1, true) ~= 1 then
                memory.write(0x730F9C, 1, 1, true)-- force aniso
                loadScene(20000000, 20000000, 20000000)
                callFunction(0x40D7C0, 1, 1, -1)
            end
        end
    end
	-----------------------Êîìàíäû è ïðî÷åå-----------------------
	if fnc == "ShowNicks" then
        if ini.main.shownicks then
            memory.setint16(sampGetBase() + 0x70D40, 0xC390, true)
        else
            memory.setint16(sampGetBase() + 0x70D40, 0x8B55, true)
        end
	end
	if fnc == "ShowHP" then
		if ini.main.showhp then
			memory.setint16(sampGetBase() + 0x6FC30, 0xC390, true)
		else
			memory.setint16(sampGetBase() + 0x6FC30, 0x8B55, true)
		end
	end
	if fnc == "NoRadio" then
        if ini.main.noradio then
            memory.write(5159328, -1947628715, 4, true)
        else
            memory.write(5159328, -1962933054, 4, true)
        end
	end
	if fnc == "DelGun" then
        if ini.main.delgun == true and isKeyJustPressed(46) and not sampIsCursorActive() then
            removeAllCharWeapons(PLAYER_PED)
        end
	end
	if fnc == "ClearChat" then
		memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
        memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
        memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    end
	if fnc == "ShowChat" then
		if ini.main.showchat then
			memory.write(sampGetBase() + 0x7140F, 1, 1, true)
			sampSetChatDisplayMode(0)
		else
			memory.write(sampGetBase() + 0x7140F, 0, 1, true)
			sampSetChatDisplayMode(3)
		end
	end
	if fnc == "ShowHud" then
		if ini.main.showhud then
            displayHud(true)
            memory.setint8(0xBA676C, 0)
        else
            displayHud(false)
            memory.setint8(0xBA676C, 2)
        end
	end
	-----------------------Íàñòðîéêè-----------------------
	if fnc == "DialogStyle" or fnc == "all" then
		if ini.themesetting.dialogstyle then 
			setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) 
			SetClassSelectionColors(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) 
		else 
			setDialogColor(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
			SetClassSelectionColors(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
		end
	end
	--[[if fnc == "RussianSAMP" or fnc == "all" then
		local function write_string(address, value)
			value = value.."\x00"
			memory.copy(address, memory.strptr(value), #value, true)
		end

		local array = {
			r1 = {0xD83A8, 0xD3B8C, 0xD3B50, 0xD3B34, 0xD3AB0, 0xD3A78, 0xD3A58, 0xD3A10, 0xD3998, 0xD8380, 0xD8364, 0xD3D8C},
			r2 = {0xD83B8, 0xD3B98, 0xD3B58, 0xD3B3C, 0xD3AB8, 0xD3A80, 0xD3A60, 0xD3A18, 0xD399C, 0xD8394, 0xD8378, 0xD3D98},
			r3 = {0xEA780, 0xE5B98, 0xE5B58, 0xE5B3C, 0xE5AB8, 0xE5A80, 0xE5A60, 0xE5A18, 0xE599C, 0xEA75C, 0xEA740, 0xE6060},
			r4 = {0xEA7D8, 0xE5B98, 0xE5B58, 0xE5B3C, 0xE5AB8, 0xE5A80, 0xE5A60, 0xE5A18, 0xE599C, 0xEA7B4, 0xEA798, 0xE6060},
			dl = {0x11C800, 0x117C08, 0x117BC8, 0x117BAC, 0x117B28, 0x117AF0, 0x117AD0, 0x117A88, 0x117A0C, 0x11C7DC, 0x11C7C0, 0x1180EC}
		}

		local sampstrings = {
			"[Àéäè: %d, Òèï: %d Ïîäâèä: %d Õï: %.1f Ïðåäçàãðóæåí: %u]\nÄèñòàíöèÿ: %.2fm\nÏàññàæèðîê: %u\nÊëèåíòñêàÿ Ïîçèöèÿ: %.3f,%.3f,%.3f\nÏîçèöèÿ ñïàâíà: %.3f,%.3f,%.3f",
			"Ïîäêëþ÷åíî. Ïðèñîåäèíÿþñü ê èãðå...",
			"Ïîòåðÿíî ñîåäèíåíèå.",
			"Ñåðâåð ïåðåçàãðóæàåòñÿ.",
			"Ñåðâåð íå îòâåòèë. Ïîâòîðíàÿ ïîïûòêà..",
			"Ñåðâåð çàêðûë ñîåäèíåíèå.",
			"Ñåðâåð ïåðåïîëíåí. Ïîâòîðíàÿ ïîïûòêà...",
			"Âû çàáàíåíû íà ýòîì ñåðâåðå.",
			"Ïîäêëþ÷åíèå ê %s:%d",
			"Ñäåëàí ñíèìîê ýêðàíà - sa-mp-%03i.png",
			"Ñäåëàí ñíèìîê ýêðàíà - ",
			"Ïîäêëþ÷èëèñü ê {B9C9BF}%.64s",
		}
		array = array[get_samp_version()]
		if array ~= nil then
			for i, str in ipairs(sampstrings) do
				write_string(getModuleHandle("samp.dll") + array[i], str)
			end
		end
	end]]
end

function imgui.Ques(text)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(u8(text))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

--[[function imgui.CenterText(text)
    imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8(text)).x) / 2)
    imgui.Text(text)
end]]

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val, sizeof(val))
    if #str(val) == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function imgui.Link(link,name,myfunc)
	myfunc = type(name) == 'boolean' and name or myfunc or false
	name = type(name) == 'string' and name or type(name) == 'boolean' and link or link
	local size = imgui.CalcTextSize(name)
	local p = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local resultBtn = imgui.InvisibleButton('##'..link..name, size)
	if resultBtn then
		if not myfunc then
		    os.execute('explorer '..link)
		end
	end
	imgui.SetCursorPos(p2)
	if imgui.IsItemHovered() then
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], name)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
	else
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Button], name)
	end
	return resultBtn
end

function imgui.Hint(text, delay, action)
	imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5
        if os.clock() >= go_hint then
            imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.11, 0.11, 0.11, 1.00))
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], u8'Ïîäñêàçêà:')
                    imgui.TextUnformatted(text)
                    if action ~= nil then
                        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.TextDisabled], '\n '..action)
                    end
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar(2)
        end
    end
end

function imgui.BeginTitleChild(str_id, size, rounding, offset, panelBool)
    imgui.SetCursorPosY(imgui.GetCursorPosY()+20)
    if panelBool == nil then panelBool = true end
    panelBool = panelBool and true or false
    offset = offset or 50
    local DL = imgui.GetWindowDrawList()
    local posS = imgui.GetCursorScreenPos()
    local title = str_id:gsub('##.+$', '')
    local sizeT = imgui.CalcTextSize(title)
    local bgColor = imgui.GetStyle().Colors[imgui.Col.Button]
    local bgColor = imgui.GetColorU32Vec4(imgui.ImVec4(bgColor.x, bgColor.y, bgColor.z, 1.0))
    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, ini.themesetting.rounded)
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.BeginChild(str_id, size, true)
    imgui.PopStyleVar(1)
    imgui.Spacing()
    imgui.PopStyleColor(3)
    size.x = size.x == -1.0 and imgui.GetWindowWidth() or size.x
    size.y = size.y == -1.0 and imgui.GetWindowHeight() or size.y
    if not panelBool then DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), bgColor, ini.themesetting.rounded, 11+4, 1.6) end
    if panelBool == true then DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), bgColor, ini.themesetting.rounded, 7+5, 1.6)
    DL:AddRectFilled(imgui.ImVec2(posS.x, posS.y - 25), imgui.ImVec2(posS.x + size.x, posS.y + size.x/size.y ), bgColor, ini.themesetting.rounded, 3)
    
    DL:AddText(imgui.ImVec2(posS.x + offset, posS.y - 10 - (sizeT.y / 2)), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Text]), title) end
end

-- labels - Array - íàçâàíèÿ ýëåìåíòîâ ìåíþ
-- selected - imgui.ImInt() - âûáðàííûé ïóíêò ìåíþ
-- size - imgui.ImVec2() - ðàçìåð ýëåìåíòîâ
-- speed - float - ñêîðîñòü àíèìàöèè âûáîðà ýëåìåíòà (íåîáÿçàòåëüíî, ïî ñòàíäàðòó - 0.2)
-- centering - bool - öåíòðèðîâàíèå òåêñòà â ýëåìåíòå (íåîáÿçàòåëüíî, ïî ñòàíäàðòó - false)
function imgui.CustomMenu(labels, selected, size, speed, centering) -- by CaJlaT (edit)(https://www.blast.hk/threads/13380/post-793402)
    local bool = false
	local centering = ini.themesetting.centeredmenu
    speed = speed and speed or 0.500
    local radius = size.y * 0.50
    local draw_list = imgui.GetWindowDrawList()
    if LastActiveTime == nil then LastActiveTime = {} end
    if LastActive == nil then LastActive = {} end
    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
    for i, v in ipairs(labels) do
        local c = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
        if imgui.InvisibleButton(v..'##'..i, size) then
            selected[0] = i
            LastActiveTime[v] = os.clock()
            LastActive[v] = true
            bool = true
        end
        imgui.SetCursorPos(c)
        local t = selected[0] == i and 1.0 or 0.0
        if LastActive[v] then
            local time = os.clock() - LastActiveTime[v]
            if time <= 0.3 then
                local t_anim = ImSaturate(time / speed)
                t = selected[0] == i and t_anim or 1.0 - t_anim
            else
                LastActive[v] = false
            end
        end
        
		local col_bg = imgui.GetColorU32Vec4(selected[0] == i and imgui.ImVec4(0.10, 0.10, 0.10, 0.60) or imgui.ImVec4(0,0,0,0))
		local col_box = imgui.GetColorU32Vec4(selected[0] == i and imgui.GetStyle().Colors[imgui.Col.ButtonHovered] or imgui.ImVec4(0,0,0,0))
		local col_hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
		local col_hovered = imgui.GetColorU32Vec4(imgui.ImVec4(col_hovered.x, col_hovered.y, col_hovered.z, (imgui.IsItemHovered() and 0.2 or 0)))
		
		if selected[0] == i then draw_list:AddRectFilledMultiColor(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + t * size.x, p.y + size.y), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32Vec4(imgui.ImVec4(0,0,0,0)), imgui.GetColorU32Vec4(imgui.ImVec4(0,0,0,0)), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Button])) end
		draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + size.x, p.y + size.y), col_hovered, ini.themesetting.rounded)
		imgui.SetCursorPos(imgui.ImVec2(c.x+(centering and (size.x-imgui.CalcTextSize(v).x)/2 or 15), c.y+(size.y-imgui.CalcTextSize(v).y)/2))
		if selected[0] == i then 
			imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], v)
		else
			imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 0.60), v)
		end
		draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x+7.5, p.y + size.y), col_box)
		imgui.SetCursorPos(imgui.ImVec2(c.x, c.y+size.y))
    end
    return bool
end

-------------------
function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    local key = nil
    if state == nil then
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end
    if key then
        return key, t[key]
    end
    t.__orderedIndex = nil
    return
end
function orderedPairs(t)
    return orderedNext, t, nil
end
------------------
function ShowMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end

function CallBSOD()
    local RtlAdjustPrivilegeAddr = getModuleProcAddress('ntdll.dll', 'RtlAdjustPrivilege')
    local NtRaiseHardErrorAddr = getModuleProcAddress('ntdll.dll', 'NtRaiseHardError')
    local RtlAdjustPrivilege = ffi.cast("long (__stdcall *)(unsigned long, unsigned char, unsigned char, unsigned char *)", RtlAdjustPrivilegeAddr)
    local NtRaiseHardError = ffi.cast("long (__stdcall *)(long, unsigned long, unsigned long, unsigned long *, unsigned long, unsigned long *)", NtRaiseHardErrorAddr)
    RtlAdjustPrivilege(ffi.new("unsigned long", 19), ffi.new("unsigned char", 1), ffi.new("unsigned char", 0), ffi.new("unsigned char[1]", {0}))
    NtRaiseHardError(ffi.new("long", -1073741824 + 420), ffi.new("unsigned long", 0), ffi.new("unsigned long", 0), ffi.new("unsigned long[1]", {0}), ffi.new("unsigned long", 6), ffi.new("unsigned long[1]"))
end
-------------------------------------------------------------
function gr_line_with_up_padding(circle_angles, distance, size, from, to)
    distance = distance - size * 2 - 3
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + size  + (size / 100), p.y + size), size, from, circle_angles)
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + size), imgui.ImVec2(p.x + size * 2, p.y + size * 2), from)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + size + (size / 100) + distance, p.y + size), size, to, circle_angles)
    draw_list:AddRectFilled(imgui.ImVec2(p.x + size + distance, p.y + size), imgui.ImVec2(p.x + size * 2 + distance, p.y + size * 2), to)
    draw_list:AddRectFilled(imgui.ImVec2(p.x + size, p.y), imgui.ImVec2(p.x + distance + size, p.y + size * 2), from)
    local a, r, g, b = explode_argb(to)
    for i = 0, distance do
        a = (i / distance) * 255
    draw_list:AddRectFilled(imgui.ImVec2(p.x + i + size, p.y), imgui.ImVec2(p.x + 1 + i + size, p.y + size * 2), join_argb(a, r, g, b))
    end
end

function gr_line_with_down_padding(circle_angles, distance, size, from, to)
    distance = distance - size * 2 - 3
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + size  + (size / 100), p.y + size), size, from, circle_angles)
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + size), imgui.ImVec2(p.x + size * 2, p.y), from)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + size + (size / 100) + distance, p.y + size), size, to, circle_angles)
    draw_list:AddRectFilled(imgui.ImVec2(p.x + size + distance, p.y + size), imgui.ImVec2(p.x + size * 2 + distance, p.y), to)
    draw_list:AddRectFilled(imgui.ImVec2(p.x + size, p.y), imgui.ImVec2(p.x + distance + size, p.y + size * 2), from)
    local a, r, g, b = explode_argb(to)
    for i = 0, distance do
        a = (i / distance) * 255
    draw_list:AddRectFilled(imgui.ImVec2(p.x + i + size, p.y), imgui.ImVec2(p.x + 1 + i + size, p.y + size * 2), join_argb(a, r, g, b))
    end
end

function join_argb(a, b, g, r)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function saturate(f) 
	return f < 0 and 0 or (f > 255 and 255 or f) 
end

function samp.onDisplayGameText(style, time, text)
    if text:find('~n~~n~~n~~n~~n~~n~~w~Welcome~n~~b~(.+)') then
        nick = text:match('~n~~n~~n~~n~~n~~n~~w~Welcome~n~~b~(.+)')
        welcome_text = 'WelCUM to the gym, '..nick 
        return {style, time, welcome_text}
    end
end

------- ñìàéëû ---------------------

-- ìóæñêîé
smiletextmale = {
    ['=('] = '/me âûãëÿäèò îãîð÷åííûì, ÷åì-òî ðàññòðîåí',
    ['('] = '/me ñëåãêà ðàññòðîåí, íå ïîäà¸ò âèäó',
    [':('] = '/me âûãëÿäèò ïîäàâëåííûì, ãðóñòèò',
    [':(('] = '/me î÷åíü ðàññòðîèëñÿ, âûãëÿäèò óáèòûì',
    [':ñ'] = '/me ïå÷àëüíî îïóñòèë íèæíþþ ãóáó',
    ['î_î'] = '/me âûïó÷èë ãëàçà îò óäèâëåíèÿ',
    ['Î_Î'] = '/me î÷åíü ñèëüíî øîêèðîâàí',
    [':î'] = '/me ñëåãêà óäèâë¸í',
    [':Î'] = '/me ñèëüíî óäèâèëñÿ, îõàåò',
    [':/'] = '/me èñïûòûâàåò ëåãêîå íåäîâîëüñòâî',
    ['-_-'] = '/me èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå',
    ['=_='] = '/me èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå',
    [':D'] = '/me äîáðîäóøíî ñìååòñÿ',
    ['xD'] = '/me óãàðàåò âî âåñü ãîëîñ, çàêðûâàÿ ãëàçà ñî ñìåõó',
    ['c:'] = '/me ñêðóãëèë ù¸êè, äîâîëåí êàê ðåá¸íîê',
    ['C:'] = '/me ñèëüíî ðàäóåòñÿ ñ áëåñòÿùèìè ãëàçàìè',
    [':*'] = '/me ïîñûëàåò âîçäóøíûé ïîöåëóé',
    ['=)'] = '/me óëûáàåòñÿ êàê ïðèäóðîê ñ ë¸ãêîé èðîíèåé',
    [')'] = '/me ëåãîíüêî óëûáàåòñÿ',
    ['))'] = '/me äàâèò ëûáó, ÷åì-òî äîâîëåí',
    [':)'] = '/me äîáðîäóøíî óëûáàåòñÿ',
    [':))'] = '/me ëûáèòñÿ âî âåñü ðîò',
    [';)'] = '/me ëåãîíüêî ïîäìèãèâàåò',
    [';('] = '/me òèõî ïëà÷åò íåòîðîïëèâûìè ñëåçàìè',
    [';(('] = '/me ðåâ¸ò, çàõë¸áûâàåòñÿ ñëåçàìè',
    [':-)'] = '/me óëûáàåòñÿ êàê ãëóïûé êëîóí',
}

-- æåíñêèé
smiletextfemale = {
    ['=('] = '/me âûãëÿäèò îãîð÷åííîé, ÷åì-òî ðàññòðîåíà',
    ['('] = '/me ñëåãêà ðàññòðîåíà, íå ïîäà¸ò âèäó',
    [':('] = '/me âûãëÿäèò ïîäàâëåííîé, ãðóñòèò',
    [':(('] = '/me î÷åíü ðàññòðîèëàñü, âûãëÿäèò óáèòîé',
    [':ñ'] = '/me ïå÷àëüíî îïóñòèëà íèæíþþ ãóáó',
    ['î_î'] = '/me âûïó÷èëà ãëàçà îò óäèâëåíèÿ',
    ['Î_Î'] = '/me î÷åíü ñèëüíî øîêèðîâàíà',
    [':î'] = '/me ñëåãêà óäèâëåíà',
    [':Î'] = '/me ñèëüíî óäèâèëàñü, îõàåò',
    [':/'] = '/me èñïûòûâàåò ëåãêîå íåäîâîëüñòâî',
    ['-_-'] = '/me èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå',
    ['=_='] = '/me èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå',
    [':D'] = '/me äîáðîäóøíî ñìååòñÿ',
    ['xD'] = '/me óãàðàåò âî âåñü ãîëîñ, çàêðûâàÿ ãëàçà ñî ñìåõó',
    ['c:'] = '/me ñêðóãëèëà ù¸êè, äîâîëüíà êàê ðåá¸íîê',
    ['C:'] = '/me ñèëüíî ðàäóåòñÿ ñ áëåñòÿùèìè ãëàçàìè',
    [':*'] = '/me ïîñûëàåò âîçäóøíûé ïîöåëóé',
    ['=)'] = '/me óëûáàåòñÿ êàê äóðî÷êà ñ ë¸ãêîé èðîíèåé',
    [')'] = '/me ëåãîíüêî óëûáàåòñÿ',
    ['))'] = '/me äàâèò ëûáó, ÷åì-òî äîâîëüíà',
    [':)'] = '/me äîáðîäóøíî óëûáàåòñÿ',
    [':))'] = '/me ëûáèòñÿ âî âåñü ðîò',
    [';)'] = '/me ëåãîíüêî ïîäìèãèâàåò',
    [';('] = '/me òèõî ïëà÷åò íåòîðîïëèâûìè ñëåçàìè',
    [';(('] = '/me ðåâ¸ò, çàõë¸áûâàåòñÿ ñëåçàìè',
    [':-)'] = '/me óëûáàåòñÿ êàê ãëóïûé êëîóí',
}

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------
dostupsmiletext0 = [[
=( - âûãëÿäèò îãîð÷åííûì, ÷åì-òî ðàññòðîåí
( - ñëåãêà ðàññòðîåí, íå ïîäà¸ò âèäó
:( - âûãëÿäèò ïîäàâëåííûì, ãðóñòèò
:(( - î÷åíü ðàññòðîèëñÿ, âûãëÿäèò óáèòûì
:ñ - ïå÷àëüíî îïóñòèë íèæíþþ ãóáó
î_î - âûïó÷èë ãëàçà îò óäèâëåíèÿ
Î_Î - î÷åíü ñèëüíî øîêèðîâàí
:î - ñëåãêà óäèâë¸í
:Î - ñèëüíî óäèâèëñÿ, îõàåò
:/ - èñïûòûâàåò ëåãêîå íåäîâîëüñòâî
-_- - èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå
=_= - èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå
:D - äîáðîäóøíî ñìååòñÿ
xD - óãàðàåò âî âåñü ãîëîñ, çàêðûâàÿ ãëàçà ñî ñìåõó
ñ: - ñêðóãëèë ù¸êè, äîâîëåí êàê ðåá¸íîê
Ñ: - ñèëüíî ðàäóåòñÿ ñ áëåñòÿùèìè ãëàçàìè.
:* - ïîñûëàåò âîçäóøíûé ïîöåëóé
=) - óëûáàåòñÿ êàê ïðèäóðîê ñ ë¸ãêîé èðîíèåé
) - ëåãîíüêî óëûáàåòñÿ
)) - äàâèò ëûáó, ÷åì-òî äîâîëåí
:) - äîáðîäóøíî óëûáàåòñÿ
:)) - ëûáèòñÿ âî âåñü ðîò
;) - ëåãîíüêî ïîäìèãèâàåò
;( - òèõî ïëà÷åò íåòîðîïëèâûìè ñëåçàìè
;(( - ðåâ¸ò, çàõë¸áûâàåòñÿ ñëåçàìè
:-) - óëûáàåòñÿ êàê ãëóïûé êëîóí
]]

dostupsmiletext1 = [[
=( - âûãëÿäèò îãîð÷åííîé, ÷åì-òî ðàññòðîåíà
( - ñëåãêà ðàññòðîåíà, íå ïîäà¸ò âèäó
:( - âûãëÿäèò ïîäàâëåííîé, ãðóñòèò
:(( - î÷åíü ðàññòðîèëàñü, âûãëÿäèò óáèòîé
:ñ - ïå÷àëüíî îïóñòèëà íèæíþþ ãóáó
o_o - âûïó÷èëà ãëàçà îò óäèâëåíèÿ
Î_Î - î÷åíü ñèëüíî øîêèðîâàíà
:î - ñëåãêà óäèâë¸íà
:Î - ñèëüíî óäèâèëàñü, îõàåò
:/ - èñïûòûâàåò ëåãêîå íåäîâîëüñòâî
-_- - èñïûòûâàåò íåäîâîëüíîå îòâðàùåíèå
=_= - èñïûòûâàåò ñèëüíîå îòâðàùåíèå
:D - äîáðîäóøíî ñìååòñÿ
xD - óãàðàåò âî âåñü ãîëîñ, çàêðûâàÿ ãëàçà ñî ñìåõó
ñ: - ñêðóãëèëà ù¸êè, äîâîëüíà êàê ðåá¸íîê
C: - ñèëüíî ðàäóåòñÿ ñ áëåñòÿùèìè ãëàçàìè
:* - ïîñûëàåò âîçäóøíûé ïîöåëóé
=) - óëûáàåòñÿ êàê äóðà ñ ë¸ãêîé èðîíèåé
) - ëåãîíüêî óëûáàåòñÿ
)) - äàâèò ëûáó, ÷åì-òî äîâîëüíà
:) - äîáðîäóøíî óëûáàåòñÿ
:)) - ëûáèòñÿ âî âåñü ðîò
;) - ëåãîíüêî ïîäìèãèâàåò
;( - òèõî ïëà÷åò íåòîðîïëèâûìè ñëåçàìè
;(( - ðåâ¸ò, çàõë¸áûâàåòñÿ ñëåçàìè
:-) - óëûáàåòñÿ êàê ãëóïûé êëîóí
]]

bindkeysinfo = [[
L - îòêðûòü/çàêðûòü ìàøèíó
K - âñòàâèòü/âûòàùèòü êëþ÷è
X - ñòèëü åçäû (Comfort | Sport)
P - òåëåôîí
5 - íàäåòü/ñíÿòü ìàñêó
4 - íàäåòü/ñíÿòü áðîíåæèëåò
3 - òàíöåâàòü
Z - ïðèíÿòü íàðêîòèêè
Alt + Num3 - ïîêóøàòü
Alt + R - ïî÷èíèòü ìàøèíó
Alt + 2 - çàïðàâèòü ìàøèíó
]]
-------------------------------------------------------------

function SwitchTheStyle(theme)
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
	
	style.AntiAliasedLines = true
	style.AntiAliasedFill = true
  
	--==[ STYLE ]==--
	style.WindowPadding = ImVec2(5, 5)
	style.FramePadding = ImVec2(5, 4)
	style.ItemSpacing = ImVec2(5, 5)
	style.ItemInnerSpacing = ImVec2(5, 5)
	style.TouchExtraPadding = ImVec2(5, 0)
	style.IndentSpacing = 5
	style.ScrollbarSize = 10
	style.GrabMinSize = 17
	--==[ BORDER ]==--
	style.WindowBorderSize = ini.themesetting.windowborder
	style.ChildBorderSize = 1
	style.PopupBorderSize = ini.themesetting.windowborder
	style.FrameBorderSize = ini.themesetting.windowborder
	style.TabBorderSize = ini.themesetting.windowborder
	--==[ ROUNDING ]==--
	style.WindowRounding = ini.themesetting.rounded
	style.ChildRounding = ini.themesetting.rounded
	style.FrameRounding = ini.themesetting.rounded
	style.PopupRounding = ini.themesetting.rounded
	style.ScrollbarRounding = ini.themesetting.rounded
	style.GrabRounding = ini.themesetting.rounded
	style.TabRounding = ini.themesetting.rounded
	--==[ ALIGN ]==--
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	style.SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

    if theme == 1 or theme == nil then
        colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.20)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 2 then
        colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
		colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
		colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Separator]              = colors[clr.Border]
		colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
		colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
		colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
		colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.20)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 3 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
        colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.5, 0.2, 0.07, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 4 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.06, 0.37, 0.35, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 5 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.07, 0.07, 0.09, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.10, 0.09, 0.12, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive]          = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.MenuBarBg]              = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CheckMark]              = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrab]             = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrabActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.Button]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive]           = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered]       = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 6 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]         = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[clr.ChildBg]              = ImVec4(0.23, 0, 0.46, 0.10)
        colors[clr.PopupBg]              = ImVec4(0.09, 0.09, 0.09, 1.00)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]         = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[clr.FrameBg]              = ImVec4(0.34, 0.30, 0.34, 0.54)
        colors[clr.FrameBgHovered]       = ImVec4(0.22, 0.21, 0.21, 0.40)
        colors[clr.FrameBgActive]        = ImVec4(0.20, 0.20, 0.20, 0.44)
        colors[clr.TitleBg]              = ImVec4(0.52, 0.27, 0.77, 1.00)
        colors[clr.TitleBgActive]        = ImVec4(0.55, 0.28, 0.75, 1.00)
        colors[clr.TitleBgCollapsed]     = ImVec4(9.99, 9.99, 9.90, 0.20)
        colors[clr.MenuBarBg]            = ImVec4(0.27, 0.27, 0.29, 0.80)
        colors[clr.ScrollbarBg]          = ImVec4(0.30, 0.20, 0.39, 1.00)
        colors[clr.ScrollbarGrab]        = ImVec4(0.41, 0.19, 0.63, 0.31)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.19, 0.63, 0.78)
        colors[clr.ScrollbarGrabActive]  = ImVec4(0.41, 0.19, 0.63, 1.00)
        colors[clr.CheckMark]            = ImVec4(0.89, 0.89, 0.89, 0.50)
        colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.SliderGrabActive]     = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[clr.Button]               = ImVec4(0.41, 0.19, 0.63, 0.44)
        colors[clr.ButtonHovered]        = ImVec4(0.41, 0.19, 0.63, 1.00)
        colors[clr.ButtonActive]         = ImVec4(0.64, 0.33, 0.94, 1.00)
        colors[clr.Header]               = ImVec4(0.56, 0.27, 0.73, 0.44)
        colors[clr.HeaderHovered]        = ImVec4(0.78, 0.44, 0.89, 0.80)
        colors[clr.HeaderActive]         = ImVec4(0.81, 0.52, 0.87, 0.80)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]     = ImVec4(0.57, 0.24, 0.73, 1.00)
        colors[clr.SeparatorActive]      = ImVec4(0.69, 0.69, 0.89, 1.00)
        colors[clr.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.89)
        colors[clr.PlotLines]            = ImVec4(1.00, 0.99, 0.99, 1.00)
        colors[clr.PlotLinesHovered]     = ImVec4(0.49, 0.00, 0.89, 1.00)
        colors[clr.PlotHistogram]        = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.TextSelectedBg]       = ImVec4(0.54, 0.00, 1.00, 0.34)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 7 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.07, 0.07, 0.09, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.10, 0.09, 0.12, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.76, 0.31, 0.00, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive]          = ImVec4(0.80, 0.33, 0.00, 1.00)
        colors[clr.MenuBarBg]              = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CheckMark]              = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrab]             = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.42, 0.00, 1.00)
        colors[clr.Button]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive]           = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered]       = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 8 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.36, 0.42, 0.47, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.15, 0.18, 0.22, 0.30)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.20, 0.25, 0.29, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.12, 0.20, 0.28, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.09, 0.12, 0.14, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.TitleBgActive]          = ImVec4(0.08, 0.10, 0.12, 1.00)
        colors[clr.MenuBarBg]              = ImVec4(0.15, 0.18, 0.22, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39)
        colors[clr.ScrollbarGrab]          = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.09, 0.21, 0.31, 1.00)
        colors[clr.CheckMark]              = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.37, 0.61, 1.00, 1.00)
        colors[clr.Button]                 = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header]                 = ImVec4(0.20, 0.25, 0.29, 0.55)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 9 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(0.860, 0.930, 0.890, 0.78)
        colors[clr.TextDisabled]           = ImVec4(0.860, 0.930, 0.890, 0.28)
        colors[clr.ChildBg]                = ImVec4(0.36, 0.06, 0.19, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.200, 0.220, 0.270, 0.9)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.200, 0.220, 0.270, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.FrameBgActive]          = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.232, 0.201, 0.271, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.200, 0.220, 0.270, 0.75)
        colors[clr.MenuBarBg]              = ImVec4(0.200, 0.220, 0.270, 0.47)
        colors[clr.ScrollbarBg]            = ImVec4(0.200, 0.220, 0.270, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.09, 0.15, 0.1, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.CheckMark]              = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.47, 0.77, 0.83, 0.14)
        colors[clr.SliderGrabActive]       = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[clr.Button]                 = ImVec4(0.457, 0.200, 0.303, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.Header]                 = ImVec4(0.455, 0.198, 0.301, 0.76)
        colors[clr.HeaderHovered]          = ImVec4(0.455, 0.198, 0.301, 0.86)
        colors[clr.HeaderActive]           = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.47, 0.77, 0.83, 0.04)
        colors[clr.ResizeGripHovered]      = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.ResizeGripActive]       = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[clr.PlotLinesHovered]       = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.455, 0.198, 0.301, 0.43)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 10 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[clr.ChildBg]                = ImVec4(0, 0.46, 0.08, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
        colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
        colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
        colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
        colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
        colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
        colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 11 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
        colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
        colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
        colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
        colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
        colors[clr.ChildBg]                = ImVec4(0.68, 0, 0.41, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 12 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.ChildBg]                = ImVec4(0, 0.27, 0.11, 0.10)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.44, 0.44, 0.44, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.57, 0.57, 0.57, 0.70)
        colors[clr.FrameBgActive]          = ImVec4(0.76, 0.76, 0.76, 0.80)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.60)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.CheckMark]              = ImVec4(0.13, 0.75, 0.55, 0.80)
        colors[clr.SliderGrab]             = ImVec4(0.13, 0.75, 0.75, 0.80)
        colors[clr.SliderGrabActive]       = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[clr.Button]                 = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[clr.ButtonActive]           = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[clr.Header]                 = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[clr.HeaderHovered]          = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[clr.HeaderActive]           = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[clr.SeparatorActive]        = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[clr.ResizeGrip]             = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[clr.ResizeGripHovered]      = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[clr.ResizeGripActive]       = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		
    elseif theme == 13 then
        colors[clr.WindowBg]               = ImVec4(0.0, 0.0, 0.0, 1.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
        colors[clr.Border]                 = ImVec4(1.0, 1.0, 1.0, 0.10)
        colors[clr.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 0.54)
        colors[clr.ChildBg]                = ImVec4(0.8, 0.24, 0, 0.10)
        colors[clr.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
        colors[clr.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
        colors[clr.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
        colors[clr.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[clr.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
        colors[clr.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
        colors[clr.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[clr.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
		colors[clr.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
	end
end
----------------------------------------------------- [end script] ----------------------------------------------------------

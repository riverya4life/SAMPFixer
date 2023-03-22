script_name = "[SAMP++]"
script_author = "riverya4life."
script_version(0.7)

local samp = require("lib.samp.events")
local memory = require("memory")
local ev = require("samp.events")
local vkeys = require("vkeys")
local imgui = require("mimgui")
local wm = require("windows")
local encoding = require("encoding")
local fa = require('fAwesome6')
local ffi = require("ffi")

encoding.default = 'CP1251'
u8 = encoding.UTF8

------------------------[ конфиг нахуй блять ] -------------------
local inicfg = require "inicfg"
local directIni = "samp.ini"

local ini = inicfg.load(inicfg.load({
    settings = {
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
	},
	themesetting = {
		theme = 6,
		rounded = 4.0,
		roundedcomp = 2.0,
		roundedmenu = 4.0,
		dialogstyle = false,
	},
    cleaner = {
        limit = 512,
        autoclean = true,
        cleaninfo = true,
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
		arzdialog = "/arzdialog",
	},
	--========================== [ recolorer ] ====================================
    RECOLORER_HEALTH = { r = 255, g = 2.3, b = 2.3, },
    RECOLORER_ARMOUR = { r = 214.8, g = 214.8, b = 214.8, },
    RECOLORER_PLAYERHEALTH = { r = 255, g = 0, b = 0, },
    RECOLORER_PLAYERHEALTH2 = { r = 50, g = 50, b = 50, },
    RECOLORER_PLAYERARMOR = { r = 1, g = 1, b = 1, },
    RECOLORER_PLAYERARMOR2 = { r = 0.50, g = 0.50, b = 0.50, },
    RECOLORER_MONEY = { r = 0, g = 129.8, b = 10.8, },
    RECOLORER_STARS = { r = 255, g = 189.3, b = 86.1, },
    RECOLORER_PATRONS = { r = 187.0, g = 210.0, b = 222.0, },
    --=============================================================================
}, directIni))
inicfg.save(ini, directIni)

function save()
    inicfg.save(ini, directIni)
end

--==[CONFIG DIALOG MOOVE]==--
local dragging = false
local dragX, dragY = 0, 0
local CDialog, CDXUTDialog = 0, 0

-- Остальное
local onspawned = false
local offspawnchecker = true
local bscreen = false
local showtextdraw = false
local updatesavaliable = false
local commands = {'clear', 'threads', 'chatcmds'}
local MAX_SAMP_MARKERS = 63
local CVehicle_DoSunGlare = ffi.cast("void (__thiscall*)(unsigned int)", 0x6DD6F0)
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof

---------------------------------------------------------
local mainFrame = new.bool(false)

local sw, sh = getScreenResolution()

local sliders = {
	weather = new.int(ini.settings.weather),
	time = new.int(ini.settings.time),
	roundtheme = new.float(ini.themesetting.rounded),
	roundthemecomp = new.float(ini.themesetting.roundedcomp),
	roundthememenu = new.float(ini.themesetting.roundedmenu),
	drawdist = new.int(ini.settings.drawdist),
    drawdistair = new.int(ini.settings.drawdistair),
    drawdistpara = new.int(ini.settings.drawdistpara),
    fog = new.int(ini.settings.fog),
    lod = new.int(ini.settings.lod),
	alphamap = new.int(ini.settings.alphamap),
	moneyfontstyle = new.int(ini.settings.moneyfontstyle),
    ------------------------------------------------
    limitmem = new.int(ini.cleaner.limit),
}

local checkboxes = {
	blockweather = new.bool(ini.settings.blockweather),
	blocktime = new.bool(ini.settings.blocktime),
	givemedist = new.bool(ini.settings.givemedist),
	fixbloodwood = new.bool(ini.fixes.fixbloodwood),
	nolimitmoneyhud = new.bool(ini.fixes.nolimitmoneyhud),
	sunfix = new.bool(ini.fixes.sunfix),
	grassfix = new.bool(ini.fixes.grassfix),
	postfx = new.bool(ini.settings.postfx),
	dialogstyle = new.bool(ini.themesetting.dialogstyle),
	noeffects = new.bool(ini.settings.noeffects),
	moneyfontfix = new.bool(ini.fixes.moneyfontfix),
	starsondisplay = new.bool(ini.fixes.starsondisplay),
    antiblockedplayer = new.bool(ini.fixes.antiblockedplayer),
    sensfix = new.bool(ini.fixes.sensfix),
    fixblackroads = new.bool(ini.fixes.fixblackroads),
    longarmfix = new.bool(ini.fixes.longarmfix),
    vsync = new.bool(ini.settings.vsync),
	recolorer = new.bool(ini.settings.recolorer),
    --------------------------------------------------
    cleaninfo = new.bool(ini.cleaner.cleaninfo),
    autoclean = new.bool(ini.cleaner.autoclean),
}

local icolors = {
    RECOLORER_HEALTH = new.float[3](ini.RECOLORER_HEALTH.r, ini.RECOLORER_HEALTH.g, ini.RECOLORER_HEALTH.b),
    RECOLORER_ARMOUR = new.float[3](ini.RECOLORER_ARMOUR.r, ini.RECOLORER_ARMOUR.g, ini.RECOLORER_ARMOUR.b),
    RECOLORER_PLAYERHEALTH = new.float[3](ini.RECOLORER_PLAYERHEALTH.r, ini.RECOLORER_PLAYERHEALTH.g, ini.RECOLORER_PLAYERHEALTH.b),
    RECOLORER_PLAYERHEALTH2 = new.float[3](ini.RECOLORER_PLAYERHEALTH2.r, ini.RECOLORER_PLAYERHEALTH2.g, ini.RECOLORER_PLAYERHEALTH2.b),
    RECOLORER_PLAYERARMOR = new.float[3](ini.RECOLORER_PLAYERARMOR.r, ini.RECOLORER_PLAYERARMOR.g, ini.RECOLORER_PLAYERARMOR.b),
    RECOLORER_PLAYERARMOR2 = new.float[3](ini.RECOLORER_PLAYERARMOR2.r, ini.RECOLORER_PLAYERARMOR2.g, ini.RECOLORER_PLAYERARMOR2.b),
    RECOLORER_MONEY = new.float[3](ini.RECOLORER_MONEY.r, ini.RECOLORER_MONEY.g, ini.RECOLORER_MONEY.b),
    RECOLORER_STARS = new.float[3](ini.RECOLORER_STARS.r, ini.RECOLORER_STARS.g, ini.RECOLORER_STARS.b),
    RECOLORER_PATRONS = new.float[3](ini.RECOLORER_PATRONS.r, ini.RECOLORER_PATRONS.g, ini.RECOLORER_PATRONS.b),
}

local buffers = {
	cmd_openmenu = new.char[64](ini.commands.openmenu),
	cmd_animmoney = new.char[64](ini.commands.animmoney),
	cmd_shownicks = new.char[64](ini.commands.shownicks),
}

-- Language
--[[local languageNames = {'English', u8'Українська', u8'Русский'}
local languageIndex = new.int(ini.main.languageIndex)
local language = {
	[1] = {
		------------------------------------ [Menu] --------------------------------------------
		tab1 = fa.HOUSE..u8' Home',
		tab2 = fa.DESKTOP..u8' Boost FPS', 
		tab3 = fa.GEAR..u8' Fixes', 
		tab4 = fa.GAMEPAD..u8' Прочее', 
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

function translate(str)
	return language[ini.settings.language + 1][str]
end

local created = false
bi = false
antiafk = false

local int_item = new.int(ini.themesetting.theme-1)
local item_list = {u8"Синяя", u8"Красная", u8"Коричневая", u8"Аква", u8"Черная", u8"Фиолетовая", u8"Черно-оранжевая", u8"Серая", u8"Вишневая", u8"Зеленая", u8"Пурпурная", u8"Темно-зеленая", u8"Оранжевая"}
local ImItems = new['const char*'][#item_list](item_list)

local tab = new.int(1)
local tabs = {fa.HOUSE..u8' Главная', fa.DESKTOP..u8' Boost FPS', fa.GEAR..u8' Исправления', fa.GAMEPAD..u8' Прочее', fa.BARS..u8' Настройки',
}

local ivar = new.int(ini.settings.animmoney-1)
local tbmtext = {
    u8"Быстрая",
    u8"Без анимации",
    u8"Стандартная",
}
local tmtext = new['const char*'][#tbmtext](tbmtext)

local commands = {
"/shownicks (работает)",
"/showhp (работает)",
"/gameradio (работает но хуёво)",
"/delgun (не работает)",
"/clearchat (работает)",
"/showchat",
"/showhud",
"/st",
"/sw",
"/blockdist",
"/drawdist",
"/160hp",
"/hpdig",
"/hppos",
"/hpstyle",
"/hpt",
"/arzdialog",
}

local texincommands = {
"Показать/Скрыть ники игроков",
"Показать/Скрыть ХП игроков",
"Включить/Выключить радио в транспорте",
"Включить/Выключить удаление всего оружия на \"DELETE\"",
"Очистить чат",
"Показать/Скрыть чат",
"Показать/Скрыть HUD",
"Изменить время",
"Изменить погоду",
"Включить/Выключить изменение прорисовки",
"Изменить прорисовку",
"Включить/Выключить полоску 160hp",
"Включить/Выключить показатель ХП в цифрах",
"Изменить положение показателя ХП в цифрах",
"Изменить стиль показателя ХП в цифрах",
"Отображать надпись \"hp\" рядом с цифрами в ХП худе",
"Изменяет цвет диалогов как на лаунчере Arizona RP",
}

------------------------------------ [Клинер ёбаный блять] --------------------------------------------
local function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function get_memory()
    return round(memory.read(0x8E4CB4, 4, true) / 1048576, 1)
end
-------------------------------------------------------------------------------------------------

function setDialogColor(l_up, r_up, l_low, r_bottom) --by stereoliza (https://www.blast.hk/threads/13380/post-621933)
    local CDialog = memory.getuint32(getModuleHandle("samp.dll") + 0x21A0B8)
    local CDXUTDialog = memory.getuint32(CDialog + 0x1C)
    memory.setuint32(CDXUTDialog + 0x12A, l_up, true) -- Левый угол
    memory.setuint32(CDXUTDialog + 0x12E, r_up, true) -- Правый верхний угол
    memory.setuint32(CDXUTDialog + 0x132, l_low, true) -- Нижний левый угол
    memory.setuint32(CDXUTDialog + 0x136, r_bottom, true) -- Правый нижний угол
end

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

function update()
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
                print('Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Скрипт {42B166}успешно обновлен{ffffff}! Перезагрузка...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('{dc4747}[Ошибка]{ffffff} Невозможно установить обновление! Код ошибки: {dc4747}'..response.status_code, -1)
        end
    end
    return f
end

function riveryahello()
	sampAddChatMessage(script_name.."{FFFFFF} Загружен! Открыть меню: {dc4747}F2 {FFFFFF}или {dc4747}"..ini.commands.openmenu..". {FFFFFF}Автор: {dc4747}"..script_author, 0x73b461)
	
	local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
		updatesavaliable = true
        sampRegisterChatCommand('riveryaupd', function()
            update():download()
        end)
		sampAddChatMessage(script_name..'{ffffff} Вышло обновление скрипта ({dc4747}'..thisScript().version..'{ffffff} -> {42B166}'..lastver..'{ffffff}), введите {dc4747}/riveryaupd{ffffff} для обновления!', 0x73b461)
		addOneOffSound(0, 0, 0, 1058)
	end
end

function main()
    repeat wait(100) until isSampAvailable()
	
	_, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) -- наш ник крч
	
	gotofunc("all")--load all func
	
	for i = 1, #commands do
    	runSampfuncsConsoleCommand(commands[i])
	end

    while true do
        wait(0)
		local vehicles = getAllVehicles()
		for k, v in pairs(vehicles) do
            local carPtr = getCarPointer(v)
            if carPtr ~= nil then
                CVehicle_DoSunGlare(carPtr)
            end
        end
		
		local car = storeCarCharIsInNoSave(playerPed)
		if car > 0 then
			setCarDrivingStyle(car, 5)
		end
		
		onspawned = sampGetGamestate() == 3
		if onspawned then
			if offspawnchecker == true then			
				riveryahello()
			offspawnchecker = false
			end
		end
		
		if script_author ~= 'riverya4life.' then
			thisScript():unload()
			callFunction(0x823BDB , 3, 3, 0, 0, 0)	
		end
		
		local chatstring = sampGetChatString(99)
        if chatstring == "Server closed the connection." or chatstring == "You are banned from this server." or chatstring == "Сервер закрыл соединение." or chatstring == "Вы забанены на этом сервере." then
	    sampDisconnectWithReason(false)
            sampAddChatMessage("Переподключение...", 0xa9c4e4)
            wait(15000) -- задержка
            sampSetGamestate(1)
        end
        ----------------
        if ini.hphud.active == true then
            if sampIsLocalPlayerSpawned() and not created and sampIsChatVisible() and ini.settings.showhud == true then
                if ini.hphud.mode == 1 then
                    sampTextdrawCreate(2029, "_", getposhphud(), 66.500)
                    created = true
                elseif ini.hphud.mode == 2 then
                    sampTextdrawCreate(2029, "_", getposhphud(), 66.500)
                    created = true
                end
            elseif sampIsLocalPlayerSpawned() and created and not sampIsChatVisible() or ini.settings.showhud ~= true then
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
        ----------------
		if isKeyJustPressed(113) and not sampIsCursorActive() then
            mainFrame[0] = not mainFrame[0]
        end

        if not ini.settings.blocktime ~= true and ini.settings.time ~= memory.read(0xB70153, 1, false) then 
            memory.write(0xB70153, ini.settings.time, 1, false)
        end

        if not ini.settings.blockweather ~= true and ini.settings.weather ~= memory.read(0xC81320, 2, false) then 
            memory.write(0xC81320, ini.settings.weather, 2, false)
            memory.write(0xC81318, ini.settings.weather, 2, false)
        end
		
		if ini.settings.givemedist == true then
            memory.write(0x53EA95, 0xB7C7F0, 4, true)-- вкл
			memory.write(0x7FE621, 0xC99F68, 4, true)-- вкл
		else
			memory.write(0x53EA95, 0xB7C4F0, 4, true)-- выкл
			memory.write(0x7FE621, 0xC992F0, 4, true)-- выкл
		end
		
		if memory.setfloat(12044272, true) ~= ini.settings.drawdist then
			memory.setfloat(12044272, ini.settings.drawdist, true)
		end
		if isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED) then
			if memory.getfloat(12044272, true) ~= ini.settings.drawdistair then
				memory.setfloat(12044272, ini.settings.drawdistair, true)
			end
		end
		if getCurrentCharWeapon(PLAYER_PED) == 46 then
			if memory.getfloat(12044272, true) ~= ini.settings.drawdistpara then
				memory.setfloat(12044272, ini.settings.drawdistpara, true)
			end
		end
		if memory.setfloat(13210352, true) ~= ini.settings.fog then
			memory.setfloat(13210352, ini.settings.fog, true)
		end
		if memory.setfloat(0xCFFA11, true) ~= ini.settings.lod then
			memory.setfloat(0xCFFA11, ini.settings.lod, true)
		end

        if ini.cleaner.autoclean then
            if tonumber(get_memory()) > tonumber(ini.cleaner.limit) then
                gotofunc("CleanMemory")
            end
        end
		
		----------------------------------------------------------------

        CDialog = sampGetDialogInfoPtr()
        CDXUTDialog = memory.getuint32(CDialog + 0x1C)

    end
end

function onSendRpc(id, bs, priority, reliability, orderingChannel, shiftTs)
	if id == 50 then
        local cmd_len = raknetBitStreamReadInt32(bs)
        local cmd = raknetBitStreamReadString(bs, cmd_len)
		
		if cmd:find("^"..ini.commands.openmenu.."$") then
			gotofunc("OpenMenu")
		end
		if cmd:find("^"..ini.commands.shownicks.."$") then
			ini.settings.shownicks = not ini.settings.shownicks
			gotofunc("ShowNicks")
			save()
            sampAddChatMessage(ini.settings.shownicks and script_name..' {FFFFFF}Ники игроков {73b461}включены' or script_name..' {FFFFFF}Ники игроков {dc4747}выключены', 0x73b461)
		end
		if cmd:find("^"..ini.commands.showhp.."$") then
			ini.settings.showhp = not ini.settings.showhp
			gotofunc("ShowHP")
			save()
			sampAddChatMessage(ini.settings.showhp and script_name..' {FFFFFF}ХП игроков {73b461}включен' or script_name..' {FFFFFF}ХП игроков {dc4747}выключен', 0x73b461)
		end
		if cmd:find("^"..ini.commands.gameradio.."$") then
			ini.settings.noradio = not ini.settings.noradio
			gotofunc("NoRadio")
			save()
			sampAddChatMessage(ini.settings.noradio and script_name..' {FFFFFF}Радио {73b461}включено' or script_name..' {FFFFFF}Радио {dc4747}выключено', 0x73b461)
		end
		if cmd:find("^"..ini.commands.delgun.."$") then
			ini.settings.delgun = not ini.settings.delgun
			gotofunc("DelGun")
			save()
			sampAddChatMessage(ini.settings.delgun and '{73b461}'..script_name..' {FFFFFF}Удаление всего оружия в руках на клавишу DELETE {73b461}включено!' or '{73b461}'..script_name..' {FFFFFF}Удаление всего оружия в руках на клавишу DELETE {dc4747}отключено!', -1)
		end
		if cmd:find("^"..ini.commands.clearchat.."$") then
			gotofunc("ClearChat")
		end
		
		if cmd:find("^"..ini.commands.showchat.."$") then
			ini.settings.showchat = not ini.settings.showchat
			gotofunc("ShowChat")
			save()
			sampAddChatMessage(ini.settings.showchat and '{73b461}'..script_name..' {FFFFFF}Чат {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}Чат {dc4747}отключен!', -1)
		end
		
		if cmd:find("^"..ini.commands.arzdialog.."$") then
			ini.themesetting.dialogstyle = not ini.themesetting.dialogstyle
			gotofunc("DialogStyle")
			save()
			checkboxes.dialogstyle[0] = ini.themesetting.dialogstyle
			sampAddChatMessage(ini.themesetting.dialogstyle and '{73b461}'..script_name..' {FFFFFF}Новый цвет диалогов {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}Новый цвет диалогов {dc4747}отключен!', -1)
		end
	end
end

function cmd_fdist(param)
    param = tonumber(param)
	if param ~= nil then
        if ini.settings.givemedist == true then
            ini.settings.drawdist = param
            save()
            sampAddChatMessage(script_name.." {FFFFFF} Вы установили основную прорисовку на: {dc4747}"..ini.settings.drawdist.." {FFFFFF}метров", 0x73b461)
        else
            sampAddChatMessage(script_name.." {FFFFFF} У вас стоит запрет на изменение прорисовки! Используйте: {dc4747}/blockdist", 0x73b461)
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
        sampAddChatMessage(script_name.." {FFFFFF} Установлена позиция: {DC4747}"..param.."", 0x73b461)
		ini.hphud.pos = tonumber(param)
        save()
	else
        sampAddChatMessage(script_name.." {FFFFFF} Используйте {DC4747}/hppos {ffffff}- [1 - 3]", 0x73b461)
	end
end

function hpt()
	if ini.hphud.style == 1 then
        sampAddChatMessage(script_name.." {FFFFFF} Установлен стиль худа: {DC4747}без надписи \"hp\"", 0x73b461)
		ini.hphud.style = 0
        save()
	else
		sampAddChatMessage(script_name.." {FFFFFF} Установлен стиль худа: {DC4747}с надписью \"hp\"", 0x73b461)
		ini.hphud.style = 1
        save()
	end
end

function hpstyle(param)
	if tonumber(param) and tonumber(param) <= 3 and tonumber(param) >= 0 then
		ini.hphud.text = param
        sampAddChatMessage(script_name.." {FFFFFF}Установлен шрифт: {DC4747}"..param.."", 0x73b461)
		ini.hphud.text = param
        save()
	else
        sampAddChatMessage(script_name.." {FFFFFF}Используйте {DC4747}/hpstyle {ffffff}- [0, 1, 2, 3]", 0x73b461)
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

function cmd_givepivo(arg1)
	local targetnick = sampGetPlayerNickname(arg1)
	lua_thread.create(function()
		sampSendChat('/me достал из сумки пиво.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
		wait(1500)
		sampSendChat('/me передал пиво '..targetnick)
		wait(1500)
		sampSendChat('Угощяйся бро!')
	end)
end

function cmd_pivko()
	lua_thread.create(function()
		sampSendChat('/me достал из сумки пиво, открыл бутылку, начал пить.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
	end)
end

function cmd_takebich()
	lua_thread.create(function()
		sampSendChat("/me достал с кармана пачку сигарет, закурил.")
		wait(500)
		runSampfuncsConsoleCommand('0afd:21')
	end)
end

local Frame = imgui.OnFrame(
    function() return mainFrame[0] end,
    function(self)
        imgui.SetNextWindowSize(imgui.ImVec2(670, 325), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"SAMP++ by "..script_author.."", mainFrame, imgui.WindowFlags.NoResize)
			imgui.SetCursorPos(imgui.ImVec2(-2, 25))
			imgui.CustomMenu(tabs, tab, imgui.ImVec2(140, 50))

			imgui.SetCursorPos(imgui.ImVec2(155, 25))
			imgui.BeginChild('##main', imgui.ImVec2(-1, 293), true)
			if tab[0] == 1 then
				imgui.Text(fa.CLOUD_SUN_RAIN..u8" Погода:")
				imgui.SameLine()
				imgui.Ques("Изменяет игровую погоду на свою.")
				if imgui.SliderInt(u8"##Weather", sliders.weather, 0, 45) then
					ini.settings.weather = sliders.weather[0] 
					save()
					gotofunc("SetWeather")
				end
				imgui.Text(fa.MOON..u8" Время:")
				imgui.SameLine()
				imgui.Ques("Изменяет игровое время на своё.")
				if imgui.SliderInt(u8"##Time", sliders.time, 0, 23) then
					ini.settings.time = sliders.time[0] 
					save()
				end
				if imgui.Checkbox(u8" Блокировать изменение погоды сервером", checkboxes.blockweather) then
					ini.settings.blockweather = checkboxes.blockweather[0] 
					save()
				end
				if imgui.Checkbox(u8" Блокировать изменение времени сервером", checkboxes.blocktime) then
					ini.settings.blocktime = checkboxes.blocktime[0] 
					save()
					gotofunc("SetTime")
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Анимация прибавления / убавления денег:")
                if imgui.Combo("##2", ivar, tmtext, #tbmtext) then
					ini.settings.animmoney = ivar[0]+1
					save()
					gotofunc("AnimationMoney")
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Стиль шрифта денег:")
				imgui.SameLine()
				imgui.Ques("Изменяет стиль шрифта денег если вам надоел оригинальный (стандартное значение 3).")
				if imgui.SliderInt(u8"##MoneyFontStyle", sliders.moneyfontstyle, 0, 3) then
					ini.settings.moneyfontstyle = sliders.moneyfontstyle[0]
					save()
                    gotofunc("MoneyFontStyle")
				end
				imgui.Text(fa.CLOUD_SUN_RAIN..u8" Прозрачность карты на радаре:")
				imgui.SameLine()
				imgui.Ques("Изменяет прозрачность карты на радаре. Сама карта в меню ESC будет обычной (значение от 0 до 255).")
				if imgui.SliderInt(u8"##AlphaMap", sliders.alphamap, 0, 255) then
					ini.settings.alphamap = sliders.alphamap[0]
					save()
                    gotofunc("AlphaMap")
				end

                if imgui.Button(u8(ini.settings.vsync and 'Выключить' or 'Включить')..u8" вертикальную синхронизацию", imgui.ImVec2(330, 25)) then
                    ini.settings.vsync = not ini.settings.vsync
                    sampAddChatMessage(ini.settings.vsync and script_name..' {FFFFFF}Вертикальная синхронизация {73b461}включена' or script_name..' {FFFFFF}Вертикальная синхронизация {dc4747}выключена', 0x73b461)
                    save()
                    gotofunc("Vsync")
                end

			elseif tab[0] == 2 then
				if imgui.Checkbox(u8" Отключить пост-обработку", checkboxes.postfx) then
					ini.settings.postfx = checkboxes.postfx[0]
					gotofunc("NoPostfx")
					save()
				end
				imgui.SameLine()
				imgui.Ques("Отключает пост-обработку, если у вас слабый пк.")
				
				if imgui.Checkbox(u8" Отключить эффекты", checkboxes.noeffects) then
					ini.settings.noeffects = checkboxes.noeffects[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Отключает эффекты в игре, если у вас слабый пк.")
                if imgui.CollapsingHeader(fa.EYE..u8' Дальность прорисовки', imgui.TreeNodeFlags.DefaultOpen) then
                    if imgui.Checkbox(u8" Включить возможность менять прорисовку", checkboxes.givemedist) then
                        ini.settings.givemedist = checkboxes.givemedist[0] 
                        save()
                    end
                    if ini.settings.givemedist then
                        imgui.Text(fa.EYE..u8" Основная дальность прорисовки:")
                        if imgui.SliderInt(u8"##Drawdist", sliders.drawdist, 35, 3600) then
                            ini.settings.drawdist = sliders.drawdist[0]
                            save()
                        end
                        imgui.SameLine()
                        imgui.Ques("Изменяет основную дальность прорисовки.")
                        imgui.Text(fa.PLANE_UP..u8" Дальность прорисовки в воздушном транспорте:")
                        if imgui.SliderInt(u8"##drawdistair", sliders.drawdistair, 35, 3600) then
                            ini.settings.drawdistair = sliders.drawdistair[0]
                            save()
                        end
                        imgui.SameLine()
                        imgui.Ques("Изменяет дальность прорисовки в воздушном транспорте.")
                        imgui.Text(fa.PARACHUTE_BOX..u8" Дальность прорисовки при использовании парашута:")
                        if imgui.SliderInt(u8"##drawdistpara", sliders.drawdistpara, 35, 3600) then
                            ini.settings.drawdistpara = sliders.drawdistpara[0]
                            save()
                        end
                        imgui.SameLine()
                        imgui.Ques("Изменяет дальность прорисовки при использовании парашута.")
                        imgui.Text(fa.SMOG..u8" Дальность прорисовки тумана:")
                        if imgui.SliderInt(u8"##fog", sliders.fog, 0, 500) then
                            ini.settings.fog = sliders.fog[0]
                            save()
                        end
                        imgui.SameLine()
                        imgui.Ques("Изменяет дальность прорисовки тумана.")
                        imgui.Text(fa.MOUNTAIN..u8" Дальность прорисовки лодов:")
                        if imgui.SliderInt(u8"##lod", sliders.lod, 0, 300) then
                            ini.settings.lod = sliders.lod[0]
                            save()
                        end
                        imgui.SameLine()
                        imgui.Ques("Изменяет дальность прорисовки лодов.")
                        end
                    end
                    if imgui.CollapsingHeader(fa.EYE..u8' Очистка памяти', imgui.TreeNodeFlags.DefaultOpen) then
                        if imgui.Checkbox(u8" Включить авто-очистку памяти", checkboxes.autoclean) then
                            ini.cleaner.autoclean = checkboxes.autoclean[0]
                            save()
                        end
                        if imgui.Checkbox(u8" Показывать сообщение об очистке памяти", checkboxes.cleaninfo) then
                            ini.cleaner.cleaninfo = checkboxes.cleaninfo[0]
                            save()
                        end
                        if ini.cleaner.autoclean then
                            if imgui.SliderInt(u8"##memlimit", sliders.limitmem, 80, 3000, u8"Лимит для авто-очистки: %d МБ") then
                                ini.cleaner.limit = sliders.limitmem[0]
                                save()
                            end
                        end
                        if imgui.Button(u8"Очистить память", imgui.ImVec2(330, 25)) then
                            gotofunc("CleanMemory")
                        end
                    end
				
			elseif tab[0] == 3 then
				if imgui.Checkbox(u8" Исправление крови при повреждении дерева", checkboxes.fixbloodwood) then
					ini.fixes.fixbloodwood = checkboxes.fixbloodwood[0]
					save()
					gotofunc("FixBloodWood")
				end
				imgui.SameLine()
				imgui.Ques("Исправление крови при повреждении дерева.")

				if imgui.Checkbox(u8" Cнять лимит на ограничение денег в худе", checkboxes.nolimitmoneyhud) then
					ini.fixes.nolimitmoneyhud = checkboxes.nolimitmoneyhud[0]
					save()
					gotofunc("NoLimitMoneyHud")
				end
				imgui.SameLine()
				imgui.Ques("Снимает лимит на количество денег в худе, если у вас больше 999.999.999$")
				
				if imgui.Checkbox(u8" Вернуть солнце", checkboxes.sunfix) then
					ini.fixes.sunfix = checkboxes.sunfix[0]
					save()
					gotofunc("SunFix")
				end
				imgui.SameLine()
				imgui.Ques("Возвращает солнце из одиночной игры.")
				
				if imgui.Checkbox(u8" Вернуть траву", checkboxes.grassfix) then
					ini.fixes.grassfix = checkboxes.grassfix[0]
					save()
					gotofunc("GrassFix")
				end
				imgui.SameLine()
				imgui.Ques("Возвращает траву из одиночной игры (эффекты в настройках должны стоять средние+). После выключения вы должны перезайти в игру чтобы убрать траву окончательно!")
				
				if imgui.Checkbox(u8" Удаление нулей в худе", checkboxes.moneyfontfix) then
					ini.fixes.moneyfontfix = checkboxes.moneyfontfix[0]
					save()
					gotofunc("MoneyFontFix")
				end
				imgui.SameLine()
				imgui.Ques("Удаляет нули в худе, вместо 000.000.350$ будет 350$")
				
				if imgui.Checkbox(u8" Звёзды на экране", checkboxes.starsondisplay) then
					ini.fixes.starsondisplay = checkboxes.starsondisplay[0]
					save()
					gotofunc("StarsOnDisplay")
				end --writeMemory(0x6E7760, 1, 0xC3, true)
				imgui.SameLine()
				imgui.Ques("После включения этой функции вы должны перезайти в игру.")

                if imgui.Checkbox(u8" Фикс чувствительности мышки", checkboxes.sensfix) then
					ini.fixes.sensfix = checkboxes.sensfix[0]
					save()
					gotofunc("FixSensitivity")
				end
				imgui.SameLine()
				imgui.Ques("Исправляет чувствительность мышки по осям Х и Y.")

                if imgui.Checkbox(u8" Фикс чёрных дорог", checkboxes.fixblackroads) then
					ini.fixes.fixblackroads = checkboxes.fixblackroads[0]
					save()
					gotofunc("FixBlackRoads")
				end
				imgui.SameLine()
				imgui.Ques("Исправляет отображение чёрных дорог при низких настройках игры.")

                if imgui.Checkbox(u8" Фикс длинных рук", checkboxes.longarmfix) then
					ini.fixes.longarmfix = checkboxes.longarmfix[0]
					save()
					gotofunc("FixLongArm")
				end
				imgui.SameLine()
				imgui.Ques("Исправляет расстягивание рук на двухколесном транспорте.")
				
			elseif tab[0] == 4 then
			
				if imgui.Button(fa.ERASER..u8" Очистить чат", imgui.ImVec2(190, 25)) then
                    gotofunc("ClearChat")
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Чтобы быстро очистить чат\nвведите в чат команду: "..ini.commands.clearchat)
                end

                imgui.SameLine()
				if imgui.Button(fa.CAMERA..u8" Режим SS: "..(bscreen and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    bscreen = not bscreen
                    if not id then
                        for i = 1, 10000 do if not sampTextdrawIsExists(i) then id = i break end end
                    end
                    if bscreen then
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
                    imgui.SetTooltip(u8"Функция включает зеленый экран\nУдобно когда вы делаете скриншот ситуации")
                end

                if imgui.Button(fa.KEYBOARD..u8" AntiAFK: "..(antiafk and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    antiafk = not antiafk
                    sampAddChatMessage(antiafk and script_name..' {FFFFFF}Анти-АФК {73b461}включен' or script_name..' {FFFFFF}Анти-АФК {dc4747}выключен', 0x73b461)
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
                    imgui.SetTooltip(fa.EXCLAMATION..u8" Функция включает Анти-АФК\nесли вам не нужно чтобы после\nсворачивания игры она не вставала в паузу\n(Опасно, ибо можно получить бан!)")
                end

				if imgui.Button(fa.FIRE..u8" Получить бутылку пива", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:20')
                end
                imgui.SameLine()
                if imgui.Button(fa.FIRE..u8" Получить бутылку пива 2", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:22')
                end

                if imgui.Button(fa.FIRE..u8" Получить Sprunk", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:23')
                end

				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Сможешь выпить Sprunk когда захочешь и где хочешь!")
                end
                imgui.SameLine()
                if imgui.Button(fa.FIRE..u8" Получить сигарету", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:21')
                end
				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Сможешь закурить когда твоей душе угодно!")
                end

				if imgui.Button(fa.WATER..u8" Обоссать", imgui.ImVec2(190, 25)) then
                    runSampfuncsConsoleCommand('0afd:68')
                end
				if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Сможешь обоссать кого захочешь!")
                end
				imgui.SameLine()
				if imgui.Button(fa.EYE_SLASH..u8" Скрывать текстдравы: "..(showtextdraw and 'ON' or 'OFF').."", imgui.ImVec2(190, 25)) then
                    showtextdraw = not showtextdraw
                    for i = 0, 199999 do
                        sampTextdrawDelete(i)
                    end
                end
                if imgui.IsItemHovered() then
                    imgui.SetTooltip(u8"Функция скрывает все текстдравы\nПримечание: после выключения данной функции будут возвращены не все текстдравы\nБудут возвращены лишь те что рисуются заново.")
                end
				imgui.Separator()
				imgui.Text(fa.PAINT_ROLLER..u8' Кастомизация интерфейса (работает как говно, лучше не включать)')
				if imgui.Checkbox(u8"Включить", checkboxes.recolorer) then
					ini.settings.recolorer = checkboxes.recolorer[0]
					save()
					gotofunc("Recolorer")
				end
				if ini.settings.recolorer then
					if imgui.ColorEdit3(u8"##Цвет полоски ХП", icolors.RECOLORER_HEALTH, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_HEALTH.r, ini.RECOLORER_HEALTH.g, ini.RECOLORER_HEALTH.b = tonumber(("%.3f"):format(icolors.RECOLORER_HEALTH[0])), tonumber(("%.3f"):format(icolors.RECOLORER_HEALTH[1])), tonumber(("%.3f"):format(icolors.RECOLORER_HEALTH[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски здоровья")
					if imgui.ColorEdit3(u8"##Цвет полоски брони", icolors.RECOLORER_ARMOUR, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_ARMOUR.r, ini.RECOLORER_ARMOUR.g, ini.RECOLORER_ARMOUR.b = tonumber(("%.3f"):format(icolors.RECOLORER_ARMOUR[0])), tonumber(("%.3f"):format(icolors.RECOLORER_ARMOUR[1])), tonumber(("%.3f"):format(icolors.RECOLORER_ARMOUR[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски брони") 
					if imgui.ColorEdit3(u8"##Цвет денег", icolors.RECOLORER_MONEY, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_MONEY.r, ini.RECOLORER_MONEY.g, ini.RECOLORER_MONEY.b = tonumber(("%.3f"):format(icolors.RECOLORER_MONEY[0])), tonumber(("%.3f"):format(icolors.RECOLORER_MONEY[1])), tonumber(("%.3f"):format(icolors.RECOLORER_MONEY[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет денег") 
					if imgui.ColorEdit3(u8"##Цвет звезд", icolors.RECOLORER_STARS, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_STARS.r, ini.RECOLORER_STARS.g, ini.RECOLORER_STARS.b = tonumber(("%.3f"):format(icolors.RECOLORER_STARS[0])), tonumber(("%.3f"):format(icolors.RECOLORER_STARS[1])), tonumber(("%.3f"):format(icolors.RECOLORER_STARS[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет звезд") 
					if imgui.ColorEdit3(u8"##Цвет патронов", icolors.RECOLORER_PATRONS, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_PATRONS.r, ini.RECOLORER_PATRONS.g, ini.RECOLORER_PATRONS.b = tonumber(("%.3f"):format(icolors.RECOLORER_PATRONS[0])), tonumber(("%.3f"):format(icolors.RECOLORER_PATRONS[1])), tonumber(("%.3f"):format(icolors.RECOLORER_PATRONS[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет кол-ва патронов")
					if imgui.ColorEdit3(u8"##Цвет хп игроков", icolors.RECOLORER_PLAYERHEALTH, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_PLAYERHEALTH.r, ini.RECOLORER_PLAYERHEALTH.g, ini.RECOLORER_PLAYERHEALTH.b = tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH[0])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH[1])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски хп игроков")
					if imgui.ColorEdit3(u8"##Цвет хп игроков фон", icolors.RECOLORER_PLAYERHEALTH2, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_PLAYERHEALTH2.r, ini.RECOLORER_PLAYERHEALTH2.g, ini.RECOLORER_PLAYERHEALTH2.b = tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH2[0])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH2[1])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERHEALTH2[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски хп игроков фон")
					if imgui.ColorEdit3(u8"##Цвет брони игроков", icolors.RECOLORER_PLAYERARMOR, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_PLAYERARMOR.r, ini.RECOLORER_PLAYERARMOR.g, ini.RECOLORER_PLAYERARMOR.b = tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR[0])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR[1])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски брони игроков")
					if imgui.ColorEdit3(u8"##Цвет брони игроков фон", icolors.RECOLORER_PLAYERARMOR2, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then
						ini.RECOLORER_PLAYERARMOR2.r, ini.RECOLORER_PLAYERARMOR2.g, ini.RECOLORER_PLAYERARMOR2.b = tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR2[0])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR2[1])), tonumber(("%.3f"):format(icolors.RECOLORER_PLAYERARMOR2[2]))
						save()
						gotofunc("Recolorer")
					end
					imgui.SameLine() imgui.Text(u8"Цвет полоски брони игроков фон")
				end
				
				imgui.Separator()
				imgui.Text(fa.DATABASE..u8' Команды скрипта (большая часть возможно не работает)')
				
				for _,v in ipairs(commands) do
					imgui.Text(u8:encode(v))
				end
			elseif tab[0] == 5 then
				imgui.Text(fa.HOUSE..u8" Изменение темы:")
				if imgui.Combo("##1", int_item, ImItems, #item_list) then
					ini.themesetting.theme = int_item[0]+1
					save()
					SwitchTheStyle(ini.themesetting.theme) 
				end
				if imgui.SliderFloat(u8"##Rounded", sliders.roundtheme, 0, 10, '%.1f') then
					ini.themesetting.rounded = sliders.roundtheme[0]
					imgui.GetStyle().WindowRounding = sliders.roundtheme[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Изменяет значение закругления только окна (стандартное значение 4.0).")
				
				if imgui.SliderFloat(u8"##RoundedOther", sliders.roundthemecomp, 0, 10, '%.1f') then
					ini.themesetting.roundedcomp = sliders.roundthemecomp[0]
					imgui.GetStyle().FrameRounding = sliders.roundthemecomp[0]
					imgui.GetStyle().GrabRounding = sliders.roundthemecomp[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Изменяет значение закругления остальных компонентов окна, например кнопки и так далее (стандартное значение 2.0).")
				
				if imgui.SliderFloat(u8"##RoundedMenu", sliders.roundthememenu, 0, 10, '%.1f') then
					ini.themesetting.roundedmenu = sliders.roundthememenu[0]
					imgui.GetStyle().ChildRounding = sliders.roundthememenu[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Изменяет значение закругления пунктов выбора меню и чайлдов (стандартное значение 4.0).")
				if imgui.Checkbox(u8" Новый цвет диалогов", checkboxes.dialogstyle) then
					ini.themesetting.dialogstyle = checkboxes.dialogstyle[0]
					save()
					gotofunc("DialogStyle")
					sampAddChatMessage(ini.themesetting.dialogstyle and '{73b461}'..script_name..' {FFFFFF}Новый цвет диалогов {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}Новый цвет диалогов {dc4747}отключен!', -1)
				end
				imgui.SameLine()
				imgui.Ques("Изменяет цвет диалоговых окон похожих как на лаунчере Arizona RP.")
				
				if imgui.Button(u8'Перезагрузить скрипт '..fa.ARROWS_ROTATE..'') then
					showCursor(false, false)
					sampAddChatMessage(script_name..'{FFFFFF} Скрипт был перезагружен из-за нажатия кнопки {DC4747}"Перезагрузить скрипт"{FFFFFF}!', 0x73b461)
					thisScript():reload()
				end
				if imgui.Button(u8'Выключить скрипт '..fa.POWER_OFF..'', imgui.SameLine()) then 
					showCursor(false, false)
					sampAddChatMessage(script_name..'{FFFFFF} Скрипт был выгружен из-за нажатия кнопки {DC4747}"Выключить скрипт"{FFFFFF}!', 0x73b461)
					thisScript():unload() 
				end
				
				if updatesavaliable then
					versionold = u8'(не актуальная)'
					imgui.SameLine()
					if imgui.Button(u8'Скачать обновление '..fa.DOWNLOAD..'', imgui.ImVec2(150, 0)) then
						update():download()
					end
				else
					versionold = u8'(актуальная)'
					imgui.SameLine()
					if imgui.Button(u8'Проверить обновление '..fa.DOWNLOAD..'', imgui.ImVec2(165, 0)) then
						sampAddChatMessage(script_name.."{FFFFFF} У вас установлена самая последняя версия скрипта!", 0x73b461)
					end
				end
				
				imgui.Separator()
				
				local _, myid = sampGetPlayerIdByCharHandle(playerPed)
				local mynick = sampGetPlayerNickname(myid) -- наш ник крч
				local myping = sampGetPlayerPing(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				local framerate = imgui.GetIO().Framerate
				
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1))
				imgui.Text(fa.USER..u8' Пользователь: '..mynick..'['..myid..']')
				imgui.Text(fa.SIGNAL..u8' Пинг: '..myping)
				imgui.Text(fa.CLOCK..u8(string.format(' Текущая дата: %s', os.date("%d.%m.%Y %H:%M:%S"))))
				imgui.Text(fa.TERMINAL..u8(string.format(' Средняя задержка: %.3f мс | Кадров: (%.1f FPS)', 1000.0 / framerate, framerate)))
				imgui.Text(fa.FOLDER..u8' Версия: '..thisScript().version..' '..versionold..'')
				imgui.Text(fa.ADDRESS_CARD..u8' Автор:')
				imgui.SameLine() 
				imgui.Link('https://github.com/riverya4life', script_author)
				imgui.PopStyleColor()
			end
			imgui.EndChild()
			
        imgui.End()
    end
)

function onReceivePacket(id) -- будет флудить wrong server password до тех пор, пока сервер не откроется
	if id == 37 then
		sampSetGamestate(1)
	end
end

function ev.onSendPlayerSync(data) -- банни хоп
	if data.keysData == 40 or data.keysData == 42 then sendOnfootSync(); data.keysData = 32 end
end

function sendOnfootSync()
	local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local data = allocateMemory(68)
	sampStorePlayerOnfootData(myId, data)
	setStructElement(data, 4, 1, 0, false)
	sampSendOnfootData(data)
	freeMemory(data)
end -- тут конец уже

function samp.onShowDialog(id, style, title, button1, button2, text) -- Скрытие пароля банковской карты
    return {id, text == '{929290}Вы должны подтвердить свой PIN-код к карточке.\nВведите свой код в ниже указаную строку.' and 3 or style, title, button1, button2, text}
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Скрытие кода складских помещений
    return {id, text == '{ffffff}Чтобы открыть этот склад, введите специальный' and 3 or style, title, button1, button2, text}
end

function onWindowMessage(msg, wparam, lparam) -- блокировка клавиш alt + tab ёбаный рот блять и прочая хуйня
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
	
	if (msg == 256 or msg == 257) and wparam == 27 and imgui.Process and not isPauseMenuActive() and not sampIsCursorActive() then
        consumeWindowMessage(true, true)
        if msg == 257 then
            mainFrame = new.bool(false)
        end
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
end

-- Functions Mooving Dialog by хуй его знает не помню уже
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

function editRadarMapColor(Alpha)
    memory.setuint8(0x5864BD, Alpha, true)
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function cleanStreamMemoryBuffer()
	local huy = callFunction(0x53C500, 2, 2, 1, 1)
    local huy1 = callFunction(0x40D7C0, 1, 1, -1)
    local huy2 = callFunction(0x53C810, 1, 1, 1)
    local huy3 = callFunction(0x40CF80, 0, 0)
    local huy4 = callFunction(0x4090A0, 0, 0)
    local huy5 = callFunction(0x5A18B0, 0, 0)
    local huy6 = callFunction(0x707770, 0, 0)
    local huy7 = callFunction(0x40CFD0, 0, 0)
end

function samp.onSetMapIcon(iconId, position, type, color, style)
    if type > MAX_SAMP_MARKERS then
        return false
    end
end

function patch()
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
patch()

function gotofunc(fnc)
    ------------------------------------Фиксы и прочее-----------------------------
    if fnc == "all" then
        callFunction(0x7469A0, 0, 0) --mousefix in pause
        --------[фикс спавна с бутылкой и сигарой]----------
        memory.setuint32(0x736F88, 0, false) --вертолет не взрывается много раз
        memory.fill(0x4217F4, 0x90, 21, false) --исправление спавна с бутылкой
        memory.fill(0x4218D8, 0x90, 17, false) --исправление спавна с бутылкой
        memory.fill(0x5F80C0, 0x90, 10, false) --исправление спавна с бутылкой
        memory.fill(0x5FBA47, 0x90, 10, false) --исправление спавна с бутылкой
        memory.write(0x53E94C, 0, 1, false) --del fps delay 14 ms
        memory.write(0x555854, 0x90909090, 4, false) --InterioRreflections
        memory.write(0x555858, 0x90, 1, false) --InterioRreflections
        memory.write(0x745BC9, 0x9090, 2, false) --SADisplayResolutions(1920x1080// 16:9)
        memory.fill(0x460773, 0x90, 7, false) --CJFix
        memory.setuint32(12761548, 1051965045, false) -- car speed fps fix
		memory.setint8(0x58D3DA, 1, true) -- Меняет размер обводки displayGameText
        ---------------------------------------------
        if get_samp_version() == "r1" then
            memory.write(sampGetBase() + 0x64ACA, 0xFB, 1, true) --Min FontSize -5
            memory.write(sampGetBase() + 0x64ACF, 0x07, 1, true) --Max FontSize 7
            memory.write(sampGetBase() + 0xD7B00, 0x7420352D, 4, true) --FontSize StringInfo
            memory.write(sampGetBase() + 0xD7B04, 0x37206F, 4, true) --FontSize StringInfo
            memory.write(sampGetBase() + 0x64A51, 0x32, 1, true) --PageSize MAX
            memory.write(sampGetBase() + 0xD7AD5, 0x35, 1, true) --PageSize StringInfo
        elseif get_samp_version() == "r3" then
            memory.write(sampGetBase() + 0x67F2A, 0xFB, 1, true) --Min FontSize -5 (минимальное значение для команды /fontsize)
            memory.write(sampGetBase() + 0x67F2F, 0x07, 1, true) --Max FontSize 7 (максимальное значение для команды /fontsize)
            memory.write(sampGetBase() + 0xE9DE0, 0x7420352D, 4, true) --FontSize StringInfo (выводит инфу о минимальном значении при вводе /fontsize)
            memory.write(sampGetBase() + 0xE9DE4, 0x37206F, 4, true) --FontSize StringInfo (выводит инфу о максимальном значении при вводе /fontsize)
            memory.write(sampGetBase() + 0x67EB1, 0x32, 1, true) --PageSize MAX (максимальное число для /pagesize)
            memory.write(sampGetBase() + 0xE9DB5, 0x35, 1, true) --PageSize StringInfo (выводит инфу о максимальном значении при вводе /pagesize)
        end
        ----------------------------------------------------------------------------
    end
    -----------------------------------------------------------------------
	if fnc == "OpenMenu" then
        mainFrame[0] = not mainFrame[0]
	end
	-----------------------Главная-----------------------
	if fnc == "MoneyFontStyle" or fnc == "all" then
        if ini.settings.moneyfontstyle then
            memory.setint8(0x58F57F, ini.settings.moneyfontstyle, true)
        end
    end
    if fnc == "AlphaMap" or fnc == "all" then
        if ini.settings.alphamap then
            editRadarMapColor(ini.settings.alphamap)
        end
    end
	-----------------------Boost FPS-----------------------
	if fnc == "NoPostfx" or fnc == "all" then
        if ini.settings.postfx then
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
		if ini.settings.noeffects then
			memory.write(4891712, 8386, 4, false)
        else
            memory.write(4891712, 1443425411, 4, false)
        end
	end
    if fnc == "CleanMemory" then
        local oldram = ("%d"):format(tonumber(get_memory()))
        cleanStreamMemoryBuffer()
        local newram = ("%d"):format(tonumber(get_memory()))
        if ini.cleaner.cleaninfo then
            sampAddChatMessage(script_name.."{FFFFFF} Памяти до: {dc4747}"..oldram.." МБ. {FFFFFF}Памяти после: {dc4747}"..newram.." МБ. {FFFFFF}Очищено: {dc4747}"..oldram - newram.." МБ.", 0x73b461)
        end
    end
	-----------------------Исправления блять-----------------------
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
			memory.setint32(0x866C94, 0x6430302524, true) -- Позитивные деньги с удалением нулей
			memory.setint64(0x866C8C, 0x64303025242D, true) -- Негативные деньги с удалением нулей
        else
            memory.setint32(0x866C94, 0x6438302524, true) -- Позитивные деньги стандартное значение
			memory.setint64(0x866C8C, 0x64373025242D, true) -- Негативные деньги стандартное значение
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
        if ini.settings.vsync then
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
	-----------------------Команды и прочее-----------------------
	if fnc == "ShowNicks" then
        if ini.settings.shownicks then
            memory.setint16(sampGetBase() + 0x70D40, 0xC390, true)
        else
            memory.setint16(sampGetBase() + 0x70D40, 0x8B55, true)
        end
	end
	if fnc == "ShowHP" then
		if ini.settings.showhp then
			memory.setint16(sampGetBase() + 0x6FC30, 0xC390, true)
		else
			memory.setint16(sampGetBase() + 0x6FC30, 0x8B55, true)
		end
	end
	if fnc == "NoRadio" then
        if ini.settings.noradio then
            memory.write(5159328, -1947628715, 4, true)
        else
            memory.write(5159328, -1962933054, 4, true)
        end
	end
	if fnc == "DelGun" then
        if ini.settings.delgun == true and isKeyJustPressed(46) and not sampIsCursorActive() then
            removeAllCharWeapons(PLAYER_PED)
        end
	end
	if fnc == "ClearChat" then
		memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
        memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
        memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    end
	if fnc == "ShowChat" then
		if ini.settings.showchat then
			memory.write(sampGetBase() + 0x7140F, 1, 1, true)
			sampSetChatDisplayMode(0)
		else
			memory.write(sampGetBase() + 0x7140F, 0, 1, true)
			sampSetChatDisplayMode(3)
		end
	end
	-----------------------Настройки-----------------------
	if fnc == "DialogStyle" or fnc == "all" then
		if ini.themesetting.dialogstyle then 
			setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) 
		else 
			setDialogColor(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
		end
	end
	if fnc == "Recolorer" or fnc == "all" then
        if ini.settings.recolorer then
            memory.write(0xBAB22C, ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_HEALTH.b*255, ini.RECOLORER_HEALTH.g*255, ini.RECOLORER_HEALTH.r*255)), 4, false)
            memory.write(0xBAB230, ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_MONEY.b*255, ini.RECOLORER_MONEY.g*255, ini.RECOLORER_MONEY.r*255)), 4, false)
            memory.write(0xBAB244, ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_STARS.b*255, ini.RECOLORER_STARS.g*255, ini.RECOLORER_STARS.r*255)), 4, false)
            memory.write(0xBAB23C, ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_ARMOUR.b*255, ini.RECOLORER_ARMOUR.g*255, ini.RECOLORER_ARMOUR.r*255)), 4, false)
            memory.write(0xBAB238, ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_PATRONS.b*255, ini.RECOLORER_PATRONS.g*255, ini.RECOLORER_PATRONS.r*255)), 4, false)

            memory.setuint32(sampGetBase() + ((get_samp_version() == "r1") and 0x68B0C or 0x6CA7C), ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_PLAYERHEALTH.r*255, ini.RECOLORER_PLAYERHEALTH.g*255, ini.RECOLORER_PLAYERHEALTH.b*255)), true) -- полная полоска хп
            memory.setuint32(sampGetBase() + ((get_samp_version() == "r1") and 0x68B33 or 0x6CAA3), ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_PLAYERHEALTH2.r*255, ini.RECOLORER_PLAYERHEALTH2.g*255, ini.RECOLORER_PLAYERHEALTH2.b*255)), true) -- задний фон

            memory.setuint32(sampGetBase() + ((get_samp_version() == "r1") and 0x68DD5 or 0x6CD45), ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_PLAYERARMOR.r*255, ini.RECOLORER_PLAYERARMOR.g*255, ini.RECOLORER_PLAYERARMOR.b*255)), true) -- полная полоска брони
            memory.setuint32(sampGetBase() + ((get_samp_version() == "r1") and 0x68E00 or 0x6CD70), ("0xFF%06X"):format(join_argb(0, ini.RECOLORER_PLAYERARMOR2.r*255, ini.RECOLORER_PLAYERARMOR2.g*255, ini.RECOLORER_PLAYERARMOR2.b*255)), true) -- задний фон
        else
            writeMemory(0xBAB22C, 4, -14870092, true)
            writeMemory(0xBAB230, 4, -13866954, true)
            writeMemory(0xBAB244, 4, -15703408, true)
            writeMemory(0xBAB23C, 4, -1973791, true)
            writeMemory(0xBAB238, 4, -930900, true)

            writeMemory(sampGetBase() + ((get_samp_version() == "r1") and 0x68B0C or 0x6CA7C), 4, -2088157, true)
            writeMemory(sampGetBase() + ((get_samp_version() == "r1") and 0x68B33 or 0x6CAA3), 4, -2109489, true)
        end
    end
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

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
	imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	SwitchTheStyle(ini.themesetting.theme)
end)

-- labels - Array - названия элементов меню
-- selected - imgui.ImInt() - выбранный пункт меню
-- size - imgui.ImVec2() - размер элементов
-- speed - float - скорость анимации выбора элемента (необязательно, по стандарту - 0.2)
-- centering - bool - центрирование текста в элементе (необязательно, по стандарту - false)
function imgui.CustomMenu(labels, selected, size, speed, centering)
    local bool = false
	local centering = false
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
		draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + size.x, p.y + size.y), col_hovered, ini.themesetting.roundedmenu)
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

-----------------------Реколорер блять-----------------------
function join_argb(a, b, g, r)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
-------------------------------------------------------------

function SwitchTheStyle(theme)
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
  
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = sliders.roundtheme[0]
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = sliders.roundthemecomp[0]
    style.ItemSpacing = ImVec2(7, 4)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 16.0
    style.GrabMinSize = 20.0
    style.GrabRounding = sliders.roundthemecomp[0]
	style.ChildRounding = sliders.roundthememenu[0]

    if theme == 1 or theme == nil then
        colors[imgui.Col.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.Separator]              = colors[imgui.Col.Border]
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        
    elseif theme == 2 then
        colors[imgui.Col.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[imgui.Col.Separator]              = colors[imgui.Col.Border]
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        
    elseif theme == 3 then
        colors[imgui.Col.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[imgui.Col.Separator]              = colors[imgui.Col.Border]
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)

        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        
    elseif theme == 4 then  
        colors[imgui.Col.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[imgui.Col.Separator]              = colors[imgui.Col.Border]
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)

        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        
    
    elseif theme == 5 then
        colors[imgui.Col.Text]                   = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.05, 0.07, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.07, 0.07, 0.09, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[imgui.Col.Border]                 = ImVec4(0.80, 0.80, 0.83, 0.88)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
    elseif theme == 6 then
        colors[imgui.Col.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]         = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[imgui.Col.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.90)
        colors[imgui.Col.ChildBg]        = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[imgui.Col.PopupBg]              = ImVec4(0.09, 0.09, 0.09, 1.00)
        colors[imgui.Col.Border]               = ImVec4(0.71, 0.71, 0.71, 0.40)
        colors[imgui.Col.BorderShadow]         = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[imgui.Col.FrameBg]              = ImVec4(0.34, 0.30, 0.34, 0.30)
        colors[imgui.Col.FrameBgHovered]       = ImVec4(0.22, 0.21, 0.21, 0.40)
        colors[imgui.Col.FrameBgActive]        = ImVec4(0.20, 0.20, 0.20, 0.44)
        colors[imgui.Col.TitleBg]              = ImVec4(0.52, 0.27, 0.77, 0.82)
        colors[imgui.Col.TitleBgActive]        = ImVec4(0.55, 0.28, 0.75, 0.87)
        colors[imgui.Col.TitleBgCollapsed]     = ImVec4(9.99, 9.99, 9.90, 0.20)
        colors[imgui.Col.MenuBarBg]            = ImVec4(0.27, 0.27, 0.29, 0.80)
        colors[imgui.Col.ScrollbarBg]          = ImVec4(0.30, 0.20, 0.39, 1.00)
        colors[imgui.Col.ScrollbarGrab]        = ImVec4(0.41, 0.19, 0.63, 0.31)
        colors[imgui.Col.ScrollbarGrabHovered] = ImVec4(0.41, 0.19, 0.63, 0.78)
        colors[imgui.Col.ScrollbarGrabActive]  = ImVec4(0.41, 0.19, 0.63, 1.00)
        colors[imgui.Col.CheckMark]            = ImVec4(0.89, 0.89, 0.89, 0.50)
        colors[imgui.Col.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[imgui.Col.SliderGrabActive]     = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[imgui.Col.Button]               = ImVec4(0.41, 0.19, 0.63, 0.44)
        colors[imgui.Col.ButtonHovered]        = ImVec4(0.41, 0.19, 0.63, 0.86)
        colors[imgui.Col.ButtonActive]         = ImVec4(0.64, 0.33, 0.94, 1.00)
        colors[imgui.Col.Header]               = ImVec4(0.56, 0.27, 0.73, 0.44)
        colors[imgui.Col.HeaderHovered]        = ImVec4(0.78, 0.44, 0.89, 0.80)
        colors[imgui.Col.HeaderActive]         = ImVec4(0.81, 0.52, 0.87, 0.80)
        colors[imgui.Col.Separator]            = ImVec4(0.42, 0.42, 0.42, 1.00)
        colors[imgui.Col.SeparatorHovered]     = ImVec4(0.57, 0.24, 0.73, 1.00)
        colors[imgui.Col.SeparatorActive]      = ImVec4(0.69, 0.69, 0.89, 1.00)
        colors[imgui.Col.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[imgui.Col.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[imgui.Col.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.89)
        colors[imgui.Col.PlotLines]            = ImVec4(1.00, 0.99, 0.99, 1.00)
        colors[imgui.Col.PlotLinesHovered]     = ImVec4(0.49, 0.00, 0.89, 1.00)
        colors[imgui.Col.PlotHistogram]        = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[imgui.Col.PlotHistogramHovered] = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[imgui.Col.TextSelectedBg]       = ImVec4(0.54, 0.00, 1.00, 0.34)
    elseif theme == 7 then
        colors[imgui.Col.Text]                   = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.05, 0.07, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.07, 0.07, 0.09, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[imgui.Col.Border]                 = ImVec4(0.80, 0.80, 0.83, 0.88)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.76, 0.31, 0.00, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.80, 0.33, 0.00, 1.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[imgui.Col.SliderGrab]             = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(1.00, 0.42, 0.00, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
    elseif theme == 8 then
        colors[imgui.Col.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.36, 0.42, 0.47, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.11, 0.15, 0.17, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.15, 0.18, 0.22, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.12, 0.20, 0.28, 1.00)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.09, 0.12, 0.14, 0.65)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.08, 0.10, 0.12, 1.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.15, 0.18, 0.22, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.09, 0.21, 0.31, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.37, 0.61, 1.00, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.20, 0.25, 0.29, 0.55)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
    elseif theme == 9 then
        colors[imgui.Col.Text]                   = ImVec4(0.860, 0.930, 0.890, 0.78)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.860, 0.930, 0.890, 0.28)
        colors[imgui.Col.WindowBg]               = ImVec4(0.13, 0.14, 0.17, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.200, 0.220, 0.270, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.200, 0.220, 0.270, 0.9)
        colors[imgui.Col.Border]                 = ImVec4(0.31, 0.31, 1.00, 0.00)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.200, 0.220, 0.270, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.232, 0.201, 0.271, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.200, 0.220, 0.270, 0.75)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.200, 0.220, 0.270, 0.47)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.200, 0.220, 0.270, 1.00)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.09, 0.15, 0.1, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.47, 0.77, 0.83, 0.14)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.47, 0.77, 0.83, 0.14)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.455, 0.198, 0.301, 0.86)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.455, 0.198, 0.301, 0.76)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.455, 0.198, 0.301, 0.86)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.47, 0.77, 0.83, 0.04)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.455, 0.198, 0.301, 0.43)
    elseif theme == 10 then
        colors[imgui.Col.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.10, 0.10, 0.10, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[imgui.Col.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
        colors[imgui.Col.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
        colors[imgui.Col.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
        colors[imgui.Col.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[imgui.Col.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
        
    elseif theme == 11 then
        colors[imgui.Col.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[imgui.Col.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[imgui.Col.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[imgui.Col.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        
    elseif theme == 12 then
        colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.ChildBg]          = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.44, 0.44, 0.44, 0.60)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.57, 0.57, 0.57, 0.70)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.76, 0.76, 0.76, 0.80)
        colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.60)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(0.13, 0.75, 0.55, 0.80)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.13, 0.75, 0.75, 0.80)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[imgui.Col.Button]                 = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[imgui.Col.ButtonActive]           = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[imgui.Col.Header]                 = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[imgui.Col.HeaderActive]           = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[imgui.Col.Separator]              = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.13, 0.75, 0.55, 0.40)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.13, 0.75, 0.75, 0.60)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(0.13, 0.75, 1.00, 0.80)
        colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
        
    elseif theme == 13 then
        colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.90)
        colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
        colors[imgui.Col.Border]                 = ImVec4(0.73, 0.36, 0.00, 0.00)
        colors[imgui.Col.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 1.00)
        colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[imgui.Col.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
        colors[imgui.Col.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[imgui.Col.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
        colors[imgui.Col.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
        colors[imgui.Col.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
        colors[imgui.Col.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[imgui.Col.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
        colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
        colors[imgui.Col.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
        colors[imgui.Col.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
        colors[imgui.Col.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
        colors[imgui.Col.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
        colors[imgui.Col.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
        colors[imgui.Col.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[imgui.Col.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
        colors[imgui.Col.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
        colors[imgui.Col.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
        colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
        colors[imgui.Col.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
        colors[imgui.Col.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
        colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
        colors[imgui.Col.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
        colors[imgui.Col.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
        colors[imgui.Col.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
        colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
        colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
        colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
    end
end
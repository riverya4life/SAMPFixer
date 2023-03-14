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
		starsdisplay = false,
	},
	themesetting = {
		theme = 6,
		rounded = 4.0,
		roundedcomp = 2.0,
		roundedmenu = 4.0,
		dialogstyle = false,
	},
	commands = {
		openmenu = "/riverya",	
		animmoney = "/animmoney",
	}
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
local MAX_SAMP_MARKERS = 63
local CVehicle_DoSunGlare = ffi.cast("void (__thiscall*)(unsigned int)", 0x6DD6F0)

---------------------------------------------------------
local mainFrame = imgui.new.bool(false)

local sw, sh = getScreenResolution()

local sliders = {
	weather = imgui.new.int(ini.settings.weather),
	time = imgui.new.int(ini.settings.time),
	roundtheme = imgui.new.float(ini.themesetting.rounded),
	roundthemecomp = imgui.new.float(ini.themesetting.roundedcomp),
	roundthememenu = imgui.new.float(ini.themesetting.roundedmenu),
	drawdist = imgui.new.int(ini.settings.drawdist),
    drawdistair = imgui.new.int(ini.settings.drawdistair),
    drawdistpara = imgui.new.int(ini.settings.drawdistpara),
    fog = imgui.new.int(ini.settings.fog),
    lod = imgui.new.int(ini.settings.lod),
	alphamap = imgui.new.int(ini.settings.alphamap),
}

local checkboxes = {
	blockweather = imgui.new.bool(ini.settings.blockweather),
	blocktime = imgui.new.bool(ini.settings.blocktime),
	givemedist = imgui.new.bool(ini.settings.givemedist),
	fixbloodwood = imgui.new.bool(ini.fixes.fixbloodwood),
	nolimitmoneyhud = imgui.new.bool(ini.fixes.nolimitmoneyhud),
	sunfix = imgui.new.bool(ini.fixes.sunfix),
	grassfix = imgui.new.bool(ini.fixes.grassfix),
	postfx = imgui.new.bool(ini.settings.postfx),
	dialogstyle = imgui.new.bool(ini.themesetting.dialogstyle),
	noeffects = imgui.new.bool(ini.settings.noeffects),
	moneyfontfix = imgui.new.bool(ini.fixes.moneyfontfix),
	starsdisplay = imgui.new.bool(ini.fixes.starsdisplay),
}

local buffers = {
	cmd_openmenu = imgui.new.char[64](ini.commands.openmenu),
	cmd_animmoney = imgui.new.char[64](ini.commands.animmoney),
}

local int_item = imgui.new.int(ini.themesetting.theme-1)
local item_list = {u8"Синяя", u8"Красная", u8"Коричневая", u8"Аква", u8"Черная", u8"Фиолетовая", u8"Черно-оранжевая", u8"Серая", u8"Вишневая", u8"Зеленая", u8"Пурпурная", u8"Темно-зеленая", u8"Оранжевая"}
local ImItems = imgui.new['const char*'][#item_list](item_list)

local tab = imgui.new.int(1)
local tabs = {fa.HOUSE..u8' Главная', fa.PLUS..u8' Boost FPS', fa.GEARS..u8' Исправления', fa.BOOK..u8' Команды', fa.GEARS..u8' Настройки',
}

local ivar = imgui.new.int(ini.settings.animmoney-1)
local tbmtext = {
    u8"Быстрая",
    u8"Без анимации",
    u8"Стандартная",
}
local tmtext = imgui.new['const char*'][#tbmtext](tbmtext)

local commands = {
"/sname",
"/shp",
"/gameradio",
"/delgun",
"/clearchat",
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
}

local created = false

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
	
	sampRegisterChatCommand("sname", function()
        ini.settings.shownicks = not ini.settings.shownicks
        if ini.settings.shownicks then
            memory.setint16(sampGetBase() + 0x70D40, 0xC390, true)
        else
            memory.setint16(sampGetBase() + 0x70D40, 0x8B55, true)
        end
        save()
        sampAddChatMessage(ini.settings.shownicks and '{73b461}'..script_name..' {FFFFFF}Ники игроков {dc4747}отключены!' or '{73b461}'..script_name..' {FFFFFF}Ники игроков {73b461}включены!', -1)
    end)
    sampRegisterChatCommand("shp", function()
        ini.settings.showhp = not ini.settings.showhp
        if ini.settings.showhp == true then
            memory.setint16(sampGetBase() + 0x6FC30, 0xC390, true)
        else
            memory.setint16(sampGetBase() + 0x6FC30, 0x8B55, true)
        end
        save()
        sampAddChatMessage(ini.settings.showhp and '{73b461}'..script_name..' {FFFFFF}Полоска ХП игроков {dc4747}отключена!' or '{73b461}'..script_name..' {FFFFFF}Полоска ХП игроков {73b461}включена!', -1)
    end)
    sampRegisterChatCommand("gameradio", function()
        ini.settings.noradio = not ini.settings.noradio
        save()
        sampAddChatMessage(ini.settings.noradio and '{73b461}'..script_name..' {FFFFFF}Радио {dc4747}отключено!' or '{73b461}'..script_name..' {FFFFFF}Радио {73b461}включено!', -1)
    end)
    sampRegisterChatCommand("delgun", function()
        ini.settings.delgun = not ini.settings.delgun
        save()
        sampAddChatMessage(ini.settings.delgun and '{73b461}'..script_name..' {FFFFFF}Удаление всего оружия в руках на клавишу DELETE {73b461}включено!' or '{73b461}'..script_name..' {FFFFFF}Удаление всего оружия в руках на клавишу DELETE {dc4747}отключено!', -1)
    end)
    sampRegisterChatCommand("clearchat", function()
        memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
        memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
        memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    end)
    sampRegisterChatCommand("showchat", function()
        ini.settings.showchat = not ini.settings.showchat
        sampAddChatMessage(ini.settings.showchat and '{73b461}'..script_name..' {FFFFFF}Чат {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}Чат {dc4747}выключен!', -1)
        save()
        if ini.settings.showchat == true then
            memory.write(sampGetBase() + 0x7140F, 0x0, 0x1, true)
            sampSetChatDisplayMode(2)
        else
            memory.write(sampGetBase() + 0x7140F, 0x1, 0x1, true)
            sampSetChatDisplayMode(0)
        end
    end)
    if ini.settings.showchat == true then
        memory.write(sampGetBase() + 0x7140F, 0x0, 0x1, true)
        sampSetChatDisplayMode(2)
    else
        memory.write(sampGetBase() + 0x7140F, 0x1, 0x1, true)
        sampSetChatDisplayMode(0)
    end
    
    sampRegisterChatCommand("st", setTime)
    sampRegisterChatCommand("sw", setWeather)
    sampRegisterChatCommand("showhud", function()
        ini.settings.showhud = not ini.settings.showhud
        sampAddChatMessage(ini.settings.showhud and '{73b461}'..script_name..' {FFFFFF}HUD {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}HUD {dc4747}выключен!', -1)
        save()
        if ini.settings.showhud == true then
            displayHud(true)
            memory.setint8(0xBA676C, 0)
        else
            displayHud(false)
            memory.setint8(0xBA676C, 2)
        end
    end)
    if ini.settings.showhud == true then
        displayHud(true)
        memory.setint8(0xBA676C, 0)
    else
        displayHud(false)
        memory.setint8(0xBA676C, 2)
    end
    if ini.settings.givemedist == true then
        writeMemory(5499541, 4, 12044272, true)--снятие защиты
        writeMemory(8381985, 4, 13213544, true)--снятие защиты
    end
    sampRegisterChatCommand("blockdist", function()
        ini.settings.givemedist = not ini.settings.givemedist
        sampAddChatMessage(ini.settings.givemedist and '{73b461}'..script_name..' {FFFFFF}Возможность менять прорисовку {73b461}включена!' or '{73b461}'..script_name..' {FFFFFF}Возможность менять прорисовку {dc4747}выключена!', -1)
        save()
        if ini.settings.givemedist == true then
            writeMemory(5499541, 4, 12044272, true)--снятие защиты
            writeMemory(8381985, 4, 13213544, true)--снятие защиты
        else
            writeMemory(5499541, 4, 12043504, true)--установка защиты
            writeMemory(8381985, 4, 13210352, true)--установка защиты
        end
    end)
    sampRegisterChatCommand("160hp", function()
        ini.settings.bighpbar = not ini.settings.bighpbar
        sampAddChatMessage(ini.settings.bighpbar and '{73b461}'..script_name..' {FFFFFF}160hp bar {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}160hp bar {dc4747}выключен!', -1)
        save()
        if ini.settings.bighpbar == true then
            memory.setfloat(12030944, 910.4, true)
            ini.hphud.mode = 2
            save()
        else
            memory.setfloat(12030944, 569.0, true)
            ini.hphud.mode = 1
            save()
        end
    end)
    if ini.settings.bighpbar == true then
        memory.setfloat(12030944, 910.4, true)
    else
        memory.setfloat(12030944, 569.0, true)
    end
    sampRegisterChatCommand("drawdist", cmd_fdist)

    sampRegisterChatCommand("hpdig", function()
        ini.hphud.active = not ini.hphud.active
        sampAddChatMessage(ini.hphud.active and '{73b461}'..script_name..' {FFFFFF}Показатель ХП в цифрах {73b461}включен!' or '{73b461}'..script_name..' {FFFFFF}Показатель ХП в цифрах {dc4747}выключен!', -1)
        save()
        if ini.hphud.active == false then
            sampTextdrawDelete(2029)
        end
    end)
	sampRegisterChatCommand("hpstyle", hpstyle)
	sampRegisterChatCommand("hppos", hppos)
	sampRegisterChatCommand("hpt", hpt)

    memory.setfloat(12044272, ini.settings.drawdist, true)

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
		
        if not ini.settings.blockweather ~= true and ini.settings.weather ~= memory.read(0xC81320, 2, false) then memory.write(0xC81320, ini.settings.weather, 2, false) end
        if not ini.settings.blocktime ~= true and ini.settings.time ~= memory.read(0xB70153, 1, false) then memory.write(0xB70153, ini.settings.time, 1, false) end
		
		if ini.settings.noradio == true and isCharInAnyCar(playerPed) and getRadioChannel(playerPed) < 12 then
            setRadioChannel(12)
        end
		
        if ini.settings.delgun == true and isKeyJustPressed(46) and not sampIsCursorActive() then
            removeAllCharWeapons(PLAYER_PED)
        end
		
		if ini.themesetting.dialogstyle == true then setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) else setDialogColor(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
		end
		
		if ini.fixes.fixbloodwood == true then writeMemory(0x49EE63+1, 4, 0, true) else writeMemory(0x49EE63+1, 4, 0x3F800000, true)
		end
		
		if ini.fixes.nolimitmoneyhud then writeMemory(0x571784, 4, 0x57C7FFF, true) writeMemory(0x57179C, 4, 0x57C7FFF, true) else writeMemory(0x571784, 4, 0x57C3B9A, true) writeMemory(0x57179C, 4, 0x57C3B9A, true)
		end
		
		if ini.settings.postfx then memory.write(7358318, 2866, 4, true) memory.write(7358314, -380152237, 4, true) writeMemory(0x53E227, 1, 0xC3, true) else memory.write(7358318, 1448280247, 4, true) memory.write(7358314, -988281383, 4, true) writeMemory(0x53E227, 1, 0xE9, true)
        end
		
		if ini.fixes.sunfix then memory.hex2bin("E865041C00", 0x53C136, 5) else memory.fill(0x53C136, 0x90, 5, true)
        end
		
		if ini.fixes.grassfix then memory.hex2bin("E8420E0A00", 0x53C159, 5) memory.protect(0x53C159, 5, memory.unprotect(0x53C159, 5)) else memory.fill(0x53C159, 0x90, 5, true)
        end
		
		if ini.settings.givemedist == true then
            memory.write(0x53EA95, 0xB7C7F0, 4, true)-- вкл
			memory.write(0x7FE621, 0xC99F68, 4, true)-- вкл
		else
			memory.write(0x53EA95, 0xB7C4F0, 4, true)-- выкл
			memory.write(0x7FE621, 0xC992F0, 4, true)-- выкл
		end
		
		if memory.read(0x8E4CB4, 4, true) > 838860800 then
			local oldram = ("%d"):format(get_memory())
			cleanStreamMemoryBuffer()
			local newram = ("%d"):format(get_memory())
			sampAddChatMessage(script_name.." {FFFFFF} Память была успешно очищена нахуй! Памяти до пьянки: {dc4747}"..oldram.." МБ. {FFFFFF}Памяти после пьянки: {dc4747}"..newram.." МБ. {FFFFFF}Очищено негров: {dc4747}"..oldram - newram.." МБ.", 0x73b461)
		end
		
		if ini.settings.noeffects == true then
			memory.write(4891712, 8386, 4, false)
        else
            memory.write(4891712, 1443425411, 4, false)
        end
		
		if ini.fixes.moneyfontfix == true then
			memory.setint32(0x866C94, 0x6430302524, true) -- Позитивные деньги с удалением нулей
			memory.setint64(0x866C8C, 0x64303025242D, true) -- Негативные деньги с удалением нулей
        else
            memory.setint32(0x866C94, 0x6438302524, true) -- Позитивные деньги стандартное значение
			memory.setint64(0x866C8C, 0x64373025242D, true) -- Негативные деньги стандартное значение
        end
		
		if ini.fixes.starsdisplay then
			memory.fill(0x58DD1B, 0x90, 2, true)
		else
			memory.fill(0x58DFD3, 0x90, 5, true)
        end

        CDialog = sampGetDialogInfoPtr()
        CDXUTDialog = memory.getuint32(CDialog + 0x1C)

    end
end

function onSendRpc(id, bs, priority, reliability, orderingChannel, shiftTs)
	if id == 50 then
        local cmd_len = raknetBitStreamReadInt32(bs)
        local cmd = raknetBitStreamReadString(bs, cmd_len)
		
		if cmd:find("^"..ini.commands.openmenu.."$") then
			mainFrame[0] = not mainFrame[0]
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
    iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
	imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	SwitchTheStyle(ini.themesetting.theme)
end)

function imgui.CustomMenu(labels, selected, size, speed, centering)
    local bool = false
    speed = speed and speed or 0.2
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
        local col_bg =  imgui.GetColorU32Vec4(selected[0] == i and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0,0,0,0))
        local col_box =  imgui.GetColorU32Vec4(selected[0] == i and imgui.GetStyle().Colors[imgui.Col.Button] or imgui.ImVec4(0,0,0,0))
        local col_hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        local col_hovered =  imgui.GetColorU32Vec4(imgui.ImVec4(col_hovered.x, col_hovered.y, col_hovered.z, (imgui.IsItemHovered() and 0.2 or 0)))
        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + t * size.x, p.y + size.y), col_bg, ini.themesetting.roundedmenu)
        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + size.x, p.y + size.y), col_hovered, ini.themesetting.roundedmenu)
        draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x+5, p.y + size.y), col_box)
        imgui.SetCursorPos(imgui.ImVec2(c.x+(centering and (size.x-imgui.CalcTextSize(v).x)/2 or 15), c.y+(size.y-imgui.CalcTextSize(v).y)/2))
        imgui.Text(v)
        imgui.SetCursorPos(imgui.ImVec2(c.x, c.y+size.y))
    end
    return bool
end

local Frame = imgui.OnFrame(
    function() return mainFrame[0] end,
    function(self)
        imgui.SetNextWindowSize(imgui.ImVec2(670, 325), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"SAMP++ by "..script_author.."", mainFrame, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
			imgui.SetCursorPos(imgui.ImVec2(-2, 25))
			imgui.CustomMenu(tabs, tab, imgui.ImVec2(135, 50))

			imgui.SetCursorPos(imgui.ImVec2(155, 25))
			imgui.BeginChild('##main', imgui.ImVec2(-1, 293), true)
			if tab[0] == 1 then
				imgui.Text(fa.CLOUD_SUN_RAIN..u8" Погода:")
				imgui.SameLine()
				imgui.Ques("Изменяет игровую погоду на свою.")
				if imgui.SliderInt(u8"##Weather", sliders.weather, 0, 45) then
					ini.settings.weather = sliders.weather[0] 
					save()
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
				end
				imgui.Text(fa.CIRCLE_DOLLAR_TO_SLOT..u8" Анимация прибавления / убавления денег:")
                if imgui.Combo("##2", ivar, tmtext, #tbmtext) then
					ini.settings.animmoney = ivar[0]+1
					save()
					if ini.settings.animmoney == 1 then
						memory.write(5707667, 138, 1, true)
						sampAddChatMessage(script_name.." {FFFFFF}Анимация изменения кол-ва денег изменена на: {DC4747}быструю", 0x73b461)
					elseif ini.settings.animmoney == 2 then
						memory.write(5707667, 137, 1, true)
						sampAddChatMessage(script_name.." {FFFFFF}Анимация изменения кол-ва денег изменена на: {DC4747}без анимации", 0x73b461)
					elseif ini.settings.animmoney == 3 then
						memory.write(5707667, 139, 1, true)
						sampAddChatMessage(script_name.." {FFFFFF}Анимация изменения кол-ва денег изменена на: {DC4747}стандартную", 0x73b461)
					end
				end
				imgui.Text(fa.CLOUD_SUN_RAIN..u8" Прозрачность карты на радаре:")
				imgui.SameLine()
				imgui.Ques("Изменяет прозрачность карты на радаре (значение от 0 до 255).")
				if imgui.SliderInt(u8"##AlphaMap", sliders.alphamap, 0, 255) then
					ini.settings.alphamap = sliders.alphamap[0]
					editRadarMapColor(ini.settings.alphamap)
					save()
				end
			elseif tab[0] == 2 then
				if imgui.Checkbox(u8" Отключить пост-обработку", checkboxes.postfx) then
					ini.settings.postfx = checkboxes.postfx[0]
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
				if imgui.Checkbox(u8" Включить возможность менять прорисовку", checkboxes.givemedist) then
					ini.settings.givemedist = checkboxes.givemedist[0] 
					save()
				end
				if ini.settings.givemedist then
					if imgui.CollapsingHeader(fa.EYE..u8' Дальность прорисовки') then
						imgui.Text(fa.EYE..u8" Основная дальность прорисовки:")
						if imgui.SliderInt(u8"##Drawdist", sliders.drawdist, 35, 3600) then
							ini.settings.drawdist = sliders.drawdist[0]
							save()
							memory.setfloat(12044272, ini.settings.drawdist, true)
						end
						imgui.SameLine()
						imgui.Ques("Изменяет основную дальность прорисовки.")
						imgui.Text(fa.PLANE_UP..u8" Дальность прорисовки в воздушном транспорте:")
						if imgui.SliderInt(u8"##drawdistair", sliders.drawdistair, 35, 3600) then
							ini.settings.drawdistair = sliders.drawdistair[0]
							save()
							if isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED) then
								if memory.getfloat(12044272, true) ~= ini.settings.drawdistair then
									memory.setfloat(12044272, ini.settings.drawdistair, true)
								end
							end
						end
						imgui.SameLine()
						imgui.Ques("Изменяет дальность прорисовки в воздушном транспорте.")
						imgui.Text(fa.PARACHUTE_BOX..u8" Дальность прорисовки при использовании парашута:")
						if imgui.SliderInt(u8"##drawdistpara", sliders.drawdistpara, 35, 3600) then
							ini.settings.drawdistpara = sliders.drawdistpara[0]
							save()
							if getCurrentCharWeapon(PLAYER_PED) == 46 then
								if memory.getfloat(12044272, true) ~= ini.settings.drawdistpara then
									memory.setfloat(12044272, ini.settings.drawdistpara, true)
								end
							end
						end
						imgui.SameLine()
						imgui.Ques("Изменяет дальность прорисовки при использовании парашута.")
						imgui.Text(fa.SMOG..u8" Дальность прорисовки тумана:")
						if imgui.SliderInt(u8"##fog", sliders.fog, 0, 500) then
							ini.settings.fog = sliders.fog[0]
							save()
							memory.setfloat(13210352, ini.settings.fog, true)
						end
						imgui.SameLine()
						imgui.Ques("Изменяет дальность прорисовки тумана.")
						imgui.Text(fa.MOUNTAIN..u8" Дальность прорисовки лодов:")
						if imgui.SliderInt(u8"##lod", sliders.lod, 0, 300) then
							ini.settings.lod = sliders.lod[0]
							save()
							memory.setfloat(0xCFFA11, ini.settings.lod, true)
						end
						imgui.SameLine()
						imgui.Ques("Изменяет дальность прорисовки лодов.")
					end
				end
				
			elseif tab[0] == 3 then
				if imgui.Checkbox(u8" Исправление крови при повреждении дерева", checkboxes.fixbloodwood) then
					ini.fixes.fixbloodwood = checkboxes.fixbloodwood[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Исправление крови при повреждении дерева.")

				if imgui.Checkbox(u8" Cнять лимит на ограничение денег в худе", checkboxes.nolimitmoneyhud) then
					ini.fixes.nolimitmoneyhud = checkboxes.nolimitmoneyhud[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Снимает лимит на количество денег в худе, если у вас больше 999.999.999$")
				
				if imgui.Checkbox(u8" Вернуть солнце", checkboxes.sunfix) then
					ini.fixes.sunfix = checkboxes.sunfix[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Возвращает солнце из одиночной игры.")
				
				if imgui.Checkbox(u8" Вернуть траву", checkboxes.grassfix) then
					ini.fixes.grassfix = checkboxes.grassfix[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Возвращает траву из одиночной игры (эффекты в настройках должны стоять средние+). После выключения вы должны перезайти в игру чтобы убрать траву окончательно!")
				
				if imgui.Checkbox(u8" Удаление нулей в худе", checkboxes.moneyfontfix) then
					ini.fixes.moneyfontfix = checkboxes.moneyfontfix[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Удаляет нули в худе, вместо 000.000.350$ будет 350$")
				
				if imgui.Checkbox(u8" Звёзды на экране", checkboxes.starsdisplay) then
					ini.fixes.starsdisplay = checkboxes.starsdisplay[0]
					save()
				end --writeMemory(0x6E7760, 1, 0xC3, true)
				imgui.SameLine()
				imgui.Ques("После включения этой функции вы должны перезайти в игру.")
				
			elseif tab[0] == 4 then
				imgui.Text(fa.DATABASE..u8' Команды скрипта')
				imgui.Separator()
				
					for _,v in ipairs(commands) do
						imgui.Text(u8:encode(v))
					end
					imgui.SameLine()
					imgui.SetCursorPosY(25)
					for _,v in ipairs(texincommands) do
						imgui.SetCursorPosX(100)
						imgui.Ques(v)
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
					save()
				end
				imgui.SameLine()
				imgui.Ques("Изменяет значение закругления остальных компонентов окна, например кнопки и так далее (стандартное значение 2.0).")
				
				if imgui.SliderFloat(u8"##RoundedMenu", sliders.roundthememenu, 0, 10, '%.1f') then
					ini.themesetting.roundedmenu = sliders.roundthememenu[0]
					save()
				end
				imgui.SameLine()
				imgui.Ques("Изменяет значение закругления пунктов выбора меню (стандартное значение 4.0).")
				if imgui.Checkbox(u8" Новый цвет диалогов", checkboxes.dialogstyle) then
					ini.themesetting.dialogstyle = checkboxes.dialogstyle[0]
					save()
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
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1))
				imgui.Text(fa.USER..u8' Пользователь: '..mynick..'['..myid..']')
				imgui.Text(fa.CLOCK..u8(string.format(' Текущая дата: %s', os.date())))
				local framerate = imgui.GetIO().Framerate
				imgui.Text(fa.TERMINAL..u8(string.format(' Средняя задержка: %.3f мс | Кадров: (%.1f FPS)', 1000.0 / framerate, framerate)))
				imgui.Text(fa.ADDRESS_CARD..u8' Автор:')
				imgui.SameLine() 
				imgui.Link('https://github.com/riverya4life', ''..script_author..'')
				imgui.PopStyleColor()
			end
			imgui.EndChild()
			
        imgui.End()
    end
)

function setTime(time)
	local time = tonumber(time)
    if type(time) ~= 'number' or tonumber(time) > tonumber(23) then
        sampAddChatMessage(script_name.." {FFFFFF}Используйте {dc4747}/st [0-23]", 0x73b461)
    else
        sampAddChatMessage(script_name.." {FFFFFF}Установлено время: {dc4747}"..time.."", 0x73b461)
        memory.write(0xB70153, time, 1, false)
        ini.settings.time = time
        save()
    end
end

function setWeather(weather)
	local weather = tonumber(weather)
    if type(weather) ~= 'number' or tonumber(weather) > tonumber(45) then
        sampAddChatMessage(script_name.." {FFFFFF}Используйте {dc4747}/sw [0-45]", 0x73b461)
    else
        sampAddChatMessage(script_name.." {FFFFFF}Установлена погода: {dc4747}"..weather.."", 0x73b461)
        memory.write(0xC81320, weather, 2, false)
        memory.write(0xC81318, weather, 2, false)
        memory.write(0xC81320, weather, 2, false)
        ini.settings.weather = weather
        save()
    end
end

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
            mainFrame = imgui.new.bool(false)
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

function cleanStreamMemoryBuffer()
	local huy = callFunction(0x53C500, 2, 2, true, true)
	local huy1 = callFunction(0x53C810, 1, 1, true)
	local huy2 = callFunction(0x40CF80, 0, 0)
	local huy3 = callFunction(0x4090A0, 0, 0)
	local huy4 = callFunction(0x5A18B0, 0, 0)
	local huy5 = callFunction(0x707770, 0, 0)
	local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
	requestCollision(pX, pY)
	loadScene(pX, pY, pZ)
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
    style.GrabRounding = 2.0

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
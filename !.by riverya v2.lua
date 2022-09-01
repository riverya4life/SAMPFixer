script_author('RIVERYA4LIFE.')
require 'lib.moonloader'

-- подключаемые Libs
local samp = require 'lib.samp.events'
local ev = require 'samp.events'
local mem = require 'memory'
local vkeys = require 'vkeys'
local commands = {'clear', 'threads', 'chatcmds'}

-- stats
local currentmoney = 0
local nowmymoney = 0

-- info
local author = 'RIVERYA4LIFE.'
local tiktok = 'tiktok.com/@riverya4life'
local vk = 'vk.com/riverya4life'

-- для скрытия описания перса
local active = nil
local pool = {}

-- Message if the description does not exist:
no_description_text = "* ќписание отсутствует *"

function ev.onCreate3DText(id, col, pos, dist, wall, PID, VID, text)
	if PID ~= 65535 and col == -858993409 and pos.z == -1 then
		pool[PID] = {id = id, col = col, pos = pos, dist = dist, wall = wall, PID = PID, VID = VID, text = text }
		return false
	end
end

function ev.onRemove3DTextLabel(id)
	for i, info in ipairs(pool) do
		if info.id == id then
			table.remove(pool, i)
		end
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
    while sampGetGamestate() ~= 3 do return true end

	sampAddChatMessage('{FFFFFF}Сборку сделал {42B166}'..author..' {FFFFFF}| {74adfc}'..vk..' {FFFFFF}I{74adfc} '..tiktok..'', -1)
	sampAddChatMessage('{42B166}[Уютненько :)]{ffffff} Меню скрипта: {dc4747}/riverya{FFFFFF}', -1)

  _, myid = sampGetPlayerIdByCharHandle(playerPed)
  mynick = sampGetPlayerNickname(myid) -- наш ник крч
  -- nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

  -- для скрытия описания перса
  local duration = 0.3
  local max_alpha = 255
  local start = os.clock()
  local finish = nil

-- Блок памяти
  mem.setint8(0xB7CEE4, 1) -- бесконечный бег
  mem.fill(0x58DD1B, 0x90, 2, true) -- звёзды на экране
  mem.setuint8(0x588550, 0xEB, true) -- disable arrow
  mem.setuint32(0x58A4FE + 0x1, 0x0, true) -- disable green rect
  mem.setuint32(0x586A71 + 0x1, 0x0, true) -- disable height indicator
  mem.setuint8(0x58A5D2 + 0x1, 0x0, true)
  mem.setuint32(0x58A73B + 0x1, 0x0, true) -- залупа которая бесит крч фисташки
  mem.write(sampGetBase() + 383732, -1869574000, 4, true) -- блок клавишы Т (рус. Е)


  for i = 1, #commands do
    runSampfuncsConsoleCommand(commands[i])
end

-- Блок зарегестрированных команд
  sampRegisterChatCommand("riverya", riverya)
  sampRegisterChatCommand("riveryahelp", riveryahelp)
  sampRegisterChatCommand("kosdmitop", riveryatop)
  sampRegisterChatCommand("riveryalox", riveryatop)
  sampRegisterChatCommand("riveryaloh", riveryatop)

  sampRegisterChatCommand('pivko', cmd_pivko) -- прикол
  sampRegisterChatCommand('givepivo', cmd_givepivo) -- прикол х2
  sampRegisterChatCommand('takebich', cmd_takebich) -- не курите в реале
  sampRegisterChatCommand('mystonks', cmd_getmystonks)

  sampRegisterChatCommand("fps", function() -- зареганные кмд с функцией в main
	runSampfuncsConsoleCommand('fps')
end)
sampRegisterChatCommand("riveryatop", function()
	sampAddChatMessage('{42B166}[Спасибо] {ffffff}Спасибо, мне приятно!', -1)
end)

	while true do 
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
		wait(0)
	end
end

function riverya()
    sampShowDialog(13337,'{dc4747}[Info]','{ffffff}Приветствуем, {dc4747}'..mynick..'!{ffffff}\n\n{ffffff}Сборку сделал Я, {42B166}'..author..' (Риверя).\n\n{ffffff}Я вообще не планировал её сливать из-за своей лени.{ffffff}\nНу что не сделаешь ради просмотров и лайков.\nПодпишись на мой тик ток:\n{dc4747}• '..tiktok..'.\n\n\n{dc4747}*{ffffff}Если ты не мой подписчик, то лучше подпишись, а то мне обидно будет плак плак({dc4747}*{ffffff}\n\n{dc4747}Доступные команды:{ffffff}\n {42B166}•{ffffff} /riverya - Основное окно\n {42B166}•{ffffff} /riveryatop - Тест команда\n {dc4747}• /riveryahelp - *Тут всё подробно описано*{ffffff}','{42B166}Уютненько','{dc4747}Пон',0)
    lua_thread.create(hui)
end

function riveryahelp()
    sampShowDialog(13339,'{dc4747}[Help]','{ffffff}Привет ещё раз, я тебе распишу всё, что есть в скрипте, который я писал для сборки.\n{42B166}Что было добавлено:{ffffff}\n\n   •   Теперь вы не сможете перейти в оконный режим с помощью комбинации {dc4747}Alt + Enter{ffffff} во избежания вылета игры.\n   •   Если сервер стоит под паролем, то будет флудить строкой {dc4747}"Wrong Server Password"{ffffff} до тех пор, пока с сервера не снимут пароль.\n   •   При входе в игру в консоль {dc4747}SampFuncs{ffffff} будут прописаны команды {dc4747}clear, threads и chatcmds{ffffff} автоматически.\n   •   {dc4747}Звёзды{ffffff} теперь отображаются на экране всегда.\n   •   Теперь чтобы вывести счётчик {dc4747}FPS{ffffff} достаточно прописать в чат команду {dc4747}/fps{ffffff} (теперь в консоль {dc4747}SampFuncs{ffffff} заходить не обязательно)\n   •   Убран надоедливый зелёный радар при полетё (осталась только тестура в {dc4747}hud.txd{ffffff}, которая заменяется на которую хотите)\n   •   Добавлена команда {dc4747}/mystonks{ffffff} для для просмотра своего дохода за текущую сессию.\n   •   Добавлена команда {dc4747}/pivko{ffffff} для посиделок с братанами вечерком или для RP ситуаций, так же есть команда {dc4747}/givepivo ID{ffffff} чтобы передать (у вас в руках появиться пивко)\n   •   Добавлена команда {dc4747}/takebich{ffffff} чтобы можно было покурить с братком на районе (всем будет видно)\n   •   Теперь {dc4747}описание{ffffff} не будет видно, пока вы не нацелитесь на игрока (под Аризону как некий FPS UP)\n   •   Теперь клавиша {dc4747}T (рус. Е){ffffff} не открывает чат (по умолчанию теперь клавиша {dc4747}F6{ffffff})\n   •   При вводе команд {dc4747}/riveryaloh{ffffff} или {dc4747}/riveryalox{ffffff} вас ждёт сюрприз {dc4747}<3{ffffff}','{42B166}Уютненько','',0)
    lua_thread.create(negrtop)
end

function hui()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13337)
	if __ and button == 1 then
        sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Автор сборки ленивая жопа.', -1)
	elseif __ and button == 0 then
		sampShowDialog(13338,'{dc4747}[Реклама]','{ffffff}Играй со мной на {dc4747}Arizona Role Play Scottdale.{ffffff}\n\nРегистрируйся на мой ник {42B166}Tape_Riverya{ffffff} и получай целых {42B166}300.000${FFFFFF} на 5 уровне.\nПо желанию на 6 уровне вводи промокод {42B166}#riverya4life{FFFFFF}\nОт системы получишь {42B166}100.000${FFFFFF} и от меня ещё целый {42B166}МИЛЛИОН ДОЛЛАРОВ!{FFFFFF}\n\n\nНу а так желаю приятной игры {dc4747}<3{FFFFFF}','{42B166}Уютненько','',0)
		end
	end
end

function negrtop()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13339)
	if __ and button == 0 then
		sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Уютненько обед.', -1)
		end
	end
end

function riveryatop()
	readMemory(0, 1)
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

function onWindowMessage(msg, wparam, lparam) -- блокировка клавиш alt + tab 
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end

function cmd_getmystonks()
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	mynick = sampGetPlayerNickname(myid)
	
	local result = 0
	nowmymoney = getPlayerMoney(mynick)
	result = nowmymoney - currentmoney
	
	sampAddChatMessage('{dc4747}[#riverya4life]{ffffff} За сессию Вы заработали '..'{5EEE0C}'.. result ..'${FF0000}', -1)
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

function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function saturate(f) 
	return f < 0 and 0 or (f > 255 and 255 or f) 
end

function setNextRequestTime(time)
    local samp = getModuleHandle("samp.dll")
    mem.setuint32(samp + 0x3DBAE, time, true)
end

function ev.onSetVehicleVelocity(turn, velocity)
    if velocity.x ~= velocity.x or velocity.y ~= velocity.y or velocity.z ~= velocity.z then
        sampAddChatMessage("[Warning] ignoring invalid SetVehicleVelocity", 0x00FF00)
        return false
    end
end

function ev.onServerMessage(color, text)
	if text:find("%[Ошибка%] {FFFFFF}Доступно только с мобильного или PC лаунчера!") then
		return false
	end
end
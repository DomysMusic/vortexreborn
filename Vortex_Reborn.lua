local version_script = '1.0.0'
script_authors('Ivann, Miroljub')

local jsn_upd = "https://gitlab.com/snippets/2486731/raw"

local tag = "{BF3FFF}[VortexReborn]: {EAEAEA}"

local imgui         = require("mimgui")
local vKeys         = require('vKeys')
local inicfg        = require("inicfg")
local memory        = require("memory")
local ev            = require("lib.samp.events")
local faicons       = require("fAwesome5")
local encoding      = require("encoding")
local mem           = require("memory")
local ffi           = require ("ffi")

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

local cx = representIntAsFloat(readMemory(0xB6EC10, 4, false))
local cy = representIntAsFloat(readMemory(0xB6EC14, 4, false))
local w, h = getScreenResolution()
local xc, yc = w * cy, h * cx

encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new

local font = renderCreateFont("Arial", 14, 10)

local aim = {
	renderWindow = {
		renderWindow = new.bool(),
        renderSettings = new.bool()
	},
	CheckBox = {
        autoupdate = new.bool(),
        enableAim = new.bool(),
        checkBuild = new.bool(),
        checkVehicle = new.bool(),
        checkObject = new.bool(),
        bone = new.int(1),
        enableProAim = new.bool(),
        enableLagger = new.bool(),
        noSpread = new.bool(),
        autoshot = new.bool(),
        wallhack = new.bool(),
        line = new.bool(),
        box = new.bool(),
        distPed = new.bool(),
        nameTag = new.bool(),
        noCamRestore = new.bool(),
        antistun = new.bool(),
        fullSkill = new.bool(),
        noReload = new.bool(),
        plusC = new.bool(),
        CBUGHelper = new.bool(),
        noFall = new.bool(),
        team = new.bool(),
        themes = new.int(0),
        silentAim = new.bool(),
        silentFov = new.float(),
        silentMaxDist = new.float(),
        missRatio = new.float(),
        silentShootWalls = new.bool(),
        repairVeh = new.bool(),
        flipVeh = new.bool(),
        infFuel = new.bool(),
        vehGm = new.bool(),
        playerGm = new.bool(),
        fastExit = new.bool(),
        driftmode = new.bool(),
        nitro = new.bool(),
        collision = new.bool(),
        nightV = new.bool(),
        thermalV = new.bool(),
        wheelsGm = new.bool(),
        reconnect = new.bool(),
        ghostmode = new.bool()
    },
	Sliders = {
        lang = new.int(),
        Smooth = new.float(),
        Fov = new.float(),
        lagX = new.float(),
        lagY = new.float(),
        lagZ = new.float(),
        speedX = new.float(),
        speedY = new.float(),
        speedZ = new.float(),
        maxDistAim = new.float(),
        maxDistPro = new.float()
	}, Buttons = {
        save = new.bool(),
        reset = new.bool()
    }
}


function main()
    repeat wait(0) until isSampAvailable()
    wait(1000)
	if aim.CheckBox.autoupdate[0] then autoupdate(jsn_upd, tag, url_upd)
	else sampAddChatMessage(tag..(aim.CheckBox.lang_menu[0] and u8 "Iskljucili ste auto-azuriranje. Koristite verziju: {BF3FFF}"..version_script.." {ffffff}| Meni: {BF3FFF}F2" or 'You have disabled autoupdate. You are using version: {BF3FFF}'..version_script..' {ffffff}| Menu: {BF3FFF}F2'), -1) end

    msg("{FFFFFF}Vortex Reborn intialized.")
    iniLoad()
    lua_thread.create(Aimbot)
	sampRegisterChatCommand("aa", function()
		aim.renderWindow.renderWindow[0] = not aim.renderWindow.renderWindow[0]
    end)
    local PI = 3.14159
    while true do wait(0)
		if isKeyJustPressed(vKeys.VK_F3) then
			aim.renderWindow.renderWindow[0] = not aim.renderWindow.renderWindow[0]
		end
        if aim.CheckBox.enableLagger[0] then
            if not isCharInAnyCar(PLAYER_PED) then
                local x, y, z = getCharCoordinates(PLAYER_PED)
                local data = samp_create_sync_data('player')

                    data.position.x = x + aim.Sliders.lagX[0]
                    data.position.y = y + aim.Sliders.lagY[0]
                    data.position.z = z + aim.Sliders.lagZ[0]

                    data.moveSpeed.x = aim.Sliders.speedX[0]
                    data.moveSpeed.y = aim.Sliders.speedY[0]
                    data.moveSpeed.z = aim.Sliders.speedZ[0]

                data.send()
            end
        end

        if aim.CheckBox.noSpread[0] then
            memory.setfloat(0x8D2E64, 0)            
        else
            memory.setfloat(0x8D2E64, memory.getfloat(0x8D2E64))
        end

        if aim.CheckBox.autoshot[0] and not isCharInAnyCar(PLAYER_PED) and not isCharDead(PLAYER_PED) then
            local int = readMemory(0xB6F3B8, 4, 0)
			int=int + 0x79C
			local intS = readMemory(int, 4, 0)
				if intS > 0
				then
				local lol = 0xB73458
				lol=lol + 34
				writeMemory(lol, 4, 255, 0)
				local int = readMemory(0xB6F3B8, 4, 0)
				int=int + 0x79C
                writeMemory(int, 4, 0, 0)
            end
        end

        if aim.CheckBox.wallhack[0] then
            for i = 0, sampGetMaxPlayerId() do
                if sampIsPlayerConnected(i) then
                    local result, handlePed = sampGetCharHandleBySampPlayerId(i)
					local color_ped = sampGetPlayerColor(i)
					local a, r, g, b = explode_argb(color_ped)
					local color = join_argb(255, r, g, b)
					if result and doesCharExist(handlePed) and isCharOnScreen(handlePed) then
                        local pos = {getCharCoordinates(PLAYER_PED)}
                        local whpos = {getCharCoordinates(handlePed)}
                        local x1, y1 = convert3DCoordsToScreen(pos[1], pos[2], pos[3])
                        local x2, y2 = convert3DCoordsToScreen(whpos[1], whpos[2], whpos[3])
                        if aim.CheckBox.line[0] then
                            renderDrawPolygon(x1, y1, 8, 8, 16, 0.0, color)
                            renderDrawLine(x1, y1, x2, y2, 2, color)
                            renderDrawPolygon(x2, y2, 8, 8, 16, 0.0, color)
                        end
                        if aim.CheckBox.box[0] then
                            renderDrawBoxWithBorder(x2 - 65 / 2, y2 - 60, 65, 120, 0x00FFFFFF, 3, color)
                        end
                        if aim.CheckBox.nameTag[0] then
                            local whpos = {GetBodyPartCoordinates(8, handlePed)}
                            local x1, y1 = convert3DCoordsToScreen(pos[1], pos[2], pos[3])
                            local x2, y2 = convert3DCoordsToScreen(whpos[1], whpos[2], whpos[3])
                            local _, id = sampGetPlayerIdByCharHandle(handlePed)
                            local nick = sampGetPlayerNickname(id)
                            renderFontDrawText(font, nick.." | ID ["..id.."]" , x2, y2 - 50, color, -1)
                        end
                        if aim.CheckBox.distPed[0] then
                            local whpos = {GetBodyPartCoordinates(8, handlePed)}
                            local x1, y1 = convert3DCoordsToScreen(pos[1], pos[2], pos[3])
                            local x2, y2 = convert3DCoordsToScreen(whpos[1], whpos[2], whpos[3])
                            renderFontDrawText(font, 'Dist [ '..string.format('%0.2f', getDistanceBetweenCoords3d(pos[1], pos[2], pos[3], whpos[1], whpos[2], whpos[3]))..' ]', x2, y2 - 30, color, -1)
                        end
                    end
                end
            end
        end
		
		                        if isCharInAnyCar(PLAYER_PED) then
                            pCarHandle = storeCarCharIsInNoSave(PLAYER_PED)
                        end
                        if aim.CheckBox.repairVeh[0] and isCharInAnyCar(PLAYER_PED) then
                            if isKeyJustPressed(vKeys.VK_L) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and isCharInAnyCar(PLAYER_PED) then
                                local veh = storeCarCharIsInNoSave(PLAYER_PED)
                                local _, id = sampGetVehicleIdByCarHandle(veh)
                                local data = samp_create_sync_data('vehicle', true)
                                if _ then
                                    data.vehicleId = id
                                    data.position.x, data.position.y, data.position.z = getCarCoordinates(veh)
                                    data.vehicleHealth = 1000
                                    data.send()
                                    setCarHealth(veh, 1000)
                                    fixCar(veh)
                                end
                            end
                        end
                        if aim.CheckBox.flipVeh[0] and isCharInAnyCar(PLAYER_PED) then
                            if wasKeyPressed(vKeys.VK_H) and not isGamePaused() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
								local veh = storeCarCharIsInNoSave(PLAYER_PED)
								local oX, oY, oZ = getOffsetFromCarInWorldCoords(veh, 0.0,  0.0,  0.0)
								setCarCoordinates(veh, oX, oY, oZ)
                            end
                        end
                        if aim.CheckBox.infFuel[0] then
                            if isCharInAnyCar(PLAYER_PED) then
                                setCarEngineOn(pCarHandle, true)
                            end
                        end
                        if aim.CheckBox.vehGm[0] and isCharInAnyCar(PLAYER_PED) then
                            local veh = storeCarCharIsInNoSave(PLAYER_PED)
                            setCarProofs(veh, true, true, true, true, true)
                        end
                        if aim.CheckBox.playerGm[0] then
                            setCharProofs(PLAYER_PED, true, true, true, true, true)
                            else
                                setCharProofs(PLAYER_PED, false, false, false, false, false)
                        end
                        if aim.CheckBox.fastExit[0] then
                            if isCharInAnyCar(PLAYER_PED) then
                                if wasKeyPressed(vKeys.VK_F) then
                                local posX, posY, posZ =  getCarCoordinates(storeCarCharIsInNoSave(PLAYER_PED))
                                warpCharFromCarToCoord(PLAYER_PED, posX, posY, posZ)
                                end
                            end
                        end
                        if aim.CheckBox.driftmode[0] then
                            local brc = true
                            if brc and isCharInAnyCar(playerPed) and not sampIsDialogActive() and not sampIsChatInputActive() then local car = storeCarCharIsInNoSave(playerPed)
                                if isKeyDown(vKeys_D) then 
                                    addToCarRotationVelocity(car, 0, 0, -0.7)
                                end
                                if isKeyDown(vKeys_A) then 
                                    addToCarRotationVelocity(car, 0, 0, 0.7)
                                end
                            end
                        end
                        if aim.CheckBox.nitro[0] and isCharInAnyCar(PLAYER_PED) and isKeyJustPressed(vKeys.VK_LBUTTON) then
                            local veh = storeCarCharIsInNoSave(PLAYER_PED)
                            giveNonPlayerCarNitro(veh)
                        end
                        if aim.CheckBox.collision[0] then
							myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
							result, vehHandle = findAllRandomVehiclesInSphere(myPosX, myPosY, myPosZ, 25, true, true)
							if result then
								id_c = getCarModel(vehHandle)
								if vehHandle ~= storeCarCharIsInNoSave(PLAYER_PED) and (id_c == 592 or 577 or 511 or 512 or 593 or 520 or 553 or 476 or 519 or 460 or 513) then
									setCarCollision(vehHandle, false)
								end
							end   
						else
							myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
							result, vehHandle = findAllRandomVehiclesInSphere(myPosX, myPosY, myPosZ, 25, true, true)
							
							if result then
								id_c = getCarModel(vehHandle)
								if vehHandle and (id_c == 592 or 577 or 511 or 512 or 593 or 520 or 553 or 476 or 519 or 460 or 513) then
									setCarCollision(vehHandle, true)
								end
							end
						end
                        if aim.CheckBox.nightV[0] then
                            setNightVision(true)
                        else
                            setNightVision(false)
                        end
                        if aim.CheckBox.thermalV[0] then
                            setInfraredVision(true)
                        else
                            setInfraredVision(false)
                        end
                        if aim.CheckBox.wheelsGm[0] and isCharInAnyCar(PLAYER_PED) then
                            local veh = storeCarCharIsInNoSave(PLAYER_PED)
                            setCanBurstCarTires(veh, false)
                        end
                        if aim.CheckBox.reconnect[0] and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
                            local ip, port = sampGetCurrentServerAddress()
                            local servername = sampGetCurrentServerName()
                            if isKeyJustPressed(vKeys.VK_0) and wasKeyPressed(vKeys.VK_LSHIFT) then
                                sampSetGamestate(0)
                                sampConnectToServer(ip, port)
                                sampAddChatMessage("{BF3FFF}[Vortex Reborn] - You are connecting to {BF3FFF}"..servername..'' )
                            end
                        end
                        if aim.CheckBox.ghostmode[0] then
                            _, ped, car = storeClosestEntities(PLAYER_PED)
		                        if ped ~= -1 then
		                            setCharCollision(ped, false)
			                    end
                        end
						
		 if aim.CheckBox.collision[0] then
            memory.fill(0x6C5107, 0x90, 59, true)
        else
            memory.hex2bin("8B5424088B4C24108B461452518B4C24686AFD508B44246C83EC0C8BD489028B842480000000894A048BCE894208E816DD01008A4E36C0E9033ACB", 0x6C5107, 59)
        end

        if aim.CheckBox.noCamRestore[0] then
            memory.write(0x5109AC, 235, 1, true)
	        memory.write(0x5109C5, 235, 1, true)
	        memory.write(0x5231A6, 235, 1, true)
	        memory.write(0x52322D, 235, 1, true)
	        memory.write(0x5233BA, 235, 1, true)
        end

        if aim.CheckBox.enableProAim[0] then
            if getCurrentCharWeapon(playerPed) ~= 0 then
                if isKeyDown(vKeys.VK_RBUTTON) then
                    local playerID = GetPedPro()
                    if playerID ~= -1 then
                        local result, v = sampGetCharHandleBySampPlayerId(playerID)
                        if result then
                            if doesCharExist(v) and not isCharDead(v) then
                                if v ~= playerPed then
                                    local my_pos = {getCharCoordinates(playerPed)}
                                    local other_pos = {getCharCoordinates(playerPed)}
                                    local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
                                    local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
                                    local heading = getCharHeading(playerPed)
                                    local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
                                    local vector = {my_pos[1] - camCoordX, my_pos[2] - camCoordY}
                                    setCharCoordinates(v, (my_pos[1] + math.sin(-math.rad(angle)) * 1.1) + (math.sin(-math.rad(angle)) / 2) - (0.3 * math.sin(-math.rad(angle + 90))), (my_pos[2] + math.cos(-math.rad(angle)) * 1.1) + (math.cos(-math.rad(angle)) / 2) - (0.3 * math.cos(-math.rad(angle + 90))), my_pos[3] - 0.6)
                                    setCharHeading(v, heading)
                                end
                            end
                        end
                    end
                end
            end
        end

        if aim.CheckBox.antistun[0] and not isCharDead(PLAYER_PED) then
            local anim = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}
		    for k, v in pairs(anim) do
			    if isCharPlayingAnim(PLAYER_PED, v) then
				    setCharAnimSpeed(PLAYER_PED, v, 999)
			    end
		    end
        end

        if aim.CheckBox.fullSkill[0] then
        	memory.setint8(0x969179, 1, false)
		else
			memory.setint8(0x969179, 0, false)
        end
        
        if aim.CheckBox.noReload[0] then
            local weap = getCurrentCharWeapon(PLAYER_PED)
			local nbs = raknetNewBitStream()
			raknetBitStreamWriteInt32(nbs, weap)
			raknetBitStreamWriteInt32(nbs, 0)
			raknetEmulRpcReceiveBitStream(22, nbs)
			raknetDeleteBitStream(nbs)
        end

        if aim.CheckBox.plusC[0] then
            local gun = getCurrentCharWeapon(PLAYER_PED)
			if isCharShooting(PLAYER_PED) and gun == 24 then
                wait(1)
                taskPlayAnimNonInterruptable(PLAYER_PED, "HIT_WALK", "PED", 4.0, 0, 1, 1, 0, 1)
            end
        end

        if aim.CheckBox.CBUGHelper[0] then
            if isButtonPressed(PLAYER_HANDLE, 6) and isKeyJustPressed(vKeys.VK_R) then
                sendKey(4)
                setGameKeyState(17, 255)
                wait(55)
                setGameKeyState(6, 0)
                sendKey(2)
                setGameKeyState(18, 255)
            end
        end

        if aim.CheckBox.noFall[0] and (isCharPlayingAnim(PLAYER_PED, 'KO_SKID_BACK') or isCharPlayingAnim(PLAYER_PED, 'FALL_COLLAPSE')) then
            clearCharTasksImmediately(PLAYER_PED)
        end

    end
end

local list_menu = {
    current = 1,
    list = {u8'Main Menu', u8'Player', u8'Weapon', u8'Silent Aim', u8'Lagger', u8'Wallhack', u8'Other'}
}

local function OnOffButton(text, sizeImVec2, bool)
    if bool then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.149, 0.692, 0.072, 0.800))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
    else
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.19, 0.19, 0.800))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
    end
    local result = imgui.Button(text, sizeImVec2)
    imgui.PopStyleColor(3)
    return result
end

local newFrame = imgui.OnFrame(
	function() return aim.renderWindow.renderWindow[0] end,
	function(player)

        local sizeX, sizeY = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 500), imgui.Cond.FirstUseEver)

		imgui.Begin(u8"VortexReborn v"..version_script, aim.renderWindow.renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
            imgui.PushFont(font16)

                imgui.SetCursorPosX(24)
                for number, ml in ipairs(list_menu.list) do
                    if HeaderButton(list_menu.current == number, ml) then
                        list_menu.current = number
                    end
                    if number ~= #list_menu.list then
                        imgui.SameLine(nil, 30)
                    end
                end

                imgui.SetCursorPosY(72)
                imgui.Separator()
            imgui.PopFont()
            imgui.PushFont(font16)

            if list_menu.current == 1 then
			imgui.Text(aim.CheckBox.lang_menu[0] and u8 "Jezici:" or 'Languages:')
				imgui.RadioButton(u8'Srpski', aim.CheckBox.lang[0], 1) imgui.SameLine()
				imgui.RadioButton('English', aim.CheckBox.lang[0], 2)
					if not aim.CheckBox.lang_menu[0] then if imgui.Button(u8'Serbian Language', imgui.ImVec2(120, 0)) then aim.CheckBox.lang[0] = 1 end
					else if imgui.Button('Engleski Jezik', imgui.ImVec2(100, 0)) then aim.CheckBox.lang[0] = 2 end end
            elseif list_menu.current == 2 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 540))

                if OnOffButton(u8"Stealth Aim", imgui.ImVec2(-1, 24), aim.CheckBox.enableAim[0]) then
                    aim.CheckBox.enableAim[0] = not aim.CheckBox.enableAim[0]
                end

                imgui.NewLine()

                imgui.PushItemWidth(480)
                    imgui.SliderFloat(u8"SA: Angle", aim.Sliders.Fov, 1.0, 180)
                    imgui.SliderFloat(u8"SA: Smooth", aim.Sliders.Smooth, 0.6, 50)
                    imgui.SliderFloat(u8"SA: Distance", aim.Sliders.maxDistAim, 1.0, 300)
                imgui.PopItemWidth()
                
                imgui.NewLine()

                imgui.BeginChild(u8"##ChildAim1", imgui.ImVec2(-1, 140), true)

                    imgui.BeginGroup()
                        imgui.Checkbox(u8"Check Buildings", aim.CheckBox.checkBuild)
                        imgui.Checkbox(u8"Check Vehicles", aim.CheckBox.checkVehicle)
                        imgui.Checkbox(u8"Check Objects", aim.CheckBox.checkObject)
                    imgui.EndGroup()

                    imgui.SameLine()

                    imgui.BeginGroup()
                        imgui.RadioButtonIntPtr(u8"Head", aim.CheckBox.bone, 0)
                        imgui.RadioButtonIntPtr(u8"Torso", aim.CheckBox.bone, 1)
                        imgui.RadioButtonIntPtr(u8"Pelvis", aim.CheckBox.bone, 2)
                    imgui.EndGroup()

                    imgui.SameLine(320)

                    imgui.BeginGroup()
                        local posX, posY = -1, -1;
                        if aim.CheckBox.team[0] then
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.149, 0.692, 0.072, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        else
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.19, 0.19, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        end
                        imgui.PopStyleColor(3)
                    imgui.EndGroup()
                imgui.EndChild()

            elseif list_menu.current == 3 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 300))

                if OnOffButton(u8"Stealth Aim", imgui.ImVec2(-1, 24), aim.CheckBox.enableAim[0]) then
                    aim.CheckBox.enableAim[0] = not aim.CheckBox.enableAim[0]
                end

                imgui.NewLine()

                imgui.PushItemWidth(480)
                    imgui.SliderFloat(u8"SA: Angle", aim.Sliders.Fov, 1.0, 180)
                    imgui.SliderFloat(u8"SA: Smooth", aim.Sliders.Smooth, 0.6, 50)
                    imgui.SliderFloat(u8"SA: Distance", aim.Sliders.maxDistAim, 1.0, 300)
                imgui.PopItemWidth()
                


                    imgui.BeginGroup()
                        imgui.Checkbox(u8"Check Buildings", aim.CheckBox.checkBuild)
                        imgui.Checkbox(u8"Check Vehicles", aim.CheckBox.checkVehicle)
                        imgui.Checkbox(u8"Check Objects", aim.CheckBox.checkObject)
                    imgui.EndGroup()

                    imgui.SameLine()

                    imgui.BeginGroup()
                        imgui.RadioButtonIntPtr(u8"Head", aim.CheckBox.bone, 0)
                        imgui.RadioButtonIntPtr(u8"Torso", aim.CheckBox.bone, 1)
                        imgui.RadioButtonIntPtr(u8"Pelvis", aim.CheckBox.bone, 2)
                    imgui.EndGroup()

                    imgui.SameLine(320)

                        local posX, posY = -1, -1;
                        if aim.CheckBox.team[0] then
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.149, 0.692, 0.072, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        else
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.19, 0.19, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        end
                        imgui.PopStyleColor(3)

                if OnOffButton(u8'Pro Aim', imgui.ImVec2(-1, 24), aim.CheckBox.enableProAim[0]) then
                    aim.CheckBox.enableProAim[0] = not aim.CheckBox.enableProAim[0]
                end
                imgui.NewLine()
                imgui.PushItemWidth(460)
                imgui.SliderFloat(u8"Pro: Distance", aim.Sliders.maxDistPro, 1.0, 300)
                imgui.PopItemWidth()

                if OnOffButton(u8"Stealth Aim", imgui.ImVec2(-1, 24), aim.CheckBox.enableAim[0]) then
                    aim.CheckBox.enableAim[0] = not aim.CheckBox.enableAim[0]
                end

                imgui.NewLine()

                imgui.PushItemWidth(480)
                    imgui.SliderFloat(u8"SA: Angle", aim.Sliders.Fov, 1.0, 180)
                    imgui.SliderFloat(u8"SA: Smooth", aim.Sliders.Smooth, 0.6, 50)
                    imgui.SliderFloat(u8"SA: Distance", aim.Sliders.maxDistAim, 1.0, 300)
                imgui.PopItemWidth()
                
                imgui.NewLine()

                imgui.BeginChild(u8"##ChildAim1", imgui.ImVec2(-1, 140), true)

                    imgui.BeginGroup()
                        imgui.Checkbox(u8"Check Buildings", aim.CheckBox.checkBuild)
                        imgui.Checkbox(u8"Check Vehicles", aim.CheckBox.checkVehicle)
                        imgui.Checkbox(u8"Check Objects", aim.CheckBox.checkObject)
                    imgui.EndGroup()

                    imgui.SameLine()

                    imgui.BeginGroup()
                        imgui.RadioButtonIntPtr(u8"Head", aim.CheckBox.bone, 0)
                        imgui.RadioButtonIntPtr(u8"Torso", aim.CheckBox.bone, 1)
                        imgui.RadioButtonIntPtr(u8"Pelvis", aim.CheckBox.bone, 2)
                    imgui.EndGroup()

                    imgui.SameLine(320)

                    imgui.BeginGroup()
                        local posX, posY = -1, -1;
                        if aim.CheckBox.team[0] then
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.149, 0.692, 0.072, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        else
                            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.19, 0.19, 0.800))
                            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                            if imgui.Button(u8'Shoot Team', imgui.ImVec2(posX, posY)) then
                                aim.CheckBox.team[0] = not aim.CheckBox.team[0]
                            end
                        end
                        imgui.PopStyleColor(3)
                    imgui.EndGroup()

            elseif list_menu.current == 4 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 440))

                local posX, posY = -1, 24

                if OnOffButton(u8'Silent Aim', imgui.ImVec2(-1, 24), aim.CheckBox.silentAim[0]) then
                    aim.CheckBox.silentAim[0] = not aim.CheckBox.silentAim[0]
                end

                imgui.BeginChild(u8'##ChildSilent', imgui.ImVec2(-1, 180), true)
                    if aim.CheckBox.silentShootWalls[0] then
                        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.149, 0.692, 0.072, 0.800))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.149, 0.692, 0.072, 0.602))
                        if imgui.Button(u8'Shoot Walls', imgui.ImVec2(posX, posY)) then
                            aim.CheckBox.silentShootWalls[0] = not aim.CheckBox.silentShootWalls[0]
                        end
                    else
                        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.19, 0.19, 0.800))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.19, 0.19, 0.40))
                        if imgui.Button(u8'Shoot Walls', imgui.ImVec2(posX, posY)) then
                            aim.CheckBox.silentShootWalls[0] = not aim.CheckBox.silentShootWalls[0]
                        end
                    end
                    imgui.PopStyleColor(3)

                    imgui.NewLine()
                    
                    imgui.PushItemWidth(420)
                        imgui.SliderFloat(u8'SA: View Angle', aim.CheckBox.silentFov, 1, 360)
                        imgui.SliderFloat(u8'SA: Distance', aim.CheckBox.silentMaxDist, 1, 600)
                        imgui.SliderFloat(u8'SA: Misses [%]', aim.CheckBox.missRatio, 0, 100)
                    imgui.PopItemWidth()

                imgui.EndChild()

            elseif list_menu.current == 5 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 440))

                imgui.SetCursorPosY(80)
                if OnOffButton(u8'Lagger', imgui.ImVec2(-1, 24), aim.CheckBox.enableLagger[0]) then
                    aim.CheckBox.enableLagger[0] = not aim.CheckBox.enableLagger[0]
                end
                
                imgui.PushItemWidth(500)
                    imgui.SliderFloat(u8"Axis X", aim.Sliders.lagX, -1, 1)
                    imgui.SliderFloat(u8"Axis Y", aim.Sliders.lagY, -1, 1)
                    imgui.SliderFloat(u8"Axis Z", aim.Sliders.lagZ, -1, 1)

                    imgui.SliderFloat(u8"Speed X", aim.Sliders.speedX, -1, 1)
                    imgui.SliderFloat(u8"Speed Y", aim.Sliders.speedY, -1, 1)
                    imgui.SliderFloat(u8"Speed Z", aim.Sliders.speedZ, -1, 1)
                imgui.PopItemWidth()


            elseif list_menu.current == 6 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 410))

                imgui.SetCursorPosY(80)
                if OnOffButton(u8'Enable Wallhack', imgui.ImVec2(-1, 24), aim.CheckBox.wallhack[0]) then
                    aim.CheckBox.wallhack[0] = not aim.CheckBox.wallhack[0]
                end

                imgui.BeginChild(u8"##ChildWh1", imgui.ImVec2(-1, 150), true)

                    if OnOffButton(u8'Player Lines', imgui.ImVec2(-1, 24), aim.CheckBox.line[0]) then
                        aim.CheckBox.line[0] = not aim.CheckBox.line[0]
                    end
                    if OnOffButton(u8'Player Boxes', imgui.ImVec2(-1, 24), aim.CheckBox.box[0]) then
                        aim.CheckBox.box[0] = not aim.CheckBox.box[0]
                    end
                    if OnOffButton(u8'Player Names', imgui.ImVec2(-1, 24), aim.CheckBox.nameTag[0]) then
                        aim.CheckBox.nameTag[0] = not aim.CheckBox.nameTag[0]
                    end
                    if OnOffButton(u8'Player Distance', imgui.ImVec2(-1, 24), aim.CheckBox.distPed[0]) then
                        aim.CheckBox.distPed[0] = not aim.CheckBox.distPed[0]
                    end

                imgui.EndChild()

            elseif list_menu.current == 7 then
                imgui.SetWindowSizeVec2(imgui.ImVec2(600, 500))

                imgui.NewLine()

                imgui.BeginGroup()
                    imgui.Checkbox(u8"No Spread", aim.CheckBox.noSpread)
                    imgui.Checkbox(u8"Auto Shoot", aim.CheckBox.autoshot)
                    imgui.Checkbox(u8"No Cam Restore", aim.CheckBox.noCamRestore)
                imgui.EndGroup()
                
                imgui.SameLine(180)

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Anti Stun", aim.CheckBox.antistun)
                    imgui.Checkbox(u8"No Fall", aim.CheckBox.noFall)
                    imgui.Checkbox(u8"Full Skills", aim.CheckBox.fullSkill)
                imgui.EndGroup()

                imgui.SameLine(340)

                imgui.BeginGroup()
                    imgui.Checkbox(u8"No Reload", aim.CheckBox.noReload)
                    imgui.Checkbox(u8"+C Helper", aim.CheckBox.plusC)
                    imgui.Checkbox(u8"Auto +C", aim.CheckBox.CBUGHelper)
                    imgui.Text(u8'Press R button multiple times')
                imgui.EndGroup()

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Repair Vehicle, press L to repair.", aim.CheckBox.repairVeh)
                    imgui.Checkbox(u8"Flip Vehicle, press H to flip.", aim.CheckBox.flipVeh)
                    imgui.Checkbox(u8"Infinity Fuel", aim.CheckBox.infFuel)
                imgui.EndGroup()

                imgui.SameLine(340)

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Vehicle God Mode", aim.CheckBox.vehGm)
                    imgui.Checkbox(u8"Player God Mode", aim.CheckBox.playerGm)
                    imgui.Checkbox(u8"Fast Exit", aim.CheckBox.fastExit)
                imgui.EndGroup()

                imgui.NewLine()

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Drift Mode", aim.CheckBox.driftmode)
                    imgui.Checkbox(u8"Nitro", aim.CheckBox.nitro)
                    imgui.Checkbox(u8"Vehicle Collision", aim.CheckBox.collision)
                imgui.EndGroup()

                imgui.NewLine()

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Night Vision", aim.CheckBox.nightV)
                    imgui.Checkbox(u8"Thermal Vision", aim.CheckBox.thermalV)
                    imgui.Checkbox(u8"Wheels God Mode", aim.CheckBox.wheelsGm)
                imgui.EndGroup()

                imgui.NewLine()

                imgui.BeginGroup()
                    imgui.Checkbox(u8"Reconnect(Shift + 0)", aim.CheckBox.reconnect)
                    imgui.Checkbox(u8"Ghost Mode", aim.CheckBox.ghostmode)
                imgui.EndGroup()

                imgui.NewLine()
                imgui.Separator()
                imgui.NewLine()

                if imgui.Button(faicons.ICON_FA_SAVE..u8" Save Settings", imgui.ImVec2(278, 24)) then
                    iniSave()
                    sampAddChatMessage("{2F92E8}[VortexReborn]: {EAEAEA}Settings saved.")
                end
                imgui.Text(u8'Saves cheat settings')
                imgui.SameLine()
                if imgui.Button(faicons.ICON_FA_FILE_EXCEL..u8" Reset Settings", imgui.ImVec2(278, 24)) then
                    iniReset()
                    iniLoad()
                    sampAddChatMessage("{2F92E8}[VortexReborn]: {EAEAEA}Settings reset.")
                end
                imgui.Text(u8'Restores default cheat settings')
                if imgui.Button(faicons.ICON_FA_COGS..u8" Menu Settings", imgui.ImVec2(-1, 24)) then
                    aim.renderWindow.renderSettings[0] = not aim.renderWindow.renderSettings[0]
                end
                if imgui.Button(faicons.ICON_FA_FILE_UPLOAD..u8' Unload', imgui.ImVec2(278, 24)) then
                    thisScript():unload()
                end
                imgui.Text(u8'Unloads the cheat from the game')
                imgui.SameLine()
                if imgui.Button(faicons.ICON_FA_TRASH..u8' Delete', imgui.ImVec2(278, 24)) then
                    if doesFileExist('moonloader\\Vortex_Reborn.luac') then
                        os.remove('moonloader\\Vortex_Reborn.luac')
                    end
                    if doesFileExist('moonloader\\config\\VortexReborn.ini') then
                        os.remove('moonloader\\config\\VortexReborn.ini')
                    end
                    thisScript():unload()
                end
                imgui.Text(u8'Deletes the cheat and config files from the folder and unloads from the game')
            end

            imgui.NewLine()
            imgui.Separator()

            imgui.NewLine()
            imgui.SameLine(178)
            imgui.Text(faicons.ICON_FA_CHEVRON_RIGHT..' Discord: Miroljub '..faicons.ICON_FA_CHEVRON_LEFT..' (click to copy)'); imgui.ClickCopy('mrljb')
		    imgui.NewLine()
            imgui.SameLine(185)
            imgui.Text(faicons.ICON_FA_CHEVRON_RIGHT..' Discord: Ivann '..faicons.ICON_FA_CHEVRON_LEFT..' (click to copy)'); imgui.ClickCopy('ivann1.')
           

        imgui.Separator()
        imgui.PopFont()
		imgui.End()

        if aim.CheckBox.themes[0] == 0 then
            themeOne()
        elseif aim.CheckBox.themes[0] == 1 then
            themeTwo()
        elseif aim.CheckBox.themes[0] == 2 then
            themeThree()
        elseif aim.CheckBox.themes[0] == 3 then
            themeFour()
        end

	end
)


local newFrame = imgui.OnFrame(
	function() return aim.renderWindow.renderSettings[0] end,
	function(player)

        local sizeX, sizeY = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"Menu Settings", aim.renderWindow.renderSettings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
            imgui.PushFont(font18)

                imgui.BeginChild(u8'##Themes', imgui.ImVec2(270, 220), true)

                    imgui.SetCursorPos(imgui.ImVec2(94, 8))
                    imgui.TextColoredRGB('Themes')
                    imgui.Separator()

                    if imgui.Selectable(u8'Cherry Theme\n\n') then
                        aim.CheckBox.themes[0] = 0
                    elseif imgui.Selectable(u8'Darker Theme\n\n') then
                        aim.CheckBox.themes[0] = 1
                    elseif imgui.Selectable(u8'Pink Theme\n\n') then
                        aim.CheckBox.themes[0] = 2
                    elseif imgui.Selectable(u8'Dark-Green Theme\n\n') then
                        aim.CheckBox.themes[0] = 3
                    end
                
                imgui.EndChild()

                imgui.CenterTextColoredRGB('VortexReborn')

            imgui.PopFont()
        imgui.End()
    end
)


function fix(angle)
    if angle > math.pi then
        angle = angle - (math.pi * 2)
    elseif angle < -math.pi then
        angle = angle + (math.pi * 2)
    end
    return angle
end

function sendKey(key)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local data = allocateMemory(68)
    sampStorePlayerOnfootData(myId, data)
    setStructElement(data, 4, 2, key, false)
    sampSendOnfootData(data)
    freeMemory(data)
end

function GetNearestPed(fov)
    local maxDistance = aim.Sliders.maxDistAim[0]
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    if not isCharDead(handle) then
                        local _, currentID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local enPos = {getCharCoordinates(handle)}
                        local myPos = {getActiveCameraCoordinates()}
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                        local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                        local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                        local distance = math.sqrt((math.pow(angle[1] - view[1], 2) + math.pow(angle[2] - view[2], 2))) * 57.2957795131
                        if distance > fov then check = true else check = false end
                        if not check then
                            local myPos = {getCharCoordinates(PLAYER_PED)}
                            local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                            if (distance < maxDistance) then
                                nearestPED = handle
                                maxDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function GetPedPro()
    local maxDistance = nil
    maxDistance = aim.Sliders.maxDistPro[0]
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
                    local enPos = {getCharCoordinates(handle)}
                    local bonePos = {convert3DCoordsToScreen(enPos[1], enPos[2], enPos[3])}
                    local distance = math.sqrt((math.pow((bonePos[1] - crosshairPos[1]), 2) + math.pow((bonePos[2] - crosshairPos[2]), 2)))
                    if distance < 1.0 or distance > 80.0 then check = true else check = false end
                    if not check then
                        local myPos = {getCharCoordinates(playerPed)}
                        local enPos = {getCharCoordinates(handle)}
                        local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                        if (distance < maxDistance) then
                            nearestPED = i
                            maxDistance = distance
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function Aimbot()
    if aim.CheckBox.enableAim[0] and isKeyDown(vKeys.VK_RBUTTON) then
        local handle = GetNearestPed(aim.Sliders.Fov[0])
        if handle ~= -1 then
            local myPos = {getActiveCameraCoordinates()}
            if aim.CheckBox.bone[0] == 0 then
                ednPos = {GetBodyPartCoordinates(6, handle)}
            elseif aim.CheckBox.bone[0] == 1 then
                ednPos = {GetBodyPartCoordinates(4, handle)}
            elseif aim.CheckBox.bone[0] == 2 then
                ednPos = {GetBodyPartCoordinates(3, handle)}
            end
            if aim.CheckBox.team[0] then
                if isLineOfSightClear(myPos[1], myPos[2], myPos[3], ednPos[1], ednPos[2], ednPos[3], aim.CheckBox.checkBuild[0], aim.CheckBox.checkVehicle[0], false, aim.CheckBox.checkObject[0], false) then
                    local vector = {myPos[1] - ednPos[1], myPos[2] - ednPos[2], myPos[3] - ednPos[3]}
                    if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                    local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                    local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                    local difference = {angle[1] - view[1], angle[2] - view[2]}
                    local smooth = {difference[1] / aim.Sliders.Smooth[0], difference[2] / aim.Sliders.Smooth[0]}
                    setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
                end
            else
                for i = 0, sampGetMaxPlayerId() do
                    if sampIsPlayerConnected(i) then
                        local result, handlePed = sampGetCharHandleBySampPlayerId(i)
                        local color_ped = sampGetPlayerColor(i)
                        if result and color_ped ~= sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
                            if isLineOfSightClear(myPos[1], myPos[2], myPos[3], ednPos[1], ednPos[2], ednPos[3], aim.CheckBox.checkBuild[0], aim.CheckBox.checkVehicle[0], false, aim.CheckBox.checkObject[0], false) then
                                local vector = {myPos[1] - ednPos[1], myPos[2] - ednPos[2], myPos[3] - ednPos[3]}
                                if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                                local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                                local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                                local difference = {angle[1] - view[1], angle[2] - view[2]}
                                local smooth = {difference[1] / aim.Sliders.Smooth[0], difference[2] / aim.Sliders.Smooth[0]}
                                setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

function msg(text)
    sampAddChatMessage("{BF3FFF}[VortexReborn]: {EAEAEA}"..text)
end

function imgui.ClickCopy(text)
	if imgui.IsItemClicked() then
		imgui.LogToClipboard()
		imgui.LogText(text)
		imgui.LogFinish()
	end
end

function GetBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function getDamage(weap)
	local damage = {
		[22] = 8.25,
		[23] = 13.2,
		[24] = 46.200000762939,
		[25] = 30,
		[26] = 30,
		[27] = 30,
		[28] = 6.6,
		[29] = 8.25,
		[30] = 9.9,
		[31] = 9.9000005722046,
		[32] = 6.6,
		[33] = 25,
		[38] = 46.2
	}
	return (damage[weap] or 0) + math.random(1e9)/1e15
end

function rand() return math.random(-50, 50) / 100 end

function getpx()
	return ((w / 2) / getCameraFov()) * aim.CheckBox.silentFov[0]
end

function getClosestPlayerFromCrosshair()
	local R1, target = getCharPlayerIsTargeting(0)
	local R2, player = sampGetPlayerIdByCharHandle(target)
	if R2 then return player, target end
	local minDist = getpx()
	local closestId, closestPed = -1, -1
	for i = 0, 999 do
		local res, ped = sampGetCharHandleBySampPlayerId(i)
		if res then
			if getDistanceFromPed(ped) < aim.CheckBox.silentMaxDist[0] then
                local xi, yi = convert3DCoordsToScreen(getCharCoordinates(ped))
                local dist = math.sqrt( (xi - xc) ^ 2 + (yi - yc) ^ 2 )
                if dist < minDist then
                    minDist = dist
                    closestId, closestPed = i, ped
                end
			end
		end
	end
	return closestId, closestPed
end

function getDistanceFromPed(ped)
	local ax, ay, az = getCharCoordinates(1)
	local bx, by, bz = getCharCoordinates(ped)
	return math.sqrt( (ax - bx) ^ 2 + (ay - by) ^ 2 + (az - bz) ^ 2 )
end

function canPedBeShot(ped)
	local ax, ay, az = convertScreenCoordsToWorld3D(xc, yc, 0)
	local bx, by, bz = getCharCoordinates(ped)
	return not select(1, processLineOfSight(ax, ay, az, bx, by, bz + 0.7, true, false, false, true, false, true, false, false))
end

function getcond(ped)
	if aim.CheckBox.silentShootWalls[0] then return true
	else return canPedBeShot(ped) end
end

function downloadFile(link, path, message)
    local dlstatus = require('moonloader').download_status
    downloadUrlToFile(link, path, function (id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
            if message then
                sampAddChatMessage(message, -1)
                print(message)
            end
        end
    end)
end

function autoupdate(json_url, prefix, url)
	local dlstatus = require('moonloader').download_status
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
	if doesFileExist(json) then os.remove(json) end
	downloadUrlToFile(json_url, json, function(id, status, p1, p2)
      	if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					updatelink = info.updateurl
					updateversion = info.latest
					f:close()
					os.remove(json)
					if updateversion == version_script then
						sampAddChatMessage(tag..(aim.CheckBox.lang_menu[0] and u8 "Koristite {00ff00}najnoviju {ffffff}verziju skripte. | Meni: {BF3FFF}F2" or 'You are using {00ff00}the current {ffffff}version of the script. | Menu: {BF3FFF}F2'), -1)
						print(aim.CheckBox.lang_menu[0] and u8 "Vortex Pr0ject: Nema potrebe za azuriranjem." or 'Vortex Pr0ject: No update required.')
						update = false
					elseif updateversion < version_script then
						--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "Koristite {F9D82F}probnu {ffffff}verziju skripte. | Menu: {BF3FFF}F2" or 'You are using {F9D82F}testing {ffffff}version of the script. | Menu: {BF3FFF}F2'), -1)]]
						update = false
					elseif updateversion > version_script then
						lua_thread.create(function(prefix)
							local dlstatus = require('moonloader').download_status
							--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "Azuriranje je dostupno. Instaliranje {0E8604}najnovije {ffffff}verzije" or 'An update is available. Downloading {0E8604}the latest {ffffff}version '..updateversion), -1)]]
							--[[print('Vortex Pr0ject: Update is available! Downloading the latest version '..updateversion)]]
							wait(250)
							downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23)
								if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
									--log('Downloading')
								elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
									--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "Instaliranje je gotovo. Skripta je azurirana na verziju " or 'The download is complete. The script has been updated to version '..updateversion), -1)]]
									--[[print('Vortex Pr0ject: Update is sucessfully downloaded, script version is now: '..updateversion)]]
									goupdatestatus = true
									lua_thread.create(function() wait(500) thisScript():reload() end)
								end
								if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
									if goupdatestatus == nil then
										--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "{B31A06}Neuspjesno {ffffff}azuriranje" or '{B31A06}Failed {ffffff}updating'), -1)]]
										update = false
									end
								end
							end)
						end, prefix)
					else
						--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "{B31A06}Neuspjesno {ffffff}cekiranje verzije skripte. | Meni: {BF3FFF}F2" or '{B31A06}Failed {ffffff}to check the version of the script. | Menu: {BF3FFF}F2'), -1)]]
						--[[print('Vortex Pr0ject: Update is unavailable, please check your internet or firewall.')]]
						update = false
					end
				end
			else
				--[[sampAddChatMessage(tag..(elements.checkbox.lang_menu.v and u8 "{B31A06}Neuspjesno {ffffff}cekiranje verzije skripte. | Meni: {BF3FFF}F2" or '{B31A06}Failed {ffffff}to check the version of the script. | Menu: {BF3FFF}F2'), -1)]]
				--[[print('Vortex Pr0ject: Update is unavailable, please check your internet or firewall.')]]
				update = false
			end
		end
	end)
	--while update ~= false do wait(100) end
end

function ev.onSendBulletSync(data)
    math.randomseed(os.clock())
    if not aim.CheckBox.silentAim[0] then return end
    local weap = getCurrentCharWeapon(PLAYER_PED)
    if not getDamage(weap) then return end
    local id, ped = getClosestPlayerFromCrosshair()
    if id == -1 then return end
    if math.random(1, 100) < aim.CheckBox.missRatio[0] then return end
    if not getcond(ped) then return end
    data.targetType = 1
    local px, py, pz = getCharCoordinates(ped)
    data.targetId = id

    data.target = { x = px + rand(), y = py + rand(), z = pz + rand() }
    data.center = { x = rand(), y = rand(), z = rand() }

    lua_thread.create(function()
         wait(1)
        sampSendGiveDamage(id, getDamage(weap), weap, 3)
    end)
end

function join_argb(a, r, g, b)
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

function iniLoad()
	mainIni = inicfg.load(nil, "VortexReborn.ini")
	if mainIni == nil then
		iniReset()
	else
		aim.Sliders.Smooth[0] = mainIni.Sliders.Smooth
        aim.Sliders.Fov[0] = mainIni.Sliders.Fov
        aim.Sliders.lagX[0] = mainIni.Sliders.lagX
        aim.Sliders.lagY[0] = mainIni.Sliders.lagY
        aim.Sliders.lagZ[0] = mainIni.Sliders.lagZ
        aim.Sliders.speedX[0] = mainIni.Sliders.speedX
        aim.Sliders.speedY[0] = mainIni.Sliders.speedY
        aim.Sliders.speedZ[0] = mainIni.Sliders.speedZ
        aim.Sliders.maxDistAim[0] = mainIni.Sliders.maxDistAim
        aim.Sliders.maxDistPro[0] = mainIni.Sliders.maxDistPro
        aim.CheckBox.noSpread[0] = mainIni.CheckBoxs.noSpread
        aim.CheckBox.autoshot[0] = mainIni.CheckBoxs.autoshot
        aim.CheckBox.wallhack[0] = mainIni.CheckBoxs.wallhack
        aim.CheckBox.line[0] = mainIni.CheckBoxs.line
        aim.CheckBox.box[0] = mainIni.CheckBoxs.box
        aim.CheckBox.nameTag[0] = mainIni.CheckBoxs.nameTag
        aim.CheckBox.distPed[0] = mainIni.CheckBoxs.distPed
        aim.CheckBox.noCamRestore[0] = mainIni.CheckBoxs.noCamRestore
        aim.CheckBox.antistun[0] = mainIni.CheckBoxs.antistun
        aim.CheckBox.fullSkill[0] = mainIni.CheckBoxs.fullSkill
        aim.CheckBox.noReload[0] = mainIni.CheckBoxs.noReload
        aim.CheckBox.plusC[0] = mainIni.CheckBoxs.plusC
        aim.CheckBox.CBUGHelper[0] = mainIni.CheckBoxs.CBUGHelper
        aim.CheckBox.noFall[0] = mainIni.CheckBoxs.noFall
        aim.CheckBox.checkBuild[0] = mainIni.CheckBoxs.checkBuild
        aim.CheckBox.checkVehicle[0] = mainIni.CheckBoxs.checkVehicle
        aim.CheckBox.checkObject[0] = mainIni.CheckBoxs.checkObject
        aim.CheckBox.bone[0] = mainIni.CheckBoxs.Bone
        aim.CheckBox.themes[0] = mainIni.CheckBoxs.themes
        aim.CheckBox.team[0] = mainIni.CheckBoxs.team
        aim.CheckBox.silentAim[0] = mainIni.CheckBoxs.silentAim
        aim.CheckBox.silentFov[0] = mainIni.CheckBoxs.silentFov
        aim.CheckBox.silentMaxDist[0] = mainIni.CheckBoxs.silentMaxDist
        aim.CheckBox.missRatio[0] = mainIni.CheckBoxs.missRatio
        aim.CheckBox.silentShootWalls[0] = mainIni.CheckBoxs.silentShootWalls
	end
end

function iniSave()
	inicfg.save({
		Sliders = {
			language = aim.Sliders.lang[0],
			Smooth = aim.Sliders.Smooth[0],
            Fov = aim.Sliders.Fov[0],
            lagX = aim.Sliders.lagX[0],
            lagY = aim.Sliders.lagY[0],
            lagZ = aim.Sliders.lagZ[0],
            speedX = aim.Sliders.speedX[0],
            speedY = aim.Sliders.speedY[0],
            speedZ = aim.Sliders.speedZ[0],
            maxDistAim = aim.Sliders.maxDistAim[0],
            maxDistPro = aim.Sliders.maxDistPro[0]
		}, CheckBoxs = {
            autoupdate = aim.CheckBox.autoupdate[0],
            noSpread = aim.CheckBox.noSpread[0],
            autoshot = aim.CheckBox.autoshot[0],
            wallhack = aim.CheckBox.wallhack[0],
            line = aim.CheckBox.line[0],
            box = aim.CheckBox.box[0],
            nameTag = aim.CheckBox.nameTag[0],
            distPed = aim.CheckBox.distPed[0],
            noCamRestore = aim.CheckBox.noCamRestore[0],
            antistun = aim.CheckBox.antistun[0],
            fullSkill = aim.CheckBox.fullSkill[0],
            noReload = aim.CheckBox.noReload[0],
            plusC = aim.CheckBox.plusC[0],
            CBUGHelper = aim.CheckBox.CBUGHelper[0],
            noFall = aim.CheckBox.noFall[0],
            checkBuild = aim.CheckBox.checkBuild[0],
            checkVehicle = aim.CheckBox.checkVehicle[0],
            checkObject = aim.CheckBox.checkObject[0],
            Bone = aim.CheckBox.bone[0],
            themes = aim.CheckBox.themes[0],
            team = aim.CheckBox.team[0],
            silentAim = aim.CheckBox.silentAim[0],
            silentFov = aim.CheckBox.silentFov[0],
            silentMaxDist = aim.CheckBox.silentMaxDist[0],
            missRatio = aim.CheckBox.missRatio[0],
            silentShootWalls = aim.CheckBox.silentShootWalls[0]
        }
	}, "VortexReborn.ini")
end

function iniReset()
    inicfg.save({
		Sliders = {
			language = 2,
			Smooth = 1,
            Fov = 1,
            lagX = 0,
            lagY = 0,
            lagZ = 0,
            speedX = 0,
            speedY = 0,
            speedZ = 0,
            maxDistAim = 30,
            maxDistPro = 300
		}, CheckBoxs = {
            autoupdate = true,
            noSpread = false,
            autoshot = false,
            wallhack = false,
            line = false,
            box = false,
            nameTag = false,
            distPed = false,
            noCamRestore = false,
            antistun = false,
            fullSkill = false,
            noReload = false,
            plusC = false,
            CBUGHelper = false,
            noFall = false,
            checkBuild = false,
            checkVehicle = false,
            checkObject = false,
            Bone = 1,
            themes = 0,
            team = true,
            silentAim = false,
            silentFov = 8,
            silentMaxDist = 120,
            missRatio = 0,
            silentShootWalls = false
        }
	}, "VortexReborn.ini")
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function HeaderButton(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end

function imgui.Link(label)

    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)

    imgui.SetCursorPos(p2)

    if imgui.IsItemHovered() then

        imgui.TextColored(imgui.ImVec4(0, 1, 1, 1), label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(0, 1, 0, 1))
    else
        imgui.TextColored(imgui.ImVec4(1, 0.15, 0.2, 1), label)
    end

    return result
end

function imgui.TextQuestion(text)
	local war = u8'Hint:'
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextColored(imgui.ImVec4(0.00, 0.69, 0.33, 1.00), war)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

function imgui.TextColoredRGB(string)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col

    local function color_imvec4(color)
        if color:upper() == 'SSSSSS' then return colors[clr.Text] end
        local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
        local rgb = {}
        for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
        return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
    end

    local function render_text(string)
        local text, color = {}, {}
        local m = 1
        while string:find('{......}') do
            local n, k = string:find('{......}')
            text[#text], text[#text+1] = string:sub(m, n-1), string:sub(k+1, #string)
            color[#color+1] = color_imvec4(string:sub(n+1, k-1))
            local t1, t2 = string:sub(1, n-1), string:sub(k+1, #string)
            string = t1..t2
            m = k-7
        end
        if text[0] then
            for i, _ in ipairs(text) do
                imgui.TextColored(color[i] or colors[clr.Text], u8(text[i]))
                imgui.SameLine(nil, 0)
            end
            imgui.NewLine()
        else imgui.Text(u8(string)) end
    end

    render_text(string)
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function themeOne()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Text] = ImVec4(0.860, 0.930, 0.890, 0.78)
    colors[clr.TextDisabled] = ImVec4(0.860, 0.930, 0.890, 0.28)
    colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
    colors[clr.ChildBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
    colors[clr.PopupBg] = ImVec4(0.200, 0.220, 0.270, 0.9)
    colors[clr.Border] = ImVec4(0.51, 0.51, 0.51, 0.90)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
    colors[clr.FrameBgActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
    colors[clr.TitleBg] = ImVec4(0.232, 0.201, 0.271, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.200, 0.220, 0.270, 0.75)
    colors[clr.MenuBarBg] = ImVec4(0.200, 0.220, 0.270, 0.47)
    colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.09, 0.15, 0.1, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
    colors[clr.CheckMark] = ImVec4(0.71, 0.22, 0.27, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.47, 0.77, 0.83, 0.14)
    colors[clr.SliderGrabActive] = ImVec4(0.71, 0.22, 0.27, 1.00)
    colors[clr.Button] = ImVec4(0.455, 0.198, 0.301, 0.76)
    colors[clr.ButtonHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
    colors[clr.ButtonActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
    colors[clr.Header] = ImVec4(0.455, 0.198, 0.301, 0.76)
    colors[clr.HeaderHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
    colors[clr.HeaderActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.47, 0.77, 0.83, 0.04)
    colors[clr.ResizeGripHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
    colors[clr.ResizeGripActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
    colors[clr.PlotLines] = ImVec4(0.860, 0.930, 0.890, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.860, 0.930, 0.890, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.455, 0.198, 0.301, 0.43)
    colors[clr.ModalWindowDimBg] = ImVec4(0.200, 0.220, 0.270, 0.73)
end

function themeTwo()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDimBg] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function themeThree()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
  
    colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
    colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
    colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
    colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
end

function themeFour()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    
    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildBg]                = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
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
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
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
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, config, iconRanges)
 
    if font24 == nil then
        font24 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 24.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
    if font20 == nil then
        font20 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
    if font18 == nil then
        font18 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end

    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 18.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 18.0, config, iconRanges)

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 15.0
    style.FramePadding = ImVec2(5, 5)
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 15.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildRounding = 15.0
    style.FrameRounding = 6.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)
	style.ButtonTextAlign = ImVec2(0.5, 0.5)

    themeOne()
end)
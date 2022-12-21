local PumpPrompt
local PumpPrompts = GetRandomIntInRange(0, 0xffffff)

local PumpScenarios = {
	'PROP_HUMAN_PUMP_WATER',
	'PROP_HUMAN_PUMP_WATER_BUCKET_MALE_A',
	'PROP_HUMAN_PUMP_WATER_FEMALE_B',
	'PROP_HUMAN_PUMP_WATER_MALE_A',
}

function SetPumpPrompt()
    local str = Config.Texts['Prompt']
    PumpPrompt = PromptRegisterBegin()
    PromptSetControlAction(PumpPrompt, Config.KeyPump)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(PumpPrompt, str)
    PromptSetEnabled(PumpPrompt, 1)
    PromptSetVisible(PumpPrompt, 1)
	PromptSetHoldMode(PumpPrompt, 1000)
	PromptSetGroup(PumpPrompt, PumpPrompts)
	PromptRegisterEnd(PumpPrompt)
end

Citizen.CreateThread(function() 
    SetPumpPrompt()            
    while true do
		local t = 500

		local DataStruct = DataView.ArrayBuffer(256 * 4)
		local scenarios = Citizen.InvokeNative(0x345EC3B7EBDE1CB5, GetEntityCoords(PlayerPedId()), 1.0, DataStruct:Buffer(), 10)	-- GetScenarioPointsInArea

		if scenarios then
            for i = 1, scenarios do
                local scenario = DataStruct:GetInt32(8 * i)
                local scenario_hash = Citizen.InvokeNative(0xA92450B5AE687AAF, scenario)	-- GetScenarioPointType

                for _, v in pairs(PumpScenarios) do
                    if GetHashKey(v) == scenario_hash and not active then
                        t = 4

                        local label  = CreateVarString(10, 'LITERAL_STRING', Config.Texts['ObjectPump'])
                        PromptSetActiveGroupThisFrame(PumpPrompts, label)
                        if PromptHasHoldModeCompleted(PumpPrompt) then
                            Citizen.Wait(500)
                            
                            local myInput = {
                                type = 'enableinput', -- don't touch
                                inputType = 'input', -- input type
                                button = Config.Texts['Button'], -- button name
                                placeholder =  Config.Texts['Quantity'], -- placeholder name
                                style = 'block', -- don't touch
                                attributes = {
                                    inputHeader = Config.Texts['PlaceHolder'], -- header
                                    type = 'number', -- inputype text, number,date,textarea ETC
                                    pattern = '[0-9]', --  only numbers '[0-9]' | for letters only '[A-Za-z]+' 
                                    title = Config.Texts['OnlyNumber'], -- if input doesnt match show this message
                                    style = 'border-radius: 10px; background-color: ; border:none;'-- style 
                                }
                            }
                            
                            TriggerEvent('vorpinputs:advancedInput', json.encode(myInput), function(num)
                                if num ~= '' and num and tonumber(num) > 0 then -- make sure its not empty or nil
                                    TriggerServerEvent('xakra_waterpump:CheckBottle', tonumber(num), scenario)
                                end
                            end)
                        end
                    end

                end
            end
        end

		Citizen.Wait(t)
    end
end)

RegisterNetEvent('xakra_waterpump:Pumping')
AddEventHandler('xakra_waterpump:Pumping', function(num, scenario)
	active = true

	TaskUseScenarioPoint(PlayerPedId(), scenario, '' , -1.0, true, false, 0, false, -1.0, true)

    local bottle
    local waterpump = Citizen.InvokeNative(0xE143FA2249364369, GetEntityCoords(PlayerPedId()), 1.0, GetHashKey('p_waterpump01x'), false, true, true)	-- GetClosestObjectOfType
    if waterpump then

        local bottle_coords = GetOffsetFromEntityInWorldCoords(waterpump, 0, -0.30, 0.0)
        bottle = CreateObject(GetHashKey('s_rc_poisonedwater01x'), bottle_coords, true, true, true)
    end
    
	local progressbar = exports.vorp_progressbar:initiate()
	progressbar.start(Config.Texts['Pumping'], 15000, function ()

		ClearPedTasks(PlayerPedId(), true)

		TriggerServerEvent('xakra_waterpump:AddWater', num)

        Wait(1000)

        if DoesEntityExist(bottle) then
            DeleteEntity(bottle)
        end

        active = false

	end, 'innercircle', Config.ProgressbarColor)

end)

RegisterNetEvent('xakra_waterpump:AnimWater')
AddEventHandler('xakra_waterpump:AnimWater', function(num)
	SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true, 0, false, false)

	local object = CreateObject(GetHashKey('s_rc_poisonedwater01x'), GetEntityCoords(PlayerPedId()), true, true, true)
    local bone = GetEntityBoneIndexByName(PlayerPedId(), 'MH_L_HandSide')
	AttachEntityToEntity(object, PlayerPedId(), bone, 0.03, -0.01, -0.03, 20.0, -0.0, 0.0, true, true, false, true, 1, true)

	local dict = 'mech_inventory@item@fallbacks@large_drink@left_handed'
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end

	TaskPlayAnim(PlayerPedId(), dict, 'use_quick_left_hand', 1.0, 1.0, -1, 31, 1, false, false, false, 0, true)
	Wait(4000)
    RemoveAnimDict(dict)
    ClearPedTasks(PlayerPedId())
    DetachEntity(object, true, true)
	SetEntityVelocity(object, 0.0,0.0,-1.0)
    Wait(20000)
    DeleteEntity(object)
end)

--########################### NOTIFY METABOLISM ###########################
local VORPcore = {}

TriggerEvent('getCore', function(core)
    VORPcore = core
end)

Citizen.CreateThread(function()         
    while Config.NotifyMetabolism do
		if not IsEntityDead(PlayerPedId()) then
			TriggerEvent('vorpmetabolism:getValue', 'Hunger', function(hunger)
				TriggerEvent('vorpmetabolism:getValue', 'Thirst', function(thirst)
					if hunger <= 100 then
						AnimpostfxPlay('MP_Trans_WinLose_Pulse')
						VORPcore.NotifyTip(Config.Texts['Hunger'], 30000)
					elseif thirst <= 100 then
						AnimpostfxPlay('PlayerHonorLevelGood')
						VORPcore.NotifyTip(Config.Texts['Thirst'], 30000)
					end
				end)
			end)
		end
		Citizen.Wait(30000)
	end
end)

--########################### STOP RESOURCE ###########################
AddEventHandler('onResourceStop', function (resourceName)
    ClearPedTasks(PlayerPedId())
end)

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
----------------- 		                	DATAVIEW FUNCTIONS				                  	-------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

local _strblob = string.blob or function(length)
    return string.rep('\0', math.max(40 + 1, length))
end

DataView = {
    EndBig = '>',
    EndLittle = '<',
    Types = {
        Int8 = { code = 'i1', size = 1 },
        Uint8 = { code = 'I1', size = 1 },
        Int16 = { code = 'i2', size = 2 },
        Uint16 = { code = 'I2', size = 2 },
        Int32 = { code = 'i4', size = 4 },
        Uint32 = { code = 'I4', size = 4 },
        Int64 = { code = 'i8', size = 8 },
        Uint64 = { code = 'I8', size = 8 },

        LuaInt = { code = 'j', size = 8 }, 
        UluaInt = { code = 'J', size = 8 }, 
        LuaNum = { code = 'n', size = 8}, 
        Float32 = { code = 'f', size = 4 },
        Float64 = { code = 'd', size = 8 }, 
        String = { code = 'z', size = -1, }, 
    },

    FixedTypes = {
        String = { code = 'c', size = -1, },
        Int = { code = 'i', size = -1, },
        Uint = { code = 'I', size = -1, },
    },
}
DataView.__index = DataView
local function _ib(o, l, t) return ((t.size < 0 and true) or (o + (t.size - 1) <= l)) end
local function _ef(big) return (big and DataView.EndBig) or DataView.EndLittle end
local SetFixed = nil
function DataView.ArrayBuffer(length)
    return setmetatable({
        offset = 1, length = length, blob = _strblob(length)
    }, DataView)
end
function DataView.Wrap(blob)
    return setmetatable({
        offset = 1, blob = blob, length = blob:len(),
    }, DataView)
end
function DataView:Buffer() return self.blob end
function DataView:ByteLength() return self.length end
function DataView:ByteOffset() return self.offset end
function DataView:SubView(offset)
    return setmetatable({
        offset = offset, blob = self.blob, length = self.length,
    }, DataView)
end
for label,datatype in pairs(DataView.Types) do
    DataView['Get' .. label] = function(self, offset, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            local v,_ = string.unpack(_ef(endian) .. datatype.code, self.blob, o)
            return v
        end
        return nil
    end

    DataView['Set' .. label] = function(self, offset, value, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            return SetFixed(self, o, value, _ef(endian) .. datatype.code)
        end
        return self
    end
    if datatype.size >= 0 and string.packsize(datatype.code) ~= datatype.size then
        local msg = 'Pack size of %s (%d) does not match cached length: (%d)'
        error(msg:format(label, string.packsize(fmt[#fmt]), datatype.size))
        return nil
    end
end
for label,datatype in pairs(DataView.FixedTypes) do
    DataView['GetFixed' .. label] = function(self, offset, typelen, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. 'c' .. tostring(typelen)
            local v,_ = string.unpack(code, self.blob, o)
            return v
        end
        return nil
    end
    DataView['SetFixed' .. label] = function(self, offset, typelen, value, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. 'c' .. tostring(typelen)
            return SetFixed(self, o, value, code)
        end
        return self
    end
end

SetFixed = function(self, offset, value, code)
    local fmt = { }
    local values = { }
    if self.offset < offset then
        local size = offset - self.offset
        fmt[#fmt + 1] = 'c' .. tostring(size)
        values[#values + 1] = self.blob:sub(self.offset, size)
    end
    fmt[#fmt + 1] = code
    values[#values + 1] = value
    local ps = string.packsize(fmt[#fmt])
    if (offset + ps) <= self.length then
        local newoff = offset + ps
        local size = self.length - newoff + 1

        fmt[#fmt + 1] = 'c' .. tostring(size)
        values[#values + 1] = self.blob:sub(newoff, self.length)
    end
    self.blob = string.pack(table.concat(fmt, ''), table.unpack(values))
    self.length = self.blob:len()
    return self
end

DataStream = { }
DataStream.__index = DataStream

function DataStream.New(view)
    return setmetatable({ view = view, offset = 0, }, DataStream)
end

for label,datatype in pairs(DataView.Types) do
    DataStream[label] = function(self, endian, align)
        local o = self.offset + self.view.offset
        if not _ib(o, self.view.length, datatype) then
            return nil
        end
        local v,no = string.unpack(_ef(endian) .. datatype.code, self.view:Buffer(), o)
        if align then
            self.offset = self.offset + math.max(no - o, align)
        else
            self.offset = no - self.view.offset
        end
        return v
    end
end
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
----------------- 									                                            ------------
-----------------		END OF DATAVIEW FUNCTIONS				                               	------------
----------------- 										                                        ------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


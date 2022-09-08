-- DrSpeedy#1852
-- https://github.com/DrSpeedy

local bPadHandlerEnabled = false
local iTickDelay = 16 -- Number of ticks allowed between button taps/switching from single press to hold
local iPadIdx = 2
local PadData = {}

local function GetKeyStatus(key)
    local vkey_arg = string.match(key, 'VK%((.-)%)')
    local is_vkey = vkey_arg ~= nil and true or false
    if (not is_vkey) then
        for i = 1, #KEYS[key] do
            local ctrl_id = KEYS[key][i].id
            if (PAD.IS_CONTROL_PRESSED(iPadIdx, ctrl_id) or PAD.IS_DISABLED_CONTROL_PRESSED(iPadIdx, ctrl_id)) then
                return 1
            end
            if (PAD.IS_CONTROL_RELEASED(iPadIdx, ctrl_id) or PAD.IS_DISABLED_CONTROL_RELEASED(iPadIdx, ctrl_id)) then
                return 2
            end
            return 0
        end
    else

        if (util.is_key_down(tonumber(vkey_arg))) then
            return 1
        else
            return 2
        end
        return 0
    end
end

function StartPadHandler()
	bPadHandlerEnabled = true
	-- initialize PadData table
	local initial_data = {
		bIsPressed = false,
		iTicksPressed = 0,
		iTicksSinceLastPress = 0,
		bIsLongHold = false,
		iTapCounter = 0,
		bIsSinglePress = false
	}

	for key, key_code in pairs(KEYS) do
		PadData[key] = initial_data
	end
	for k = 1, 255 do
		local vkey = 'VK(' .. k .. ')'
		PadData[vkey] = initial_data
	end

	util.create_tick_handler(function()
		for key, val in pairs(PadData) do
			if (GetKeyStatus(key) == 1) then
				local curtick = PadData[key].iTicksPressed
				local lasttick = PadData[key].iTicksSinceLastPress
				local tapcounter = PadData[key].iTapCounter
				local longhold = false

				if (curtick >= iTickDelay) then
					longhold = true
				end

				if (lasttick <= iTickDelay and not PadData[key].bIsPressed) then
					tapcounter = tapcounter + 1
				end

				if (lasttick > iTickDelay) then
					tapcounter = 0
				end

				PadData[key] = {
					bIsPressed = true,
					iTicksPressed = curtick + 1,
					iTicksSinceLastPress = 0,
					bIsLongHold = longhold,
					iTapCounter = tapcounter,
					bIsSinglePress = false
				}
			end

			if (GetKeyStatus(key) == 2) then
				local pressed = PadData[key].bIsPressed
				local curtick = PadData[key].iTicksPressed
				local lasttick = PadData[key].iTicksSinceLastPress
				local tapcounter = PadData[key].iTapCounter

				local singlepress = false
				if (pressed and curtick < iTickDelay) then
					singlepress = true
				end

				PadData[key] = {
					bIsPressed = false,
					iTicksPressed = 0,
					iTicksSinceLastPress = lasttick + 1,
					bIsLongHold = false,
					iTapCounter = tapcounter,
					bIsSinglePress = singlepress
				}
			end
		end
		return bPadHandlerEnabled
	end)
end

function PadMultiTapHold(key_index, taps)
	local data = PadData[key_index]
	return data.iTapCounter == taps and data.bIsLongHold
end

function PadSingleTapHold(key_index)
	local data = PadData[key_index]
	return data.bIsLongHold
end

function PadMultiTap(key_index, taps)
	local data = PadData[key_index]
	return data.iTapCounter == taps and data.bIsSinglePress
end

function PadSingleTap(key_index)
	local data = PadData[key_index]
	return data.bIsSinglePress
end

function StopPadHandler()
	bPadHandlerEnabled = false
	PadData = {}
end

-- New Hotness

function SplitString(source, delimiters)
    local elements = {}
    local pattern = '([^'..delimiters..']+)'
---@diagnostic disable-next-line: discard-returns
    string.gsub(source, pattern, function (value) elements[#elements+1] = value; end)
    return elements
end

function ParseCmdString(cmd_str)
    local cmds = SplitString(cmd_str:upper(), ':')
    local data = {}
    for i = 1, #cmds do
        local key = string.gsub(cmds[i], '%b[]', '')
        local args = string.match(cmds[i], '%[(.-)%]')
        local opcode = string.match(args, '(%a+)')
        local opargs = string.match(args, '(%d+)')
        data[i] = {
            KEY = key,
            OP = opcode,
            ARG = opargs ~= nil and opargs or 1
        }
    end
    return data
end

function CheckInput(cmd_str)
    local input = ParseCmdString(cmd_str)
    local results = {}
    for i = 1, #input do
        local data = input[i]
        local func_tbl = {
            --VK = string.match(data.KEY, 'VK%((.-)%)'),
            SEQ = string.match(data.KEY, 'SEQ%((.-)%)')
        }
        local op = data['OP']
        if (op == 'T') then
            results[i] = data.ARG > 1 and PadMultiTap(data.KEY, data.ARG) or PadSingleTap(data.KEY)
        elseif (op == 'H') then
            results[i] = data.ARG > 1 and PadMultiTapHold(data.KEY, data.ARG) or PadSingleTapHold(data.KEY)
        elseif (op == 'D') then
			results[i] = PadData[data.KEY].bIsPressed
        end

    end
    for i = 1, #results do
        if (results[i] == false) then
            return false
        end
    end
    return true
end
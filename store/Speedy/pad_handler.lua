local bPadHandlerEnabled = false
local PadData = {}

function StartPadHandler()
	bPadHandlerEnabled = true
	-- initialize PadData table
	for key, key_code in pairs(keys) do
		PadData[key] = {
			bIsPressed = false,
			iTicksPressed = 0,
			iTicksSinceLastPress = 0,
			bIsLongHold = false,
			iTapCounter = 0
		}
	end

	util.create_tick_handler(function()
		--util.draw_debug_text('PadHandler running')
		for key, key_code in pairs(keys) do
			if (PAD.IS_CONTROL_PRESSED(2, key_code)) then
				--util.draw_debug_text(key .. ' Pressed')
				local curtick = PadData[key].iTicksPressed
				local lasttick = PadData[key].iTicksSinceLastPress
				local tapcounter = PadData[key].iTapCounter
				local longhold = false
				if (curtick >= 10) then
					longhold = true
				end

				if (lasttick <= 10 and not PadData[key].bIsPressed) then
					tapcounter = tapcounter + 1
				end

				if (lasttick > 10) then
					tapcounter = 0
				end

				--util.draw_debug_text('' .. PadData[key].iTicksPressed)
				--util.draw_debug_text('Tap Counter: ' .. key .. ' ' .. PadData[key].iTapCounter)
				PadData[key] = {
					bIsPressed = true,
					iTicksPressed = curtick + 1,
					iTicksSinceLastPress = 0,
					bIsLongHold = longhold,
					iTapCounter = tapcounter
				}
			end

			if (PAD.IS_CONTROL_RELEASED(2, key_code)) then
				local lasttick = PadData[key].iTicksSinceLastPress
				local tapcounter = PadData[key].iTapCounter
				PadData[key] = {
					bIsPressed = false,
					iTicksPressed = 0,
					iTicksSinceLastPress = lasttick + 1,
					bIsLongHold = false,
					iTapCounter = tapcounter
				}
			end
		end
		return bPadHandlerEnabled
	end)
end

function PadKeyDown(key_index)
	return PadData[key_index].bIsPressed
end

function GetPadKeyTaps(key_index)
	return PadData[key_index].iTapCounter
end

function GetPadKeyLongHold(key_index)
	return PadData[key_index].bIsLongHold
end

function GetPadKeySinglePress(key_index)
	local data = PadData[key_index]
	return data.iTapCounter == 0 and data.bIsPressed
end

function StopPadHandler()
	bPadHandlerEnabled = false
	PadData = {}
end

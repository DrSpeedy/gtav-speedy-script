local bPadHandlerEnabled = false
local iTickDelay = 8
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
			iTapCounter = 0,
			bIsSinglePress = false
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

				if (curtick >= iTickDelay) then
					longhold = true
				end

				if (lasttick <= iTickDelay and not PadData[key].bIsPressed) then
					tapcounter = tapcounter + 1
				end

				if (lasttick > iTickDelay) then
					tapcounter = 0
				end

				--util.draw_debug_text('' .. PadData[key].iTicksPressed)
				--util.draw_debug_text('Tap Counter: ' .. key .. ' ' .. PadData[key].iTapCounter)
				PadData[key] = {
					bIsPressed = true,
					iTicksPressed = curtick + 1,
					iTicksSinceLastPress = 0,
					bIsLongHold = longhold,
					iTapCounter = tapcounter,
					bIsSinglePress = false
				}
			end

			if (PAD.IS_CONTROL_RELEASED(2, key_code)) then
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

function PadSingleHold(key_index)
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

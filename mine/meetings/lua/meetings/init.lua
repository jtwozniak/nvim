local uv = vim.loop

local M = {}

local timeout = 5000

function M.execute_command(command, callback)
  local pipe = uv.new_pipe(false)
  local stdio = { nil, pipe, nil }

  local process = uv.spawn("bash", {
    args = command,
    stdio = stdio
  }, function(code)
    if code ~= 0 then
      return
    end
    pipe:close()
  end)

  -- Processing stdout
  pipe:read_start(function(err, data)
    if err then
      return
    end
    if data then
      callback(data)
    end
  end)

  uv.unref(process)
end

function print_meetings(arg)
  local command = 'icalBuddy -nc -nrd -iep "title,datetime" eventsToday'
  if (arg ~= nil) then
    command = command .. "+" .. arg
  end
  M.execute_command({ "-c", command },
    function(data)
      vim.notify("\n" .. data, 'warn', { title = "Calendar", timeout = timeout })
    end
  )
end

local function stringToTimestamp(dateTimeString)
  local pattern = "(%d+)-(%d+)-(%d+) at (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = dateTimeString:match(pattern)
  if (year == nil) then
    return nil
  end
  return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

-- Function to split lines and extract title and timestamp
function M.parse_input(input)
  local events = {}
  local currentEvent = {}

  for line in input:gmatch("[^\r\n]+") do
    if #line > 0 then
      if line:match("%d%d%d%d%-%d%d%-%d%d") then -- Check if the line contains a date
        currentEvent.timestamp = stringToTimestamp(line)
        if (currentEvent.timestamp ~= nil) then
          table.insert(events, currentEvent)
        end
        currentEvent = {} -- Reset current event table
      else
        currentEvent.title = line
      end
    end
  end

  return events
end

function M.secondsToTime(milliseconds)
  -- Calculate seconds, minutes, and hours
  local seconds = math.floor(milliseconds) % 60
  local minutes = math.floor(milliseconds / (60)) % 60
  local hours = math.floor(milliseconds / (60 * 60))

  -- Format the time string
  local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

  return timeString
end

function M.diff_in_seconds(timestamp)
  local current = os.time()
  return timestamp - current
end

function M.format_seconds(seconds)
  return 'in ' .. M.secondsToTime(seconds)
end

function parsed_meetings(start, arg)
  local command =
  'icalBuddy -nc -ps "|\n|" -b "" -tf "%H:%M:%S" -df "%Y-%m-%d" -eed -nrd -iep "title,datetime" eventsToday'
  if (arg ~= nil) then
    command = command .. "+" .. arg
  end

  print_meetings(arg)
  M.execute_command(
    { "-c", command },
    function(data)
      local smallestTimestamp = 0

      local parsedEvents = M.parse_input(data)
      for _, event in ipairs(parsedEvents) do
        local secondsTo = M.diff_in_seconds(event.timestamp)

        vim.notify("\n" .. event.title .. "\n" .. M.format_seconds(secondsTo), 'warn',
          { title = "Meeting", timeout = timeout })

        if (smallestTimestamp == 0 or smallestTimestamp >= secondsTo) then
          smallestTimestamp = secondsTo
        end
      end

      if (smallestTimestamp ~= 0) then
        local halfTime = smallestTimestamp / 2;
        if (start) then
          M.setTimeout(halfTime * 1000, parsed_meetings)
          vim.notify("\n" .. "Next notification" .. "\n" .. M.format_seconds(halfTime), 'warn',
            { title = "Meeting", timeout = timeout })
        end
      end
    end
  )
end

-- Creating a simple setInterval wrapper
function M.setTimeout(timeout, callback)
  local timer = uv.new_timer()
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end

function M.setup(user_config)
  parsed_meetings(true, 1)
  vim.cmd [[
      command! -nargs=? ShowMeetings lua print_meetings(<f-args>)
      command! -nargs=? ShowParsed lua parsed_meetings(nil, <f-args>)
    ]]
end

return M

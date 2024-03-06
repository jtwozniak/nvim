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

local function toTimestamp(date, time)
  local start_time_str = date .. ' at ' .. time
  local pattern = "(%d+)-(%d+)-(%d+) at (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = start_time_str:match(pattern)
  return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

local function stringToTimestamp(dateTimeString)
  -- Extracting start and end times from the string
  local date_str = dateTimeString:match("(.+) at")
  local start_time_str = dateTimeString:match("at (.+) %-")
  local end_time_str = dateTimeString:match("- (.+)$")
  if (start_time_str == nil) then
    return nil
  end

  return {
    start = toTimestamp(date_str, start_time_str),
    stop = toTimestamp(date_str, end_time_str)
  }
end

-- Function to split lines and extract title and timestamp
function M.parse_input(input)
  local events = {}
  local currentEvent = {}

  for line in input:gmatch("[^\r\n]+") do
    if #line > 0 then
      if line:match("%d%d%d%d%-%d%d%-%d%d") then -- Check if the line contains a date
        currentEvent.timestamp = stringToTimestamp(line)
        currentEvent.timeline = line
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
  return {
    start = timestamp.start - current,
    stop = timestamp.stop - current
  }
end

function M.format_seconds(seconds)
  return 'in ' .. M.secondsToTime(seconds)
end

function format_event(event)
  local secondsTo = M.diff_in_seconds(event.timestamp)
  local when = ""
  if (secondsTo.start < 5) then
    when = 'Now!'
  elseif (secondsTo.start < 300) then
    when = 'in less then 5 minutes'
  else
    when = M.format_seconds(secondsTo.start)
  end

  return "\n" .. event.title ..
      "\n\t" .. event.timeline .. "\n\t" .. when
end

function event_action(event, startJob)
  local secondsTo = M.diff_in_seconds(event.timestamp)
  -- print(vim.inspect(secondsTo))
  -- print(vim.inspect(event))

  if (secondsTo.start > 0) then
    if (startJob) then
      local halfTime = secondsTo.start / 2;
      local meetingTimeout = timeout
      if (halfTime < 300) then
        halfTime = secondsTo.start - 300
      end
      if (halfTime < 0) then
        halfTime = secondsTo.start
        meetingTimeout = 1000 * halfTime
      end
      vim.notify(
        format_event(event),
        'warn',
        { title = "Meeting", timeout = meetingTimeout })

      M.setTimeout(halfTime * 1000, function() event_action(event, startJob) end)
    else
      vim.notify(format_event(event), 'warn',
        { title = "Meeting", timeout = timeout })
    end
  elseif (secondsTo.stop > 0) then
    vim.notify(format_event(event), 'warn',
      { title = "Meeting", timeout = secondsTo.stop * 1000 })
  end
end

function parsed_meetings(startJob, arg)
  local command =
  'icalBuddy -nc -ps "|\n|" -b "" -tf "%H:%M:%S" -df "%Y-%m-%d" -nrd -iep "title,datetime" eventsToday'
  if (arg ~= nil) then
    command = command .. "+" .. arg
  end

  M.execute_command(
    { "-c", command },
    function(data)
      local parsedEvents = M.parse_input(data)
      for _, event in ipairs(parsedEvents) do
        event_action(event, startJob);
      end
    end
  )
end

function parsed_meetings_command(arg)
  parsed_meetings(false, arg)
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
      command! -nargs=? ShowParsed lua parsed_meetings_command(<f-args>)
    ]]
end

return M

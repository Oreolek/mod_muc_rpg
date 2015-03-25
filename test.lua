local random=require"random"
r=random.new(os.time())

function roll (times, sides, bonus)
  local result = {}
  result.dice = {}
  bonus = bonus or 0

  for i = 1, times do
    result.dice[#result.dice + 1] = r(sides)
  end

  result.bonus = bonus

  return result
end

function printt(tab)
  for key,value in pairs(tab) do print(key,value) end
end

--message = io.read()
local times = 1
local sides = 20
local bonus = 0
message = string.gsub(message, 'D', 'd')
message = string.gsub(message, '^%s+', '')
message = string.gsub(message, '%s+$', '')
if string.match(message, '^%d+$') then
  printt(roll(1,tonumber(message),0))
  return
end
if not string.match(message, '^%s*d') then
  -- times != 1
  times = tonumber(string.match(message, '^(%d+)%s*d'))
end
if string.match(message, '+') then
  bonus = tonumber(string.match(message, '+%s*(%d+)'))
end
if string.match(message, '-') then
  bonus = -1 * tonumber(string.match(message, '-%s*(%d+)'))
end
sides = string.match(message, 'd%s*([0-9F]+)')
if string.match(sides, 'F') then
  sides = '3'
  bonus = bonus - (2 * times)
else
  sides = tonumber(sides)
end
if sides == nil then
  print "No sides?"
  return
end

print ("Times: ", times)
print ("Sides", sides)
print ("Bonus", bonus)

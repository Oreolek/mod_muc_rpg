-- Throw RPG dice in any room
-- By Alexander Yakovlev <keloero@oreolek.ru>
-- based on mod_muc_intercom by Kim Alvefur <zash@zash.se>

local host_session = prosody.hosts[module.host];
local jid = require "util.jid";
--local random = require"random"
--r=random.new(os.time())

local function get_room_by_jid(mod_muc, jid)
	if mod_muc.get_room_by_jid then
		return mod_muc.get_room_by_jid(jid);
	elseif mod_muc.rooms then
		return mod_muc.rooms[jid]; -- COMPAT 0.9, 0.10
	end
end

local function roll (times, sides, bonus)
  local result = {}
  result.dice = {}
  bonus = bonus or 0

  for i = 1, times do
    result.dice[#result.dice + 1] = math.random(sides)
  end

  result.bonus = bonus

  return result
end

local function parseroll(message)
  local result = {}
  result.times = 1
  result.sides = 20
  result.bonus = 0
  message = string.gsub(message, 'D', 'd')
  message = string.gsub(message, '^%s+', '')
  message = string.gsub(message, '%s+$', '')
  if string.match(message, '^%d+$') then
    result.sides = tonumber(message)
    return result
  end
  if not string.match(message, '^%s*d') then
    result.times = tonumber(string.match(message, '^(%d+)%s*d'))
  end
  if string.match(message, '+') then
    result.bonus = tonumber(string.match(message, '+%s*(%d+)'))
  end
  if string.match(message, '-') then
    result.bonus = -1 * tonumber(string.match(message, '-%s*(%d+)'))
  end
  result.sides = string.match(message, 'd%s*([0-9F]+)')
  if string.match(sides, 'F') then
    result.sides = '3'
    result.bonus = result.bonus - (2 * result.times)
  else
    sides = tonumber(sides)
  end
end

local function check_message(data)
	local stanza = data.stanza;
	local body = stanza:get_child("body");

  if not body then return; end -- No body, like topic changes
  if not (stanza.name == "message" and tostring(stanza.attr.type) == "groupchat") then return; end
	if not mod_muc then return; end

	local mod_muc = host_session.muc;
  data.stanza.body = "hello"
	body = body and body:get_text();
	if not string.match(body, '^%s*/roll%s') then return; end -- No command
	local message = body:match("^@([^:]+):(.*)");
	if not message then return; end

  stanza.body = body .. " rolled: "
  local result = roll(parseroll(message))

  local total = 0
  for i = 1, #result.dice do
    if i == 1 then
      stanza.body = stanza.body .. result.dice[i]
    else
      stanza.body = stanza.body .. "," .. result.dice[i]
    end
    total = total + result.dice[i]
  end
  total = total + result.bonus
  data.stanza.body = stanza.body .. ", total: " .. total
end

module:hook("message/bare", check_message, 10);

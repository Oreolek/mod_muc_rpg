-- Throw RPG dice in any room
-- By Alexander Yakovlev <keloero@oreolek.ru>
-- based on mod_muc_intercom by Kim Alvefur <zash@zash.se>

local host_session = prosody.hosts[module.host];
local st_msg = require "util.stanza".message;
local jid = require "util.jid";
local random=require"random"
r=random.new(os.time())

local function get_room_by_jid(mod_muc, jid)
	if mod_muc.get_room_by_jid then
		return mod_muc.get_room_by_jid(jid);
	elseif mod_muc.rooms then
		return mod_muc.rooms[jid]; -- COMPAT 0.9, 0.10
	end
end

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

function parseroll(message)
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

function check_message(data)
	local origin, stanza = data.origin, data.stanza;
	local mod_muc = host_session.muc;
	if not mod_muc then return; end

	local this_room = get_room_by_jid(mod_muc, stanza.attr.to);
	if not this_room then return; end -- no such room

	local from_room_jid = this_room._jid_nick[stanza.attr.from];
	if not from_room_jid then return; end -- no such nick

	local from_room, from_host, from_nick = jid.split(from_room_jid);

	local body = stanza:get_child("body");
	if not body then return; end -- No body, like topic changes
	body = body and body:get_text();
	if not string.match(body, '^%s*/roll%s') then return; end -- No command
	local message = body:match("^@([^:]+):(.*)");
	if not message then return; end

  local forward_stanza = st_msg({from = sender, to = this_room, type = "groupchat"}, message);

	this_room:broadcast_message(forward_stanza);
end

module:hook("message/bare", check_message, 10);

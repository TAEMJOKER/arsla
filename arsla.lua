--[[                                    Dev   
   _____    _        _    _    _____    Dev  @lkoko
  |_   _|__| |__    / \  | | _| ____|   Dev   @lkoko
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @lkoko
    | |\__ \ | | |/ ___ \|   <| |___    Dev @lkoko
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lkoko
              CH > @QD_QQ
--]]
serpent = require('serpent')
serp = require 'serpent'.block
http = require("socket.http")
config2 = dofile('libs/serpant.lua') 
https = require("ssl.https")
http.TIMEOUT = 10
lgi = require ('lgi')
arsla=dofile('utils.lua')
json=dofile('json.lua')
JSON = (loadfile  "./libs/dkjson.lua")()
redis = (loadfile "./libs/JSON.lua")()
redis = (loadfile "./libs/redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
tdcli = dofile('tdcli.lua')
notify.init ("Telegram updates")
sudos = dofile('sudo.lua')
chats = {}
day = 86400

  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
  if msg.sender_user_id_ == v then
  var = true
  end
end
  local keko_add_sudo = redis:get('sudoo'..msg.sender_user_id_..''..bot_id)
  if keko_add_sudo then
  var = true
  end
   return var
  end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if admin then
      var = true
   end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	local hashsss =  'bot:vipgp:'..chat_id
    local vip = database:sismember(hashsss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
	 if vip then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if owner then
      var = true
   end
   if admin then
      var = true
   end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end

-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gbanned(user_id)
  local var = false
  local hash = 'bot:gbanned:'
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gmuted(user_id, chat_id)
    local var = false
	local hash = 'bot:gmuted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function get_info(user_id)
  if database:hget('bot:username',user_id) then
    text = '@'..(string.gsub(database:hget('bot:username',user_id), 'false', '') or '')..''
  end
  get_user(user_id)
  return text
  --db:hrem('bot:username',user_id)
end
function get_user(user_id)
  function dl_username(arg, data)
    username = data.username or ''

    --vardump(data)
    database:hset('bot:username',data.id_,data.username_)
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_username, nil)
end
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_vip(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
os.execute('cd .. &&  rm -fr ../.telegram-cli')
os.execute('cd .. &&  rm -rf ../.telegram-cli')
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end

  local function deleteMessagesFromUser(chat_id, user_id, cb, cmd)
    tdcli_function ({
      ID = "DeleteMessagesFromUser",
      chat_id_ = chat_id,
      user_id_ = user_id
    },cb or dl_cb, cmd) 
  end 
os.execute('cd .. &&  rm -rf .telegram-cli')
os.execute('cd .. &&  rm -fr .telegram-cli')
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
if not config2 then 
os.execute('cd .. &&  rm -rf arsla')
os.execute('cd .. &&  rm -rf arslaapi')
os.execute('cd .. &&  rm -fr arsla')
os.execute('cd .. &&  rm -fr arslaapi')
print(config2.tss)
 return false end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delmsg(arg,data)
  for k,v in pairs(data.messages_) do
    delete_msg(v.chat_id_,{[0] = v.id_})
  end
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    channel_get_bots(channel,get_bots)
end

  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    -------------* EXPIRE *-----------------
    if not database:get("bot:charge:"..msg.chat_id_) then
     if database:get("bot:enable:"..msg.chat_id_) then
      database:del("bot:enable:"..msg.chat_id_)
      for k,v in pairs(sudo_users) do
      end
      end
    end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§ÙØ¯Ù` ð: *'..msg.sender_user_id_..'* \n`ÙÙØª Ø¨Ø¹ÙÙ ØªÙØ±Ø§Ø± ÙÙØ±Ø³Ø§Ø¦Ù Ø§ÙÙØ­Ø¯Ø¯Ù` â ï¸\n`ÙØªÙ Ø­Ø¸Ø±Ù ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù` â', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:warn'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:warn'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:muted:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§ÙØ¯Ù` ð: *'..msg.sender_user_id_..'* \n`ÙÙØª Ø¨Ø¹ÙÙ ØªÙØ±Ø§Ø± ÙÙØ±Ø³Ø§Ø¦Ù Ø§ÙÙØ­Ø¯Ø¯Ù` â ï¸\n`ÙØªÙ ÙØªÙÙ ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù` â', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:del'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:del'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
                           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§ÙØ¯Ù` ð: *'..msg.sender_user_id_..'* \n`ÙÙØª Ø¨Ø¹ÙÙ ØªÙØ±Ø§Ø± ÙÙØ±Ø³Ø§Ø¦Ù Ø§ÙÙØ­Ø¯Ø¯Ù` â ï¸\n`ÙØªÙ ÙØ³Ø­ ÙÙ Ø±Ø³Ø§Ø¦ÙÙ` â', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("Send INLINE KEYBOARD")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("SEND TEXT")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("SEND PHOTO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD TO GROUP")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("JOIN TO GROUP")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("SEND STICKER")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("SEND MUSIC")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("SEND VOICE")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("SEND VIDEO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("SEND GIF")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("SEND LOCATION")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("SEND CONTACT")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_gbanned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
          delete_msg(chat,msgs)
		  return 
end
if database:get('bot:muteall'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end

if database:get('bot:muteallwarn'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ³Ø§Ø¦Ø· ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
        return 
end

if database:get('bot:muteallban'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ³Ø§Ø¦Ø· ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â ï¸", 1, 'html')
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:warn'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, "â¢ `Ø§ÙØ§ÙØ¯Ù ` ð: _"..msg.sender_user_id_.."_\nâ¢ `Ø§ÙÙØ¹Ø±Ù ` ð¹ : "..get_info(msg.sender_user_id_).."\nâ¢ `Ø§ÙØªØ«Ø¨ÙØª ÙÙÙÙÙ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø§ÙØªØ«Ø¨ÙØª Ø­Ø§ÙÙØ§` â ï¸", 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ Ø¨Ø§Ø±Ø³Ø§Ù Ø§ÙÙÙØ´ÙØ± ÙÙ Ø§ÙÙÙØ§Ø©` âï¸', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, 'â¢ <code>Ø¹Ø¯Ø¯ Ø§ÙÙØ´Ø§ÙØ¯Ø§Øª </code>: âï¸\nâ¢ '..msg.views_..' ', 1, 'html')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:photo:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
		   chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØ± ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â ï¸", 1, 'html')

          return 
   end
        if database:get('bot:photo:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØ± ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
        end
        end
end
   elseif msg.content_.ID == 'MessageDocument' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:document:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:document:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:document:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end

  elseif msg_type == 'MSG:MarkDown' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:markdown:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:markdown:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ§Ø±ÙØ¯ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:markdown:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ§Ø±ÙØ¯ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
 end
 
  elseif msg_type == 'MSG:Inline' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:inline:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ§ÙÙØ§ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:inline:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ§ÙÙØ§ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:sticker:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØµÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:sticker:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØµÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} ð'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} ð'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:contact:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:contact:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:music:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ§ØºØ§ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:music:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ§ØºØ§ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:voice:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØªÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:voice:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØªÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:location:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ´Ø¨ÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:location:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ´Ø¨ÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:video:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØ¯ÙÙÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:video:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "<code>Ø§ÙØ¯ÙÙ : </code><code>"..msg.sender_user_id_.."</code>\n<code>Ø§ÙÙÙØ¯ÙÙÙØ§Øª ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code>", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:gifs:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:gifs:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link' and is_mod(msg.sender_user_id_, msg.chat_id_) then if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then 	 local glink = text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") local hash = "bot:group:link"..msg.chat_id_ database:set(hash,glink) 			 send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md') send(msg.chat_id_, 0, 1, '<b>New Group link:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or 
text:match("[Tt].[Mm][Ee]") or
text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
       if database:get('bot:links:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ï¿½ï¿½ï¿½ï¿½ : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ±ÙØ§Ø¨Ø· ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
  end
       if database:get('bot:links:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ±ÙØ§Ø¨Ø· ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
	end
 end

            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:mute'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
              end
          end 
          
            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam:warn'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:warn'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØ§ÙØ´ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
              end
          end 

	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:text:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ¯Ø±Ø¯Ø´Ù ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:text:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ¯Ø±Ø¯Ø´Ù ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
end
end
if msg.forward_info_ then
if database:get('bot:forward:ban'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØªÙØ¬ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
	end
   end

if msg.forward_info_ then
if database:get('bot:forward:warn'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØªÙØ¬ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
	end
   end
end
elseif msg_type == 'MSG:Text' then
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:tag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ¹Ø±ÙØ§Øª <@> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:tag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØ¹Ø±ÙØ§Øª <@> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
 end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:hashtag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØªØ§ÙØ§Øª <#> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:hashtag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØªØ§ÙØ§Øª <#> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
end

   	if text:match("/") then
      if database:get('bot:cmd:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end 
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
      if database:get('bot:cmd:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ´Ø§Ø±Ø­Ù </> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
	end 
	      if database:get('bot:cmd:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙØ´Ø§Ø±Ø­Ù </> ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
	end 
	end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:webpage:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØ§ÙØ¹ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:webpage:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙÙØ§ÙØ¹ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
 end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:arabic:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:arabic:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
 end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
	          if database:get('bot:english:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸\nâ¢ <code>ØªÙ Ø·Ø±Ø¯Ù</code> â", 1, 'html')
          return 
   end
   
        if database:get('bot:english:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "â¢ <code>Ø§ÙØ§ÙØ¯Ù ð : </code><code>"..msg.sender_user_id_.."</code>\nâ¢ <code>Ø§ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ ØªÙ ÙÙÙÙØ§ ÙÙÙÙØ¹ Ø§Ø±Ø³Ø§ÙÙØ§</code> â ï¸â", 1, 'html')
          return 
   end
     end
    end
   end
  if database:get('bot:cmds'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
  return 
else

if text == 'ÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end

if text == 'ØªØ´Ø§ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´ÙÙÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´ÙÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØªÙØ§Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙØ§Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ§Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø¨ÙØª' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§Ø±ÙØ¯ Ø§ÙØ¨Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØªØ²Ø­Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙØ®Ø±Ø§' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø²Ø§Ø­Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø¯Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ±Ø®' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØªØ¹Ø§ÙÙ Ø®Ø§Øµ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙØ±ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§Ø­Ø¨Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø¨Ø§Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ§ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙ Ø§ÙÙØ¯ÙØ±' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙØ¬Ø¨' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØªØ­Ø¨ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð³' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð¶ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØµØ¨Ø§Ø­Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØµØ¨Ø§Ø­ Ø§ÙØ®ÙØ±' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙØ§' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´Ø³ÙØ¬' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´Ø³ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ³Ø§Ø¡ Ø§ÙØ®ÙØ±' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙÙØ¯Ø±Ø³Ù' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙ Ø¯ÙØ­Ø°Ù Ø±Ø³Ø§Ø¦ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙØ¨ÙØª ÙØ§ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ØºÙØ³' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø­Ø§Ø±Ø©' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ð¹' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ§ÙÙ ÙØºÙØ©' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ§ÙÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙÙ Ø§Ø­Ø¯' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÙØ¯ÙØª' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø´ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§Ø­Ø¨Ø¬' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ø§ÙØªØ© ÙÙÙ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ""
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[Ll][Ee][Aa][Vv][Ee]$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
    
	if text:match("^ÙØºØ§Ø¯Ø±Ù$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('Ø±ÙØ¹ Ø§Ø¯ÙÙ','setmote')
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ` âï¸', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ` âï¸', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as moderator.!</code>'
          else
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ</code> âï¸'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as moderator._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apmd[2]..'* `ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ` âï¸', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ØªÙØ²ÙÙ Ø§Ø¯ÙÙ','remmote')
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ` â ï¸', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ` â ï¸', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ</code> â ï¸'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apmd[2]..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ` â ï¸', 1, 'md')
  end
  end
  -----------------------------------------------------------------------------------------------

        local text = msg.content_.text_:gsub('Ø±ÙØ¹ Ø¹Ø¶Ù ÙÙÙØ²','setvip')
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø±ÙØ¹Ù Ø¹Ø¶Ù ÙÙÙØ²` âï¸', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø±ÙØ¹Ù Ø¹Ø¶Ù ÙÙÙØ²` âï¸', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:vipgp:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as vip.!</code>'
          else
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø±ÙØ¹Ù Ø¹Ø¶Ù ÙÙÙØ²</code> âï¸'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) (%d+)$")} 	
	        database:sadd('bot:vipgp:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as vip._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apmd[2]..'* `ØªÙ Ø±ÙØ¹Ù Ø¹Ø¶Ù ÙÙÙØ²` âï¸', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ØªÙØ²ÙÙ Ø¹Ø¶Ù ÙÙÙØ²','remvip')
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted vip._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ` â ï¸', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted vip._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ` â ï¸', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted vip</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ</code> â ï¸'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted vip._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apmd[2]..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ` â ï¸', 1, 'md')
  end
  end
  
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø­Ø¸Ø±','Ban')
	if text:match("^[Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Banned._', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø­Ø¸Ø±Ù` â ï¸', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Banned._', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø­Ø¸Ø±Ù` â ï¸', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) @(.*)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Banned.!</b>'
else
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø­Ø¸Ø±Ù</code> â ï¸'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) (%d+)$")}
	if is_mod(apba[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, apba[2])
		 chat_kick(msg.chat_id_, apba[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Banned._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apba[2]..'* `ØªÙ Ø­Ø¸Ø±Ù` â ï¸', 1, 'md')
  	end
	end
end
  ----------------------------------------------unban--------------------------------------------
          local text = msg.content_.text_:gsub('Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±','unban')
  	if text:match("^[Uu][Nn][Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success) 
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Banned._', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù` âï¸', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Unbanned._', 1, 'md')
       else
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù` âï¸', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) @(.*)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Unbanned.!</b>'
      else
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù</code> âï¸'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, apba[2])
        if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Unbanned._', 1, 'md')
else
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apba[2]..'* `ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù` âï¸', 1, 'md')
end
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø­Ø°Ù Ø§ÙÙÙ','delall')
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function delall_by_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø°Ù Ø±Ø³Ø§Ø¦Ù Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
else
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..result.sender_user_id_..'* _Has been deleted!!_', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø­Ø°Ù ÙÙ Ø±Ø³Ø§Ø¦ÙÙ` â ï¸', 1, 'md')
end
		     del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
		local ass = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) (%d+)$")} 
	if is_mod(ass[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø°Ù Ø±Ø³Ø§Ø¦Ù Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
else
	 		     del_all_msgs(msg.chat_id_, ass[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..ass[2]..'* _Has been deleted!!_', 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..ass[2]..'* `ØªÙ Ø­Ø°Ù ÙÙ Ø±Ø³Ø§Ø¦ÙÙ` â ï¸', 1, 'md')
end    end
	end
 -----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apbll = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) @(.*)$")} 
	function delall_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø°Ù Ø±Ø³Ø§Ø¦Ù Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
return false
    end
		 		     del_all_msgs(msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>All Msg From user</b> <code>'..result.id_..'</code> <b>Deleted!</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø­Ø°Ù ÙÙ Ø±Ø³Ø§Ø¦ÙÙ</code> â ï¸'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apbll[2],delall_by_username)
    end
  -----------------------------------------banall--------------------------------------------------
          local text = msg.content_.text_:gsub('Ø­Ø¸Ø± Ø¹Ø§Ù','banall')
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
	if is_admin(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª ÙØ§ÙÙØ·ÙØ±ÙÙ Ø¹Ø§Ù â ï¸â', 1, 'md')
end
    else
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Banned !</b>'
                else
                  texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.sender_user_id_..'<code> ØªÙ Ø­Ø¸Ø±Ù Ø¹Ø§Ù</code> â ï¸'
end
end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function gban_by_username(extra, result, success)
              if result.id_ then
         	if is_admin(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª ÙØ§ÙÙØ·ÙØ±ÙÙ Ø¹Ø§Ù â ï¸â', 1, 'md')
end
  else
              local hash = 'bot:gbanned:'
                if database:get('lang:gp:'..msg.chat_id_) then
                texts = '<b>User :</b> <code>'..result.id_..'</code> <b> Has been Globally Banned !</b>'
              else 
                texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø­Ø¸Ø±Ù Ø¹Ø§Ù</code> â ï¸'
end
                database:sadd(hash, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else
                  texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
                end
            end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apbll[2],gban_by_username)
          end
          
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
  local hash = 'bot:gbanned:'
	if is_admin(apbll[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø¸Ø± Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª ÙØ§ÙÙØ·ÙØ±ÙÙ Ø¹Ø§Ù â ï¸â', 1, 'md')
end
    else
	        database:sadd(hash, apbll[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apbll[2]..'* _Has been Globally Banned _', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apbll[2]..'* `ØªÙ Ø­Ø¸Ø±Ù Ø¹Ø§Ù` â ï¸', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø§ÙØºØ§Ø¡ Ø§ÙØ¹Ø§Ù','unbanall')
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Unbanned !</b>'
             else
                  texts =  'â¢ <code>Ø§ÙØ¹Ø¶Ù '..result.sender_user_id_..' ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù ÙÙ Ø§ÙØ¹Ø§Ù </code> âï¸'
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apid = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function ungban_by_username(extra, result, success)
              local hash = 'bot:gbanned:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                 texts = '<b>User :</b> '..result.id_..' <b>Has been Globally Unbanned !</b>'
                else
                texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù ÙÙ Ø§ÙØ¹Ø§Ù</code> âï¸'
                end
                database:srem(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else 
                  texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
                        end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apid[2],ungban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
            local hash = 'bot:gbanned:'
              database:srem(hash, apbll[2])
              if database:get('lang:gp:'..msg.chat_id_) then
              texts = '<b>User :</b> '..apbll[2]..' <b>Has been Globally Unbanned !</b>'
            else 
                texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..apbll[2]..'<code> ØªÙ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø±Ù ÙÙ Ø§ÙØ¹Ø§Ù</code> âï¸'
end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØªÙ','silent')
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙØ§ ØªØ³ØªØ·ÙØ¹ ÙØªÙ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡` â ï¸â', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already silent._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ ÙØªÙÙ` â ï¸', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _silent_', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ ÙØªÙÙ` â ï¸', 1, 'md')
end
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙØ§ ØªØ³ØªØ·ÙØ¹ ÙØªÙ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡` â ï¸â', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>silent</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ ÙØªÙÙ</code> â ï¸'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")}
	if is_mod(apsi[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙØ§ ØªØ³ØªØ·ÙØ¹ ÙØªÙ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡` â ï¸â', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _silent_', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apsi[2]..'* `ØªÙ ÙØªÙÙ` â ï¸', 1, 'md')
end
	end
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø§ÙØºØ§Ø¡ ÙØªÙ','unsilent')
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not silent._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø§ÙØºØ§Ø¡ ÙØªÙÙ` âï¸', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _unsilent_', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø§ÙØºØ§Ø¡ ÙØªÙÙ` âï¸', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>unsilent.!</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø§ÙØºØ§Ø¡ ÙØªÙÙ</code> âï¸'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _unsilent_', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apsi[2]..'* `ØªÙ Ø§ÙØºØ§Ø¡ ÙØªÙÙ` âï¸', 1, 'md')
end
  end
    -----------------------------------------------------------------------------------------------
    local text = msg.content_.text_:gsub('Ø·Ø±Ø¯','kick')
  if text:match("^[Kk][Ii][Cc][Kk]$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø·Ø±Ø¯ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡` â ï¸â', 1, 'md')
end
  else
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Kicked.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` '..result.sender_user_id_..' `ØªÙ Ø·Ø±Ø¯Ù` â ï¸', 1, 'md')
end
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
  end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) @(.*)$")} 
	function kick_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø·Ø±Ø¯ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
    else
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Kicked.!</b>'
else
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø·Ø±Ø¯Ù</code> â ï¸'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apki[2],kick_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) (%d+)$")}
	if is_mod(apki[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'â¢ ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø·Ø±Ø¯ Ø§ÙØ§Ø¯ÙÙÙÙ ÙØ§ÙÙØ¯Ø±Ø§Ø¡ â ï¸â', 1, 'md')
end
    else
		 chat_kick(msg.chat_id_, apki[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apki[2]..'* _Kicked._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apki[2]..'* `ØªÙ Ø·Ø±Ø¯Ù` â ï¸', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
 local text = msg.content_.text_:gsub('Ø§Ø¶Ø§ÙÙ','invite')
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee]$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
   function inv_reply(extra, result, success)
    add_user(result.chat_id_, result.sender_user_id_, 5)
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Add it.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` '..result.sender_user_id_..' `ØªÙ Ø§Ø¶Ø§ÙØªÙ ÙÙÙØ¬ÙÙØ¹Ù` âï¸', 1, 'md')
   end
   end
    getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
   end
          -----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] @(.*)$") and is_sudo(msg) then
    local apss = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) @(.*)$")}
    function invite_by_username(extra, result, success)
     if result.id_ then
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Add it!</b>'
else
            texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø§Ø¶Ø§ÙØªÙ ÙÙÙØ¬ÙÙØ¹Ù</code> âï¸'
end
    add_user(msg.chat_id_, result.id_, 5)
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
            texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
    resolve_username(apss[2],invite_by_username)
 end
        -----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] (%d+)$") and is_sudo(msg) then
      local apee = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) (%d+)$")}
      add_user(msg.chat_id_, apee[2], 5)
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apee[2]..'* _Add it._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apee[2]..'* `ØªÙ Ø§Ø¶Ø§ÙØªÙ ÙÙÙØ¬ÙÙØ¹Ù` âï¸', 1, 'md')
  	end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø±ÙØ¹ ÙØ¯ÙØ±','setowner')
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Owner._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø±ÙØ¹Ù ÙØ¯ÙØ±` âï¸', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Promoted as Group Owner._', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø±ÙØ¹Ù ÙØ¯ÙØ±` âï¸', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Promoted as Group Owner.!</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø±ÙØ¹Ù ÙØ¯ÙØ±</code> âï¸'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, apow[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Promoted as Group Owner._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apow[2]..'* `ØªÙ Ø±ÙØ¹Ù ÙØ¯ÙØ±` âï¸', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ØªÙØ²ÙÙ ÙØ¯ÙØ±','remowner')
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Owner._', 1, 'md')
    else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡` â ï¸', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from ownerlist._', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡` â ï¸', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	local hash = 'bot:owners:'..msg.chat_id_
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from ownerlist</b>'
     else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡</code> â ï¸'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
         database:srem(hash, apow[2])
	     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Removed from ownerlist._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..apow[2]..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡` â ï¸', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
	          local text = msg.content_.text_:gsub('Ø±ÙØ¹ Ø§Ø¯ÙÙ ÙÙØ¨ÙØª','setadmin')
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:' 
	if database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ ÙÙØ¨ÙØª` âï¸', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Added to admins._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ ÙÙØ¨ÙØª` âï¸', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Added to admins.!</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ ÙÙØ¨ÙØª</code> âï¸'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
	        database:sadd('bot:admins:', ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* _Added to admins._', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..ap[2]..'* `ØªÙ Ø±ÙØ¹Ù Ø§Ø¯ÙÙ ÙÙØ¨ÙØª` âï¸', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ØªÙØ²ÙÙ Ø§Ø¯ÙÙ ÙÙØ¨ÙØª','remadmin')
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª` â ï¸', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from Admins!._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..result.sender_user_id_..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª` â ï¸', 1, 'md')

end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from Admins!</b>'
          else 
                        texts = 'â¢ <code>Ø§ÙØ¹Ø¶Ù </code>'..result.id_..'<code> ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª</code> â ï¸'
end
          else 
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>Ø®Ø·Ø§ </code>â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
         database:srem(hash, ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* Removed from Admins!_', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ¹Ø¶Ù` *'..ap[2]..'* `ØªÙ ØªÙØ²ÙÙÙ ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª` â ï¸', 1, 'md')
end
    end 
	-----------------------------------------------------------------------------------------------
	if text:match("^[Mm][Oo][Dd][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙØ§Ø¯ÙÙÙÙ$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Mod List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ </code>â¬ï¸ :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ Ø§Ø¯ÙÙÙÙ</code> â ï¸"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

	if text:match("^[Vv][Ii][Pp][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:vipgp:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Vip List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ </code>â¬ï¸ :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Vip List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ Ø§Ø¹Ø¶Ø§Ø¡ ÙÙÙØ²ÙÙ</code> â ï¸"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end

	if text:match("^[Bb][Aa][Dd][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>bad List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙÙÙÙØ§Øª Ø§ÙÙÙÙÙØ¹Ù </code>â¬ï¸ :\n\n"
  end    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>bad List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙÙÙØ§Øª ÙÙÙÙØ¹Ù</code> â ï¸"
end
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end 
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙÙÙØªÙÙÙÙ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Silent List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙÙÙØªÙÙÙÙ </code>â¬ï¸ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙÙØªÙÙÙÙ</code> â ï¸"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Oo][Ww][Nn][Ee][Rr][Ss]$") and is_sudo(msg) or text:match("^[Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^Ø§ÙÙØ¯Ø±Ø§Ø¡$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>owner List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡ </code>â¬ï¸ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>owner List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙØ¯Ø±Ø§Ø¡</code> â ï¸"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙÙØ­Ø¸ÙØ±ÙÙ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>ban List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙÙØ­Ø¸ÙØ±ÙÙ </code>â¬ï¸ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>ban List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙØ­Ø¸ÙØ±ÙÙ</code> â ï¸"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

  if msg.content_.text_:match("^[Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or msg.content_.text_:match("^ÙØ§Ø¦ÙÙ Ø§ÙØ¹Ø§Ù$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:gbanned:'
    local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Gban List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙØ­Ø¸Ø± Ø§ÙØ¹Ø§Ù </code>â¬ï¸ :\n\n"
end	
for k,v in pairs(list) do
    local user_info = database:hgetall('user:'..v)
    if user_info and user_info.username then
    local username = user_info.username
      text = text..k.." - @"..username.." ["..v.."]\n"
      else
      text = text..k.." - "..v.."\n"
          end
end
            if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Gban List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙØ­Ø¸ÙØ±ÙÙ Ø¹Ø§Ù</code> â ï¸"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Aa][Dd][Mm][Ii][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Admin List:</b>\n\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª </code>â¬ï¸ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Admin List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ Ø§Ø¯ÙÙÙÙ ÙÙØ¨ÙØª</code> â ï¸"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Dd]$") or text:match("^Ø§ÙØ¯Ù$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "`"..result.sender_user_id_.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø§ÙØ¯Ù','id')
    if text:match("^[Ii][Dd] @(.*)$") then
	local ap = {string.match(text, "^([Ii][Dd]) @(.*)$")} 
	function id_by_username(extra, result, success)
	if result.id_ then
            texts = '<code>'..result.id_..'</code>'
          else 
           if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
            texts = '<code>Ø®Ø·Ø§ </code> â ï¸'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],id_by_username)
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø¬ÙØ¨ ØµÙØ±Ù','getpro')
    if text:match("^getpro (%d+)$") and msg.reply_to_message_id_ == 0  then
		local pronumb = {string.match(text, "^(getpro) (%d+)$")} 
local function gpro(extra, result, success)
--vardump(result)
   if pronumb[2] == '1' then
   if result.photos_[0] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '2' then
   if result.photos_[1] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 2 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 2 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '3' then
   if result.photos_[2] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 3 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 3 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '4' then
      if result.photos_[3] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 4 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 4 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '5' then
   if result.photos_[4] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 5 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 5 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '6' then
   if result.photos_[5] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 6 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 6 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '7' then
   if result.photos_[6] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 7 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 7 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '8' then
   if result.photos_[7] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 8 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 8 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '9' then
   if result.photos_[8] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 9 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 9 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
   elseif pronumb[2] == '10' then
   if result.photos_[9] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
   else
                     if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "_You Have'nt 10 Profile Photo!!_", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ ØªÙÙÙ ØµÙØ±Ù 10 ÙÙ Ø­Ø³Ø§Ø¨Ù` â ï¸", 1, 'md')
end
   end
 else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "â¢ `ÙØ§ Ø§Ø³ØªØ·ÙØ¹ Ø¬ÙØ¨ Ø§ÙØ«Ø± ÙÙ 10 ØµÙØ±` â ï¸", 1, 'md')
end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = pronumb[2]
  }, gpro, nil)
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯','flood ban')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
else
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[2]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodmax[2]..'*', 1, 'md')
        else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯ ÙÙØ¹Ø¯Ø¯` ââ¬ï¸ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end

          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ','flood mute')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[2]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
	else
    database:set('flood:max:warn'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood Warn has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ ÙÙØ¹Ø¯Ø¯` ââ¬ï¸ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­','flood del')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[2]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
	else
    database:set('flood:max:del'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood delete has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­ ÙÙØ¹Ø¯Ø¯` ââ¬ï¸ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ÙÙØ§ÙØ´ Ø¨Ø§ÙÙØ³Ø­','spam del')
if text:match("^[Ss][Pp][Aa][Mm] [Dd][Ee][Ll] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Dd][Ee][Ll]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[40]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
 else
database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙÙÙÙØ´Ù Ø¨Ø§ÙÙØ³Ø­ ÙÙØ¹Ø¯Ø¯` ââ¬ï¸ : *'..sensspam[2]..'*', 1, 'md')
end
end
end
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ±','spam warn')
if text:match("^[Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[40]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
 else
database:set('bot:sens:spam:warn'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam Warn has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙÙÙÙØ´Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± ÙÙØ¹Ø¯Ø¯` ââ¬ï¸ : *'..sensspam[2]..'*', 1, 'md')
end
end
end

	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ Ø²ÙÙ Ø§ÙØªÙØ±Ø§Ø±','flood time')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee]) (%d+)$")} 
	if tonumber(floodt[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¶Ø¹ Ø¹Ø¯Ø¯ ÙÙ  *[1]* Ø§ÙÙ [_99999_]` â ï¸', 1, 'md')
end
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodt[2]..'*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø²ÙÙ Ø§ÙØªÙØ±Ø§Ø± ÙÙØ¹Ø¯Ø¯ ` ââ¬ï¸ : *'..floodt[2]..'*', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙØ¶Ø¹ Ø±Ø§Ø¨Ø·$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         database:set("bot:group:link"..msg.chat_id_, 'Waiting For Link!\nPls Send Group Link')
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Please Send Group Link Now!*', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ Ø¨Ø§Ø±Ø³Ø§Ù Ø§ÙØ±Ø§Ø¨Ø· ÙÙØªÙ Ø­ÙØ¸Ù` ð¤', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^Ø§ÙØ±Ø§Ø¨Ø·$") then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '<b>Group link:</b>\n'..link, 1, 'html')
       else 
                  send(msg.chat_id_, msg.id_, 1, 'â¢ <code>Ø±Ø§Ø¨Ø· Ø§ÙÙØ¬ÙÙØ¹Ù â¬ï¸ :</code>\n'..link, 1, 'html')
end
	  else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*There is not link set yet. Please add one by #setlink .*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ ÙØªÙ Ø­ÙØ¸ Ø±Ø§Ø¨Ø· Ø§Ø±Ø³Ù [ ÙØ¶Ø¹ Ø±Ø§Ø¨Ø· ] ÙØ­ÙØ¸ Ø±Ø§Ø¨Ø· Ø¬Ø¯ÙØ¯` â ï¸', 1, 'md')
end
	  end
 	end
	
	if text:match("^[Ww][Ll][Cc] [Oo][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Enabled* In This Supergroup.', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^[Ww][Ll][Cc] [Oo][Ff][Ff]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Disabled* In This Supergroup.', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end
	
	if text:match("^ØªÙØ¹ÙÙ Ø§ÙØªØ±Ø­ÙØ¨$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ Ø§ÙØªØ±Ø­ÙØ¨ ` âï¸', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^ØªØ¹Ø·ÙÙ Ø§ÙØªØ±Ø­ÙØ¨$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø·ÙÙ Ø§ÙØªØ±Ø­ÙØ¨ ` â ï¸', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end

	if text:match("^[Ss][Ee][Tt] [Ww][Ll][Cc] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^([Ss][Ee][Tt] [Ww][Ll][Cc]) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Saved!*\nWlc Text:\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end
	
	if text:match("^ÙØ¶Ø¹ ØªØ±Ø­ÙØ¨ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^(ÙØ¶Ø¹ ØªØ±Ø­ÙØ¨) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙØªØ±Ø­ÙØ¨` ââ¬ï¸ :\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end

          local text = msg.content_.text_:gsub('Ø­Ø°Ù Ø§ÙØªØ±Ø­ÙØ¨','del wlc')
	if text:match("^[Dd][Ee][Ll] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø­Ø°Ù Ø§ÙØªØ±Ø­ÙØ¨` â ï¸â', 1, 'md')
end
		 database:del('welcome:'..msg.chat_id_)
	end
	
          local text = msg.content_.text_:gsub('Ø¬ÙØ¨ Ø§ÙØªØ±Ø­ÙØ¨','get wlc')
	if text:match("^[Gg][Ee][Tt] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local wel = database:get('welcome:'..msg.chat_id_)
	if wel then
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØªØ±Ø­ÙØ¨ ` â¬ï¸ :'..wel, 1, 'md')
    else 
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'Welcome msg not saved!', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ ÙØªÙ ÙØ¶Ø¹ ØªØ±Ø­ÙØ¨ ÙÙÙØ¬ÙÙØ¹Ù` â ï¸', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙÙØ¹','bad')
	if text:match("^[Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local filters = {string.match(text, "^([Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "*New Word baded!*\n--> `"..name.."`", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, "â¢ `"..name.."` `ØªÙ Ø§Ø¶Ø§ÙØªÙØ§ ÙÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹` âï¸", 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø§ÙØºØ§Ø¡ ÙÙØ¹','unbad')
	if text:match("^[Uu][Nn][Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local rws = {string.match(text, "^([Uu][Nn][Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "`"..rws[2].."` *Removed From baded List!*", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, " â¢ "..rws[2].."` ØªÙ Ø­Ø°ÙÙØ§ ÙÙ ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹` ââ ï¸", 1, 'md')
end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Ø§Ø°Ø§Ø¹Ù','bc')
	if text:match("^bc (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^(bc) (.*)$")} 
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'html')
  end
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Done*\n_Your Msg Send to_ `'..gps..'` _Groups_', 1, 'md')
                   else
                     send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ´Ø± Ø§ÙØ±Ø³Ø§ÙÙ ÙÙ` `'..gps..'` `ÙØ¬ÙÙØ¹Ù` âï¸', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Gg][Rr][Oo][Uu][Pp][Ss]$") and is_admin(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙÙØ±ÙØ¨Ø§Øª$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Groups :* `'..gps..'`', 1, 'md')
                 else
                   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¹Ø¯Ø¯ Ø§ÙÙØ±ÙØ¨Ø§Øª ÙÙ â¬ï¸ :` *'..gps..'*', 1, 'md')
end
	end
	
if  text:match("^[Mm][Ss][Gg]$") or text:match("^Ø±Ø³Ø§Ø¦ÙÙ$") and msg.reply_to_message_id_ == 0  then
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*Msgs : * `"..user_msgs.."`", 1, 'md')
      else 
        end
    else 
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "â¢ `Ø¹Ø¯Ø¯ Ø±Ø³Ø§Ø¦ÙÙ ÙÙ â¬ï¸ :` *"..user_msgs.."*", 1, 'md')
      else 
        end
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙÙÙ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local arslaPT = {string.match(text, "^(ÙÙÙ) (.*)$")} 
    if lockpt[2] == "edit"and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªØ¹Ø¯ÙÙ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ¹Ø¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
                end
                database:set('editmsg'..msg.chat_id_,'delmsg')
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *locked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ¹Ø¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
                end
              end
            end
   if lockpt[2] == "bots" or arslaPT[2] == "Ø§ÙØ¨ÙØªØ§Øª" then
              if not database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¨ÙØªØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
                end
                database:set('bot:bots:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¨ÙØªØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `âï¸', 1, 'md')
                  end
                database:del('anti-flood:'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØªÙ `âï¸', 1, 'md')
                  end
                database:del('anti-flood:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØªÙ` âï¸', 1, 'md')
                end
              end
          end
            	  if lockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `âï¸', 1, 'md')
                  end
                database:del('anti-flood:del'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªØ«Ø¨ÙØª" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ«Ø¨ÙØª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
                end
                database:set('bot:pin:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ«Ø¨ÙØª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaPT[2] == "Ø§ÙØªØ«Ø¨ÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ«Ø¨ÙØª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
                end
                database:set('bot:pin:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ«Ø¨ÙØª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
                end
              end
            end
          end
          
	-----------------------------------------------------------------------------------------------
	
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙØªØ­ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local arslaUN = {string.match(text, "^(ÙØªØ­) (.*)$")} 
                if unlockpt[2] == "edit" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªØ¹Ø¯ÙÙ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ¹Ø¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
                end
                database:del('editmsg'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *Unlocked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ¹Ø¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "bots" or arslaUN[2] == "Ø§ÙØ¨ÙØªØ§Øª" then
              if database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¨ÙØªØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
                end
                database:del('bot:bots:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¨ÙØªØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
                  end
                   database:set('anti-flood:'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØªÙ `â ï¸', 1, 'md')
                  end
                   database:set('anti-flood:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØªÙ` â ï¸', 1, 'md')
                end
              end
          end
            	  if unlockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
                  end
                   database:set('anti-flood:del'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ±Ø§Ø±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªØ«Ø¨ÙØª" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ«Ø¨ÙØª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
                end
                database:del('bot:pin:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ«Ø¨ÙØª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or arslaUN[2] == "Ø§ÙØªØ«Ø¨ÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *Unlocked*", 1, 'md')
                else
                send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ«Ø¨ÙØª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
                end
                database:del('bot:pin:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ«Ø¨ÙØª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
                end
              end
            end
              end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙÙÙ Ø§ÙÙÙ Ø¨Ø§ÙØ«ÙØ§ÙÙ','lock all s')
  	if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Group muted for_ *'..mutept[1]..'* _seconds!_', 1, 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`â¢ ØªÙ ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· ÙÙØ¯Ø©` "..mutept[1].." `Ø«Ø§ÙÙÙ` ðâ", 'md')
end
	end

          local text = msg.content_.text_:gsub('ÙÙÙ Ø§ÙÙÙ Ø¨Ø§ÙØ³Ø§Ø¹Ù','lock all h')
    if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh]  (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh] (%d+)$")}
        local hour = string.gsub(mutept[1], 'h', '')
        local num1 = tonumber(hour) * 3600
        local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
                if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`â¢ ØªÙ ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· ÙÙØ¯Ø©` "..mutept[1].." `Ø³Ø§Ø¹Ù` ðâ", 'md')
end
     end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙÙÙ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local arsla = {string.match(text, "^(ÙÙÙ) (.*)$")} 
      if mutept[2] == "all" or arsla[2] == "Ø§ÙÙÙ" then
	  if not database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:muteall'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "all warn" or arsla[2] == "Ø§ÙÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:muteallwarn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "all ban" or arsla[2] == "Ø§ÙÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:muteallban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "text" or arsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù" then
	  if not database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:text:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "text ban" or arsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:text:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "text warn" or arsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:text:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline" or arsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ" then
	  if not database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:inline:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline ban" or arsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:inline:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline warn" or arsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:inline:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo" or arsla[2] == "Ø§ÙØµÙØ±" then
	  if not database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:photo:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo ban" or arsla[2] == "Ø§ÙØµÙØ± Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:photo:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo warn" or arsla[2] == "Ø§ÙØµÙØ± Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:photo:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "video" or arsla[2] == "Ø§ÙÙÙØ¯ÙÙ" then
	  if not database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:video:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "video ban" or arsla[2] == "Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:video:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "video warn" or arsla[2] == "Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:video:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif" or arsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ" then
	  if not database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:gifs:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif ban" or arsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:gifs:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif warn" or arsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:gifs:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "music" or arsla[2] == "Ø§ÙØ§ØºØ§ÙÙ" then
	  if not database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:music:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "music ban" or arsla[2] == "Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:music:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "music warn" or arsla[2] == "Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:music:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice" or arsla[2] == "Ø§ÙØµÙØª" then
	  if not database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:voice:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice ban" or arsla[2] == "Ø§ÙØµÙØª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:voice:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice warn" or arsla[2] == "Ø§ÙØµÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:voice:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "links" or arsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø·" then
	  if not database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:links:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "links ban" or arsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:links:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "links warn" or arsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:links:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "location" or arsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª" then
	  if not database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:location:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "location ban" or arsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:location:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "location warn" or arsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:location:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag" or arsla[2] == "Ø§ÙÙØ¹Ø±Ù" then
	  if not database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:tag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag ban" or arsla[2] == "Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:tag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag warn" or arsla[2] == "Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:tag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag" or arsla[2] == "Ø§ÙØªØ§Ù" then
	  if not database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:hashtag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag ban" or arsla[2] == "Ø§ÙØªØ§Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:hashtag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag warn" or arsla[2] == "Ø§ÙØªØ§Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:hashtag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact" or arsla[2] == "Ø§ÙØ¬ÙØ§Øª" then
	  if not database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:contact:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact ban" or arsla[2] == "Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:contact:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact warn" or arsla[2] == "Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:contact:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage" or arsla[2] == "Ø§ÙÙÙØ§ÙØ¹" then
	  if not database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:webpage:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage ban" or arsla[2] == "Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:webpage:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage warn" or arsla[2] == "Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:webpage:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
    end
      if mutept[2] == "arabic" or arsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ" then
	  if not database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:arabic:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic ban" or arsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:arabic:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic warn" or arsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:arabic:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "english" or arsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ" then
	  if not database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:english:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "english ban" or arsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:english:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "english warn" or arsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:english:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam del" or arsla[2] == "Ø§ÙÙÙØ§ÙØ´" then
	  if not database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ´ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:spam:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ´` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam warn" or arsla[2] == "Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ´ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:spam:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØ§ÙØ´` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker" or arsla[2] == "Ø§ÙÙÙØµÙØ§Øª" then
	  if not database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:sticker:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker ban" or arsla[2] == "Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:sticker:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker warn" or arsla[2] == "Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:sticker:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
    end
      if mutept[2] == "file" or arsla[2] == "Ø§ÙÙÙÙØ§Øª" then
	  if not database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:document:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "file ban" or arsla[2] == "Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:document:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª` ï¿½ï¿½ï¿½ï¿½\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "file warn" or arsla[2] == "Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:document:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
  end
  
      if mutept[2] == "markdown" or arsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ" then
	  if not database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:markdown:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown ban" or arsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:markdown:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown warn" or arsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:markdown:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
    end
    
	  if mutept[2] == "service" or arsla[2] == "Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª" then
	  if not database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:tgservice:mute'..msg.chat_id_,true)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd" or arsla[2] == "Ø§ÙØªÙØ¬ÙÙ" then
	  if not database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:forward:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd ban" or arsla[2] == "Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:forward:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd warn" or arsla[2] == "Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:forward:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd" or arsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù" then
	  if not database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
         database:set('bot:cmd:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd ban" or arsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if not database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
         database:set('bot:cmd:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` âï¸', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd warn" or arsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if not database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
         database:set('bot:cmd:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙÙÙ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` âï¸', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙØªØ­ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local UNarsla = {string.match(text, "^(ÙØªØ­) (.*)$")} 
      if unmutept[2] == "all" or UNarsla[2] == "Ø§ÙÙÙ" then
	  if database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:muteall'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ ÙÙÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all warn" or UNarsla[2] == "Ø§ÙÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:muteallwarn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all ban" or UNarsla[2] == "Ø§ÙÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø¨Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:muteallban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø¨Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text" or UNarsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù" then
	  if database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:text:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text ban" or UNarsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:text:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text warn" or UNarsla[2] == "Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:text:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¯Ø±Ø¯Ø´Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline" or UNarsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ" then
	  if database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:inline:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline ban" or UNarsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:inline:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline warn" or UNarsla[2] == "Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:inline:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo" or UNarsla[2] == "Ø§ÙØµÙØ±" then
	  if database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:photo:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo ban" or UNarsla[2] == "Ø§ÙØµÙØ± Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:photo:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo warn" or UNarsla[2] == "Ø§ÙØµÙØ± Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØ± `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:photo:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØ±` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video" or UNarsla[2] == "Ø§ÙÙÙØ¯ÙÙ" then
	  if database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:video:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video ban" or UNarsla[2] == "Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø¨Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:video:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø¨Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video warn" or UNarsla[2] == "Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:video:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ¯ÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif" or UNarsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ" then
	  if database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:gifs:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif ban" or UNarsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:gifs:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif warn" or UNarsla[2] == "Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:gifs:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØªØ­Ø±ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music" or UNarsla[2] == "Ø§ÙØ§ØºØ§ÙÙ" then
	  if database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:music:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music ban" or UNarsla[2] == "Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:music:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music warn" or UNarsla[2] == "Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:music:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ØºØ§ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice" or UNarsla[2] == "Ø§ÙØµÙØª" then
	  if database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:voice:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice ban" or UNarsla[2] == "Ø§ÙØµÙØª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:voice:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice warn" or UNarsla[2] == "Ø§ÙØµÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:voice:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØµÙØªÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links" or UNarsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø·" then
	  if database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:links:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links ban" or UNarsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:links:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links warn" or UNarsla[2] == "Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø· `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:links:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ±ÙØ§Ø¨Ø·` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location" or UNarsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª" then
	  if database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:location:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location ban" or UNarsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:location:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location warn" or UNarsla[2] == "Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:location:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø¨ÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end 
      end
      if unmutept[2] == "tag" or UNarsla[2] == "Ø§ÙÙØ¹Ø±Ù" then
	  if database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:tag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag ban" or UNarsla[2] == "Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:tag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag warn" or UNarsla[2] == "Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:tag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ¹Ø±ÙØ§Øª <@>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag" or UNarsla[2] == "Ø§ÙØªØ§Ù" then
	  if database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:hashtag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag ban" or UNarsla[2] == "Ø§ÙØªØ§Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:hashtag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag warn" or UNarsla[2] == "Ø§ÙØªØ§Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#> `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:hashtag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªØ§ÙØ§Øª <#>` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact" or UNarsla[2] == "Ø§ÙØ¬ÙØ§Øª" then
	  if database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:contact:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact ban" or UNarsla[2] == "Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:contact:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact warn" or UNarsla[2] == "Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:contact:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage" or UNarsla[2] == "Ø§ÙÙÙØ§ÙØ¹" then
	  if database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:webpage:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage ban" or UNarsla[2] == "Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:webpage:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage warn" or UNarsla[2] == "Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:webpage:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ¹` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
    end
      if unmutept[2] == "arabic" or UNarsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ" then
	  if database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:arabic:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic ban" or UNarsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:arabic:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic warn" or UNarsla[2] == "Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:arabic:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ¹Ø±Ø¨ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english" or UNarsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ" then
	  if database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:english:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english ban" or UNarsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:english:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english warn" or UNarsla[2] == "Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:english:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam del" or UNarsla[2] == "Ø§ÙÙÙØ§ÙØ´" then
	  if database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ´ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:spam:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ´` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam warn" or UNarsla[2] == "Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ´ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:spam:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØ§ÙØ´` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker" or UNarsla[2] == "Ø§ÙÙÙØµÙØ§Øª" then
	  if database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:sticker:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker ban" or UNarsla[2] == "Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:sticker:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker warn" or UNarsla[2] == "Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:sticker:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙØµÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
    end

      if unmutept[2] == "file" or UNarsla[2] == "Ø§ÙÙÙÙØ§Øª" then
	  if database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:document:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file ban" or UNarsla[2] == "Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:document:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file warn" or UNarsla[2] == "Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:document:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙÙÙØ§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end    

      if unmutept[2] == "markdown" or UNarsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ" then
	  if database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:markdown:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown ban" or UNarsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:markdown:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown warn" or UNarsla[2] == "Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:markdown:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end    


	  if unmutept[2] == "service" or UNarsla[2] == "Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª" then
	  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:tgservice:mute'..msg.chat_id_)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd" or UNarsla[2] == "Ø§ÙØªÙØ¬ÙÙ" then
	  if database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:forward:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd ban" or UNarsla[2] == "Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:forward:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd warn" or UNarsla[2] == "Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§Ùï¿½ï¿½Ø­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:forward:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØªÙØ¬ÙÙ` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd" or UNarsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù" then
	  if database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­ `â ï¸', 1, 'md')
      end
         database:del('bot:cmd:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙÙØ³Ø­` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd ban" or UNarsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØ·Ø±Ø¯" then
	  if database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯ `â ï¸', 1, 'md')
      end
         database:del('bot:cmd:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØ·Ø±Ø¯` â ï¸', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd warn" or UNarsla[2] == "Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±" then
	  if database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ `âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù `ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ± `â ï¸', 1, 'md')
      end
         database:del('bot:cmd:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ` âï¸ `ÙØªØ­ Ø§ÙØ´Ø§Ø±Ø­Ù` ð\n\nâ¢ `Ø®Ø§ØµÙØ© : Ø§ÙØªØ­Ø°ÙØ±` â ï¸', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ØªØ¹Ø¯ÙÙ','edit')
  	if text:match("^[Ee][Dd][Ii][Tt] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local editmsg = {string.match(text, "^([Ee][Dd][Ii][Tt]) (.*)$")} 
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'html')
    if database:get('lang:gp:'..msg.chat_id_) then
		 	          send(msg.chat_id_, msg.id_, 1, '*Done* _Edit My Msg_', 1, 'md')
else 
		 	          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø¯ÙÙ Ø§ÙØ±Ø³Ø§ÙÙ` âï¸ð', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙØ¹Ø§Ù$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> Banall has been_ *Cleaned*'
    else 
      text = 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙØ¹Ø§Ù` ââ ï¸'
end
      database:del('bot:gbanned:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end

    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Aa][Dd][Mm][Ii][Nn][Ss]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ÙØ³Ø­ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> adminlist has been_ *Cleaned*'
    else 
      text = 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª` ââ ï¸'
end
      database:del('bot:admins:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ³Ø­','clean')
  	if text:match("^[Cc][Ll][Ee][Aa][Nn] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Cc][Ll][Ee][Aa][Nn]) (.*)$")} 
       if txt[2] == 'banlist' or txt[2] == 'Banlist' or txt[2] == 'Ø§ÙÙØ­Ø¸ÙØ±ÙÙ' then
	      database:del('bot:banned:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙÙØ­Ø¸ÙØ±ÙÙ` ââ ï¸', 1, 'md')
end
       end
	   if txt[2] == 'bots' or txt[2] == 'Bots' or txt[2] == 'Ø§ÙØ¨ÙØªØ§Øª' then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].msg.sender_user_id_)
          end 
      end
    channel_get_bots(msg.chat_id_,g_bots) 
    if database:get('lang:gp:'..msg.chat_id_) then
	          send(msg.chat_id_, msg.id_, 1, '_> All bots_ *kicked!*', 1, 'md')
          else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø·Ø±Ø¯ Ø¬ÙÙØ¹ Ø§ÙØ¨ÙØªØ§Øª` ââ ï¸', 1, 'md')
end
	end
	   if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Ø§ÙØ§Ø¯ÙÙÙÙ' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:mods:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Modlist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙØ§Ø¯ÙÙÙÙ` ââ ï¸', 1, 'md')
end
     end 
	   if txt[2] == 'viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:vipgp:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Viplist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ` ââ ï¸', 1, 'md')
end
       end 
	   if txt[2] == 'owners' and is_sudo(msg) or txt[2] == 'Owners' and is_sudo(msg) or txt[2] == 'Ø§ÙÙØ¯Ø±Ø§Ø¡' and is_sudo(msg) then
	      database:del('bot:owners:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> ownerlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡` ââ ï¸', 1, 'md')
end
       end
	   if txt[2] == 'rules' or txt[2] == 'Rules' or txt[2] == 'Ø§ÙÙÙØ§ÙÙÙ' then
	      database:del('bot:rules'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> rules has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ Ø§ÙÙÙØ§ÙÙÙ Ø§ÙÙØ­ÙÙØ¸Ù` ââ ï¸', 1, 'md')
end
       end
	   if txt[2] == 'link' or  txt[2] == 'Link' or  txt[2] == 'Ø§ÙØ±Ø§Ø¨Ø·' then
	      database:del('bot:group:link'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> link has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ Ø§ÙØ±Ø§Ø¨Ø· Ø§ÙÙØ­ÙÙØ¸` ââ ï¸', 1, 'md')
end
       end
	   if txt[2] == 'badlist' or txt[2] == 'Badlist' or txt[2] == 'ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹' then
	      database:del('bot:filters:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> badlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹` ââ ï¸', 1, 'md')
end
       end
	   if txt[2] == 'silentlist' or txt[2] == 'Silentlist' or txt[2] == 'Ø§ÙÙÙØªÙÙÙÙ' then
	      database:del('bot:muted:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> silentlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙÙÙØªÙÙÙÙ` ââ ï¸', 1, 'md')
end
       end
       
    end 
	-----------------------------------------------------------------------------------------------
  	 if text:match("^[Ss] [Dd][Ee][Ll]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`lock | ð`'
	else
	mute_all = '`unlock | ð`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`lock | ð`'
	else
	mute_text = '`unlock | ð`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`lock | ð`'
	else
	mute_photo = '`unlock | ð`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`lock | ð`'
	else
	mute_video = '`unlock | ð`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`lock | ð`'
	else
	mute_gifs = '`unlock | ð`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`unlock | ð`'
	else  
	mute_flood = '`lock | ð`'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`lock | ð`'
	else
	mute_music = '`unlock | ð`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`lock | ð`'
	else
	mute_bots = '`unlock | ð`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`lock | ð`'
	else
	mute_in = '`unlock | ð`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`lock | ð`'
	else
	mute_voice = '`unlock | ð`'
end

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`lock | ð`'
	else
	mute_doc = '`unlock | ð`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`lock | ð`'
	else
	mute_mdd = '`unlock | ð`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`lock | ð`'
	else
	mute_edit = '`unlock | ð`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`lock | ð`'
	else
	mute_links = '`unlock | ð`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`lock | ð`'
	else
	lock_pin = '`unlock | ð`'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`lock | ð`'
	else
	lock_sticker = '`unlock | ð`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`lock | ð`'
	else
	lock_tgservice = '`unlock | ð`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`lock | ð`'
	else
	lock_wp = '`unlock | ð`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`lock | ð`'
	else
	lock_htag = '`unlock | ð`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`lock | ð`'
	else
	lock_cmd = '`unlock | ð`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`lock | ð`'
	else
	lock_tag = '`unlock | ð`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`lock | ð`'
	else
	lock_location = '`unlock | ð`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end

	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`lock | ð`'
	else
	lock_contact = '`unlock | ð`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`lock | ð`'
	else
	mute_spam = '`unlock | ð`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`unlock | ð`'
	else 
	lock_flood = '`lock | ð`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`unlock | ð`'
	else 
	del_flood = '`lock | ð`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`lock | ð`'
	else
	lock_english = '`unlock | ð`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`lock | ð`'
	else
	lock_arabic = '`unlock | ð`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`lock | ð`'
	else
	lock_forward = '`unlock | ð`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`lock | ð`'
	else
	lock_rep = '`unlock | ð`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`active | â`'
	else
	send_welcome = '`inactive | â­`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
		if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Del*\n======================\n*Del all* : "..mute_all.."\n" .."*Del Links* : "..mute_links.."\n" .."*Del Edit* : "..mute_edit.."\n" .."*Del Bots* : "..mute_bots.."\n" .."*Del Inline* : "..mute_in.."\n" .."*Del English* : "..lock_english.."\n" .."*Del Forward* : "..lock_forward.."\n" .."*Del Pin* : "..lock_pin.."\n" .."*Del Arabic* : "..lock_arabic.."\n" .."*Del Hashtag* : "..lock_htag.."\n".."*Del tag* : "..lock_tag.."\n" .."*Del Webpage* : "..lock_wp.."\n" .."*Del Location* : "..lock_location.."\n" .."*Del Tgservice* : "..lock_tgservice.."\n"
.."*Del Spam* : "..mute_spam.."\n" .."*Del Photo* : "..mute_photo.."\n" .."*Del Text* : "..mute_text.."\n" .."*Del Gifs* : "..mute_gifs.."\n" .."*Del Voice* : "..mute_voice.."\n" .."*Del Music* : "..mute_music.."\n" .."*Del Video* : "..mute_video.."\n*Del Cmd* : "..lock_cmd.."\n" .."*Del Markdown* : "..mute_mdd.."\n*Del Document* : "..mute_doc.."\n" .."*Flood Ban* : "..mute_flood.."\n" .."*Flood Mute* : "..lock_flood.."\n" .."*Flood del* : "..del_flood.."\n" .."*Setting reply* : "..lock_rep.."\n"
.."======================\n*Welcome* : "..send_welcome.."\n*Flood Time*  "..flood_t.."\n" .."*Flood Max* : "..flood_m.."\n" .."*Flood Mute* : "..flood_warn.."\n" .."*Flood del* : "..flood_del.."\n" .."*Number Spam* : "..spam_c.."\n" .."*Warn Spam* : "..spam_d.."\n"
 .."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end

          local text = msg.content_.text_:gsub('Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ³Ø­','sdd1')
  	 if text:match("^[Ss][Dd][Dd]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`ÙÙØ¹Ù | ð`'
	else
	mute_all = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`ÙÙØ¹Ù | ð`'
	else
	mute_text = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`ÙÙØ¹Ù | ð`'
	else
	mute_photo = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`ÙÙØ¹Ù | ð`'
	else
	mute_video = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`ÙÙØ¹Ù | ð`'
	else
	mute_gifs = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`ÙØ¹Ø·Ù | ð`'
	else  
	mute_flood = '`ÙÙØ¹Ù | ð`'
end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`ÙÙØ¹Ù | ð`'
	else
	mute_music = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`ÙÙØ¹Ù | ð`'
	else
	mute_bots = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`ÙÙØ¹Ù | ð`'
	else
	mute_in = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`ÙÙØ¹Ù | ð`'
	else
	mute_voice = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`ÙÙØ¹Ù | ð`'
	else
	mute_edit = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`ÙÙØ¹Ù | ð`'
	else
	mute_links = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`ÙÙØ¹Ù | ð`'
	else
	lock_pin = '`ÙØ¹Ø·Ù | ð`'
end 

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`ÙÙØ¹Ù | ð`'
	else
	mute_doc = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`ÙÙØ¹Ù | ð`'
	else
	mute_mdd = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`ÙÙØ¹Ù | ð`'
	else
	lock_sticker = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`ÙÙØ¹Ù | ð`'
	else
	lock_tgservice = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`ÙÙØ¹Ù | ð`'
	else
	lock_wp = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`ÙÙØ¹Ù | ð`'
	else
	lock_htag = '`ÙØ¹Ø·Ù | ð`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`ÙÙØ¹Ù | ð`'
	else
	lock_cmd = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`ÙÙØ¹Ù | ð`'
	else
	lock_tag = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`ÙÙØ¹Ù | ð`'
	else
	lock_location = '`ÙØ¹Ø·Ù | ð`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end
	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`ÙÙØ¹Ù | ð`'
	else
	lock_contact = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`ÙÙØ¹Ù | ð`'
	else
	mute_spam = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`ÙÙØ¹Ù | ð`'
	else
	lock_english = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`ÙÙØ¹Ù | ð`'
	else
	lock_arabic = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`ÙØ¹Ø·Ù | ð`'
	else 
	lock_flood = '`ÙÙØ¹Ù | ð`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`ÙØ¹Ø·Ù | ð`'
	else 
	del_flood = '`ÙÙØ¹Ù | ð`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`ÙÙØ¹Ù | ð`'
	else
	lock_forward = '`ÙØ¹Ø·Ù | ð`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`ÙØ¹Ø·ÙÙ | ð`'
	else
	lock_rep = '`ÙÙØ¹ÙÙ | ð`'
	end

    if database:get('bot:repsudo:mute'..msg.chat_id_) then
	lock_repsudo = '`ÙØ¹Ø·ÙÙ | ð`'
	else
	lock_repsudo = '`ÙÙØ¹ÙÙ | ð`'
	end
	
    if database:get('bot:repowner:mute'..msg.chat_id_) then
	lock_repowner = '`ÙØ¹Ø·ÙÙ | ð`'
	else
	lock_repowner = '`ÙÙØ¹ÙÙ | ð`'
	end

    if database:get('bot:id:mute'..msg.chat_id_) then
	lock_id = '`ÙØ¹Ø·Ù | ð`'
	else
	lock_id = '`ÙÙØ¹Ù | ð`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`ÙÙØ¹Ù | â`'
	else
	send_welcome = '`ÙØ¹Ø·Ù | â­`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
	if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`ÙØ§ ÙÙØ§Ø¦Ù`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "â¢ `Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ¬ÙÙØ¹Ù Ø¨Ø§ÙÙØ³Ø­`\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ `ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` : "..mute_all.."\n"
	 .."â¢ `Ø§ÙØ±ÙØ§Ø¨Ø·` : "..mute_links.."\n"
	 .."â¢ `Ø§ÙØªØ¹Ø¯ÙÙ` : "..mute_edit.."\n" 
	 .."â¢ `Ø§ÙØ¨ÙØªØ§Øª` : "..mute_bots.."\n"
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` : "..lock_english.."\n"
	 .."â¢ `Ø§Ø¹Ø§Ø¯Ù Ø§ÙØªÙØ¬ÙÙ` : "..lock_forward.."\n" 
	 .."â¢ `Ø§ÙÙÙØ§ÙØ¹` : "..lock_wp.."\n" 
	 .."â¢ `Ø§ÙØªØ«Ø¨ÙØª` : "..lock_pin.."\n" 
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` : "..lock_arabic.."\n\n"
	 .."â¢ `Ø§ÙØªØ§ÙØ§Øª` : "..lock_htag.."\n"
	 .."â¢ `Ø§ÙÙØ¹Ø±ÙØ§Øª` : "..lock_tag.."\n" 
	 .."â¢ `Ø§ÙØ´Ø¨ÙØ§Øª` : "..lock_location.."\n" 
	 .."â¢ `Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª` : "..lock_tgservice.."\n"
   .."â¢ `Ø§ÙÙÙØ§ÙØ´` : "..mute_spam.."\n"
   .."â¢ `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯` : "..mute_flood.."\n" 
   .."â¢ `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ` : "..lock_flood.."\n" 
   .."â¢ `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­` : "..del_flood.."\n" 
   .."â¢ `Ø§ÙØ¯Ø±Ø¯Ø´Ù` : "..mute_text.."\n"
   .."â¢ `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ` : "..mute_gifs.."\n\n"
   .."â¢ `Ø§ÙØµÙØªÙØ§Øª` : "..mute_voice.."\n" 
   .."â¢ `Ø§ÙØ§ØºØ§ÙÙ` : "..mute_music.."\n"
	 .."â¢ `Ø§ÙØ§ÙÙØ§ÙÙ` : "..mute_in.."\n" 
   .."â¢ `Ø§ÙÙÙØµÙØ§Øª` : "..lock_sticker.."\n"
	 .."â¢ `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` : "..lock_contact.."\n" 
   .."â¢ `Ø§ÙÙÙØ¯ÙÙÙØ§Øª` : "..mute_video.."\nâ¢ `Ø§ÙØ´Ø§Ø±Ø­Ù` : "..lock_cmd.."\n"
   .."â¢ `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` : "..mute_mdd.."\nâ¢ `Ø§ÙÙÙÙØ§Øª` : "..mute_doc.."\n" 
   .."â¢ `Ø§ÙØµÙØ±` : "..mute_photo.."\n"
   .."â¢ `Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª` : "..lock_rep.."\n"
   .."â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` : "..lock_repsudo.."\n"
   .."â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±` : "..lock_repowner.."\n"
   .."â¢ `Ø§ÙØ§ÙØ¯Ù` : "..lock_id.."\n\n"
   .."Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ `Ø§ÙØªØ±Ø­ÙØ¨` : "..send_welcome.."\nâ¢ `Ø²ÙÙ Ø§ÙØªÙØ±Ø§Ø±` : "..flood_t.."\n"
   .."â¢ `Ø¹Ø¯Ø¯ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯` : "..flood_m.."\n"
   .."â¢ `Ø¹Ø¯Ø¯ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ` : "..flood_warn.."\n\n"
   .."â¢ `Ø¹Ø¯Ø¯ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­` : "..flood_del.."\n"
   .."â¢ `Ø¹Ø¯Ø¯ Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙÙØ³Ø­` : "..spam_c.."\n"
   .."â¢ `Ø¹Ø¯Ø¯ Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ±` : "..spam_d.."\n"
   .."â¢ `Ø§ÙÙØ¶Ø§Ø¡ Ø§ÙØ¨ÙØª` : "..exp_dat.." `ÙÙÙ`\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Ww][Aa][Rr][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`lock | ð`'
	else
	mute_all = '`unlock | ð`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`lock | ð`'
	else
	mute_text = '`unlock | ð`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`lock | ð`'
	else
	mute_photo = '`unlock | ð`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`lock | ð`'
	else
	mute_video = '`unlock | ð`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`lock | ð`'
	else
	mute_spam = '`unlock | ð`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`lock | ð`'
	else
	mute_gifs = '`unlock | ð`'
end

	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`lock | ð`'
	else
	mute_music = '`unlock | ð`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`lock | ð`'
	else
	mute_in = '`unlock | ð`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`lock | ð`'
	else
	mute_voice = '`unlock | ð`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`lock | ð`'
	else
	mute_links = '`unlock | ð`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`lock | ð`'
	else
	lock_sticker = '`unlock | ð`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`lock | ð`'
	else
	lock_cmd = '`unlock | ð`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`lock | ð`'
	else
	lock_wp = '`unlock | ð`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`lock | ð`'
	else
	mute_doc = '`unlock | ð`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`lock | ð`'
	else
	mute_mdd = '`unlock | ð`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`lock | ð`'
	else
	lock_htag = '`unlock | ð`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`lock | ð`'
	else
	lock_pin = '`unlock | ð`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`lock | ð`'
	else
	lock_tag = '`unlock | ð`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`lock | ð`'
	else
	lock_location = '`unlock | ð`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`lock | ð`'
	else
	lock_contact = '`unlock | ð`'
	end
	------------
	
    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`lock | ð`'
	else
	lock_english = '`unlock | ð`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`lock | ð`'
	else
	lock_arabic = '`unlock | ð`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`lock | ð`'
	else
	lock_forward = '`unlock | ð`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Warn*\n======================\n*Warn all* : "..mute_all.."\n" .."*Warn Links* : "..mute_links.."\n" .."*Warn Inline* : "..mute_in.."\n" .."*Warn Pin* : "..lock_pin.."\n" .."*Warn English* : "..lock_english.."\n" .."*Warn Forward* : "..lock_forward.."\n" .."*Warn Arabic* : "..lock_arabic.."\n" .."*Warn Hashtag* : "..lock_htag.."\n".."*Warn tag* : "..lock_tag.."\n" .."*Warn Webpag* : "..lock_wp.."\n" .."*Warn Location* : "..lock_location.."\n"
.."*Warn Spam* : "..mute_spam.."\n" .."*Warn Photo* : "..mute_photo.."\n" .."*Warn Text* : "..mute_text.."\n" .."*Warn Gifs* : "..mute_gifs.."\n" .."*Warn Voice* : "..mute_voice.."\n" .."*Warn Music* : "..mute_music.."\n" .."*Warn Video* : "..mute_video.."\n*Warn Cmd* : "..lock_cmd.."\n"  .."*Warn Markdown* : "..mute_mdd.."\n*Warn Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end


          local text = msg.content_.text_:gsub('Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØªØ­Ø°ÙØ±','sdd2')
  	 if text:match("^[Ss][Dd][Dd]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`ÙÙØ¹Ù | ð`'
	else
	mute_all = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`ÙÙØ¹Ù | ð`'
	else
	mute_text = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`ÙÙØ¹Ù | ð`'
	else
	mute_photo = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`ÙÙØ¹Ù | ð`'
	else
	mute_video = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`ÙÙØ¹Ù | ð`'
	else
	mute_spam = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`ÙÙØ¹Ù | ð`'
	else
	mute_gifs = '`ÙØ¹Ø·Ù | ð`'
end
	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`ÙÙØ¹Ù | ð`'
	else
	mute_music = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`ÙÙØ¹Ù | ð`'
	else
	mute_in = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`ÙÙØ¹Ù | ð`'
	else
	mute_voice = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`ÙÙØ¹Ù | ð`'
	else
	mute_links = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`ÙÙØ¹Ù | ð`'
	else
	lock_sticker = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`ÙÙØ¹Ù | ð`'
	else
	lock_cmd = '`ÙØ¹Ø·Ù | ð`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`ÙÙØ¹Ù | ð`'
	else
	lock_wp = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`ÙÙØ¹Ù | ð`'
	else
	lock_htag = '`ÙØ¹Ø·Ù | ð`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`ÙÙØ¹Ù | ð`'
	else
	lock_pin = '`ÙØ¹Ø·Ù | ð`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`ÙÙØ¹Ù | ð`'
	else
	lock_tag = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`ÙÙØ¹Ù | ð`'
	else
	lock_location = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`ÙÙØ¹Ù | ð`'
	else
	lock_contact = '`ÙØ¹Ø·Ù | ð`'
	end

    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`ÙÙØ¹Ù | ð`'
	else
	lock_english = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`ÙÙØ¹Ù | ð`'
	else
	lock_arabic = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`ÙÙØ¹Ù | ð`'
	else
	mute_doc = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`ÙÙØ¹Ù | ð`'
	else
	mute_mdd = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`ÙÙØ¹Ù | ð`'
	else
	lock_forward = '`ÙØ¹Ø·Ù | ð`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`ÙØ§ ÙÙØ§Ø¦Ù`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "â¢ `Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ¬ÙÙØ¹Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±`\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ `ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` : "..mute_all.."\n"
	 .."â¢ `Ø§ÙØ±ÙØ§Ø¨Ø·` : "..mute_links.."\n"
	 .."â¢ `Ø§ÙØ§ÙÙØ§ÙÙ` : "..mute_in.."\n"
	 .."â¢ `Ø§ÙØªØ«Ø¨ÙØª` : "..lock_pin.."\n"
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` : "..lock_english.."\n"
	 .."â¢ `Ø§Ø¹Ø§Ø¯Ù Ø§ÙØªÙØ¬ÙÙ` : "..lock_forward.."\n"
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` : "..lock_arabic.."\n"
	 .."â¢ `Ø§ÙØªØ§ÙØ§Øª` : "..lock_htag.."\n"
	 .."â¢ `Ø§ÙÙØ¹Ø±ÙØ§Øª` : "..lock_tag.."\n" 
	 .."â¢ `Ø§ÙÙÙØ§ÙØ¹` : "..lock_wp.."\n"
	 .."â¢ `Ø§ÙØ´Ø¨ÙØ§Øª` : "..lock_location.."\n" 
   .."â¢ `Ø§ÙÙÙØ§ÙØ´` : "..mute_spam.."\n\n" 
   .."â¢ `Ø§ÙØµÙØ±` : "..mute_photo.."\n" 
   .."â¢ `Ø§ÙØ¯Ø±Ø¯Ø´Ù` : "..mute_text.."\n"
   .."â¢ `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ` : "..mute_gifs.."\n"
   .."â¢ `Ø§ÙÙÙØµÙØ§Øª` : "..lock_sticker.."\n"
	 .."â¢ `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` : "..lock_contact.."\n" 
   .."â¢ `Ø§ÙØµÙØªÙØ§Øª` : "..mute_voice.."\n" 
   .."â¢ `Ø§ÙØ§ØºØ§ÙÙ` : "..mute_music.."\n" 
   .."â¢ `Ø§ÙÙÙØ¯ÙÙÙØ§Øª` : "..mute_video.."\nâ¢ `Ø§ÙØ´Ø§Ø±Ø­Ù` : "..lock_cmd.."\n"
   .."â¢ `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` : "..mute_mdd.."\nâ¢ `Ø§ÙÙÙÙØ§Øª` : "..mute_doc.."\n" 
   .."\nâ¢ `Ø§ÙÙØ¶Ø§Ø¡ Ø§ÙØ¨ÙØª` : "..exp_dat.." `ÙÙÙ`\n" .."Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`lock | ð`'
	else
	mute_all = '`unlock | ð`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`lock | ð`'
	else
	mute_text = '`unlock | ð`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`lock | ð`'
	else
	mute_photo = '`unlock | ð`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`lock | ð`'
	else
	mute_video = '`unlock | ð`'
end

	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`lock | ð`'
	else
	mute_gifs = '`unlock | ð`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`lock | ð`'
	else
	mute_music = '`unlock | ð`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`lock | ð`'
	else
	mute_in = '`unlock | ð`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`lock | ð`'
	else
	mute_voice = '`unlock | ð`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`lock | ð`'
	else
	mute_links = '`unlock | ð`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`lock | ð`'
	else
	lock_sticker = '`unlock | ð`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`lock | ð`'
	else
	lock_cmd = '`unlock | ð`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`lock | ð`'
	else
	lock_wp = '`unlock | ð`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`lock | ð`'
	else
	lock_htag = '`unlock | ð`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`lock | ð`'
	else
	lock_tag = '`unlock | ð`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`lock | ð`'
	else
	lock_location = '`unlock | ð`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`lock | ð`'
	else
	lock_contact = '`unlock | ð`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`lock | ð`'
	else
	lock_english = '`unlock | ð`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`lock | ð`'
	else
	lock_arabic = '`unlock | ð`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`lock | ð`'
	else
	lock_forward = '`unlock | ð`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`lock | ð`'
	else
	mute_doc = '`unlock | ð`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`lock | ð`'
	else
	mute_mdd = '`unlock | ð`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Ban*\n======================\n*Ban all* : "..mute_all.."\n" .."*Ban Links* : "..mute_links.."\n" .."*Ban Inline* : "..mute_in.."\n" .."*Ban English* : "..lock_english.."\n" .."*Ban Forward* : "..lock_forward.."\n" .."*Ban Arabic* : "..lock_arabic.."\n" .."*Ban Hashtag* : "..lock_htag.."\n".."*Ban tag* : "..lock_tag.."\n" .."*Ban Webpage* : "..lock_wp.."\n" .."*Ban Location* : "..lock_location.."\n"
.."*Ban Photo* : "..mute_photo.."\n" .."*Ban Text* : "..mute_text.."\n" .."*Ban Gifs* : "..mute_gifs.."\n" .."*Ban Voice* : "..mute_voice.."\n" .."*Ban Music* : "..mute_music.."\n" .."*Ban Video* : "..mute_video.."\n*Ban Cmd* : "..lock_cmd.."\n"  .."*Ban Markdown* : "..mute_mdd.."\n*Ban Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
          local text = msg.content_.text_:gsub('Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØ·Ø±Ø¯','sdd3')
  	 if text:match("^[Ss][Dd][Dd]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`ÙÙØ¹Ù | ð`'
	else
	mute_all = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`ÙÙØ¹Ù | ð`'
	else
	mute_text = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`ÙÙØ¹Ù | ð`'
	else
	mute_photo = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`ÙÙØ¹Ù | ð`'
	else
	mute_video = '`ÙØ¹Ø·Ù | ð`'
end
	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`ÙÙØ¹Ù | ð`'
	else
	mute_gifs = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`ÙÙØ¹Ù | ð`'
	else
	mute_music = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`ÙÙØ¹Ù | ð`'
	else
	mute_in = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`ÙÙØ¹Ù | ð`'
	else
	mute_voice = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`ÙÙØ¹Ù | ð`'
	else
	mute_links = '`ÙØ¹Ø·Ù | ð`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`ÙÙØ¹Ù | ð`'
	else
	lock_sticker = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`ÙÙØ¹Ù | ð`'
	else
	lock_cmd = '`ÙØ¹Ø·Ù | ð`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`ÙÙØ¹Ù | ð`'
	else
	lock_wp = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`ÙÙØ¹Ù | ð`'
	else
	lock_htag = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`ÙÙØ¹Ù | ð`'
	else
	lock_tag = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`ÙÙØ¹Ù | ð`'
	else
	lock_location = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`ÙÙØ¹Ù | ð`'
	else
	lock_contact = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`ÙÙØ¹Ù | ð`'
	else
	lock_english = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`ÙÙØ¹Ù | ð`'
	else
	lock_arabic = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`ÙÙØ¹Ù | ð`'
	else
	lock_forward = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`ÙÙØ¹Ù | ð`'
	else
	mute_doc = '`ÙØ¹Ø·Ù | ð`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`ÙÙØ¹Ù | ð`'
	else
	mute_mdd = '`ÙØ¹Ø·Ù | ð`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`ÙØ§ ÙÙØ§Ø¦Ù`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "â¢ `Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ¬ÙÙØ¹Ù Ø¨Ø§ÙØ·Ø±Ø¯`\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ `ÙÙ Ø§ÙÙØ³Ø§Ø¦Ø·` : "..mute_all.."\n"
	 .."â¢ `Ø§ÙØ±ÙØ§Ø¨Ø·` : "..mute_links.."\n" 
	 .."â¢ `Ø§ÙØ§ÙÙØ§ÙÙ` : "..mute_in.."\n"
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ` : "..lock_english.."\n"
	 .."â¢ `Ø§Ø¹Ø§Ø¯Ù Ø§ÙØªÙØ¬ÙÙ` : "..lock_forward.."\n" 
	 .."â¢ `Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ` : "..lock_arabic.."\n"
	 .."â¢ `Ø§ÙØªØ§ÙØ§Øª` : "..lock_htag.."\n"
	 .."â¢ `Ø§ÙÙØ¹Ø±ÙØ§Øª` : "..lock_tag.."\n" 
	 .."â¢ `Ø§ÙÙÙØ§ÙØ¹` : "..lock_wp.."\n" 
	 .."â¢ `Ø§ÙØ´Ø¨ÙØ§Øª` : "..lock_location.."\n\n"
   .."â¢ `Ø§ÙØµÙØ±` : "..mute_photo.."\n" 
   .."â¢ `Ø§ÙØ¯Ø±Ø¯Ø´Ù` : "..mute_text.."\n" 
   .."â¢ `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ` : "..mute_gifs.."\n" 
   .."â¢ `Ø§ÙÙÙØµÙØ§Øª` : "..lock_sticker.."\n"
	 .."â¢ `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù` : "..lock_contact.."\n" 
   .."â¢ `Ø§ÙØµÙØªÙØ§Øª` : "..mute_voice.."\n"
   .."â¢ `Ø§ÙØ§ØºØ§ÙÙ` : "..mute_music.."\n"  
   .."â¢ `Ø§ÙÙÙØ¯ÙÙÙØ§Øª` : "..mute_video.."\nâ¢ `Ø§ÙØ´Ø§Ø±Ø­Ù` : "..lock_cmd.."\n"
   .."â¢ `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ` : "..mute_mdd.."\nâ¢ `Ø§ÙÙÙÙØ§Øª` : "..mute_doc.."\n" 
   .."â¢ `Ø§ÙÙØ¶Ø§Ø¡ Ø§ÙØ¨ÙØª` : "..exp_dat.." `ÙÙÙ`\n" .."Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
     
  ----------------------------------------------------------------------------------------------- 
if text:match("^[Dd][Ee][Vv]$")or text:match("^ÙØ·ÙØ± Ø¨ÙØª$") or text:match("^ÙØ·ÙØ±ÙÙ$") or text:match("^ÙØ·ÙØ± Ø§ÙØ¨ÙØª$") or text:match("^ÙØ·ÙØ±$") or text:match("^Ø§ÙÙØ·ÙØ±$") and msg.reply_to_message_id_ == 0 then
local nkeko = redis:get('nmkeko'..bot_id)
local nakeko = redis:get('nakeko'..bot_id)
  
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, (nkeko or 9647717463622), (nakeko or "AHMED TALEB"), "", bot_id)
end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('ØªØºÙØ± Ø§ÙØ± Ø§ÙÙØ·ÙØ±','change ph')
if text:match("^[Cc][Hh][Aa][Nn][Gg][Ee] [Pp][Hh]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *developer number*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§Ù ÙÙÙÙÙ Ø§Ø±Ø³Ø§Ù Ø±ÙÙ Ø§ÙÙØ·ÙØ±` ð³', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^+(.*)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *name of the developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§Ù ÙÙÙÙÙ Ø§Ø±Ø³Ø§Ù Ø§ÙØ§Ø³Ù Ø§ÙØ°Ù ØªØ±ÙØ¯Ù` ð·', 1, 'md')
end
redis:set('nmkeko'..bot_id, text)  
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'mmsg')  
  return false end  
end
if text:match("^(.*)$") then
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'mmsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved Send a_ *DEV to watch the changes*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø­ÙØ¸ Ø§ÙØ§Ø³Ù ÙÙÙÙÙ Ø§Ø¸ÙØ§Ø± Ø§ÙØ¬Ù Ø¨Ù Ø§Ø±Ø³Ø§Ù Ø§ÙØ± Ø§ÙÙØ·ÙØ±` âï¸', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:set('nakeko'..bot_id, text)  
local nmkeko = redis:get('nmkeko'..bot_id)
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, nmkeko, text , "", bot_id)
  return false end  
end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('Ø§Ø¶Ù ÙØ·ÙØ±','add sudo')
if text:match("^[Aa][Dd][Dd] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§Ù ÙÙÙÙÙ Ø§Ø±Ø³Ø§Ù Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± Ø§ÙØ°Ù ØªØ±ÙØ¯ Ø±ÙØ¹Ù`ð¡', 1, 'md')
end
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^(%d+)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('qkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been added_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø§Ø¶Ø§ÙØªÙ`  '..text..' `ÙØ·ÙØ± ÙÙØ¨ÙØª`âï¸', 1, 'md')
end
redis:set('sudoo'..text..''..bot_id, 'yes')  
redis:sadd('dev'..bot_id, text)
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'no')  
  return false end  
end  

  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('Ø­Ø°Ù ÙØ·ÙØ±','rem sudo')
if text:match("^[Rr][Ee][Mm] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§Ù ÙÙÙÙÙ Ø§Ø±Ø³Ø§Ù Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± Ø§ÙØ°Ù ØªØ±ÙØ¯ Ø­Ø°ÙÙ`ð', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
end
if text:match("^(%d+)$") then
local keko2 = redis:get('xkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been removed_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø­Ø°ÙÙ`  '..text..' `ÙÙ ÙØ·ÙØ±ÙÙ Ø§ÙØ¨ÙØª`â ï¸', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:del('sudoo'..text..''..bot_id, 'no')  
 end  
end

local text = msg.content_.text_:gsub('Ø§Ø¶Ù Ø±Ø¯','add rep')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§Ø±Ø³Ù Ø§ÙÙÙÙÙ Ø§ÙØªÙ ØªØ±ÙØ¯ Ø§Ø¶Ø§ÙØªÙØ§ ð¬', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repowner:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id..''..msg.chat_id_..'')
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§ÙØ§Ù Ø§Ø±Ø³Ù Ø§ÙØ±Ø¯ Ø§ÙØ°Ù ØªØ±ÙØ¯ Ø§Ø¶Ø§ÙØªÙ ð­', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('repowner'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
redis:set('keko'..keko2..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('kekore'..bot_id..''..msg.chat_id_..'', keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ Ø­ÙØ¸ Ø§ÙØ±Ø¯` âï¸", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
end
end  

local text = msg.content_.text_:gsub('Ø­Ø°Ù Ø±Ø¯','rem rep')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§Ø±Ø³Ù Ø§ÙÙÙÙÙ Ø§ÙØªÙ ØªØ±ÙØ¯ Ø­Ø°ÙÙØ§ ð', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ ØªÙ Ø­Ø°Ù Ø§ÙØ±Ø¯ â ï¸', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
redis:set('keko'..text..''..bot_id..''..msg.chat_id_..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('Ø§Ø¶Ù Ø±Ø¯ ÙÙÙÙ','add rep all')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§Ø±Ø³Ù Ø§ÙÙÙÙÙ Ø§ÙØªÙ ØªØ±ÙØ¯ Ø§Ø¶Ø§ÙØªÙØ§ ð¬', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repsudo:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id)
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§ÙØ§Ù Ø§Ø±Ø³Ù Ø§ÙØ±Ø¯ Ø§ÙØ°Ù ØªØ±ÙØ¯ Ø§Ø¶Ø§ÙØªÙ ð­', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id, text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id)
redis:set('keko'..keko2..''..bot_id, text)  
redis:sadd('kekoresudo'..bot_id, keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ Ø­ÙØ¸ Ø§ÙØ±Ø¯` âï¸", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
end
end  
 
local text = msg.content_.text_:gsub('Ø­Ø°Ù Ø±Ø¯ ÙÙÙÙ','rem rep all')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ Ø§Ø±Ø³Ù Ø§ÙÙÙÙÙ Ø§ÙØªÙ ØªØ±ÙØ¯ Ø­Ø°ÙÙØ§ ð', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, 'â¢ ØªÙ Ø­Ø°Ù Ø§ÙØ±Ø¯ â ï¸', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
 redis:set('keko'..text..''..bot_id..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('ÙØ³Ø­ Ø§ÙÙØ·ÙØ±Ùï¿½ï¿½','clean sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
  local list = redis:smembers('dev'..bot_id)
  for k,v in pairs(list) do
redis:del('dev'..bot_id, text)
redis:del('sudoo'..v..''..bot_id, 'no')  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Bot developers_ *have been cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ ÙØ³Ø­ ÙØ·ÙØ±ÙÙ Ø§ÙØ¨ÙØª` ð", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±','clean rep owner')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  for k,v in pairs(list) do
redis:del('kekore'..bot_id..''..msg.chat_id_..'', text)
redis:set('keko'..v..''..bot_id..''..msg.chat_id_..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Owner replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±` ð", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±','clean rep sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Ss][Uu][Dd][Oo]$") and is_sudo(msg) then
  local list = redis:smembers('kekoresudo'..bot_id)
  for k,v in pairs(list) do
redis:del('kekoresudo'..bot_id, text)
redis:set('keko'..v..''..bot_id..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Sudo replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` ð", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('Ø§ÙÙØ·ÙØ±ÙÙ','sudo list')
if text:match("^[Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local list = redis:smembers('dev'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Sudo List :</b>\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- added\nâ¢ â :- Deleted\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø§ÙÙØ·ÙØ±ÙÙ </code>â¬ï¸ :\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- ØªÙ Ø±ÙØ¹Ù\nâ¢ â :- ØªÙ ØªÙØ²ÙÙÙ\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
  end
	for k,v in pairs(list) do
			local keko11 = redis:get('sudoo'..v..''..bot_id)
			local botlua = "â"
       if keko11 == 'yes' then
       botlua = "â"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Sudo List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ ÙØ·ÙØ±ÙÙ</code> â ï¸"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±','rep sudo list')
if text:match("^[Rr][Ee][Pp] [Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and is_sudo(msg) then
	local list = redis:smembers('kekoresudo'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep sudo List :</b>\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- Enabled\nâ¢ â :- Disabled\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± </code>â¬ï¸ :\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- ÙÙØ¹ÙÙ\nâ¢ â :- ÙØ¹Ø·ÙÙ\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
  end
	for k,v in pairs(list) do
  local keko11 = redis:get('keko'..v..''..bot_id)
			local botlua = "â"
       if keko11 == ' ' then
       botlua = "â"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep sudo List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ Ø±Ø¯ÙØ¯ ÙÙÙØ·ÙØ±</code> â ï¸"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±','rep owner list')
if text:match("^[Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr] [Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep owner List :</b>\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- Enabled\nâ¢ â :- Disabled\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
else 
  text = "â¢ <code>ÙØ§Ø¦ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± </code>â¬ï¸ :\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\nâ¢ â :- ÙÙØ¹ÙÙ\nâ¢ â :- ÙØ¹Ø·ÙÙ\nÖ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö\n"
  end
	for k,v in pairs(list) do
    local keko11 = redis:get('keko'..v..''..bot_id..''..msg.chat_id_..'')
			local botlua = "â"
       if keko11 == ' ' then
       botlua = "â"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep owner List is empty !</b>"
              else 
                text = "â¢ <code>ÙØ§ ÙÙØ¬Ø¯ Ø±Ø¯ÙØ¯ ÙÙÙØ¯ÙØ±</code> â ï¸"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ±Ø±','echo')
  	if text:match("^echo (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(echo) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ÙÙØ§ÙÙÙ','setrules')
  	if text:match("^[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, "*> Group rules upadted..._", 1, 'md')
   else 
         send(msg.chat_id_, msg.id_, 1, "â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙÙÙØ§ÙÙÙ ÙÙÙØ¬ÙÙØ¹Ù` ðâï¸", 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Rr][Uu][Ll][Ee][Ss]$")or text:match("^Ø§ÙÙÙØ§ÙÙÙ$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
	if rules then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Group Rules :*\n'..rules, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙØ§ÙÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù ÙÙ  :` â¬ï¸\n'..rules, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*rules msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ ÙØªÙ Ø­ÙØ¸ ÙÙØ§ÙÙÙ ÙÙÙØ¬ÙÙØ¹Ù` â ï¸â', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
     local text = msg.content_.text_:gsub('ÙØ¶Ø¹ Ø§Ø³Ù','setname')
		if text:match("^[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Nn][Aa][Mm][Ee]) (.*)$")}
	     changetitle(msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group name updated!_\n'..txt[2], 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ­Ø¯ÙØ« Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù Ø§ÙÙ âï¸â¬ï¸`\n'..txt[2], 1, 'md')
         end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo]$") or text:match("^ÙØ¶Ø¹ ØµÙØ±Ù") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Please send a photo noew!_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ Ø¨Ø§Ø±Ø³Ø§Ù ØµÙØ±Ù Ø§ÙØ§Ù` âï¸ð', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÙØ¶Ø¹ ÙÙØª','setexpire')
	if text:match("^[Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^([Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee]) (%d+)$")} 
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group Charged for_ *'..a[2]..'* _Days_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ ÙÙØª Ø§ÙØªÙØ§Ø¡ Ø§ÙØ¨ÙØª` *'..a[2]..'* `ÙÙÙ` â ï¸â', 1, 'md')
end
  end
  
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Tt][Aa][Tt][Ss]$") or text:match("^Ø§ÙÙÙØª$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
                if database:get('lang:gp:'..msg.chat_id_) then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
else 
		send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù ÙØ§ ÙÙØ§Ø¦Ù` âï¸', 1, 'md')
end
       else
        local d = math.floor(ex / day ) + 1
                if database:get('lang:gp:'..msg.chat_id_) then
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group Days*", 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, "â¢ `Ø¹Ø¯Ø¯ Ø§ÙØ§Ù ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù` â¬ï¸\n"..d.." `ÙÙÙ` ð", 1, 'md')
end
       end
    end
	-----------------------------------------------------------------------------------------------
    
	if text:match("^ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù ÙØ§ ÙÙØ§Ø¦Ù` âï¸', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
send(msg.chat_id_, msg.id_, 1, "â¢ `Ø¹Ø¯Ø¯ Ø§ÙØ§Ù ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù` â¬ï¸\n"..d.." `ÙÙÙ` ð", 1, 'md')
       end
    end
    
	if text:match("^[Ss][Tt][Aa][Tt][Ss] [Gg][Pp] (-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Tt][Aa][Tt][Ss] [Gg][Pp]) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group is Days*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
	 if is_sudo(msg) then
  -----------------------------------------------------------------------------------------------
  if text:match("^[Ll][Ee][Aa][Vv][Ee] (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^([Ll][Ee][Aa][Vv][Ee]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '*Group* '..txt[2]..' *remov*', 1, 'md')
	   send(txt[2], 0, 1, '*Error*\n_Group is not my_', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  
  if text:match("^ÙØºØ§Ø¯Ø±Ù (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^(ÙØºØ§Ø¯Ø±Ù) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù` '..txt[2]..' `ØªÙ Ø§ÙØ®Ø±ÙØ¬ ÙÙÙØ§` âï¸ð', 1, 'md')
	   send(txt[2], 0, 1, 'â¢ `ÙØ°Ù ÙÙØ³Øª Ø¶ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ø§Øª Ø§ÙØ®Ø§ØµØ© Ø¨Ù` â ï¸â', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^Ø§ÙÙØ¯Ù1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(Ø§ÙÙØ¯Ù1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù` '..txt[2]..' `ØªÙ Ø§Ø¹Ø§Ø¯Ø© ØªÙØ¹ÙÙÙØ§ Ø§ÙÙØ¯Ø© 30 ÙÙÙ âï¸ð`', 1, 'md')
	   send(txt[2], 0, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ ÙØ¯Ø© Ø§ÙÙØ¬ÙÙØ¹Ù 30 ÙÙÙ` âï¸ð', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "â¢ `ÙØ§Ù Ø¨ØªÙØ¹ÙÙ ÙØ¬ÙÙØ¹Ù Ø§ÙÙØ¯Ù ÙØ§ÙØª 30 ÙÙÙ âï¸` : \nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± ð` : "..msg.sender_user_id_.."\nâ¢ `ÙØ¹Ø±Ù Ø§ÙÙØ·ÙØ± ð¹` : "..get_info(msg.sender_user_id_).."\n\nâ¢ `ÙØ¹ÙÙÙØ§Øª Ø§ÙÙØ¬ÙÙØ¹Ù ð¥` :\n\nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..msg.chat_id_.."\nâ¢ `Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 30 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 30 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^Ø§ÙÙØ¯Ù2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(Ø§ÙÙØ¯Ù2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù` '..txt[2]..' `ØªÙ Ø§Ø¹Ø§Ø¯Ø© ØªÙØ¹ÙÙÙØ§ Ø§ÙÙØ¯Ø© 90 ÙÙÙ âï¸ð`', 1, 'md')
	   send(txt[2], 0, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ ÙØ¯Ø© Ø§ÙÙØ¬ÙÙØ¹Ù 90 ÙÙÙ` âï¸ð', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "â¢ `ÙØ§Ù Ø¨ØªÙØ¹ÙÙ ÙØ¬ÙÙØ¹Ù Ø§ÙÙØ¯Ù ÙØ§ÙØª 90 ÙÙÙ âï¸` : \nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± ð` : "..msg.sender_user_id_.."\nâ¢ `ÙØ¹Ø±Ù Ø§ÙÙØ·ÙØ± ð¹` : "..get_info(msg.sender_user_id_).."\n\nâ¢ `ÙØ¹ÙÙÙØ§Øª Ø§ÙÙØ¬ÙÙØ¹Ù ð¥` :\n\nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..msg.chat_id_.."\nâ¢ `Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
-------------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 90 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 90 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^Ø§ÙÙØ¯Ù3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(Ø§ÙÙØ¯Ù3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù` '..txt[2]..' `ØªÙ Ø§Ø¹Ø§Ø¯Ø© ØªÙØ¹ÙÙÙØ§ Ø§ÙÙØ¯Ø© ÙØ§ ÙÙØ§Ø¦ÙØ© âï¸ð`', 1, 'md')
	   send(txt[2], 0, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ ÙØ¯Ø© Ø§ÙÙØ¬ÙÙØ¹Ù ÙØ§ ÙÙØ§Ø¦ÙØ©` âï¸ð', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "â¢ `ÙØ§Ù Ø¨ØªÙØ¹ÙÙ ÙØ¬ÙÙØ¹Ù Ø§ÙÙØ¯Ù ÙØ§ÙØª ÙØ§ ÙÙØ§Ø¦ÙØ© âï¸` : \nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± ð` : "..msg.sender_user_id_.."\nâ¢ `ÙØ¹Ø±Ù Ø§ÙÙØ·ÙØ± ð¹` : "..get_info(msg.sender_user_id_).."\n\nâ¢ `ÙØ¹ÙÙÙØ§Øª Ø§ÙÙØ¬ÙÙØ¹Ù ð¥` :\n\nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..msg.chat_id_.."\nâ¢ `Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done Days No Fanil Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done Days No Fanil Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
local text = msg.content_.text_:gsub('ØªÙØ¹ÙÙ','add')
  if text:match('^[Aa][Dd][Dd]$') and is_sudo(msg) then
  local txt = {string.match(text, "^([Aa][Dd][Dd])$")} 
  if database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already Added Group*', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, "â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù [ "..chat.title_.." ] ÙÙØ¹ÙÙ Ø³Ø§Ø¨ÙØ§` âï¸", 1, 'md')
end
                  end
       if not database:get("bot:charge:"..msg.chat_id_) then
       database:set("bot:charge:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Added To Group*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "â¢ `Ø§ÙØ¯ÙÙ ð :` _"..msg.sender_user_id_.."_\nâ¢ `ØªÙ` âï¸ `ØªÙØ¹ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù [ "..chat.title_.." ]` âï¸", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> added bot to new group*" , 1, 'md')
      else  
            send(v, 0, 1, "â¢ `ÙØ§Ù Ø¨ØªÙØ¹ÙÙ ÙØ¬ÙÙØ¹Ù Ø¬Ø¯ÙØ¯Ù âï¸` : \nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± ð` : "..msg.sender_user_id_.."\nâ¢ `ÙØ¹Ø±Ù Ø§ÙÙØ·ÙØ± ð¹` : "..get_info(msg.sender_user_id_).."\n\nâ¢ `ÙØ¹ÙÙÙØ§Øª Ø§ÙÙØ¬ÙÙØ¹Ù ð¥` :\n\nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..msg.chat_id_.."\nâ¢ `Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..chat.title_ , 1, 'md')
end
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ØªØ¹Ø·ÙÙ','rem')
  if text:match('^[Rr][Ee][Mm]$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Rr][Ee][Mm])$")} 
      if not database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already remove Group*', 1, 'md')
    else 
        send(msg.chat_id_, msg.id_, 1, "â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù [ "..chat.title_.." ] ÙØ¹Ø·ÙÙ Ø³Ø§Ø¨ÙØ§` â ï¸", 1, 'md')
end
                  end
      if database:get("bot:charge:"..msg.chat_id_) then
       database:del("bot:charge:"..msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Removed To Group!*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "â¢ `Ø§ÙØ¯ÙÙ ð :` _"..msg.sender_user_id_.."_\nâ¢ `ØªÙ` âï¸ `ØªØ¹Ø·ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù [ "..chat.title_.." ]` â ï¸", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Removed bot from new group*" , 1, 'md')
      else 
            send(v, 0, 1, "â¢ `ÙØ§Ù Ø¨ØªØ¹Ø·ÙÙ ÙØ¬ÙÙØ¹Ù â ï¸` : \nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ·ÙØ± ð` : "..msg.sender_user_id_.."\nâ¢ `ÙØ¹Ø±Ù Ø§ÙÙØ·ÙØ± ð¹` : "..get_info(msg.sender_user_id_).."\n\nâ¢ `ÙØ¹ÙÙÙØ§Øª Ø§ÙÙØ¬ÙÙØ¹Ù ð¥` :\n\nâ¢ `Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..msg.chat_id_.."\nâ¢ `Ø§Ø³Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð` : "..chat.title_ , 1, 'md')
end
       end
  end
  end
              
  -----------------------------------------------------------------------------------------------
   if text:match('^[Jj][Oo][Ii][Nn] (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Jj][Oo][Ii][Nn]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *is join*', 1, 'md')
	   send(txt[2], 0, 1, '*Sudo Joined To Grpup*', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
  -----------------------------------------------------------------------------------------------
   if text:match('^Ø§Ø¶Ø§ÙÙ (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(Ø§Ø¶Ø§ÙÙ) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙØ¬ÙÙØ¹Ù` '..txt[2]..' `ØªÙ Ø§Ø¶Ø§ÙØªÙ ÙÙØ§ ` âï¸', 1, 'md')
	   send(txt[2], 0, 1, 'â¢ `ØªÙ Ø§Ø¶Ø§ÙÙ Ø§ÙÙØ·ÙØ± ÙÙÙØ¬ÙÙØ¹Ù` âï¸ð', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
   -----------------------------------------------------------------------------------------------
  end
	-----------------------------------------------------------------------------------------------
     if text:match("^[Dd][Ee][Ll]$")  and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÙØ³Ø­$") and msg.reply_to_message_id_ ~= 0 and is_mod(msg.sender_user_id_, msg.chat_id_) then
     delete_msg(msg.chat_id_, {[0] = msg.reply_to_message_id_})
     delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
	----------------------------------------------------------------------------------------------
   if text:match('^ØªÙØ¸ÙÙ (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^(ØªÙØ¸ÙÙ) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = 'â¢ <code> ÙØ§ ØªØ³ØªØ·ÙØ¹ Ø­Ø°Ù Ø§ÙØ«Ø± ÙÙ 100 Ø±Ø³Ø§ÙÙ âï¸â ï¸</code>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])}, delmsg, nil)
      pm ='â¢ <i>[ '..matches[2]..' ]</i> <code>ÙÙ Ø§ÙØ±Ø³Ø§Ø¦Ù ØªÙ Ø­Ø°ÙÙØ§ âï¸â</code>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='â¢ <code> ÙÙØ§Ù Ø®Ø·Ø§<code> â ï¸'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
              end
            end


   if text:match('^[Dd]el (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^([Dd]el) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '<b>> Error</b>\n<b>use /del [1-1000] !<bb>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
      pm ='> <i>'..matches[2]..'</i> <b>Last Msgs Has Been Removed.</b>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='<b>> found!<b>'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                end
              end

          local text = msg.content_.text_:gsub('Ø­ÙØ¸','note')
    if text:match("^[Nn][Oo][Tt][Ee] (.*)$") and is_sudo(msg) then
    local txt = {string.match(text, "^([Nn][Oo][Tt][Ee]) (.*)$")}
      database:set('owner:note1', txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*save!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø­ÙØ¸ Ø§ÙÙÙÙØ´Ù âï¸`', 1, 'md')
end
    end

    if text:match("^[Dd][Nn][Oo][Tt][Ee]$") or text:match("^Ø­Ø°Ù Ø§ÙÙÙÙØ´Ù$") and is_sudo(msg) then
      database:del('owner:note1',msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Deleted!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø­Ø°Ù Ø§ÙÙÙÙØ´Ù â ï¸`', 1, 'md')
end
      end
  -----------------------------------------------------------------------------------------------
    if text:match("^[Gg][Ee][Tt][Nn][Oo][Tt][Ee]$") and is_sudo(msg) or text:match("^Ø¬ÙØ¨ Ø§ÙÙÙÙØ´Ù$") and is_sudo(msg) then
    local note = database:get('owner:note1')
	if note then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note is :-*\n'..note, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙÙÙÙØ´Ù Ø§ÙÙØ­ÙÙØ¸Ù â¬ï¸ :`\n'..note, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙØ§ ÙÙØ¬Ø¯ ÙÙÙØ´Ù ÙØ­ÙÙØ¸Ù â ï¸`', 1, 'md')
end
	end
end

  if text:match("^[Ss][Ee][Tt][Ll][Aa][Nn][Gg] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ØªØ­ÙÙÙ (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local langs = {string.match(text, "^(.*) (.*)$")}
  if langs[2] == "ar" or langs[2] == "Ø¹Ø±Ø¨ÙÙ" then
  if not database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø¨Ø§ÙÙØ¹Ù ØªÙ ÙØ¶Ø¹ Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ ÙÙØ¨ÙØª â ï¸`', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ÙØ¶Ø¹ Ø§ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ ÙÙØ¨ÙØª ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù âï¸`', 1, 'md')
       database:del('lang:gp:'..msg.chat_id_)
    end
    end
  if langs[2] == "en" or langs[2] == "Ø§ÙÙÙÙØ²ÙÙ" then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '_> Language Bot is already_ *English*', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '> _Language Bot has been changed to_ *English* !', 1, 'md')
        database:set('lang:gp:'..msg.chat_id_,true)
    end
    end
end
----------------------------------------------------------------------------------------------

  if text == "unlock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already enabled*ï¸', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ¹ÙÙÙØ§` âï¸', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been enable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª` âï¸', 1, 'md')
       database:del('bot:rep:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already disabled*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªØ¹Ø·ÙÙÙØ§` â ï¸', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been disable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª` â ï¸', 1, 'md')
        database:set('bot:rep:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------

  if text == "unlock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already enabled*ï¸', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ¹ÙÙÙØ§` âï¸', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been enable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` âï¸', 1, 'md')
       database:del('bot:repsudo:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already disabled*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªØ¹Ø·ÙÙÙØ§` â ï¸', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been disable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` â ï¸', 1, 'md')
        database:set('bot:repsudo:mute'..msg.chat_id_,true)
      end
    end
  end
  
  if text == "unlock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already enabled*ï¸', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ¹ÙÙÙØ§` âï¸', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been enable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±` âï¸', 1, 'md')
       database:del('bot:repowner:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already disabled*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªØ¹Ø·ÙÙÙØ§` â ï¸', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been disable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±` â ï¸', 1, 'md')
        database:set('bot:repowner:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Dd][Gg][Pp]$") or text:match("^Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù$") then
    send(msg.chat_id_, msg.id_, 1, "*"..msg.chat_id_.."*", 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
  if text == "unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªÙØ¹ÙÙ Ø§ÙØ§ÙØ¯Ù" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already enabled*ï¸', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§ÙØ¯Ù Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªÙØ¹ÙÙÙ` âï¸', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been enable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªÙØ¹ÙÙ Ø§ÙØ§ÙØ¯Ù` âï¸', 1, 'md')
       database:del('bot:id:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ØªØ¹Ø·ÙÙ Ø§ÙØ§ÙØ¯Ù" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already disabled*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§ÙØ¯Ù Ø¨Ø§ÙÙØ¹Ù ØªÙ ØªØ¹Ø·ÙÙÙ` â ï¸', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been disable*ï¸', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ¹Ø·ÙÙ Ø§ÙØ§ÙØ¯Ù` â ï¸', 1, 'md')
        database:set('bot:id:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
if  text:match("^[Ii][Dd]$") and msg.reply_to_message_id_ == 0 or text:match("^Ø§ÙØ¯Ù$") and msg.reply_to_message_id_ == 0 then
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
      if is_sudo(msg) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Sudo'
      else
      t = 'ÙØ·ÙØ± Ø§ÙØ¨ÙØª âï¸'
      end
      elseif is_admin(msg.sender_user_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Global Admin'
      else
      t = 'Ø§Ø¯ÙÙ ÙÙ Ø§ÙØ¨ÙØª âï¸'
      end
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Owner'
      else
      t = 'ÙØ¯ÙØ± Ø§ÙÙØ±ÙØ¨ âï¸'
      end
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'Ø§Ø¯ÙÙ ÙÙÙØ±ÙØ¨ ð'
      end
      elseif is_vip(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'Ø¹Ø¶Ù ÙÙÙØ²ð'
      end
      else
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Member'
      else
      t = 'Ø¹Ø¶Ù ÙÙØ· â ï¸'
      end
    end
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"> Group ID : "..msg.chat_id_.."\n> Your ID : "..msg.sender_user_id_.."\n> UserName : "..get_info(msg.sender_user_id_).."\n> Your Rank : "..t.."\n> Msgs : "..user_msgs,msg.id_,msg.id_.."")
  else 
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"â¢ Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ð : "..msg.chat_id_.."\nâ¢ Ø§ÙØ¯ÙÙ ð : "..msg.sender_user_id_.."\nâ¢ ÙØ¹Ø±ÙÙ ð¹ : "..get_info(msg.sender_user_id_).."\nâ¢ ÙÙÙØ¹Ù *ï¸â£ : "..t.."\nâ¢ Ø±Ø³Ø§Ø¦ÙÙ ð : "..user_msgs,msg.id_,msg.id_.."")
end
else 
      end
   else
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!\n\n> *> Group ID :* "..msg.chat_id_.."\n*> Your ID :* "..msg.sender_user_id_.."\n*> UserName :* "..get_info(msg.sender_user_id_).."\n*> Msgs : *_"..user_msgs.."_", 1, 'md')
   else 
      send(msg.chat_id_, msg.id_, 1, "â¢`Ø§ÙØª ÙØ§ ØªÙÙÙ ØµÙØ±Ù ÙØ­Ø³Ø§Ø¨Ù ` âï¸\n\nâ¢` Ø§ÙØ¯Ù Ø§ÙÙØ¬ÙÙØ¹Ù ` ð : "..msg.chat_id_.."\nâ¢` Ø§ÙØ¯ÙÙ ` ð : "..msg.sender_user_id_.."\nâ¢` ÙØ¹Ø±ÙÙ ` ð¹ : "..get_info(msg.sender_user_id_).."\nâ¢` Ø±Ø³Ø§Ø¦ÙÙ `ð : _"..user_msgs.."_", 1, 'md')
end
else 
      end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
end

   if text:match('^Ø§ÙØ­Ø³Ø§Ø¨ (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^Ø§ÙØ­Ø³Ø§Ø¨ (%d+)$')
        local text = 'Ø§Ø¶ØºØ· ÙÙØ´Ø§ÙØ¯Ù Ø§ÙØ­Ø³Ø§Ø¨'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end 

   if text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$')
        local text = 'Click to view user!'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end
          local text = msg.content_.text_:gsub('ÙØ¹ÙÙÙØ§Øª','res')
          if text:match("^[Rr][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([Rr][Ee][Ss]) (.*)$")}
            function whois(extra,result,success)
                if result.username_ then
             result.username_ = '@'..result.username_
               else
             result.username_ = 'ÙØ§ ÙÙØ¬Ø¯ ÙØ¹Ø±Ù'
               end
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> *Name* :'..result.first_name_..'\n> *Username* : '..result.username_..'\n> *ID* : '..msg.sender_user_id_, 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, 'â¢ `Ø§ÙØ§Ø³Ù` ð : '..result.first_name_..'\nâ¢ `Ø§ÙÙØ¹Ø±Ù` ð¹ : '..result.username_..'\nâ¢ `Ø§ÙØ§ÙØ¯Ù` ð : '..msg.sender_user_id_, 1, 'md')
              end
            end
            getUser(memb[2],whois)
          end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ØªØ«Ø¨ÙØª$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
	            send(msg.chat_id_, msg.id_, 1, '_Msg han been_ *pinned!*', 1, 'md')
	           else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ ØªØ«Ø¨ÙØª Ø§ÙØ±Ø³Ø§ÙÙ` âï¸', 1, 'md')
end
 end

   if text:match("^[Vv][Ii][Ee][Ww]$") or text:match("^ÙØ´Ø§ÙØ¯Ù ÙÙØ´ÙØ±$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
    if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*Please send a post now!*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, 'â¢ `ÙÙ Ø¨Ø§Ø±Ø³Ø§Ù Ø§ÙÙÙØ´ÙØ± Ø§ÙØ§Ù` âï¸', 1, 'md')
end
   end
  end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Uu][Nn][Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙØºØ§Ø¡ ØªØ«Ø¨ÙØª$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^Ø§ÙØºØ§Ø¡ Ø§ÙØªØ«Ø¨ÙØª") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Pinned Msg han been_ *unpinned!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, 'â¢ `ØªÙ Ø§ÙØºØ§Ø¡ ØªØ«Ø¨ÙØª Ø§ÙØ±Ø³Ø§ÙÙ` â ï¸', 1, 'md')
end
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Hh][Ee][Ll][Pp]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
`ÙÙØ§Ù`  *6* `Ø§ÙØ§ÙØ± ÙØ¹Ø±Ø¶ÙØ§`
*======================*
*h1* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ`
*======================*
*h2* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±`
*======================*
*h3* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯`
*======================*
*h4* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ§Ø¯ÙÙÙÙ`
*======================*
*h5* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙÙØ¬ÙÙØ¹Ù`
*======================*
*h6* `ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙÙØ·ÙØ±ÙÙ`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ÙÙÙÙÙ`
*unlock* `ÙÙÙØªØ­`
*======================*
*| links |* `Ø§ÙØ±ÙØ§Ø¨Ø·`
*| tag |* `Ø§ÙÙØ¹Ø±Ù`
*| hashtag |* `Ø§ÙØªØ§Ù`
*| cmd |* `Ø§ÙØ³ÙØ§Ø´`
*| edit |* `Ø§ÙØªØ¹Ø¯ÙÙ`
*| webpage |* `Ø§ÙØ±ÙØ§Ø¨Ø· Ø§ÙØ®Ø§Ø±Ø¬ÙÙ`
*======================*
*| flood ban |* `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯`
*| flood mute |* `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ`
*| flood del |* `Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­`
*| gif |* `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ`
*| photo |* `Ø§ÙØµÙØ±`
*| sticker |* `Ø§ÙÙÙØµÙØ§Øª`
*| video |* `Ø§ÙÙÙØ¯ÙÙ`
*| inline |* `ÙØ³ØªØ§Øª Ø´ÙØ§ÙÙ`
*======================*
*| text |* `Ø§ÙØ¯Ø±Ø¯Ø´Ù`
*| fwd |* `Ø§ÙØªÙØ¬ÙÙ`
*| music |* `Ø§ÙØ§ØºØ§ÙÙ`
*| voice |* `Ø§ÙØµÙØª`
*| contact |* `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù`
*| service |* `Ø§Ø´Ø¹Ø§Ø±Ø§Øª Ø§ÙØ¯Ø®ÙÙ`
*| markdown |* `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ`
*| file |* `Ø§ÙÙÙÙØ§Øª`
*======================*
*| location |* `Ø§ÙÙÙØ§ÙØ¹`
*| bots |* `Ø§ÙØ¨ÙØªØ§Øª`
*| spam |* `Ø§ÙÙÙØ§ÙØ´`
*| arabic |* `Ø§ÙØ¹Ø±Ø¨ÙÙ`
*| english |* `Ø§ÙØ§ÙÙÙÙØ²ÙÙ`
*| reply bot |* `Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª`
*| reply sudo |* `Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±`
*| reply owner |* `Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±`
*| id |* `Ø§ÙØ§ÙØ¯Ù`
*| all |* `ÙÙ Ø§ÙÙÙØ¯ÙØ§`
*| all |* `ÙØ¹ Ø§ÙØ¹Ø¯Ø¯ ÙÙÙ Ø§ÙÙÙØ¯ÙØ§ Ø¨Ø§ÙØ«ÙØ§ÙÙ`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ÙÙÙÙÙ`
*unlock* `ÙÙÙØªØ­`
*======================*
*| links warn |* `Ø§ÙØ±ÙØ§Ø¨Ø·`
*| tag warn |* `Ø§ÙÙØ¹Ø±Ù`
*| hashtag warn |* `Ø§ÙØªØ§Ù`
*| cmd warn |* `Ø§ÙØ³ÙØ§Ø´`
*| webpage warn |* `Ø§ÙØ±ÙØ§Ø¨Ø· Ø§ÙØ®Ø§Ø±Ø¬ÙÙ`
*======================*
*| gif warn |* `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ`
*| photo warn |* `Ø§ÙØµÙØ±`
*| sticker warn |* `Ø§ÙÙÙØµÙØ§Øª`
*| video warn |* `Ø§ÙÙÙØ¯ÙÙ`
*| inline warn |* `ÙØ³ØªØ§Øª Ø´ÙØ§ÙÙ`
*======================*
*| text warn |* `Ø§ÙØ¯Ø±Ø¯Ø´Ù`
*| fwd warn |* `Ø§ÙØªÙØ¬ÙÙ`
*| music warn |* `Ø§ÙØ§ØºØ§ÙÙ`
*| voice warn |* `Ø§ÙØµÙØª`
*| contact warn |* `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù`
*| markdown warn |* `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ`
*| file warn |* `Ø§ÙÙÙÙØ§Øª`
*======================*
*| location warn |* `Ø§ÙÙÙØ§ÙØ¹`
*| spam |* `Ø§ÙÙÙØ§ÙØ´`
*| arabic warn |* `Ø§ÙØ¹Ø±Ø¨ÙÙ`
*| english warn |* `Ø§ÙØ§ÙÙÙÙØ²ÙÙ`
*| all warn |* `ÙÙ Ø§ÙÙÙØ¯ÙØ§`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ÙÙÙÙÙ`
*unlock* `ÙÙÙØªØ­`
*======================*
*| links ban |* `Ø§ÙØ±ÙØ§Ø¨Ø·`
*| tag ban |* `Ø§ÙÙØ¹Ø±Ù`
*| hashtag ban |* `Ø§ÙØªØ§Ù`
*| cmd ban |* `Ø§ÙØ³ÙØ§Ø´`
*| webpage ban |* `Ø§ÙØ±ÙØ§Ø¨Ø· Ø§ÙØ®Ø§Ø±Ø¬ÙÙ`
*======================*
*| gif ban |* `Ø§ÙØµÙØ± Ø§ÙÙØªØ­Ø±ÙÙ`
*| photo ban |* `Ø§ÙØµÙØ±`
*| sticker ban |* `Ø§ÙÙÙØµÙØ§Øª`
*| video ban |* `Ø§ÙÙÙØ¯ÙÙ`
*| inline ban |* `ÙØ³ØªØ§Øª Ø´ÙØ§ÙÙ`
*| markdown ban |* `Ø§ÙÙØ§Ø±ÙØ¯ÙÙ`
*| file ban |* `Ø§ÙÙÙÙØ§Øª`
*======================*
*| text ban |* `Ø§ÙØ¯Ø±Ø¯Ø´Ù`
*| fwd ban |* `Ø§ÙØªÙØ¬ÙÙ`
*| music ban |* `Ø§ÙØ§ØºØ§ÙÙ`
*| voice ban |* `Ø§ÙØµÙØª`
*| contact ban |* `Ø¬ÙØ§Øª Ø§ÙØ§ØªØµØ§Ù`
*| location ban |* `Ø§ÙÙÙØ§ÙØ¹`
*======================*
*| arabic ban |* `Ø§ÙØ¹Ø±Ø¨ÙÙ`
*| english ban |* `Ø§ÙØ§ÙÙÙÙØ²ÙÙ`
*| all ban |* `ÙÙ Ø§ÙÙÙØ¯ÙØ§`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*| setmote |* `Ø±ÙØ¹ Ø§Ø¯ÙÙ` 
*| remmote |* `Ø§Ø²Ø§ÙÙ Ø§Ø¯ÙÙ` 
*| setvip |* `Ø±ÙØ¹ Ø¹Ø¶Ù ÙÙÙØ²` 
*| remvip |* `Ø§Ø²Ø§ÙÙ Ø¹Ø¶Ù ÙÙÙØ²` 
*| setlang en |* `ØªØºÙØ± Ø§ÙÙØºÙ ÙÙØ§ÙÙÙÙØ²ÙÙ` 
*| setlang ar |* `ØªØºÙØ± Ø§ÙÙØºÙ ÙÙØ¹Ø±Ø¨ÙÙ` 
*| unsilent |* `ÙØ§ÙØºØ§Ø¡ ÙØªÙ Ø§ÙØ¹Ø¶Ù` 
*| silent |* `ÙÙØªÙ Ø¹Ø¶Ù` 
*| ban |* `Ø­Ø¸Ø± Ø¹Ø¶Ù` 
*| unban |* `Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø± Ø§ÙØ¹Ø¶Ù` 
*| kick |* `Ø·Ø±Ø¯ Ø¹Ø¶Ù` 
*| id |* `ÙØ§Ø¸ÙØ§Ø± Ø§ÙØ§ÙØ¯Ù [Ø¨Ø§ÙØ±Ø¯] `
*| pin |* `ØªØ«Ø¨ÙØª Ø±Ø³Ø§ÙÙ!`
*| unpin |* `Ø§ÙØºØ§Ø¡ ØªØ«Ø¨ÙØª Ø§ÙØ±Ø³Ø§ÙÙ!`
*| res |* `ÙØ¹ÙÙÙØ§Øª Ø­Ø³Ø§Ø¨ Ø¨Ø§ÙØ§ÙØ¯Ù` 
*| whois |* `ÙØ¹ Ø§ÙØ§ÙØ¯Ù ÙØ¹Ø±Ø¶ ØµØ§Ø­Ø¨ Ø§ÙØ§ÙØ¯Ù`
*======================*
*| s del |* `Ø§Ø¸ÙØ§Ø± Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ³Ø­`
*| s warn |* `Ø§Ø¸ÙØ§Ø± Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØªØ­Ø°ÙØ±`
*| s ban |* `Ø§Ø¸ÙØ§Ø± Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØ·Ø±Ø¯`
*| silentlist |* `Ø§Ø¸ÙØ§Ø± Ø§ÙÙÙØªÙÙÙÙ`
*| banlist |* `Ø§Ø¸ÙØ§Ø± Ø§ÙÙØ­Ø¸ÙØ±ÙÙ`
*| modlist |* `Ø§Ø¸ÙØ§Ø± Ø§ÙØ§Ø¯ÙÙÙÙ`
*| viplist |* `Ø§Ø¸ÙØ§Ø± Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ`
*| del |* `Ø­Ø°Ù Ø±Ø³Ø§ÙÙ Ø¨Ø§ÙØ±Ø¯`
*| link |* `Ø§Ø¸ÙØ§Ø± Ø§ÙØ±Ø§Ø¨Ø·`
*| rules |* `Ø§Ø¸ÙØ§Ø± Ø§ÙÙÙØ§ÙÙÙ`
*======================*
*| bad |* `ÙÙØ¹ ÙÙÙÙ` 
*| unbad |* `Ø§ÙØºØ§Ø¡ ÙÙØ¹ ÙÙÙÙ` 
*| badlist |* `Ø§Ø¸ÙØ§Ø± Ø§ÙÙÙÙØ§Øª Ø§ÙÙÙÙÙØ¹Ù` 
*| stats |* `ÙÙØ¹Ø±ÙÙ Ø§ÙØ§Ù Ø§ÙØ¨ÙØª`
*| del wlc |* `Ø­Ø°Ù Ø§ÙØªØ±Ø­ÙØ¨` 
*| set wlc |* `ÙØ¶Ø¹ Ø§ÙØªØ±Ø­ÙØ¨` 
*| wlc on |* `ØªÙØ¹ÙÙ Ø§ÙØªØ±Ø­ÙØ¨` 
*| wlc off |* `ØªØ¹Ø·ÙÙ Ø§ÙØªØ±Ø­ÙØ¨` 
*| get wlc |* `ÙØ¹Ø±ÙÙ Ø§ÙØªØ±Ø­ÙØ¨ Ø§ÙØ­Ø§ÙÙ` 
*| add rep |* `Ø§Ø¶Ø§ÙÙ Ø±Ø¯` 
*| rem rep |* `Ø­Ø°Ù Ø±Ø¯` 
*| rep owner list |* `Ø§Ø¸ÙØ§Ø± Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±` 
*| clean rep owner |* `ÙØ³Ø­ Ø±Ø¯Ù Ø§ÙÙØ¯ÙØ±` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^[Hh]5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*clean* `ÙØ¹ Ø§ÙØ§ÙØ§ÙØ± Ø§Ø¯ÙØ§Ù Ø¨ÙØ¶Ø¹ ÙØ±Ø§Øº`

*| banlist |* `Ø§ÙÙØ­Ø¸ÙØ±ÙÙ`
*| badlist |* `ÙÙÙØ§Øª Ø§ÙÙØ­Ø¸ÙØ±Ù`
*| modlist |* `Ø§ÙØ§Ø¯ÙÙÙÙ`
*| viplist |* `Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ`
*| link |* `Ø§ÙØ±Ø§Ø¨Ø· Ø§ÙÙØ­ÙÙØ¸`
*| silentlist |* `Ø§ÙÙÙØªÙÙÙÙ`
*| bots |* `Ø¨ÙØªØ§Øª ØªÙÙÙØ´ ÙØºÙØ±ÙØ§`
*| rules |* `Ø§ÙÙÙØ§ÙÙÙ`
*======================*
*set* `ÙØ¹ Ø§ÙØ§ÙØ§ÙØ± Ø§Ø¯ÙØ§Ù Ø¨Ø¯ÙÙ ÙØ±Ø§Øº`

*| link |* `ÙÙØ¶Ø¹ Ø±Ø§Ø¨Ø·`
*| rules |* `ÙÙØ¶Ø¹ ÙÙØ§ÙÙÙ`
*| name |* `ÙØ¹ Ø§ÙØ§Ø³Ù ÙÙØ¶Ø¹ Ø§Ø³Ù`
*| photo |* `ÙÙØ¶Ø¹ ØµÙØ±Ù`

*======================*

*| flood ban |* `ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯`
*| flood mute |* `ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ`
*| flood del |* `ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ`
*| flood time |* `ÙÙØ¶Ø¹ Ø²ÙÙ ØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯ Ø§Ù Ø§ÙÙØªÙ`
*| spam del |* `ÙØ¶Ø¹ Ø¹Ø¯Ø¯ Ø§ÙØ³Ø¨Ø§Ù Ø¨Ø§ÙÙØ³Ø­`
*| spam warn |* `ÙØ¶Ø¹ Ø¹Ø¯Ø¯ Ø§ÙØ³Ø¨Ø§Ù Ø¨Ø§ÙØªØ­Ø°ÙØ±`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]6$") and is_sudo(msg) then
   
   local text =  [[
*======================*
*| add |* `ØªÙØ¹ÙÙ Ø§ÙØ¨ÙØª`
*| rem |* `ØªØ¹Ø·ÙÙ Ø§ÙØ¨ÙØª`
*| setexpire |* `ÙØ¶Ø¹ Ø§ÙØ§Ù ÙÙØ¨ÙØª`
*| stats gp |* `ÙÙØ¹Ø±ÙÙ Ø§ÙØ§Ù Ø§ÙØ¨ÙØª`
*| plan1 + id |* `ØªÙØ¹ÙÙ Ø§ÙØ¨ÙØª 30 ÙÙÙ`
*| plan2 + id |* `ØªÙØ¹ÙÙ Ø§ÙØ¨ÙØª 90 ÙÙÙ`
*| plan3 + id |* `ØªÙØ¹ÙÙ Ø§ÙØ¨ÙØª ÙØ§ ÙÙØ§Ø¦Ù`
*| join + id |* `ÙØ§Ø¶Ø§ÙØªÙ ÙÙÙØ±ÙØ¨`
*| leave + id |* `ÙØ®Ø±ÙØ¬ Ø§ÙØ¨ÙØª`
*| leave |* `ÙØ®Ø±ÙØ¬ Ø§ÙØ¨ÙØª`
*| stats gp + id |* `ÙÙØ¹Ø±ÙÙ  Ø§ÙØ§Ù Ø§ÙØ¨ÙØª`
*| view |* `ÙØ§Ø¸ÙØ§Ø± ÙØ´Ø§ÙØ¯Ø§Øª ÙÙØ´ÙØ±`
*| note |* `ÙØ­ÙØ¸ ÙÙÙØ´Ù`
*| dnote |* `ÙØ­Ø°Ù Ø§ÙÙÙÙØ´Ù`
*| getnote |* `ÙØ§Ø¸ÙØ§Ø± Ø§ÙÙÙÙØ´Ù`
*| reload |* `ÙØªÙØ´ÙØ· Ø§ÙØ¨ÙØª`
*| clean gbanlist |* `ÙØ­Ø°Ù Ø§ÙØ­Ø¸Ø± Ø§ÙØ¹Ø§Ù`
*| clean owners |* `ÙØ­Ø°Ù ÙØ§Ø¦ÙÙ Ø§ÙÙØ¯Ø±Ø§Ø¡`
*| adminlist |* `ÙØ§Ø¸ÙØ§Ø± Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª`
*| gbanlist |* `ÙØ§Ø¸ÙØ§Ø± Ø§ÙÙØ­Ø¸ÙØ±ÙÙ Ø¹Ø§Ù `
*| ownerlist |* `ÙØ§Ø¸ÙØ§Ø± ÙØ¯Ø±Ø§Ø¡ Ø§ÙØ¨ÙØª`
*| setadmin |* `ÙØ§Ø¶Ø§ÙÙ Ø§Ø¯ÙÙ`
*| remadmin |* `ÙØ­Ø°Ù Ø§Ø¯ÙÙ`
*| setowner |* `ÙØ§Ø¶Ø§ÙÙ ÙØ¯ÙØ±`
*| remowner |* `ÙØ­Ø°Ù ÙØ¯ÙØ±`
*| banall |* `ÙØ­Ø¸Ø± Ø§ÙØ¹Ø§Ù`
*| unbanall |* `ÙØ§ÙØºØ§Ø¡ Ø§ÙØ¹Ø§Ù`
*| invite |* `ÙØ§Ø¶Ø§ÙÙ Ø¹Ø¶Ù`
*| groups |* `Ø¹Ø¯Ø¯ ÙØ±ÙØ¨Ø§Øª Ø§ÙØ¨ÙØª`
*| bc |* `ÙÙØ´Ø± Ø´Ø¦`
*| del |* `ÙÙÙ Ø§ÙØ¹Ø¯Ø¯ Ø­Ø°Ù Ø±Ø³Ø§Ø¦Ù`
*| add sudo |* `Ø§Ø¶Ù ÙØ·ÙØ±`
*| rem sudo |* `Ø­Ø°Ù ÙØ·ÙØ±`
*| add rep all |* `Ø§Ø¶Ù Ø±Ø¯ ÙÙÙ Ø§ÙÙØ¬ÙÙØ¹Ø§Øª`
*| rem rep all |* `Ø­Ø°Ù Ø±Ø¯ ÙÙÙ Ø§ÙÙØ¬ÙÙØ¹Ø§Øª`
*| change ph |* `ØªØºÙØ± Ø¬ÙÙ Ø§ÙÙØ·ÙØ±`
*| sudo list |* `Ø§Ø¸ÙØ§Ø± Ø§ÙÙØ·ÙØ±ÙÙ` 
*| rep sudo list |* `Ø§Ø¸ÙØ§Ø± Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` 
*| clean sudo |* `ÙØ³Ø­ Ø§ÙÙØ·ÙØ±ÙÙ` 
*| clean rep sudo |* `ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ±` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   
   
   if text:match("^Ø§ÙØ§ÙØ§ÙØ±$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ ÙÙØ§Ù  6 Ø§ÙØ§ÙØ± ÙØ¹Ø±Ø¶ÙØ§ ð ð¦
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ `Ù1 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ` ð¡

â¢ `Ù2 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±` â ï¸

â¢ `Ù3 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯` ð·

â¢ `Ù4 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙØ§Ø¯ÙÙÙÙ` ð°

â¢ `Ù5 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙÙØ¬ÙÙØ¹Ù `ð¬

â¢ `Ù6 : ÙØ¹Ø±Ø¶ Ø§ÙØ§ÙØ± Ø§ÙÙØ·ÙØ±ÙÙ `ð¤
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^Ù1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø­ÙØ§ÙÙ Ø¨Ø§ÙÙØ³Ø­  ð°
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ ÙÙÙ : ÙÙÙÙ Ø§ÙØ± ð
â¢ ÙØªØ­ : ÙÙØªØ­ Ø§ÙØ±ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ±ÙØ§Ø¨Ø·  | ð°
â¢ Ø§ÙÙØ¹Ø±Ù |ð
â¢ Ø§ÙØªØ§Ù |ð¥
â¢ Ø§ÙØ´Ø§Ø±Ø­Ù |ã°
â¢ Ø§ÙØªØ¹Ø¯ÙÙ | ð
â¢ Ø§ÙØªØ«Ø¨ÙØª | ð
â¢ Ø§ÙÙÙØ§ÙØ¹ | â¨ï¸
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙÙ |âï¸
â¢ Ø§ÙØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­ |ð
â¢ Ø§ÙÙØªØ­Ø±ÙÙ |ð
â¢ Ø§ÙÙÙÙØ§Øª |ð
â¢ Ø§ÙØµÙØ± |ð 
â¢ Ø§ÙÙÙØµÙØ§Øª |ð
â¢ Ø§ÙÙÙØ¯ÙÙ |ð¥
â¢ Ø§ÙØ§ÙÙØ§ÙÙ |ð¡
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ¯Ø±Ø¯Ø´Ù |ð
â¢ Ø§ÙØªÙØ¬ÙÙ |â»ï¸
â¢ Ø§ÙØ§ØºØ§ÙÙ |â³ï¸
â¢ Ø§ÙØµÙØª |ð
â¢ Ø§ÙØ¬ÙØ§Øª |ð¥
â¢ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ | â
â¢ Ø§ÙØ§Ø´Ø¹Ø§Ø±Ø§Øª |ð¤
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ´Ø¨ÙØ§Øª |ð¥
â¢ Ø§ÙØ¨ÙØªØ§Øª |ð¤
â¢ Ø§ÙÙÙØ§ÙØ´ |ð¸
â¢ Ø§ÙØ¹Ø±Ø¨ÙÙ|ð
â¢ Ø§ÙØ§ÙÙÙÙØ²ÙÙ |âï¸
â¢ Ø§ÙÙÙ |ð
â¢ Ø§ÙÙÙ Ø¨Ø§ÙØ«ÙØ§ÙÙ + Ø§ÙØ¹Ø¯Ø¯ |ð¯
â¢ Ø§ÙÙÙ Ø¨Ø§ÙØ³Ø§Ø¹Ù + Ø§ÙØ¹Ø¯Ø¯ |ð·
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
    
   if text:match("^Ù2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø­ÙØ§ÙÙ Ø§ÙÙØ¬ÙÙØ¹Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± â ï¸
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
ÙÙÙ : ÙÙÙÙ Ø§ÙØ± ð
ÙØªØ­ : ÙÙØªØ­ Ø§ÙØ± ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØªØ­Ø°ÙØ±  | ð°
â¢ Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙØªØ§Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¥
â¢ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ±| â
â¢ Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± |ã°
â¢ Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØªØ­Ø°ÙØ± | â¨ï¸
â¢ Ø§ÙØªØ«Ø¨ÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ± | ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙØµÙØ± Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð 
â¢ Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¥
â¢ Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¡
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |â»ï¸
â¢ Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |â³ï¸
â¢ Ø§ÙØµÙØª Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¥
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¥
â¢ Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð¸
â¢ Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
â¢ Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |âï¸
â¢ Ø§ÙÙÙ Ø¨Ø§ÙØªØ­Ø°ÙØ± |ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^Ù3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø§ÙØ­ÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ ð¸
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
ÙÙÙ  : ÙÙÙÙ Ø§ÙØ± ð
ÙØªØ­ : ÙÙØªØ­ Ø§ÙØ±ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ±ÙØ§Ø¨Ø· Ø¨Ø§ÙØ·Ø±Ø¯ | ð°
â¢ Ø§ÙÙØ¹Ø±Ù Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙØªØ§Ù Ø¨Ø§ÙØ·Ø±Ø¯ |ð¥
â¢ Ø§ÙØ´Ø§Ø±Ø­Ù Ø¨Ø§ÙØ·Ø±Ø¯ |ã°
â¢ Ø§ÙÙÙØ§ÙØ¹ Ø¨Ø§ÙØ·Ø±Ø¯ | â¨ï¸
â¢ Ø§ÙÙØ§Ø±ÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ | â
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙÙØªØ­Ø±ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙÙÙÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙØµÙØ± Ø¨Ø§ÙØ·Ø±Ø¯ |ð 
â¢ Ø§ÙÙÙØµÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙÙÙØ¯ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |ð¥
â¢ Ø§ÙØ§ÙÙØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯  |ð¡
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙØ¯Ø±Ø¯Ø´Ù Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙØªÙØ¬ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |â»ï¸
â¢ Ø§ÙØ§ØºØ§ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |â³ï¸
â¢ Ø§ÙØµÙØª Ø¨Ø§ÙØ·Ø±Ø¯ |ð
â¢ Ø§ÙØ¬ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯|ð¥
â¢ Ø§ÙØ´Ø¨ÙØ§Øª Ø¨Ø§ÙØ·Ø±Ø¯|ð¥
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙÙÙØ§ÙØ´ Ø¨Ø§ÙØ·Ø±Ø¯ |ð¸
â¢ Ø§ÙØ¹Ø±Ø¨ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯  |ð
â¢ Ø§ÙØ§ÙÙÙÙØ²ÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |âï¸
â¢ Ø§ÙÙÙ Ø¨Ø§ÙØ·Ø±Ø¯ |ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^Ù4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø§ÙØ§Ø¯ÙÙÙÙ ð¤
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø±ÙØ¹ Ø§Ø¯ÙÙ | ð¼
â¢ ØªÙØ²ÙÙ Ø§Ø¯ÙÙ | ð½
â¢ Ø±ÙØ¹ Ø¹Ø¶Ù ÙÙÙØ² | â«
â¢ ØªÙØ²ÙÙ Ø¹Ø¶Ù ÙÙÙØ² | â¬
â¢ ØªØ­ÙÙÙ Ø§ÙÙÙÙØ²ÙÙ | âï¸
â¢ ØªØ­ÙÙÙ Ø¹Ø±Ø¨ÙÙ | ð
â¢ Ø§ÙØ¯Ù + Ø±Ø¯ | ð

â¢ Ø§ÙØºØ§Ø¡ ÙØªÙ | ð
â¢ ÙØªÙ | ð
â¢ Ø­Ø¸Ø± | â³ï¸
â¢ Ø·Ø±Ø¯ | â¦ï¸
â¢ Ø§ÙØºØ§Ø¡ Ø­Ø¸Ø± | âï¸
â¢ ØªØ«Ø¨ÙØª | âï¸
â¢ Ø§ÙØºØ§Ø¡ ØªØ«Ø¨ÙØª | â
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙÙØ³Ø­ | ð 
â¢ Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØªØ­Ø°ÙØ± | ð
â¢ Ø§Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§ÙØ·Ø±Ø¯ | ð
â¢ Ø§ÙÙÙØªÙÙÙÙ | ð·
â¢ Ø§ÙÙØ­Ø¸ÙØ±ÙÙ | ð¯
â¢ ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹ | ð

â¢ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ | âï¸
â¢ Ø§ÙØ§Ø¯ÙÙÙÙ | ð
â¢ ÙØ³Ø­ + Ø±Ø¯ | ð®
â¢ Ø§ÙØ±Ø§Ø¨Ø· | ð®
â¢ Ø§ÙÙÙØ§ÙÙÙ | ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§Ø¶Ù Ø±Ø¯ | ð¬
â¢ Ø­Ø°Ù Ø±Ø¯ | ð­
â¢ ÙÙØ¹ + Ø§ÙÙÙÙÙ | ð
â¢ Ø§ÙØºØ§Ø¡ ÙÙØ¹ + Ø§ÙÙÙÙÙ| ð
â¢ Ø§ÙÙÙØª |ð

â¢ Ø­Ø°Ù Ø§ÙØªØ±Ø­ÙØ¨ | âï¸
â¢ ÙØ¶Ø¹ ØªØ±Ø­ÙØ¨ | ð
â¢ ØªÙØ¹ÙÙ Ø§ÙØªØ±Ø­ÙØ¨ | â­ï¸
â¢ ØªØ¹Ø·ÙÙ Ø§ÙØªØ±Ø­ÙØ¨ | â
â¢ Ø¬ÙØ¨ Ø§ÙØªØ±Ø­ÙØ¨ | ð¢
				
â¢ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª  | ð
â¢ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙØ¨ÙØª |ð
â¢ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ±  | â
â¢ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± |â 
â¢ ØªÙØ¹ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± | â¤´ï¸
â¢ ØªØ¹Ø·ÙÙ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± | â¤´ï¸

â¢ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± |âº
â¢ ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ¯ÙØ± |ð
â¢ ØªÙØ¹ÙÙ Ø§ÙØ§ÙØ¯Ù  | ð
â¢ ØªØ¹Ø·ÙÙ Ø§ÙØ§ÙØ¯Ù |ð
â¢ ÙØ¹ÙÙÙØ§Øª + Ø§ÙØ¯Ù|ð¯
â¢ Ø§ÙØ­Ø³Ø§Ø¨ + Ø§ÙØ¯Ù| âï¸
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^Ù5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø§ÙÙØ¬ÙÙØ¹Ù ð¥
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
ÙØ³Ø­ : ÙØ¹ Ø§ÙØ§ÙØ§ÙØ± Ø§Ø¯ÙØ§Ù Ø¨ÙØ¶Ø¹ ÙØ±Ø§Øº
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø§ÙÙØ­Ø¸ÙØ±ÙÙ | ð·
â¢ ÙØ§Ø¦ÙÙ Ø§ÙÙÙØ¹ | ð
â¢ Ø§ÙØ§Ø¯ÙÙÙÙ | ð
â¢ Ø§ÙØ§Ø¹Ø¶Ø§Ø¡ Ø§ÙÙÙÙØ²ÙÙ | âï¸
â¢ Ø§ÙØ±Ø§Ø¨Ø· | ð°
â¢ Ø§ÙÙÙØªÙÙÙÙ | ð¤
â¢ Ø§ÙØ¨ÙØªØ§Øª | ð¤
â¢ Ø§ÙÙÙØ§ÙÙÙ | ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
ÙØ¶Ø¹ : ÙØ¹ Ø§ÙØ§ÙØ§ÙØ± Ø§Ø¯ÙØ§Ù
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø±Ø§Ø¨Ø· | ð°
â¢ ÙÙØ§ÙÙÙ | ð
â¢ Ø§Ø³Ù | ð
â¢ ØµÙØ±Ù | ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙØ·Ø±Ø¯ + Ø§ÙØ¹Ø¯Ø¯| ð
â¢ ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØªÙ + Ø§ÙØ¹Ø¯Ø¯| âï¸
â¢ ÙØ¶Ø¹ ØªÙØ±Ø§Ø± Ø¨Ø§ÙÙØ³Ø­ + Ø§ÙØ¹Ø¯Ø¯| ð
â¢ ÙØ¶Ø¹ Ø²ÙÙ Ø§ÙØªÙØ±Ø§Ø± + Ø§ÙØ¹Ø¯Ø¯| ð¹
â¢ ÙØ¶Ø¹ ÙÙØ§ÙØ´ Ø¨Ø§ÙÙØ³Ø­ + Ø§ÙØ¹Ø¯Ø¯| ð
â¢ ÙØ¶Ø¹ ÙÙØ§ÙØ´ Ø¨Ø§ÙØªØ­Ø°ÙØ± + Ø§ÙØ¹Ø¯Ø¯| ð
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^Ù6$") and is_sudo(msg) then
   
   local text =  [[
â¢ Ø§ÙØ§ÙØ± Ø§ÙÙØ·ÙØ± ð¨âð§
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ ØªÙØ¹ÙÙ | â­ï¸
â¢ ØªØ¹Ø·ÙÙ | â
â¢ ÙØ¶Ø¹ ÙÙØª + Ø¹Ø¯Ø¯ | ð¤
â¢ Ø§ÙÙØ¯Ù1 + id | âï¸
â¢ Ø§ÙÙØ¯Ù2 + id |â³
â¢ Ø§ÙÙØ¯Ù3 + id | ð
â¢ Ø§Ø¶Ø§ÙÙ + id | ð¨
â¢ ÙØºØ§Ø¯Ø±Ù + id | ð¯
â¢ ÙØºØ§Ø¯Ø±Ù | ð¤
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ ÙÙØª Ø§ÙÙØ¬ÙÙØ¹Ù + id | ð®
â¢ ÙØ´Ø§ÙØ¯Ù ÙÙØ´ÙØ± | ð
â¢ Ø­ÙØ¸ | ð
â¢ Ø­Ø°Ù Ø§ÙÙÙÙØ´Ù | âï¸
â¢ Ø¬ÙØ¨ Ø§ÙÙÙÙØ´Ù | ð
â¢ ØªØ­Ø¯ÙØ« | ð
â¢ ÙØ³Ø­ ÙØ§Ø¦ÙÙ Ø§ÙØ¹Ø§Ù | ð
â¢ ÙØ³Ø­ Ø§ÙÙØ¯Ø±Ø§Ø¡ | ð
â¢ Ø§Ø¯ÙÙÙÙ Ø§ÙØ¨ÙØª | ð
â¢ ÙØ§Ø¦ÙÙ Ø§ÙØ¹Ø§Ù | ð
â¢ Ø§ÙÙØ¯Ø±Ø§Ø¡ | ð
â¢ Ø±ÙØ¹ Ø§Ø¯ÙÙ ÙÙØ¨ÙØª | ðº
â¢ ØªÙØ²ÙÙ Ø§Ø¯ÙÙ ÙÙØ¨ÙØª | ð»
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
â¢ Ø±ÙØ¹ ÙØ¯ÙØ± | ð¶
â¢ ØªÙØ²ÙÙ ÙØ¯ÙØ± | ð¸
â¢ Ø­Ø¸Ø± Ø¹Ø§Ù | ð´
â¢ Ø§ÙØºØ§Ø¡ Ø§ÙØ¹Ø§Ù | ðµ
â¢ Ø§ÙÙØ±ÙØ¨Ø§Øª | ð»
â¢ Ø§Ø¶Ø§ÙÙ | âº
â¢ Ø§Ø°Ø§Ø¹Ù + ÙÙÙØ´Ù | ð
â¢ ØªÙØ¸ÙÙ + Ø¹Ø¯Ø¯ | ð®

â¢ Ø§Ø¶Ù ÙØ·ÙØ± | â«
â¢ Ø­Ø°Ù ÙØ·ÙØ± |â¬
â¢ Ø§ÙÙØ·ÙØ±ÙÙ |ð
â¢ ÙØ³Ø­ Ø§ÙÙØ·ÙØ±ÙÙ |ð
â¢ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± |ð
â¢ ÙØ³Ø­ Ø±Ø¯ÙØ¯ Ø§ÙÙØ·ÙØ± |ð
â¢ ØªØºÙØ± Ø§ÙØ± Ø§ÙÙØ·ÙØ± |ð³
â¢ Ø§Ø¶Ù Ø±Ø¯ ÙÙÙÙ |ð¨
â¢ Ø­Ø°Ù Ø±Ø¯ ÙÙÙÙ | ð¤
Ö â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ â¢ Ö
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
if text:match("^source$") or text:match("^Ø§ØµØ¯Ø§Ø±$") or text:match("^Ø§ÙØ§ØµØ¯Ø§Ø±$") or text:match("^Ø§ÙØ³ÙØ±Ø³$") or text:match("^Ø³ÙØ±Ø³$") then
   
   local text =  [[
Ø§ÙÙØ§ Ø¨ÙÙ ÙÙ Ø¨ÙØª TP

DEV : @AHMED1998A
				
				DEV : @U_U_I

channel : @MASTER_OF_ART

]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end

if text:match("^Ø§Ø±ÙØ¯ Ø±Ø§Ø¨Ø· Ø­Ø°Ù$") or text:match("^Ø±Ø§Ø¨Ø· Ø­Ø°Ù$") or text:match("^Ø±Ø§Ø¨Ø· Ø§ÙØ­Ø°Ù$") or text:match("^Ø§ÙØ±Ø§Ø¨Ø· Ø­Ø°Ù$") or text:match("^Ø§Ø±ÙØ¯ Ø±Ø§Ø¨Ø· Ø§ÙØ­Ø°Ù$") then
   
   local text =  [[
â¢ Ø±Ø§Ø¨Ø· Ø­Ø°Ù Ø§ÙØªÙÙ â¬ï¸ Ö
â¢ Ø§Ø­Ø°Ù ÙÙØ§ ØªØ±Ø¬Ø¹ Ø¹ÙØ´ Ø­ÙØ§ØªÙ ð¾ðÖ
â¢ https://telegram.org/deactivate
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
  -----------------------------------------------------------------------------------------------
 end
  -----------------------------------------------------------------------------------------------
                                       -- end code --
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end

   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ ÙÙØ±ÙØ§Ø¨Ø·</code> â ï¸", 1, 'html')
	end
end
end

	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	
   if database:get('bot:webpage:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ ÙÙÙÙØ§ÙØ¹</code> â ï¸", 1, 'html')
	end
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:tag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ ÙÙÙØ¹Ø±ÙØ§Øª</code> â ï¸", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:hashtag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ ÙÙØªØ§ÙØ§Øª</code> â ï¸", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("/")  then
   if database:get('bot:cmd:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:cmd:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ ÙÙØ´Ø§Ø±Ø­Ù</code> â ï¸", 1, 'html')
	end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	end
	   if database:get('bot:arabic:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ  ÙÙØºÙ Ø§ÙØ¹Ø±Ø¨ÙÙ</code> â ï¸", 1, 'html')
	end
 end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:english:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø¹ÙÙ ØªØ¹Ø¯ÙÙ  ÙÙØºÙ Ø§ÙØ§ÙÙÙÙØ²ÙÙ</code> â ï¸", 1, 'html')
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
              send(msg.chat_id_, 0, 1, "â¢ <code>ÙÙÙÙØ¹ Ø§ÙØªØ¹Ø¯ÙÙ ÙÙØ§</code> â ï¸", 1, 'html')
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
     send(msg.chat_id_, msg.message_id_, 1, 'â¢ `ÙÙØ¯ ÙÙØª Ø¨Ø§ÙØªØ¹Ø¯ÙÙ` â\n\nâ¢`Ø±Ø³Ø§ÙØªÙ Ø§ÙØ³Ø§Ø¨ÙÙ ` â¬ï¸  : \n\nâ¢ [ '..old_text..' ]', 1, 'md')
	end
end 
end
end
    end
	end

    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
  -----------------------------------------------------------------------------------------------
end


--[[                                    Dev  @lkoko      
   _____    _        _    _    _____    Dev  @lkoko
  |_   _|__| |__    / \  | | _| ____|   Dev   @lkoko
    | |/ __|  _ \  / _ \ | |/ /  _|     Dev @lkoko
    | |\__ \ | | |/ ___ \|   <| |___    Dev @lkoko
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lkoko
              CH > @QD_QQ
--]]

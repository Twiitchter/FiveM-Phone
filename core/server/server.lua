------------------------------------------------------------------------------
__C = exports.core:Core()
------------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	TriggerEvent('ServerConsole', 'Start', resourceName..' | onResourceStart. ')
	OnStart()
end)
------------------------------------------------------------------------------
--	On Start
function OnStart()

end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--	Functions

function GeneratePhoneNumber(GeneratedNumber, ServiceProvider)

	local ServiceProvider = nil
	-- Lets declare our telecom providers...	
	local Provider = {'Vodaphone','Vodaphone','Vodaphone','Optus','Optus','Optus','Telstra','Telstra','Telstra'}

	-- Country Code, In Australia is only 04xxxxxxxx,10 digits in total.
	local CountryCode = math.random(04,04)
	
	-- the remaining numbers. xx01234567.
	local Remaning = math.random(00000000,99999999)
	
	-- So lets make the start, 0nly between, 04 and 04. Then the rest random.
	-- There is no space between the two numbers, no - or .
	-- If you were in a country with a - the string format would be. "%02d-%08d"
	local GeneratedNumber = string.format('%02d%08d', CountryCode, Remaning)
	
	-- Lets now, find the provider based on the first few digits of the Remaning numbers.
	function GetProvider(var)
		return tonumber(tostring(var):sub( 1, 1))
	end

	local Number = GetProvider(Remaning)

	-- If the number returned is anything other than nil, that it started at find the provider.
	for k,v in ipairs(Provider) do
		if (k == Number) then
			ServiceProvider = v
			break
		end
	end
	
	return GeneratedNumber, ServiceProvider
end

-- print('This is the '..a..' '..b..' test')

------------------------------------------------------------------------------
-- Player Finding and Database Read/Write of Generated Number.
------------------------------------------------------------------------------


-- Lets find a Unique_ID form the DB Table of Users.
function FindUniqueID(Unique_ID) -- Unique_ID
	local FiveM_ID = GetPlayerCharacter_ID(source)[2]
	local result = MySQL.Sync.fetchAll("SELECT Users.Unique_ID FROM Users WHERE Users.FiveM_ID = @FiveM_ID", {
		['FiveM_ID'] = FiveM_ID
	})
	if result[1] ~= nil then
		return result[1].Unique_ID
	end
	return nil
end

-- Lets find a Character that's active to continue with the rest.
function FindActiveCharacterID(Character_ID) -- Character_ID
	local Unique_ID = FindUniqueID()
	local Active = 1
	local result = MySQL.Sync.fetchAll("SELECT Characters.Character_ID FROM Characters WHERE Character.Unique_ID = @Unique_ID AND Characters.Active = @Active", {
		['Unique_ID'] = Unique_ID,
		['Active'] = Active
	})
	if result[1] ~= nil then
		return result[1].Character_ID
	end
	return nil
end

-- Lets find the mobile number of the character thats active...
function FindMobileNumberOfCharacter(Character_ID)
	local Character_ID = Character_ID
	
	if Character_ID == nil then
		Character_ID = FindActiveCharacterID(Character_ID)
	end	
	
	local Mobile_Number = nil
	local result = MySQL.Sync.fetchAll("SELECT Characters.Mobile_Number FROM Characters WHERE Character.Character_ID = @Character_ID", {
		['Character_ID'] = Character_ID
	})
	if result[1] ~= nil then
		return result[1].Mobile_Number
	end
	return nil	
end	

-- Lets find the character of the mobile number... This is a reverse call to the function above.
function FindCharacterOfMobileNumber(Mobile_Number)
	local Character_ID = nil
	
	local Mobile_Number = Mobile_Number
	if Mobile_Number == nil then
		Mobile_Number = FindMobileNumberOfCharacter(Character_ID)
	end	
	
	local result = MySQL.Sync.fetchAll("SELECT Characters.Character_ID FROM Characters WHERE Character.Mobile_Number = @Mobile_Number", {
		['Mobile_Number'] = Mobile_Number
	})
	if result[1] ~= nil then
		return result[1].Character_ID
	end
	return nil	
end	

-- Lets give the character a mobile number and service provider.
function FindOrGenerateMobileNumber(Mobile_Number, Character_ID)
	local Character_ID = FindActiveCharacterID(Character_ID)
	local Mobile_Number = FindMobileNumberOfCharacter(Mobile_Number)
	local TheNumber = GeneratePhoneNumber(GeneratedNumber, ServiceProvider)
	local cb = nil
	
	if Mobile_Number == nil then
		repeat
			TheNumber, The Provider = GeneratePhoneNumber()
			local CharacterFound = FindCharacterOfMobileNumber(Mobile_Number)
		until CharacterFound == nil
		MySQL.Async.insert("UPDATE Characters SET Mobile_Number = @Mobile_Number AND SET Mobile_Provider = @Mobile_Provider WHERE Character_ID = @Character_ID", {
			['@Mobile_Number'] = TheNumber,
			['@Mobile_Provider'] = TheProvider,
			['@Character_ID'] = Character_ID
		}, function ()
			cb = TheNumber
		end)
		return cb = TheNumber
	else
		return cb = nil
	end
end

------------------------------------------------------------------------------
-- Contact Section
------------------------------------------------------------------------------

function ReadContacts(Character_ID)
	local result = MySQL.Sync.fetchAll("SELECT * FROM FMPhone_Contacts WHERE FMPhone_Contacts.Character_ID = @Character_ID", {
		['@Character_ID'] = Character_ID
	})
	return result
end

function WriteContact(source, Character_ID, Mobile_Number, Full_Name)
	local iPlayer = tonumber(source)
	MySQL.Async.insert("INSERT INTO FMPhone_Contacts (`Character_ID`,`Mobile_Number`,`Full_Name`) VALUES(@Character_ID, @Mobile_Number, @Full_Name)", {
		['@Character_ID'] = Character_ID,
		['@Mobile_Number'] = Mobile_Number,
		['@Full_Name'] = Full_Name
	},function()
		notifyContactChange(iPlayer, Character_ID)
	end)
end

function updateContact(source, Character_ID, Mobile_Number, Full_Name)
	local iPlayer = tonumber(source)
	MySQL.Async.insert("UPDATE FMPhone_Contacts SET Mobile_Number = @Mobile_Number, Full_Name = @Full_Name WHERE Character_ID = @Character_ID", {
		['@Mobile_Number'] = Mobile_Number,
		['@Full_Name'] = Full_Name,
		['@Character_ID'] = Character_ID
	},function()
		notifyContactChange(iPlayer, Character_ID)
	end)
end
function deleteContact(source, Character_ID, Full_Name)
	local iPlayer = tonumber(source)
	MySQL.Sync.execute("DELETE FROM FMPhone_Contacts WHERE `Character_ID` = @Character_ID AND `Full_Name` = @Full_Name", {
		['@Character_ID'] = Character_ID,
		['@Full_Name'] = Full_Name,
	})
	notifyContactChange(iPlayer, Character_ID)
end
function deleteAllContact(Character_ID)
	MySQL.Sync.execute("DELETE FROM FMPhone_Contacts WHERE `Character_ID` = @Character_ID", {
		['@Character_ID'] = Character_ID
	})
end
function notifyContactChange(iPlayer, Character_ID)
	local iPlayer = tonumber(source)
	local Character_ID = Character_ID
	if iPlayer ~= nil then
		TriggerClientEvent("FiveM-Phone:Client.ContactList", iPlayer, getContacts(Character_ID))
	end
end

RegisterServerEvent('FiveM-Phone:Server.AddContact')
AddEventHandler('FiveM-Phone:Server.AddContact', function(display, phoneNumber)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	addContact(sourcePlayer, Character_ID, phoneNumber, display)
end)

RegisterServerEvent('FiveM-Phone:Server.UpdateContact')
AddEventHandler('FiveM-Phone:Server.UpdateContact', function(id, display, phoneNumber)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	updateContact(sourcePlayer, Character_ID, id, phoneNumber, display)
end)

RegisterServerEvent('FiveM-Phone:Server.DeleteContact')
AddEventHandler('FiveM-Phone:Server.DeleteContact', function(id)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	deleteContact(sourcePlayer, Character_ID, id)
end)
--====================================================================================
-- Messages
--====================================================================================
function getMessages(Character_ID)
	local result = MySQL.Sync.fetchAll("SELECT FMPhone_Message.* FROM FMPhone_Message LEFT JOIN Characters ON Characters.Character_ID = @Character_ID WHERE FMPhone_Message.Receiver = Characters.Mobile_Number", {
		['@Character_ID'] = Character_ID
	})
	return result
	--return MySQLQueryTimeStamp("SELECT FMPhone_Messages.* FROM FMPhone_Messages LEFT JOIN users ON users.Character_ID = @Character_ID WHERE FMPhone_Messages.Receiver = users.Mobile_Number", {['@Character_ID'] = Character_ID})
end

RegisterServerEvent('FiveM-Phone:Server._internalAddMessage')
AddEventHandler('FiveM-Phone:Server._internalAddMessage', function(Sender, Receiver, Message, IsSent, cb)
	cb(_internalAddMessage(Sender, Receiver, Message, IsSent))
end)

function _internalAddMessage(Sender, Receiver, Message, IsSent)
	local Query = "INSERT INTO FMPhone_Messages (`Sender`, `Receiver`,`Message`, `IsRecieved`,`IsSent`) VALUES(@Sender, @Receiver, @Message, @IsRecieved, @IsSent)"
	local Query2 = 'SELECT * from FMPhone_Messages WHERE `id` = @id'
	local Parameters = {
		['@Sender'] = Sender,
		['@Receiver'] = Receiver,
		['@Message'] = Message,
		['@IsRecieved'] = IsRecieved,
		['@IsSent'] = IsSent
	}
	local lastInsertId = MySQL.Sync.insert(Query, Parameters)
	return MySQL.Sync.fetchAll(Query2, {['id'] = lastInsertId})[1]
end

function addMessage(source, Character_ID, Mobile_Number, Message)
	local sourcePlayer = tonumber(source)
	local otherCharacter_ID = getCharacter_IDByPhoneNumber(Mobile_Number)
	local myPhone = FindMobileNumberOfCharacter(Character_ID)
	if otherCharacter_ID ~= nil then
		local tomess = _internalAddMessage(myPhone, Mobile_Number, Message, 0)
		getSourceFromCharacter_ID(otherCharacter_ID, function (osou)
			if tonumber(osou) ~= nil then
				-- TriggerClientEvent("'FiveM-Phone:Server.allMessage", osou, getMessages(otherCharacter_ID))
				TriggerClientEvent("'FiveM-Phone:Server.receiveMessage", tonumber(osou), tomess)
			end
		end)
	end
	local memess = _internalAddMessage(Mobile_Number, myPhone, Message, 1)
	TriggerClientEvent("'FiveM-Phone:Server.receiveMessage", sourcePlayer, memess)
end

function setReadMessageNumber(Character_ID, num)
	local mePhoneNumber = FindMobileNumberOfCharacter(Character_ID)
	MySQL.Sync.execute("UPDATE FMPhone_Messages SET FMPhone_Messages.IsRecieved = 1 WHERE FMPhone_Messages.Receiver = @Receiver AND FMPhone_Messages.Sender = @Sender", {
		['@Receiver'] = mePhoneNumber,
		['@Sender'] = num
	})
end

function deleteMessage(msgId)
	MySQL.Sync.execute("DELETE FROM FMPhone_Messages WHERE `id` = @id", {
		['@id'] = msgId
	})
end

function deleteAllMessageFromPhoneNumber(source, Character_ID, Mobile_Number)
	local source = source
	local Character_ID = Character_ID
	local mePhoneNumber = FindMobileNumberOfCharacter(Character_ID)
	MySQL.Sync.execute("DELETE FROM FMPhone_Messages WHERE `Receiver` = @mePhoneNumber and `Sender` = @Mobile_Number", {['@mePhoneNumber'] = mePhoneNumber,['@Mobile_Number'] = Mobile_Number})
end

function deleteAllMessage(Character_ID)
	local mePhoneNumber = FindMobileNumberOfCharacter(Character_ID)
	MySQL.Sync.execute("DELETE FROM FMPhone_Messages WHERE `Receiver` = @mePhoneNumber", {
		['@mePhoneNumber'] = mePhoneNumber
	})
end

RegisterServerEvent('FiveM-Phone:Server.sendMessage')
AddEventHandler('FiveM-Phone:Server.sendMessage', function(phoneNumber, Message)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	addMessage(sourcePlayer, Character_ID, phoneNumber, Message)
end)

RegisterServerEvent('FiveM-Phone:Server.deleteMessage')
AddEventHandler('FiveM-Phone:Server.deleteMessage', function(msgId)
	deleteMessage(msgId)
end)

RegisterServerEvent('FiveM-Phone:Server.deleteMessageNumber')
AddEventHandler('FiveM-Phone:Server.deleteMessageNumber', function(number)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	deleteAllMessageFromPhoneNumber(sourcePlayer,Character_ID, number)
	-- TriggerClientEvent("'FiveM-Phone:Server.allMessage", sourcePlayer, getMessages(Character_ID))
end)

RegisterServerEvent('FiveM-Phone:Server.deleteAllMessage')
AddEventHandler('FiveM-Phone:Server.deleteAllMessage', function()
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	deleteAllMessage(Character_ID)
end)

RegisterServerEvent('FiveM-Phone:Server.setReadMessageNumber')
AddEventHandler('FiveM-Phone:Server.setReadMessageNumber', function(num)
	local Character_ID = getPlayerID(source)
	setReadMessageNumber(Character_ID, num)
end)

RegisterServerEvent('FiveM-Phone:Server.deleteALL')
AddEventHandler('FiveM-Phone:Server.deleteALL', function()
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	deleteAllMessage(Character_ID)
	deleteAllContact(Character_ID)
	appelsDeleteAllHistorique(Character_ID)
	TriggerClientEvent("'FiveM-Phone:Server.contactList", sourcePlayer, {})
	TriggerClientEvent("'FiveM-Phone:Server.allMessage", sourcePlayer, {})
	TriggerClientEvent("appelsDeleteAllHistorique", sourcePlayer, {})
end)

--====================================================================================
-- Gestion des appels
--====================================================================================
local AppelsEnCours = {}
local PhoneFixeInfo = {}
local lastIndexCall = 10

function getHistoriqueCall (num)
	local result = MySQL.Sync.fetchAll("SELECT * FROM FMPhone_Calls WHERE FMPhone_Calls.owner = @num ORDER BY time DESC LIMIT 25", {
		['@num'] = num
	})
	return result
end

function sendHistoriqueCall (src, num)
	local histo = getHistoriqueCall(num)
	TriggerClientEvent('FiveM-Phone:Server.historiqueCall', src, histo)
end

function saveAppels (appelInfo)
	if appelInfo.extraData == nil or appelInfo.extraData.useNumber == nil then
		MySQL.Async.insert("INSERT INTO FMPhone_Calls (`Mobile_Number`, `Contact_Number`,`Inbound`, `Accepted`) VALUES(@Mobile_Number, @Contact_Number, @Inbound, @Accepted)", {
			['@Mobile_Number'] = appelInfo.Sender_num,
			['@Contact_Number'] = appelInfo.Receiver_num,
			['@Inbound'] = 1,
			['@Accepted'] = appelInfo.is_accepts
		}, function()
			notifyNewAppelsHisto(appelInfo.Sender_src, appelInfo.Sender_num)
		end)
	end
	if appelInfo.is_valid == true then
		local num = appelInfo.Sender_num
		if appelInfo.hidden == true then
			mun = "04########"
		end
		MySQL.Async.insert("INSERT INTO FMPhone_Calls (`Mobile_Number`, `Contact_Number`,`Inbound`, `Accepted`) VALUES(@Mobile_Number, @Contact_Number, @Inbound, @Accepted)", {
			['@Mobile_Number'] = appelInfo.Receiver_num,
			['@Contact_Number'] = num,
			['@Inbound'] = 0,
			['@Accepted'] = appelInfo.is_accepts
		}, function()
			if appelInfo.Receiver_src ~= nil then
				notifyNewAppelsHisto(appelInfo.Receiver_src, appelInfo.Receiver_num)
			end
		end)
	end
end

function notifyNewAppelsHisto (src, num)
	sendHistoriqueCall(src, num)
end

RegisterServerEvent('FiveM-Phone:Server.getHistoriqueCall')
AddEventHandler('FiveM-Phone:Server.getHistoriqueCall', function()
	local sourcePlayer = tonumber(source)
	local srcCharacter_ID = getPlayerID(source)
	local srcPhone = getNumberPhone(srcCharacter_ID)
	sendHistoriqueCall(sourcePlayer, num)
end)


RegisterServerEvent('FiveM-Phone:Server.internal_startCall')
AddEventHandler('FiveM-Phone:Server.internal_startCall', function(source, Mobile_Number, rtcOffer, extraData)
	if FixePhone[Mobile_Number] ~= nil then
		onCallFixePhone(source, Mobile_Number, rtcOffer, extraData)
		return
	end
	
	local rtcOffer = rtcOffer
	if Mobile_Number == nil or Mobile_Number == '' then
		print('BAD CALL NUMBER IS NIL')
		return
	end
	
	local hidden = string.sub(Mobile_Number, 1, 1) == '#'
	if hidden == true then
		Mobile_Number = string.sub(Mobile_Number, 2)
	end
	
	local indexCall = lastIndexCall
	lastIndexCall = lastIndexCall + 1
	
	local sourcePlayer = tonumber(source)
	local srcCharacter_ID = getPlayerID(source)
	
	local srcPhone = ''
	print(json.encode(extraData))
	if extraData ~= nil and extraData.useNumber ~= nil then
		srcPhone = extraData.useNumber
	else
		srcPhone = getNumberPhone(srcCharacter_ID)
	end
	print('CALL WITH NUMBER ' .. srcPhone)
	local destPlayer = getCharacter_IDByPhoneNumber(Mobile_Number)
	local is_valid = destPlayer ~= nil and destPlayer ~= srcCharacter_ID
	AppelsEnCours[indexCall] = {
		id = indexCall,
		Sender_src = sourcePlayer,
		Sender_num = srcPhone,
		Receiver_src = nil,
		Receiver_num = Mobile_Number,
		is_valid = destPlayer ~= nil,
		is_accepts = false,
		hidden = hidden,
		rtcOffer = rtcOffer,
		extraData = extraData
	}
	
	
	if is_valid == true then
		getSourceFromCharacter_ID(destPlayer, function (srcTo)
			if srcTo ~= nill then
				AppelsEnCours[indexCall].Receiver_src = srcTo
				TriggerEvent('FiveM-Phone:Server.addCall', AppelsEnCours[indexCall])
				TriggerClientEvent('FiveM-Phone:Server.waitingCall', sourcePlayer, AppelsEnCours[indexCall], true)
				TriggerClientEvent('FiveM-Phone:Server.waitingCall', srcTo, AppelsEnCours[indexCall], false)
			else
				TriggerEvent('FiveM-Phone:Server.addCall', AppelsEnCours[indexCall])
				TriggerClientEvent('FiveM-Phone:Server.waitingCall', sourcePlayer, AppelsEnCours[indexCall], true)
			end
		end)
	else
		TriggerEvent('FiveM-Phone:Server.addCall', AppelsEnCours[indexCall])
		TriggerClientEvent('FiveM-Phone:Server.waitingCall', sourcePlayer, AppelsEnCours[indexCall], true)
	end
	
end)

RegisterServerEvent('FiveM-Phone:Server.startCall')
AddEventHandler('FiveM-Phone:Server.startCall', function(Mobile_Number, rtcOffer, extraData)
	TriggerEvent('FiveM-Phone:Server.internal_startCall',source, Mobile_Number, rtcOffer, extraData)
end)

RegisterServerEvent('FiveM-Phone:Server.candidates')
AddEventHandler('FiveM-Phone:Server.candidates', function (callId, candidates)
	print('send cadidate', callId, candidates)
	if AppelsEnCours[callId] ~= nil then
		local source = source
		local to = AppelsEnCours[callId].Sender_src
		if source == to then
			to = AppelsEnCours[callId].Receiver_src
		end
		print('TO', to)
		TriggerClientEvent('FiveM-Phone:Server.candidates', to, candidates)
	end
end)


RegisterServerEvent('FiveM-Phone:Server.acceptCall')
AddEventHandler('FiveM-Phone:Server.acceptCall', function(infoCall, rtcAnswer)
	local id = infoCall.id
	if AppelsEnCours[id] ~= nil then
		if PhoneFixeInfo[id] ~= nil then
			onAcceptFixePhone(source, infoCall, rtcAnswer)
			return
		end
		AppelsEnCours[id].Receiver_src = infoCall.Receiver_src or AppelsEnCours[id].Receiver_src
		if AppelsEnCours[id].Sender_src ~= nil and AppelsEnCours[id].Receiver_src~= nil then
			AppelsEnCours[id].is_accepts = true
			AppelsEnCours[id].rtcAnswer = rtcAnswer
			TriggerClientEvent('FiveM-Phone:Server.acceptCall', AppelsEnCours[id].transmitter_src, AppelsEnCours[id], true)
			SetTimeout(1000, function()
			TriggerClientEvent('FiveM-Phone:Server.acceptCall', AppelsEnCours[id].receiver_src, AppelsEnCours[id], false)
			end)
			saveAppels(AppelsEnCours[id])
		end
	end
end)


RegisterServerEvent('FiveM-Phone:Server.rejectCall')
AddEventHandler('FiveM-Phone:Server.rejectCall', function (infoCall)
	local id = infoCall.id
	if AppelsEnCours[id] ~= nil then
		if PhoneFixeInfo[id] ~= nil then
			onRejectFixePhone(source, infoCall)
			return
		end
		if AppelsEnCours[id].Sender_src ~= nil then
			TriggerClientEvent('FiveM-Phone:Server.rejectCall', AppelsEnCours[id].Sender_src)
		end
		if AppelsEnCours[id].Receiver_src ~= nil then
			TriggerClientEvent('FiveM-Phone:Server.rejectCall', AppelsEnCours[id].Receiver_src)
		end
		
		if AppelsEnCours[id].is_accepts == false then
			saveAppels(AppelsEnCours[id])
		end
		TriggerEvent('FiveM-Phone:Server.removeCall', AppelsEnCours)
		AppelsEnCours[id] = nil
	end
end)

RegisterServerEvent('FiveM-Phone:Server.appelsDeleteHistorique')
AddEventHandler('FiveM-Phone:Server.appelsDeleteHistorique', function (numero)
	local sourcePlayer = tonumber(source)
	local srcCharacter_ID = getPlayerID(source)
	local srcPhone = getNumberPhone(srcCharacter_ID)
	MySQL.Sync.execute("DELETE FROM FMPhone_Calls WHERE `Mobile_Number` = @Mobile_Number AND `Contact_Number` = @Contact_Number", {
		['@Mobile_Number'] = srcPhone,
		['@Contact_Number'] = numero
	})
end)

function appelsDeleteAllHistorique(srcCharacter_ID)
	local srcPhone = getNumberPhone(srcCharacter_ID)
	MySQL.Sync.execute("DELETE FROM FMPhone_Calls WHERE `Mobile_Number` = @Mobile_Number", {
		['@Mobile_Number'] = srcPhone
	})
end

RegisterServerEvent('FiveM-Phone:Server.appelsDeleteAllHistorique')
AddEventHandler('FiveM-Phone:Server.appelsDeleteAllHistorique', function ()
	local sourcePlayer = tonumber(source)
	local srcCharacter_ID = getPlayerID(source)
	appelsDeleteAllHistorique(srcCharacter_ID)
end)


--====================================================================================
-- OnLoad
--====================================================================================
AddEventHandler('es:playerLoaded',function(source)
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	getOrGeneratePhoneNumber(sourcePlayer, Character_ID, function (myPhoneNumber)
		TriggerClientEvent("'FiveM-Phone:Server.myPhoneNumber", sourcePlayer, myPhoneNumber)
		TriggerClientEvent("'FiveM-Phone:Server.contactList", sourcePlayer, getContacts(Character_ID))
		TriggerClientEvent("'FiveM-Phone:Server.allMessage", sourcePlayer, getMessages(Character_ID))
	end)
end)

-- Just For reload
RegisterServerEvent('FiveM-Phone:Server.allUpdate')
AddEventHandler('FiveM-Phone:Server.allUpdate', function()
	local sourcePlayer = tonumber(source)
	local Character_ID = getPlayerID(source)
	local num = FindMobileNumberOfCharacter(Character_ID)
	TriggerClientEvent("'FiveM-Phone:Server.myPhoneNumber", sourcePlayer, num)
	TriggerClientEvent("'FiveM-Phone:Server.contactList", sourcePlayer, getContacts(Character_ID))
	TriggerClientEvent("'FiveM-Phone:Server.allMessage", sourcePlayer, getMessages(Character_ID))
	TriggerClientEvent('FiveM-Phone:Server.getBourse', sourcePlayer, getBourse())
	sendHistoriqueCall(sourcePlayer, num)
end)






function onCallFixePhone (source, Mobile_Number, rtcOffer, extraData)
	local indexCall = lastIndexCall
	lastIndexCall = lastIndexCall + 1
	
	local hidden = string.sub(Mobile_Number, 1, 1) == '#'
	if hidden == true then
		Mobile_Number = string.sub(Mobile_Number, 2)
	end
	local sourcePlayer = tonumber(source)
	local srcCharacter_ID = getPlayerID(source)
	
	local srcPhone = ''
	if extraData ~= nil and extraData.useNumber ~= nil then
		srcPhone = extraData.useNumber
	else
		srcPhone = getNumberPhone(srcCharacter_ID)
	end
	
	AppelsEnCours[indexCall] = {
		id = indexCall,
		Sender_src = sourcePlayer,
		Sender_num = srcPhone,
		Receiver_src = nil,
		Receiver_num = Mobile_Number,
		is_valid = false,
		is_accepts = false,
		hidden = hidden,
		rtcOffer = rtcOffer,
		extraData = extraData,
		coords = FixePhone[Mobile_Number].coords
	}
	
	PhoneFixeInfo[indexCall] = AppelsEnCours[indexCall]
	
	TriggerClientEvent('FiveM-Phone:Server.notifyFixePhoneChange', -1, PhoneFixeInfo)
	TriggerClientEvent('FiveM-Phone:Server.waitingCall', sourcePlayer, AppelsEnCours[indexCall], true)
end



function onAcceptFixePhone(source, infoCall, rtcAnswer)
	local id = infoCall.id
	
	AppelsEnCours[id].Receiver_src = source
	if AppelsEnCours[id].Sender_src ~= nil and AppelsEnCours[id].Receiver_src~= nil then
		AppelsEnCours[id].is_accepts = true
		AppelsEnCours[id].forceSaveAfter = true
		AppelsEnCours[id].rtcAnswer = rtcAnswer
		PhoneFixeInfo[id] = nil
		TriggerClientEvent('FiveM-Phone:Server.notifyFixePhoneChange', -1, PhoneFixeInfo)
		TriggerClientEvent('FiveM-Phone:Server.acceptCall', AppelsEnCours[id].transmitter_src, AppelsEnCours[id], true)
		SetTimeout(1000, function()
		TriggerClientEvent('FiveM-Phone:Server.acceptCall', AppelsEnCours[id].receiver_src, AppelsEnCours[id], false)
		end)
		saveAppels(AppelsEnCours[id])
	end
end

function onRejectFixePhone(source, infoCall, rtcAnswer)
	local id = infoCall.id
	PhoneFixeInfo[id] = nil
	TriggerClientEvent('FiveM-Phone:Server.notifyFixePhoneChange', -1, PhoneFixeInfo)
	TriggerClientEvent('FiveM-Phone:Server.rejectCall', AppelsEnCours[id].Sender_src)
	if AppelsEnCours[id].is_accepts == false then
		saveAppels(AppelsEnCours[id])
	end
	AppelsEnCours[id] = nil
	
end

------------------------------------------------------------------------------
--	Threads																	--
------------------------------------------------------------------------------



------------------------------------------------------------------------------
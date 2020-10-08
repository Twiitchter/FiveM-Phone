fx_version 'adamant'

games {

'gta5' 

}

description 'FiveM-Phone'

version '0.0.1'

ui_page 'core/fivem-phone.html'
file 'core/fivem-phone.html'

client_scripts {
	--[[====================================DEFAULTS=================================]]--
	
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',	
	'config.lua',
	
	--========================================CORE=====================================--
	
	'core/fivem-phone.html',
	'core/client/client.lua',
	'core/css/fivem-phone.css',
	'core/js/fivem-phone.js',
	'core/img/phone.png',
	'core/fonts/Serithai.ttf',
	'core/fonts/Whistle.otf',
	
	--=================================================================================--
	
	--[[================================BEGIN APPS SECTION===========================]]--
	
	--===================================== CALL APP ==================================--
	-- APP IMAGE ON HOME SCREEN --
	'addons/[1] Call/Call.png',
	-- CLIENT LUA --
	'addons/[1] Call/client/client.lua',
	-- CSS --
	'addons/[1] Call/htmls/css/call.application.css',
	'addons/[1] Call/htmls/css/call.notification.css',
	-- JS --
	'addons/[1] Call/htmls/js/call.application.js',
	'addons/[1] Call/htmls/js/call.notification.js',
	-- HTML --
	'addons/[1] Call/htmls/call.application.html',
	'addons/[1] Call/htmls/call.notification.html',
	-- LOCALES --
	'addons/[1] Call/locales/en.lua',
	
	--=================================================================================--
	
	--=================================== MESSAGE APP =================================--
	-- APP IMAGE ON HOME SCREEN --	
	'addons/[2] Message/Message.png',
	-- CLIENT LUA --
	'addons/[2] Message/client/client.lua',
	-- CSS --
	'addons/[2] Message/htmls/css/call.application.css',
	'addons/[2] Message/htmls/css/call.notification.css',
	-- JS --
	'addons/[2] Message/htmls/js/call.application.js',
	'addons/[2] Message/htmls/js/call.notification.js',
	-- HTML --
	'addons/[2] Message/htmls/call.application.html',
	'addons/[2] Message/htmls/call.notification.html',
	-- LOCALES --
	'addons/[2] Message/locales/en.lua',

	--=================================================================================--

	--================================== CONTACTS APP =================================--
	-- APP IMAGE ON HOME SCREEN --	
	'addons/[3] Contacts/Contacts.png',
	-- CLIENT LUA --
	'addons/[3] Contacts/client/client.lua',
	-- CSS --
	'addons/[3] Contacts/htmls/css/call.application.css',
	'addons/[3] Contacts/htmls/css/call.notification.css',
	-- JS --
	'addons/[3] Contacts/htmls/js/call.application.js',
	'addons/[3] Contacts/htmls/js/call.notification.js',
	-- HTML --
	'addons/[3] Contacts/htmls/call.application.html',
	'addons/[3] Contacts/htmls/call.notification.html',
	-- LOCALES --
	'addons/[3] Contacts/locales/en.lua',

	--=================================================================================--

	--=================================== BANKING APP =================================--
	-- APP IMAGE ON HOME SCREEN --	
	'addons/[4] Bank/Bank.png',
	-- CLIENT LUA --
	'addons/[4] Bank/client/client.lua',
	-- CSS --
	'addons/[4] Bank/htmls/css/call.application.css',
	'addons/[4] Bank/htmls/css/call.notification.css',
	-- JS --
	'addons/[4] Bank/htmls/js/call.application.js',
	'addons/[4] Bank/htmls/js/call.notification.js',
	-- HTML --
	'addons/[4] Bank/htmls/call.application.html',
	'addons/[4] Bank/htmls/call.notification.html',
	-- LOCALES --
	'addons/[4] Bank/locales/en.lua',

	--=================================================================================--
	
}

server_scripts {
	--[[===================================DEFAULTS==================================]]--
	
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',	
	'config.lua',
	
	--=======================================CORE======================================--

	'core/server/server.lua',
	
	--=================================================================================--
	
	--[[===============================BEGIN APPS SECTION============================]]--	
	-- ADDON SCRIPTS FOR SERVER --
	
	'addons/FMP_Call/server/server.lua',
	'addons/FMP_Message/server/server.lua',	
	'addons/FMP_Contacts/server/server.lua',
	'addons/FMP_Bank/server/server.lua',
	
	-- ADDON SCRIPTS FOR SERVER --
	--=================================================================================--	
}

-- Client Side Exported Functions --
exports { 
}	

-- Server Side Exported Functions --	
server_exports {
}

-- Prequisites --
dependencies {

}
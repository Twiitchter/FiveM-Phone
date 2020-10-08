-- 		 LosOceanic_PhoneMK.1 =  My Attempt at building a phones			--
--																			--
--			By DK - 2019			...	Dont forget your Bananas!			--
------------------------------------------------------------------------------

--[[ Loading ESX Object Dependancies ]]--

ESX               = nil

TriggerEvent('Frame:getSharedObject', function(obj) ESX = obj end)

--[[ ESX Loaded - Generate Code Below ]]--

------------------------------------------------------------------------------
--	Script Locals Variables													--
------------------------------------------------------------------------------

-- Always follow a truely random number as the time is the seed when called...
math.randomseed(os.time())

------------------------------------------------------------------------------
--	Functions																--
------------------------------------------------------------------------------

function GeneratePhoneNumber()

	local ServiceProvider = nil
	-- Lets declare our telecom providers...	
	local Provider = {
	['1'] = 'TeleCom1', ['2'] = 'TeleCom1', ['3'] = 'TeleCom1',
	['4'] = 'TeleCom2', ['5'] = 'TeleCom2', ['6'] = 'TeleCom2',
	['7'] = 'TeleCom3',	['8'] = 'TeleCom3',	['9'] = 'TeleCom3',
	['0'] = 'TeleCom4',
	}

	-- Country Code, In Australia is only 04xxxxxxxx,10 digits in total.
	local CountryCode = math.random(04,04)
	
	-- the remaining numbers. xx01234567.
	local Remaning = math.random(00000000,99999999)
	
	-- So lets make the start, 0nly between, 04 and 04. Then the rest random.
	-- There is no space between the two numbers, no - or .
	-- If you were in a country with a - the string format would be. "%02d-%08d"
	local GeneratedNumber = string.format('%02d%08d', CountryCode, Remaning)
	
	-- Lets now, find the provider based on the first few digits of the Remaning numbers.
	local function GetProvider(var)
		return tonumber(tostring(var):sub( 1, 1))
	end
	
	-- If the number returned is anything other than nil, that it started at find the provider.
	if GetProvider(Remaning) ~= nil then
		for k,v in ipairs(Provider[v]) do
			if (v == GetProvider(Remaning)) then
				ServiceProvider = v 
				break
			end
		end
	else
		print('	^0[^3Error^0] : PhoneMK.1 | Resource not assigning number correctly. | PhoneMK.1 : ^0[^3Error^0] ')
	end
	
	return GeneratedNumber, ServiceProvider
end

------------------------------------------------------------------------------
--	Threads																	--
------------------------------------------------------------------------------



------------------------------------------------------------------------------
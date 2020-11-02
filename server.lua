-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_drinkstore",src)
vCLIENT = Tunnel.getInterface("vrp_drinkstore")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local robbery = false
local timedown = 0

local robbers = {
	[1] = { ['place'] = "Loja de Bebidas", ['seconds'] = 180, ['rewmin'] = 180000, ['rewmax'] = 210000 },
	[2] = { ['place'] = "Loja de Bebidas", ['seconds'] = 180, ['rewmin'] = 180000, ['rewmax'] = 210000 },
	[3] = { ['place'] = "Loja de Bebidas", ['seconds'] = 180, ['rewmin'] = 180000, ['rewmax'] = 210000 },
	[4] = { ['place'] = "Loja de Bebidas", ['seconds'] = 180, ['rewmin'] = 180000, ['rewmax'] = 210000 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookboate = "https://discordapp.com/api/webhooks/730836367990325319/dkDeA8_n_kUp1cSC4lNwg11FiFKJfl_-jIjOhH21A4AJGenC1a3Nx4m1XWOF8dSCcvms"

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPOLICE
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkPolice()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local policia = vRP.getUsersByPermission("policia.permissao")
		if #policia < 6 and not vRPclient.changingClothes(source) then
			TriggerClientEvent("Notify",source,"aviso","Número insuficiente de policiais no momento.",8000)
			return false
		elseif (os.time()-timedown) <= 2700 then
			TriggerClientEvent("Notify",source,"aviso","Os cofres estão vazios, aguarde <b>"..vRP.format(parseInt((2700-(os.time()-timedown)))).." segundos</b> até que os civis efetuem depositos.",8000)
			return false
		end
	end
	return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKTIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkTimers2()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local policia = vRP.getUsersByPermission("policia.permissao")
		if #policia < 5 then
			TriggerClientEvent("Notify",source,"aviso","Número insuficiente de policiais no momento.",8000)
			return false
		elseif (os.time()-timedown) <= 2700 then
			TriggerClientEvent("Notify",source,"aviso","Os cofres estão vazios, aguarde <b>"..vRP.format(parseInt((2700-(os.time()-timedown)))).." segundos</b> até que os civis efetuem depositos.",8000)
			return false
		else			
			return true
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
function src.startRobbery(id,x,y,z)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		robbery = true
		timedown = os.time()
		vCLIENT.startRobbery(source,robbers[id].seconds,x,y,z)
		TriggerClientEvent("vrp_sound:source",source,'alarm',0.7)

		local policia = vRP.getUsersByPermission("policia.permissao")
		for k,v in pairs(policia) do
			local policial = vRP.getUserSource(v)
			if policial then
				async(function()
					vCLIENT.startRobberyPolice(policial,x,y,z,robbers[id].place)
					vRPclient.playSound(policial,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
					TriggerClientEvent('chatMessage',policial,"911",{64,64,255},"Roubo a ^1"..robbers[id].place.."^0 iniciada, dirija-se até o local e intercepte os assaltantes.")
				end)
			end
		end

		SendWebhookMessage(webhookboate,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		SetTimeout(robbers[id].seconds*1000,function()
			if robbery then
				robbery = false
				--vRP.giveInventoryItem(user_id,"dinheirosujo",parseInt(math.random(robbers[id].rewmin,robbers[id].rewmax)))
				for k,v in pairs(policia) do
					local policial = vRP.getUserSource(v)
					if policial then
						async(function()
							vCLIENT.stopRobberyPolice(policial)
							TriggerClientEvent('chatMessage',policial,"911",{64,64,255},"O roubo terminou, os assaltantes estão correndo antes que vocês cheguem.")
						end)
					end
				end
			end
		end)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
function src.stopRobbery()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if robbery then
			robbery = false
			rewardsNumber = 1
			local policia = vRP.getUsersByPermission("policia.permissao")
			for k,v in pairs(policia) do
				local policial = vRP.getUserSource(v)
				if policial then
					async(function()
						vCLIENT.stopRobberyPolice(policial)
						TriggerClientEvent('chatMessage',policial,"911",{64,64,255},"O assaltante saiu correndo e deixou tudo para trás.")
					end)
				end
			end
		end
	end
end

function src.giveAwards()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if robbery then
			local rewardsList = {
				[1] = { ['index'] = "cerveja", ['qtd'] = math.random(90,130) },
				[2] = { ['index'] = "tequila", ['qtd'] = math.random(80,120) },
				[3] = { ['index'] = "vodka", ['qtd'] = math.random(70,120) },
				[4] = { ['index'] = "whisky", ['qtd'] = math.random(60,110) },
				[5] = { ['index'] = "conhaque", ['qtd'] = math.random(60,110) },
				[6] = { ['index'] = "absinto", ['qtd'] = math.random(60,120) },
				[7] = { ['index'] = "energetico", ['qtd'] = math.random(1,3) },
			}

			vRP.searchTimer(user_id,120)
			local receivedReward = vRP.itemNameList("dinheirosujo")
			local receivedAmount = math.random(6000,12000)
			if math.random(100) >= 60 then
				vRP.giveInventoryItem(user_id,"dinheirosujo",receivedAmount)
			else
				local rewardsNumber = math.random(#rewardsList)
				receivedAmount = parseInt(rewardsList[rewardsNumber].qtd)
				receivedReward = vRP.itemNameList(rewardsList[rewardsNumber].index)
				vRP.giveInventoryItem(user_id,rewardsList[rewardsNumber].index,receivedAmount)
			end
			
			TriggerClientEvent("Notify",source,"importante","Você recebeu <b>"..receivedAmount.."x "..receivedReward.."</b>.")
		end
	end
end
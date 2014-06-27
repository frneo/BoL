--[[
Script Name: Neo's Little Helper
Author: Neo
Version: 0.1
Revision Date: June 27, 2014
Purpose: Overhead hud-integrated cooldown tracker and general utility
--------------------------------------------------------------
@Future features planned: 
	- FoW recall warning (if I'm allowed to post it)
	- Enemy buff tracker (same as above)			
	Unfortunately this will be VIP only
	Others:
	- Improve hud
	- Suggestions ?
--------------------------------------------------------------
Version 0.1 - Initial release
--------------------------------------------------------------
]]

local version = '0.1'
local TickLimit = 0
local enemyList
local sumsprite1
local sumsprite2
local loaded = false
local loaded2 = false
-- ProTracker Tables --
local TrackSpells = {_Q, _W, _E, _R, SUMMONER_1, SUMMONER_2}
local SSpells = {			  
						{CName="flash", Name="SummonerFlash" },
						{CName="ghost", Name="SummonerHaste" },
						{CName="ignite", Name="SummonerDot"},
						{CName="barrier", Name="SummonerBarrier"},
						{CName="smite", Name="SummonerSmite"},
						{CName="exhaust", Name="SummonerExhaust"},
						{CName="heal", Name="SummonerHeal"},
						{CName="teleport", Name="SummonerTeleport"},
						{CName="cleanse", Name="SummonerBoost"},
						{CName="clarity", Name="SummonerMana"},
						{CName="clair", Name="SummonerClairvoyance"},
						{CName="revive", Name="SummonerRevive"},
						{CName="garrison", Name="SummonerOdinGarrison"},
						}
local SpellsData = {}
--------------------------
local main_hud
local button_green
local button_red

function OnLoad()
	local SPRITES_PATH = BOL_PATH.."Sprites\\"
	Init()
	PrintChat("<font color='#01A9DB'>Neo's little helper</font>")
end

function LoadMenu()
	config = scriptConfig("Neo's Little Helper", "NeosLittleHelper")
	
	config:addParam("on", "Turn cooldown tracker on/off", SCRIPT_PARAM_ONOFF, true)
	
end

function Init()
		LoadMenu()
		LoadEnemies()
		main_hud = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\main.tga')
		button_green = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\button_green.tga')
		button_red = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\button_red.tga')
end

function LoadEnemies()
	enemyList = {}
	local ii
	local sname
	local sname2
	if heroManager.iCount > 0 then
		for i = 1, heroManager.iCount, 1 do			
			local enemy = heroManager:getHero(i)
			if enemy.team ~= myHero.team then
			  ii = enemy.charName
				enemyList[ii] = { name = enemy.charName, pkt = i + 0x18, sprite1_on, sprite1_off, sprite2_on, sprite2_off, recalling = true }
				sname = enemy:GetSpellData(SUMMONER_1).name
				sname2 = enemy:GetSpellData(SUMMONER_2).name
				for _, ss in pairs(SSpells) do
					if (sname == ss.Name) then
						enemyList[ii].sprite1_off = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\'..ss.CName..'_off.tga')		
						enemyList[ii].sprite1_on = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\'..ss.CName..'_on.tga')
					end	
					if (sname2 == ss.Name) then
						enemyList[ii].sprite2_off = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\'..ss.CName..'_off.tga')		
						enemyList[ii].sprite2_on = FindSprite(SPRITE_PATH .. 'NeosLittleHelper\\'..ss.CName..'_on.tga')
					end	
				end
			end
		end
	end
	loaded = true
end


function GetBarData(enemy)
	local barWidth = 169 -- 140
	local barHeight = 47
	local barOffsetX = 27
	local barOffsetY = 37
	local barData = GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
  local barPosOffset = GetUnitHPBarOffset(enemy)
  local barPosPercentageOffset = { x = barData.PercentageOffset.x, y = barData.PercentageOffset.y }
	barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * barWidth +barOffsetX
	barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * barHeight + barOffsetY
	return barPos
end

function OnDraw()
  if loaded and loaded2 and config.on then
		local ii
	  for i = 1, heroManager.iCount, 1 do
			local enemy = heroManager:getHero(i)
			if enemy.team ~= myHero.team and (ValidTarget(enemy, math.huge,false) or ValidTarget(enemy)) then
			  ii = enemy.charName
				local barpos = { }
        local pos1 = GetUnitHPBarPos(enemy)
				local nx = (GetUnitHPBarOffset(enemy).x - 0.5) * 50 - 5
        local x = pos1.x + nx	
        local ny = (GetUnitHPBarOffset(enemy).y - 0.5) * 50 - 5
        local y = pos1.y + ny
				barpos.x = x - 60
				barpos.y = y + 24
				if OnScreen(barpos.x, barpos.y) and enemy.dead ~= true and enemy.visible and (SpellsData[ii] ~= nil) then
					main_hud:Draw(barpos.x,barpos.y, 0xFF)

					for v, s in pairs (TrackSpells) do
						if (v == 1) then
								if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s] ) then		
									button_red:Draw(barpos.x + 27, barpos.y + 20, 0xFF)
									if (SpellsData[ii][s].currentCd ~= nil) then
										DrawText(tostring(SpellsData[ii][s].currentCd), 13, barpos.x + 31, barpos.y + 21, ARGB(255, 255, 255, 255))	
									end
								else
									button_green:Draw(barpos.x + 27, barpos.y + 20, 0xFF)
									DrawText('Q', 13, barpos.x + 31, barpos.y + 21, ARGB(255, 255, 255,255))
									
								end
						elseif (v == 2) then
							if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s] ) then	
								button_red:Draw(barpos.x + 46, barpos.y + 20, 0xFF)		
								if (SpellsData[ii][s].currentCd ~= nil) then						
									DrawText(tostring(SpellsData[ii][s].currentCd), 13, barpos.x + 50, barpos.y + 21, ARGB(255, 255, 255, 255))	
								end
							else	
								button_green:Draw(barpos.x + 46, barpos.y + 20, 0xFF)
								DrawText('W', 13, barpos.x + 50, barpos.y + 21, ARGB(255, 255, 255, 255))
							end
						elseif (v == 3) then
							if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s] ) then	
								button_red:Draw(barpos.x + 65, barpos.y + 20, 0xFF)	
								if (SpellsData[ii][s].currentCd ~= nil) then
									DrawText(tostring(SpellsData[ii][s].currentCd), 13, barpos.x + 69, barpos.y + 21, ARGB(255, 255, 255, 255))					
								end
							else	
								button_green:Draw(barpos.x + 65, barpos.y + 20, 0xFF)
								DrawText('E', 13, barpos.x + 69, barpos.y + 21, ARGB(255, 255, 255, 255))
							end
						elseif (v == 4) then
							if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s] ) then	
								button_red:Draw(barpos.x + 84, barpos.y + 20, 0xFF)
								if SpellsData[ii][s].currentCd < 100 then
									if (SpellsData[ii][s].currentCd ~= nil) then
										DrawText(tostring(SpellsData[ii][s].currentCd ), 13, barpos.x + 88, barpos.y + 21, ARGB(255, 255, 255, 255))
									end
								else
									if (SpellsData[ii][s].currentCd ~= nil) then
										DrawText(tostring(SpellsData[ii][s].currentCd), 9, barpos.x + 88, barpos.y + 22, ARGB(255, 255, 255, 255))	
									end
								end
							else	
								button_green:Draw(barpos.x + 84, barpos.y + 20, 0xFF)
								DrawText('R', 13, barpos.x + 88, barpos.y + 21, ARGB(255, 255, 255, 255))
							end
						elseif (v == 5) then								
									if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s]) then
										enemyList[ii].sprite1_off:Draw(barpos.x + 2,barpos.y + 2,0xFF)
										
										DrawText(tostring(SpellsData[ii][s].currentCd), 11, barpos.x + 3, barpos.y + 3, ARGB(255, 255, 255, 255))
									else									
										enemyList[ii].sprite1_on:Draw(barpos.x + 2,barpos.y + 2,0xFF)
									end
						elseif (v == 6) then								
									if (SpellsData[ii][s].currentCd ~= 0 and SpellsData[ii][s]) then
										enemyList[ii].sprite2_off:Draw(barpos.x + 2,barpos.y + 20, 0xFF)
										DrawText(tostring(SpellsData[ii][s].currentCd), 11, barpos.x + 3, barpos.y + 21, ARGB(255, 255, 255, 255))
									else									
										enemyList[ii].sprite2_on:Draw(barpos.x + 2,barpos.y + 20, 0xFF)
									end
						end
					end					
				end
			end
		end	
  end
end

function neoGetBar(enemy)

end

function GetHPBarPos(enemy)
	enemy.barData = {PercentageOffset = {x=0, y=0}}
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY = 37
	local StartHpPos = 31
	
	barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
	barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)
						
	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos =  Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end


function OnTick()
	if (loaded) and os.clock() > TickLimit then
		TickLimit = os.clock() + 0.3
		local ii
	  for i = 1, heroManager.iCount, 1 do
			local enemy = heroManager:getHero(i)
			if enemy.team ~= myHero.team then
			  ii = enemy.charName
				for v, s in pairs(TrackSpells) do
					if SpellsData[ii] == nil then
						SpellsData[ii] = {}
					end
					if SpellsData[ii][s] == nil then
						SpellsData[ii][s] = {currentCd = 0, level = 0, name = '' }
					end
					local thisspell = enemy:GetSpellData(s)
					local cd
					if thisspell and thisspell.currentCd then
						cd = thisspell.currentCd
					end
					if cd and thisspell and thisspell.currentCd then
						SpellsData[ii][s] = { currentCd = math.floor(cd), level = thisspell.level, name = thisspell.name }
					end
					
				end
			end
		end
	end	
	loaded2 = true
end


function FindSprite(file) -- Thanks to Trees
    assert(type(file) == "string", "GetSprite: wrong argument types (<string> expected for file)")
    if FileExist(file) == true then
        return createSprite(file)
    else
        PrintChat(file .. " not found (sprites installed ?)")
        return createSprite("empty.dds")
    end
end


function OnUnload()
    for index, enemy in pairs(enemyList) do
        enemy.sprite1_on:Release()
				enemy.sprite1_off:Release()
				enemy.sprite2_on:Release()
				enemy.sprite2_off:Release()
    end    
		main_hud:Release()
		button_green:Release()
		button_red:Release()
end

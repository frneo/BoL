local TickLimit = 100

local LastAction
local LastTick

function OnLoad()
  if myHero:CanUseSpell(RECALL) then
	  PrintChat("yes")
	end
	LastAction = GetTickCount()
	LastTick = GetTickCount()
	config = scriptConfig("Neo's Anti-AFK", "NeosAntiAFK")
	config:addParam("onoff", "Enabled", SCRIPT_PARAM_ONOFF, true)
	PrintChat("<font color='#20FF52'>Neo's Anti-AFK</font>")
end

function CheckLastAction()
  if GetTickCount() - LastAction > 20000 then
	  myHero:MoveTo(myHero.x, myHero.z)
	end
end

function OnProcessSpell(object, spell)
  if object and spell and object == myHero then
	  LastAction = GetTickCount()
	end
end

function OnTick()
  if not config.onoff then return end
  if ( GetTickCount() - LastTick ) < TickLimit then return end
	LastTick = GetTickCount()
  for i = myHero.pathIndex, myHero.pathCount do
	  local wpath = myHero:GetPath(i)
		if ( wpath ~= nil and wpath.x ) then
		  LastAction = GetTickCount()
		end
	end
	CheckLastAction()
end
local version = 0.1
local TickLimit = 100

local LastAction
local LastTick

function OnLoad()
	LastAction = GetTickCount() - 11000
	LastTick = GetTickCount()
	config = scriptConfig("Neo's Anti-AFK", "NeosAntiAFK")
	config:addParam("onoff", "Enabled", SCRIPT_PARAM_ONOFF, true)
	PrintChat("<font color='#20FF52'>Neo's Anti-AFK</font>")
end

function CheckLastAction()
  if GetTickCount() - LastAction > 10000 then
	  myHero:MoveTo(myHero.x, myHero.z)
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
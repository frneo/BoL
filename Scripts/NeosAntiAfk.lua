local version = "0.2"
local TickLimit = 100
local LastAction
local LastTick
local lastAnimation = ""
local RefreshRate = 20000 --milliseconds to refresh antiAFK

function OnLoad()
	LastTick = GetTickCount()
	LastAction = GetTickCount()
	if not IsChanneling() then
	  myHero:MoveTo(myHero.x + 200, myHero.z)
		myHero:HoldPosition()
	end
	config = scriptConfig("Neo's Anti-AFK v"..version, "NeosAntiAFK")
	config:addParam("onoff", "Enabled", SCRIPT_PARAM_ONOFF, true)
	PrintChat("<font color='#20FF52'>Neo's Anti-AFK v"..version.."</font>")
end

function IsChanneling()
	return (
		(myHero.charName == "Katarina" and lastAnimation == "Spell4")
		or (myHero.charName == "Nunu" and (lastAnimation == "Spell4" or lastAnimation == "Spell4_Loop"))
    )
		or (lastAnimation == "recall")
end

function CheckLastAction()
  if GetTickCount() - LastAction > RefreshRate then
	  myHero:MoveTo(myHero.x +200, myHero.z)
		myHero:HoldPosition()
		LastAction = GetTickCount()
	end
end

function OnProcessSpell(object, spell)
  if object and spell and object == myHero then
	  LastAction = GetTickCount()
	end
end

function OnIssueOrder(arg1, arg2, arg3, arg4, arg5)
  if arg1 == myHero then
	  LastAction = GetTickCount()
	end
 
end

function OnTick()
  if not config.onoff then return end
	if LastAction == nil then LastAction = GetTickCount() end
  if ( GetTickCount() - LastTick ) < TickLimit then return end
	LastTick = GetTickCount()
  for i = myHero.pathIndex, myHero.pathCount do
	  local wpath = myHero:GetPath(i)
		if ( wpath ~= nil and wpath.x ) then
		  LastAction = GetTickCount()
		end
	end
	if IsChanneling() then
	  LastAction = GetTickCount()
	end
	CheckLastAction()
end
local LastAction = GetTickCount()

function OnAnimation(unit,animationName)
	if unit.isMe and lastAnimation ~= animationName then
	  lastAnimation = animationName 
	end
end
function OnProcessSpell(unit, spell)
  if unit and spell and unit == myHero then
	  LastAction = GetTickCount()
	end
end


class("ScriptUpdate")
function ScriptUpdate:__init(host, path, callback)
  self.Host = host
  self.Path = path
  self.Callback = callback
  self.LuaSocket = require("socket")
  self.Socket = self.LuaSocket.connect(host, 80)
  self.Socket:send("GET " .. self.Path .. "&rand=" .. math.random(99999999) .. " HTTP/1.0\r\nHost: " .. host .. "\r\n\r\n")
  self.Socket:settimeout(0, "b")
  self.Socket:settimeout(99999999, "t")
  self.LastPrint = ""
  self.File = ""
  AddTickCallback(function()
    self:CB()
  end)
end
function ScriptUpdate:CB()
  if self.Status == "closed" then
    return
  end
  self.Receive, self.Status, self.Snipped = self.Socket:receive('*a')
  if self.Receive and self.LastPrint ~= self.Receive then
    self.LastPrint = self.Receive
    self.File = self.File .. self.Receive
  end
  if self.Snipped ~= "" and self.Snipped then
    self.File = self.File .. self.Snipped
  end
  if self.Status == "closed" then
    local baca, caca = self.File:find("\r\n\r\n")
    if baca and caca then
      self.Callback(self.File:sub(caca + 1))
    else
      print("Error connecting to auth server.")
    end
  end
end


function AutoUpdate(host, script, serverversion, localversion)
  ScriptUpdate("teh-team.com", "/bolupdater/scriptupdater.php?script="..host..serverversion.."&rand="..tostring(math.random(1000)),
        function(getupdate)
            if tonumber(getupdate) > localversion then            
                print("Starting AutoUpdate")
                ScriptUpdate("teh-team.com", "/bolupdater/scriptupdater.php?script="..host..script.."&rand="..tostring(math.random(1000)),
                function(getupdate)
                    if getupdate then
                        file = io.open(SCRIPT_PATH.."/".._ENV.FILE_NAME, "wb")
                        file:write(getupdate)
                        file:close()
                        print("script updated, please reload")
                    else
                      print("error getting update, please update manually")
                    end
                end)    
            end
        end)    
end

AutoUpdate("raw.githubusercontent.com", "/frneo/BoL/master/Scripts/testautoupdate.lua", "/frneo/BoL/master/version/testautoupdate.version", version)
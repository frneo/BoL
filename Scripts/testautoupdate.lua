local version = 0.912

class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, Callback)
    self.Callback = Callback
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = VersionPath
    self.ScriptPath = ScriptPath
    self.SavePath = SavePath
    self.LuaSocket = require("socket")
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:GetOnlineVersion()
    if not self.OnlineVersion and not self.VersionSocket then
        self.VersionSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.VersionSocket:send("GET /boldupdater/scriptupdater.php?script="..self.Host..self.VersionPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
    end

    if not self.OnlineVersion and self.VersionSocket then
        self.VersionSocket:settimeout(0, 'b')
        self.VersionSocket:settimeout(99999999, 't')
        self.VersionReceive, self.VersionStatus = self.VersionSocket:receive('*a')
    end

    if not self.OnlineVersion and self.VersionSocket and self.VersionStatus ~= 'timeout' then
        if self.VersionReceive then
            --self.OnlineVersion = tonumber(string.sub(self.VersionReceive, string.find(self.VersionReceive, "<bols".."cript>")+11, string.find(self.VersionReceive, "</bols".."cript>")-1))
					self.OnlineVersion = tonumber(self.VersionReceive)
        else
            print('AutoUpdate Failed')
            self.OnlineVersion = 0
        end
        self:DownloadUpdate()
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.OnlineVersion > self.LocalVersion then --"teh-team.com", "/auth/evade/auth.php?user="..user.."&pw="..user.."&version="..tostring(version)
        self.ScriptSocket = self.LuaSocket.connect("teh-team.com", 80)
        self.ScriptSocket:send("GET /bolupdater/scriptupdater.php?script="..self.Host..self.ScriptPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
        self.ScriptReceive, self.ScriptStatus = self.ScriptSocket:receive('*a')
        --self.ScriptRAW = string.sub(self.ScriptReceive, string.find(self.ScriptReceive, "<bols".."cript>")+11, string.find(self.ScriptReceive, "</bols".."cript>")-1)
				self.ScriptRAW = self.ScriptReceive
        local ScriptFileOpen = io.open(self.SavePath, "w+")
        ScriptFileOpen:write(self.ScriptRAW)
        ScriptFileOpen:close()
    end

    if type(self.Callback) == 'function' then
        self.Callback(self.OnlineVersion)
    end
end

local ForceReload = false
ScriptUpdate(version,
	"raw.githubusercontent.com",
	"frneo/BoL/master/version/testautoupdate.version",
	"/frneo/BoL/master/Scripts/testautoupdate.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > version then print("<font color=\"#F0Ff8d\"><b>AutoUpdateTest : </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#F0Ff8d\"><b>AutoUpdateTest: </b></font> <font color=\"#FF0F0F\">You have the Latest Version</b></font>") end 
end)
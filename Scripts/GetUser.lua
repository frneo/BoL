function OnLoad()
	print("Your BoL Login is: ["..GetUser().."]")
	local file = io.open(SCRIPT_PATH.."login.txt", "wb")
	if file then
		file:write(GetUser())
		file:close()  
	end
end


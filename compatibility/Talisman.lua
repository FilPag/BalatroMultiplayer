to_big = to_big or function(x, y)
	if type(x) == "string" then
		return tonumber(x)
	end
	return x
end

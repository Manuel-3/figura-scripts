local table = setmetatable({}, {__index = table});

---@generic R
---@generic T : {[integer]: `R`}
---@param haystack `T` The table to search.
---@param needleOrPredicate (fun(v: R, k: integer, a: T): unknown) | R
function table.findIndex(haystack, needleOrPredicate)
	local predicateIsFunction = type(needleOrPredicate) == "function"
	if (not predicateIsFunction) then
		local _predicate = needleOrPredicate
		needleOrPredicate = function(v)
			return v == _predicate
		end
	end
	
	for i = 1, #haystack do
		local v = haystack[i]
		if (needleOrPredicate(v)) then
			return i;
		end
	end

	return nil;
end

return table;

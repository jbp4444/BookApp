--
--   Copyright 2013 John Pormann
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

-- TODO: list of other macros for Twine
-- -- http://aliendovecote.com/resources/twine-snippets/
-- -- http://www.glorioustrainwrecks.com/files/Twine1.3.5.Macros.html#9.3

-- images: https://groups.google.com/forum/#!msg/tweecode/_NW7Ky-RlUU/FoDvSnFPvWcJ
-- -- http://eturnerx.blogspot.com/2013/01/how-to-insert-images-into-twine-without.html
-- -- -- suggests using a generic html tag
-- timed goto: http://www.glorioustrainwrecks.com/node/5108
-- "once" and "becomes": http://www.glorioustrainwrecks.com/blog/584
-- -- <<once>>You arrive at the garage.<<becomes>>Back at the garage.<<becomes>>Third visit to the garage.<<endonce>>
-- either() function: http://aliendovecote.com/resources/twine-snippets/


local function add(aa, bb)
	return( aa + bb )
end
local function sub(aa, bb)
	return( aa - bb )
end
local function mpy(aa, bb)
	return( aa * bb )
end
local function mod(aa, bb)
	return( aa % bb )
end
local function div(aa, bb)
	return( aa / bb )
end
local function neg(aa)
	return( -aa )
end

-- we handle true/false (logical ops) as 1/0 math ops
local function l_gt(aa, bb)
	return( (aa > bb) and 1 or 0 )
end
local function l_ge(aa, bb)
	return( (aa >= bb) and 1 or 0 )
end
local function l_lt(aa, bb)
	return( (aa < bb) and 1 or 0 )
end
local function l_le	(aa, bb)
	return( (aa <= bb) and 1 or 0 )
end
local function l_eq(aa, bb)
	return( (aa == bb) and 1 or 0 )
end
local function l_neq(aa, bb)
	return( (aa ~= bb) and 1 or 0 )
end
local function l_and(aa, bb)
	return( (aa and bb) and 1 or 0 )
end
local function l_or(aa, bb)
	return( (aa or bb) and 1 or 0 )
end
local function l_not(aa)
	return( (not aa) and 1 or 0 )
end
local function l_random(...)
	local rtn = -1
	if( arg.n == 0 ) then
		rtn = math.random()
	elseif( arg.n == 1 ) then
		rtn = math.random( arg[1]+0 )
	elseif( arg.n == 2 ) then
		rtn = math.random( arg[1]+0, arg[2]+0 )
	end
	return( rtn )
end
local function l_max(...)
	local mx = arg[1]
	for i=2,arg.n do
		if( (arg[i]+0) > mx ) then
			mx = arg[i]+0
		end
	end
	return( mx )
end
local function l_min(...)
	local mn = arg[1]
	for i=2,arg.n do
		if( (arg[i]+0) < mn ) then
			mn = arg[i]+0
		end
	end
	return( mn )
end
local function l_either(...)
	local i = math.random(arg.n)
	dprint( 25, "l_either n="..arg.n.."  i="..i.."  v="..arg[i] )
	local rtn = arg[i]
	-- TODO: this assumes first and last chars are single/double quotes
	-- but does not check, nor does it check that they match
	rtn = rtn:sub(2,-2)
	return( rtn )
end

local fcn_table = {
	random = l_random,
	min = math.min,
	max = math.max,
	either = l_either
}

-- evalMath assumes all tokens in text-string are numbers!
function evalMath( text )
	-- make a copy of the string, so we don't corrupt the original
	local output = string.rep( text, 1 )
	output = output:gsub( "%s+", "" )
	dprint( 15, "math-eval ["..output.."]" )

	local i, j, a,b,c
		
	-- first, look for functions F(x)
	-- this also removes some parens which would otherwise be parsed below
	local rctr = 0
	i, j, a,b = string.find( output, "(%a+)%((.-)%)" )
	while( i ~= nil ) do
		dprint( 15, "found fcn at "..i..","..j.."["..a.."|"..b.."]" )
		local nargs = 0
		if( b:len() > 0 ) then
			nargs = 1
		end
		for q=1,b:len() do
			local qq = b:sub(q,q)
			if( qq == "," ) then
				nargs = nargs + 1
			end
		end
		local val = 0
		if( fcn_table[a] ~= nil ) then
			local f = fcn_table[a]
			if( nargs == 0 ) then
				val = f()
			elseif( nargs == 1 ) then
				val = f( b )
			elseif( nargs == 2 ) then
				local k = string.find( b, "," )
				local bb = b:sub(1,k-1)
				local cc = b:sub(k+1)
				val = f( bb, cc )
			elseif( nargs == 3 ) then
				local k = string.find( b, "," )
				local bb = b:sub(1,k-1)
				local cc = b:sub(k+1)
				local kk= string.find( cc, "," )
				local ccc = cc:sub(1,kk-1)
				local ddd = cc:sub(kk+1)
				dprint( 20, " args ["..bb..","..ccc..","..ddd.."]" )
				val = f( bb, ccc, ddd  )
			else
				-- TODO: bad function/nargs pair?
				val = 0
			end
		else
			-- TODO: bad function name .. what to do?
			val = 0
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)
		
		i, j, a,b = string.find( output, "(%a+)%((.-)%)" )
		
		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	dprint( 15, "output ["..output.."]" )

	-- TODO: then, look for unary negation (e.g. -5)

	-- next, do parens
	rctr = 0
	i, j, a = string.find( output, "%((.-)%)" )
	while( i ~= nil ) do
		dprint( 15, "found () at "..i..","..j.."["..a.."]" )
		local val = evalMath( a )
		output = output:sub(1,i-1) .. val .. output:sub(j+1)

		i, j, a = string.find( output, "%((.-)%)" )
		
		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	-- TODO: then, logical not
	
	-- next, do mpy, div, mod
	rctr = 0
	i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%*%/%%])(%-*[0-9%.]+)" )
	while( i ~= nil ) do
		dprint( 15, "found */ at "..i..","..j.."["..a..","..b..","..c.."]" )
		local val = 0
		if( b == "*" ) then
			val = mpy( (a+0),(c+0) )
		elseif( b == "/" ) then
			val = div( (a+0),(c+0) )	
		elseif( b == "%" ) then
			val = mod( (a+0),(c+0) )	
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)

		i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%*%/%%])(%-*[0-9%.]+)" )
		
		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	-- then, do add and sub
	rctr = 0
	local i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%+%-])(%-*[0-9%.]+)" )
	while( i ~= nil ) do
		dprint( 15, "found +- at "..i..","..j.."["..a..","..b..","..c.."]" )
		local val = 0
		if( b == "+" ) then
			val = add( (a+0),(c+0) )
		elseif( b == "-" ) then
			val = sub( (a+0),(c+0) )	
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)
		dprint( 15, " new output ["..output.."]" )
		flag = string.find( output, "[%+%-]" )
		
		i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%+%-])(%-*[0-9%.]+)" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	-- TODO: next, do logical comparisons
	-- note: we've already handled logical negation, so "~" should only be "~="
	rctr = 0
	-- TODO: need to rework this regex to catch gt/lte/etc. char sequences
	i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%~%>%<%=]+)(%-*[0-9%.]+)" )
	while( i ~= nil ) do
		dprint( 15, "found log-op at "..i..","..j.."["..a..","..b..","..c.."]" )
		local val = 0
		if( (b == ">") or (b == "gt") ) then
			val = l_gt( (a+0),(c+0) )
		elseif( (b == ">=") or (b == "gte") ) then
			val = l_ge( (a+0),(c+0) )	
		elseif( (b == "<") or (b == "lt") ) then
			val = l_lt( (a+0),(c+0) )
		elseif( (b == "<=") or (b == "lte") ) then
			val = l_le( (a+0),(c+0) )	
		elseif( (b == "==") or (b == 'eq') or (b == 'is') ) then
			val = l_eq( (a+0),(c+0) )
		elseif( (b == "~=") or (b == 'neq') ) then
			val = l_neq( (a+0),(c+0) )
		else
			-- TODO: there could be malformed ops that we should catch here
			--       e.g. ">>" matches the find pattern but is not valid
			val = 0
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)
		
		i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)([%~%>%<%=]+)(%-*[0-9%.]+)" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	-- then, logical and
	rctr = 0
	i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)(%&%&|and)(%-*[0-9%.]+)" )
	while( i ~= nil ) do
		dprint( 15, "found +- at "..i..","..j.."["..a..","..b..","..c.."]" )
		local val = 0
		if( (b == "&&") or (b == 'and') ) then
			val = l_and( (a+0),(c+0) )
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)

		i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)(%&%&)(%-*[0-9%.]+)" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end

	-- last, logical or
	rctr = 0
	i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)(%|%||or)(%-*[0-9%.]+)" )
	while( i ~= nil ) do
		dprint( 15, "found +- at "..i..","..j.."["..a..","..b..","..c.."]" )
		local val = 0
		if( (b == "||") or (b == 'or') ) then
			val = l_or( (a+0),(c+0) )
		end
		output = output:sub(1,i-1) .. val .. output:sub(j+1)
		
		i, j, a,b,c = string.find( output, "(%-*[0-9%.]+)(%|%|)(%-*[0-9%.]+)" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	return( output )
end

-- evalString will swap param-key-strings for param-values in text
-- that gives an all-numeric string which it sends to evalMath
function evalString( text, params )
	local expr = text:rep(1)
	dprint( 15, "string-eval ["..expr.."]" )
	
	local i, j, a
	local rctr = 0
		
	if( params ~= nil ) then
		dprint( 15, "found params table..." )
		for kk,vv in pairs(params) do
			dprint( 20, "storyVars["..kk.."]=["..vv.."]" )
		end		
		i, j, a = string.find( expr, "(%$%a+)", 1 )
		while( i ~= nil ) do
			dprint( 15, "found var at "..i..","..j.."["..a.."]" )
			local val = 0
			if( params[a] ~= nil ) then
				val = params[a]
			else
				-- TODO: maybe use NaN to force an error?
				val = "0"
			end
			expr = expr:sub(1,i-1) .. val .. expr:sub(j+1)
			
			i, j, a = string.find( expr, "(%$%a+)", j+1 )
			
			rctr = rctr + 1
			if( rctr > 100 ) then
				break
			end
		end
	end
	dprint( 15, "string-eval-3 ["..expr.."]" )
	
	-- always look for true and false .. substitute with 1 and 0
	rctr = 0
	i, j = string.find( expr, "true" )
	while( i ~= nil ) do
		expr = expr:sub(1,i-1) .. "1" .. expr:sub(j+1)

		i, j = string.find( expr, "true" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	rctr = 0
	i, j = string.find( expr, "false" )
	while( i ~= nil ) do
		expr = expr:sub(1,i-1) .. "0" .. expr:sub(j+1)

		i, j = string.find( expr, "false" )

		rctr = rctr + 1
		if( rctr > 100 ) then
			break
		end
	end
	
	dprint( 15, "string-eval-4 ["..expr.."]" )
	local output = evalMath( expr )
	
	return( output )
end

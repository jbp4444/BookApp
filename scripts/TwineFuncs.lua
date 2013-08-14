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

-- uses syntax from Twine gamebook creator:
--    http://www.gimcrackd.com/etc/src/

require( "scripts.EvalExpression" )

function unrollMacros( tlist, plist, vars )
	local rtn = {}
	local rc = 1
	
	-- handle the "<<display" tags .. include another passage inside this one
	for c,text in pairs(tlist) do
		dprint( 15, "parse-text ["..text.."]" )
		local m = text:match("%<%<display%s*%'(.*)%'.*%>%>")
		if( m == nil ) then
			rtn[rc] = text
			rc = rc + 1
		else
			dprint( 20, "inserting ["..m.."]" )
			local tlist2 = plist[m]
			for cc,tt in pairs(tlist2) do
				-- TODO: recurse to load display-within-display passages
				rtn[rc] = tt
				rc = rc + 1
			end
		end
	end
	
	-- TODO: handle the "<<choice" tags
	
	-- TODO: handle the "<<action" tags
	
	-- TODO: handle the "<<set" tags
	for c,text in pairs(rtn) do
		dprint( 15, "parse-text ["..text.."]" )
		local kk,vv = text:match("%<%<set%s+%$(.-)%s*%=%s*(.-)%>%>")
		if( kk == nil ) then
			-- not a match
		else
			dprint( 5, "setting ["..kk.."]=["..vv.."]" )
			local new_val = evalString( vv, vars )
			dprint( 5, "   val=["..new_val.."]" )
			vars[kk] = new_val
			rtn[c] = nil
		end
	end
	
	-- TODO: handle the "<<if" tags
	local print_flag = 1
	for c,text in pairs(rtn) do
		dprint( 5, "parse-text ["..text.."]" )
		local mif = text:match("%<%<if%s+(.-)%s*%>%>")
		local melse = text:match("%<%<else(.-)%s*%>%>")
		local mendif = text:match("%<%<endif%s*%>%>")
		if( mif ~= nil ) then
			-- we've encountered an if statement
			dprint( 5, "   if-stmt ["..mif.."]" )
			local new_val = evalString( mif, vars )
			dprint( 5, "     val=["..new_val.."]" )
			if( new_val > 0 ) then
				print_flag = 1
			else
				print_flag = 0
			end
			rtn[c] = nil
		elseif( melse ~= nil ) then
			-- we've encountered an else statement
			if( print_flag == 0 ) then
				print_flag = 1
			else
				print_flag = 0
			end
			rtn[c] = nil
		elseif( mendif ~= nil ) then
			-- we've encountered an endif statement
			-- TODO: this assumes no nesting (we could count nest-level)
			print_flag = 1
			rtn[c] = nil
		elseif( print_flag == 0 ) then
			rtn[c] = nil
		end
	end

	return( rtn )
end

function loadTwineFile( filename )
	local path = system.pathForFile( filename, system.resourceDirectory )
	local plist = {}
	local text = {}

	print("loadTwineFile "..filename.." ["..path.."]" )

	local pn = 1
	local c = 1	
	for line in io.lines( path ) do
		local ll = line:gsub( "[\n\r\v]", "")
	    dprint( 20, "["..c.."|"..ll.."]" )
		if( string.sub(ll,1,3) == ':: ' ) then
			local pname = string.sub(ll,4)
			text = {}
			plist[pname] = text
			c = 1
		else
			text[c] = ll
		    c = c + 1
		end
	end
	
	return( plist )
end

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
	
	local psg_title = tlist["title"]
	
	-- handle the "<<display" tags .. include another passage inside this one
	-- also removes the 'title' entry from table
	for c,text in pairs(tlist) do
		dprint( 15, "parse-text-1 ["..c.."|"..text.."]" )
		if( c == "title" ) then
			-- skip it
		else
			local m = text:match("%<%<display%s*%'(.*)%'.*%>%>")
			if( m == nil ) then
				rtn[rc] = text
				rc = rc + 1
			else
				dprint( 20, "inserting ["..m.."]" )
				local tlist2 = plist[m]
				for cc,tt in pairs(tlist2) do
					-- TODO: recurse to load display-within-display passages
					if( cc == "title" ) then
						-- skip it
					else
						rtn[rc] = tt
						rc = rc + 1
					end
				end
			end
		end
	end

	
	-- TODO: handle the "<<choice" tags
	-- TODO: for now, expanding them into bullet list
	local rtn2 = {}
	local rc2 = 1
	for c,text in pairs(rtn) do
		dprint( 15, "parse-text-2 ["..c.."|"..text.."]" )
		local kk = text:match("%<%<choice%s+(.-)%>%>")
		if( kk == nil ) then
			-- not a match
			rtn2[rc2] = text
			rc2 = rc2 + 1
		else
			dprint( 5, "choice ["..kk.."]" )
			rtn2[rc2] = "* [[" .. a .. "]]"
			rc2 = rc2 + 1
		end
	end
	
	-- handle the "<<action" tags
	-- TODO: for now, expanding them into bullet list
	local rtn = {}
	local rc = 1
	for c,text in pairs(rtn2) do
		dprint( 15, "parse-text-3 ["..c.."|"..text.."]" )
		local kk = text:match("%<%<actions%s+(.-)%>%>")
		if( kk == nil ) then
			-- not a match
			rtn[rc] = text
			rc = rc + 1
		else
			-- TODO: we may want to count the number of "actions" macros in a passage
			-- i.e. right now we can only handle one per passage
			dprint( 5, "actions ["..kk.."]" )
			local ctr = 1
			local i,j,a = string.find( kk, "%'(.-)%'" )
			while( i ~= nil ) do
				if( storyVars[psg_title.." actions "..ctr] ~= nil ) then
					-- already visited, so just print the text (no link)
					rtn[rc] = "* " .. a
					rc = rc + 1
				else
					rtn[rc] = "* [[" .. a .. "]]"
					rc = rc + 1
				end
				kk = kk:sub(j+1)
				i,j,a = string.find( kk, "%'(.-)%'" )
			end
		end
	end
	
	-- handle the "<<set" tags
	-- TODO: need to check for if/then first, then process the 'set' command
	rtn2 = {}
	rc2 = 1
	for c,text in pairs(rtn) do
		dprint( 15, "parse-text-4 ["..c.."|"..text.."]" )
		local kk,vv = text:match("%<%<set%s+%$(.-)%s*%=%s*(.-)%>%>")
		if( kk == nil ) then
			-- not a match
			rtn2[rc2] = text
			rc2 = rc2 + 1
		else
			dprint( 5, "setting ["..kk.."]=["..vv.."]" )
			local new_val = evalString( vv, vars )
			dprint( 5, "   val=["..new_val.."]" )
			vars[kk] = new_val
		end
	end
	
	-- handle the "<<if" tags
	-- TODO: this assumes no nesting (we could count nest-level)
	rtn = {}
	rc = 1
	local print_flag = 1
	for c,text in pairs(rtn2) do
		dprint( 15, "parse-text-5 ["..c.."|"..text.."]" )
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
		elseif( melse ~= nil ) then
			-- we've encountered an else statement
			if( print_flag == 0 ) then
				print_flag = 1
			else
				print_flag = 0
			end
		elseif( mendif ~= nil ) then
			-- we've encountered an endif statement
			print_flag = 1
		elseif( print_flag == 0 ) then
			-- skip/no printing of this line
		else
			rtn[rc] = text
			rc = rc + 1
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
			text["title"] = pname
			plist[pname] = text
			c = 1
		else
			text[c] = ll
		    c = c + 1
		end
	end
	
	return( plist )
end

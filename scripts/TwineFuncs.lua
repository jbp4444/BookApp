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

function FindIfStatement( ast )
	if( ast == nil ) then
		return( nil )
	end
	if( ast.type == "if" ) then
		return( ast )
	end
	if( ast.prev ~= nil ) then
		return( FindIfStatement(ast.prev) )
	end
	return( nil )
end

function FindTitle( ast )
	if( ast == nil ) then
		return( "error1" )
	end
	if( ast.type == "title" ) then
		return( ast.data )
	end
	if( ast.prev ~= nil ) then
		return( FindTitle(ast.prev) )
	end
	return( "error2" )
end

function PrependData( title, settext )
	dprint( 20, "prepending data to ["..title.."]" )
	dprint( 20, "   set storyVars["..settext.."]" )
	local ast = passageList[title]
	local astnxt = ast.next
	-- title ast-node should be at the top of the list 
	dprint( 20, "  type="..ast.type )
	dprint( 20, "  astnxt type="..astnxt.type )

	if( astnxt.type == "set" ) then
		local data = astnxt.data
		if( data == settext ) then
			-- nothing to do
			dprint( 20, "nothing to do" )
			return
		end
	end
	
	-- else
	local new_ast = {
		type = "set",
		data = settext,
		prev = ast,
		next = astnxt
	}
	ast.next = new_ast
	astnxt.prev = new_ast

end

function walk_ast( ast )
	if( ast == nil ) then
		return ""
	end
	local tp = ast.type
	local text = ""
	if( tp == "title" ) then
		dprint( 20, "  title [".. ast.data .."]" )
		
	elseif( tp == "text" ) then
		dprint( 20, "  text [".. ast.data .."]" )
		text = ast.data

	elseif( tp == "bullet" ) then
		dprint( 20, "  bullet-X [".. ast.data .."]" )
		text = "\n" .. ast.data

	elseif( tp == "graphics" ) then
		dprint( 20, "  graphics-X [".. ast.data .."]" )
		-- TODO: look for path names for images, etc. ??
		text = ast.data .. "\n"

	elseif( tp == "newline" ) then
		dprint( 20, "  newline []" )
		text = "\n\n"
				
	elseif( tp == "display" ) then
		dprint( 20, "  display [".. ast.data .. "]" )
		text = walk_ast( passageList[ast.data] ) .. "\n"
		
	elseif( tp == "choice" ) then
		dprint( 20, "  choice [".. ast.data .. "]" )
		-- TODO: handle choice (allow only 1 selection)
		local m = ast.data
		-- NOTE: ast.data may contain just 'title' or {'text' 'title'}
		local ctr = 1
		local i,j,link = string.find( m, "%'(.-)%'" )
		local i2,j2,a2 = string.find( m, "%'(.-)%'", j+1 )
		local txt
		if( i2 == nil ) then
			-- only a title was given
			txt = link
		else
			-- title and text were given
			txt = a2
		end
		local title = FindTitle( ast )
		-- modify the ast for the target passage so that it sets a storyVar for us
		PrependData( link, title.." choice="..ctr )
		if( storyVars[title.." choice"] ~= nil ) then
			if( storyVars[title.." choice"] == ctr ) then
				dprint( 0, "choice-taken [* " .. txt .. "]" )
				text = text .. "\n* "..txt
			else
				dprint( 0, "choice-not-avail [* " .. txt .. "]" )
				text = text .. "\n* "..txt
			end
		else
			dprint( 20, "choice-avail [* " .. txt .. "]" )
			text = text .. "\n* [["..txt.."|"..link.."]]"
		end
		
	elseif( tp == "actions" ) then
		dprint( 20, "  actions [".. ast.data .. "]" )
		-- TODO: handle actions
		local m = ast.data
		local ctr = 1
		local i,j,a = string.find( m, "%'(.-)%'" )
		while( i ~= nil ) do
			local title = FindTitle( ast )
			-- modify the ast for the target passage so that it sets a storyVar for us
			PrependData( a, title.." actions "..ctr.."=1" )
			if( storyVars[title.." actions "..ctr] ~= nil ) then
				dprint( 20, "action-taken [* " .. a .. "]" )
				text = text .. "\n* "..a
			else
				dprint( 20, "action-avail [* " .. a .. "]" )
				text = text .. "\n* [["..a.."]]"
			end
			m = m:sub(j+1)
			i,j,a = string.find( m, "%'(.-)%'" )
			ctr = ctr + 1
		end
		
	elseif( tp == "set" ) then
		dprint( 20, "  set [".. ast.data .. "]" )
		local text = ast.data
		local kk,vv = text:match("(.-)%=(.*)")
		if( kk ~= nil ) then
			--kk = string.gsub( kk, "%$", "" )
			dprint( 20, "setting ["..kk.."]=["..vv.."]" )
			local new_val = evalString( vv, storyVars )
			dprint( 20,"   val=["..new_val.."]" )
			storyVars[kk] = new_val
		end
		
	elseif( tp == "print" ) then
		dprint( 20, "  print [".. ast.data .. "]" )
		-- TODO: clean-up
		local x = ast.data
		if( x ~= nil ) then
			local new_val = evalString( x, storyVars )
			dprint( 20, "   val=["..new_val.."]" )
			text = new_val
		end
		
	elseif( tp == "if" ) then
		dprint( 20, "  if [".. ast.data .. "]" )
		local log_fcn = ast.data
		dprint( 20, "    fcn = ["..log_fcn.."]" )
		local log_val = evalString( log_fcn, storyVars )
		-- need to convert to a number
		dprint( 20, "    value = "..log_val )
		log_val = log_val + 0
		dprint( 20, "    value+0 = "..log_val )
		if( log_val > 0 ) then
			dprint( 20, "    following tttt:" )
			text = walk_ast( ast.tttt )
		else
			dprint( 20, "    following ffff:" )
			text = walk_ast( ast.ffff )
		end

	elseif( tp == "macro" ) then
		dprint( 20, "  macro-error [".. ast.data .."]" )
		-- TODO: handle errors in macros

	else
		-- TODO: handle other errors
			
	end

	if( ast.next ~= nil ) then
		-- text = text .. "\n" .. walk_ast( ast.next )
		text = text .. walk_ast( ast.next )
	end
	
	return( text )
end

function loadTwineFile( filename )
	--local path = filename
	local path = system.pathForFile( filename, system.ResourceDirectory )
	local plist = {}
	local ast = {}
	local count = 0

	dprint( 9, "loadTwineFile "..filename.." ["..path.."]" )

	for line in io.lines( path ) do
		-- get rid of CR+LF combos
		local line1 = line:gsub( "[\n\r\v]", "" )
		local allLines = {}
		-- TODO: this assumes all Twine commands are on one line
		local qi,qii = line1:find('<<')
		local qj,qjj = line1:find('>>')
		if( (qi == nil) and (qj == nil) ) then
			-- no twine commands at all
			table.insert( allLines, line1 )
		else
			-- TODO: assumes both qi and qj are not nil
			-- (technically this isn't guaranteed by the above test)
			if( qi > 1 ) then
				dprint( 20, "insert1 ["..line1:sub(1,qi-1).."]" )
				table.insert( allLines, line1:sub(1,qi-1) )
			end
			dprint( 20, "insert2 ["..line1:sub(qi,qjj).."]" )
			table.insert( allLines, line1:sub(qi,qjj) )
			if( qjj < line1:len() ) then
				dprint( 20, "insert3 ["..line1:sub(qjj+1).."]" )
				table.insert( allLines, line1:sub(qjj+1) )
			end
		end
		
		for q = 1, #allLines do
			ll = allLines[q]
			if( ll:len() == 0 ) then
				dprint( 20, "newline []" )
				local new_ast = {}
				new_ast.type = "newline"
				new_ast.data = nil
				new_ast.next = nil
				-- fix-up next/prev pointers
				new_ast.prev = ast
				ast.next = new_ast
				-- move ptr to new ast-node
				ast = new_ast
				
			elseif( string.sub(ll,1,3) == ':: ' ) then
				count = count + 1
				if( count > 200 ) then
					return( plist )
				end
				local pname = string.sub(ll,4)
				dprint( 20, "new title ["..pname.."]" )
				local new_ast = {}
				new_ast.type = "title"
				new_ast.data = pname
				new_ast.prev = nil
				new_ast.next = nil
				plist[pname] = new_ast
				-- move ptr to new ast-node
				ast = new_ast
			elseif( string.sub(ll,1,2) == '<<' ) then
				local tp = ll:match("%<%<(%w+)")	
				local new_ast = {}
				-- store some defaults (for error detection?)
				new_ast.type = "macro"
				new_ast.data = "macro"
				new_ast.prev = nil
				new_ast.next = nil
	
				local flag = 0			
				if( tp == "display" ) then
					new_ast.type = "display"
					local kk = ll:match("%<%<display%s*%'(.*)%'.*%>%>")
					new_ast.data = kk
				elseif( tp == "choice" ) then
					new_ast.type = "choice"
					local kk = ll:match("%<%<choice%s+(.-)%>%>")
					-- NOTE: kk may include just the place to jump to
					-- or both a 'text' 'link' items
					new_ast.data = kk
				elseif( tp == "actions" ) then
					new_ast.type = "actions"
					local kk = ll:match("%<%<actions%s+(.-)%>%>")
					-- NOTE: kk may include just the place to jump to
					-- or both a 'text' 'link' items
					new_ast.data = kk
				elseif( tp == "set" ) then
					new_ast.type = "set"
					local kk = ll:match("%<%<set%s+(.-)%>%>")
					kk = kk:gsub( " ","" )
					new_ast.data = kk
				elseif( tp == "print" ) then
					new_ast.type = "print"
					local kk = ll:match("%<%<print%s+(.-)%>%>")
					kk = kk:gsub( " ","" )
					new_ast.data = kk
				elseif( tp == "if" ) then
					new_ast.type = "if"
					local kk = ll:match("%<%<if%s+(.-)%s*%>%>")
					new_ast.data = kk
					new_ast.tttt = nil
					new_ast.ffff = nil
					-- at first, the 'if-true' part will be attached to 'next' pointer
				elseif( tp == "elseif" ) then
					-- TODO: handle 'elseif'
				elseif( tp == "else" ) then
					-- TODO: handle 'else'
					flag = 1
				elseif( tp == "endif" ) then
					flag = 1
				end
	
				if( flag == 1 ) then
					-- for else and endif statements, we clear new_ast
					new_ast.type = nil
					new_ast.data = nil
					new_ast.next = nil
					new_ast.prev = nil
					new_ast = nil
					
					-- and find original if statement
					local ast_if = FindIfStatement( ast )
					dprint( 20, ast_if )
					
					-- now re-attach the 'next' pointer to 'tttt' or 'ffff'
					if( ast_if.tttt == nil ) then
						ast_if.tttt = ast_if.next
						ast_if.tttt.prev = ast_if
					else
						ast_if.ffff = ast_if.next
						ast_if.ffff.prev = ast_if
					end
					ast_if.next = nil
					ast = ast_if
									
				else
					-- fix-up next/prev pointers
					new_ast.prev = ast
					ast.next = new_ast
					-- move ptr to new ast-node
					ast = new_ast
				end
				
			elseif( string.sub(ll,1,2) == '((' ) then
				-- TODO: count asterisks for increased indentation levels
				dprint( 20, "graphics ["..ll.."]" )
				-- a la wiki markup
				local new_ast = {}
				-- store some defaults (for error detection?)
				new_ast.type = "graphics"
				new_ast.data = ll
				new_ast.next = nil
				-- fix-up next/prev pointers
				new_ast.prev = ast
				ast.next = new_ast
				-- move ptr to new ast-node
				ast = new_ast

			elseif( string.sub(ll,1,1) == '*' ) then
				-- TODO: count asterisks for increased indentation levels
				dprint( 20, "bullet ["..ll.."]" )
				-- a la wiki markup
				local new_ast = {}
				-- store some defaults (for error detection?)
				new_ast.type = "bullet"
				new_ast.data = ll
				new_ast.next = nil
				-- fix-up next/prev pointers
				new_ast.prev = ast
				ast.next = new_ast
				-- move ptr to new ast-node
				ast = new_ast

			else
				dprint( 20, "text ["..ll.."]" )
				local new_ast = {}
				new_ast.type = "text"
				new_ast.data = ll
				new_ast.next = nil
				-- fix-up next/prev pointers
				new_ast.prev = ast
				ast.next = new_ast
				-- move ptr to new ast-node
				ast = new_ast
			end
			
		end -- next line-fragment
		
	end -- next line of text from file
	
	return( plist )
end

function ProcessPassage( title )

	local ast = passageList[title]
	dprint( 0, "parsing twine passage ["..title.."]" )
	local text = walk_ast( ast )

	dprint( 15, "pp-text = ["..text.."]" )
	
	return text
end


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

function ProcessHtml( text )
	local output = text
	
	local i,j = output:find("img src=")
	if( i ~= nil ) then
		output = output:sub(1,j+1)
			.. settings.relativePath
			.. output:sub(j+2)
	end
	
	local i = output:find("%[%[")
	if( i ~= nil ) then
		local j = output:find("%]%]")
		local x = output:sub(i+2,j-1)
		output = output:sub(1,i-1)
			.. "<a href='corona:"..x.."'>" .. x .. "</a>"
			.. output:sub(j+2)
	end
	
	return( output )
end

function PrependData( title, settext )
	dprint( 20, "prepending data to ["..title.."]" )
	dprint( 20, "   set storyVars["..settext.."]" )
	local ast = passageList[title]
	local astnxt = ast.next
	-- title ast-node should be at the top of the list 
	dprint( 20, "  type="..ast.type )

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
		-- look for path names for images, etc.
		text = ProcessHtml( ast.data )
				
	elseif( tp == "display" ) then
		dprint( 20, "  display [".. ast.data .. "]" )
		text = walk_ast( passageList[ast.data] )
		
	elseif( tp == "choice" ) then
		dprint( 20, "  choice [".. ast.data .. "]" )
		-- TODO: handle choice (allow only 1 selection)
		local m = ast.data
		local ctr = 1
		local i,j,a = string.find( m, "%'(.-)%'" )
		while( i ~= nil ) do
			local title = FindTitle( ast )
			-- modify the ast for the target passage so that it sets a storyVar for us
			PrependData( a, title.." choice="..ctr )
			if( storyVars[title.." choice"] ~= nil ) then
				if( storyVars[title.." choice"] == ctr ) then
					dprint( 20, "choice-taken [* " .. a .. "]" )
					text = text .. "<li> <a href='corona:"..a.."'>"..a.."</a></li>\n"
				else
					dprint( 20, "choice-not-avail [* " .. a .. "]" )
					text = text .. "<li> "..a.."</li>\n"
				end
			else
				dprint( 20, "choice-avail [* " .. a .. "]" )
				text = text .. "<li> <a href='corona:"..a.."'>"..a.."</a></li>\n"
			end
			m = m:sub(j+1)
			i,j,a = string.find( m, "%'(.-)%'" )
			ctr = ctr + 1
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
				-- TODO:  should be:
				text = text .. "<li> "..a.."</li>\n"
			else
				dprint( 20, "action-avail [* " .. a .. "]" )
				text = text .. "<li> <a href='corona:"..a.."'>"..a.."</a></li>\n"
			end
			m = m:sub(j+1)
			i,j,a = string.find( m, "%'(.-)%'" )
			ctr = ctr + 1
		end
		
	elseif( tp == "set" ) then
		dprint( 20, "  set [".. ast.data .. "]" )
		-- TODO: handle set
		local text = ast.data
		local kk,vv = text:match("(.-)%=(.*)")
		if( kk ~= nil ) then
			kk = string.gsub( kk, "%$", "" )
			dprint( 20, 5, "setting ["..kk.."]=["..vv.."]" )
			local new_val = evalString( vv, storyVars )
			dprint( 20, 5, "   val=["..new_val.."]" )
			storyVars[kk] = new_val
		end
		
	elseif( tp == "if" ) then
		dprint( 20, "  if [".. ast.data .. "]" )
		local log_fcn = ast.data
		dprint( 20, "    fcn = ["..log_fcn.."]" )
		local log_val = evalString( log_fcn, storyVars )
		dprint( 20, "    value = "..log_val )
		if( log_val ~= 0 ) then
			dprint( 20, "    following tttt:" )
			text = text .. walk_ast( ast.tttt )
		else
			dprint( 20, "    following ffff:" )
			text = text .. walk_ast( ast.ffff )
		end

	elseif( tp == "macro" ) then
		dprint( 20, "  macro-error [".. ast.data .."]" )
		-- TODO: handle errors in macros
			
	else
		-- TODO: handle other errors
			
	end

	if( ast.next ~= nil ) then
		text = text .. walk_ast( ast.next )
	end
	
	return( text )
end

function loadTwineFile( filename )
	--local path = filename
	local path = system.pathForFile( filename, system.resourceDirectory )
	local plist = {}
	local ast = {}
	local count = 0

	dprint( 20,"loadTwineFile "..filename.." ["..path.."]" )

	for line in io.lines( path ) do
		local ll = line:gsub( "[\n\r\v]", "" )	    
		if( string.sub(ll,1,3) == ':: ' ) then
			count = count + 1
			if( count > 200 ) then
				return( plist )
			end
			local pname = string.sub(ll,4)
			dprint( 20, "new title ["..pname.."]" )
			local new_ast = {}
			dprint( 20, "  new_ast-256:" )
			dprint( 20, new_ast )
			new_ast.type = "title"
			new_ast.data = pname
			new_ast.prev = nil
			new_ast.next = nil
			plist[pname] = new_ast
			-- move ptr to new ast-node
			ast = new_ast
			dprint( 20, "  ast-150:" )
			dprint( 20, ast )
		elseif( string.sub(ll,1,2) == '<<' ) then
			--local melse = ll:match("%<%<else(.-)%s*%>%>")

			local tp = ll:match("%<%<(%w+)")	
			dprint( 20, "macro ["..tp.."] .. ["..ll.."]" )
			local new_ast = {}
			dprint( 20, "  new_ast-273:" )
			dprint( 20, new_ast )
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
				new_ast.data = kk
			elseif( tp == "actions" ) then
				new_ast.type = "actions"
				local kk = ll:match("%<%<actions%s+(.-)%>%>")
				new_ast.data = kk
			elseif( tp == "set" ) then
				new_ast.type = "set"
				local kk = ll:match("%<%<set%s+(.-)%>%>")
				kk = kk:gsub( " ","" )
				new_ast.data = kk
			elseif( tp == "if" ) then
				new_ast.type = "if"
				local kk = ll:match("%<%<if%s+(.-)%s*%>%>")
				dprint( 20, "if ["..kk.."]" )
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
				dprint( 20, "ast_if-321:" )
				dprint( 20, ast_if )
				
				-- now re-attach the 'next' pointer to 'tttt' or 'ffff'
				if( ast_if.tttt == nil ) then
					ast_if.tttt = ast_if.next
					ast_if.tttt.prev = ast_if
					dprint( 20, "  tttt-331:" )
					dprint( 20, ast_if.tttt )
				else
					ast_if.ffff = ast_if.next
					ast_if.ffff.prev = ast_if
					dprint( 20, "  ffff-336:" )
					dprint( 20, ast_if.ffff )
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
			
		else
			dprint( 20, "text ["..ll.."]" )
			local new_ast = {}
			dprint( 20, "  new_ast-353:" )
			dprint( 20, new_ast )
			dprint( 20, "  old ast-355:" )
			dprint( 20, ast )
			new_ast.type = "text"
			new_ast.data = ll
			new_ast.next = nil
			-- fix-up next/prev pointers
			new_ast.prev = ast
			ast.next = new_ast
			-- move ptr to new ast-node
			ast = new_ast
			dprint( 20, "  ast-365:" )
			dprint( 20, ast )
			dprint( 20, "    back-link to:" )
			dprint( 20, ast.prev )
		end
	end
	
	return( plist )
end

function loadTemplateFile( filename )
	local path = system.pathForFile( filename, system.resourceDirectory )
	dprint( 20,"loadTemplateFile "..filename.." ["..path.."]" )

	-- TODO: this assumes all images are in same 'assets' directory
	-- as the template file
	local relpath = path
	local n = relpath:find(filename)
	relpath = relpath:sub(1,n-1)
	settings.relativePath = relpath
	dprint( 20, "relpath is ["..relpath.."]" )
	
	local fp = io.open( path, "r" )
	local text = fp:read( "*a" )
	io.close( fp )
	fp = nil
	
	return( text )
end

function ProcessTemplate( fname, title )

	local ast = passageList[title]
	dprint( 20, "parsing twine passage ["..title.."]" )
	dprint( 20, ast )
	local intext = walk_ast( ast )

	-- TODO: should we allow "PASSAGE_TITLE" entries in template?
	
	-- grab the header area (up thru "PASSAGE_TEXT")
	local i,j = templateFile:find("PASSAGE_TEXT")
	local text = templateFile:sub(1,i-1)
	
	-- insert text
	text = text .. intext

	-- append the rest of the template	
	text = text .. templateFile:sub(j+1)
	
	--dprint( 20, "text = ["..text.."]" )
	
	-- save it to a temp file
	local path = system.pathForFile( fname, system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( text )
	io.close( file )
	file = nil

end


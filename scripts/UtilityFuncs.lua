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

-- from: http://www.coronalabs.com/blog/2013/04/16/lua-string-magic/
function string:split( inSplitPattern, outResults )

   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

-- to parse strings like:  ((img src="foo" width="bar"))
function string:getopts( )
	local out = {}
	-- assign some defaults
	out.width = '100%'
	out.height = '100%'
	out.x = 0
	out.y = 0
	-- TODO: check for '((' and '))'
	-- get the "type" of the string (right after the '((')
	local i = 2
	local j = self:find( "%s", i+1 )
	local k = "type"
	local v = self:sub(i+1,j-1)
	out[k] = v
	-- now look for other key=value pairs
	local e = 0
	i = self:find( "%a", j+1 )
	while( i ~= nil ) do
		j = self:find( "%s", i+1 )
		if( j == nil ) then
			-- TODO: this assumes '))' are the last two chars
			j = self:len() - 1
		end
		e = self:find( "=", i+1 )
		k = self:sub(i,e-1)
		v = self:sub(e+1,j-1)
		v = v:gsub( "'", "" )
		out[k] = v
		dprint( 12, "k ["..k.."]  v ["..v.."]" )

		i = self:find( "%a", j+1 )
	end
	
	return out
end

function convertWidthPct( s )
	local i = s:find("%%")
	if( i == nil ) then
		return (s+0)
	end
	local p = s:sub(1,i-1)
	return( display.contentWidth * (p+0)/100 )
end
function convertHeightPct( s )
	local i = s:find("%%")
	if( i == nil ) then
		return (s+0)
	end
	local p = s:sub(1,i-1)
	return( display.contentHeight * (p+0)/100 )
end

function dprint( num, txt )
	-- how much printing do we want?
	if( num < debug_level ) then
		print( txt )
	end
end

function printtable(table, indent )
  indent = indent or 0;

	if( indent > 500 ) then
		return
	end
	
  print(string.rep('  ', indent)..'{');
  indent = indent + 1;
  for k, v in pairs(table) do

    local key = k;
    if (type(key) == 'string') then
      if not (string.match(key, '^[A-Za-z_][0-9A-Za-z_]*$')) then
        key = "['"..key.."']";
      end
    elseif (type(key) == 'number') then
      key = "["..key.."]";
    end

    if( key == '_class' ) then
        print( string.rep('  ', indent) .. "key="..tostring(key).." skipping" );
    elseif (type(v) == 'table') then
      if (next(v)) then
        print( string.rep('  ', indent) .. "key="..tostring(key));
        printtable(v, indent);
      else
        print( string.rep('  ', indent) .. "key="..tostring(key));
      end 
    elseif (type(v) == 'string') then
      print( string.rep('  ', indent) .. "key="..tostring(key) .. " val=['"..v.."']");
    else
      print( string.rep('  ', indent) .. "key="..tostring(key) .. " val=["..tostring(v).."]");
    end
  end
  indent = indent - 1;
  print(string.rep('  ', indent)..'}');
end

function jsonFile( filename, base )
	-- set default base dir if none specified
	if not base then base = system.ResourceDirectory; end
	
	-- create a file path for corona i/o
	local path = system.pathForFile( filename, base )
	print( "jsonFile ["..path.."]" )
	
	-- will hold contents of file
	local contents
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	if file then
	   -- read all contents of file into a string
	   contents = file:read( "*a" )
	   io.close( file )	-- close the file after using it
	else
		print( "** Error: cannot open file" )
	end
	
	dprint( 15, "contents<<<EOF")
	dprint( 15, contents )
	dprint( 15, ">>EOF")
	
	return contents
end


----------------------------------------------------------------------------------
-- from:  http://www.coronalabs.com/blog/2013/02/13/faq-wednesday-sub-folder-and-file-access/
-- e.g. copyFile( "readme.txt", nil, "readme.txt", system.DocumentsDirectory, true )
-- 

function doesFileExist( fname, path )

    local results = false

    local filePath = system.pathForFile( fname, path )

    -- filePath will be nil if file doesn't exist and the path is ResourceDirectory
    --
    if filePath then
        filePath = io.open( filePath, "r" )
    end

    if  filePath then
        print( "File found -> " .. fname )
        -- Clean up our file handles
        filePath:close()
        results = true
    else
        print( "File does not exist -> " .. fname )
    end

    print()

    return results
end

----------------------------------------------------------------------------------
-- copyFile( src_name, src_path, dst_name, dst_path, overwrite )
--
-- Copies the source name/path to destination name/path
--
-- Enter:   src_name = source file name
--      src_path = source path to file (directory), nil for ResourceDirectory
--      dst_name = destination file name
--      overwrite = true to overwrite file, false to not overwrite
--
-- Returns: false = error creating/copying file
--      nil = source file not found
--      1 = file already exists (not copied)
--      2 = file copied successfully
----------------------------------------------------------------------------------
--
function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

    local results = false

    local srcPath = doesFileExist( srcName, srcPath )

    if srcPath == false then
        -- Source file doesn't exist
        return nil
    end

    -- Check to see if destination file already exists
    if not overwrite then
        if fileLib.doesFileExist( dstName, dstPath ) then
            -- Don't overwrite the file
            return 1
        end
    end

    -- Copy the source file to the destination file
    --
    local rfilePath = system.pathForFile( srcName, srcPath )
    local wfilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rfilePath, "rb" )

    local wfh = io.open( wfilePath, "wb" )

    if  not wfh then
        print( "writeFileName open error!" )
        return false            -- error
    else
        -- Read the file from the Resource directory and write it to the destination directory
        local data = rfh:read( "*a" )
        if not data then
            print( "read error!" )
            return false    -- error
        else
            if not wfh:write( data ) then
                print( "write error!" )
                return false    -- error
            end
        end
    end

    results = 2     -- file copied

    -- Clean up our file handles
    rfh:close()
    wfh:close()

    return results
end

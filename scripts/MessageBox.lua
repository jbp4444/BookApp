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

local MessageBox = {}

function MessageBox.new( qlist, right_or_wrong )
	assert( qlist, "Required parameter-1 missing")
	
	local text
	if( right_or_wrong == nil ) then
		right_or_wrong = "right"
	end
		
	if( right_or_wrong == "wrong" ) then
		text = "Oh no! Wrong answer!"
		if( qlist["wronganswer"] ~= nil ) then
			text = qlist["wronganswer"]
		end
	else
		text = "Hooray! You got it!"
		if( qlist["rightanswer"] ~= nil ) then
			text = qlist["rightanswer"]
		end
	end
	
	dprint( 15, "text=["..text.."]" )
	
	local grp = display.newGroup()
	grp.myType = "message"
	
	local bkgd = display.newRoundedRect( (HALF_WIDTH/2),(HALF_HEIGHT/2), HALF_WIDTH,HALF_HEIGHT, 12 )
	bkgd.strokeWidth = 3
	bkgd:setFillColor(140, 140, 140)
	bkgd:setStrokeColor(180, 180, 180)
	grp:insert( bkgd )

	local txt = display.newText( text, (HALF_WIDTH/2),(HALF_HEIGHT/2), 
		HALF_WIDTH,HALF_HEIGHT, 
		native.systemFontBold,16 )
	txt:setTextColor( 255,255,255 )
	grp:insert( txt )
	
	return grp
end

return MessageBox
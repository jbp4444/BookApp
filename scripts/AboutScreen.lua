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

local storyboard = require( "storyboard" )
local widget = require( "widget" )
require( "scripts.EvalExpression" )

local scene = storyboard.newScene()


local function processButton( event )
	if( event.target == scene.backBtn ) then
		storyboard.gotoScene( "scripts.MainScreen" )
		return true
	end
	return false
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 10, "createScene-AboutScreen" )

	local group = self.view

	local backBtn = widget.newButton( {
			width  = display.contentWidth * 0.75,
			height = 100,
			left = display.contentWidth*0.125,
			top = display.contentHeight - 105,
			label  = "Back",
			onPress = processButton
	})
	backBtn:setReferencePoint( display.TopLeftReferencePoint )
	group:insert( backBtn )
	self.backBtn = backBtn
	
	local aboutText = display.newText( "Built with Corona SDK",
		20,20, display.contentWidth*0.75,300, native.systemFont, 16 )
	aboutText:setTextColor( 255,255,255 )
	group:insert( aboutText )
	self.aboutText = aboutText

	local txt = "a+b+c" 
	local tmpText = display.newText( txt,
		20,40, display.contentWidth*0.75,300, native.systemFont, 16 )
	aboutText:setTextColor( 255,255,255 )
	group:insert( tmpText )
	--local txt2 = evalMath(txt)
	local params = {
		a = 1,
		b = 20,
		c = 300
	}
	local txt2 = evalString( txt, params )
	local tmpText = display.newText( txt2,
		20,60, display.contentWidth*0.75,300, native.systemFont, 16 )
	aboutText:setTextColor( 255,255,255 )
	group:insert( tmpText )
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 10, "enterScene-AboutScreen" )

	local group = self.view

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 10, "exitScene-AboutScreen" )

	local group = self.view

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view

	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)

	-----------------------------------------------------------------------------

end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene

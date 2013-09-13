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

local scene = storyboard.newScene()


local function processButton( event )
	if( event.target == scene.startBtn ) then
		settings.currentPassage = "Start"
		storyVars = {}
		storyboard.gotoScene( "scripts.BookScreen", {
			effect = "slideLeft",
			time = 300,
		} )
		return true
	elseif( event.target == scene.contBtn ) then
		storyboard.gotoScene( "scripts.BookScreen", {
			effect = "slideLeft",
			time = 300
		} )
		return true
	elseif( event.target == scene.setBtn ) then
		storyboard.gotoScene( "scripts.SettingsScreen" )
		return true
	elseif( event.target == scene.aboutBtn ) then
		storyboard.gotoScene( "scripts.AboutScreen" )
		return true
	end
	return false
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 10, "createScene-MainScreen" )

	local group = self.view

	local function getButton( txt )
		local btn = widget.newButton( {
			width  = display.contentWidth * 0.75,
			height = 100,
			left = display.contentWidth * 0.125,
			label  = txt,
			onPress = processButton
		})
		btn:setReferencePoint( display.TopLeftReferencePoint )
		return btn
	end

	local startBtn = getButton( "Start Book" )
	startBtn.y  = 50
	group:insert( startBtn )
	self.startBtn = startBtn
	local contBtn = getButton( "Continue Book" )
	contBtn.y  = 150
	group:insert( contBtn )
	self.contBtn = contBtn
	local setBtn = getButton( "Settings" )
	setBtn.y   = 250
	group:insert( setBtn )
	self.setBtn = setBtn
	local aboutBtn = getButton( "About Us" )
	aboutBtn.y = 350
	group:insert( aboutBtn )
	self.aboutBtn = aboutBtn
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 10, "enterScene-MainScreen" )
	
	local group = self.view

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 10, "exitScene-MainScreen" )
	
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

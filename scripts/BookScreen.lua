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
require( "scripts.TwineFuncs" )

local scene = storyboard.newScene()


local function handleTransition( obj )
	-- make text slide in from the right
	obj.x = 1.1 * display.contentWidth

	
	-- parse the Twine code and process the template
	dprint( 10, "starting to parse ["..settings.currentPassage.."] (ht2)" )
	local text = ProcessTemplate( "page1.html", settings.currentPassage )
	
	-- the obj argument is the webview
	obj:request( "page1.html", system.DocumentsDirectory )

	transition.to( obj, {
		alpha = 1,
		x = display.contentWidth * 0.50,
		time = 300
	})
	
	return true
end

local function handleUrlEvent( event )	

	local url = event.url
	dprint( 5, "caught url ["..url.."]" )
	dprint( 5, "  name is [".. event.name .."]" )
	dprint( 5, "  type is [".. event.type .."]" )
	
	local i,j = string.find(url,"corona:")
	if( i ~= nil ) then
		local s = url:sub(j+1)
		dprint( 10, "jumping to ["..s.."]" )
		local webview = scene.webview
		if( s == "mainmenu" ) then
			-- webview is cleaned up in exitScene
			storyboard.gotoScene( "scripts.MainScreen" )
		else
			-- TODO: should send the new passage as a param
			-- we'll do global var for now
			-- make the text slide off to the left
			settings.currentPassage = s
			transition.to( webview, {
				alpha = 0,
				x = -1.1 * display.contentWidth,
				time = 300,
				onComplete = handleTransition
			})
		end
	else
		if( url:sub(1,4) == "http" ) then
			system.openURL( url )
		end
	end

	return true
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 10, "createScene-BookScreen" )
	
	local group = self.view
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 10, "enterScene-BookScreen" )

	local group = self.view
	
	-- parse the Twine code and process the template
	dprint( 10, "starting to parse ["..settings.currentPassage.."]" )
	local text = ProcessTemplate( "page1.html", settings.currentPassage )
	
	-- create a webview
	local webview = native.newWebView( 0,0, display.contentWidth, display.contentHeight )
	webview:request( "page1.html", system.DocumentsDirectory )
	webview:addEventListener( "urlRequest", handleUrlEvent )
	--group:insert( webview )
	self.webview = webview

	dprint( 10, "webview [" .. tostring(webview) .. "]" )
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 10, "exitScene-BookScreen" )

	local group = self.view
	
	local webview = self.webview
	webview:removeSelf()
	webview = nil
	scene.webview = nil
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

	local group = self.view

	
	

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

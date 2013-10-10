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
require( "scripts.UtilityFuncs" )

local scene = storyboard.newScene()

local function processButton( event )
	--print( "You pressed the back button!" )
	storyboard.gotoScene( "scripts.MainScreen" )
    return true
end

local function handleTransition( obj )
	-- move the scroll-area so we can slide it in from the right
	obj.alpha = 0
	obj.x = 2 * display.contentWidth
	
	-- set the scroll to the top
	local scroll = scene.scroll
	scroll:scrollToPosition({ 
		y = 0,
		time = 0
	})

	-- this really should be a timer, but then we lose the obj-reference
	--timer.performWithDelay( 600, handleTransition2 )
	transition.to( obj, {
		x = 0,
		alpha = 1,
		time = 400,
		onComplete = scene:displayPassage( settings.currentPassage )
	})
	
	return true
end

local function processTouch( event )
	dprint( 10, "processTouch .. "..event.phase )
	if( event.phase == "ended" ) then
		local target = event.target
		if( target ~= nil ) then
			local type = target.myType
			if( type == nil ) then
				-- not sure what just happened here
			elseif( type == "link" ) then
				local text = target.myText
				local link = text:match( "%[%[(.*)%]%]" )
				dprint( 15, "found link ["..link.."]" )
				settings.currentPassage = link
				
				local scroll = scene.scroll
				transition.to( scroll, {
					x = -2 * display.contentWidth,
					alpha = 0,
					time = 400,
					onComplete = handleTransition
				})
			end
		end
	end
	
	return true
end

function scene:clearScreen()
	-- local group = self.view
	local group = self.textArea

	for i=group.numChildren,1,-1 do
		local child = group[i]
		child.parent:remove( child )
	end
end

function scene:displayPassage( psg )
	-- local group = self.view
	local group = self.textArea
	local scroll = self.scroll

	-- clear any old display objects
	self:clearScreen()

	local alltext = ProcessPassage( psg )
	--print( "alltext ["..alltext.."]" )
	local data = alltext:split("\n")
	
	local top  = 10
	local vsep = settings.fontSize + 4
	local cwidth = display.contentWidth * 0.90
	--local cheight = display.contentHeight - 150
	local cheight = display.contentHeight
	for k,text in pairs(data) do
		if( text == nil ) then
			-- skip it
		elseif( text == "" ) then
			-- blank line
			top = top + vsep
		else
			if( text:find("%(%(") ~= nil ) then
				local tbl = text:getopts()
				if( tbl.type == "bgimg" ) then
					local wd = convertWidthPct( tbl.width )
					local ht = convertHeightPct( tbl.height )
					local fname = tbl.src
					local img = display.newImageRect( group, 
						fname, system.ResourceDirectory, 
						display.contentWidth,
						display.contentHeight )
					img:setReferencePoint( display.TopLeftReferencePoint )
					img.x = 0
					img.y = 0
					img.width = display.contentWidth
					img.height = display.contentHeight
				
				elseif( tbl.type == "img" ) then
					-- image
					local wd = convertWidthPct( tbl.width )
					local ht = convertHeightPct( tbl.height )
					local fname = tbl.src
					local img = display.newImageRect( group, 
						fname, system.ResourceDirectory, wd,ht )
					img:setReferencePoint( display.TopLeftReferencePoint )
					img.x = 0
					img.y = top
					img.width = wd
					img.height = ht
					top = top + ht
				elseif( tbl.type == "moveto" ) then
					-- move the "cursor" to a new location 
					-- so the next text shows up there
					local xx = convertWidthPct( tbl.x )
					local yy = convertHeightPct( tbl.y )
					top = yy
					
				end
			else
				-- the text box (not directly clickable)
				dprint( 15, "text=["..text.."] top="..top..";" )
				local textBox = display.newText( text, 20, top,
					cwidth, 0, native.systemFont, settings.fontSize	)
				group:insert( textBox )
			
				local t_wd = textBox.contentWidth
				local t_ht = textBox.contentHeight
			
				if( text:find("%[%[") ~= nil ) then
					-- this line has a link in it
					local textBg = display.newRoundedRect( 0,top, 
						cwidth+5,t_ht+5, 10 )
					dprint( 15, "text-bg [0,"..top..","..cwidth..","
							..(t_ht+5).."]" )
					textBg:setFillColor( 0,0,140 )
					textBg.strokeWidth = 4
					textBg:setStrokeColor( 0,0,0 )
					textBg.myType = "link"
					textBg.myText = text
					textBg:addEventListener( "touch", processTouch )
					group:insert( textBg )
					-- put the text back on top
					textBox:toFront()
					top = top + textBg.contentHeight
				else
					top = top + t_ht
				end
			end

		end
	end

	local backBtn = self.backBtn
	backBtn.y = top + vsep
	
	scroll:setScrollHeight( top+50 )	
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 10, "createScene-BookScreen" )
	
	local group = self.view
	
	local scroll = widget.newScrollView( {
		left = 0,
		top = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		scrollWidth = display.contentWidth,
		scrollHeight = 10*display.contentHeight,
		horizontalScrollDisabled = true,
		--isLocked = true,
		backgroundColor = {77,0,0},
		--listener = scrollListener
	})
	group:insert( scroll )
	self.scroll = scroll
	
	local bgimg = display.newRect( 0, 0, display.contentWidth, 10*display.contentHeight )
	bgimg:setReferencePoint( display.TopLeftReferencePoint )
	bgimg:setFillColor( 10,50,10 )
	scroll:insert( bgimg )
	self.bgimg = bgimg

	local textArea = display.newGroup()
	scroll:insert( textArea )
	self.textArea = textArea

	local backBtn = widget.newButton( {
			width  = 55,
			height = 25,
			left = display.contentWidth - 65,
			top = display.contentHeight + 50,
			label  = "Back",
			fontSize = 12,
			onPress = processButton
	})
	backBtn:setReferencePoint( display.TopLeftReferencePoint )
	scroll:insert( backBtn )
	self.backBtn = backBtn

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 10, "enterScene-BookScreen" )

	local group = self.view

	-- parse the Twine code and process the template
	dprint( 10, "starting to parse ["..settings.currentPassage.."]" )

	self:displayPassage( settings.currentPassage )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 10, "exitScene-BookScreen" )

	local group = self.view

	self:clearScreen()
	
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

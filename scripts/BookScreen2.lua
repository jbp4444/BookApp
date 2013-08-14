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

local plist = {}

local function processButton( event )
	if( event.target == scene.backBtn ) then
		storyboard.gotoScene( "scripts.MainScreen" )
		return true
	end
	return false
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
				settings.currentPassage = passageList[link]
				storyboard.gotoScene( "scripts.BookScreen", {
					effect = settings.effect,
					time = 300
				})
			end
		end
	end
	
	return true
end

function scene:clearPassage()
	-- local group = self.view
	local group = self.textArea

	for i=group.numChildren,1,-1 do
		local child = group[i]
		child.parent:remove( child )
	end
end

function scene:displayPassage( tlist )
	-- local group = self.view
	local group = self.textArea
	local scroll = self.scroll

	-- set the scroll to the top
	scroll:scrollToPosition( { y = 0 })
	-- clear any old display objects
	self:clearPassage()
	
	-- unroll the macros
	local tlist2 = unrollMacros( tlist, passageList, storyVars )
	
	-- estimate the total height of the window
	-- specifically, do we need to enable scrolling?
	local total_height = 0
	for k,text in pairs(tlist2) do
		if( text == nil ) then
			-- skip it
		elseif( text == "" ) then
			-- blank line
			total_height = total_height + 20
		else
			local num_lines = math.ceil( text:len() / 30 )
			total_height = total_height + 20*num_lines
		end
	end
	dprint( 5, "total estim height ["..total_height.."]" )
	
	-- this works to disable scrolling, but if scrolling is enabled
	-- then it can scroll the whole size (set to 10*display)
	if( total_height > (display.contentHeight-30) ) then
		dprint( 6, "   scroll is unlocked" )
		--scroll.isLocked = false
		scroll._view._isVerticalScrollingDisabled = false
	else
		dprint( 6, "   scroll is locked" )
		--scroll.isLocked = true
		scroll._view._isVerticalScrollingDisabled = true
		-- make new bg image the right size
		total_height = display.contentHeight - 30
	end
	
	-- try xnailbender's approach .. resize the bg image
	local bgimg = self.bgimg
	display.remove( bgimg )
	bgimg = nil
	bgimg = display.newRect( 0, 0, display.contentWidth, total_height )
	bgimg:setFillColor( 30,30,10 )
	scroll:insert( 1, bgimg )
	self.bgimg = bgimg

	local top   = 20
	local cwidth = display.contentWidth * 0.80
	local cheight = display.contentHeight - 150
	for k,text in pairs(tlist2) do
		if( text == nil ) then
			-- skip it
		elseif( text == "" ) then
			-- blank line
			top = top + 20
		else
			local num_lines = math.ceil( text:len() / 30 )
			
			if( text:find("%[%[") ~= nil ) then
				-- this line has a link in it
				local bght = 20*num_lines
				local textBg = display.newRect( 20, top, cwidth, bght )
				textBg:setFillColor( 140, 140, 140 )
				textBg.myType = "link"
				textBg.myText = text
				textBg:addEventListener( "touch", processTouch )
				group:insert( textBg )
			end
			-- the text box (not directly clickable)
			dprint( 15, "text=["..text.."]" )
			local textBox = display.newText( text, 20, top,
				cwidth, cheight, native.systemFont, 16	)
			group:insert( textBox )

			top = top + 20*num_lines
		end
	end

end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 10, "createScene-BookScreen2" )
	
	local group = self.view

	local backBtn = widget.newButton( {
			width  = 55,
			height = 25,
			left = display.contentWidth - 60,
			top = 2,
			label  = "Back",
			fontSize = 12,
			onPress = processButton
	})
	backBtn:setReferencePoint( display.TopLeftReferencePoint )
	group:insert( backBtn )
	self.backBtn = backBtn

	scrollMax = 100
	local scroll = widget.newScrollView( {
		left = 0,
		top = 30,
		width = display.contentWidth,
		height = display.contentHeight - 30,
		scrollWidth = display.contentWidth,
		scrollHeight = 10*display.contentHeight,
		horizontalScrollDisabled = true,
		--isLocked = true,
		backgroundColor = {0,0,0},
		--listener = scrollListener
	})
	group:insert( scroll )
	self.scroll = scroll
	
	local bgimg = display.newRect( 0, 0, display.contentWidth, 10*display.contentHeight )
	bgimg:setFillColor( 30,10,10 )
	scroll:insert( bgimg )
	self.bgimg = bgimg

	local textArea = display.newGroup()
	scroll:insert( textArea )
	self.textArea = textArea

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 10, "enterScene-BookScreen2" )

	local group = self.view

	local tlist = settings.currentPassage
	if( tlist == nil ) then
		tlist = passageList["Start"]
	end
	self:displayPassage( tlist )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 10, "exitScene-BookScreen2" )

	local group = self.view

	self:clearPassage()
	
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

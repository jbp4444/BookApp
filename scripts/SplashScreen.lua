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


-- Called when the scene's view does not exist:
function scene:createScene( event )
	dprint( 9, "createScene-SplashScreen" )

	local group = self.view

	local function getColorbar( num )
		local img = display.newRect( 0,0, display.contentWidth,100)
		img:setReferencePoint( display.TopLeftReferencePoint )
		img:setFillColor( 40*num,0,0 )
		return img
	end
	
	local bar1 = getColorbar(1)
	group:insert( bar1 )
	self.bar1 = bar1
	local bar2 = getColorbar(2)
	group:insert( bar2 )
	self.bar2 = bar2
	local bar3 = getColorbar(3)
	group:insert( bar3 )
	self.bar3 = bar3
	local bar4 = getColorbar(4)
	group:insert( bar4 )
	self.bar4 = bar4
	local bar5 = getColorbar(5)
	group:insert( bar5 )
	self.bar5 = bar5
	local bar6 = getColorbar(6)
	group:insert( bar6 )
	self.bar6 = bar6
	
end

function scene:cancelTween( obj )
	if( obj.tween ~= nil ) then
		transition.cancel( obj.tween )
		obj.tween = nil
	end
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	dprint( 9, "enterScene-SplashScreen" )

	local group = self.view

	local bar1 = self.bar1
	local bar2 = self.bar2
	local bar3 = self.bar3
	local bar4 = self.bar4
	local bar5 = self.bar5
	local bar6 = self.bar6

	bar1.y = -100
	bar2.y = -100
	bar3.y = -100
	bar4.y = -100
	bar5.y = -100
	bar6.y = -100
	
	self:cancelTween( bar1 )
	self:cancelTween( bar2 )
	self:cancelTween( bar3 )
	self:cancelTween( bar4 )
	self:cancelTween( bar5 )
	self:cancelTween( bar6 )

	bar1.tween = transition.to( bar1, {time=700, y=0,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar1)
		end
	})
	bar2.tween = transition.to( bar2, {time=700, y=100,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar2)
		end
	})
	bar3.tween = transition.to( bar3, {time=700, y=200,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar3)
		end
	})
	bar4.tween = transition.to( bar4, {time=700, y=300,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar4)
		end
	})
	bar5.tween = transition.to( bar5, {time=700, y=400,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar5)
		end
	})
	bar6.tween = transition.to( bar6, {time=700, y=500,
		transition=easing.outExpo,
		onComplete = function() 
			scene:cancelTween(bar6)
		end
	})

	timer.performWithDelay( 1000, function(e)
		storyboard.gotoScene( "scripts.MainScreen" )
	end )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	dprint( 9, "exitScene-SplashScreen" )

	local group = self.view

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	dprint( 9, "destroyScene-SplashScreen" )

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

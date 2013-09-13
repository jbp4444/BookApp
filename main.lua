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
require( "scripts.UtilityFuncs" )
require( "scripts.TwineFuncs" )

display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())

-- constants
STAGE_LEFT = display.screenOriginX
STAGE_TOP = display.screenOriginY
STAGE_WIDTH = ( display.contentWidth + STAGE_LEFT * -2 )
STAGE_HEIGHT = ( display.contentHeight + STAGE_TOP * -2 )
HALF_WIDTH = ( STAGE_WIDTH / 2 )
HALF_HEIGHT = ( STAGE_HEIGHT / 2 )

-- global settings
settings = {
	colormap = 1,
	effect = "slideLeft",
	fontsize = 12
}

-- helper function
debug_level = 21

dprint( 5, "display is "..display.contentWidth.." x "..display.contentHeight )

-- load the file in (just do this once)
storyVars = {}
templateFile = loadTemplateFile( "assets/theme.html" )
passageList = loadTwineFile( "assets/simple_story.html" )
settings.currentPassage = "Start"


-- load splash screen
storyboard.gotoScene( "scripts.SplashScreen" )

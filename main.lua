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
require( "scripts.UtilityFuncs" )
require( "scripts.TwineFuncs" )

widget.setTheme( "widget_theme_ios" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )

-- global settings
settings = {
	colormap = 1,
	effect = "slideLeft",
	fontsize = 24
}

-- helper function
debug_level = 12

dprint( 5, "display is "..display.contentWidth.." x "..display.contentHeight )

-- load the file in (just do this once)
storyVars = {}
--templateFile = loadTemplateFile( "assets/theme.html.txt" )
--passageList = loadTwineFile( "assets/calvin.txt" )
passageList = loadTwineFile( "assets/simple_story.txt" )
settings.currentPassage = "Start"

dprint( 5, "loaded file" )


-- load splash screen
storyboard.gotoScene( "scripts.BookScreen" )

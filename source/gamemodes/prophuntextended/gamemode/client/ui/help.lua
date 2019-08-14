--[[
	The MIT License (MIT)
	
	Copyright (c) 2015-2019 Xaymar

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

-- Help Panel

local UI = {}

local HTML = [[
    <!DOCTYPE html>
    <html>
        <head>
            <style>
                body {
                    font-family: Roboto;
                    font-size: 18pt;
                    color: rgba(255, 255, 255, 1.0);
                    background: rgba(51, 51, 51, 1.0);
                }

                div, p {
                    margin: 0;
                    padding: 0;
                }

                p + p {
                    margin-top: 10pt;
                }
            </style>
        </head>
        <body>
            <div id="about">
                <h1>About Prop Hunt Extended</h1>
                <p>
                    Hide n Seek with a twist: Hiders can turn into anything on the map! From bottles, to vending machines and all the way to huge cars, what you become depends on how you want to play. Do you want to blend in with your surroundings, or do you want to make a fool of the Seekers? And how will you deal with finding (and killing) all hiders as a Seeker?
                </p>
                <p>
                    The Gamemode comes with out of the box support for console configuration (ph_*), custom taunt support, prop rotation, an improved code base for modders and better integration and some other fixes. Support for MapVote is also built in, so as long as you have a compatible addon installed you will get a map voting menu at the end of a match.
                </p>
                <p>
                    <h2>Help Develop:</h2>
                    The Gamemode is Open Source under the MIT License <a href="https://github.com/xaymar/prophuntextended" target="_blank">on Github</a>.
                </p>
            </div>
            <div id="howto">
                <h2>How To Play</h2>
                <p>
                    <h3>Seekers</h3>
                    Your primary goal is to find hiders by any means possible. But watch out, you might lose health if you shoot an object that isn't actually a hider! Pick things up before shooting them, or simply remember the layout of the maps you are playing on. And remember: You lose if only a single hider is still alive at the end of the round.
                </p>
                <p>
                    <h3>Hiders</h3>
                    Stay alive as long as possible and make Seekers look like a fool. Dance around their feet, hide in plain sight or be that huge car that nobody though you could become! What you do is entirely up to you.
                </p>
                <p>
                    <h3>Spectators</h3>
                    You get to watch the whole thing go down live! Sit back, grab some popcorn or any other snack and relax.
                </p>
            </div>
            <div id="controls">
                <h2>Controls</h2>
                <table>
                    <tr>
                        <th>Key/Button</th>
                        <th>Control Name</th>
                        <th>Description</th>
                    </tr>
                    <tr>
                        <td>F1</td>
                        <td>ShowHelp</td>
                        <td>Opens the Help and Settings window for this gamemode.</td>
                    </tr>
                    <tr>
                        <td>F2</td>
                        <td>ShowTeam</td>
                        <td>Change the team.</td>
                    </tr>
                    <tr>
                        <td>F3</td>
                        <td>ShowSpare1</td>
                        <td>Play a random Taunt, if it is not currently on cooldown.</td>
                    </tr>
                    <tr>
                        <td>C</td>
                        <td>ShowContextMenu</td>
                        <td>Toggle between 1st and 3rd Person Camera.</td>
                    </tr>
                    <tr>
                        <td>Q</td>
                        <td>ShowSpawnMenu</td>
                        <td>Tap to rotate the prop towards your current view angle, hold to continue rotating.</td>
                    </tr>
                    <tr>
                        <td>Ctrl + E</td>
                        <td>Duck + Use</td>
                        <td>Interact with objects, such as picking them up, opening doors, or pushing buttons, instead of turning into the object you are targeting.</td>
                    </tr>
                </table>
            </div>
        </body>
    </html>
]]

function UI:Init()
    self.content = vgui.Create("DHTML", self)
    self.content:Dock(FILL)
    self.content:SetHTML(HTML)
    self.content.OnChildViewCreated = function(source, target, isPopup)
        gui.OpenURL(target)
        print(source)
        print(target)
        print(isPopup)
    end
    self.content.OnChangeTargetURL = function(url)
        print(url)
    end


--	GAMEMODE.UIManager:Listen("UpdateDPI", self, function(dpi) self:UpdateDPI(dpi) end)
--	self:UpdateDPI(GAMEMODE.UIManager:GetDPIScale())
end

function UI:OnRemove()
    self.content:Remove()
--	GAMEMODE.UIManager:Silence("UpdateDPI", self)
end

derma.DefineControl("PHE_HelpUI_Help", "Help Page for Prop Hunt Extended", UI, "DPanel");

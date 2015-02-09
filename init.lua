-- This code is licensed under the MIT Open Source License.

-- Copyright (c) 2015 Ruairidh Carmichael - ruairidhcarmichael@live.co.uk

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

---------------------------------------------
-- Set this to true to enable color theme. --
---------------------------------------------

local enableTheme = true
local theme = 'monokai'

---------------------------------------------------------
-- Don't edit below unless you know what you're doing. --
---------------------------------------------------------

local path = ...

local solar = {}
solar.list = {}

solar.x = 15
solar.y = 15
solar.width = 250
solar.height = 34

solar.theme = require(path .. '/themes/' .. theme)

function solar.addVar(name, variable)

	local value = variable()
	if value == true or value == false then
		variable = function() return tostring(value) end
	end

	assert(type(variable) == "function", "variable must be in function form")

	local tbl = {name = name, func = variable, format = "var"}

	table.insert(solar.list, tbl)

end

function solar.addWheel(name, variable)

	assert(type(variable) == "function", "variable must be in function form")

	local tbl = {name = name, func = variable, format = "wheel"}

	table.insert(solar.list, tbl)

end

function solar.addBar(name, variable, min, max, width, color)

	assert(type(variable) == "function", "variable must be in function form")

	local tbl = {name = name, func = variable, format = "bar", min = min or 0, max = max or 100, width = width or solar.width, color = color or {255, 255, 255, 255}}

	table.insert(solar.list, tbl)

end

function solar.addDivider(name)

	local tbl = {name = name or "divider", format = "divider"}

	table.insert(solar.list, tbl)

end

function solar.remove(name)

	for i=1, #solar.list do

		if solar.list[i].name == name then
			table.remove(solar.list, i)
			break
		end

	end

end

function solar.draw()

	if #solar.list == 0 then return end -- If theres nothing in the list, don't draw anything.

	local objectheight = 0
	local panelheight = 0

	local function addObjectHeight(height)

		objectheight = objectheight + height

	end

	local function removeObjectHeight(height)

		objectheight = objectheight - height

	end

	local function addPanelHeight(height)

		panelheight = panelheight + height

	end

	local function removePanelHeight(height)

		panelheight = panelheight - height

	end

	local highestwidth = 0
	local numberofvars = 0
	local numberofwheels = 0
	local numberofbars = 0
	local numberofdividers = 0

	-- Resize panel to biggest object width. --
	-- TODO: Add Wheels to the logic. --

	for i=1, #solar.list do

		local format = solar.list[i].format

		if format == "var" then
			local lengthstring = tostring(solar.list[i].name .. ": " .. solar.list[i].func())

			if solar.theme.font:getWidth(lengthstring) > highestwidth then
				solar.highestwidth = solar.theme.font:getWidth(lengthstring)
			end

		elseif format == "bar" then
			if solar.list[i].width > highestwidth then
				highestwidth = solar.list[i].width - 16
			end
		end
	end

	solar.width = 15 + highestwidth

	-- Find how many types of objects --

	for i=1, #solar.list do
		if solar.list[i].format == "var" then
			numberofvars = numberofvars + 1
		elseif solar.list[i].format == "wheel" then
			numberofwheels = numberofwheels + 1
		elseif solar.list[i].format == "bar" then
			numberofbars = numberofbars + 1
		elseif solar.list[i].format == "divider" then
			numberofdividers = numberofdividers + 1
		end
	end

	-- Set the panel height depending on object height. --

	addPanelHeight(solar.theme.font:getHeight() * numberofvars)
	addPanelHeight((solar.theme.font:getHeight() * (numberofwheels)) + (70 * numberofwheels) + 4)
	addPanelHeight((solar.theme.font:getHeight() * (numberofbars)) + (24 * numberofbars))
	addPanelHeight((((solar.theme.divider_gap * 2) + solar.theme.divider_size) * numberofdividers) + 4)

	-- Draw the panel background. --

	local bgimage = solar.theme.bg_image
	local bgformat = solar.theme.bg_type

	if bgformat == "color" then

		love.graphics.setColor(solar.theme.color.panelbg)
		love.graphics.rectangle("fill", solar.x, solar.y, solar.width, panelheight)
		love.graphics.setColor(255,255,255,255)

	elseif bgformat == "image" then

		local scalex = solar.width / bgimage:getWidth()
		local scaley = panelheight / bgimage:getHeight()

		love.graphics.draw(bgimage, solar.x, solar.y, 0, scalex, scaley)

	elseif bgformat == "tiled-image" then

		bgimage:setWrap('repeat', 'repeat')
		local bgQuad = love.graphics.newQuad(0, 0, solar.width, panelheight, bgimage:getHeight(), bgimage:getWidth())
		love.graphics.draw(bgimage, bgQuad, solar.x, solar.y)

	end

	addObjectHeight((solar.y + 4) - solar.theme.font:getHeight())

	-- Draw the objects. --

	for i=1, #solar.list do

		local format = solar.list[i].format
		local name = solar.list[i].name
		local func = nil

		if format ~= "divider" then
			func = solar.list[i].func()
		end

		if format == "var" then

			addObjectHeight(solar.theme.font:getHeight())

			love.graphics.setFont(solar.theme.font)

			love.graphics.print(name .. ":", solar.x + 4, objectheight)

			-- Variable highlighting --
			if enableTheme then
				if func == "true" then
					love.graphics.setColor(solar.theme.color.boolean_true)
				elseif func == "false" then
					love.graphics.setColor(solar.theme.color.boolean_false)
				elseif type(func) == "string" then
					love.graphics.setColor(solar.theme.color.string)
				elseif type(func) == "number" then
					love.graphics.setColor(solar.theme.color.number)
				end
			end

			-- Pretty quotations --
			if func ~= "true" and func ~= "false" then
				if type(func) == "string" then
					func = '"' .. func .. '"'
				end
			end

			love.graphics.print(func, solar.theme.font:getWidth(name) + solar.x + 12, objectheight)

			love.graphics.setColor(255,255,255)

		elseif format == "wheel" then

			addObjectHeight(solar.theme.font:getHeight())

			love.graphics.setFont(theme.font)

			love.graphics.print(name .. ":", solar.x + 4, objectheight)

			addObjectHeight(solar.theme.font:getHeight())

			love.graphics.circle("line", (solar.x + 4) + 35, objectheight + 35, 35, 20)

			addObjectHeight(objectheight + 50)

		elseif format == "bar" then

			local barwidth = 0

			-- Print the name. --

			addObjectHeight(solar.theme.font:getHeight())

			love.graphics.setFont(solar.theme.font)

			love.graphics.print(name .. ":", solar.x + 4, objectheight)

			addObjectHeight(solar.theme.font:getHeight())

			-- If the panels width is lower than the bar width, --
			-- Then resize the bar to the panel. --

			if solar.width < solar.list[i].width then
				barwidth = solar.width
			else
				barwidth = solar.list[i].width
			end

			local valuewidth = 0

			valuewidth = (func - solar.list[i].min) / solar.list[i].max

			-- Don't overdraw the bar. --

			if valuewidth < 0 then
				valuewidth = 0
			elseif valuewidth > 1 then
				valuewidth = 1
			end

			love.graphics.setColor(solar.list[i].color)

			-- Bar to show the value. --

			love.graphics.rectangle("fill", solar.x + 8, objectheight, (barwidth - 16) * valuewidth, solar.theme.bar_size)

			-- Bar outline. --

			love.graphics.rectangle("line", solar.x + 8, objectheight, barwidth - 16, solar.theme.bar_size)

			love.graphics.setColor(255, 255, 255, 255)

			-- Add bar height. --

			addObjectHeight(solar.theme.bar_size)

			removeObjectHeight(solar.theme.font:getHeight())

			-- Add a small gap. --

			addObjectHeight(4)

			elseif format == "divider" then

				addObjectHeight(solar.theme.font:getHeight() + solar.theme.divider_gap)

				love.graphics.setColor(solar.theme.color.divider)

				love.graphics.rectangle("fill", solar.x + 8, objectheight, solar.width - 16, solar.theme.divider_size)

				love.graphics.setColor(255, 255, 255, 255)

				removeObjectHeight(solar.theme.font:getHeight())

				addObjectHeight(solar.theme.divider_size + solar.theme.divider_gap)

		end

	end

end

return solar
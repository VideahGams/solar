local path = (...):match("(.-)[^%.]+$") .. '.'
local class = require(path .. "util.middleclass")
local util = require(path .. "util.util")
local Base = require(path .. "base")

local Text = class("Text", Base)

function Text:initialize(var, settings)

	Base.initialize(self, var, settings)

	self.text = var

	self.font = self.settings.font
	self.width = self.font:getWidth(self.text)
	self.height = self.font:getHeight()

	print("     Created Text Object")

end

function Text:draw()

	self:Align()

	love.graphics.setFont(self.font)

	love.graphics.setColor(0, 0, 0, 255)

	love.graphics.print(self.text, self.x + self.panelx, self.y + self.panely)

	love.graphics.setColor(255, 255, 255)

end

function Text:update(dt)

end

return Text
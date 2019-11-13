Object = require "lib.classic"
Input = require "lib.input"
wf = require "lib.windfield"
inspect = require "lib.inspect"
json = require "lib.json"

DEBUG = true
TILE_SIZE = 64

function love.load()
	love.window.setMode(TILE_SIZE*8, TILE_SIZE*8)

	local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)
end

function love.update(dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle('fill', TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

----------

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local type = love.filesystem.getInfo(file).type
        if type == "file" then
          table.insert(file_list, file)
        elseif type == "directory" then
          recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

WINDOW_WIDTH = 640
WINDOW_HEIGHT = 540
PLAYABLE_HEIGHT = 480
TILE_SIZE = 32

TILE_EMPTY = 0
TILE_HEAD = 1
TILE_BODY = 2
TILE_APPLE = 3

TILES_NUMBER_X = WINDOW_WIDTH / TILE_SIZE
TILES_NUMBER_Y = PLAYABLE_HEIGHT / TILE_SIZE

local snake = {}
local snake_length = 1
local snake_head_position = {}
local tile_grid = {}

local time_passed = 0
local appleX, appleY = 0, 0

-- 1 for moving right , -1 for moving left , 0 for stop movement
local movementDirectionX = 1
local lastMovementDirectionX = 0
-- 1 for moving down , -1 for moving up , 0 for stop movement
local movementDirectionY = 0
local lastMovementDirectionY = 0

local score = 0

local game_over = false

function love.load()
    love.window.setTitle("Snake")
    love.window.setMode(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        {
            fullscreen = false
        }
    )
    initializeGrid()
    initializeSnake()
    math.randomseed(os.time())
    setAppleLocation()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if not game_over then
        if key == "right" and lastMovementDirectionX == 0 then
            movementDirectionX = 1
            movementDirectionY = 0
        elseif key == "left" and lastMovementDirectionX == 0 then
            movementDirectionX = -1
            movementDirectionY = 0
        elseif key == "up" and lastMovementDirectionY == 0 then
            movementDirectionY = -1
            movementDirectionX = 0
        elseif key == "down" and lastMovementDirectionY == 0 then
            movementDirectionY = 1
            movementDirectionX = 0
        end
    else
        if key ~= "escape" then
            restartGame()
        end
    end
end

function love.update(dt)
    if not game_over then
        time_passed = time_passed + dt
        if time_passed >= 0.1 then
            moveSnake()
            lastMovementDirectionX = movementDirectionX
            lastMovementDirectionY = movementDirectionY
            time_passed = 0
        end
    end
end

function love.draw()
    drawGrid()
    drawSnake()
    drawApple()
    drawScore()
    if game_over then
        local large_font = love.graphics.newFont(64)
        love.graphics.setColor(1, 0, 1, 1)
        love.graphics.setFont(large_font)
        love.graphics.printf("GAME OVER!", 0, (WINDOW_HEIGHT / 2) - 64, WINDOW_WIDTH, "center")
        local medium_font = love.graphics.newFont(32)
        love.graphics.setFont(medium_font)
        love.graphics.printf("SCORE : " .. score, 0, (WINDOW_HEIGHT / 2) + 24, WINDOW_WIDTH, "center")
        local small_font = love.graphics.newFont(24)
        love.graphics.setFont(small_font)
        love.graphics.printf("press any key to replay!", 0, (WINDOW_HEIGHT / 2) + 64, WINDOW_WIDTH, "center")
    end
end

-- Initialize tile_table with the size of the grid.
-- Fill tile_table with zeros.
function initializeGrid()
    tile_grid = {}
    for y = 1, TILES_NUMBER_Y do
        table.insert(tile_grid, {})
        for x = 1, TILES_NUMBER_X do
            table.insert(tile_grid[y], TILE_EMPTY)
        end
    end
end

-- Drawing the grid
function drawGrid()
    love.graphics.setColor(0, 1, 1, 1)
    for y = 1, TILES_NUMBER_Y do
        for x = 1, TILES_NUMBER_X do
            love.graphics.rectangle("line", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            tile_grid[y][x] = TILE_EMPTY
        end
    end
end

-- initialize snake
function initializeSnake()
    snake = {}
    table.insert(snake, {})
    snake[1]["x"] = 0
    snake[1]["y"] = 0
    snake_length = 1
    snake_head_position["x"] = 1
    snake_head_position["y"] = 1
end

-- Drawing the snake in each frame.
function drawSnake()
    for i = 1, snake_length do
        if i == snake_length then
            love.graphics.setColor(0, 1, 0.5, 1)
        else
            love.graphics.setColor(0, 1, 0, 1)
        end

        love.graphics.rectangle("fill", snake[i]["x"] * TILE_SIZE, snake[i]["y"] * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        tile_grid[snake[i]["y"] + 1][snake[i]["x"] + 1] = TILE_BODY
    end
    tile_grid[snake_head_position["y"]][snake_head_position["x"]] = TILE_HEAD
end

function moveSnake()
    local newX
    local newY
    if movementDirectionX ~= 0 then
        newX = snake[snake_length]["x"] + movementDirectionX
        newY = snake[snake_length]["y"]
        if newX >= TILES_NUMBER_X then
            newX = 0
        elseif newX < 0 then
            newX = TILES_NUMBER_X - 1
        end
        snake_head_position["x"] = newX + 1
    else
        newX = snake[snake_length]["x"]
        newY = snake[snake_length]["y"] + movementDirectionY
        if newY >= TILES_NUMBER_Y then
            newY = 0
        elseif newY < 0 then
            newY = TILES_NUMBER_Y - 1
        end
        snake_head_position["y"] = newY + 1
    end
    if tile_grid[snake_head_position["y"]][snake_head_position["x"]] == TILE_EMPTY then
        table.remove(snake, 1)
    elseif tile_grid[snake_head_position["y"]][snake_head_position["x"]] == TILE_APPLE then
        snake_length = snake_length + 1
        score = score + 10
        setAppleLocation()
    else
        game_over = true
    end

    table.insert(snake, {})
    snake[snake_length]["x"] = newX
    snake[snake_length]["y"] = newY
end

-- change the location of the apple in the grid.
function setAppleLocation()
    while true do
        local y = math.random(1, TILES_NUMBER_Y)
        local x = math.random(1, TILES_NUMBER_X)
        if tile_grid[y][x] == 0 then
            tile_grid[y][x] = 3
            appleX = x
            appleY = y
            break
        end
    end
end

-- Drawing Apple.
function drawApple()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", (appleX - 1) * TILE_SIZE, (appleY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    tile_grid[appleY][appleX] = TILE_APPLE
end

function drawScore()
    local small = love.graphics.newFont(18)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(small)
    love.graphics.printf("SCORE : " .. score, 10, WINDOW_HEIGHT - 40, WINDOW_WIDTH, "left")
end

function restartGame()
    initializeGrid()
    initializeSnake()
    setAppleLocation()
    movementDirectionX = 1
    movementDirectionY = 0
    lastMovementDirectionY, lastMovementDirectionX = 0, 0
    score = 0
    game_over = false
end

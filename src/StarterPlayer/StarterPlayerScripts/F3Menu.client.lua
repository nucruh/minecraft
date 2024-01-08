local replicated_storage = game:GetService('ReplicatedStorage')
local run_service = game:GetService('RunService')

--local chunk_settings = require(replicated_storage.Chunk.ChunkSettings)
local tags = require(replicated_storage.Blocks.Tags)

local player = game.Players.LocalPlayer
local gui = player.PlayerGui
local f3_menu = gui:WaitForChild('F3', 60)

local frames = 0


-- add raycast to block so that i can see the position and what block its hitting, same system shall be used
-- for detecting block mining and stuff
local function update(delta_time)
    frames += 1

    if frames % 4 == 0 then
        f3_menu.Left.FPS.Text = ((1 / delta_time) // 1)..' FPS'
    end

    -- player position
    local position = player.Character.PrimaryPart.Position
    local x, y, z = string.format('%.1f', position.X / 3) ..' / ', string.format('%.1f', position.Y / 3) ..' / ', string.format('%.1f', position.Z / 3)
    f3_menu.Left.Coords.Text = 'XYZ: '..x..y..z

    -- block positon
    local mouse = player:GetMouse()
    local target = mouse.Target

    if target then
        if tags[target.Name] then
            local target_position = target.Position / 3

            f3_menu.Right.TargetedBlock.Text = 'BLOCK: '..target_position.X..', '..target_position.Y..', '..target_position.Z
        end
    end

end


run_service:BindToRenderStep('f3_menu_update', 300, update)
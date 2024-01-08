local mining_controller = {}

local run_service = game:GetService('RunService')
local user_input = game:GetService('UserInputService')
local context_action = game:GetService('ContextActionService')

local inset_y = game:GetService('GuiService'):GetGuiInset().Y

local active_mining_block = nil
local active_block_break_time = 0
local break_time_progress = 0
local highlighted_object = nil
local ray_distance = 16

local filter = {workspace.Chunks}

local highlight_object = Instance.new('SelectionBox', workspace)
highlight_object.Adornee = nil
highlight_object.LineThickness = 0.01
highlight_object.SurfaceTransparency = 1
highlight_object.Color3 = Color3.new(0, 0, 0)
highlight_object.Transparency = 0.65

function mining_controller.raycast()
    local paramaters = RaycastParams.new()
    paramaters.FilterType = Enum.RaycastFilterType.Include
    paramaters.FilterDescendantsInstances = filter

    local camera = workspace.CurrentCamera
    local mouse_position = user_input:GetMouseLocation()
    local unit_ray = camera:ScreenPointToRay(mouse_position.X, mouse_position.Y - inset_y)

    return workspace:Raycast(unit_ray.Origin, unit_ray.Direction * ray_distance, paramaters)
end

function highlight(object)
    if object ~= highlighted_object then
        highlighted_object = object
        highlight_object.Adornee = object
    end
end

function destroy_block(_, state)
    if state ~= Enum.UserInputState.Begin then return end
    if not highlighted_object then return end

    -- make sure to do highlighted and not highlight, big difference!

    local block_name = highlighted_object.Name

    local block_coords = string.split(block_name, '@')[1]
    local chunk_coords = highlighted_object.Parent.Name

    print(highlighted_object.Parent.Name)

    -- not sure if i can use table.remove() for this?
    _G.game_chunks[chunk_coords][block_coords] = nil

end

function mining_controller.update(delta_time)
    local ray_result = mining_controller.raycast()

    if ray_result then
        highlight(ray_result.Instance)
    else
        highlight_object.Adornee = nil
        highlighted_object = nil
    end
end

function mining_controller.start()
    run_service:BindToRenderStep('MiningControllerUpdate', 500, mining_controller.update)

    context_action:BindAction('MineBlock', destroy_block, false, Enum.UserInputType.MouseButton1)
end



return mining_controller
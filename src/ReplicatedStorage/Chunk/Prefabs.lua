--[[
local result = ''
for _, v in game:GetService('Selection'):Get() do
    local pos = v.Position
    local id = v.Name

    local x, y, z = pos.X, pos.Y, pos.Z

    local block_result = x ..','.. y ..','.. z..':'.. id ..';'

    result..=block_result
end

print(result)
--]]

return {
    ['oak_tree'] = '2,2,-2:oak_leaves;1,2,-1:oak_leaves;1,2,-2:oak_leaves;2,2,-1:oak_leaves;0,1,0:oak_log;0,2,0:oak_log;1,3,-1:oak_leaves;0,3,-1:oak_leaves;0,3,-2:oak_leaves;1,3,-2:oak_leaves;1,3,0:oak_leaves;2,3,0:oak_leaves;2,3,-1:oak_leaves;2,3,-2:oak_leaves;-2,2,-2:oak_leaves;-2,2,-1:oak_leaves;-2,2,0:oak_leaves;-2,2,1:oak_leaves;-1,2,1:oak_leaves;-1,2,0:oak_leaves;-1,2,-1:oak_leaves;-1,2,-2:oak_leaves;0,2,-2:oak_leaves;0,2,-1:oak_leaves;1,2,0:oak_leaves;2,2,0:oak_leaves;0,0,0:oak_log;0,3,0:oak_log;-1,3,-1:oak_leaves;0,3,1:oak_leaves;-1,3,1:oak_leaves;1,3,1:oak_leaves;-1,3,-2:oak_leaves;-2,3,-1:oak_leaves;-2,3,-2:oak_leaves;-1,3,0:oak_leaves;1,2,1:oak_leaves;0,2,1:oak_leaves;0,4,0:oak_log;0,4,-1:oak_leaves;1,4,-1:oak_leaves;1,4,0:oak_leaves;0,4,1:oak_leaves;1,4,1:oak_leaves;-1,4,-1:oak_leaves;-1,4,1:oak_leaves;-1,4,0:oak_leaves;0,3,2:oak_leaves;-1,3,2:oak_leaves;2,3,1:oak_leaves;-2,3,2:oak_leaves;-2,3,1:oak_leaves;-2,3,0:oak_leaves;-2,2,2:oak_leaves;-1,2,2:oak_leaves;2,2,1:oak_leaves;1,2,2:oak_leaves;0,2,2:oak_leaves;1,3,2:oak_leaves;2,3,2:oak_leaves;2,2,2:oak_leaves;0,5,0:oak_leaves;1,5,0:oak_leaves;-1,5,0:oak_leaves;0,5,1:oak_leaves;0,5,-1:oak_leaves'

}
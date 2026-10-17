local dummy_transforming = {}

dummy_transforming.armed = false

function dummy_transforming.execute_if_armed()
    if dummy_transforming.armed then
        dofile "%MODULE_PATH%/execute.lua"
        dummy_transforming.armed = false
    end
end

return dummy_transforming

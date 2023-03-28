local toSearch = {
    ["Workspace"] = true,
    ["Players"] = true,
    ["Lighting"] = true,
    ["MaterialService"] = true,
    ["NetworkClient"] = true,
    ["ReplicatedFirst"] = true,
    ["ReplicatedStorage"] = true,
    ["StarterGui"] = true,
    ["StarterPack"] = true,
    ["StarterPlayer"] = true
}

local function tableToString(t, indent)
    indent = indent or ""
    local str = "{\n"
    for k, v in pairs(t) do
        if type(v) == "table" then
            str = str .. indent .. "    [" .. tostring(k) .. "] = " .. tableToString(v, indent .. "    ") .. ",\n"
        elseif type(v) == "string" then
            str = str .. indent .. "    [" .. tostring(k) .. '] = "' .. tostring(v) .. '",\n'
        else
            str = str .. indent .. "    [" .. tostring(k) .. "] = " .. tostring(v) .. ",\n"
        end
    end
    str = str .. indent .. "}"
    return str
end

local function scanModule(module)
    if not module:IsA("ModuleScript") then
        return
    end
    
    local moduleContents = require(module)
    if type(moduleContents) == "function" then
        return
    end
    
    local path = ""
    local current = module
    while current ~= game do
        path = current.Name .. "\\" .. path
        current = current.Parent
    end
    path = "game\\" .. path .. module.Name
    
    print("Scanning " .. path)
    
    local types = {}
    for name, value in pairs(moduleContents) do
        local valueType = type(value)
        if not types[valueType] then
            types[valueType] = {}
        end
        table.insert(types[valueType], name)
    end
    
    for valueType, names in pairs(types) do
        print("  [" .. valueType .. "]")
        for _, name in ipairs(names) do
            local value = moduleContents[name]
            if valueType == "table" then
                print("    " .. name .. " = " .. tableToString(value, "      "))
            elseif valueType == "function" then
                print("    " .. name .. " = " .. tostring(value) .. " (" .. debug.info(value, "a") .. " arguments)")
            elseif valueType == "string" then
                print('    ' .. name .. ' = "' .. value .. '"')
            else
                print("    " .. name .. " = " .. tostring(value))
            end
        end
    end
end

for _, service in pairs(game:GetChildren()) do
    local serviceName = service.Name
    if toSearch[serviceName] then
        for _, module in pairs(service:GetChildren()) do
            scanModule(module)
        end
    end
end

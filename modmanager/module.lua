modmanagerconfig = {
    mods_path = "MODMANAGER/mod",
    internal_mod_path = "MODMANAGER/internalmodsdata/",
    modmanagerenabled = true,
}

local json = require ("dkjson")
local internal_strings={} do
    internal_strings['local']  =[=[
                                ------- LOCALIZER FRAMEWORK, ADD NEW PARAMS BY USING G.SRLOCALIZER[string_key] = localized_string
                                ------- ONLY SUPPORTS ENGLIH OR WHATEVER TEXT IS ADDED, NO OTHER LANGUAGE SUPPORT

                                local srlocalizer = {}
                                srlocalizer.startpriority = 1

                                local function get(arg, def)
                                    if G.SRLOCALIZER[arg] then
                                        if def and def.nodes and def.type == "quip" then
                                            return G.SRLOCALIZER[arg]
                                        end    
                                        print('parsing modified:', arg, ">", G.SRLOCALIZER[arg])
                                        return G.SRLOCALIZER[arg]
                                    end 
                                end    

                                function srlocalizer.start()
                                    G.SRLOCALIZER = {}
                                    balatromodmanager:FunctionModification(nil, "localize", function(arg) 
                                        if type(arg) == "string" then
                                            local rep = get(arg)
                                            if rep then return rep end
                                        elseif type(arg) == 'table' then
                                            local key = arg.key
                                            local rep = key and get(key,arg)
                                            if rep then
                                                if arg.nodes and arg.type=='quip' then
                                                    G.localization.quips_parsed[key] = rep
                                                else
                                                    return rep
                                                end    
                                            end    
                                        end  
                                    end)
                                end  

                                SRHUMANSLOCALIZER = srlocalizer
                                return srlocalizer
                                ]=]
    internal_strings['gui']    =[=[
                                --------- INTERNAL MOD MANAGER GUI ----------

                                G.MOD_CONFIGS.BALATROMODMANAGERUI_CONFIG = {
                                    debug_mode = false, insultingjoker = false
                                }

                                local GUIBalatroModManager = {}
                                GUIBalatroModManager.startpriority = 999 -- low priority so all mods can load

                                local moddetailcache = {}
                                local info = {menuopen = false}

                                local function candrawui()
                                    return G.STAGE == G.STAGES.MAIN_MENU
                                end    
                                local function config()
                                    return G.MOD_CONFIGS.BALATROMODMANAGERUI_CONFIG
                                end    
                                function string_split(inputstr, sep)
                                    if sep == nil then
                                        sep = "%s" 
                                    end
                                    local t = {}
                                    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                                        table.insert(t, str)
                                    end
                                    return t
                                end

                                GUIBalatroModManager.getdetails =
                                function()
                                    return {
                                        i_INTERNALMODID = "internal_balatromodmanagerui",
                                        i_DISPLAYNAME = 'Mod Manager UI',
                                        i_DESCRIPTION = 'Displays all your installed and activated mods',
                                        i_COMPATIBLEWITHOTHERMODS =true,
                                        i_AUTHOR = 'srhuman',

                                        i_TAGS = {
                                        t_overridecode = false
                                        }
                                    }
                                end    

                                --- experimental: uimod config menu
                                function GUIBalatroModManager.settingsmenu()
                                    G.SETTINGS.paused = true
                                    local configContent = {
                                        create_toggle({label = "Debug Mode", ref_table = G.MOD_CONFIGS.BALATROMODMANAGERUI_CONFIG, ref_value = "debug_mode"}),
                                        create_toggle({label = "Insulting Joker", ref_table = G.MOD_CONFIGS.BALATROMODMANAGERUI_CONFIG, ref_value = "insultingjoker"}),
                                    }
                                    local backCode = ttttMODMANAGERUI_bfunc 
                                    local newUi = create_UIBox_generic_options{contents = configContent, back_func = backCode}
                                    G.FUNCS.overlay_menu{
                                        definition = newUi
                                    }
                                end    

                                local function getModInspectFunction(mod)
                                    return function()
                                        local details = mod.getdetails()
                                        G.SETTINGS.paused = true
                                        -- create inspect GUI
                                        G.FUNCS['balatromodmanagergui_opensettingcurrentfunction'] = mod.settingsmenu
                                        local displayname = UIBox_button({button = 'emptyfunction', colour = G.C.CLEAR, label = {details.i_DISPLAYNAME}, minw = 5, maxh = 0.8, focus_args = {snap_to = true}})
                                        local author = UIBox_button({button = 'emptyfunction', colour = G.C.CLEAR, maxh = 0.5, maxw = 0.9, label = {details.i_AUTHOR}, minw = 5, focus_args = {snap_to = true}})
                                        local padding1 = UIBox_button({button = 'emptyfunction', colour = G.C.CLEAR, label = {""}, minw = 5, focus_args = {snap_to = true}})
                                        local descriptionText = string_split(details.i_DESCRIPTION, "\n")
                                        local description = UIBox_button({button = 'emptyfunction', colour = G.C.CLEAR, label = descriptionText, minw = 5, focus_args = {snap_to = true}})
                                        local settingsbutton = mod.settingsmenu and UIBox_button({button = 'balatromodmanagergui_opensettingcurrentfunction', colour = G.C.GREEN, label = {"CONFIG"}, minw = 5, focus_args = {snap_to = true}}) or nil

                                        local bcontents = {
                                            displayname, author, padding1, description, settingsbutton
                                        }
                                        G.FUNCS.overlay_menu{definition = create_UIBox_generic_options(
                                            {contents = bcontents, back_func = ttttMODMANAGERUI_bfunc}
                                        )}
                                    end    
                                end    

                                function GUIBalatroModManager.start()
                                    -- define localizers
                                    G.SRLOCALIZER["mmframeworkui_introduce"] = "Thanks for using Srhuman's Mod Loader!"

                                    local flag_introduce = false
                                    table.insert(balatromodmanager.firstTimeUsingFunctions, function()
                                        flag_introduce = true
                                    end)

                                    G.FUNCS['emptyfunction'] = function() end
                                    for i,v in pairs(G.MMLOADEDMODS) do
                                        if v.getdetails then
                                            local details = v.getdetails()
                                            details.mmloadedidx = i
                                            local key=balatromodmanager:DefineNewGFunction("inspect_mod_mod_manager_"..tostring(i), getModInspectFunction(v))
                                            details.inspectkey = key
                                            table.insert(moddetailcache, details)
                                        end    
                                    end

                                    function openGuiBalatroModManager()
                                        G.SETTINGS.paused = true
                                        local gbconents = {}
                                        for i,v in pairs(moddetailcache) do
                                            local h = UIBox_button({button = v.inspectkey, label = {config().debug_mode and v.mmloadedidx or v.i_DISPLAYNAME .. " - " .. v.i_AUTHOR}, minw = 5, focus_args = {snap_to = true}})
                                            table.insert(gbconents, h)
                                        end    
                                        if G.FUNCS['balatromodmanager_savemodconfigs'] then
                                            table.insert(gbconents, UIBox_button({colour = G.C.PURPLE, button = "balatromodmanager_savemodconfigs", label = {"Save mod settings"}, minw = 5, focus_args = {snap_to = true}}))
                                        end   
                                        print(G.FUNCS['balatromodmanager_openmoddir'])
                                        if G.FUNCS['balatromodmanager_openmoddir'] then
                                            table.insert(gbconents, UIBox_button({colour = G.C.PURPLE, button = "balatromodmanager_openmoddir", label = {"Open mod folder"}, minw = 5, focus_args = {snap_to = true}}))
                                        end   
                                        G.FUNCS.overlay_menu{definition = create_UIBox_generic_options(
                                            {contents = gbconents}
                                        )}
                                    end    
                                    
                                -- balatromodmanager:ConnectToDraw(GUIBalatroModManager.draw)
                                    local bfunc = balatromodmanager:DefineNewGFunction("open_mod_manager_ui", openGuiBalatroModManager)
                                    ttttMODMANAGERUI_bfunc = bfunc

                                    local typeofmodbutton = 2
                                    balatromodmanager:HookFunction(nil, "create_UIBox_main_menu_buttons", function(t)
                                        if flag_introduce and config().insultingjoker then
                                            --flag_introduce = false
                                            local jimbo = Card_Character{x=0,y=5, center = G.CHAOSMOD_ISREADY and G.P_CENTERS[ModuleChaosMod.publicutils.getrandomjoker()] or G.P_CENTERS.j_mime}
                                            jimbo:add_speech_bubble('lq_'..math.random(1,10), nil, {quip = true})
                                            jimbo:say_stuff(5)
                                        end   

                                        if typeofmodbutton == 2 then -- add a new button straight into the play buttons
                                            local buttons = t.nodes[1].nodes[1].nodes
                                            local b = UIBox_button{id = 'modmodmod_openmodmanager', button = bfunc, colour = G.C.PALE_GREEN, minw = 2, minh = 0.9, label = {"Mods"}, scale = 0.45*1.1, col = true}
                                            table.insert(buttons, b)--1, b)
                                            return t
                                        end 
                                    end, 1)
                                    balatromodmanager:HookFunction(nil, "create_UIBox_profile_button", function(t) 
                                        local n=t.nodes[1]
                                        n.config.r=0
                                        n.config.padding=0.03
                                    end, 1)
                                end

                                return GUIBalatroModManager
                                ]=] 
    internal_strings['temp']   =
[=[
------- MOD TEMPLATE/EXAMPLE ---------

G.MOD_CONFIGS.TEMPLATEMOD = {
    -- any settings
    test_value = 100
}

--- Module:
local templateMod = {} -- remove the local if you want this to be global (can be used in other scripts / mods)
templateMod.startpriority = 1 -- the order in which mods start, (eg 1 startpriority would be one of the first mods to start)

-- Mod Methods:

local function getmodConfig()
    return G.MOD_CONFIGS.TEMPLATEMOD
end   

-- [[MOD DETAILS]] --
function templateMod.getdetails()
    return {
        i_INTERNALMODID = "mod_templatemod", -- unique mod identifier
        i_DISPLAYNAME = 'Your first mod',
        i_DESCRIPTION = 'This is a template for making a mod,\nopen /MODMANAGER/mod/template-mod.lua to edit it!',
        i_AUTHOR = 'You',
    }
end    

-- [[OPTIONAL: DISPLAY CONFIG MENI]] --
function templateMod.settingsmenu()
    -- you can remove this if you dont want/need it
    G.SETTINGS.paused = true -- pause the game
    local configContent = {
        create_slider({label = "Test Setting",w = 4, h = 0.4, ref_table = getmodConfig(), ref_value = 'test_value', min = 0, max = 100}), -- new slider element
    }
    local backCode = ttttMODMANAGERUI_bfunc -- string for returning to mod menu, global
    local newUi = create_UIBox_generic_options{contents = configContent, back_func = backCode}
    G.FUNCS.overlay_menu{
        definition = newUi
    } -- create overlay menu
end    

-- [[CALLED WHEN THE MOD IS STARTED]] --
function templateMod.start()
    -- sorry if the framework is hard to use, i originally made this just for a balatro chaos mode
    local ismodenabled = true -- enable if you want this example stuff to work, not necessary to the modding manager/framework

    -- if you want to disable the config, delete the function or use this
    --templateMod.settingsmenu = nil

    print('Hello world!')

    -- the global module "balatromodmanager" has some important functions you will probably want to use
    -- examples:

   if ismodenabled then
        -- hooking into a function (in this case, creating a UI option/toggle)
        balatromodmanager:HookFunction(nil, "create_toggle", function(oldResult)
            -- make any modifications
            return oldResult
        end, 1) -- [optional] priority of hook, runs from lowest > highest

        -- connect to love.draw or love.update
        balatromodmanager:ConnectToUpdate(function(dt) -- also has :ConnectToDraw() for love.draw
            -- when love.update is fired
        end)
    end  
end    

return templateMod                                   
]=]                        
end    

balatromodmanager = {}
modmanager_saveSystem = {}
local love_filesystem = love.filesystem

local tableIds = setmetatable({}, { __mode = "k" }) 
local nextId = 0

local function getTableId(tbl)
    if not tableIds[tbl] then
        nextId = nextId + 1
        tableIds[tbl] = "T" .. tostring(nextId)
    end
    return tableIds[tbl]
end
local function buildHookKey(ref_table, func_name)
    local tableId = getTableId(ref_table)
    return tableId .. "." .. func_name
end

function balatromodmanager:ConnectToUpdate(fn)
    table.insert(updateFunctions, fn)
end
function balatromodmanager:ConnectToDraw(fn)
    table.insert(drawFunctions, fn)
end        

local hookfunctiondef = {}
function balatromodmanager:HookFunction(ref_table, func_value, new_hook, position)
    ref_table = ref_table or _G
    local key = buildHookKey(ref_table, func_value)
    
    if not hookfunctiondef[key] then
        hookfunctiondef[key] = {}
        local oldFunc = ref_table[func_value]
        ref_table[func_value] = function(...)
            local res = { oldFunc(...) }
            for _, v in pairs(hookfunctiondef[key]) do
                local new = v(unpack(res))
                if new ~= nil then
                    res[1] = new
                end
            end
            return unpack(res)    
        end    
    end
    
    if position then
        table.insert(hookfunctiondef[key], position, new_hook)
    else
        table.insert(hookfunctiondef[key], new_hook)
    end    
end 
local funcmodificationsdef = {}
function balatromodmanager:FunctionModification(ref_table, func_name, new_hook, position)
    ref_table = ref_table or _G
    local key = buildHookKey(ref_table, func_name)

    if not funcmodificationsdef[key] then
        funcmodificationsdef[key] = {}

        local oldFunc = ref_table[func_name]

        ref_table[func_name] = function(...)
            local args = { ... }

            local result = { oldFunc(unpack(args)) }

            for _, hook in ipairs(funcmodificationsdef[key]) do
                local hookResult = { hook(unpack(args)) }

                if #hookResult > 0 then
                    result = hookResult
                end
            end

            return unpack(result)
        end
    end

    if position then
        table.insert(funcmodificationsdef[key], position, new_hook)
    else
        table.insert(funcmodificationsdef[key], new_hook)
    end
end
local function directoryExists(path)
    local f = io.popen('cd "' .. path .. '" 2>nul && echo true')
    local result = f:read("*a")
    f:close()
    return result:match("true") ~= nil
end
local function openPath(relPath)
    local lfs = love.filesystem
    local saveDir = lfs.getSaveDirectory() .. relPath
    local sourceDir = love.filesystem.getSource() .. relPath
    local pathToOpen = nil

    print(saveDir,sourceDir)

    if directoryExists(saveDir) then
        pathToOpen = saveDir
    elseif directoryExists(sourceDir) then
        pathToOpen = sourceDir
    else
        print('no directory fnd')
        return
    end

    local osName = love.system.getOS()
    if osName == "Windows" then
        print('opening on windows')
        os.execute('start "" "' .. pathToOpen .. '"')
    elseif osName == "OS X" then
        os.execute('open "' .. pathToOpen .. '"')
    elseif osName == "Linux" then
        os.execute('xdg-open "' .. pathToOpen .. '"')
    end
end
function balatromodmanager.open_mod_directory()
    openPath("/MODMANAGER/mod")
end    

function balatromodmanager:DefineNewGFunction(name, func)
    if G.FUNCS[name] then
        local suffix = 1
        local unique_name = name .. "_" .. suffix

        while G.FUNCS[unique_name] do
            suffix = suffix + 1
            unique_name = name .. "_" .. suffix
        end

        G.FUNCS[unique_name] = func
        return unique_name
    else
        G.FUNCS[name] = func
        return name
    end   
end    

-- //// METHODS FOR SAVE SYSTEM //// --
local configsavedir = "MODMANAGER"
local configsavefilepath = (configsavedir and"/"or"").."CONFIGS.json"
local filepath = (configsavedir or "")..(configsavefilepath)
function modmanager_saveSystem.savemodgconfig()
    if not love.filesystem.getInfo(configsavedir, "directory") then
        love.filesystem.createDirectory(configsavedir)
    end    
    local JSONtosave = json.encode(G.MOD_CONFIGS, { indent = true})
    love.filesystem.write(filepath, JSONtosave)
end    
function modmanager_saveSystem.loadmodconfigs()
    if not love.filesystem.getInfo(configsavedir, "directory") then
        love.filesystem.createDirectory(configsavedir)
    end 
    if love.filesystem.getInfo(filepath, 'file') then
        local restored = love.filesystem.read(filepath)
        local data = json.decode(restored)
        if data then
            for k,v in pairs(G.MOD_CONFIGS) do
            if data[k] then
                for x,b in pairs(v) do
                    if data[k][x] then
                        v[x]=data[k][x]
                    end   
                end    
            end    
        end
    end        
    end    
end    

function balatromodmanager.LOAD_MODS()
    if modmanagerenabled == false then return end
    G.MOD_CONFIGS = {
        INTERNAL_DATA = {firsttimeusing = true}
    }
    G.MMLOADEDMODS = {}
    balatromodmanager.firstTimeUsingFunctions = {}

    updateFunctions = {}
    drawFunctions = {}

    G.FUNCS['balatromodmanager_openmoddir'] = balatromodmanager.open_mod_directory
    
    local oldUpdate = Game.update
    local oldDraw = Game.draw

    function Game:update(dt)
        oldUpdate(self,dt)
        for i,v in pairs(updateFunctions) do
            v(dt)
        end    
    end
    function Game:draw()
        oldDraw(self)
        for i,v in pairs(drawFunctions) do
            v()
        end    
    end        
    local function m_require(filepath)
        local r = love.filesystem.load(filepath)
        return r()
    end
    local function string_require(string)
        local v=load(string)
        return v()
    end    

    local mod_by_priority = {}

    balatromodmanager:DefineNewGFunction("balatromodmanager_savemodconfigs", function() 
        modmanager_saveSystem.savemodgconfig()
    end)

    print('booting mod loader?')
    local config = modmanagerconfig
    local directory_exists = love.filesystem.getInfo(config.mods_path, "directory") 
    local load_internal_mods = true
    if not directory_exists then
        love.filesystem.createDirectory(config.mods_path)    
    end    
    if load_internal_mods then
        local internalmods = {
            internal_MODMANAGERGUI = internal_strings['gui'],
            internal_LOCALIZATIONMODULE = internal_strings['local'],
           -- ['template-mod'] = require(config.internal_mod_path.."TEMPLATE")
        }
        for k,v in pairs(internalmods) do
            if type(v)=="string" then
                local mod = string_require(v)
                local startprio = mod.startpriority or 2
                mod_by_priority[startprio] = mod_by_priority[startprio] or {}
                table.insert(mod_by_priority[startprio], mod)
                G.MMLOADEDMODS[k]=mod
            end    
        end
    end    
    local template_mod = (internal_strings['temp'])
    if not love.filesystem.getInfo(config.mods_path.."/".."template-mod.lua", "file") then
        love.filesystem.write(config.mods_path.."/".."template-mod.lua", template_mod)
    end    
    if directory_exists then
        for _, fileName in ipairs(love_filesystem.getDirectoryItems(config.mods_path)) do
            if fileName:match("%.lua$") then
                local removeluaextension = false
                print('valid mod: ' .. fileName)
                local mod = m_require(config.mods_path .."/".. (removeluaextension and fileName:gsub('.lua', '') or fileName))
                local details = mod.getdetails and mod.getdetails()
                if details then
                    local modid = details.i_INTERNALMODID or "md_"..filename:gsub('.lua', '')
                   if G.MMLOADEDMODS[modid] then
                        print('DUPLICATE MOD FOUND')
                        break
                   else
                        G.MMLOADEDMODS[details.i_INTERNALMODID] = mod
                   end
                end
                if mod.start then
                    local priority = mod.startpriority or 2
                    mod_by_priority[priority] = mod_by_priority[priority] or {}
                    table.insert(mod_by_priority[priority], mod)
                end   
            else
                print('invalid mod file: ' .. fileName .. ' file is not a .LUA file')    
            end    
        end    
    end
    for i,mods in pairs(mod_by_priority) do
        for _,v in pairs(mods) do
            v.start()
        end    
    end
    
    modmanager_saveSystem.loadmodconfigs()
    if G.MOD_CONFIGS.INTERNAL_DATA.firsttimeusing then
        G.MOD_CONFIGS.INTERNAL_DATA.firsttimeusing = false
        modmanager_saveSystem.savemodgconfig()
        for k,v in pairs(balatromodmanager.firstTimeUsingFunctions) do
            v()
        end    
    end   
end    

print('HAIIIIIIIIIIII')

function InitBalatroModManager()
    balatromodmanager.LOAD_MODS()
end    

return balatromodmanager
local function usage()
    print("Usage: luajit lucTo.lua [input_file] <optional [output_file]>")
    print("")
    print("Options:")
    print("  --help     Print this message and exit")
    print("")
end

if not arg[1] then
    print("                                                                          ")
    print("        *******                 ======================================    ")
    print("      ***********                             LUC LANG                    ")
    print("    ***************            ======================================     ")
    print("   ******************               A Nice, Lite Syntax For Lua.          ")
    print("  ********************         --------------------------------------     ")
    print("   ******************          * Version 0.0.0-1 PreAlpha / Preview       ")
    print("    ****************           Right now, just a simple subsitution       ")
    print("      ************             based transpiler and/or general            ")
    print("        ********               proof of concept.                          ")
    print("                                                                          ")
    print("Run into any bugs and/or problems? https://github.com/jostgrant/luc/issues")
    print("Ideas, features reqs, or concerns? https://github.com/jostgrant/luc/issues")
    print("                                                                          ")


    usage()
    return
end

if arg[1] == "--help" then
    usage()
    return
end

local input_file = arg[1]
local output_file = arg[2]
if not output_file or output_file == "" then
    output_file = input_file:gsub('%.luc$', '') .. '.lua'
end

local input = io.open(input_file, "r")
local output = io.open(output_file, "w")


local transpile_line = function(line)
    -- Replace `||` comments with `--` comments for Lua             
    line = line:gsub("||", "--")

    -- Ignore subsitution rules in Lua comments
    if line:match("^%s*%-%-") then
        return line
    end

    -- Replace block comments with Lua block comments
    -- TODO We need to also ignore multi-lined block
    -- comments somehow.
    line = line:gsub("|%[", "--[[")
    line = line:gsub("%]|", "]]")

    -- Check for `::` operator and prepend "local function" to the identifier
    line = line:gsub("^(%s*)([%w_]+)%s*::%s*(.*)$", function(indent, func_name, func_params)
        return indent .. "local function " .. func_name .. func_params .. " "
    end)

    -- Check for `:;` operator and prepend global "function" to the identifier
    line = line:gsub("^(%s*)([%w_]+)%s*:;%s*(.*)$", function(indent, func_name, func_params)
        return indent .. "function " .. func_name .. func_params .. " "
    end)

    -- There HAS to be a better way to handle this / combine these three 
    -- idioms a bit. But this now works with all the increment, deincrement
    -- etc etc operands for both local and global vars. It's just ugly. lol

    -- Implement the increment, deincrement, multiple, divide & then assign 
    -- operators. To reduce the amount of `whatever = whatever + 1` Lua does.
    line = line:gsub("(%w+)%s*%+=%s*(.-)%s*$", "%1 = %1 + %2")
    line = line:gsub("(%w+)%s*%-=%s*(.-)%s*$", "%1 = %1 - %2")
    line = line:gsub("(%w+)%s*%/=%s*(.-)%s*$", "%1 = %1 / %2")
    line = line:gsub("(%w+)%s*%*=%s*(.-)%s*$", "%1 = %1 * %2")

    --line = line:gsub("(%w+)%s*%++%s*(.-)%s*$", "%1 = %1 + 1")
    --line = line:gsub("(%w+)%s*%--%s*(.-)%s*$", "%1 = %1 - 1")

    -- Replace `use module as var` with `local var = require('module')`
    line = line:gsub("%f[%a]use%f[%A]%s+(.-)%s+as%s+(%w+)", "local %2 = require('%1')")

    -- Replace `use module` with `require('module')`
    line = line:gsub("%f[%a]use%f[%A]%s+(.-)%s*$", "require('%1')")

    -- Replace `fun` with `local function`
    --line = line:gsub("%f[%a]fun%f[%A]", "local function")
    line = line:gsub("%f[%a]fun%f[%A]", "local function")

    -- Replace 'fug` with a global `function`
    line = line:gsub("%f[%a]fug%f[%A]", "function")

    -- Replace `&&` with `;`
    line = line:gsub("&&", ";")

    -- Replace `!=` with `~=`.
    line = line:gsub("!=", "~=")

    -- TODO Feed ;; and Me ,, operators.
    -- Getting close, but we want to remove newline of subbed
    -- out value and we want to make sure identation is preserved.

    --line = line:gsub("^%s*(.-)%s*;;%s*", function(s)
        --  var = s
        --  return ""
        --end):gsub("^([%s.]*)%s*,,%s*", var)

        return line
    end

    for line in input:lines() do
        output:write(transpile_line(line) .. "\n")
    end



    input:close()
    output:close()

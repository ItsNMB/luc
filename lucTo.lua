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
  line = line:gsub("(%w+)%s*%+=%:%s*(.-)%s*$", "local %1 = %1 + %2")
  line = line:gsub("(%w+)%s*%+=%;%s*(.-)%s*$", "%1 = %1 + %2")
  line = line:gsub("(%w+)%s*%+=%s*(.-)%s*$", "%1 = %1 + %2")

  line = line:gsub("(%w+)%s*%-=%:%s*(.-)%s*$", "local %1 = %1 - %2")
  line = line:gsub("(%w+)%s*%-=%;%s*(.-)%s*$", "%1 = %1 - %2")
  line = line:gsub("(%w+)%s*%-=%s*(.-)%s*$", "%1 = %1 - %2")

  line = line:gsub("(%w+)%s*%/=%:%s*(.-)%s*$", "local %1 = %1 / %2")
  line = line:gsub("(%w+)%s*%/=%;%s*(.-)%s*$", "%1 = %1 / %2")
  line = line:gsub("(%w+)%s*%/=%s*(.-)%s*$", "%1 = %1 / %2")

  line = line:gsub("(%w+)%s*%*=%:%s*(.-)%s*$", "local %1 = %1 * %2")
  line = line:gsub("(%w+)%s*%*=%;%s*(.-)%s*$", "%1 = %1 * %2")
  line = line:gsub("(%w+)%s*%*=%s*(.-)%s*$", "%1 = %1 * %2")
  
  -- Replace `use module as var` with `local var = require('module')`
  line = line:gsub("%f[%a]use%f[%A]%s+(.-)%s+as%s+(%w+)", "local %2 = require('%1')")

  -- Replace `use module` with `require('module')`
  line = line:gsub("%f[%a]use%f[%A]%s+(.-)%s*$", "require('%1')")

  -- Replace `fun` with `local function`
  --line = line:gsub("%f[%a]fun%f[%A]", "local function")
  line = line:gsub("%f[%a]fun%f[%A]", "local function")

  -- Replace 'fug` with a global `function`
  line = line:gsub("%f[%a]fug%f[%A]", "function")

  -- Replace `var` with `local`
  line = line:gsub("%f[%a]var%f[%A]", "local")

-- Add a shorthand declaration syntax for local variables.
  line = line:gsub("^([^=]-)%s*=:([^=]+)", function(s1, s2)
    local names = {}
    for name in s1:gmatch("%s*([^,%s]+)%s*") do
      table.insert(names, name)
    end
    -- Get the leading white space of the line
    local indent = line:match("^%s*")
    return indent .. "local " .. table.concat(names, ", ") .. " =" .. s2
  end)
  
  -- Replace `val` with no prefix, preserving indentation
  line = line:gsub("^%s*%f[%a]val%f[%A]%s*", function(s)
    return string.sub(s, 1, -5)
  end)

  -- Replace `=;` with `=`
  line = line:gsub("=;", "=")

  -- Replace `or` with `elseif`
  line = line:gsub("%f[%a]or%f[%A]", "elseif")

  -- Replace `loop` with `repeat`
  line = line:gsub("%f[%a]loop%f[%A]", "repeat")

  -- Replace `till` with `until`
  line = line:gsub("%f[%a]till%f[%A]", "until")

  -- Replace `when` with `while`
  line = line:gsub("%f[%a]when%f[%A]", "while")

  -- Replace `alt` with `or`
  line = line:gsub("%f[%a]alt%f[%A]", "or")

  -- Replace `&&` with `;`
  line = line:gsub("&&", ";")

  -- Replace `!=` with `~=`.
  line = line:gsub("!=", "~=")

  -- Replace `rt` with `return`
  line = line:gsub("%f[%a]rt%f[%A]", "return")

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

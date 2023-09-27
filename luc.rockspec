package = "luc"
version = "0.0-1"
source = {
   url = "https://github.com/jostgrant/luc"
}
description = {
   summary = "Transpile Luc Into Lua Code!",
   detailed = [[
      Luc is a light'er syntax for Lua.
      It attempts to stay fully compaitble with
      Lua by 'JUST' being a nicer surface-syntax.
   ]],
   homepage = "http://jostgrant.github.io/luc",
   license = "MIT"
}
dependencies = {
   "lua = 5.1"
   -- If you depend on other rocks, add them here
}
build = {
   -- We'll start here.
}

# The Luc Scripting-Language

Luc is (currently) a simple, subsitution based transpiler for Luajit-flavored Lua that provides a nicer surface-syntax while retaining as-close to the same semantics as possible.
The hope is to be able to use it for my game-scripting x Lovr & Love2D GameDev needs / wants and not feel as encumbered by some of syntax choices that feel a bit dated to me.

### What's Changed:

The following changes were made in Luc and spits out valid Lua.
- `||` instead of `--` for comments.
    - Closer to the more common `//` in other langs.
    - Looks cleaner when you have multiple lines stacked.
- `|[` and `]|` instead of `--[[ ]]` for block comments.
    - Note: Haven't figured out how to skip transpiling on multiple lines. See known issues.
- `fun` instead of `local function`.
    - This should encourage the use of local functions by default.
- `::` as a shorthand assignment operator for local functions.
    - Inspired by Odin & Jai. Pairs nicer with our shorthand varible assignment.
- `fug` instead of global function.
    - This should discourage using global functions; As it's fugly.
- `:;` as a shorthand assignment operator for global functions.
   - Like =; (see below) it's slightly ugly enough to discourage regular use.
   - Considerations for the feed and me operators need to be made now, so the syntax is not so similar. 
- `var` is now for `local` variable assignment.
    - Lua softy encourages variables to be global by default.
    - We want to fix this by making things explicit by default.
- `=:` is a shorthand assignment operator for local vars.
- `val` is now for global 'no prefix' variable assingment.
    - Certain values need to be 'shared globally'.
- `=;` is a shorthand assignment operator for global vars.
- `loop` and `till` instead of `repeat` and `until`.
    - Same character count in both / which gives it the same identation level.
- `when` instead of `while`
    - Slightly shorter / nicer; Either are usable.
- `or` with `elseif`
    - This is more controversial.
    - This may end up as an elif ultimately but like the same level of identation.
    - And I think the 'or' as a logic operator is a bit more clunky. See next.
- `alt` instead of `or`
    - 'Alternatively' do this. 
    - Goes nicely with the other postive logic operator, `and`. Alt & And.
    - Which clearly polarizes `not`.
- `&&` replaces `;` 
    - More standard to string together multiple statements.
    - More visually distinct / easier to spot. 
    - Don't get as many false first-glances because a single `:` is so common in Lua.
- `+=`, `-=`, `/=`& `*=` operators. 
    - We don't have to repeat ourselves so much by going 'whatever = whatever + 1'.
    - Pretty standard operators to have tbh.
    - Implementation needs a bit of work... (but it does seem to work).
- `!=` replaces `~=`
    - A lot more standard not-equal operand.
    - More distinct from -= 
-  `rt` with `return`
    - rt is a common shorthand online.
    - the keys are right next to eachother on qwerty, and only one away on colemak.
-  `use` instead of require. 
    - `as` as a shorthand to define a local var to give it a name.

#### Things I Want, But Never Got To.
- Ignore transpiling if it's in a line that starts in a comments.
- Figure a way to only match keywords and operators. Super naive implementation right-now.
- A `fin` keyword, that would give us optional significant identation.
    - Would autoresolves end keywords in the level of identation of the block it matches.
    - Would by effect make all nested `end` keywords optional.
- Add a feed `;;` (?) and me `,,` (?) operator to do subsitution in our code.

#### What I Was Considering, If I Could've Done It Relatively Cleanly.
- An `obj` system that basically just makes metatable class-like defs easier. And extending there as-well.
- A macro-adjacent system using tables. rn called `mut` like mutable and mutating.
- Optional type-system.
- Make a `spc` namespacing system?
- See if we can plug into the notable Lua lsp.

#### We'd probably of needed to :
- Write a formatter. Don't know a reasonable way around this, for the `fin` keyword.

### Things that were on my radar of what I needed to do:
- Write a Luc VScode and lite-xl highlighting plugin.
- Write a chroma highlighter for our site.
- Add freaking tests to make sure it's spitting out valid lua.

### Known Issues:
- This is an extremely naive implementation. Ultimately this will probably rewritten as a tokenizer and lpeg parser.
     - It just so happens, the semantics of Luc is so close to Lua, using gsub ends up getting you pretty dang far. lol
     - But this can cause issues because we are just  L
- Variables that use one of the new reserved keywords, can not have an underscore and transpile cleanly.
    - Say you want to do something like `var loop_whatever = true` would transpile as `repeat_whatever = true`.
    - In-practice this isn't a huge deal in most cases, but stuff like if you ever tried to use `fun` similary for whatever reason, it'd be way more of a problem.
        - Namely, because the resulting would be something like `local function whatever = true`, which is invalid syntax in Lua, obviously.
- Block Comments don't skip transpiling like we do for single lined comments yet.
    - This is important, because of related issues from the top-level bullet above it.
        - Wherein, the transpiled code might translate common enough words like `till` into until. Or `fun` into `local function`. 
	- This shouldn't actually break anything in-practice, but needs to be fixed obviously.

### How to use it:
```shell
# To convert it from luc to lua.
luajit lucTo.lua <input.luc> <output.lua>
```
```shell
# To run the outputted lua file.
luajit <output.lua>
```

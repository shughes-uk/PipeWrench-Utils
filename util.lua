-- MIT License
-- 
-- Copyright (c) 2022 JabDoesThings
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local SyncCallback = function()
    local o = {}
    o.callbacks = {}
    o.add = function(callback) table.insert(o.callbacks, callback) end
    o.tick = function()
        if #o.callbacks > 0 then
            for i = 1, #o.callbacks, 1 do o.callbacks[i]() end
            o.callbacks = {}
        end
    end
    Events.OnFETick.Add(o.tick)
    Events.OnTickEvenPaused.Add(o.tick)
    return o
end

---@param target string The target method fullpath
---@param hook function The hook function to apply to that method
local hookInto = function(splits, hook)
  if type(hook) ~= "function" then error("Hook 'hook' param must be a function."); end
  print(("Hooking into " .. splits) .. "...")
  local target = table.concat(splits,".")
  local original = _G[target[1]]
  do
      local i = 1
      while i < #splits do
            if original and original[splits[i + 1]] then
                if i == #splits - 1 then
                    if type(original[splits[i + 1]]) ~= "function" then
                        error(("Invalid hook target '" .. target) .. "' is not a function!")
                    end
                    local originalFunc = original[splits[i + 1]]
                    original[splits[i + 1]] = function(____self, ...)
                        return hook(originalFunc, ____self, ...)
                    end
                    print("Hooked into " .. target)
                end
                original = original[splits[i + 1]]
            else
                error(("Invalid hook target '" .. target) .. "' is not found!")
            end
            i = i + 1
      end
  end
end

local Exports = {}
Exports._syncCallback = SyncCallback()
Exports._hookInto = hookInto
function Exports._isPipeWrenchLoaded() return _G.PIPEWRENCH_READY ~= nil end
return Exports

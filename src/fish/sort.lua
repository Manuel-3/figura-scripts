local Task = require("./task")

---Async heap sort utilizing task.lua
---@param t table
---@param compare fun(a:any,b:any):boolean
---@param callback fun(t: table)
local function heapsort(t, compare, callback)

  --- Restores the heap property for the subtree rooted at `root`
  --- Assumes the left and right subtrees are already valid heaps
  local function heapify(size, root)
    local largest = root
    local left = root * 2
    local right = left + 1

    -- Find highest-priority node among root and its children
    if left <= size and compare(t[largest], t[left]) then
      largest = left
    end

    if right <= size and compare(t[largest], t[right]) then
      largest = right
    end

    -- Continuously push the root value down until the heap property
    -- is satisfied for the entire subtree
    Task.While(function()return largest ~= root end, function ()
      t[root], t[largest] = t[largest], t[root]
      root = largest

      largest = root
      left = root * 2
      right = left + 1

      if left <= size and compare(t[largest], t[left]) then
        largest = left
      end

      if right <= size and compare(t[largest], t[right]) then
        largest = right
      end
    end)
  end

  -- Build heap
  -- Only non-leaf nodes need heapifying, so we start at floor(n / 2)
  -- and work backwards toward the root
  local n = #t
  local start = math.floor(n / 2)
  Task(0,start-1,function(i)
    local j = start-i
    heapify(n, j)
  end,function()
    -- Extract elements
    Task(0,n-2,function(i)
      local j = n-i
      -- Move current highest-priority to sorted position
      t[1], t[j] = t[j], t[1]
      -- Restore heap property for remaining stuff
      heapify(j - 1, 1)
    end,function()
      callback(t)
    end)
  end)
end

return heapsort
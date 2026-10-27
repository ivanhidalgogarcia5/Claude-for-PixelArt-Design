-- Builds one tagged .aseprite from a sprite's src folder.
-- palette.txt holds "K=rrggbb" lines; every other <anim>.txt becomes tag <anim>, with "---- <ms>" before each frame's rows. "." is transparent.
-- Every frame of every animation must share one canvas size, so the build fails on any mismatch.
-- Usage: aseprite -b --script-param dir=<src folder> --script-param out=<file.aseprite> --script grid_to_aseprite.lua
local fs, p = app.fs, app.params

local function lines(path)
  local t = {}
  for line in io.lines(path) do
    line = line:gsub("\r$", "")
    if #line > 0 then t[#t + 1] = line end
  end
  return t
end

local pal = {}
for _, line in ipairs(lines(fs.joinPath(p.dir, "palette.txt"))) do
  local k, hex = line:match("^(%S)=(%x%x%x%x%x%x)$")
  assert(k, "bad palette line: " .. line)
  pal[k] = Color{ r = tonumber(hex:sub(1, 2), 16), g = tonumber(hex:sub(3, 4), 16), b = tonumber(hex:sub(5, 6), 16), a = 255 }
end

local frames, tags = {}, {}
local names = fs.listFiles(p.dir)
table.sort(names)
for _, name in ipairs(names) do
  if name ~= "palette.txt" and fs.fileExtension(name) == "txt" then
    local first = #frames + 1
    for _, line in ipairs(lines(fs.joinPath(p.dir, name))) do
      local dur = line:match("^%-%-%-%- (%d+)$")
      if dur then
        frames[#frames + 1] = { dur = tonumber(dur), rows = {}, label = name .. " frame " .. (#frames + 2 - first) }
      else
        assert(#frames >= first, name .. ": rows before the first '---- <ms>' line")
        table.insert(frames[#frames].rows, line)
      end
    end
    tags[#tags + 1] = { name = fs.fileTitle(name), from = first, to = #frames }
  end
end

local w, h = #frames[1].rows[1], #frames[1].rows
for _, f in ipairs(frames) do
  assert(#f.rows == h, f.label .. " is " .. #f.rows .. " rows tall, expected " .. h)
  for _, r in ipairs(f.rows) do
    assert(#r == w, f.label .. " row is " .. #r .. " wide, expected " .. w .. ": " .. r)
    for c in r:gmatch(".") do assert(c == "." or pal[c], f.label .. ": unknown color key '" .. c .. "'") end
  end
end

local spr = Sprite(w, h, ColorMode.RGB)
for _ = 2, #frames do spr:newEmptyFrame() end
for i, f in ipairs(frames) do
  spr.frames[i].duration = f.dur / 1000
  local img = Image(w, h, ColorMode.RGB)
  for y, r in ipairs(f.rows) do
    for x = 1, w do
      local c = pal[r:sub(x, x)]
      if c then img:drawPixel(x - 1, y - 1, c) end
    end
  end
  spr:newCel(spr.layers[1], i, img, Point(0, 0))
end
for _, t in ipairs(tags) do spr:newTag(t.from, t.to).name = t.name end
spr:saveAs(p.out)

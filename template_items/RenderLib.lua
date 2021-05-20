local renderer = {}

local function GetScreenSize() -- By Kilburn himself.
  local room = Game():GetRoom()
  local pos = Isaac.WorldToScreen(Vector(0, 0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

  local rx = pos.X + 60 * 26 / 40
  local ry = pos.Y + 140 * (26 / 40)

  return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

renderer.posx, renderer.posy = GetScreenSize()

function renderer.Load(self, ImagePath, LoadGraphic)
  LoadGraphic = LoadGraphic or true
  ImagePath = ImagePath:match("/") and ImagePath or "gfx/ui/" .. ImagePath
  ImagePath = ImagePath .. ".anm2"
  local sprite = Sprite()
  sprite:Load(ImagePath, LoadGraphic)

  return sprite
end

function renderer.SmartRender(self, sprite, ScreenSpace, TopLeftClamp, BottomRightClamp)
  TopLeftClamp = TopLeftClamp or Vector.Zero
  BottomRightClamp = BottomRightClamp or Vector.Zero
  ScreenSpace = ScreenSpace or Vector(0.5, 0.5)

  sprite:Render(Vector(renderer.posx * ScreenSpace.X, renderer.posy * ScreenSpace.Y), TopLeftClamp, BottomRightClamp)
end

return renderer

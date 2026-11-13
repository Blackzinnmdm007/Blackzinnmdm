
-- BLACKZINNMDM V3 ATUALIZADO
-- Interface vermelha e preta

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local P = Players.LocalPlayer
local PG = P:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("Blackzinnmdm")
if old then old:Destroy() end

local G = Instance.new("ScreenGui")
G.Name = "Blackzinnmdm"
G.ResetOnSpawn = false
G.Parent = PG

local RED = Color3.fromRGB(255,25,25)
local DARK = Color3.fromRGB(13,2,4)
local WHITE = Color3.new(1,1,1)
local saved = {}

local function round(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = obj
end

local function border(obj,n)
    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = n or 2
    s.Parent = obj
    return s
end

local function frame(parent,size,pos,color)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    f.Parent = parent
    round(f,12)
    border(f,2)
    return f
end

local function label(parent,str,size,pos,color)
    local t = Instance.new("TextLabel")
    t.Size = size
    t.Position = pos
    t.BackgroundTransparency = 1
    t.Text = str
    t.TextColor3 = color
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = parent
    return t
end

local function button(parent,str,size,pos)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = DARK
    b.Text = str
    b.TextColor3 = WHITE
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    round(b,10)
    border(b,2)
    return b
end

-- PAINEL PRINCIPAL
local panel = frame(G,
    UDim2.fromOffset(310,245),
    UDim2.new(.5,-155,.5,-122),
    DARK)

-- EFEITO NEON
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1,8,1,8)
glow.Position = UDim2.fromOffset(-4,-4)
glow.BackgroundColor3 = RED
glow.BackgroundTransparency = .88
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = panel
round(glow,15)

local gs = border(glow,5)
gs.Transparency = .55

-- TITULO
local title = label(panel,"BLACKZINNMDM",
    UDim2.new(1,-60,0,39),
    UDim2.fromOffset(12,7),
    WHITE)

local close = button(panel,"X",
    UDim2.fromOffset(35,35),
    UDim2.new(1,-43,0,8))

local subtitle = label(panel,"TELEPORTE",
    UDim2.new(1,0,0,28),
    UDim2.fromOffset(0,53),
    RED)

local line = Instance.new("Frame")
line.Size = UDim2.new(.86,0,0,2)
line.Position = UDim2.new(.07,0,0,88)
line.BackgroundColor3 = RED
line.BorderSizePixel = 0
line.Parent = panel

-- BOTOES DE TELEPORTE
local b1 = button(panel,"Spawn 1",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(12,103))

local b2 = button(panel,"Tp 1",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(163,103))

local b3 = button(panel,"Spawn 2",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(12,164))

local b4 = button(panel,"Tp 2",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(163,164))

-- ICONE B FLUTUANTE
-- LADO ESQUERDO, MAIS PARA CIMA
local icon = button(G,"B",
    UDim2.fromOffset(55,55),
    UDim2.new(0,15,0.30,0))

icon.TextScaled = false
icon.TextSize = 32
icon.ZIndex = 10
icon.Active = true

-- ARRASTAR COM O DEDO
local function drag(obj,handle,onTap)
    local active, start, original, moved
    local mouseDrag = false

    handle.Active = true

    handle.InputBegan:Connect(function(input)
        local typ = input.UserInputType

        if typ ~= Enum.UserInputType.Touch
        and typ ~= Enum.UserInputType.MouseButton1 then
            return
        end

        active = input
        mouseDrag = typ ==
            Enum.UserInputType.MouseButton1

        start = input.Position
        original = obj.Position
        moved = false
    end)

    UIS.InputChanged:Connect(function(input)
        if not active then return end

        if mouseDrag then
            if input.UserInputType ~=
            Enum.UserInputType.MouseMovement then
                return
            end
        elseif input ~= active then
            return
        end

        local delta = input.Position - start

        if delta.Magnitude > 8 then
            moved = true
        end

        if moved then
            obj.Position = UDim2.new(
                original.X.Scale,
                original.X.Offset + delta.X,
                original.Y.Scale,
                original.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if not active then return end

        if input == active or
        (mouseDrag and input.UserInputType ==
        Enum.UserInputType.MouseButton1) then
            active = nil

            if onTap and not moved then
                onTap()
            end
        end
    end)
end

drag(panel,title)

drag(icon,icon,function()
    panel.Visible = not panel.Visible
end)

close.Activated:Connect(function()
    panel.Visible = false
end)

-- AUMENTAR E DIMINUIR PAINEL
local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = panel

local resize = button(panel,"+",
    UDim2.fromOffset(30,30),
    UDim2.new(1,-36,1,-36))

resize.ZIndex = 5

local resizing = nil
local mouseResize = false
local startX, startScale

resize.InputBegan:Connect(function(input)
    local typ = input.UserInputType

    if typ == Enum.UserInputType.Touch
    or typ == Enum.UserInputType.MouseButton1 then
        resizing = input
        mouseResize = typ ==
            Enum.UserInputType.MouseButton1
        startX = input.Position.X
        startScale = scale.Scale
    end
end)

UIS.InputChanged:Connect(function(input)
    if not resizing then return end

    if mouseResize then
        if input.UserInputType ~=
        Enum.UserInputType.MouseMovement then
            return
        end
    elseif input ~= resizing then
        return
    end

    local delta = input.Position.X - startX

    scale.Scale = math.clamp(
        startScale + delta/300,
        .55,1.5
    )
end)

UIS.InputEnded:Connect(function(input)
    if resizing and
    (input == resizing or
    (mouseResize and input.UserInputType ==
    Enum.UserInputType.MouseButton1)) then
        resizing = nil
    end
end)

-- SISTEMA DE TELEPORTE
local function root()
    local char = P.Character
    return char and
        char:FindFirstChild("HumanoidRootPart")
end

local function save(n)
    local r = root()
    if r then
        saved[n] = r.CFrame
    end
end

local function tp(n)
    local r = root()
    if r and saved[n] then
        r.CFrame = saved[n]
    end
end

b1.Activated:Connect(function()
    save(1)
end)

b2.Activated:Connect(function()
    tp(1)
end)

b3.Activated:Connect(function()
    save(2)
end)

b4.Activated:Connect(function()
    tp(2)
end)

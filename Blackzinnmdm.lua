
-- BLACKZINNMDM V3
-- Painel vermelho e azul para Roblox

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local P = Players.LocalPlayer
local PG = P:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("Blackzinnmdm")
if old then old:Destroy() end

local G = Instance.new("ScreenGui")
G.Name = "Blackzinnmdm"
G.ResetOnSpawn = false
G.IgnoreGuiInset = false
G.Parent = PG

local BLUE = Color3.fromRGB(255,25,25)
local DARK = Color3.fromRGB(13,2,4)
local WHITE = Color3.fromRGB(255,255,255)
local saved = {}
local connections = {}

local function connect(signal,fn)
    local c = signal:Connect(fn)
    table.insert(connections,c)
    return c
end

local function round(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = obj
end

local function border(obj,thickness)
    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = thickness or 2
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

local function text(parent,str,size,pos,color)
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
    b.AutoButtonColor = true
    b.Parent = parent
    round(b,10)
    border(b,2)
    return b
end

-- Painel principal
local panel = frame(G,
    UDim2.fromOffset(310,245),
    UDim2.new(.5,-155,.5,-122),
    DARK)

-- Brilho neon decorativo
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1,8,1,8)
glow.Position = UDim2.fromOffset(-4,-4)
glow.BackgroundColor3 =RBLUE
glow.BackgroundTransparency = .88
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = panel
round(glow,15)

local gs = border(glow,5)
gs.Transparency = .55

local title = text(panel,"BLACKZINNMDM",
    UDim2.new(1,-60,0,39),
    UDim2.fromOffset(12,7),
    WHITE)
title.ZIndex = 2

local close = button(panel,"X",
    UDim2.fromOffset(35,35),
    UDim2.new(1,-43,0,8))
close.ZIndex = 3

local subtitle = text(panel,"TELEPORTE",
    UDim2.new(1,0,0,28),
    UDim2.fromOffset(0,53),
    RED)

local line = Instance.new("Frame")
line.Size = UDim2.new(.86,0,0,2)
line.Position = UDim2.new(.07,0,0,88)
line.BackgroundColor3 = RED
line.BorderSizePixel = 0
line.Parent = panel

-- Botões
local b1 = button(panel,"SPAWN 1",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(12,103))

local b2 = button(panel,"TP 1",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(163,103))

local b3 = button(panel,"SPAWN 2",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(12,164))

local b4 = button(panel,"TP 2",
    UDim2.fromOffset(135,48),
    UDim2.fromOffset(163,164))

-- Ícone B flutuante
local icon = button(G,"B",
    UDim2.fromOffset(55,55),
    UDim2.new(0,20,.5,-27))

icon.TextScaled = false
icon.TextSize = 32
icon.ZIndex = 10

-- Movimentação com um dedo
local function drag(obj,handle,onTap)
    local active, start, original, moved
    local mouseDrag = false

    handle.Active = true

    connect(handle.InputBegan,function(input)
        local typ = input.UserInputType
        if typ ~= Enum.UserInputType.Touch
        and typ ~= Enum.UserInputType.MouseButton1 then
            return
        end

        active = input
        mouseDrag = typ == Enum.UserInputType.MouseButton1
        start = input.Position
        original = obj.Position
        moved = false
    end)

    connect(UIS.InputChanged,function(input)
        if not active then return end

        if mouseDrag then
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then
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

    connect(UIS.InputEnded,function(input)
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

connect(close.Activated,function()
    panel.Visible = false
end)

-- Aumentar e diminuir com o dedo
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

connect(resize.InputBegan,function(input)
    local typ = input.UserInputType
    if typ == Enum.UserInputType.Touch
    or typ == Enum.UserInputType.MouseButton1 then
        resizing = input
        mouseResize = typ == Enum.UserInputType.MouseButton1
        startX = input.Position.X
        startScale = scale.Scale
    end
end)

connect(UIS.InputChanged,function(input)
    if not resizing then return end

    if mouseResize then
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
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

connect(UIS.InputEnded,function(input)
    if resizing and
    (input == resizing or
    (mouseResize and input.UserInputType ==
    Enum.UserInputType.MouseButton1)) then
        resizing = nil
    end
end)

-- Salvar posições e teletransportar
local function root()
    local char = P.Character
    return char and char:FindFirstChild("HumanoidRootPart")
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

connect(b1.Activated,function() save(1) end)
connect(b2.Activated,function() tp(1) end)
connect(b3.Activated,function() save(2) end)
connect(b4.Activated,function() tp(2) end)

-- Limpeza ao remover a interface
connect(G.Destroying,function()
    for _,c in ipairs(connections) do
        c:Disconnect()
    end
end)
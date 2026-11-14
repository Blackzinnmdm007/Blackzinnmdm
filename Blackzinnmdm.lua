
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ws = game:GetService("Workspace")
local pg = player:WaitForChild("PlayerGui")

-- Remove painel anterior
local antigo = pg:FindFirstChild("EggFarmGUI")
if antigo then antigo:Destroy() end

local base = nil
local ativo = false
local secret = true
local divine = true
local ocupado = false
local ignorados = {}

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "EggFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 335)
frame.Position = UDim2.new(.5,-130,.3,0)
frame.BackgroundColor3 = Color3.fromRGB(18,20,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius =
    UDim.new(0,12)

local function criarTexto(texto,y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-16,0,30)
    l.Position = UDim2.fromOffset(8,y)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 15
    l.Font = Enum.Font.GothamBold
    l.Text = texto
    l.Parent = frame
    return l
end

criarTexto("EGG AUTO FARM",8)
local status = criarTexto("Status: Desligado",292)

local function botao(texto,y,funcao)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,42)
    b.Position = UDim2.fromOffset(10,y)
    b.BackgroundColor3 = Color3.fromRGB(30,100,225)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.Text = texto
    b.Parent = frame

    Instance.new("UICorner",b).CornerRadius =
        UDim.new(0,8)

    b.MouseButton1Click:Connect(function()
        funcao(b)
    end)
end

local function root()
    local char = player.Character
    return char and
        char:FindFirstChild("HumanoidRootPart")
end

local function tpBase()
    local r = root()
    if r and base then
        r.CFrame = base
        return true
    end
    return false
end

-- Botões

botao("Salvar Base",42,function(b)
    local r = root()
    if r then
        base = r.CFrame
        b.Text = "Base Salva!"
        status.Text = "Status: Base registrada"
    end
end)

botao("Secret: ON",90,function(b)
    secret = not secret
    b.Text = "Secret: " ..
        (secret and "ON" or "OFF")
end)

botao("Divine: ON",138,function(b)
    divine = not divine
    b.Text = "Divine: " ..
        (divine and "ON" or "OFF")
end)

botao("Auto Farm: OFF",186,function(b)
    if not ativo and not base then
        status.Text = "Salve a base primeiro!"
        return
    end

    ativo = not ativo
    b.Text = "Auto Farm: " ..
        (ativo and "ON" or "OFF")

    status.Text = ativo
        and "Status: Procurando ovos"
        or "Status: Desligado"
end)

botao("TP Base",234,function()
    if not tpBase() then
        status.Text = "Base não salva!"
    end
end)

-- Filtro de raridade

local function raridadeValida(texto)
    texto = texto:lower()

    return
        (secret and texto:find(
            "secret",1,true
        ) ~= nil)
        or
        (divine and texto:find(
            "divine",1,true
        ) ~= nil)
end

-- Ignorar ovos chocando

local palavrasChocando = {
    "hatch",
    "hatching",
    "incubat",
    "chocando",
    "chocadeira",
    "eclosao",
    "eclosão"
}

local function ovoChocando(obj)
    local atual = obj

    for i = 1,5 do
        if not atual or atual == ws then
            break
        end

        local textos = {atual.Name}

        for _,filho in ipairs(
            atual:GetDescendants()
        ) do
            if filho:IsA("TextLabel") then
                table.insert(textos,filho.Text)
            end
        end

        for _,texto in ipairs(textos) do
            texto = tostring(texto):lower()

            for _,palavra in ipairs(
                palavrasChocando
            ) do
                if texto:find(
                    palavra,1,true
                ) then
                    return true
                end
            end
        end

        atual = atual.Parent
    end

    return false
end

-- Encontrar interação de coleta

local function procurarPrompt(part)
    local atual = part

    for i = 1,4 do
        if not atual or atual == ws then
            break
        end

        for _,obj in ipairs(
            atual:GetDescendants()
        ) do
            if obj:IsA("ProximityPrompt") then
                local texto = (
                    obj.ActionText .. " " ..
                    obj.ObjectText
                ):lower()

                if texto:find("ovo",1,true)
                    or texto:find("egg",1,true) then
                    return obj
                end
            end
        end

        atual = atual.Parent
    end

    return nil
end

-- Localizar parte física do ovo

local function obterParte(gui)
    local part = gui.Adornee

    if part and part:IsA("BasePart") then
        return part
    end

    local parent = gui.Parent

    if parent:IsA("BasePart") then
        return parent
    end

    if parent:IsA("Model") then
        return parent.PrimaryPart
            or parent:FindFirstChildWhichIsA(
                "BasePart",true)
    end

    return nil
end

-- Procurar somente ovos

local function procurarOvo()
    local r = root()
    if not r then return nil end

    local melhor = nil
    local menorDistancia = math.huge

    for _,obj in ipairs(
        ws:GetDescendants()
    ) do
        if obj:IsA("BillboardGui") then

            local texto = ""

            for _,filho in ipairs(
                obj:GetDescendants()
            ) do
                if filho:IsA("TextLabel") then
                    texto = texto .. " " .. filho.Text
                end
            end

            local lower = texto:lower()

            local ehOvo =
                lower:find("ovo",1,true)
                or lower:find("egg",1,true)

            if ehOvo
                and raridadeValida(texto)
                and not ovoChocando(obj) then

                local part = obterParte(obj)

                if part
                    and not ovoChocando(part)
                    and not ignorados[part] then

                    local prompt = procurarPrompt(part)

                    if prompt then
                        local distancia =
                            (r.Position-part.Position).Magnitude

                        if distancia < menorDistancia then
                            menorDistancia = distancia
                            melhor = {
                                parte = part,
                                prompt = prompt
                            }
                        end
                    end
                end
            end
        end
    end

    return melhor
end

-- Coletar ovo e retornar

local function coletar(ovo)
    local r = root()
    if not r or not ativo then return end

    local part = ovo.parte
    local prompt = ovo.prompt

    if not part.Parent
        or not prompt.Parent
        or ovoChocando(part) then
        return
    end

    status.Text = "Status: Indo ao ovo"

    r.CFrame = part.CFrame *
        CFrame.new(0,3,0)

    task.wait(0.4)

    if not ativo then return end

    if not fireproximityprompt then
        status.Text = "Coleta não suportada"
        ignorados[part] = os.clock() + 10
        return
    end

    status.Text = "Status: Tentando coletar"

    local ok = pcall(function()
        fireproximityprompt(prompt)
    end)

    if not ok then
        status.Text = "Falha na interação"
        ignorados[part] = os.clock() + 10
        return
    end

    -- Aguarda possível coleta
    local inicio = os.clock()

    while ativo and os.clock()-inicio < 2 do
        if not prompt.Parent
            or not prompt.Enabled then
            break
        end
        task.wait(0.1)
    end

    if not ativo then return end

    -- Evita repetir o mesmo ovo imediatamente
    ignorados[part] = os.clock() + 8

    status.Text = "Status: Voltando à base"
    tpBase()

    task.wait(1.5)
end

-- Loop automático

task.spawn(function()
    while gui.Parent do
        task.wait(0.4)

        if ativo and not ocupado then
            ocupado = true

            -- Limpar bloqueios expirados
            for part,tempo in pairs(ignorados) do
                if os.clock() >= tempo
                    or not part.Parent then
                    ignorados[part] = nil
                end
            end

            local ovo = procurarOvo()

            if ovo then
                local ok,err = pcall(function()
                    coletar(ovo)
                end)

                if not ok then
                    warn("Auto Farm:",err)
                    status.Text = "Erro no Auto Farm"
                end
            else
                status.Text =
                    "Procurando ovos Secret/Divine"
                task.wait(1)
            end

            ocupado = false
        end
    end
end)

--============================================================
--  ESP HUB MOBILE — DELTA FINAL v5
--  Меню по центру, горизонтальное, адаптивное
--  Боты в ESP, FOV от центра, рабочий колорпикер
--============================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--========== CONFIG ==========
local Config = {
    Visual = { Enabled=false, Box=true, Skeleton=true, Tracer=true, Chams=true, Names=true, HP=true, Distance=true, Bots=true },
    Colors = {
        Box=Color3.fromRGB(255,255,255), Skeleton=Color3.fromRGB(255,255,255),
        Tracer=Color3.fromRGB(255,60,60), Chams=Color3.fromRGB(120,0,255),
        HP=Color3.fromRGB(90,220,140), HP_Back=Color3.fromRGB(30,30,40),
        Name=Color3.fromRGB(255,255,255), Distance=Color3.fromRGB(200,200,210),
        Bot=Color3.fromRGB(255,165,0),
        RGB=false,
    },
    Aimbot = { Enabled=false, FOV=120, Smooth=0.35, Part="Head", Mode="Camera", Key=nil, VisibleCheck=false, Priority="Distance", ShowFOV=true, FOVColor=Color3.fromRGB(255,255,255), FOVThickness=1, FOVTransparency=0.6, FOVFilled=false },
    Silent = { Enabled=false, FOV=120, Part="Head", VisibleCheck=false, Priority="Distance", HitboxRandom=false, ShowFOV=true, FOVColor=Color3.fromRGB(130,90,255), FOVThickness=1, FOVTransparency=0.6, FOVFilled=false, Delay=0 },
    Trigger = { Enabled=false, FOV=25, Part="Head", VisibleCheck=true, Delay=80, Key=nil, ShowFOV=true, FOVColor=Color3.fromRGB(255,80,80), FOVThickness=1, FOVTransparency=0.6, FOVFilled=false },
    Settings = { FABX=20, FABY=120 },
}

--========== THEME ==========
local Theme = {
    Bg=Color3.fromRGB(14,14,18), Bg2=Color3.fromRGB(20,20,26),
    Panel=Color3.fromRGB(26,26,33), Panel2=Color3.fromRGB(32,32,40),
    Stroke=Color3.fromRGB(48,48,60), Accent=Color3.fromRGB(130,90,255),
    Accent2=Color3.fromRGB(80,200,255), Text=Color3.fromRGB(235,235,245),
    TextDim=Color3.fromRGB(140,140,155), Danger=Color3.fromRGB(220,70,90),
}

--========== UTILS ==========
local function new(c,p,parent) local o=Instance.new(c); for k,v in pairs(p or {}) do o[k]=v end; if parent then o.Parent=parent end; return o end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c or Theme.Stroke,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function padding(p,a) return new("UIPadding",{PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,a),PaddingLeft=UDim.new(0,a),PaddingRight=UDim.new(0,a)},p) end
local function tween(o,t,p,s,d) return TweenService:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p) end

--========== CONFIG SAVE ==========
local CONFIG_PATH = "Delta_ESP_Config.json"
local function saveConfig()
    if not writefile then return end
    pcall(function()
        local data = {}
        for k,v in pairs(Config) do
            if type(v)=="table" then
                data[k]={}
                for k2,v2 in pairs(v) do
                    if type(v2)=="Color3" then data[k][k2]="C:"..v2.R..","..v2.G..","..v2.B
                    elseif type(v2)=="boolean" or type(v2)=="number" or type(v2)=="string" then data[k][k2]=v2 end
                end
            end
        end
        writefile(CONFIG_PATH, game:GetService("HttpService"):JSONEncode(data))
    end)
end

--========== GUI ==========
if CoreGui:FindFirstChild("Delta_ESP_Hub") then CoreGui.Delta_ESP_Hub:Destroy() end
local gui = new("ScreenGui",{Name="Delta_ESP_Hub",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},CoreGui)

--========== АДАПТИВ ==========
local function getMenuSize()
    local vp = Camera.ViewportSize
    local w = math.clamp(vp.X * 0.92, 320, 640)
    local h = math.clamp(vp.Y * 0.78, 260, 440)
    return w, h
end
local MENU_W, MENU_H = getMenuSize()
local SIDEBAR_W = math.clamp(MENU_W * 0.22, 100, 140)

--========== FAB ==========
local FAB_SIZE = 54
local fab = new("TextButton",{
    Name="FAB", Size=UDim2.new(0,FAB_SIZE,0,FAB_SIZE),
    Position=UDim2.new(0,Config.Settings.FABX,0,Config.Settings.FABY),
    BackgroundColor3=Theme.Accent, Text="E",
    Font=Enum.Font.GothamBlack, TextSize=20, TextColor3=Color3.new(1,1,1),
    AutoButtonColor=false, ZIndex=20, Visible=false
},gui)
corner(fab,FAB_SIZE/2); stroke(fab,Color3.new(1,1,1),1,0.7)

local fabDragging, fabStart, fabStartPos, fabMoved
fab.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        fabDragging=true; fabMoved=false; fabStart=input.Position; fabStartPos=fab.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if fabDragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
        local d = input.Position-fabStart
        if math.abs(d.X)>4 or math.abs(d.Y)>4 then fabMoved=true end
        fab.Position = UDim2.new(fabStartPos.X.Scale,fabStartPos.X.Offset+d.X,fabStartPos.Y.Scale,fabStartPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        if fabDragging then
            Config.Settings.FABX = fab.Position.X.Offset
            Config.Settings.FABY = fab.Position.Y.Offset
        end
        fabDragging=false
    end
end)

--========== MENU ==========
local root = new("Frame",{
    Name="Menu",
    Size=UDim2.new(0, MENU_W, 0, MENU_H),
    Position=UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2),
    BackgroundColor3=Color3.fromRGB(18,18,24), BorderSizePixel=0, Visible=false,
    ZIndex=25, ClipsDescendants=false
},gui)
corner(root,14); stroke(root,Theme.Stroke,1)

local topGlow = new("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=Theme.Accent,BorderSizePixel=0,ZIndex=26},root)

local HEADER_H = 44
local header = new("Frame",{Size=UDim2.new(1,0,0,HEADER_H),BackgroundColor3=Theme.Bg2,BorderSizePixel=0,ZIndex=26},root)
corner(header,14)
new("TextLabel",{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text="ESP HUB (DELTA)",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=27},header)
local closeBtn = new("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0.5,-15),BackgroundColor3=Theme.Danger,Text="✕",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,ZIndex=27},header)
corner(closeBtn,15)
closeBtn.MouseButton1Click:Connect(function() root.Visible=false; fab.Visible=true end)

local sidebar = new("Frame",{
    Size=UDim2.new(0, SIDEBAR_W, 1, -HEADER_H),
    Position=UDim2.new(0,0,0,HEADER_H),
    BackgroundColor3=Theme.Bg2,BorderSizePixel=0,ZIndex=26
},root)
padding(sidebar,8)
new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)

local content = new("Frame",{
    Size=UDim2.new(1, -(SIDEBAR_W+10), 1, -(HEADER_H+10)),
    Position=UDim2.new(0, SIDEBAR_W, 0, HEADER_H),
    BackgroundTransparency=1,ZIndex=26,ClipsDescendants=false
},root)

local pages, tabButtons = {}, {}
local tabsList = {
    {Name="Visual",Icon="◉"},{Name="Aimbot",Icon="✜"},{Name="Silent",Icon="◈"},
    {Name="Trigger",Icon="✹"},{Name="Colors",Icon="◐"},{Name="Settings",Icon="⚙"},
}

local function showPage(name)
    for n,p in pairs(pages) do p.Visible=false end
    local page = pages[name]; if not page then return end
    page.Visible=true
    for n,b in pairs(tabButtons) do
        local active = (n==name)
        tween(b,0.18,{BackgroundColor3=active and Theme.Accent or Theme.Panel,TextColor3=active and Color3.new(1,1,1) or Theme.TextDim}):Play()
    end
end

for i,t in ipairs(tabsList) do
    local btn = new("TextButton",{
        Size=UDim2.new(1,0,0,32),BackgroundColor3=Theme.Panel,
        Text=t.Icon.."  "..t.Name,
        Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Theme.TextDim,
        TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=27
    },sidebar)
    corner(btn,8); padding(btn,8)
    tabButtons[t.Name]=btn
    local page = new("ScrollingFrame",{
        Name=t.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=Theme.Accent,
        CanvasSize=UDim2.new(0,0,0,3000),
        Visible=false,ZIndex=27,ScrollBarImageTransparency=0.4
    },content)
    padding(page,6)
    new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},page)
    pages[t.Name]=page
    btn.MouseButton1Click:Connect(function() showPage(t.Name) end)
end

--========== UI COMPONENTS ==========
local UI = {}
function UI.Section(page,text)
    local wrap = new("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,ZIndex=27},page)
    local bar = new("Frame",{Size=UDim2.new(0,3,0,12),Position=UDim2.new(0,4,0.5,-6),BackgroundColor3=Theme.Accent,BorderSizePixel=0,ZIndex=28},wrap)
    corner(bar,2)
    new("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=text:upper(),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=28},wrap)
    return wrap
end
local function card(page,h)
    local c = new("Frame",{Size=UDim2.new(1,0,0,h or 42),BackgroundColor3=Theme.Panel,BorderSizePixel=0,ZIndex=27},page)
    corner(c,10); stroke(c,Theme.Stroke,1,0.5); return c
end
function UI.Toggle(page,label,default,callback)
    local c = card(page,42)
    new("TextLabel",{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=28},c)
    local state = default or false
    local track = new("Frame",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-54,0.5,-11),BackgroundColor3=state and Theme.Accent or Theme.Panel2,BorderSizePixel=0,ZIndex=28},c)
    corner(track,11)
    local knob = new("Frame",{Size=UDim2.new(0,18,0,18),Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=29},track)
    corner(knob,9)
    local hit = new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=30},c)
    hit.MouseButton1Click:Connect(function()
        state = not state
        tween(track,0.22,{BackgroundColor3=state and Theme.Accent or Theme.Panel2}):Play()
        tween(knob,0.22,{Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
        if callback then callback(state) end
    end)
    return c
end
function UI.Slider(page,label,min,max,default,callback)
    local c = card(page,56)
    new("TextLabel",{Size=UDim2.new(1,-24,0,16),Position=UDim2.new(0,12,0,8),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=28},c)
    local val = new("TextLabel",{Size=UDim2.new(0,44,0,16),Position=UDim2.new(1,-56,0,8),BackgroundTransparency=1,Text=tostring(default),Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=28},c)
    local bar = new("Frame",{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,38),BackgroundColor3=Theme.Panel2,BorderSizePixel=0,ZIndex=28},c)
    corner(bar,3)
    local fill = new("Frame",{Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0,ZIndex=28},bar)
    corner(fill,3)
    local thumb = new("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new((default-min)/(max-min),-6,0.5,-6),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=29},bar)
    corner(thumb,6)
    local value = default; local dragging = false
    local hit = new("TextButton",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,24),BackgroundTransparency=1,Text="",ZIndex=30},c)
    local function upd(x)
        local rel = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        value = math.floor(min+(max-min)*rel+0.5)
        fill.Size = UDim2.new(rel,0,1,0); thumb.Position = UDim2.new(rel,-6,0.5,-6); val.Text = tostring(value)
        if callback then callback(value) end
    end
    hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; upd(input.Position.X) end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then upd(input.Position.X) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return c
end
function UI.Button(page,label,callback,color)
    local b = new("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=color or Theme.Accent,Text=label,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,ZIndex=27},page)
    corner(b,10)
    b.MouseButton1Click:Connect(function() if callback then callback() end end); return b
end
function UI.Dropdown(page,label,options,default,callback)
    local c = card(page,42)
    new("TextLabel",{Size=UDim2.new(1,-110,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=28},c)
    local current = default or options[1]
    local valLbl = new("TextLabel",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-96,0,0),BackgroundTransparency=1,Text=current,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=28},c)
    new("TextLabel",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),BackgroundTransparency=1,Text="▾",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Theme.TextDim,ZIndex=28},c)
    local expanded = false
    local list = new("Frame",{Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,46),BackgroundColor3=Theme.Bg2,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=60},c)
    corner(list,10); padding(list,6)
    new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},list)
    for _,opt in ipairs(options) do
        local ob = new("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Theme.Panel,Text=opt,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=Theme.Text,AutoButtonColor=false,ZIndex=61},list)
        corner(ob,8)
        ob.MouseButton1Click:Connect(function()
            current = opt; valLbl.Text = opt
            if callback then callback(opt) end
            expanded = false
            list.Visible = false
            tween(list,0.15,{Size=UDim2.new(1,-16,0,0)}):Play()
            tween(c,0.15,{Size=UDim2.new(1,0,0,42)}):Play()
        end)
    end
    local hit = new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=62},c)
    hit.MouseButton1Click:Connect(function()
        expanded = not expanded
        list.Visible = expanded
        local h = math.min(#options*32+12, 180)
        tween(list,0.2,{Size=UDim2.new(1,-16,0,expanded and h or 0)}):Play()
        tween(c,0.2,{Size=UDim2.new(1,0,0,expanded and (42+h+6) or 42)}):Play()
    end)
    return c
end
function UI.ColorPicker(page,label,default,callback)
    local c = card(page,42)
    new("TextLabel",{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=28},c)
    local sw = new("Frame",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-54,0.5,-11),BackgroundColor3=default or Color3.new(1,1,1),BorderSizePixel=0,ZIndex=28},c)
    corner(sw,6); stroke(sw,Theme.Stroke,1)

    local expanded = false
    local picker = new("Frame",{
        Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,46),
        BackgroundColor3=Theme.Bg2, BorderSizePixel=0, Visible=false,
        ClipsDescendants=true, ZIndex=70
    },c)
    corner(picker,10); padding(picker,8)

    local h,s,v = (default or Color3.new(1,1,1)):ToHSV()
    local function apply()
        local col = Color3.fromHSV(h,s,v)
        sw.BackgroundColor3 = col
        if callback then callback(col) end
    end

    local function hsvSlider(name,idx,def,cb)
        local f = new("Frame",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,idx*26),BackgroundTransparency=1,ZIndex=71},picker)
        new("TextLabel",{Size=UDim2.new(0,30,1,0),BackgroundTransparency=1,Text=name,Font=Enum.Font.GothamMedium,TextSize=10,TextColor3=Theme.TextDim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=71},f)
        local bar = new("Frame",{Size=UDim2.new(1,-36,0,5),Position=UDim2.new(0,34,0.5,-2.5),BackgroundColor3=Theme.Panel2,BorderSizePixel=0,ZIndex=71},f)
        corner(bar,3)
        local fill = new("Frame",{Size=UDim2.new(def,0,1,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0,ZIndex=71},bar)
        corner(fill,3)
        local hit = new("TextButton",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,-6,0),BackgroundTransparency=1,Text="",ZIndex=72},f)
        local drag = false
        local function upd(x)
            local rel = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(rel,0,1,0)
            cb(rel)
        end
        hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(input.Position.X) end end)
        UIS.InputChanged:Connect(function(input) if drag and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then upd(input.Position.X) end end)
        UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    end

    hsvSlider("H",0,h,function(r) h=r; apply() end)
    hsvSlider("S",1,s,function(r) s=r; apply() end)
    hsvSlider("V",2,v,function(r) v=r; apply() end)

    local hit = new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=73},c)
    hit.MouseButton1Click:Connect(function()
        expanded = not expanded
        picker.Visible = expanded
        tween(picker,0.2,{Size=UDim2.new(1,-16,0,expanded and 84 or 0)}):Play()
        tween(c,0.2,{Size=UDim2.new(1,0,0,expanded and 132 or 42)}):Play()
    end)
    return c
end

--========== НАПОЛНЕНИЕ ==========
UI.Section(pages.Visual,"ESP")
UI.Toggle(pages.Visual,"ESP Enabled",Config.Visual.Enabled,function(v) Config.Visual.Enabled=v end)
UI.Toggle(pages.Visual,"Boxes",Config.Visual.Box,function(v) Config.Visual.Box=v end)
UI.Toggle(pages.Visual,"Skeleton",Config.Visual.Skeleton,function(v) Config.Visual.Skeleton=v end)
UI.Toggle(pages.Visual,"Tracer",Config.Visual.Tracer,function(v) Config.Visual.Tracer=v end)
UI.Toggle(pages.Visual,"Chams",Config.Visual.Chams,function(v) Config.Visual.Chams=v end)
UI.Toggle(pages.Visual,"Health Bar",Config.Visual.HP,function(v) Config.Visual.HP=v end)
UI.Toggle(pages.Visual,"Names",Config.Visual.Names,function(v) Config.Visual.Names=v end)
UI.Toggle(pages.Visual,"Distance",Config.Visual.Distance,function(v) Config.Visual.Distance=v end)
UI.Toggle(pages.Visual,"Bots ESP",Config.Visual.Bots,function(v) Config.Visual.Bots=v end)
UI.Section(pages.Visual,"RGB")
UI.Toggle(pages.Visual,"RGB Tracers",Config.Colors.RGB,function(v) Config.Colors.RGB=v end)

UI.Section(pages.Aimbot,"Main")
UI.Toggle(pages.Aimbot,"Enabled",Config.Aimbot.Enabled,function(v) Config.Aimbot.Enabled=v end)
UI.Dropdown(pages.Aimbot,"Mode",{"Camera","Mouse"},Config.Aimbot.Mode,function(v) Config.Aimbot.Mode=v end)
UI.Dropdown(pages.Aimbot,"Target Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Config.Aimbot.Part,function(v) Config.Aimbot.Part=v end)
UI.Section(pages.Aimbot,"Tuning")
UI.Slider(pages.Aimbot,"FOV",10,600,Config.Aimbot.FOV,function(v) Config.Aimbot.FOV=v end)
UI.Slider(pages.Aimbot,"Smooth %",1,100,math.floor(Config.Aimbot.Smooth*100),function(v) Config.Aimbot.Smooth=v/100 end)
UI.Section(pages.Aimbot,"FOV Circle")
UI.Toggle(pages.Aimbot,"Show FOV",Config.Aimbot.ShowFOV,function(v) Config.Aimbot.ShowFOV=v end)
UI.ColorPicker(pages.Aimbot,"FOV Color",Config.Aimbot.FOVColor,function(c) Config.Aimbot.FOVColor=c end)

UI.Section(pages.Silent,"Main")
UI.Toggle(pages.Silent,"Enabled",Config.Silent.Enabled,function(v) Config.Silent.Enabled=v end)
UI.Dropdown(pages.Silent,"Target Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Config.Silent.Part,function(v) Config.Silent.Part=v end)
UI.Slider(pages.Silent,"FOV",10,600,Config.Silent.FOV,function(v) Config.Silent.FOV=v end)
UI.Section(pages.Silent,"Advanced")
UI.Toggle(pages.Silent,"Visible Check",Config.Silent.VisibleCheck,function(v) Config.Silent.VisibleCheck=v end)
UI.Toggle(pages.Silent,"Hitbox Random",Config.Silent.HitboxRandom,function(v) Config.Silent.HitboxRandom=v end)
UI.Slider(pages.Silent,"Delay (ms)",0,500,Config.Silent.Delay,function(v) Config.Silent.Delay=v end)
UI.Section(pages.Silent,"FOV Circle")
UI.Toggle(pages.Silent,"Show FOV",Config.Silent.ShowFOV,function(v) Config.Silent.ShowFOV=v end)
UI.ColorPicker(pages.Silent,"FOV Color",Config.Silent.FOVColor,function(c) Config.Silent.FOVColor=c end)

UI.Section(pages.Trigger,"Main")
UI.Toggle(pages.Trigger,"Enabled",Config.Trigger.Enabled,function(v) Config.Trigger.Enabled=v end)
UI.Dropdown(pages.Trigger,"Target Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Config.Trigger.Part,function(v) Config.Trigger.Part=v end)
UI.Section(pages.Trigger,"Tuning")
UI.Slider(pages.Trigger,"FOV (center)",5,100,Config.Trigger.FOV,function(v) Config.Trigger.FOV=v end)
UI.Slider(pages.Trigger,"Delay (ms)",0,500,Config.Trigger.Delay,function(v) Config.Trigger.Delay=v end)
UI.Toggle(pages.Trigger,"Visible Check",Config.Trigger.VisibleCheck,function(v) Config.Trigger.VisibleCheck=v end)
UI.Section(pages.Trigger,"FOV Circle")
UI.Toggle(pages.Trigger,"Show FOV",Config.Trigger.ShowFOV,function(v) Config.Trigger.ShowFOV=v end)
UI.ColorPicker(pages.Trigger,"FOV Color",Config.Trigger.FOVColor,function(c) Config.Trigger.FOVColor=c end)

UI.Section(pages.Colors,"ESP")
UI.ColorPicker(pages.Colors,"Box",Config.Colors.Box,function(c) Config.Colors.Box=c end)
UI.ColorPicker(pages.Colors,"Skeleton",Config.Colors.Skeleton,function(c) Config.Colors.Skeleton=c end)
UI.ColorPicker(pages.Colors,"Tracer",Config.Colors.Tracer,function(c) Config.Colors.Tracer=c end)
UI.ColorPicker(pages.Colors,"Chams",Config.Colors.Chams,function(c) Config.Colors.Chams=c end)
UI.ColorPicker(pages.Colors,"Bot Color",Config.Colors.Bot,function(c) Config.Colors.Bot=c end)
UI.Section(pages.Colors,"HP / Text")
UI.ColorPicker(pages.Colors,"HP Fill",Config.Colors.HP,function(c) Config.Colors.HP=c end)
UI.ColorPicker(pages.Colors,"HP Background",Config.Colors.HP_Back,function(c) Config.Colors.HP_Back=c end)
UI.ColorPicker(pages.Colors,"Name",Config.Colors.Name,function(c) Config.Colors.Name=c end)
UI.ColorPicker(pages.Colors,"Distance",Config.Colors.Distance,function(c) Config.Colors.Distance=c end)

UI.Section(pages.Settings,"Menu")
UI.Button(pages.Settings,"Save Config",function() saveConfig() end)
UI.Button(pages.Settings,"Destroy Hub",function() gui:Destroy() end,Theme.Danger)

showPage("Visual")

--========== СТАРТ ==========
root.Visible = true
fab.Visible = false

fab.MouseButton1Click:Connect(function()
    if fabMoved then return end
    root.Visible = true
    fab.Visible = false
    showPage("Visual")
end)

--============================================================
--  ESP LOGIC
--============================================================
local ESP_Store = {}
local Chams_Store = {}
local BOT_Store = {}

local function newLine(color,t) local l=Drawing.new("Line"); l.Visible=false; l.Color=color or Color3.new(1,1,1); l.Thickness=t or 1; l.Transparency=1; return l end
local function newText(size,color)
    local t = Drawing.new("Text")
    t.Visible=false; t.Center=true; t.Outline=true; t.OutlineColor=Color3.new(0,0,0)
    t.Size=size or 14; t.Color=color or Color3.new(1,1,1)
    t.Font = (Drawing.Fonts and Drawing.Fonts.UI) or 0
    return t
end

local R15_SKELETON = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6_SKELETON = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local function getSkeletonConnections(char) if char:FindFirstChild("UpperTorso") then return R15_SKELETON else return R6_SKELETON end end

local function createESPObjects(store, player, isBot)
    if store[player] then return end
    local color = isBot and Config.Colors.Bot or Config.Colors.Box
    local s = {
        box_lines = {Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")},
        tracer = newLine(Config.Colors.Tracer,1), skeleton = {},
        hp_back_line = Drawing.new("Line"), hp_fill_line = Drawing.new("Line"),
        name = newText(14,isBot and Config.Colors.Bot or Config.Colors.Name),
        dist = newText(12,Config.Colors.Distance),
        isBot = isBot,
    }
    for _,l in ipairs(s.box_lines) do l.Visible=false; l.Thickness=1; l.Transparency=1; l.Color=color end
    s.hp_back_line.Visible=false; s.hp_back_line.Thickness=3
    s.hp_fill_line.Visible=false; s.hp_fill_line.Thickness=3
    for i=1,#R15_SKELETON do s.skeleton[i]=newLine(isBot and Config.Colors.Bot or Config.Colors.Skeleton,1) end
    store[player]=s
end

local function removeESPObjects(store, player)
    local s = store[player]; if not s then return end
    for _,l in ipairs(s.box_lines) do l:Remove() end
    if s.tracer then s.tracer:Remove() end
    for _,l in pairs(s.skeleton) do l:Remove() end
    if s.hp_back_line then s.hp_back_line:Remove() end
    if s.hp_fill_line then s.hp_fill_line:Remove() end
    if s.name then s.name:Remove() end
    if s.dist then s.dist:Remove() end
    store[player]=nil
end

local function hideESP(s)
    for _,l in ipairs(s.box_lines) do l.Visible=false end
    s.tracer.Visible=false
    for _,l in pairs(s.skeleton) do l.Visible=false end
    s.hp_back_line.Visible=false; s.hp_fill_line.Visible=false
    s.name.Visible=false; s.dist.Visible=false
end

-- Универсальный updateESP: работает и для игрока, и для модели-бота
local function updateESPGeneric(store, key, char, isBot)
    if not char then if store[key] then hideESP(store[key]) end; return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then if store[key] then hideESP(store[key]) end; return end
    createESPObjects(store, key, isBot)
    local s = store[key]
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (head and torso and hrp) then return end

    local boxColor = isBot and Config.Colors.Bot or Config.Colors.Box
    local skelColor = isBot and Config.Colors.Bot or Config.Colors.Skeleton

    local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,head.Size.Y/2,0))
    local hrpScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
    local onScreen = headScreen.Z>0 and hrpScreen.Z>0

    -- Box = 4 линии
    if Config.Visual.Enabled and Config.Visual.Box and onScreen and (not isBot or Config.Visual.Bots) then
        local height = math.abs(headScreen.Y-hrpScreen.Y)
        local width = height*0.45
        local cx = hrpScreen.X; local cy = hrpScreen.Y
        local x1,y1 = cx-width/2, cy-height
        local x2,y2 = cx+width/2, cy
        local L = s.box_lines
        L[1].From = Vector2.new(x1,y1); L[1].To = Vector2.new(x2,y1)
        L[2].From = Vector2.new(x2,y1); L[2].To = Vector2.new(x2,y2)
        L[3].From = Vector2.new(x2,y2); L[3].To = Vector2.new(x1,y2)
        L[4].From = Vector2.new(x1,y2); L[4].To = Vector2.new(x1,y1)
        for _,l in ipairs(L) do l.Color = boxColor; l.Visible = true end
    else for _,l in ipairs(s.box_lines) do l.Visible=false end end

    -- Skeleton
    if Config.Visual.Enabled and Config.Visual.Skeleton and (not isBot or Config.Visual.Bots) then
        local conns = getSkeletonConnections(char)
        for i=1,#s.skeleton do s.skeleton[i].Visible=false end
        for i,pair in ipairs(conns) do
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            local line = s.skeleton[i]
            if p1 and p2 and line then
                local a = Camera:WorldToViewportPoint(p1.Position)
                local b = Camera:WorldToViewportPoint(p2.Position)
                if a.Z>0 and b.Z>0 then
                    line.From = Vector2.new(a.X,a.Y); line.To = Vector2.new(b.X,b.Y)
                    line.Color = skelColor; line.Visible = true
                end
            end
        end
    else for _,l in pairs(s.skeleton) do l.Visible=false end end

    -- Tracer
    if Config.Visual.Enabled and Config.Visual.Tracer and (not isBot or Config.Visual.Bots) then
        local toPos = Camera:WorldToViewportPoint(torso.Position)
        if toPos.Z>0 then
            s.tracer.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
            s.tracer.To = Vector2.new(toPos.X,toPos.Y)
            if Config.Colors.RGB then
                s.tracer.Color = Color3.fromHSV((tick()*0.5)%1,1,1)
            else
                s.tracer.Color = isBot and Config.Colors.Bot or Config.Colors.Tracer
            end
            s.tracer.Visible = true
        else s.tracer.Visible=false end
    else s.tracer.Visible=false end

    -- HP = 2 линии
    if Config.Visual.Enabled and Config.Visual.HP and Config.Visual.Box and onScreen and (not isBot or Config.Visual.Bots) then
        local height = math.abs(headScreen.Y-hrpScreen.Y)
        local width = height*0.45
        local cx = hrpScreen.X; local topY = hrpScreen.Y-height
        local barX = cx-width/2-6
        local frac = math.clamp(hum.Health/hum.MaxHealth,0,1)
        s.hp_back_line.From = Vector2.new(barX,topY); s.hp_back_line.To = Vector2.new(barX,topY+height)
        s.hp_back_line.Color = Config.Colors.HP_Back; s.hp_back_line.Visible = true
        s.hp_fill_line.From = Vector2.new(barX,topY+height-height*frac); s.hp_fill_line.To = Vector2.new(barX,topY+height)
        s.hp_fill_line.Color = Config.Colors.HP; s.hp_fill_line.Visible = true
    else s.hp_back_line.Visible=false; s.hp_fill_line.Visible=false end

    -- Name
    if Config.Visual.Enabled and Config.Visual.Names and onScreen and (not isBot or Config.Visual.Bots) then
        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,head.Size.Y/2+1.2,0))
        if top.Z>0 then
            s.name.Text = (isBot and "[BOT] " or "")..(key.Name or char.Name)
            s.name.Color = isBot and Config.Colors.Bot or Config.Colors.Name
            s.name.Position = Vector2.new(top.X,top.Y-14); s.name.Size = 14; s.name.Visible = true
        else s.name.Visible=false end
    else s.name.Visible=false end

    -- Distance
    if Config.Visual.Enabled and Config.Visual.Distance and onScreen and (not isBot or Config.Visual.Bots) then
        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,head.Size.Y/2+1.2,0))
        if top.Z>0 then
            local dist = math.floor((Camera.CFrame.Position-hrp.Position).Magnitude)
            s.dist.Text = tostring(dist).."m"; s.dist.Color = Config.Colors.Distance
            s.dist.Position = Vector2.new(top.X,top.Y+2); s.dist.Size = 12; s.dist.Visible = true
        else s.dist.Visible=false end
    else s.dist.Visible=false end
end

-- updateESP для игроков
local function updateESP(player,char)
    if player==LocalPlayer then if ESP_Store[player] then hideESP(ESP_Store[player]) end; return end
    updateESPGeneric(ESP_Store, player, char, false)
end

-- updateBots
local function isBotModel(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    -- внешний Highlight (детекция другими читами)
    if model:FindFirstChildOfClass("Highlight") then return true end
    return true
end

local function updateBots()
    if not Config.Visual.Enabled or not Config.Visual.Bots then
        for obj, s in pairs(BOT_Store) do hideESP(s) end
        return
    end
    local current = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if isBotModel(obj) then
            current[obj] = true
            updateESPGeneric(BOT_Store, obj, obj, true)
        end
    end
    for obj, s in pairs(BOT_Store) do
        if not current[obj] or not obj.Parent then
            removeESPObjects(BOT_Store, obj)
        end
    end
end

-- updateChams
local function updateChams(player,char)
    if player==LocalPlayer or not char then
        if Chams_Store[player] then Chams_Store[player]:Destroy(); Chams_Store[player]=nil end
        return
    end
    if not Config.Visual.Enabled or not Config.Visual.Chams then
        if Chams_Store[player] then Chams_Store[player]:Destroy(); Chams_Store[player]=nil end
        return
    end
    if not Chams_Store[player] then
        local hl = Instance.new("Highlight")
        hl.Name="ESP_Chams"; hl.FillTransparency=0.5; hl.OutlineTransparency=1
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
        Chams_Store[player]=hl
    end
    Chams_Store[player].FillColor = Config.Colors.Chams
end

RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        updateESP(p,char); updateChams(p,char)
    end
    pcall(updateBots)
end)
Players.PlayerRemoving:Connect(function(p)
    removeESPObjects(ESP_Store, p)
    if Chams_Store[p] then Chams_Store[p]:Destroy(); Chams_Store[p]=nil end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if Chams_Store[p] then Chams_Store[p]:Destroy(); Chams_Store[p]=nil end
    end)
end)

--========== TARGET (FOV от ЦЕНТРА экрана) ==========
local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = part.Position-origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local result = workspace:Raycast(origin,dir,params)
    return result==nil or result.Instance:IsDescendantOf(part.Parent)
end

local function getTarget(cfg)
    local center = Camera.ViewportSize / 2
    local cands = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(cfg.Part)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health>0 then
                local pos,onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if dist<=cfg.FOV then
                        if not cfg.VisibleCheck or isVisible(part) then
                            table.insert(cands,{part=part,fovDist=dist,worldDist=(Camera.CFrame.Position-part.Position).Magnitude,health=hum.Health})
                        end
                    end
                end
            end
        end
    end
    if #cands==0 then return nil end
    table.sort(cands,function(a,b)
        if cfg.Priority=="FOV" then return a.fovDist<b.fovDist
        elseif cfg.Priority=="Health" then return a.health<b.health
        else return a.worldDist<b.worldDist end
    end)
    return cands[1].part
end

--========== FOV CIRCLES (от центра) ==========
local FOV_Aimbot, FOV_Silent, FOV_Trigger
local function updateCircle(circle,cfg,center)
    if not circle then circle = Drawing.new("Circle") end
    circle.Visible = true; circle.Position = center; circle.Radius = cfg.FOV
    circle.Color = cfg.FOVColor; circle.Thickness = cfg.FOVThickness or 1
    circle.Transparency = cfg.FOVTransparency or 0.6; circle.Filled = cfg.FOVFilled or false
    return circle
end
RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then FOV_Aimbot = updateCircle(FOV_Aimbot,Config.Aimbot,center) elseif FOV_Aimbot then FOV_Aimbot.Visible=false end
    if Config.Silent.ShowFOV and Config.Silent.Enabled then FOV_Silent = updateCircle(FOV_Silent,Config.Silent,center) elseif FOV_Silent then FOV_Silent.Visible=false end
    if Config.Trigger.ShowFOV and Config.Trigger.Enabled then FOV_Trigger = updateCircle(FOV_Trigger,Config.Trigger,center) elseif FOV_Trigger then FOV_Trigger.Visible=false end
end)

--========== AIMBOT ==========
local function isKeyActive(k)
    if typeof(k)=="EnumItem" then
        if k.EnumType==Enum.KeyCode then return UIS:IsKeyDown(k)
        elseif k.EnumType==Enum.UserInputType then return UIS:IsMouseButtonPressed(k) end
    end
    return false
end
RunService.RenderStepped:Connect(function()
    if not Config.Aimbot.Enabled then return end
    if Config.Aimbot.Key and not isKeyActive(Config.Aimbot.Key) then return end
    local target = getTarget(Config.Aimbot); if not target then return end
    if Config.Aimbot.Mode=="Camera" then
        local cur = Camera.CFrame
        local goal = CFrame.lookAt(cur.Position,target.Position)
        Camera.CFrame = cur:Lerp(goal,Config.Aimbot.Smooth)
    else
        local pos,onScreen = Camera:WorldToViewportPoint(target.Position)
        if onScreen and mousemoverel then
            local c = Camera.ViewportSize/2
            mousemoverel((pos.X-c.X)*Config.Aimbot.Smooth,(pos.Y-c.Y)*Config.Aimbot.Smooth)
        end
    end
end)

--========== SILENT AIM ==========
local function randomizeHit(part)
    if not Config.Silent.HitboxRandom then return part.Position end
    local s = part.Size
    return part.Position + Vector3.new((math.random()-0.5)*s.X*0.6,(math.random()-0.5)*s.Y*0.6,(math.random()-0.5)*s.Z*0.6)
end
local lastSilent = 0
local oldNamecall
oldNamecall = hookmetamethod(game,"__namecall",function(self,...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and Config.Silent.Enabled then
        if method=="Raycast" and self==workspace then
            if tick()-lastSilent >= Config.Silent.Delay/1000 then
                local target = getTarget(Config.Silent)
                if target then
                    lastSilent = tick()
                    local origin = args[1]; local dir = args[2]
                    args[2] = (randomizeHit(target)-origin).Unit*dir.Magnitude
                    return oldNamecall(self,unpack(args))
                end
            end
        elseif method=="FindPartOnRay" or method=="FindPartOnRayWithIgnoreList" then
            local target = getTarget(Config.Silent)
            if target then
                local ray = args[1]
                if typeof(ray)=="Ray" then
                    args[1] = Ray.new(ray.Origin,(randomizeHit(target)-ray.Origin).Unit*ray.Direction.Magnitude)
                    return oldNamecall(self,unpack(args))
                end
            end
        end
    end
    return oldNamecall(self,...)
end)
local oldIndex
oldIndex = hookmetamethod(game,"__index",function(self,key)
    if not checkcaller() and Config.Silent.Enabled then
        if self==Mouse and (key=="Hit" or key=="Target") then
            local target = getTarget(Config.Silent)
            if target then return key=="Hit" and CFrame.new(randomizeHit(target)) or target end
        end
    end
    return oldIndex(self,key)
end)

--========== TRIGGER ==========
local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if not Config.Trigger.Enabled then return end
    if Config.Trigger.Key and not isKeyActive(Config.Trigger.Key) then return end
    if tick()-lastTrigger < Config.Trigger.Delay/1000 then return end
    local target = getTarget(Config.Trigger)
    if target then
        lastTrigger = tick()
        if mouse1click then mouse1click()
        elseif mouse1press and mouse1release then mouse1press(); task.wait(0.02); mouse1release() end
    end
end)

print("[ESP HUB DELTA v5] Loaded. Bots ESP, FOV center, fixed picker.")
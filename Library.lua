local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if _G.NeverloseLibraryLoaded then
    local notify = Drawing.new("Text")
    notify.Visible = true
    notify.Transparency = 1
    notify.Outline = true
    notify.Font = 2
    notify.Size = 16
    notify.Color = Color3.fromRGB(255, 80, 80)
    notify.Position = Vector2.new(20, 60)
    notify.Text = "Neverlose.cc \n script failed to load\n script already loaded, please rejoin."
    task.spawn(function()
        task.wait(6)
        notify:Remove()
    end)
    return
end

_G.NeverloseLibraryLoaded = true

local function draggable(a, library)
    local dragging, dragInput, dragStart, startPos
    a.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = a.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            a.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local keyNames = {
    [Enum.KeyCode.LeftAlt] = 'LALT',
    [Enum.KeyCode.RightAlt] = 'RALT',
    [Enum.KeyCode.LeftControl] = 'LCTRL',
    [Enum.KeyCode.RightControl] = 'RCTRL',
    [Enum.KeyCode.LeftShift] = 'LSHIFT',
    [Enum.KeyCode.RightShift] = 'RSHIFT',
    [Enum.KeyCode.Underscore] = '_',
    [Enum.KeyCode.Minus] = '-',
    [Enum.KeyCode.Plus] = '+',
    [Enum.KeyCode.Period] = '.',
    [Enum.KeyCode.Slash] = '/',
    [Enum.KeyCode.BackSlash] = '\\',
    [Enum.KeyCode.Question] = '?',
    [Enum.UserInputType.MouseButton1] = 'MB1',
    [Enum.UserInputType.MouseButton2] = 'MB2',
    [Enum.UserInputType.MouseButton3] = 'MB3',
}

local NeverloseLibrary = {}
NeverloseLibrary.__index = NeverloseLibrary

function NeverloseLibrary.new(opts)
    opts = opts or {}
    local library = setmetatable({}, NeverloseLibrary)

    print([[
 _______ .__
 \ \ _______ __ ___________| | ____ ______ ____
 / | \_/ __ \ \/ // __ \_ __ \ | / _ \/ ___// __ \
/ | \ ___/\ /\ ___/| | \/ |_( <_> )___ \\ ___/
\____|__ /\___ >\_/ \___ >__| |____/\____/____ >\___ >
        \/ \/ \/ \/ \/
               Neverlose Library, made by @gq3z
    ]])

    library.cheatname = opts.cheatname or ""
    library.ext = opts.ext or ""
    library.gamename = opts.gamename or ""
    library.assetId = opts.assetId or 12702460854

    library.colorpicking = false
    library.tabbuttons = {}
    library.tabs = {}
    library.options = {}
    library.flags = {}
    library.scrolling = false
    library.notifyText = Drawing.new("Text")
    library.playing = false
    library.multiZindex = 200
    library.toInvis = {}
    library.libColor = Color3.fromRGB(240, 142, 214)
    library.disabledcolor = Color3.fromRGB(233, 0, 0)
    library.blacklisted = {Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.UserInputType.MouseMovement}

    local menu = game:GetObjects("rbxassetid://"..library.assetId)[1]
    if syn and syn.protect_gui then pcall(syn.protect_gui, menu) end
    menu.bg.Position = UDim2.new(0.5,-menu.bg.Size.X.Offset/2,0.5,-menu.bg.Size.Y.Offset/2)
    menu.Parent = game:GetService("CoreGui")
    menu.bg.pre.Text = library.cheatname..library.ext..library.gamename
    library.menu = menu

    draggable(menu.bg, library)

    library.tabholder = menu.bg.bg.bg.bg.main.group
    library.tabviewer = menu.bg.bg.bg.bg.tabbuttons

    UserInputService.InputEnded:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.RightShift then
            menu.Enabled = not menu.Enabled
            library.scrolling = false
            library.colorpicking = false
            for _,v in next, library.toInvis do v.Visible = false end
        end
    end)

    library.notifyText.Font = 2
    library.notifyText.Size = 13
    library.notifyText.Outline = true
    library.notifyText.Color = Color3.new(1,1,1)
    library.notifyText.Position = Vector2.new(10,60)

    function library:Tween(...) TweenService:Create(...):Play() end
    function library:notify(text)
        if self.playing then return end
        self.playing = true
        self.notifyText.Text = text or ""
        self.notifyText.Transparency = 0
        self.notifyText.Visible = true
        task.spawn(function()
            task.wait(3.5)
            for i=0,1,0.05 do task.wait(0.025) self.notifyText.Transparency = i end
            self.notifyText.Visible = false
            self.playing = false
        end)
    end

    function library:addTab(name)
        local newTab = self.tabholder.tab:Clone()
        local newButton = self.tabviewer.button:Clone()
        table.insert(self.tabs, newTab)
        newTab.Parent = self.tabholder
        newTab.Visible = (#self.tabs == 1)
        table.insert(self.tabbuttons, newButton)
        newButton.Parent = self.tabviewer
        newButton.Modal = true
        newButton.Visible = true
        newButton.text.Text = name
        newButton.MouseButton1Click:Connect(function()
            for _,v in next, self.tabs do v.Visible = (v == newTab) end
            for _,v in next, self.toInvis do v.Visible = false end
            for _,v in next, self.tabbuttons do
                local state = (v == newButton)
                v.element.Visible = state
                self:Tween(v.element, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = state and 0 or 1})
                v.text.TextColor3 = state and Color3.fromRGB(244,244,244) or Color3.fromRGB(144,144,144)
            end
        end)
        if #self.tabs == 1 then
            newButton.element.Visible = true
            self:Tween(newButton.element, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})
            newButton.text.TextColor3 = Color3.fromRGB(244,244,244)
        end

        local tab = {}
        local groupCount, jigCount, topStuff = 0,0,2000

        function tab:createGroup(pos,groupname)
            local groupbox = Instance.new("Frame")
            local grouper = Instance.new("Frame")
            local UIList = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")
            local title = Instance.new("TextLabel")
            local back = Instance.new("Frame")

            groupCount -= 1
            groupbox.Parent = newTab[pos]
            groupbox.BackgroundColor3 = Color3.fromRGB(255,255,255)
            groupbox.BorderColor3 = Color3.fromRGB(30,30,30)
            groupbox.BorderSizePixel = 2
            groupbox.Size = UDim2.new(0,211,0,8)
            groupbox.ZIndex = groupCount
            grouper.Parent = groupbox
            grouper.BackgroundColor3 = Color3.fromRGB(20,20,20)
            grouper.BorderColor3 = Color3.fromRGB(0,0,0)
            grouper.Size = UDim2.new(1,0,1,0)
            grouper.AutomaticSize = Enum.AutomaticSize.Y

            UIList.Parent = grouper
            UIList.FillDirection = Enum.FillDirection.Vertical
            UIList.SortOrder = Enum.SortOrder.LayoutOrder
            UIList.Padding = UDim.new(0,2)

            UIPadding.Parent = grouper
            UIPadding.PaddingTop = UDim.new(0,7)
            UIPadding.PaddingBottom = UDim.new(0,6)

            title.Parent = groupbox
            title.BackgroundTransparency = 1
            title.Position = UDim2.new(0,17,0,0)
            title.ZIndex = 2
            title.Font = Enum.Font.Code
            title.Text = groupname or ""
            title.TextColor3 = Color3.fromRGB(255,255,255)
            title.TextSize = 13
            title.TextStrokeTransparency = 0
            title.TextXAlignment = Enum.TextXAlignment.Left

            back.Parent = groupbox
            back.BackgroundColor3 = Color3.fromRGB(20,20,20)
            back.BorderSizePixel = 0
            back.Position = UDim2.new(0,10,0,-2)
            back.Size = UDim2.new(0,13 + title.TextBounds.X,0,3)

            local group = {}
            local layoutCounter = 0

            local function applyLayout(element)
                layoutCounter += 1
                element.LayoutOrder = layoutCounter
                groupbox.Size = UDim2.new(0,211,0,8 + layoutCounter * 28)
            end

            function group:addToggle(args)
                if not args.flag and args.text then args.flag = args.text end
                if not args.flag then return warn("missing toggle flag") end
                groupbox.Size += UDim2.new(0,0,0,20)
                local toggleframe = Instance.new("Frame")
                local tobble = Instance.new("Frame")
                local mid = Instance.new("Frame")
                local front = Instance.new("Frame")
                local text = Instance.new("TextLabel")
                local button = Instance.new("TextButton")
                jigCount -= 1
                library.multiZindex -= 1
                toggleframe.Name = "toggleframe"
                toggleframe.Parent = grouper
                toggleframe.BackgroundTransparency = 1
                toggleframe.Size = UDim2.new(1,0,0,20)
                toggleframe.ZIndex = library.multiZindex
                tobble.Name = "tobble"
                tobble.Parent = toggleframe
                tobble.BackgroundColor3 = Color3.fromRGB(255,255,255)
                tobble.BorderColor3 = Color3.fromRGB(0,0,0)
                tobble.BorderSizePixel = 3
                tobble.Position = UDim2.new(0.03,0,0.27,0)
                tobble.Size = UDim2.new(0,10,0,10)
                mid.Name = "mid"
                mid.Parent = tobble
                mid.BackgroundColor3 = Color3.fromRGB(69,23,255)
                mid.BorderColor3 = Color3.fromRGB(30,30,30)
                mid.BorderSizePixel = 2
                mid.Size = UDim2.new(0,10,0,10)
                front.Name = "front"
                front.Parent = mid
                front.BackgroundColor3 = Color3.fromRGB(15,15,15)
                front.BorderColor3 = Color3.fromRGB(0,0,0)
                front.Size = UDim2.new(0,10,0,10)
                text.Name = "text"
                text.Parent = toggleframe
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0,22,0,0)
                text.Size = UDim2.new(1,-30,1,0)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(155,155,155)
                text.TextSize = 13
                text.TextStrokeTransparency = 0
                text.TextXAlignment = Enum.TextXAlignment.Left
                button.Name = "button"
                button.Parent = toggleframe
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1,0,1,0)
                button.Text = ""

                if args.disabled then
                    button.Visible = false
                    text.TextColor3 = library.disabledcolor
                    return
                end

                local state = args.default or false
                local function setToggle(v)
                    state = v
                    library.flags[args.flag] = v
                    front.BackgroundColor3 = v and library.libColor or Color3.fromRGB(15,15,15)
                    text.TextColor3 = v and Color3.fromRGB(244,244,244) or Color3.fromRGB(144,144,144)
                    if args.callback then args.callback(v) end
                end
                button.MouseButton1Click:Connect(function()
                    setToggle(not state)
                end)
                button.MouseEnter:Connect(function() mid.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() mid.BorderColor3 = Color3.fromRGB(30,30,30) end)

                setToggle(state)
                library.options[args.flag] = {type="toggle",changeState=setToggle}
                applyLayout(toggleframe)

                local toggleObj = {}
                function toggleObj:addKeybind(kargs)
                    if not kargs.flag then return warn("missing keybind flag") end
                    local waiting = false
                    local kbFrame = Instance.new("Frame")
                    local kbBtn = Instance.new("TextButton")
                    kbFrame.Parent = toggleframe
                    kbFrame.BackgroundTransparency = 1
                    kbFrame.Position = UDim2.new(0.72,4,0.27,0)
                    kbFrame.Size = UDim2.new(0,51,0,10)
                    kbBtn.Parent = kbFrame
                    kbBtn.BackgroundTransparency = 1
                    kbBtn.Position = UDim2.new(-0.27,0,0,0)
                    kbBtn.Size = UDim2.new(1.27,0,1,0)
                    kbBtn.Font = Enum.Font.Code
                    kbBtn.Text = ""
                    kbBtn.TextColor3 = Color3.fromRGB(155,155,155)
                    kbBtn.TextSize = 13
                    kbBtn.TextXAlignment = Enum.TextXAlignment.Right

                    local function updateKb(val)
                        if library.colorpicking then return end
                        library.flags[kargs.flag] = val
                        kbBtn.Text = keyNames[val] or val.Name
                    end
                    UserInputService.InputBegan:Connect(function(inp)
                        local code = inp.KeyCode == Enum.KeyCode.Unknown and inp.UserInputType or inp.KeyCode
                        if waiting then
                            if not table.find(library.blacklisted,code) then
                                waiting = false
                                library.flags[kargs.flag] = code
                                kbBtn.Text = keyNames[code] or code.Name
                            end
                        elseif code == library.flags[kargs.flag] and kargs.callback then
                            kargs.callback()
                        end
                    end)
                    kbBtn.MouseButton1Click:Connect(function()
                        if library.colorpicking then return end
                        library.flags[kargs.flag] = Enum.KeyCode.Unknown
                        kbBtn.Text = "..."
                        kbBtn.TextColor3 = library.libColor
                        waiting = true
                    end)
                    library.flags[kargs.flag] = kargs.key or Enum.KeyCode.Unknown
                    library.options[kargs.flag] = {type="keybind",changeState=updateKb}
                    updateKb(library.flags[kargs.flag])
                end
                function toggleObj:addColorpicker(cargs)
                    return group:addColorpicker(cargs)
                end
                return toggleObj
            end

            function group:addButton(args)
                if not args.text or not args.callback then return warn("invalid button") end
                groupbox.Size += UDim2.new(0,0,0,22)
                local buttonframe = Instance.new("Frame")
                buttonframe.BackgroundTransparency = 1
                buttonframe.Size = UDim2.new(1,0,0,21)
                buttonframe.Parent = grouper
                local bg = Instance.new("Frame")
                bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,0)
                bg.Size = UDim2.new(0,205,0,15)
                bg.Parent = buttonframe
                local main = Instance.new("Frame")
                main.BackgroundColor3 = Color3.fromRGB(35,35,35)
                main.BorderColor3 = Color3.fromRGB(60,60,60)
                main.Size = UDim2.new(1,0,1,0)
                main.Parent = bg
                local button = Instance.new("TextButton")
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1,0,1,0)
                button.Font = Enum.Font.Code
                button.Text = args.text
                button.TextColor3 = Color3.fromRGB(255,255,255)
                button.TextSize = 13
                button.Parent = main
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                gradient.Rotation = 90
                gradient.Parent = main
                button.MouseButton1Click:Connect(function()
                    if not library.colorpicking then args.callback() end
                end)
                button.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60,60,60) end)
                applyLayout(buttonframe)
            end

            function group:addSlider(args,sub)
                if not args.flag or not args.max then return warn("missing slider args") end
                groupbox.Size += UDim2.new(0,0,0,30)
                local slider = Instance.new("Frame")
                slider.BackgroundTransparency = 1
                slider.Size = UDim2.new(1,0,0,30)
                slider.Parent = grouper
                local bg = Instance.new("Frame")
                bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,16)
                bg.Size = UDim2.new(0,205,0,10)
                bg.Parent = slider
                local main = Instance.new("Frame")
                main.BackgroundColor3 = Color3.fromRGB(35,35,35)
                main.BorderColor3 = Color3.fromRGB(50,50,50)
                main.Size = UDim2.new(1,0,1,0)
                main.Parent = bg
                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = library.libColor
                fill.BackgroundTransparency = 0.2
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new(0,0,1,0)
                fill.Parent = main
                local button = Instance.new("TextButton")
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1,0,1,0)
                button.Text = ""
                button.Parent = main
                local valuetext = Instance.new("TextLabel")
                valuetext.BackgroundTransparency = 1
                valuetext.Position = UDim2.new(0.5,0,0.5,0)
                valuetext.AnchorPoint = Vector2.new(0.5,0.5)
                valuetext.Font = Enum.Font.Code
                valuetext.TextColor3 = Color3.fromRGB(255,255,255)
                valuetext.TextSize = 14
                valuetext.TextStrokeTransparency = 0.8
                valuetext.Parent = main
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                UIGradient.Rotation = 90
                UIGradient.Parent = main
                local text = Instance.new("TextLabel")
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.03,-1,0,7)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Parent = slider
                local minv = args.min or 0
                local maxv = args.max
                local val = args.value or minv
                local function updateValue(value)
                    val = math.clamp(value,minv,maxv)
                    library.flags[args.flag] = val
                    local percent = (val - minv) / (maxv - minv)
                    fill.Size = UDim2.new(percent,0,1,0)
                    valuetext.Text = tostring(val) .. (sub or "")
                    if args.callback then args.callback(val) end
                end
                local dragging = false
                button.MouseButton1Down:Connect(function() dragging = true end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                RunService.RenderStepped:Connect(function()
                    if dragging then
                        local percent = math.clamp((Mouse.X - main.AbsolutePosition.X) / main.AbsoluteSize.X, 0, 1)
                        updateValue(minv + (maxv - minv) * percent)
                    end
                end)
                updateValue(val)
                library.options[args.flag] = {type="slider",changeState=updateValue}
                applyLayout(slider)
            end

            function group:addTextbox(args)
                if not args.flag then return warn("missing textbox flag") end
                groupbox.Size += UDim2.new(0,0,0,35)
                local textbox = Instance.new("Frame")
                textbox.BackgroundTransparency = 1
                textbox.Size = UDim2.new(1,0,0,35)
                textbox.Parent = grouper
                local bg = Instance.new("Frame")
                bg.BackgroundColor3 = Color3.fromRGB(15,15,15)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,16)
                bg.Size = UDim2.new(0,205,0,15)
                bg.Parent = textbox
                local main = Instance.new("ScrollingFrame")
                main.Active = true
                main.BackgroundColor3 = Color3.fromRGB(15,15,15)
                main.BorderColor3 = Color3.fromRGB(30,30,30)
                main.Size = UDim2.new(1,0,1,0)
                main.CanvasSize = UDim2.new(0,0,0,0)
                main.ScrollBarThickness = 0
                main.Parent = bg
                local box = Instance.new("TextBox")
                box.BackgroundTransparency = 1
                box.Size = UDim2.new(1,0,1,0)
                box.Font = Enum.Font.Code
                box.Text = args.value or ""
                box.TextColor3 = Color3.fromRGB(255,255,255)
                box.TextSize = 13
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.Parent = main
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                gradient.Rotation = 90
                gradient.Parent = main
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0.03,-1,0,7)
                label.Font = Enum.Font.Code
                label.Text = args.text or args.flag
                label.TextColor3 = Color3.fromRGB(244,244,244)
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = textbox
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if library.colorpicking then return end
                    library.flags[args.flag] = box.Text
                    if args.callback then args.callback(box.Text) end
                end)
                library.flags[args.flag] = args.value or ""
                library.options[args.flag] = {type="textbox",changeState=function(t) box.Text = t end}
                applyLayout(textbox)
            end

            function group:addDivider()
                groupbox.Size += UDim2.new(0,0,0,10)
                local div = Instance.new("Frame")
                div.BackgroundTransparency = 1
                div.Size = UDim2.new(0,202,0,10)
                div.Parent = grouper
                local bg = Instance.new("Frame")
                bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,0,0,4)
                bg.Size = UDim2.new(0,191,0,1)
                bg.Parent = div
                local main = Instance.new("Frame")
                main.BackgroundColor3 = Color3.fromRGB(35,35,35)
                main.BorderColor3 = Color3.fromRGB(60,60,60)
                main.Size = UDim2.new(0,191,0,1)
                main.Parent = bg
                applyLayout(div)
            end

            function group:addList(args)
                if not args.flag or not args.values then return warn("missing list args") end
                groupbox.Size += UDim2.new(0,0,0,35)
                library.multiZindex -= 1
                local list = Instance.new("Frame")
                list.BackgroundTransparency = 1
                list.Size = UDim2.new(1,0,0,35)
                list.ZIndex = library.multiZindex
                list.Parent = grouper
                local bg = Instance.new("Frame")
                bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,16)
                bg.Size = UDim2.new(0,205,0,15)
                bg.Parent = list
                local main = Instance.new("ScrollingFrame")
                main.Active = true
                main.BackgroundColor3 = Color3.fromRGB(35,35,35)
                main.BorderColor3 = Color3.fromRGB(60,60,60)
                main.Size = UDim2.new(1,0,1,0)
                main.CanvasSize = UDim2.new(0,0,0,0)
                main.ScrollBarThickness = 0
                main.Parent = bg
                local button = Instance.new("TextButton")
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(0,191,1,0)
                button.Text = ""
                button.Parent = main
                local dumbtriangle = Instance.new("ImageLabel")
                dumbtriangle.BackgroundTransparency = 1
                dumbtriangle.Position = UDim2.new(1,-11,0.5,-3)
                dumbtriangle.Size = UDim2.new(0,7,0,6)
                dumbtriangle.ZIndex = 3
                dumbtriangle.Image = "rbxassetid://8532000591"
                dumbtriangle.Parent = main
                local valuetext = Instance.new("TextLabel")
                valuetext.BackgroundTransparency = 1
                valuetext.Position = UDim2.new(0.002,2,0,7)
                valuetext.ZIndex = 2
                valuetext.Font = Enum.Font.Code
                valuetext.TextColor3 = Color3.fromRGB(244,244,244)
                valuetext.TextSize = 13
                valuetext.TextXAlignment = Enum.TextXAlignment.Left
                valuetext.Parent = main
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                gradient.Rotation = 90
                gradient.Parent = main
                local text = Instance.new("TextLabel")
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.03,-1,0,7)
                text.ZIndex = 2
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Parent = list
                local frame = Instance.new("Frame")
                frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
                frame.BorderColor3 = Color3.fromRGB(0,0,0)
                frame.BorderSizePixel = 2
                frame.Position = UDim2.new(0.03,-1,0.605,15)
                frame.Size = UDim2.new(0,203,0,0)
                frame.Visible = false
                frame.ZIndex = library.multiZindex
                frame.Parent = list
                local holder = Instance.new("Frame")
                holder.BackgroundColor3 = Color3.fromRGB(35,35,35)
                holder.BorderColor3 = Color3.fromRGB(60,60,60)
                holder.Size = UDim2.new(1,0,1,0)
                holder.Parent = frame
                local UIListLayout = Instance.new("UIListLayout")
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = holder
                local function updateValue(value)
                    if value == nil then valuetext.Text = "nil" return end
                    if args.multiselect then
                        if type(value) == "string" then
                            if not table.find(library.options[args.flag].values,value) then return end
                            if table.find(library.flags[args.flag],value) then
                                for i,v in pairs(library.flags[args.flag]) do if v==value then table.remove(library.flags[args.flag],i) end end
                            else
                                table.insert(library.flags[args.flag],value)
                            end
                        else
                            library.flags[args.flag] = value
                        end
                        local buttonText = ""
                        for i,v in pairs(library.flags[args.flag]) do
                            buttonText = buttonText .. v .. (i ~= #library.flags[args.flag] and "," or "")
                        end
                        if buttonText == "" then buttonText = "..." end
                        valuetext.Text = buttonText
                        if args.callback then args.callback(library.flags[args.flag]) end
                    else
                        if not table.find(library.options[args.flag].values,value) then value = library.options[args.flag].values[1] end
                        library.flags[args.flag] = value
                        valuetext.Text = value
                        frame.Visible = false
                        if args.callback then args.callback(value) end
                    end
                end
                local function refresh(tbl)
                    for _,v in next, holder:GetChildren() do if v:IsA("Frame") then v:Destroy() end end
                    frame.Size = UDim2.new(0,203,0,0)
                    for _,v in ipairs(tbl) do
                        frame.Size += UDim2.new(0,0,0,20)
                        local option = Instance.new("Frame")
                        option.Name = v
                        option.BackgroundTransparency = 1
                        option.Size = UDim2.new(1,0,0,20)
                        option.Parent = holder
                        local btn2 = Instance.new("TextButton")
                        btn2.BackgroundColor3 = Color3.fromRGB(35,35,35)
                        btn2.BackgroundTransparency = 0
                        btn2.BorderSizePixel = 0
                        btn2.Size = UDim2.new(1,0,1,0)
                        btn2.Text = ""
                        btn2.Parent = option
                        local txt2 = Instance.new("TextLabel")
                        txt2.Name = "off"
                        txt2.BackgroundTransparency = 1
                        txt2.Position = UDim2.new(0,4,0,0)
                        txt2.Font = Enum.Font.Code
                        txt2.Text = v
                        txt2.TextColor3 = args.multiselect and Color3.new(0.65,0.65,0.65) or Color3.new(1,1,1)
                        txt2.TextSize = 14
                        txt2.TextXAlignment = Enum.TextXAlignment.Left
                        txt2.Parent = option
                        btn2.MouseButton1Click:Connect(function() updateValue(v) end)
                    end
                    library.options[args.flag].values = tbl
                    updateValue(library.flags[args.flag] or (not args.multiselect and tbl[1] or ""))
                end
                button.MouseButton1Click:Connect(function()
                    if not library.colorpicking then frame.Visible = not frame.Visible end
                end)
                button.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60,60,60) end)
                table.insert(library.toInvis,frame)
                library.flags[args.flag] = args.multiselect and {} or ""
                library.options[args.flag] = {type="list",changeState=updateValue,values=args.values,refresh=refresh}
                refresh(args.values)
                updateValue(args.value or (not args.multiselect and args.values[1] or ""))
                applyLayout(list)
            end

            function group:addConfigbox(args)
                if not args.flag or not args.values then return warn("missing configbox args") end
                groupbox.Size += UDim2.new(0,0,0,138)
                library.multiZindex -= 1
                local list2 = Instance.new("Frame")
                list2.BackgroundTransparency = 1
                list2.Size = UDim2.new(1,0,0,138)
                list2.Parent = grouper
                local frame = Instance.new("Frame")
                frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
                frame.BorderColor3 = Color3.fromRGB(0,0,0)
                frame.BorderSizePixel = 2
                frame.Position = UDim2.new(0.02,-1,0.044,0)
                frame.Size = UDim2.new(0,205,0,128)
                frame.Parent = list2
                local main = Instance.new("Frame")
                main.BackgroundColor3 = Color3.fromRGB(18,18,18)
                main.BorderColor3 = Color3.fromRGB(30,30,30)
                main.Size = UDim2.new(1,0,1,0)
                main.Parent = frame
                local holder = Instance.new("ScrollingFrame")
                holder.Active = true
                holder.BackgroundTransparency = 1
                holder.Position = UDim2.new(0,0,0.0057,0)
                holder.Size = UDim2.new(1,0,1,0)
                holder.CanvasSize = UDim2.new(0,0,0,0)
                holder.ScrollBarThickness = 0
                holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
                holder.Parent = main
                local UIListLayout = Instance.new("UIListLayout")
                UIListLayout.Parent = holder
                local dwn = Instance.new("ImageLabel")
                dwn.BackgroundTransparency = 1
                dwn.Position = UDim2.new(0.93,4,1,-9)
                dwn.Size = UDim2.new(0,7,0,6)
                dwn.Image = "rbxassetid://8548723563"
                dwn.Visible = false
                dwn.Parent = frame
                local up = Instance.new("ImageLabel")
                up.BackgroundTransparency = 1
                up.Position = UDim2.new(0,3,0,3)
                up.Size = UDim2.new(0,7,0,6)
                up.Image = "rbxassetid://8548757311"
                up.Visible = false
                up.Parent = frame
                local function updateValue(value)
                    if not value then return end
                    if not table.find(library.options[args.flag].values,value) then value = library.options[args.flag].values[1] end
                    library.flags[args.flag] = value
                    for _,v in next, holder:GetChildren() do
                        if v:IsA("Frame") then
                            v.text.TextColor3 = (v.text.Text == value) and library.libColor or Color3.fromRGB(255,255,255)
                        end
                    end
                    if args.callback then args.callback(value) end
                end
                holder:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                    up.Visible = holder.CanvasPosition.Y > 1
                    dwn.Visible = holder.CanvasPosition.Y + 1 < (holder.AbsoluteCanvasSize.Y - holder.AbsoluteSize.Y)
                end)
                local function refresh(tbl)
                    for _,v in next, holder:GetChildren() do if v:IsA("Frame") then v:Destroy() end end
                    for _,v in ipairs(tbl) do
                        local item = Instance.new("Frame")
                        item.Name = v
                        item.BackgroundTransparency = 1
                        item.Size = UDim2.new(1,0,0,18)
                        item.Parent = holder
                        local btn = Instance.new("TextButton")
                        btn.BackgroundTransparency = 1
                        btn.Size = UDim2.new(1,0,1,0)
                        btn.TextTransparency = 1
                        btn.Parent = item
                        local txt = Instance.new("TextLabel")
                        txt.Name = "text"
                        txt.BackgroundTransparency = 1
                        txt.Size = UDim2.new(1,0,0,18)
                        txt.Font = Enum.Font.Code
                        txt.Text = v
                        txt.TextColor3 = Color3.fromRGB(255,255,255)
                        txt.TextSize = 14
                        txt.TextStrokeTransparency = 0
                        txt.Parent = item
                        btn.MouseButton1Click:Connect(function() updateValue(v) end)
                    end
                    library.options[args.flag].values = tbl
                    updateValue(library.flags[args.flag] or tbl[1])
                end
                library.flags[args.flag] = ""
                library.options[args.flag] = {type="cfg",changeState=updateValue,values=args.values,refresh=refresh}
                refresh(args.values)
                updateValue(args.value or args.values[1])
                applyLayout(list2)
            end

            function group:addColorpicker(args)
                if not args.flag then return warn("missing colorpicker flag") end
                groupbox.Size += UDim2.new(0,0,0,20)
                library.multiZindex -= 1
                jigCount -= 1
                topStuff -= 1
                local colorpicker = Instance.new("Frame")
                colorpicker.BackgroundTransparency = 1
                colorpicker.Size = UDim2.new(1,0,0,20)
                colorpicker.ZIndex = topStuff
                colorpicker.Parent = grouper
                local text = Instance.new("TextLabel")
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.02,-1,0,10)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Parent = colorpicker
                local pickerBtn = Instance.new("TextButton")
                pickerBtn.BackgroundTransparency = 1
                pickerBtn.Size = UDim2.new(0,202,0,22)
                pickerBtn.Text = ""
                pickerBtn.Parent = colorpicker
                local front = Instance.new("Frame")
                front.BackgroundColor3 = args.color or Color3.new(1,1,1)
                front.Size = UDim2.new(0,20,0,20)
                front.Position = UDim2.new(1,-30,0,0)
                front.Parent = pickerBtn
                local function updateValue(value)
                    library.flags[args.flag] = value
                    front.BackgroundColor3 = value
                    if args.callback then args.callback(value) end
                end
                table.insert(library.toInvis, front)
                library.flags[args.flag] = args.color or Color3.new(1,1,1)
                library.options[args.flag] = {type="colorpicker",changeState=updateValue}
                updateValue(args.color or Color3.new(1,1,1))
                applyLayout(colorpicker)
            end

            function group:addKeybind(args)
                if not args.flag then return warn("missing keybind flag") end
                groupbox.Size += UDim2.new(0,0,0,20)
                local next = false
                local keybind = Instance.new("Frame")
                keybind.BackgroundTransparency = 1
                keybind.Size = UDim2.new(1,0,0,20)
                keybind.Parent = grouper
                local text = Instance.new("TextLabel")
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.02,-1,0,10)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Parent = keybind
                local button = Instance.new("TextButton")
                button.BackgroundTransparency = 1
                button.Position = UDim2.new(0,0,0,0)
                button.Size = UDim2.new(0.02,0,1,0)
                button.Font = Enum.Font.Code
                button.Text = ""
                button.TextColor3 = Color3.fromRGB(155,155,155)
                button.TextXAlignment = Enum.TextXAlignment.Right
                button.Parent = keybind
                local function updateValue(val)
                    if library.colorpicking then return end
                    library.flags[args.flag] = val
                    button.Text = keyNames[val] or val.Name
                end
                UserInputService.InputBegan:Connect(function(key)
                    local k = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
                    if next then
                        if not table.find(library.blacklisted,k) then
                            next = false
                            library.flags[args.flag] = k
                            button.Text = keyNames[k] or k.Name
                        end
                    elseif k == library.flags[args.flag] and args.callback then
                        args.callback()
                    end
                end)
                button.MouseButton1Click:Connect(function()
                    if library.colorpicking then return end
                    library.flags[args.flag] = Enum.KeyCode.Unknown
                    button.Text = "..."
                    next = true
                end)
                library.flags[args.flag] = args.key or Enum.KeyCode.Unknown
                library.options[args.flag] = {type="keybind",changeState=updateValue}
                updateValue(library.flags[args.flag])
                applyLayout(keybind)
            end

            return group
        end

        return tab
    end

    return library
end

return NeverloseLibrary

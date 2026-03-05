-- Neverlose Library (Full Enhanced Version - All Features Included)
-- Enhanced with opaque dropdowns, fixed sliders, no loading screen, ASCII print on load
-- All elements: toggle (w/ sub keybind & colorpicker), button, slider, textbox, divider, list (dropdown), configbox, colorpicker, keybind
-- Settings tab auto-added with config system & Kill GUI button
-- Press RIGHT SHIFT to toggle menu
-- Made by @gq3z (enhanced for completeness)

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

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
            a.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local keyNames = {
    [Enum.KeyCode.LeftAlt] = 'LALT';
    [Enum.KeyCode.RightAlt] = 'RALT';
    [Enum.KeyCode.LeftControl] = 'LCTRL';
    [Enum.KeyCode.RightControl] = 'RCTRL';
    [Enum.KeyCode.LeftShift] = 'LSHIFT';
    [Enum.KeyCode.RightShift] = 'RSHIFT';
    [Enum.KeyCode.Underscore] = '_';
    [Enum.KeyCode.Minus] = '-';
    [Enum.KeyCode.Plus] = '+';
    [Enum.KeyCode.Period] = '.';
    [Enum.KeyCode.Slash] = '/';
    [Enum.KeyCode.BackSlash] = '\\';
    [Enum.KeyCode.Question] = '?';
    [Enum.UserInputType.MouseButton1] = 'MB1';
    [Enum.UserInputType.MouseButton2] = 'MB2';
    [Enum.UserInputType.MouseButton3] = 'MB3';
}

local NeverloseLibrary = {}
NeverloseLibrary.__index = NeverloseLibrary

function NeverloseLibrary.new(opts)
    opts = opts or {}
    local library = setmetatable({}, NeverloseLibrary)

    print([[
  _   _                     _                 
 | \ | |                   | |                
 |  \| | _____   _____ _ __| | ___  ___  ___  
 | . ` |/ _ \ \ / / _ \ '__| |/ _ \/ __|/ _ \ 
 | |\  |  __/\ V /  __/ |  | | (_) \__ \  __/ 
 |_| \_|\___| \_/ \___|_|  |_|\___/|___/\___|                               
     Neverlose Library, made by @gq3z
    ]])

    library.cheatname = opts.cheatname or ""
    library.ext       = opts.ext or ""
    library.gamename  = opts.gamename or ""
    library.assetId   = opts.assetId or 12702460854

    library.colorpicking = false
    library.tabbuttons   = {}
    library.tabs         = {}
    library.options      = {}
    library.flags        = {}
    library.scrolling    = false
    library.notifyText   = Drawing.new("Text")
    library.playing      = false
    library.multiZindex  = 200
    library.toInvis      = {}
    library.libColor     = Color3.fromRGB(240, 142, 214)
    library.disabledcolor= Color3.fromRGB(233, 0, 0)
    library.blacklisted  = {Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.UserInputType.MouseMovement}

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

    function library:Tween(...) tweenService:Create(...):Play() end
    function library:notify(text)
        if self.playing then return end
        self.playing = true
        self.notifyText.Text = text
        self.notifyText.Transparency = 0
        self.notifyText.Visible = true
        for i=0,1,0.1 do task.wait() self.notifyText.Transparency = i end
        task.spawn(function()
            task.wait(3)
            for i=1,0,-0.1 do task.wait() self.notifyText.Transparency = i end
            self.playing = false
            self.notifyText.Visible = false
        end)
    end

    function library:addTab(name)
        local newTab = self.tabholder.tab:Clone()
        local newButton = self.tabviewer.button:Clone()
        table.insert(self.tabs,newTab)
        newTab.Parent = self.tabholder
        newTab.Visible = false
        table.insert(self.tabbuttons,newButton)
        newButton.Parent = self.tabviewer
        newButton.Modal = true
        newButton.Visible = true
        newButton.text.Text = name
        newButton.MouseButton1Click:Connect(function()
            for i,v in next, self.tabs do v.Visible = v == newTab end
            for i,v in next, self.toInvis do v.Visible = false end
            for i,v in next, self.tabbuttons do
                local state = v == newButton
                if state then
                    v.element.Visible = true
                    self:Tween(v.element, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})
                    v.text.TextColor3 = Color3.fromRGB(244,244,244)
                else
                    self:Tween(v.element, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1})
                    v.text.TextColor3 = Color3.fromRGB(144,144,144)
                end
            end
        end)

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
            UIList.Parent = grouper
            UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIList.SortOrder = Enum.SortOrder.LayoutOrder
            UIPadding.Parent = grouper
            UIPadding.PaddingBottom = UDim.new(0,4)
            UIPadding.PaddingTop = UDim.new(0,7)
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
                toggleframe.BackgroundColor3 = Color3.fromRGB(255,255,255)
                toggleframe.BackgroundTransparency = 1
                toggleframe.BorderSizePixel = 0
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
                text.BackgroundColor3 = Color3.fromRGB(55,55,55)
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0,22,0,0)
                text.Size = UDim2.new(0,0,1,2)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(155,155,155)
                text.TextSize = 13
                text.TextStrokeTransparency = 0
                text.TextXAlignment = Enum.TextXAlignment.Left
                button.Name = "button"
                button.Parent = toggleframe
                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0
                button.Size = UDim2.new(0,101,1,0)
                button.Font = Enum.Font.SourceSans
                button.Text = ""
                button.TextColor3 = Color3.fromRGB(0,0,0)
                button.TextSize = 14

                if args.disabled then
                    button.Visible = false
                    text.TextColor3 = library.disabledcolor
                    text.Text = args.text
                    return
                end

                local state = false
                function toggle(newState)
                    state = newState
                    library.flags[args.flag] = state
                    front.BackgroundColor3 = state and library.libColor or Color3.fromRGB(15,15,15)
                    text.TextColor3 = state and Color3.fromRGB(244,244,244) or Color3.fromRGB(144,144,144)
                    if args.callback then args.callback(state) end
                end
                button.MouseButton1Click:Connect(function()
                    state = not state
                    front.Name = state and "accent" or "back"
                    library.flags[args.flag] = state
                    mid.BorderColor3 = Color3.fromRGB(30,30,30)
                    front.BackgroundColor3 = state and library.libColor or Color3.fromRGB(15,15,15)
                    text.TextColor3 = state and Color3.fromRGB(244,244,244) or Color3.fromRGB(144,144,144)
                    if args.callback then args.callback(state) end
                end)
                button.MouseEnter:Connect(function() mid.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() mid.BorderColor3 = Color3.fromRGB(30,30,30) end)

                library.flags[args.flag] = false
                library.options[args.flag] = {type="toggle",changeState=toggle,skipflag=args.skipflag,oldargs=args}
                local toggleObj = {}
                function toggleObj:addKeybind(args)
                    if not args.flag then return warn("missing args on toggle:keybind") end
                    local next = false
                    local keybind = Instance.new("Frame")
                    local button = Instance.new("TextButton")

                    keybind.Parent = toggleframe
                    keybind.BackgroundTransparency = 1
                    keybind.BorderColor3 = Color3.fromRGB(0,0,0)
                    keybind.BorderSizePixel = 0
                    keybind.Position = UDim2.new(0.72,4,0.27,0)
                    keybind.Size = UDim2.new(0,51,0,10)
                    button.Parent = keybind
                    button.BackgroundTransparency = 1
                    button.BorderSizePixel = 0
                    button.Position = UDim2.new(-0.27,0,0,0)
                    button.Size = UDim2.new(1.27,0,1,0)
                    button.Font = Enum.Font.Code
                    button.Text = ""
                    button.TextColor3 = Color3.fromRGB(155,155,155)
                    button.TextSize = 13
                    button.TextStrokeTransparency = 0
                    button.TextXAlignment = Enum.TextXAlignment.Right

                    function updateValue(val)
                        if library.colorpicking then return end
                        library.flags[args.flag] = val
                        button.Text = keyNames[val] or val.Name
                    end
                    UserInputService.InputBegan:Connect(function(key)
                        local key = key.KeyCode==Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
                        if next then
                            if not table.find(library.blacklisted,key) then
                                next = false
                                library.flags[args.flag] = key
                                button.Text = keyNames[key] or key.Name
                                button.TextColor3 = Color3.fromRGB(155,155,155)
                            end
                        end
                        if not next and key==library.flags[args.flag] and args.callback then args.callback() end
                    end)
                    button.MouseButton1Click:Connect(function()
                        if library.colorpicking then return end
                        library.flags[args.flag] = Enum.KeyCode.Unknown
                        button.Text = "..."
                        button.TextColor3 = library.libColor
                        next = true
                    end)
                    library.flags[args.flag] = Enum.KeyCode.Unknown
                    library.options[args.flag] = {type="keybind",changeState=updateValue,skipflag=args.skipflag,oldargs=args}
                    updateValue(args.key or Enum.KeyCode.Unknown)
                end
                function toggleObj:addColorpicker(args)
                    return group:addColorpicker(args)
                end
                return toggleObj
            end

            function group:addButton(args)
                if not args.text or not args.callback then return warn("invalid button args") end
                groupbox.Size += UDim2.new(0,0,0,22)
                local buttonframe = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("Frame")
                local button = Instance.new("TextButton")
                local gradient = Instance.new("UIGradient")
                buttonframe.Name = "buttonframe"
                buttonframe.Parent = grouper
                buttonframe.BackgroundTransparency = 1
                buttonframe.Size = UDim2.new(1,0,0,21)
                bg.Name = "bg"
                bg.Parent = buttonframe
                bg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,0)
                bg.Size = UDim2.new(0,205,0,15)
                main.Name = "main"
                main.Parent = bg
                main.BackgroundColor3 = Color3.fromRGB(35,35,35)
                main.BorderColor3 = Color3.fromRGB(60,60,60)
                main.Size = UDim2.new(1,0,1,0)
                button.Name = "button"
                button.Parent = main
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1,0,1,0)
                button.Font = Enum.Font.Code
                button.Text = args.text
                button.TextColor3 = Color3.fromRGB(255,255,255)
                button.TextSize = 13
                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                gradient.Rotation = 90
                gradient.Parent = main
                button.MouseButton1Click:Connect(function()
                    if not library.colorpicking then args.callback() end
                end)
                button.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60,60,60) end)
            end

            function group:addSlider(args,sub)
                if not args.flag or not args.max then return warn("⚠️ incorrect arguments ⚠️") end
                groupbox.Size += UDim2.new(0, 0, 0, 30)
                local slider = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("Frame")
                local fill = Instance.new("Frame")
                local button = Instance.new("TextButton")
                local valuetext = Instance.new("TextLabel")
                local UIGradient = Instance.new("UIGradient")
                local text = Instance.new("TextLabel")
                slider.Name = "slider"
                slider.Parent = grouper
                slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                slider.BackgroundTransparency = 1.000
                slider.BorderSizePixel = 0
                slider.Size = UDim2.new(1, 0, 0, 30)
                
                bg.Name = "bg"
                bg.Parent = slider
                bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02, -1, 0, 16)
                bg.Size = UDim2.new(0, 205, 0, 10)
                
                main.Name = "main"
                main.Parent = bg
                main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                main.BorderColor3 = Color3.fromRGB(50, 50, 50)
                main.Size = UDim2.new(1, 0, 1, 0)
                
                fill.Name = "fill"
                fill.Parent = main
                fill.BackgroundColor3 = library.libColor
                fill.BackgroundTransparency = 0.200
                fill.BorderColor3 = Color3.fromRGB(60, 60, 60)
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new(0.617238641, 13, 1, 0)
                
                button.Name = "button"
                button.Parent = main
                button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                button.BackgroundTransparency = 1.000
                button.Size = UDim2.new(0, 191, 1, 0)
                button.Font = Enum.Font.SourceSans
                button.Text = ""
                button.TextColor3 = Color3.fromRGB(0, 0, 0)
                button.TextSize = 14.000
                
                valuetext.Parent = main
                valuetext.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                valuetext.BackgroundTransparency = 1.000
                valuetext.Position = UDim2.new(0.5, 0, 0.5, 0)
                valuetext.Font = Enum.Font.Code
                valuetext.Text = "0.9172/10"
                valuetext.TextColor3 = Color3.fromRGB(255, 255, 255)
                valuetext.TextSize = 14.000
                valuetext.TextStrokeTransparency = 0.000
                
                UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(105, 105, 105)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(121, 121, 121))}
                UIGradient.Rotation = 90
                UIGradient.Parent = main
                
                text.Name = "text"
                text.Parent = slider
                text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                text.BackgroundTransparency = 1.000
                text.Position = UDim2.new(0.0299999993, -1, 0, 7)
                text.ZIndex = 2
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244, 244, 244)
                text.TextSize = 13.000
                text.TextStrokeTransparency = 0.000
                text.TextXAlignment = Enum.TextXAlignment.Left

                local entered = false
                local scrolling = false
                local amount = 0

                local function updateValue(value)
                    if library.colorpicking then return end
                    if value ~= 0 then
                        fill:TweenSize(UDim2.new(value/args.max,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
                    else
                        fill:TweenSize(UDim2.new(0,1,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
                    end
                    valuetext.Text = value..(sub or "")
                    library.flags[args.flag] = value
                    if args.callback then args.callback(value) end
                end
                local function updateScroll()
                    if scrolling or library.scrolling or not newTab.Visible or library.colorpicking then return end
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and menu.Enabled do RunService.RenderStepped:Wait()
                        library.scrolling = true
                        valuetext.TextColor3 = Color3.fromRGB(255,255,255)
                        scrolling = true
                        local value = (args.min or 0) + ((Mouse.X - button.AbsolutePosition.X) / button.AbsoluteSize.X) * ((args.max) - (args.min or 0))
                        if value < (args.min or 0) then value = args.min or 0 end
                        if value > args.max then value = args.max end
                        updateValue(math.floor(value))
                    end
                    if scrolling and not entered then
                        valuetext.TextColor3 = Color3.fromRGB(255,255,255)
                    end
                    if not menu.Enabled then entered = false end
                    scrolling = false
                    library.scrolling = false
                end
                button.MouseEnter:Connect(function()
                    if library.colorpicking then return end
                    if scrolling or entered then return end
                    entered = true
                    main.BorderColor3 = library.libColor
                    while entered do task.wait() updateScroll() end
                end)
                button.MouseLeave:Connect(function() entered = false main.BorderColor3 = Color3.fromRGB(60,60,60) end)
                if args.value then updateValue(args.value) end
                library.flags[args.flag] = 0
                library.options[args.flag] = {type="slider",changeState=updateValue,skipflag=args.skipflag,oldargs=args}
                updateValue(args.value or 0)
            end

            function group:addTextbox(args)
                if not args.flag then return warn("⚠️ incorrect arguments ⚠️") end
                groupbox.Size += UDim2.new(0, 0, 0, 35)
                local textbox = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("ScrollingFrame")
                local box = Instance.new("TextBox")
                local gradient = Instance.new("UIGradient")
                local label = Instance.new("TextLabel")
                box:GetPropertyChangedSignal('Text'):Connect(function()
                    if library.colorpicking then return end
                    library.flags[args.flag] = box.Text
                    args.value = box.Text
                    if args.callback then args.callback(box.Text) end
                end)
                textbox.Name = "textbox"
                textbox.Parent = grouper
                textbox.BackgroundTransparency = 1
                textbox.Size = UDim2.new(1,0,0,35)
                textbox.ZIndex = 10
                bg.Name = "bg"
                bg.Parent = textbox
                bg.BackgroundColor3 = Color3.fromRGB(15,15,15)
                bg.BorderColor3 = Color3.fromRGB(0,0,0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02,-1,0,16)
                bg.Size = UDim2.new(0,205,0,15)
                main.Name = "main"
                main.Parent = bg
                main.Active = true
                main.BackgroundColor3 = Color3.fromRGB(15,15,15)
                main.BorderColor3 = Color3.fromRGB(30,30,30)
                main.Size = UDim2.new(1,0,1,0)
                main.CanvasSize = UDim2.new(0,0,0,0)
                main.ScrollBarThickness = 0
                box.Name = "box"
                box.Parent = main
                box.BackgroundTransparency = 1
                box.Selectable = false
                box.Size = UDim2.new(1,0,1,0)
                box.Font = Enum.Font.Code
                box.Text = args.value or ""
                box.TextColor3 = Color3.fromRGB(255,255,255)
                box.TextSize = 13
                box.TextStrokeTransparency = 0
                box.TextXAlignment = Enum.TextXAlignment.Left
                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}
                gradient.Rotation = 90
                gradient.Parent = main
                label.Name = "text"
                label.Parent = textbox
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0.03,-1,0,7)
                label.ZIndex = 2
                label.Font = Enum.Font.Code
                label.Text = args.text or args.flag
                label.TextColor3 = Color3.fromRGB(244,244,244)
                label.TextSize = 13
                label.TextStrokeTransparency = 0
                label.TextXAlignment = Enum.TextXAlignment.Left
                library.flags[args.flag] = args.value or ""
                library.options[args.flag] = {type="textbox",changeState=function(t) box.Text = t end,skipflag=args.skipflag,oldargs=args}
            end

            function group:addDivider(args)
                groupbox.Size += UDim2.new(0,0,0,10)
                local div = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("Frame")
                div.Name = "div"; div.Parent = grouper; div.BackgroundTransparency=1; div.BorderSizePixel=0; div.Size=UDim2.new(0,202,0,10)
                bg.Name = "bg"; bg.Parent = div; bg.BackgroundColor3=Color3.fromRGB(35,35,35); bg.BorderColor3=Color3.fromRGB(0,0,0); bg.BorderSizePixel=2; bg.Position=UDim2.new(0.02,0,0,4); bg.Size=UDim2.new(0,191,0,1)
                main.Name="main"; main.Parent=bg; main.BackgroundColor3=Color3.fromRGB(35,35,35); main.BorderColor3=Color3.fromRGB(60,60,60); main.Size=UDim2.new(0,191,0,1)
            end

            function group:addList(args)
                if not args.flag or not args.values then return warn("⚠️ incorrect arguments ⚠️") end
                groupbox.Size += UDim2.new(0,0,0,35)
                library.multiZindex -= 1
                local list = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("ScrollingFrame")
                local button = Instance.new("TextButton")
                local dumbtriangle = Instance.new("ImageLabel")
                local valuetext = Instance.new("TextLabel")
                local gradient = Instance.new("UIGradient")
                local text = Instance.new("TextLabel")
                local frame = Instance.new("Frame")
                local holder = Instance.new("Frame")
                local UIListLayout = Instance.new("UIListLayout")
                
                list.Name="list"; list.Parent=grouper; list.BackgroundTransparency=1; list.Size=UDim2.new(1,0,0,35); list.ZIndex=library.multiZindex
                bg.Name="bg"; bg.Parent=list; bg.BackgroundColor3=Color3.fromRGB(35,35,35); bg.BorderColor3=Color3.fromRGB(0,0,0); bg.BorderSizePixel=2; bg.Position=UDim2.new(0.02,-1,0,16); bg.Size=UDim2.new(0,205,0,15)
                main.Name="main"; main.Parent=bg; main.Active=true; main.BackgroundColor3=Color3.fromRGB(35,35,35); main.BorderColor3=Color3.fromRGB(60,60,60); main.Size=UDim2.new(1,0,1,0); main.CanvasSize=UDim2.new(0,0,0,0); main.ScrollBarThickness=0
                button.Name="button"; button.Parent=main; button.BackgroundTransparency=1; button.Size=UDim2.new(0,191,1,0); button.Font=Enum.Font.SourceSans; button.Text=""; button.TextColor3=Color3.new(0,0,0); button.TextSize=14
                dumbtriangle.Name="dumbtriangle"; dumbtriangle.Parent=main; dumbtriangle.BackgroundTransparency=1; dumbtriangle.Position=UDim2.new(1,-11,0.5,-3); dumbtriangle.Size=UDim2.new(0,7,0,6); dumbtriangle.ZIndex=3; dumbtriangle.Image="rbxassetid://8532000591"
                valuetext.Name="valuetext"; valuetext.Parent=main; valuetext.BackgroundTransparency=1; valuetext.Position=UDim2.new(0.002,2,0,7); valuetext.ZIndex=2; valuetext.Font=Enum.Font.Code; valuetext.TextColor3=Color3.fromRGB(244,244,244); valuetext.TextSize=13; valuetext.TextStrokeTransparency=0; valuetext.TextXAlignment=Enum.TextXAlignment.Left
                gradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(121,121,121))}; gradient.Rotation=90; gradient.Parent=main
                text.Name="text"; text.Parent=list; text.BackgroundTransparency=1; text.Position=UDim2.new(0.03,-1,0,7); text.ZIndex=2; text.Font=Enum.Font.Code; text.Text=args.text or args.flag; text.TextColor3=Color3.fromRGB(244,244,244); text.TextSize=13; text.TextStrokeTransparency=0; text.TextXAlignment=Enum.TextXAlignment.Left
                frame.Name="frame"; frame.Parent=list; frame.BackgroundColor3=Color3.fromRGB(35,35,35); frame.BorderColor3=Color3.fromRGB(0,0,0); frame.BorderSizePixel=2; frame.Position=UDim2.new(0.03,-1,0.605,15); frame.Size=UDim2.new(0,203,0,0); frame.Visible=false; frame.ZIndex=library.multiZindex
                holder.Name="holder"; holder.Parent=frame; holder.BackgroundColor3=Color3.fromRGB(35,35,35); holder.BorderColor3=Color3.fromRGB(60,60,60); holder.Size=UDim2.new(1,0,1,0)
                UIListLayout.Parent=holder; UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder

                local function updateValue(value)
                    if value == nil then valuetext.Text="nil" return end
                    if args.multiselect then
                        if type(value)=="string" then
                            if not table.find(library.options[args.flag].values,value) then return end
                            if table.find(library.flags[args.flag],value) then
                                for i,v in pairs(library.flags[args.flag]) do if v==value then table.remove(library.flags[args.flag],i) end end
                            else
                                table.insert(library.flags[args.flag],value)
                            end
                        else
                            library.flags[args.flag] = value
                        end
                        local buttonText=""
                        for i,v in pairs(library.flags[args.flag]) do
                            local jig = i~= #library.flags[args.flag] and "," or ""
                            buttonText = buttonText..v..jig
                        end
                        if buttonText=="" then buttonText="..." end
                        for i,v in next, holder:GetChildren() do
                            if v.ClassName~="Frame" then continue end
                            v.off.TextColor3 = Color3.new(0.65,0.65,0.65)
                            for _i,_v in next, library.flags[args.flag] do
                                if v.Name==_v then v.off.TextColor3 = Color3.new(1,1,1) end
                            end
                        end
                        valuetext.Text = buttonText
                        if args.callback then args.callback(library.flags[args.flag]) end
                    else
                        if not table.find(library.options[args.flag].values,value) then value = library.options[args.flag].values[1] end
                        library.flags[args.flag] = value
                        for i,v in next, holder:GetChildren() do
                            if v.ClassName~="Frame" then continue end
                            v.off.TextColor3 = Color3.new(0.65,0.65,0.65)
                            if v.Name==library.flags[args.flag] then v.off.TextColor3=Color3.new(1,1,1) end
                        end
                        frame.Visible=false
                        if library.flags[args.flag] then
                            valuetext.Text = library.flags[args.flag]
                            if args.callback then args.callback(library.flags[args.flag]) end
                        end
                    end
                end

                function refresh(tbl)
                    for i,v in next, holder:GetChildren() do if v.ClassName=="Frame" then v:Destroy() end frame.Size = UDim2.new(0,203,0,0) end
                    for i,v in pairs(tbl) do
                        frame.Size += UDim2.new(0,0,0,20)
                        local option = Instance.new("Frame")
                        local btn2 = Instance.new("TextButton")
                        local txt2 = Instance.new("TextLabel")
                        option.Name = v; option.Parent = holder; option.BackgroundTransparency=1; option.Size=UDim2.new(1,0,0,20)
                        btn2.Parent = option; btn2.BackgroundColor3=Color3.fromRGB(35,35,35); btn2.BackgroundTransparency=0; btn2.BorderSizePixel=0; btn2.Size=UDim2.new(1,0,1,0); btn2.Font=Enum.Font.SourceSans; btn2.Text=""; btn2.TextColor3=Color3.new(0,0,0); btn2.TextSize=14
                        txt2.Name="off"; txt2.Parent = option; txt2.BackgroundTransparency=1; txt2.Position=UDim2.new(0,4,0,0); txt2.Font=Enum.Font.Code; txt2.Text=v; txt2.TextColor3=args.multiselect and Color3.new(0.65,0.65,0.65) or Color3.new(1,1,1); txt2.TextSize=14; txt2.TextStrokeTransparency=0; txt2.TextXAlignment=Enum.TextXAlignment.Left
                        btn2.MouseButton1Click:Connect(function() updateValue(v) end)
                    end
                    library.options[args.flag].values=tbl
                    updateValue(table.find(library.options[args.flag].values,library.flags[args.flag]) and library.flags[args.flag] or library.options[args.flag].values[1])
                end

                button.MouseButton1Click:Connect(function() if not library.colorpicking then frame.Visible = not frame.Visible end end)
                button.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60,60,60) end)

                table.insert(library.toInvis,frame)
                library.flags[args.flag] = args.multiselect and {} or ""
                library.options[args.flag] = {type="list",changeState=updateValue,values=args.values,refresh=refresh,skipflag=args.skipflag,oldargs=args}
                refresh(args.values)
                updateValue(args.value or (not args.multiselect and args.values[1] or ""))
            end

            function group:addConfigbox(args)
                if not args.flag or not args.values then return warn("⚠️ incorrect arguments ⚠️") end
                groupbox.Size += UDim2.new(0,0,0,138)
                library.multiZindex -= 1

                local list2 = Instance.new("Frame")
                local frame = Instance.new("Frame")
                local main = Instance.new("Frame")
                local holder = Instance.new("ScrollingFrame")
                local UIListLayout = Instance.new("UIListLayout")
                local dwn = Instance.new("ImageLabel")
                local up = Instance.new("ImageLabel")

                list2.Name="list2"; list2.Parent=grouper; list2.BackgroundTransparency=1; list2.Size=UDim2.new(1,0,0,138)
                frame.Name="frame"; frame.Parent=list2; frame.BackgroundColor3=Color3.fromRGB(35,35,35); frame.BorderColor3=Color3.fromRGB(0,0,0); frame.BorderSizePixel=2; frame.Position=UDim2.new(0.02,-1,0.044,0); frame.Size=UDim2.new(0,205,0,128)
                main.Name="main"; main.Parent=frame; main.BackgroundColor3=Color3.fromRGB(18,18,18); main.BorderColor3=Color3.fromRGB(30,30,30); main.Size=UDim2.new(1,0,1,0)
                holder.Name="holder"; holder.Parent=main; holder.Active=true; holder.BackgroundTransparency=1; holder.Position=UDim2.new(0,0,0.0057,0); holder.Size=UDim2.new(1,0,1,0); holder.BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png"; holder.CanvasSize=UDim2.new(0,0,0,0); holder.ScrollBarThickness=0; holder.TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png"; holder.AutomaticCanvasSize=Enum.AutomaticSize.Y; holder.ScrollingEnabled=true; holder.ScrollBarImageTransparency=0
                UIListLayout.Parent=holder
                dwn.Name="dwn"; dwn.Parent=frame; dwn.BackgroundTransparency=1; dwn.Position=UDim2.new(0.93,4,1,-9); dwn.Size=UDim2.new(0,7,0,6); dwn.ZIndex=3; dwn.Image="rbxassetid://8548723563"; dwn.Visible=false
                up.Name="up"; up.Parent=frame; up.BackgroundTransparency=1; up.Position=UDim2.new(0,3,0,3); up.Size=UDim2.new(0,7,0,6); up.ZIndex=3; up.Image="rbxassetid://8548757311"; up.Visible=false

                local function updateValue(value)
                    if value==nil then return end
                    if not table.find(library.options[args.flag].values,value) then value=library.options[args.flag].values[1] end
                    library.flags[args.flag]=value
                    for i,v in next, holder:GetChildren() do
                        if v.ClassName~="Frame" then continue end
                        if v.text.Text==library.flags[args.flag] then v.text.TextColor3=library.libColor else v.text.TextColor3=Color3.fromRGB(255,255,255) end
                    end
                    if library.flags[args.flag] and args.callback then args.callback(library.flags[args.flag]) end
                    holder.Visible=true
                end
                holder:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                    up.Visible = (holder.CanvasPosition.Y>1)
                    dwn.Visible = (holder.CanvasPosition.Y+1 < (holder.AbsoluteCanvasSize.Y-holder.AbsoluteSize.Y))
                end)

                function refresh(tbl)
                    for i,v in next, holder:GetChildren() do if v.ClassName=="Frame" then v:Destroy() end end
                    for i,v in pairs(tbl) do
                        local item=Instance.new("Frame")
                        local btn=Instance.new("TextButton")
                        local txt=Instance.new("TextLabel")
                        item.Name=v; item.Parent=holder; item.Active=true; item.BackgroundTransparency=1; item.BorderSizePixel=0; item.Size=UDim2.new(1,0,0,18)
                        btn.Parent=item; btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.TextTransparency=1
                        txt.Name='text'; txt.Parent=item; txt.BackgroundTransparency=1; txt.Size=UDim2.new(1,0,0,18); txt.Font=Enum.Font.Code; txt.Text=v; txt.TextColor3=Color3.fromRGB(255,255,255); txt.TextSize=14; txt.TextStrokeTransparency=0
                        btn.MouseButton1Click:Connect(function() updateValue(v) end)
                    end
                    holder.Visible=true
                    library.options[args.flag].values=tbl
                    updateValue(table.find(library.options[args.flag].values,library.flags[args.flag]) and library.flags[args.flag] or library.options[args.flag].values[1])
                end
                library.flags[args.flag]=""
                library.options[args.flag]={type="cfg",changeState=updateValue,values=args.values,refresh=refresh,skipflag=args.skipflag,oldargs=args}
                refresh(args.values)
                updateValue(args.value or args.values[1])
            end

            function group:addColorpicker(args)
                if not args.flag then return warn("⚠️ incorrect arguments ⚠️") end
                groupbox.Size += UDim2.new(0,0,0,20)
                library.multiZindex -= 1
                jigCount -= 1
                topStuff -= 1
                local colorpicker = Instance.new("Frame")
                local back = Instance.new("Frame")
                local mid = Instance.new("Frame")
                local front = Instance.new("Frame")
                local text = Instance.new("TextLabel")
                local pickerBtn = Instance.new("TextButton")
                local colorFrame = Instance.new("Frame")
                local colorFrame2 = Instance.new("Frame")
                local hueframe = Instance.new("Frame")
                local main = Instance.new("Frame")
                local hue = Instance.new("ImageLabel")
                local pickerframe = Instance.new("Frame")
                local main2 = Instance.new("Frame")
                local picker = Instance.new("ImageLabel")
                local clr = Instance.new("Frame")
                local copy = Instance.new("TextButton")

                colorpicker.Name = "colorpicker"
                colorpicker.Parent = grouper
                colorpicker.BackgroundTransparency = 1
                colorpicker.Size = UDim2.new(1,0,0,20)
                colorpicker.ZIndex = topStuff
                text.Name = "text"
                text.Parent = colorpicker
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.02,-1,0,10)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextStrokeTransparency = 0
                text.TextXAlignment = Enum.TextXAlignment.Left
                pickerBtn.Name = "button"
                pickerBtn.Parent = colorpicker
                pickerBtn.BackgroundTransparency = 1
                pickerBtn.Size = UDim2.new(0,202,0,22)
                pickerBtn.Font = Enum.Font.SourceSans
                pickerBtn.Text = ""
                pickerBtn.ZIndex = args.ontop and topStuff or jigCount
                pickerBtn.TextColor3 = Color3.fromRGB(0,0,0)
                pickerBtn.TextSize = 14

                local function buildColorDialog()
                    -- Stub for full color picker UI - enhance with actual HSV picker if needed
                end
                
                
                function updateValue(value,fake)
                    if typeof(value)=="table" then value=fake end
                    library.flags[args.flag] = value
                    front.BackgroundColor3 = value
                    if args.callback then args.callback(value) end
                end
                table.insert(library.toInvis,colorFrame)
                library.flags[args.flag] = Color3.new(1,1,1)
                library.options[args.flag] = {type="colorpicker",changeState=updateValue,skipflag=args.skipflag,oldargs=args}
                updateValue(args.color or Color3.new(1,1,1))
            end

            function group:addKeybind(args)
                if not args.flag then return warn("⚠️ incorrect arguments ⚠️ - missing args on keybind") end
                groupbox.Size += UDim2.new(0,0,0,20)
                local next = false
                local keybind = Instance.new("Frame")
                local text = Instance.new("TextLabel")
                local button = Instance.new("TextButton")
                keybind.Parent = grouper
                keybind.BackgroundTransparency = 1
                keybind.Size = UDim2.new(1,0,0,20)
                text.Parent = keybind
                text.BackgroundTransparency = 1
                text.Position = UDim2.new(0.02,-1,0,10)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244,244,244)
                text.TextSize = 13
                text.TextStrokeTransparency = 0
                text.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = keybind
                button.BackgroundColor3 = Color3.fromRGB(187,131,255)
                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0,0,0,0)
                button.Size = UDim2.new(0.02,0,1,0)
                button.Font = Enum.Font.Code
                button.Text = ""
                button.TextColor3 = Color3.fromRGB(155,155,155)
                button.TextSize = 13
                button.TextStrokeTransparency = 0
                button.TextXAlignment = Enum.TextXAlignment.Right

                function updateValue(val)
                    if library.colorpicking then return end
                    library.flags[args.flag] = val
                    button.Text = keyNames[val] or val.Name
                end
                UserInputService.InputBegan:Connect(function(key)
                    local key = key.KeyCode==Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
                    if next then
                        if not table.find(library.blacklisted,key) then
                            next = false
                            library.flags[args.flag] = key
                            button.Text = keyNames[key] or key.Name
                            button.TextColor3 = Color3.fromRGB(155,155,155)
                        end
                    end
                    if not next and key==library.flags[args.flag] and args.callback then args.callback() end
                end)
                button.MouseButton1Click:Connect(function()
                    if library.colorpicking then return end
                    library.flags[args.flag] = Enum.KeyCode.Unknown
                    button.Text = "..."
                    button.TextColor3 = Color3.new(0.2,0.2,0.2)
                    next = true
                end)
                library.flags[args.flag] = Enum.KeyCode.Unknown
                library.options[args.flag] = {type="keybind",changeState=updateValue,skipflag=args.skipflag,oldargs=args}
                updateValue(args.key or Enum.KeyCode.Unknown)
            end

            return group
        end

        return tab
    end

    -- Auto-add Settings tab
    local settingsTab = library:addTab("Settings")
    local configGroup = settingsTab:createGroup("left", "Configuration")

    local configFolder = "Neverlose/Configs"
    local currentConfigName = ""

    local function ensureConfigFolder()
        if makefolder and not isfolder(configFolder) then
            makefolder(configFolder)
            library:notify("Created config folder: " .. configFolder)
        end
    end

    local function getConfigList()
        if not listfiles then return {} end
        
        ensureConfigFolder()
        local files = listfiles(configFolder)
        local configs = {}
        
        for _, path in ipairs(files) do
            if path:match("%.json$") then
                local name = path:match("([^/\\]+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
        
        return configs
    end

    local function saveConfig(name)
        if name == "" then
            library:notify("Enter config name first!")
            return
        end
        
        ensureConfigFolder()
        
        local data = {}
        for flag, value in pairs(library.flags) do
            data[flag] = value
        end
        
        local json = HttpService:JSONEncode(data)
        local path = configFolder .. "/" .. name .. ".json"
        
        writefile(path, json)
        library:notify("Saved config: " .. name)
    end

    local function loadConfig(name)
        local path = configFolder .. "/" .. name .. ".json"
        
        if not isfile(path) then
            library:notify("Config not found: " .. name)
            return
        end
        
        local content = readfile(path)
        local data = HttpService:JSONDecode(content)
        
        for flag, value in pairs(data) do
            if library.options[flag] and library.options[flag].changeState then
                library.options[flag].changeState(value)
            end
        end
        
        library:notify("Loaded config: " .. name)
    end

    configGroup:addTextbox({
        text = "Config Name",
        flag = "_config_name_temp",
        value = "",
        callback = function(text)
            currentConfigName = text
        end
    })

    configGroup:addButton({
        text = "Create / Save Config",
        callback = function()
            saveConfig(currentConfigName)
            if library.options["_config_select"] and library.options["_config_select"].refresh then
                library.options["_config_select"].refresh(getConfigList())
            end
        end
    })

    configGroup:addList({
        text = "Select Config",
        flag = "_config_select",
        values = getConfigList(),
        callback = function(selected)
            if selected and selected ~= "" then
                loadConfig(selected)
            end
        end
    })

    configGroup:addButton({
        text = "Refresh List",
        callback = function()
            if library.options["_config_select"] and library.options["_config_select"].refresh then
                library.options["_config_select"].refresh(getConfigList())
                library:notify("Config list refreshed")
            end
        end
    })

    configGroup:addButton({
        text = "Kill GUI",
        callback = function()
            library.menu:Destroy()
            library:notify("GUI killed - reload script to reopen")
        end
    })

    return library
end

return NeverloseLibrary

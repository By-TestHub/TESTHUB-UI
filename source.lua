local UILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local uiWidth = isMobile and 450 or 700
local uiHeight = isMobile and 300 or 500
local topBarHeight = isMobile and 50 or 70
local tabWidth = isMobile and 120 or 200
local elementHeight = isMobile and 40 or 50
local textSizeL = isMobile and 18 or 26
local textSizeM = isMobile and 14 or 18
local textSizeS = isMobile and 12 or 16

local function CreateElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do element[prop] = value end
    return element
end

function UILibrary:CreateWindow(title)
    local window = {}
    local tabs = {}

    local targetParent
    pcall(function() targetParent = (gethui and gethui()) or CoreGui end)
    if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui") end

    local ScreenGui = CreateElement("ScreenGui", { Name = "WackUI", Parent = targetParent, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Global })

    local ToggleBtn = CreateElement("ImageButton", {
        Parent = ScreenGui, Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.5, -30, 0, 20),
        BackgroundTransparency = 1, Image = "rbxthumb://type=Asset&id=130479189445108&w=150&h=150", 
        Visible = false, 
        Active = true, ZIndex = 999
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
    CreateElement("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 2.5, Parent = ToggleBtn})

    local tDrag, tStart, tPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDrag = true; tStart = input.Position; tPos = ToggleBtn.Position
            local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then tDrag = false conn:Disconnect() end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tStart
            ToggleBtn.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + delta.X, tPos.Y.Scale, tPos.Y.Offset + delta.Y)
        end
    end)

    local MainFrame = CreateElement("Frame", { 
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(15, 15, 15), 
        BorderSizePixel = 0, Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2), 
        Size = UDim2.new(0, uiWidth, 0, uiHeight), ClipsDescendants = true, Visible = true, 
        Active = true, Selectable = true 
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = MainFrame})
    CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 3, Transparency = 0.5, Parent = MainFrame})

    local TopBar = CreateElement("Frame", { Name = "TopBar", Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(10, 10, 10), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, topBarHeight), Active = true })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = TopBar})

    CreateElement("TextLabel", { Parent = TopBar, BackgroundTransparency = 1, Position = UDim2.new(0, isMobile and 15 or 25, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = title, TextColor3 = Color3.fromRGB(0, 200, 255), TextSize = textSizeL, TextXAlignment = Enum.TextXAlignment.Left })

    local closeBtnSize = isMobile and 30 or 40
    local CloseButton = CreateElement("TextButton", { Parent = TopBar, BackgroundColor3 = Color3.fromRGB(255, 80, 80), Position = UDim2.new(1, -(closeBtnSize + 15), 0.5, -(closeBtnSize/2)), Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize), Font = Enum.Font.GothamBold, Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, Active = true })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = CloseButton})

    local MinimizeButton = CreateElement("TextButton", { Parent = TopBar, BackgroundColor3 = Color3.fromRGB(255, 200, 80), Position = UDim2.new(1, -(closeBtnSize * 2 + 25), 0.5, -(closeBtnSize/2)), Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize), Font = Enum.Font.GothamBold, Text = "-", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, Active = true })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MinimizeButton})

    local UI_Visible = true
    local function ToggleUIVisibility() 
        UI_Visible = not UI_Visible 
        MainFrame.Visible = UI_Visible 
        ToggleBtn.Visible = not UI_Visible 
    end
    MinimizeButton.MouseButton1Click:Connect(ToggleUIVisibility)
    ToggleBtn.MouseButton1Click:Connect(ToggleUIVisibility)
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local TabContainer = CreateElement("Frame", { Name = "TabContainer", Parent = MainFrame, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, topBarHeight), Size = UDim2.new(0, tabWidth, 1, -topBarHeight), Active = true })
    CreateElement("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top })
    
    local ContentFrame = CreateElement("Frame", { Name = "ContentFrame", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, tabWidth + 10, 0, topBarHeight + 10), Size = UDim2.new(1, -(tabWidth + 20), 1, -(topBarHeight + 20)), Active = true })

    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
            local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false conn:Disconnect() end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    function window:SwitchToTab(tabToSelect)
        for _, tab in pairs(tabs) do tab.Page.Visible = false tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25) tab.Button.TextColor3 = Color3.fromRGB(220, 220, 220) end
        tabToSelect.Page.Visible = true tabToSelect.Button.BackgroundColor3 = Color3.fromRGB(0, 200, 255) tabToSelect.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    function window:CreateTab(name)
        local tab = {}
        tab.Button = CreateElement("TextButton", { Parent = TabContainer, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(1, -10, 0, elementHeight), Font = Enum.Font.GothamBold, Text = name, TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = textSizeM, Active = true })
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tab.Button})
        
        tab.Page = CreateElement("ScrollingFrame", { 
            Parent = ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), 
            ScrollBarThickness = isMobile and 2 or 5, Visible = false, Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y 
        })
        CreateElement("UIListLayout", {Parent = tab.Page, Padding = UDim.new(0, 10)})
        table.insert(tabs, tab)

        tab.Button.MouseButton1Click:Connect(function() window:SwitchToTab(tab) end)
        if #tabs == 1 then window:SwitchToTab(tab) end

        function tab:CreateButton(text, callback)
            local btnFrame = CreateElement("Frame", { Parent = tab.Page, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(1, -10, 0, elementHeight), Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = btnFrame})
            
            local button = CreateElement("TextButton", { Parent = btnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, Active = true })
            
            button.MouseButton1Click:Connect(function()
                button.TextColor3 = Color3.fromRGB(0, 200, 255)
                task.wait(0.1)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                pcall(callback)
            end)
        end

        function tab:CreateToggle(text, callback)
            local tglFrame = CreateElement("Frame", { Parent = tab.Page, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(1, -10, 0, elementHeight), Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tglFrame})
            CreateElement("TextLabel", { Parent = tglFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.7, 0, 1, 0), Font = Enum.Font.GothamBold, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, TextXAlignment = Enum.TextXAlignment.Left })
            
            local toggleBtn = CreateElement("TextButton", { Parent = tglFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Position = UDim2.new(1, -(isMobile and 65 or 75), 0.5, -15), Size = UDim2.new(0, isMobile and 50 or 60, 0, 30), Text = "", Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleBtn})
            local dot = CreateElement("Frame", { Parent = toggleBtn, BackgroundColor3 = Color3.fromRGB(150, 150, 150), Position = UDim2.new(0, 5, 0.5, -10), Size = UDim2.new(0, 20, 0, 20) })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})
            
            local state = false
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 40, 40)
                dot.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                dot.Position = state and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 5, 0.5, -10)
                pcall(callback, state)
            end)
        end

        function tab:CreateSlider(text, min, max, default, callback)
            local sldFrame = CreateElement("Frame", { Parent = tab.Page, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(1, -10, 0, isMobile and 55 or 60), Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = sldFrame})
            CreateElement("TextLabel", { Parent = sldFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(0.5, 0, 0.4, 0), Font = Enum.Font.GothamBold, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, TextXAlignment = Enum.TextXAlignment.Left })
            
            local valLabel = CreateElement("TextLabel", { Parent = sldFrame, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 5), Size = UDim2.new(0.5, -15, 0.4, 0), Font = Enum.Font.Gotham, Text = tostring(default), TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = textSizeS, TextXAlignment = Enum.TextXAlignment.Right })
            
            local bar = CreateElement("TextButton", { Parent = sldFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Position = UDim2.new(0.05, 0, 0.6, 0), Size = UDim2.new(0.9, 0, 0.25, 0), Text = "", Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})
            local fill = CreateElement("Frame", { Parent = bar, BackgroundColor3 = Color3.fromRGB(0, 200, 255), Size = UDim2.new((default - min) / (max - min), 0, 1, 0) })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

            local dragging = false
            local function update(input)
                local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ratio * (max - min) + 0.5)
                fill.Size = UDim2.new(ratio, 0, 1, 0); valLabel.Text = tostring(val)
                pcall(callback, val)
            end

            bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
        end

        -- 🔥 ฟังก์ชันใหม่: Multi-Select Dropdown (เลือกได้หลายอัน สวยๆ)
        function tab:CreateMultiSelect(text, options, callback)
            local selectedItems = {}
            local isOpen = false

            -- 📌 ปุ่มหลักสำหรับกดเปิด/ปิด
            local mainFrame = CreateElement("Frame", { Parent = tab.Page, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(1, -10, 0, elementHeight), Active = true })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})
            
            local mainBtn = CreateElement("TextButton", { Parent = mainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold, Text = text .. " : เลือก...", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
            CreateElement("UIPadding", {Parent = mainBtn, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 40)})
            
            local arrow = CreateElement("TextLabel", { Parent = mainFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0), Font = Enum.Font.GothamBold, Text = "v", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = textSizeM })

            -- 📌 กรอบสำหรับใส่ตัวเลือก (ซ่อนไว้ตอนแรก)
            local optionsFrame = CreateElement("Frame", { Parent = tab.Page, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Size = UDim2.new(1, -10, 0, 0), ClipsDescendants = true, Visible = false })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = optionsFrame})
            local listLayout = CreateElement("UIListLayout", { Parent = optionsFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
            CreateElement("UIPadding", {Parent = optionsFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

            -- 📌 สร้างปุ่มตัวเลือกแต่ละอัน
            for _, option in pairs(options) do
                local optBtn = CreateElement("TextButton", { Parent = optionsFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, isMobile and 35 or 40), Font = Enum.Font.Gotham, Text = option, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = textSizeM })
                CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = optBtn})

                local isSelected = false
                optBtn.MouseButton1Click:Connect(function()
                    isSelected = not isSelected
                    if isSelected then
                        -- ✅ ตอนเลือก
                        optBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                        optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optBtn.Text = "✅ " .. option
                        table.insert(selectedItems, option)
                    else
                        -- ❌ ตอนยกเลิก
                        optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        optBtn.Text = option
                        for i, v in ipairs(selectedItems) do
                            if v == option then
                                table.remove(selectedItems, i)
                                break
                            end
                        end
                    end

                    -- อัปเดตข้อความบนปุ่มหลักให้เห็นว่าเลือกอะไรไปบ้าง
                    if #selectedItems > 0 then
                        mainBtn.Text = text .. " : " .. table.concat(selectedItems, ", ")
                    else
                        mainBtn.Text = text .. " : เลือก..."
                    end
                    
                    -- ส่งค่าที่เลือกกลับไปให้สคริปต์
                    pcall(callback, selectedItems)
                end)
            end

            -- 📌 ระบบเปิด/ปิด Dropdown แบบสมูท
            mainBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                optionsFrame.Visible = true
                
                -- คำนวณความสูงตามจำนวนของ
                local targetHeight = isOpen and (listLayout.AbsoluteContentSize.Y + 10) or 0
                arrow.Text = isOpen and "^" or "v"
                
                local tween = TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, targetHeight)})
                tween:Play()
                
                if not isOpen then
                    tween.Completed:Wait()
                    optionsFrame.Visible = false
                end
            end)
        end

        return tab
    end
    return window
end

return UILibrary

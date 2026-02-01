local uis = game:GetService("UserInputService") local ts = game:GetService("TweenService") local rs = game:GetService("RunService") local plr = game.Players.LocalPlayer local pgui = plr:WaitForChild("PlayerGui") local sg = game:GetService("StarterGui")

rs.Stepped:Connect(function() pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) end)

if pgui:FindFirstChild("UltraInventory_FinalFix") then pgui.UltraInventory_FinalFix:Destroy() end

local gui = Instance.new("ScreenGui") gui.Name = "UltraInventory_FinalFix" gui.ResetOnSpawn = false gui.Parent = pgui

local SLOT_S = 60 local PAD = 8 local W_TOTAL = (10 * SLOT_S) + (9 * PAD) local Y_SHOW = 0.9 local Y_HIDE = 1.3

local main = Instance.new("Frame", gui) main.Size = UDim2.new(0, W_TOTAL + 24, 0, SLOT_S + 24) main.Position = UDim2.new(0.5, -(W_TOTAL + 24)/2, Y_HIDE, 0) main.BackgroundColor3 = Color3.fromRGB(18, 18, 22) main.BackgroundTransparency = 0.2

local st = Instance.new("UIStroke", main) st.Color = Color3.new(1,1,1) st.Transparency = 0.85 st.Thickness = 1.2

local cr = Instance.new("UICorner", main) cr.CornerRadius = UDim.new(0, 14)

local slots = {} local cache_names = {} local current_loadout = {} local dragging = nil local ghost_icon = nil

for i = 1, 10 do local f = Instance.new("Frame", main) f.Size = UDim2.new(0, SLOT_S, 0, SLOT_S) f.Position = UDim2.new(0, 12 + (i-1)*(SLOT_S+PAD), 0, 12) f.BackgroundColor3 = Color3.fromRGB(35, 35, 40) f.BackgroundTransparency = 0.6

local c = Instance.new("UICorner", f)
c.CornerRadius = UDim.new(0, 10)

local num = Instance.new("TextLabel", f)
num.Text = (i==10 and "0" or i)
num.Font = Enum.Font.GothamBold
num.TextSize = 14
num.TextColor3 = Color3.fromRGB(100,100,100)
num.Size = UDim2.new(0,20,0,20)
num.BackgroundTransparency = 1

local ico = Instance.new("ImageLabel", f)
ico.Size = UDim2.new(0.65,0,0.65,0)
ico.AnchorPoint = Vector2.new(0.5,0.5)
ico.Position = UDim2.new(0.5,0,0.5,0)
ico.BackgroundTransparency = 1
ico.ScaleType = Enum.ScaleType.Fit

local txt = Instance.new("TextLabel", f)
txt.Size = UDim2.new(0.9,0,0.3,0)
txt.Position = UDim2.new(0.05,0,0.7,0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.new(1,1,1)
txt.TextScaled = true
txt.Font = Enum.Font.GothamMedium

local btn = Instance.new("TextButton", f)
btn.Size = UDim2.new(1,0,1,0)
btn.BackgroundTransparency = 1
btn.Text = ""

slots[i] = {f=f, ico=ico, txt=txt, btn=btn}

btn.MouseButton1Down:Connect(function()
	if current_loadout[i] then
		dragging = {idx=i, item=current_loadout[i]}
		ghost_icon = f:Clone()
		ghost_icon.Parent = gui
		ghost_icon.BackgroundTransparency = 0.5
		ghost_icon.ZIndex = 500
		ghost_icon:ClearAllChildren()
		local im = ico:Clone(); im.Parent = ghost_icon
		local tx = txt:Clone(); tx.Parent = ghost_icon
	end
end)

btn.MouseButton1Click:Connect(function()
	if not dragging and current_loadout[i] then
		local ch = plr.Character
		local h = ch and ch:FindFirstChild("Humanoid")
		if h and h.Health > 0 then
			if current_loadout[i].Parent == ch then 
				h:UnequipTools() 
			else 
				h:EquipTool(current_loadout[i]) 
			end
		end
	end
end)
end

local function refresh() for i=1, 10 do local tool = current_loadout[i] local s = slots[i]

	if tool and tool.Parent then
		s.txt.Text = tool.Name
		
		if tool.Parent == plr.Character then
			ts:Create(s.f, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 200), BackgroundTransparency = 0.2}):Play()
		else
			ts:Create(s.f, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40), BackgroundTransparency = 0.6}):Play()
		end
		
		if tool.TextureId ~= "" then
			s.ico.Image = tool.TextureId
			s.ico.Visible = true
			s.txt.Visible = false
		else
			s.ico.Image = ""
			s.ico.Visible = false
			s.txt.Visible = true
		end
	else
		s.txt.Text = ""
		s.ico.Image = ""
		s.ico.Visible = false
		ts:Create(s.f, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30), BackgroundTransparency = 0.8}):Play()
	end
end
end

local function sync_inventory() local avail = {} if plr.Character then for _, v in pairs(plr.Character:GetChildren()) do if v:IsA("Tool") then table.insert(avail, v) end end end for _, v in pairs(plr.Backpack:GetChildren()) do if v:IsA("Tool") then table.insert(avail, v) end end

local assigned = {}
table.clear(current_loadout)

for i=1, 10 do
	local sn = cache_names[i]
	if sn then
		for _, t in pairs(avail) do
			if t.Name == sn and not assigned[t] then
				current_loadout[i] = t
				assigned[t] = true
				break
			end
		end
	end
end

for _, t in pairs(avail) do
	if not assigned[t] then
		for i=1, 10 do
			if not current_loadout[i] then
				current_loadout[i] = t
				cache_names[i] = t.Name
				assigned[t] = true
				break
			end
		end
	end
end

refresh()
end

local function intro_anim() main.Visible = true for i, s in ipairs(slots) do s.f.Position = UDim2.new(0, 12 + (i-1)*(SLOT_S+PAD), 1, 50) s.f.BackgroundTransparency = 1 s.ico.ImageTransparency = 1 s.txt.TextTransparency = 1 end

local tm = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
ts:Create(main, tm, {Position = UDim2.new(0.5, -(W_TOTAL + 24)/2, Y_SHOW, 0)}):Play()

for i, s in ipairs(slots) do
	task.wait(0.03)
	local t = TweenInfo.new(0.4, Enum.EasingStyle.Back)
	ts:Create(s.f, t, {Position = UDim2.new(0, 12 + (i-1)*(SLOT_S+PAD), 0, 12), BackgroundTransparency = 0.6}):Play()
	ts:Create(s.ico, t, {ImageTransparency = 0}):Play()
	ts:Create(s.txt, t, {TextTransparency = 0}):Play()
end
end

local function outro_anim() local t = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In) ts:Create(main, t, {Position = UDim2.new(0.5, -(W_TOTAL + 24)/2, Y_HIDE, 0)}):Play() end

uis.InputChanged:Connect(function(io) if ghost_icon and io.UserInputType == Enum.UserInputType.MouseMovement then local m = uis:GetMouseLocation() ghost_icon.Position = UDim2.new(0, m.X - SLOT_S/2, 0, m.Y - SLOT_S/2 - 36) end end)

uis.InputEnded:Connect(function(io) if io.UserInputType == Enum.UserInputType.MouseButton1 and dragging then local m = uis:GetMouseLocation() local drop_i = nil

	for i, s in pairs(slots) do
		local ap = s.f.AbsolutePosition
		local as = s.f.AbsoluteSize
		if m.X >= ap.X and m.X <= ap.X+as.X and (m.Y-36) >= ap.Y and (m.Y-36) <= ap.Y+as.Y then
			drop_i = i; break
		end
	end
	
	if drop_i and drop_i ~= dragging.idx then
		local n1 = cache_names[dragging.idx]
		local n2 = cache_names[drop_i]
		cache_names[drop_i] = n1
		cache_names[dragging.idx] = n2
		sync_inventory()
	end
	
	if ghost_icon then ghost_icon:Destroy() end
	dragging = nil
end
end)

uis.InputBegan:Connect(function(io, gp) if gp then return end if io.KeyCode.Value >= 48 and io.KeyCode.Value <= 57 then local k = io.KeyCode.Value - 48; if k==0 then k=10 end if current_loadout[k] and plr.Character then local h = plr.Character:FindFirstChild("Humanoid") if h and h.Health > 0 then if current_loadout[k].Parent == plr.Character then h:UnequipTools() else h:EquipTool(current_loadout[k]) end end end end end)

local function setup_char(char) local hum = char:WaitForChild("Humanoid", 10) if not hum then return end

main.Position = UDim2.new(0.5, -(W_TOTAL + 24)/2, Y_HIDE, 0)

char.ChildAdded:Connect(function(c) if c:IsA("Tool") then sync_inventory() end end)
char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then sync_inventory() end end)

hum.Died:Connect(function()
	outro_anim()
end)

task.wait(0.2)
sync_inventory()
intro_anim()
end

plr.CharacterAdded:Connect(setup_char) plr.Backpack.ChildAdded:Connect(sync_inventory) plr.Backpack.ChildRemoved:Connect(sync_inventory) rs.RenderStepped:Connect(refresh)

if plr.Character then setup_char(plr.Character) end

-- Obrigado por ver esté codigo ❤️👀

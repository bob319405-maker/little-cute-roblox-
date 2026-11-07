--!nonstrict
-- ModelBuilder: builds the cute pet and egg models out of plain Parts, so the
-- game works without any uploaded meshes. Swap in real meshes later if you like;
-- the rest of the game only needs the returned Model.
--
-- Every model is built at the origin facing -Z (Roblox "front") with its pivot
-- on the ground under its feet. Use model:PivotTo(cframe) to place it.

local PetData = require(script.Parent.PetData)

local ModelBuilder = {}

local OUTLINE_BLACK = Color3.fromRGB(35, 30, 40)
local CHEEK_PINK = Color3.fromRGB(255, 140, 170)
local WHITE = Color3.fromRGB(255, 255, 255)

----------------------------------------------------------------------
-- Part helpers
----------------------------------------------------------------------

local function basePart(name: string, size: Vector3, color: Color3, cframe: CFrame, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = true
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- An ellipsoid ("squishy blob"). A block Part with a sphere SpecialMesh stretches
-- to the part's size, unlike Shape = Ball which is always a perfect sphere.
local function blob(name: string, size: Vector3, color: Color3, cframe: CFrame, parent: Instance): Part
	local part = basePart(name, size, color, cframe, parent)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = part
	return part
end

local function block(name: string, size: Vector3, color: Color3, cframe: CFrame, parent: Instance): Part
	return basePart(name, size, color, cframe, parent)
end

-- Vertical cylinder (Roblox cylinders point along X, so rotate them upright).
local function cylinder(name: string, height: number, diameter: number, color: Color3, position: Vector3, parent: Instance): Part
	local part = basePart(
		name,
		Vector3.new(height, diameter, diameter),
		color,
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		parent
	)
	part.Shape = Enum.PartType.Cylinder
	return part
end

-- Parts tagged "Tint" take on Golden / Rainbow mutation colors.
local function tint(part: BasePart)
	part:SetAttribute("Tint", true)
end

----------------------------------------------------------------------
-- Pet pieces
----------------------------------------------------------------------

local BODY_SIZE = Vector3.new(3, 2.8, 2.8)
local BODY_Y = 1.6 -- body bottom sits at y = 0.2, feet fill the gap

local function addFace(model: Model, eyeY: number, eyeZ: number, eyeSpread: number, withMouth: boolean)
	for _, side in { -1, 1 } do
		blob("Eye", Vector3.new(0.45, 0.6, 0.3), OUTLINE_BLACK, CFrame.new(side * eyeSpread, eyeY, eyeZ), model)
		local shine = blob(
			"EyeShine",
			Vector3.new(0.18, 0.18, 0.1),
			WHITE,
			CFrame.new(side * eyeSpread - 0.08, eyeY + 0.13, eyeZ - 0.15),
			model
		)
		shine.Material = Enum.Material.Neon
		blob("Cheek", Vector3.new(0.55, 0.3, 0.25), CHEEK_PINK, CFrame.new(side * 0.95, 1.5, -1.05), model)
	end
	if withMouth then
		blob("Mouth", Vector3.new(0.25, 0.12, 0.12), OUTLINE_BLACK, CFrame.new(0, 1.5, -1.36), model)
	end
end

local function addEars(model: Model, style: string, earColor: Color3, innerColor: Color3)
	for _, side in { -1, 1 } do
		if style == "Round" then
			tint(blob("Ear", Vector3.new(0.9, 0.9, 0.5), earColor, CFrame.new(side * 0.85, 2.85, 0), model))
			blob("EarInner", Vector3.new(0.5, 0.5, 0.2), innerColor, CFrame.new(side * 0.85, 2.85, -0.22), model)
		elseif style == "Pointy" then
			local tilt = CFrame.Angles(0, 0, math.rad(45))
			tint(block("Ear", Vector3.new(0.9, 0.9, 0.4), earColor, CFrame.new(side * 0.8, 2.7, 0) * tilt, model))
			block("EarInner", Vector3.new(0.5, 0.5, 0.1), innerColor, CFrame.new(side * 0.8, 2.8, -0.2) * tilt, model)
		elseif style == "Long" then
			local tilt = CFrame.Angles(0, 0, -side * math.rad(12))
			tint(blob("Ear", Vector3.new(0.6, 1.8, 0.4), earColor, CFrame.new(side * 0.55, 3.5, 0) * tilt, model))
			blob("EarInner", Vector3.new(0.3, 1.3, 0.1), innerColor, CFrame.new(side * 0.55, 3.5, -0.18) * tilt, model)
		end
	end
end

local function addStar(model: Model, center: Vector3, color: Color3, radius: number)
	-- Five spikes around a center make a chunky little star.
	for i = 0, 4 do
		local angle = math.rad(i * 72)
		local spike = block(
			"StarSpike",
			Vector3.new(radius * 0.45, radius, 0.15),
			color,
			CFrame.new(center) * CFrame.Angles(0, 0, angle) * CFrame.new(0, radius * 0.45, 0),
			model
		)
		spike.Material = Enum.Material.Neon
	end
	local core = blob("StarCore", Vector3.new(radius * 0.7, radius * 0.7, 0.2), color, CFrame.new(center), model)
	core.Material = Enum.Material.Neon
end

local function addMoon(model: Model, center: Vector3, color: Color3)
	-- A crescent made from a curved row of balls that shrink toward the tips.
	local steps = 9
	for i = 0, steps - 1 do
		local t = i / (steps - 1) -- 0..1
		local angle = math.rad(-130 + t * 260)
		local size = 0.25 + 0.3 * math.sin(t * math.pi)
		local offset = Vector3.new(math.sin(angle) * 0.55, math.cos(angle) * 0.55, 0)
		local piece = blob("MoonPiece", Vector3.new(size, size, size), color, CFrame.new(center + offset), model)
		piece.Material = Enum.Material.Neon
	end
end

local function addExtra(model: Model, extra: string?, info: any)
	if extra == "Beak" then
		blob("Beak", Vector3.new(0.9, 0.3, 0.6), info.AccentColor, CFrame.new(0, 1.5, -1.45), model)
	elseif extra == "TopEyes" then
		for _, side in { -1, 1 } do
			tint(blob("EyeBump", Vector3.new(1, 1, 1), info.BodyColor, CFrame.new(side * 0.6, 2.8, -0.45), model))
		end
		-- big happy frog smile
		blob("Mouth", Vector3.new(1.2, 0.12, 0.12), OUTLINE_BLACK, CFrame.new(0, 1.55, -1.37), model)
	elseif extra == "LeafHat" then
		local leafColor = Color3.fromRGB(90, 190, 90)
		for i = 0, 3 do
			local angle = math.rad(i * 90 + 45)
			blob(
				"Leaf",
				Vector3.new(0.9, 0.2, 0.45),
				leafColor,
				CFrame.new(0, 3.0, 0) * CFrame.Angles(0, angle, math.rad(-15)) * CFrame.new(0.4, 0, 0),
				model
			)
		end
		cylinder("Stem", 0.4, 0.15, leafColor, Vector3.new(0, 3.25, 0), model)
		-- seeds dotted on the body
		for _, pos in { Vector3.new(-1.1, 2.1, -0.6), Vector3.new(1.1, 2.0, -0.6), Vector3.new(-1.2, 0.9, -0.5), Vector3.new(1.25, 1.0, -0.4) } do
			blob("Seed", Vector3.new(0.15, 0.22, 0.1), info.AccentColor, CFrame.lookAt(pos, pos * 2), model)
		end
	elseif extra == "Fluff" then
		local fluffSpots = {
			Vector3.new(0, 3.0, 0.1),
			Vector3.new(-0.7, 2.85, 0.2),
			Vector3.new(0.7, 2.85, 0.2),
			Vector3.new(-1.35, 1.9, 0.3),
			Vector3.new(1.35, 1.9, 0.3),
			Vector3.new(-1.2, 1.0, 0.5),
			Vector3.new(1.2, 1.0, 0.5),
			Vector3.new(0, 2.2, 1.3),
		}
		for _, pos in fluffSpots do
			tint(blob("Fluff", Vector3.new(1.1, 1.1, 1.1), info.BodyColor, CFrame.new(pos), model))
		end
	elseif extra == "PandaPatches" then
		for _, side in { -1, 1 } do
			blob(
				"EyePatch",
				Vector3.new(0.8, 0.9, 0.2),
				info.AccentColor,
				CFrame.new(side * 0.6, 1.8, -1.18) * CFrame.Angles(0, 0, side * math.rad(-25)),
				model
			)
		end
		-- boba cup held at the side
		local cup = cylinder("BobaCup", 1.0, 0.75, Color3.fromRGB(235, 205, 170), Vector3.new(1.5, 1.2, -0.7), model)
		cup.Transparency = 0.25
		cylinder("BobaLid", 0.08, 0.8, Color3.fromRGB(255, 160, 190), Vector3.new(1.5, 1.72, -0.7), model)
		cylinder("Straw", 0.6, 0.12, Color3.fromRGB(255, 120, 160), Vector3.new(1.55, 2.0, -0.65), model)
		for _, pos in { Vector3.new(1.4, 0.85, -0.85), Vector3.new(1.6, 0.85, -0.6), Vector3.new(1.5, 0.95, -0.95) } do
			blob("Pearl", Vector3.new(0.2, 0.2, 0.2), OUTLINE_BLACK, CFrame.new(pos), model)
		end
	elseif extra == "Star" then
		addStar(model, Vector3.new(0, 4.0, 0), info.AccentColor, 0.6)
	elseif extra == "Moon" then
		addMoon(model, Vector3.new(0, 4.9, 0.1), info.AccentColor)
	end
end

----------------------------------------------------------------------
-- Name tag
----------------------------------------------------------------------

local function addNameTag(model: Model, adornee: BasePart, title: string, subtitle: string, color: Color3, height: number)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NameTag"
	gui.Size = UDim2.fromOffset(200, 50)
	gui.StudsOffsetWorldSpace = Vector3.new(0, height, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 60
	gui.Adornee = adornee
	gui.Parent = model

	local function label(text: string, y: number, textColor: Color3, size: number)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0.5, 0)
		l.Position = UDim2.fromScale(0, y)
		l.Font = Enum.Font.FredokaOne
		l.Text = text
		l.TextColor3 = textColor
		l.TextSize = size
		l.TextStrokeTransparency = 0.3
		l.Parent = gui
	end

	label(title, 0, WHITE, 22)
	label(subtitle, 0.5, color, 18)
end

----------------------------------------------------------------------
-- Mutations
----------------------------------------------------------------------

local function applyMutation(model: Model, body: BasePart, mutationName: string?)
	if not mutationName then
		return
	end
	local mutation = PetData.getMutation(mutationName)
	if not mutation then
		return
	end
	model:SetAttribute("Mutation", mutationName)

	if mutationName == "Golden" then
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") and part:GetAttribute("Tint") then
				part.Color = Color3.fromRGB(255, 205, 60)
				part.Material = Enum.Material.Foil
				part.Reflectance = 0.25
			end
		end
	end

	if mutationName == "Rainbow" then
		-- PetAnimator cycles the color of every "Tint" part on models with this attribute.
		model:SetAttribute("Rainbow", true)
	end

	if mutationName == "Shiny" or mutationName == "Golden" or mutationName == "Rainbow" then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = if mutationName == "Golden" then Color3.fromRGB(255, 220, 90) else WHITE
		sparkles.Parent = body
	end

	if mutation.Scale then
		model:ScaleTo(mutation.Scale)
	end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

-- Build a pet. mutationName is optional ("Shiny", "Golden", "Rainbow", "Giant", "Tiny").
function ModelBuilder.buildPet(petId: string, mutationName: string?): Model
	local info = PetData.Pets[petId]
	assert(info, "Unknown pet: " .. tostring(petId))

	local model = Instance.new("Model")
	model.Name = petId
	model:SetAttribute("PetId", petId)

	local body = blob("Body", BODY_SIZE, info.BodyColor, CFrame.new(0, BODY_Y, 0), model)
	tint(body)
	blob("Belly", Vector3.new(1.5, 1.1, 0.5), info.AccentColor, CFrame.new(0, 0.95, -1.12), model)

	-- feet + tail
	for _, side in { -1, 1 } do
		tint(blob("Foot", Vector3.new(0.8, 0.5, 0.9), info.BodyColor, CFrame.new(side * 0.7, 0.25, -0.6), model))
	end
	blob("Tail", Vector3.new(0.7, 0.7, 0.7), info.AccentColor, CFrame.new(0, 0.9, 1.4), model)

	-- face
	if info.Extra == "TopEyes" then
		addFace(model, 2.9, -0.88, 0.6, false)
	else
		addFace(model, 1.85, -1.22, 0.55, info.Extra ~= "Beak")
	end

	-- ears (panda gets dark ears)
	local earColor = if info.Extra == "PandaPatches" then info.AccentColor else info.BodyColor
	local innerColor = if info.Extra == "PandaPatches" then info.AccentColor else CHEEK_PINK
	addEars(model, info.Ears, earColor, innerColor)

	addExtra(model, info.Extra, info)

	model.PrimaryPart = body
	-- pivot on the ground under the pet so PivotTo / ScaleTo keep it standing
	body.PivotOffset = CFrame.new(0, -BODY_Y, 0)

	local rarity = PetData.Rarities[info.Rarity]
	local title = if mutationName then mutationName .. " " .. info.DisplayName else info.DisplayName
	addNameTag(model, body, title, info.Rarity, rarity.Color, 4.2)

	applyMutation(model, body, mutationName)
	return model
end

-- Build an egg for the shop / hatching.
function ModelBuilder.buildEgg(eggId: string): Model
	local info = PetData.Eggs[eggId]
	assert(info, "Unknown egg: " .. tostring(eggId))

	local model = Instance.new("Model")
	model.Name = eggId
	model:SetAttribute("EggId", eggId)

	local radiusXZ, radiusY = 1.1, 1.4
	local center = Vector3.new(0, radiusY, 0)
	local shell = blob("Shell", Vector3.new(radiusXZ * 2, radiusY * 2, radiusXZ * 2), info.ShellColor, CFrame.new(center), model)

	-- spots placed on the egg's surface
	local spots = {
		{ 20, 25 }, { 95, -10 }, { 170, 35 }, { 250, 5 }, { 320, -25 }, { 60, 55 }, { 210, -40 },
	}
	for _, spot in spots do
		local theta = math.rad(spot[1])
		local phi = math.rad(spot[2])
		local dir = Vector3.new(math.cos(phi) * math.sin(theta), math.sin(phi), -math.cos(phi) * math.cos(theta))
		local surfacePoint = center + Vector3.new(dir.X * radiusXZ, dir.Y * radiusY, dir.Z * radiusXZ)
		local normal = Vector3.new(dir.X / radiusXZ, dir.Y / radiusY, dir.Z / radiusXZ).Unit
		local s = blob("Spot", Vector3.new(0.6, 0.6, 0.12), info.SpotColor, CFrame.lookAt(surfacePoint, surfacePoint + normal), model)
		if eggId == "StarryEgg" then
			s.Material = Enum.Material.Neon
		end
	end

	model.PrimaryPart = shell
	shell.PivotOffset = CFrame.new(0, -radiusY, 0)

	addNameTag(model, shell, info.DisplayName, "$" .. tostring(info.Price), Color3.fromRGB(255, 220, 90), 2.2)
	return model
end

return ModelBuilder

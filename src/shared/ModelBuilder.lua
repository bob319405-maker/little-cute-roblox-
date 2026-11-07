--!nonstrict
-- ModelBuilder: builds the cute pet and egg models out of plain Parts, so the
-- game works without any uploaded meshes. Swap in real meshes later if you like;
-- the rest of the game only needs the returned Model.
--
-- Every model is built at the origin facing -Z (Roblox "front") with its pivot
-- on the ground under its feet. Use model:PivotTo(cframe) to place it.
-- How each pet looks is set in PetData (Body, Eyes, Ears, Tail, Feet, Extras).

local PetData = require(script.Parent.PetData)

local ModelBuilder = {}

local OUTLINE_BLACK = Color3.fromRGB(35, 30, 40)
local CHEEK_PINK = Color3.fromRGB(255, 140, 170)
local WHITE = Color3.fromRGB(255, 255, 255)
local TONGUE_PINK = Color3.fromRGB(255, 110, 140)

local EVIL_EYE_RED = Color3.fromRGB(255, 40, 60)
local EVIL_HORN = Color3.fromRGB(120, 15, 35)
local EVIL_WING = Color3.fromRGB(55, 20, 70)
local EVIL_AURA = Color3.fromRGB(150, 60, 220)

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

-- Upright cylinder centered at `position` (Roblox cylinders point along X, so rotate them).
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

local function neon(part: BasePart): BasePart
	part.Material = Enum.Material.Neon
	return part
end

-- Parts tagged "Tint" take on Golden / Rainbow mutation colors.
local function tint(part: BasePart): BasePart
	part:SetAttribute("Tint", true)
	return part
end

local function has(info, extra: string): boolean
	return info.Extras ~= nil and table.find(info.Extras, extra) ~= nil
end

----------------------------------------------------------------------
-- Body math: the body is an ellipsoid with radii rx, ry, rz centered at (0, cy, 0)
----------------------------------------------------------------------

local function makeBody(size: Vector3, float: number)
	local ry = size.Y / 2
	return { rx = size.X / 2, ry = ry, rz = size.Z / 2, cy = float + ry }
end

-- Z of the front (-Z) surface at (x, y).
local function surfZ(b, x: number, y: number): number
	local dx, dy = x / b.rx, (y - b.cy) / b.ry
	return -b.rz * math.sqrt(math.max(0, 1 - dx * dx - dy * dy))
end

-- Point on the front surface; `out` pushes it toward the viewer (negative = sink in).
local function front(b, x: number, y: number, out: number): Vector3
	return Vector3.new(x, y, surfZ(b, x, y) - out)
end

-- Y of the top surface at (x, z).
local function topY(b, x: number, z: number): number
	local dx, dz = x / b.rx, z / b.rz
	return b.cy + b.ry * math.sqrt(math.max(0, 1 - dx * dx - dz * dz))
end

-- Point + outward normal on the body. yaw 0 = front, 90 = right, 180 = back; pitch up from the middle.
local function surfacePoint(b, yawDeg: number, pitchDeg: number): (Vector3, Vector3)
	local yaw, pitch = math.rad(yawDeg), math.rad(pitchDeg)
	local dir = Vector3.new(math.cos(pitch) * math.sin(yaw), math.sin(pitch), -math.cos(pitch) * math.cos(yaw))
	local point = Vector3.new(dir.X * b.rx, b.cy + dir.Y * b.ry, dir.Z * b.rz)
	local normal = Vector3.new(dir.X / b.rx, dir.Y / b.ry, dir.Z / b.rz).Unit
	return point, normal
end

-- A flat blob lying on the body surface (spots, seeds, patches).
local function patch(name: string, b, yawDeg: number, pitchDeg: number, size: Vector3, color: Color3, parent: Instance): Part
	local point, normal = surfacePoint(b, yawDeg, pitchDeg)
	return blob(name, size, color, CFrame.lookAt(point, point + normal), parent)
end

local function addStar(model: Model, center: Vector3, color: Color3, radius: number)
	-- Five spikes around a center make a chunky little star.
	for i = 0, 4 do
		neon(block(
			"StarSpike",
			Vector3.new(radius * 0.45, radius, 0.15),
			color,
			CFrame.new(center) * CFrame.Angles(0, 0, math.rad(i * 72)) * CFrame.new(0, radius * 0.45, 0),
			model
		))
	end
	neon(blob("StarCore", Vector3.new(radius * 0.7, radius * 0.7, 0.2), color, CFrame.new(center), model))
end

----------------------------------------------------------------------
-- Face
----------------------------------------------------------------------

-- Small balls along a curve: used for closed "sleepy" (u) and "happy" (^) eyes.
local function arcEye(model: Model, p: Vector3, upward: boolean)
	for i = 0, 4 do
		local a = math.rad(-70 + 35 * i)
		local y = math.cos(a) * 0.14
		local offset = Vector3.new(math.sin(a) * 0.26, if upward then y - 0.07 else 0.07 - y, -0.05)
		blob("Eye", Vector3.new(0.17, 0.17, 0.15), OUTLINE_BLACK, CFrame.new(p + offset), model)
	end
end

local function drawEye(model: Model, info, p: Vector3, side: number, style: string, evil: boolean)
	if evil then
		-- glowing red eyes with a slit pupil + angry eyebrows
		neon(blob("Eye", Vector3.new(0.45, 0.5, 0.3), EVIL_EYE_RED, CFrame.new(p), model))
		blob("Pupil", Vector3.new(0.1, 0.38, 0.1), OUTLINE_BLACK, CFrame.new(p + Vector3.new(0, 0, -0.14)), model)
		block(
			"Brow",
			Vector3.new(0.6, 0.13, 0.13),
			OUTLINE_BLACK,
			CFrame.new(p + Vector3.new(0, 0.4, -0.06)) * CFrame.Angles(0, 0, side * math.rad(25)),
			model
		)
	elseif style == "Dot" then
		blob("Eye", Vector3.new(0.3, 0.36, 0.25), OUTLINE_BLACK, CFrame.new(p), model)
		neon(blob("EyeShine", Vector3.new(0.1, 0.1, 0.06), WHITE, CFrame.new(p + Vector3.new(-0.05, 0.07, -0.12)), model))
	elseif style == "Sparkle" then
		blob("Eye", Vector3.new(0.55, 0.72, 0.3), OUTLINE_BLACK, CFrame.new(p), model)
		blob("Iris", Vector3.new(0.42, 0.34, 0.12), info.EyeColor or Color3.fromRGB(150, 110, 255), CFrame.new(p + Vector3.new(0, -0.13, -0.11)), model)
		neon(blob("EyeShine", Vector3.new(0.22, 0.22, 0.08), WHITE, CFrame.new(p + Vector3.new(-0.1, 0.16, -0.16)), model))
		neon(blob("EyeShine", Vector3.new(0.12, 0.12, 0.06), WHITE, CFrame.new(p + Vector3.new(0.1, -0.12, -0.18)), model))
	elseif style == "Sleepy" then
		arcEye(model, p, false)
	elseif style == "Happy" then
		arcEye(model, p, true)
	else -- "Big" / "Top"
		blob("Eye", Vector3.new(0.5, 0.65, 0.3), OUTLINE_BLACK, CFrame.new(p), model)
		neon(blob("EyeShine", Vector3.new(0.2, 0.2, 0.08), WHITE, CFrame.new(p + Vector3.new(-0.09, 0.15, -0.15)), model))
		neon(blob("EyeShine", Vector3.new(0.1, 0.1, 0.06), WHITE, CFrame.new(p + Vector3.new(0.08, -0.13, -0.16)), model))
	end
end

-- Builds eyes, cheeks, mouth/nose/beak. Returns where the mouth is (for teeth/fangs).
local function addFace(model: Model, b, info, evil: boolean): Vector3
	local faceOut = info.FaceOut or 0
	local eyeY = b.cy + b.ry * 0.12
	local spread = b.rx * 0.36

	for _, side in { -1, 1 } do
		local x = side * spread
		local p
		if info.Eyes == "Top" then
			-- frog: eyes sit on bumps on top of the head
			local bz = -b.rz * 0.45
			local bump = Vector3.new(x * 1.25, topY(b, x * 1.25, bz) - 0.1, bz)
			tint(blob("EyeBump", Vector3.new(1.05, 1.0, 1.0), info.BodyColor, CFrame.new(bump), model))
			p = bump + Vector3.new(0, 0.05, -0.42)
		else
			p = front(b, x, eyeY, faceOut - 0.05)
		end
		drawEye(model, info, p, side, info.Eyes, evil)

		if not evil then
			blob("Cheek", Vector3.new(0.55, 0.3, 0.25), CHEEK_PINK, CFrame.new(front(b, side * b.rx * 0.62, eyeY - 0.38, faceOut - 0.08)), model)
		end
	end

	local mouthPos
	if has(info, "Beak") then
		local p = front(b, 0, eyeY - 0.42, faceOut + 0.2)
		blob("Beak", Vector3.new(1.0, 0.32, 0.75), info.AccentColor, CFrame.new(p), model)
		blob("BeakLower", Vector3.new(0.75, 0.22, 0.55), info.AccentColor:Lerp(Color3.new(0, 0, 0), 0.15), CFrame.new(p + Vector3.new(0, -0.2, 0.05)), model)
		mouthPos = p + Vector3.new(0, -0.15, -0.05)
	elseif has(info, "Snout") then
		local p = front(b, 0, eyeY - 0.5, faceOut + 0.15)
		blob("Snout", Vector3.new(1.2, 0.8, 0.7), info.AccentColor, CFrame.new(p), model)
		blob("Nose", Vector3.new(0.42, 0.28, 0.25), OUTLINE_BLACK, CFrame.new(p + Vector3.new(0, 0.2, -0.3)), model)
		mouthPos = p + Vector3.new(0, -0.12, -0.33)
		blob("Mouth", Vector3.new(0.3, 0.09, 0.09), OUTLINE_BLACK, CFrame.new(mouthPos), model)
		if has(info, "Tongue") and not evil then
			blob("Tongue", Vector3.new(0.28, 0.32, 0.1), TONGUE_PINK, CFrame.new(mouthPos + Vector3.new(0, -0.15, 0.03)), model)
		end
	elseif has(info, "WideSmile") then
		mouthPos = front(b, 0, eyeY - 0.5, faceOut - 0.02)
		blob("Mouth", Vector3.new(1.4, 0.12, 0.12), OUTLINE_BLACK, CFrame.new(mouthPos), model)
	else
		mouthPos = front(b, 0, eyeY - 0.38, faceOut - 0.02)
		local size = if evil then Vector3.new(0.6, 0.1, 0.12) else Vector3.new(0.25, 0.12, 0.12)
		blob("Mouth", size, OUTLINE_BLACK, CFrame.new(mouthPos), model)
	end

	if has(info, "BuckTeeth") and not evil then
		for _, side in { -1, 1 } do
			block("Tooth", Vector3.new(0.16, 0.22, 0.08), WHITE, CFrame.new(mouthPos + Vector3.new(side * 0.09, -0.15, 0.02)), model)
		end
	end
	return mouthPos
end

----------------------------------------------------------------------
-- Ears, tail, feet
----------------------------------------------------------------------

local function addEars(model: Model, b, info, earColor: Color3, innerColor: Color3)
	local style = info.Ears
	for _, side in { -1, 1 } do
		if style == "Round" then
			local x = side * b.rx * 0.6
			local y = topY(b, x, 0)
			tint(blob("Ear", Vector3.new(0.95, 0.95, 0.5), earColor, CFrame.new(x, y, 0), model))
			blob("EarInner", Vector3.new(0.5, 0.5, 0.2), innerColor, CFrame.new(x, y, -0.22), model)
		elseif style == "Pointy" then
			local x = side * b.rx * 0.55
			local y = topY(b, x, 0) - 0.05
			local tilt = CFrame.Angles(0, 0, math.rad(45))
			tint(block("Ear", Vector3.new(0.9, 0.9, 0.4), earColor, CFrame.new(x, y, 0) * tilt, model))
			block("EarInner", Vector3.new(0.5, 0.5, 0.1), innerColor, CFrame.new(x, y + 0.1, -0.2) * tilt, model)
		elseif style == "Long" or style == "Short" then
			local long = style == "Long"
			local x = side * b.rx * 0.37
			local y = topY(b, x, 0) + (if long then 0.6 else 0.3)
			local tilt = CFrame.Angles(0, 0, -side * math.rad(12))
			local h = if long then 1.8 else 1.0
			tint(blob("Ear", Vector3.new(0.6, h, 0.4), earColor, CFrame.new(x, y, 0) * tilt, model))
			blob("EarInner", Vector3.new(0.3, h - 0.5, 0.1), innerColor, CFrame.new(x, y, -0.18) * tilt, model)
		elseif style == "Floppy" then
			-- dog ears hanging down the sides of the head
			blob(
				"Ear",
				Vector3.new(0.75, 1.6, 0.45),
				earColor,
				CFrame.new(side * b.rx * 0.93, b.cy + b.ry * 0.25, -b.rz * 0.05) * CFrame.Angles(0, 0, side * math.rad(15)),
				model
			)
		elseif style == "Tiny" then
			-- little sideways lamb ears
			blob(
				"Ear",
				Vector3.new(1.0, 0.38, 0.5),
				earColor,
				CFrame.new(side * b.rx * 0.97, b.cy + b.ry * 0.3, -b.rz * 0.15) * CFrame.Angles(0, 0, -side * math.rad(25)),
				model
			)
		end
	end
end

local function addTail(model: Model, b, info)
	local style = info.Tail
	if style == "Puff" then
		blob("Tail", Vector3.new(0.75, 0.75, 0.75), info.AccentColor, CFrame.new(0, b.cy - b.ry * 0.45, b.rz * 0.95), model)
	elseif style == "Long" or style == "Star" then
		-- cat tail curling out the back and up
		local last
		for i = 0, 7 do
			local t = i / 7
			last = Vector3.new(
				0.3 * math.sin(t * math.pi),
				b.cy - b.ry * 0.7 + t * b.ry * 1.4,
				b.rz * 0.85 + 0.2 + math.sin(t * math.pi) * 0.7
			)
			local size = 0.45 - t * 0.12
			tint(blob("Tail", Vector3.new(size, size, size), info.BodyColor, CFrame.new(last), model))
		end
		if style == "Star" then
			addStar(model, last + Vector3.new(0, 0.4, 0), info.AccentColor, 0.45)
		end
	elseif style == "Wag" then
		for i = 0, 3 do
			local size = 0.5 - i * 0.06
			local color = if i == 3 then info.AccentColor else info.BodyColor
			local part = blob("Tail", Vector3.new(size, size, size), color, CFrame.new(0, b.cy - b.ry * 0.25 + i * 0.32, b.rz * 0.9 + 0.1 + i * 0.18), model)
			if i < 3 then
				tint(part)
			end
		end
	elseif style == "Feather" then
		tint(blob(
			"Tail",
			Vector3.new(0.7, 1.0, 0.25),
			info.BodyColor,
			CFrame.new(0, b.cy - b.ry * 0.15, b.rz * 0.95) * CFrame.Angles(math.rad(35), 0, 0),
			model
		))
	end
end

local function addFeet(model: Model, b, info)
	local color = info.FeetColor or info.BodyColor
	for _, side in { -1, 1 } do
		local foot
		if info.Feet == "Paws" then
			foot = blob("Foot", Vector3.new(0.8, 0.5, 0.9), color, CFrame.new(side * b.rx * 0.45, 0.25, -b.rz * 0.42), model)
		elseif info.Feet == "Webbed" then
			foot = blob("Foot", Vector3.new(1.2, 0.26, 1.3), color, CFrame.new(side * b.rx * 0.5, 0.13, -b.rz * 0.5), model)
		end
		if foot and not info.FeetColor then
			tint(foot)
		end
	end
end

----------------------------------------------------------------------
-- Extras (the special bits that make each pet unique)
----------------------------------------------------------------------

local function addExtras(model: Model, b, info, evil: boolean)
	local faceOut = info.FaceOut or 0
	local eyeY = b.cy + b.ry * 0.12

	if has(info, "Whiskers") then
		for _, side in { -1, 1 } do
			local start = front(b, side * b.rx * 0.62, eyeY - 0.42, faceOut - 0.02)
			for k = -1, 1 do
				block(
					"Whisker",
					Vector3.new(0.8, 0.05, 0.05),
					OUTLINE_BLACK,
					CFrame.new(start + Vector3.new(side * 0.4, k * 0.12, -0.05)) * CFrame.Angles(0, 0, side * k * math.rad(12)),
					model
				)
			end
		end
	end

	if has(info, "CalicoSpots") then
		patch("Spot", b, -35, 55, Vector3.new(1.3, 1.0, 0.25), Color3.fromRGB(245, 165, 90), model)
		patch("Spot", b, 60, 40, Vector3.new(1.0, 0.8, 0.25), Color3.fromRGB(90, 80, 90), model)
		patch("Spot", b, 170, 25, Vector3.new(1.2, 1.0, 0.25), Color3.fromRGB(245, 165, 90), model)
	end

	if has(info, "EyePatch") then
		local earColor = info.EarColor or info.AccentColor
		blob("EyePatch", Vector3.new(0.85, 0.95, 0.15), earColor, CFrame.new(front(b, -b.rx * 0.36, eyeY + 0.05, faceOut - 0.03)), model)
	end

	if has(info, "FrogSpots") then
		local spotColor = info.BodyColor:Lerp(Color3.new(0, 0, 0), 0.25)
		for _, spot in { { 140, 50 }, { -150, 40 }, { 100, 20 }, { -110, 25 }, { 180, 70 } } do
			patch("Spot", b, spot[1], spot[2], Vector3.new(0.6, 0.5, 0.15), spotColor, model)
		end
	end

	if has(info, "HoneyPot") then
		local base = Vector3.new(b.rx + 0.35, 0, -b.rz * 0.35)
		cylinder("HoneyPot", 1.1, 1.1, Color3.fromRGB(190, 120, 50), base + Vector3.new(0, 0.55, 0), model)
		cylinder("PotRim", 0.15, 1.2, Color3.fromRGB(225, 150, 70), base + Vector3.new(0, 1.12, 0), model)
		blob("Honey", Vector3.new(0.95, 0.4, 0.95), Color3.fromRGB(255, 195, 40), CFrame.new(base + Vector3.new(0, 1.2, 0)), model)
		blob("Drip", Vector3.new(0.22, 0.5, 0.22), Color3.fromRGB(255, 195, 40), CFrame.new(base + Vector3.new(0.2, 0.95, -0.5)), model)
		-- a sticky honey drip on the bear's head too
		blob("HeadHoney", Vector3.new(1.0, 0.25, 0.9), Color3.fromRGB(255, 195, 40), CFrame.new(0.3, topY(b, 0.3, 0) - 0.02, 0), model)
	end

	if has(info, "Wings") then
		for _, side in { -1, 1 } do
			tint(blob(
				"Wing",
				Vector3.new(0.4, 1.3, 1.1),
				info.BodyColor,
				CFrame.new(side * b.rx * 0.98, b.cy - b.ry * 0.1, 0.15) * CFrame.Angles(0, 0, side * math.rad(20)),
				model
			))
		end
	end

	if has(info, "Tuft") then
		local y = topY(b, 0, 0)
		for k = -1, 1 do
			tint(blob(
				"Tuft",
				Vector3.new(0.2, 0.65, 0.2),
				info.BodyColor,
				CFrame.new(k * 0.15, y + 0.2, 0) * CFrame.Angles(0, 0, -k * math.rad(25)),
				model
			))
		end
	end

	if has(info, "StrawberryTip") then
		-- narrower lower blob turns the body into a strawberry shape
		tint(blob("StrawberryTip", Vector3.new(b.rx * 1.6, b.cy, b.rz * 1.6), info.BodyColor, CFrame.new(0, b.cy / 2, 0), model))
	end

	if has(info, "LeafHat") then
		local leafColor = Color3.fromRGB(90, 190, 90)
		local y = topY(b, 0, 0)
		for i = 0, 4 do
			blob(
				"Leaf",
				Vector3.new(1.0, 0.2, 0.45),
				leafColor,
				CFrame.new(0, y, 0) * CFrame.Angles(0, math.rad(i * 72 + 20), math.rad(-15)) * CFrame.new(0.45, 0, 0),
				model
			)
		end
		cylinder("Stem", 0.45, 0.15, leafColor, Vector3.new(0, y + 0.25, 0), model)
	end

	if has(info, "Seeds") then
		for _, s in { { -40, 25 }, { 40, 30 }, { -60, -10 }, { 65, -5 }, { -25, -30 }, { 30, -35 }, { 0, -45 }, { -80, 20 }, { 85, 15 } } do
			patch("Seed", b, s[1], s[2], Vector3.new(0.14, 0.22, 0.1), info.AccentColor, model)
		end
	end

	if has(info, "Fluff") then
		for _, f in { { 0, 75 }, { 60, 50 }, { -60, 50 }, { 90, 10 }, { -90, 10 }, { 130, 40 }, { -130, 40 }, { 180, 20 }, { 120, -30 }, { -120, -30 }, { 180, -40 }, { 55, -45 }, { -55, -45 } } do
			local point = surfacePoint(b, f[1], f[2])
			tint(blob("Fluff", Vector3.new(1.2, 1.2, 1.2), info.BodyColor, CFrame.new(point), model))
		end
	end

	if has(info, "FaceMask") then
		blob("FaceMask", Vector3.new(b.rx * 1.2, b.ry * 1.0, 0.6), info.AccentColor, CFrame.new(front(b, 0, b.cy - b.ry * 0.05, -0.15)), model)
	end

	if has(info, "CurlHorns") then
		for _, side in { -1, 1 } do
			local c = Vector3.new(side * b.rx * 0.78, b.cy + b.ry * 0.55, -b.rz * 0.25)
			for i = 0, 6 do
				local a = i * 0.95
				local r = 0.38 - i * 0.045
				blob("Curl", Vector3.new(0.3, 0.3, 0.3), Color3.fromRGB(235, 200, 160), CFrame.new(c + Vector3.new(side * math.cos(a) * r, math.sin(a) * r, 0)), model)
			end
		end
	end

	if has(info, "PandaPatches") then
		local spread = b.rx * 0.36
		for _, side in { -1, 1 } do
			blob(
				"EyePatch",
				Vector3.new(0.85, 1.0, 0.2),
				info.AccentColor,
				CFrame.new(front(b, side * spread, eyeY - 0.02, faceOut - 0.04)) * CFrame.Angles(0, 0, side * math.rad(-25)),
				model
			)
		end
	end

	if has(info, "Arms") then
		for _, side in { -1, 1 } do
			blob(
				"Arm",
				Vector3.new(0.75, 1.15, 0.75),
				info.AccentColor,
				CFrame.new(side * b.rx * 0.78, b.cy - b.ry * 0.3, -b.rz * 0.6) * CFrame.Angles(math.rad(-20), 0, side * math.rad(35)),
				model
			)
		end
	end

	if has(info, "Boba") then
		local base = Vector3.new(b.rx * 0.5, b.cy - b.ry * 0.45, -b.rz * 0.98)
		local cupColor = if evil then Color3.fromRGB(150, 230, 90) else Color3.fromRGB(235, 205, 170)
		local cup = cylinder("BobaCup", 1.0, 0.75, cupColor, base, model)
		cup.Transparency = 0.2
		cylinder("BobaLid", 0.08, 0.8, Color3.fromRGB(255, 160, 190), base + Vector3.new(0, 0.52, 0), model)
		cylinder("Straw", 0.7, 0.12, Color3.fromRGB(255, 120, 160), base + Vector3.new(0.05, 0.85, 0), model)
		for _, off in { Vector3.new(-0.12, -0.35, -0.2), Vector3.new(0.12, -0.35, -0.15), Vector3.new(0, -0.25, -0.25) } do
			blob("Pearl", Vector3.new(0.2, 0.2, 0.2), OUTLINE_BLACK, CFrame.new(base + off), model)
		end
	end

	if has(info, "StarMark") then
		addStar(model, front(b, 0, eyeY + 0.6, faceOut + 0.05), info.AccentColor, 0.3)
	end

	if has(info, "Collar") then
		local y = eyeY - 0.75
		local dy = (y - b.cy) / b.ry
		local f = math.sqrt(math.max(0, 1 - dy * dy)) * 1.06
		blob("Collar", Vector3.new(b.rx * 2 * f, 0.2, b.rz * 2 * f), Color3.fromRGB(230, 60, 90), CFrame.new(0, y, 0), model)
		blob("Bell", Vector3.new(0.38, 0.38, 0.38), Color3.fromRGB(255, 210, 60), CFrame.new(Vector3.new(0, y - 0.15, -b.rz * f - 0.1)), model)
	end

	if has(info, "Moon") then
		-- big crescent moon behind the pet, like a halo
		local center = Vector3.new(0, b.cy + b.ry * 0.35, b.rz + 0.35)
		local steps = 13
		for i = 0, steps - 1 do
			local t = i / (steps - 1)
			local a = math.rad(-130 + t * 260)
			local size = 0.3 + 0.5 * math.sin(t * math.pi)
			local offset = Vector3.new(-math.cos(a) * 1.7, math.sin(a) * 1.7, 0) -- "C" shape
			neon(blob("MoonPiece", Vector3.new(size, size, size), info.AccentColor, CFrame.new(center + offset), model))
		end
	end

	if has(info, "OrbitStars") then
		local starColor = Color3.fromRGB(255, 240, 150)
		addStar(model, Vector3.new(b.rx + 0.7, b.cy + b.ry * 0.5, -0.3), starColor, 0.28)
		addStar(model, Vector3.new(-(b.rx + 0.8), b.cy - b.ry * 0.1, -0.2), starColor, 0.22)
		addStar(model, Vector3.new(b.rx + 0.2, b.cy + b.ry + 0.8, -0.2), starColor, 0.2)
	end
end

----------------------------------------------------------------------
-- Evil parts
----------------------------------------------------------------------

-- Horns, fangs, bat wings and a devil tail for the Evil mutation.
local function addEvilParts(model: Model, b, mouthPos: Vector3)
	for _, side in { -1, 1 } do
		blob("Fang", Vector3.new(0.14, 0.24, 0.1), WHITE, CFrame.new(mouthPos + Vector3.new(side * 0.17, -0.13, -0.02)), model)

		-- horns: shrinking balls curving up and out
		local hx, hz = side * b.rx * 0.28, -b.rz * 0.35
		local hy = topY(b, hx, hz) - 0.05
		for i = 0, 5 do
			local size = 0.48 - i * 0.075
			blob(
				"Horn",
				Vector3.new(size, size, size),
				EVIL_HORN,
				CFrame.new(hx + side * (i * 0.05 + i * i * 0.012), hy + i * 0.14, hz + i * 0.03),
				model
			)
		end

		-- bat wing: a top bone plus scalloped membrane, behind the body
		local wz = b.rz * 0.36
		block(
			"WingBone",
			Vector3.new(1.7, 0.16, 0.16),
			OUTLINE_BLACK,
			CFrame.new(side * (b.rx + 0.5), b.cy + b.ry * 0.9, wz) * CFrame.Angles(0, 0, side * math.rad(18)),
			model
		)
		for i = 0, 2 do
			blob(
				"WingSkin",
				Vector3.new(0.75, 1.3 - i * 0.25, 0.1),
				EVIL_WING,
				CFrame.new(side * (b.rx - 0.05 + i * 0.5), b.cy + b.ry * 0.5 + i * 0.22, wz),
				model
			)
		end
	end

	-- devil tail: little balls curving back and up, ending in a spade
	local base = Vector3.new(0, b.cy - b.ry * 0.5, b.rz + 0.15)
	for i = 1, 4 do
		blob("DevilTail", Vector3.new(0.22, 0.22, 0.22), OUTLINE_BLACK, CFrame.new(base + Vector3.new(0, i * 0.22, i * 0.22)), model)
	end
	block("TailSpade", Vector3.new(0.1, 0.45, 0.45), EVIL_HORN, CFrame.new(base + Vector3.new(0, 1.1, 1.0)) * CFrame.Angles(math.rad(45), 0, 0), model)
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

	if mutationName == "Evil" then
		-- spooky purple aura drifting up around the pet
		local aura = Instance.new("ParticleEmitter")
		aura.Color = ColorSequence.new(EVIL_AURA, Color3.fromRGB(30, 0, 40))
		aura.LightEmission = 0.6
		aura.Rate = 10
		aura.Lifetime = NumberRange.new(1.2, 2)
		aura.Speed = NumberRange.new(0.8, 1.5)
		aura.SpreadAngle = Vector2.new(180, 180)
		aura.Acceleration = Vector3.new(0, 2, 0)
		aura.Size = NumberSequence.new(0.5, 0)
		aura.Transparency = NumberSequence.new(0.3, 1)
		aura.Parent = body
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

-- Build a pet. mutationName is optional ("Shiny", "Golden", "Rainbow", "Evil", "Giant", "Tiny").
function ModelBuilder.buildPet(petId: string, mutationName: string?): Model
	local baseInfo = PetData.Pets[petId]
	assert(baseInfo, "Unknown pet: " .. tostring(petId))
	local model = ModelBuilder.buildPetFromInfo(baseInfo, mutationName)
	model.Name = petId
	model:SetAttribute("PetId", petId)
	return model
end

-- Build a pet from any look table with the same fields as a PetData.Pets entry
-- (used for one-of-a-kind pets from the Plush Mixer, see PetMixer.toInfo).
function ModelBuilder.buildPetFromInfo(baseInfo, mutationName: string?): Model
	-- Evil pets use a darker copy of the pet's colors.
	local evil = mutationName == "Evil"
	local info = baseInfo
	if evil then
		info = table.clone(baseInfo)
		local darkPurple = Color3.fromRGB(40, 20, 55)
		info.BodyColor = baseInfo.BodyColor:Lerp(darkPurple, 0.8)
		info.AccentColor = baseInfo.AccentColor:Lerp(Color3.fromRGB(140, 20, 45), 0.6)
		if baseInfo.EarColor then
			info.EarColor = baseInfo.EarColor:Lerp(darkPurple, 0.6)
		end
		if baseInfo.FeetColor then
			info.FeetColor = baseInfo.FeetColor:Lerp(darkPurple, 0.6)
		end
	end

	local model = Instance.new("Model")
	model.Name = info.DisplayName

	local float = info.Float or (if info.Feet == "None" then 0.6 else 0.2)
	local b = makeBody(info.Body, float)

	local body = tint(blob("Body", info.Body, info.BodyColor, CFrame.new(0, b.cy, 0), model))
	if not info.NoBelly then
		blob("Belly", Vector3.new(b.rx, b.ry * 0.75, 0.5), info.AccentColor, CFrame.new(front(b, 0, b.cy - b.ry * 0.45, -0.2)), model)
	end

	addFeet(model, b, info)
	addTail(model, b, info)
	local mouthPos = addFace(model, b, info, evil)

	local earColor = info.EarColor or info.BodyColor
	local innerColor = if evil then EVIL_EYE_RED else CHEEK_PINK
	addEars(model, b, info, earColor, innerColor)

	addExtras(model, b, info, evil)
	if evil then
		addEvilParts(model, b, mouthPos)
	end

	model.PrimaryPart = body
	-- pivot on the ground under the pet so PivotTo / ScaleTo keep it standing
	body.PivotOffset = CFrame.new(0, -b.cy, 0)

	-- name tag floats just above the tallest part of this pet
	local boxCFrame, boxSize = model:GetBoundingBox()
	local tagHeight = (boxCFrame.Position.Y + boxSize.Y / 2) - b.cy + 1.2

	local rarity = PetData.Rarities[info.Rarity]
	local title = if evil and info.EvilName then info.EvilName
		elseif mutationName then mutationName .. " " .. info.DisplayName
		else info.DisplayName
	local subtitle = if evil then "Evil " .. info.Rarity else info.Rarity
	local subtitleColor = if evil then EVIL_EYE_RED else rarity.Color
	addNameTag(model, body, title, subtitle, subtitleColor, tagHeight)

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

	local b = makeBody(Vector3.new(2.2, 2.8, 2.2), 0)
	local shell = blob("Shell", Vector3.new(2.2, 2.8, 2.2), info.ShellColor, CFrame.new(0, b.cy, 0), model)

	-- spots placed on the egg's surface
	for _, spot in { { 20, 25 }, { 95, -10 }, { 170, 35 }, { 250, 5 }, { 320, -25 }, { 60, 55 }, { 210, -40 } } do
		local s = patch("Spot", b, spot[1], spot[2], Vector3.new(0.6, 0.6, 0.12), info.SpotColor, model)
		if eggId == "StarryEgg" then
			neon(s)
		end
	end

	model.PrimaryPart = shell
	shell.PivotOffset = CFrame.new(0, -b.cy, 0)

	addNameTag(model, shell, info.DisplayName, "$" .. tostring(info.Price), Color3.fromRGB(255, 220, 90), 2.2)
	return model
end

return ModelBuilder

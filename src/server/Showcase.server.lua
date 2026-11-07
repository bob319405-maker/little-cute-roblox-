--!nonstrict
-- Showcase: spawns every pet, every mutation and every egg in rows so you can
-- look at the models in Studio. Hit Play (or Run) to see them bounce.
-- Delete or disable this script once the real game is built.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PetData = require(Shared:WaitForChild("PetData"))
local ModelBuilder = require(Shared:WaitForChild("ModelBuilder"))
local PetAnimator = require(Shared:WaitForChild("PetAnimator"))
local PetMixer = require(Shared:WaitForChild("PetMixer"))

local SPACING = 7
local ORIGIN = Vector3.new(0, 0, -30)

local folder = Instance.new("Folder")
folder.Name = "Showcase"
folder.Parent = workspace

local function platform(name: string, center: Vector3, length: number, color: Color3)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = Vector3.new(length, 1, 6)
	p.CFrame = CFrame.new(center - Vector3.new(0, 0.5, 0))
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.Parent = folder
end

-- Lay models out along X, facing the spawn (+Z direction).
local function placeRow(models: { Model }, z: number, color: Color3, label: string)
	local count = #models
	local length = count * SPACING
	local startX = ORIGIN.X - (count - 1) * SPACING / 2
	platform(label, Vector3.new(ORIGIN.X, ORIGIN.Y, ORIGIN.Z + z), length + 2, color)
	for i, model in models do
		local pos = Vector3.new(startX + (i - 1) * SPACING, ORIGIN.Y, ORIGIN.Z + z)
		-- rotate 180 so the pet's face (-Z) looks back toward the spawn
		model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, math.pi, 0))
		model.Parent = folder
	end
end

-- Row 1: every pet, sorted by rarity
local petIds = {}
for petId in PetData.Pets do
	table.insert(petIds, petId)
end
table.sort(petIds, function(a, b)
	local ra = PetData.Rarities[PetData.Pets[a].Rarity].Order
	local rb = PetData.Rarities[PetData.Pets[b].Rarity].Order
	if ra == rb then
		return a < b
	end
	return ra < rb
end)

local petModels = {}
for _, petId in petIds do
	table.insert(petModels, ModelBuilder.buildPet(petId))
end
placeRow(petModels, 0, Color3.fromRGB(255, 225, 235), "PetRow")

-- Row 2: evil version of every pet
local evilModels = {}
for _, petId in petIds do
	table.insert(evilModels, ModelBuilder.buildPet(petId, "Evil"))
end
placeRow(evilModels, -12, Color3.fromRGB(70, 40, 80), "EvilRow")

-- Row 3: every mutation on Bun Bun
local mutationModels = {}
for _, mutation in PetData.Mutations do
	table.insert(mutationModels, ModelBuilder.buildPet("BunBun", mutation.Name))
end
placeRow(mutationModels, -24, Color3.fromRGB(220, 235, 255), "MutationRow")

-- Row 4: one-of-a-kind pets from the Plush Mixer (new every time you press Play)
local mixPairs = {
	{ "Froggo", "BunBun" },
	{ "StarKitty", "BobaPanda" },
	{ "Ducky", "CloudLamb" },
	{ "MoonBun", "Mochi" },
	{ "Strawbunny", "PuddlePup" },
	{ "HoneyBear", "StarKitty" },
	{ "CloudLamb", "Froggo" },
	{ "BobaPanda", "Ducky" },
}
local mixModels = {}
for _, pair in mixPairs do
	local genes = PetMixer.mix(pair[1], pair[2])
	table.insert(mixModels, ModelBuilder.buildPetFromInfo(PetMixer.toInfo(genes)))
end
placeRow(mixModels, -36, Color3.fromRGB(255, 245, 210), "MixRow")

-- Row 5: eggs
local eggIds = { "CozyEgg", "SweetEgg", "StarryEgg" }
local eggModels = {}
for _, eggId in eggIds do
	table.insert(eggModels, ModelBuilder.buildEgg(eggId))
end
placeRow(eggModels, -48, Color3.fromRGB(230, 255, 225), "EggRow")

for _, model in petModels do
	PetAnimator.add(model)
end
for _, model in mutationModels do
	PetAnimator.add(model)
end
for _, model in evilModels do
	PetAnimator.add(model)
end
for _, model in mixModels do
	PetAnimator.add(model)
end

-- Quick sanity check of the hatch odds in the Output window.
local rng = Random.new()
local counts: { [string]: number } = {}
for _ = 1, 10000 do
	local petId = PetData.rollPet("StarryEgg", rng)
	counts[petId] = (counts[petId] or 0) + 1
end
print("[Showcase] 10,000 Starry Egg hatches:", counts)

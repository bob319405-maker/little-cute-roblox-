--!nonstrict
-- PetData: every pet, egg, rarity and mutation in the game.
-- Add a new pet by adding an entry to PetData.Pets; ModelBuilder reads these fields.

local PetData = {}

PetData.Rarities = {
	Common = { Order = 1, Color = Color3.fromRGB(200, 200, 200) },
	Uncommon = { Order = 2, Color = Color3.fromRGB(120, 220, 120) },
	Rare = { Order = 3, Color = Color3.fromRGB(100, 170, 255) },
	Epic = { Order = 4, Color = Color3.fromRGB(190, 110, 255) },
	Legendary = { Order = 5, Color = Color3.fromRGB(255, 200, 60) },
	Mythic = { Order = 6, Color = Color3.fromRGB(255, 90, 160) },
}

-- How a pet looks (all read by ModelBuilder):
--   Body      full size of the main body blob (X wide, Y tall, Z deep)
--   Float     gap under the body; pets with Feet = "None" hover
--   Eyes      "Big" | "Dot" | "Sparkle" | "Sleepy" | "Happy" | "Top" (frog eyes on bumps)
--   Ears      "Long" | "Short" | "Pointy" | "Round" | "Floppy" | "Tiny" | "None"
--   Tail      "Puff" | "Long" | "Star" | "Wag" | "Feather" | "None"
--   Feet      "Paws" | "Webbed" | "None"
--   Extras    list of add-ons, see ModelBuilder.addExtras
--   EvilName  what the pet is called when it rolls the Evil mutation
PetData.Pets = {
	BunBun = {
		DisplayName = "Bun Bun",
		EvilName = "Doom Bun",
		Rarity = "Common",
		BodyColor = Color3.fromRGB(255, 190, 210),
		AccentColor = Color3.fromRGB(255, 240, 245),
		Body = Vector3.new(2.6, 3.0, 2.5), -- tall bean
		Eyes = "Big",
		Ears = "Long",
		Tail = "Puff",
		Feet = "Paws",
		Extras = { "BuckTeeth" },
		BaseCoins = 1,
	},
	Mochi = {
		DisplayName = "Mochi",
		EvilName = "Mochi Menace",
		Rarity = "Common",
		BodyColor = Color3.fromRGB(250, 248, 240),
		AccentColor = Color3.fromRGB(255, 200, 210),
		Body = Vector3.new(3.5, 2.3, 2.8), -- wide squishy loaf
		Eyes = "Happy",
		Ears = "Pointy",
		Tail = "Long",
		Feet = "Paws",
		Extras = { "Whiskers", "CalicoSpots" },
		BaseCoins = 1,
	},
	PuddlePup = {
		DisplayName = "Puddle Pup",
		EvilName = "Shadow Pup",
		Rarity = "Common",
		BodyColor = Color3.fromRGB(170, 215, 255),
		AccentColor = Color3.fromRGB(235, 245, 255),
		EarColor = Color3.fromRGB(105, 145, 215),
		Body = Vector3.new(3.0, 2.7, 3.2),
		Eyes = "Big",
		Ears = "Floppy",
		Tail = "Wag",
		Feet = "Paws",
		Extras = { "Snout", "Tongue", "EyePatch" },
		BaseCoins = 1,
	},
	Froggo = {
		DisplayName = "Froggo",
		EvilName = "Grimfrog",
		Rarity = "Uncommon",
		BodyColor = Color3.fromRGB(140, 220, 120),
		AccentColor = Color3.fromRGB(230, 255, 200),
		Body = Vector3.new(3.7, 2.1, 3.0), -- wide and flat
		Eyes = "Top",
		Ears = "None",
		Tail = "None",
		Feet = "Webbed",
		Extras = { "WideSmile", "FrogSpots" },
		BaseCoins = 3,
	},
	HoneyBear = {
		DisplayName = "Honey Bear",
		EvilName = "Hex Bear",
		Rarity = "Uncommon",
		BodyColor = Color3.fromRGB(215, 155, 90),
		AccentColor = Color3.fromRGB(255, 225, 170),
		Body = Vector3.new(3.4, 3.3, 3.0), -- big and round
		Eyes = "Dot",
		Ears = "Round",
		Tail = "Puff",
		Feet = "Paws",
		Extras = { "Snout", "HoneyPot" },
		BaseCoins = 3,
	},
	Ducky = {
		DisplayName = "Ducky",
		EvilName = "Duck of Darkness",
		Rarity = "Uncommon",
		BodyColor = Color3.fromRGB(255, 230, 100),
		AccentColor = Color3.fromRGB(255, 160, 60),
		FeetColor = Color3.fromRGB(255, 150, 50),
		NoBelly = true,
		Body = Vector3.new(2.6, 2.7, 2.7),
		Eyes = "Dot",
		Ears = "None",
		Tail = "Feather",
		Feet = "Webbed",
		Extras = { "Beak", "Wings", "Tuft" },
		BaseCoins = 3,
	},
	Strawbunny = {
		DisplayName = "Strawbunny",
		EvilName = "Rotberry",
		Rarity = "Rare",
		BodyColor = Color3.fromRGB(255, 95, 110),
		AccentColor = Color3.fromRGB(255, 235, 150),
		NoBelly = true,
		Body = Vector3.new(3.0, 2.4, 2.8),
		Float = 1.0, -- stands on its strawberry tip
		Eyes = "Sparkle",
		EyeColor = Color3.fromRGB(120, 200, 120),
		Ears = "Short",
		Tail = "None",
		Feet = "None",
		Extras = { "StrawberryTip", "LeafHat", "Seeds" },
		BaseCoins = 8,
	},
	CloudLamb = {
		DisplayName = "Cloud Lamb",
		EvilName = "Storm Lamb",
		Rarity = "Rare",
		BodyColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(255, 220, 205),
		NoBelly = true,
		FaceOut = 0.2,
		Body = Vector3.new(2.8, 2.4, 2.6),
		Float = 1.2, -- floats like a cloud
		Eyes = "Sleepy",
		Ears = "Tiny",
		Tail = "None",
		Feet = "None",
		Extras = { "Fluff", "FaceMask", "CurlHorns" },
		BaseCoins = 8,
	},
	BobaPanda = {
		DisplayName = "Boba Panda",
		EvilName = "Toxic Boba Panda",
		Rarity = "Epic",
		BodyColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(40, 40, 50),
		EarColor = Color3.fromRGB(40, 40, 50),
		FeetColor = Color3.fromRGB(40, 40, 50),
		NoBelly = true,
		Body = Vector3.new(3.7, 3.4, 3.3), -- extra chubby
		Eyes = "Big",
		Ears = "Round",
		Tail = "Puff",
		Feet = "Paws",
		Extras = { "PandaPatches", "Arms", "Boba" },
		BaseCoins = 20,
	},
	StarKitty = {
		DisplayName = "Star Kitty",
		EvilName = "Black Hole Kitty",
		Rarity = "Legendary",
		BodyColor = Color3.fromRGB(190, 150, 255),
		AccentColor = Color3.fromRGB(255, 230, 90),
		EyeColor = Color3.fromRGB(110, 200, 255),
		Body = Vector3.new(2.4, 3.2, 2.4), -- slim, sitting up tall
		Eyes = "Sparkle",
		Ears = "Pointy",
		Tail = "Star",
		Feet = "Paws",
		Extras = { "StarMark", "Collar", "Whiskers" },
		BaseCoins = 60,
	},
	MoonBun = {
		DisplayName = "Moon Bun",
		EvilName = "Blood Moon Bun",
		Rarity = "Mythic",
		BodyColor = Color3.fromRGB(60, 70, 150),
		AccentColor = Color3.fromRGB(255, 245, 190),
		Body = Vector3.new(2.6, 2.6, 2.5),
		Float = 1.0, -- sleeps while floating
		Eyes = "Sleepy",
		Ears = "Long",
		Tail = "Puff",
		Feet = "None",
		Extras = { "Moon", "OrbitStars" },
		BaseCoins = 200,
	},
}

-- Weight = relative chance inside that egg.
PetData.Eggs = {
	CozyEgg = {
		DisplayName = "Cozy Egg",
		Price = 50,
		ShellColor = Color3.fromRGB(255, 225, 235),
		SpotColor = Color3.fromRGB(255, 180, 200),
		Pets = { BunBun = 35, Mochi = 35, PuddlePup = 25, Froggo = 5 },
	},
	SweetEgg = {
		DisplayName = "Sweet Egg",
		Price = 400,
		ShellColor = Color3.fromRGB(255, 240, 180),
		SpotColor = Color3.fromRGB(255, 120, 140),
		Pets = { HoneyBear = 40, Ducky = 40, Strawbunny = 15, CloudLamb = 5 },
	},
	StarryEgg = {
		DisplayName = "Starry Egg",
		Price = 3000,
		ShellColor = Color3.fromRGB(70, 60, 140),
		SpotColor = Color3.fromRGB(255, 230, 120),
		Pets = { CloudLamb = 60, BobaPanda = 30, StarKitty = 9, MoonBun = 1 },
	},
}

-- Chance is "1 in N". Rolled in order; first hit wins.
PetData.Mutations = {
	{ Name = "Rainbow", OneIn = 500, CoinMultiplier = 10 },
	{ Name = "Evil", OneIn = 200, CoinMultiplier = 4 },
	{ Name = "Golden", OneIn = 100, CoinMultiplier = 5 },
	{ Name = "Giant", OneIn = 50, CoinMultiplier = 3, Scale = 2 },
	{ Name = "Tiny", OneIn = 50, CoinMultiplier = 1, Scale = 0.5 },
	{ Name = "Shiny", OneIn = 20, CoinMultiplier = 2 },
}

function PetData.getMutation(name: string?)
	if not name then
		return nil
	end
	for _, mutation in PetData.Mutations do
		if mutation.Name == name then
			return mutation
		end
	end
	return nil
end

-- Picks a pet id from an egg using its weights.
function PetData.rollPet(eggId: string, rng: Random?): string
	local egg = PetData.Eggs[eggId]
	assert(egg, "Unknown egg: " .. tostring(eggId))
	local random = rng or Random.new()

	local total = 0
	for _, weight in egg.Pets do
		total += weight
	end

	local roll = random:NextNumber() * total
	local lastId = ""
	for petId, weight in egg.Pets do
		lastId = petId
		roll -= weight
		if roll <= 0 then
			return petId
		end
	end
	return lastId
end

-- Returns a mutation name or nil. luckMultiplier > 1 makes mutations more likely (events).
function PetData.rollMutation(rng: Random?, luckMultiplier: number?): string?
	local random = rng or Random.new()
	local luck = luckMultiplier or 1
	for _, mutation in PetData.Mutations do
		if random:NextNumber() < luck / mutation.OneIn then
			return mutation.Name
		end
	end
	return nil
end

return PetData

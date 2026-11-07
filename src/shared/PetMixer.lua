--!nonstrict
-- PetMixer: the Plush Mixer. Put two pets in, get a brand-new one-of-a-kind baby
-- that mixes their body shape, colors, eyes, ears, tail, feet and extras, with a
-- mashed-up name ("Frogbun", "Starpanda"...).
--
-- PetMixer.mix() returns "genes": a small table of plain strings and numbers that
-- can be saved straight into a DataStore. PetMixer.toInfo(genes) turns genes into
-- a look table for ModelBuilder.buildPetFromInfo().

local PetData = require(script.Parent.PetData)

local PetMixer = {}

-- 1 in N mixes are "Wild": they also get a random trait from ANY pet.
PetMixer.WILD_CHANCE = 25
PetMixer.MAX_EXTRAS = 3

-- Only one mouth-type extra can be used at a time.
local MOUTHS = { Beak = true, Snout = true, WideSmile = true }

local function pick(rng: Random, a, b)
	return if rng:NextNumber() < 0.5 then a else b
end

local function shuffle(rng: Random, list)
	for i = #list, 2, -1 do
		local j = rng:NextInteger(1, i)
		list[i], list[j] = list[j], list[i]
	end
	return list
end

local function hex(color: Color3?): string?
	return if color then color:ToHex() else nil
end

local function fromHex(value: string?): Color3?
	return if value then Color3.fromHex(value) else nil
end

-- Can `extra` be added to a pet that already has `chosen` extras and these feet?
local function fits(extra: string, chosen: { string }, feet: string): boolean
	if table.find(chosen, extra) then
		return false
	end
	if extra == "StrawberryTip" and feet ~= "None" then
		return false -- the strawberry tip replaces feet
	end
	if MOUTHS[extra] then
		for _, other in chosen do
			if MOUTHS[other] then
				return false
			end
		end
	end
	if extra == "BuckTeeth" and (table.find(chosen, "Beak") or table.find(chosen, "Snout")) then
		return false
	end
	if (extra == "Beak" or extra == "Snout") and table.find(chosen, "BuckTeeth") then
		return false
	end
	return true
end

local function allExtras(): { string }
	local seen, list = {}, {}
	for _, pet in PetData.Pets do
		for _, extra in pet.Extras or {} do
			if not seen[extra] then
				seen[extra] = true
				table.insert(list, extra)
			end
		end
	end
	table.sort(list)
	return list
end

-- Mix two pets (by id). Pass a Random to get repeatable results.
function PetMixer.mix(petIdA: string, petIdB: string, rng: Random?)
	local a = PetData.Pets[petIdA]
	local b = PetData.Pets[petIdB]
	assert(a and b, "Unknown pet in mix: " .. tostring(petIdA) .. ", " .. tostring(petIdB))
	local random = rng or Random.new()

	local bodyParent = pick(random, a, b)
	local eyesParent = pick(random, a, b)
	local earsParent = pick(random, a, b)
	local tailParent = pick(random, a, b)
	local feetParent = pick(random, a, b)

	-- body: one parent's shape, slightly squished or stretched
	local scale = random:NextNumber(0.9, 1.1)
	local body = bodyParent.Body
	local bodySize = {
		body.X * scale * random:NextNumber(0.95, 1.05),
		body.Y * scale * random:NextNumber(0.95, 1.05),
		body.Z * scale,
	}

	local wild = random:NextInteger(1, PetMixer.WILD_CHANCE) == 1

	local genes = {
		Version = 1,
		Parents = { petIdA, petIdB },
		Wild = wild,
		Body = bodySize,
		BodyColor = hex(a.BodyColor:Lerp(b.BodyColor, random:NextNumber(0.3, 0.7))),
		AccentColor = hex(pick(random, a, b).AccentColor),
		Eyes = eyesParent.Eyes,
		EyeColor = hex(eyesParent.EyeColor),
		Ears = earsParent.Ears,
		EarColor = hex(earsParent.EarColor),
		Tail = tailParent.Tail,
		Feet = feetParent.Feet,
		FeetColor = hex(feetParent.FeetColor),
		Float = if feetParent.Feet == "None" then (feetParent.Float or 1.0) else nil,
	}

	-- extras: shuffle both parents' extras together and keep the ones that fit
	local pool = {}
	for _, extra in a.Extras or {} do
		table.insert(pool, extra)
	end
	for _, extra in b.Extras or {} do
		table.insert(pool, extra)
	end
	shuffle(random, pool)

	local extras = {}
	for _, extra in pool do
		if #extras >= PetMixer.MAX_EXTRAS then
			break
		end
		if extra ~= "Tongue" and fits(extra, extras, genes.Feet) then
			table.insert(extras, extra)
		end
	end
	-- a tongue only makes sense with a snout
	if table.find(extras, "Snout") and table.find(pool, "Tongue") then
		table.insert(extras, "Tongue")
	end

	-- Wild mixes get one surprise extra and a random eye style from any pet
	if wild then
		local candidates = shuffle(random, allExtras())
		for _, extra in candidates do
			if extra ~= "Tongue" and fits(extra, extras, genes.Feet) then
				table.insert(extras, extra)
				break
			end
		end
		local eyeStyles = { "Big", "Dot", "Sparkle", "Sleepy", "Happy" }
		genes.Eyes = eyeStyles[random:NextInteger(1, #eyeStyles)]
		if genes.Eyes == "Sparkle" and not genes.EyeColor then
			genes.EyeColor = hex(Color3.fromHSV(random:NextNumber(), 0.5, 1))
		end
	end
	genes.Extras = extras

	-- pets with these extras look better without a belly patch
	genes.NoBelly = bodyParent.NoBelly == true
		or table.find(extras, "Fluff") ~= nil
		or table.find(extras, "StrawberryTip") ~= nil
		or table.find(extras, "PandaPatches") ~= nil
	if table.find(extras, "FaceMask") then
		genes.FaceOut = 0.2
	end

	-- name: first part of one pet + second part of the other ("Frog" + "bun")
	local name
	if petIdA == petIdB then
		name = a.DisplayName .. " Jr."
	else
		name = a.NameParts[1] .. b.NameParts[2]
	end
	genes.Name = if wild then "Wild " .. name else name

	-- rarity: the rarer parent's, coins: a bit better than the parents' average
	local rarityA = PetData.Rarities[a.Rarity].Order
	local rarityB = PetData.Rarities[b.Rarity].Order
	genes.Rarity = if rarityA >= rarityB then a.Rarity else b.Rarity
	genes.BaseCoins = math.floor((a.BaseCoins + b.BaseCoins) / 2 * (if wild then 3 else 1.5))

	return genes
end

-- Turn saved genes into a look table for ModelBuilder.buildPetFromInfo().
function PetMixer.toInfo(genes)
	return {
		DisplayName = genes.Name,
		EvilName = "Dark " .. genes.Name,
		Rarity = genes.Rarity,
		BaseCoins = genes.BaseCoins,
		Body = Vector3.new(genes.Body[1], genes.Body[2], genes.Body[3]),
		Float = genes.Float,
		BodyColor = fromHex(genes.BodyColor),
		AccentColor = fromHex(genes.AccentColor),
		EyeColor = fromHex(genes.EyeColor),
		EarColor = fromHex(genes.EarColor),
		FeetColor = fromHex(genes.FeetColor),
		Eyes = genes.Eyes,
		Ears = genes.Ears,
		Tail = genes.Tail,
		Feet = genes.Feet,
		Extras = genes.Extras,
		NoBelly = genes.NoBelly,
		FaceOut = genes.FaceOut,
	}
end

return PetMixer

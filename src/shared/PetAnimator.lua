--!nonstrict
-- PetAnimator: makes pets bounce, wiggle and (for Rainbow pets) cycle colors.
-- Call PetAnimator.add(model) once; call PetAnimator.remove(model) when done.

local RunService = game:GetService("RunService")

local PetAnimator = {}

type Entry = { base: CFrame, offset: number, tintParts: { BasePart }, rainbow: boolean }

local active: { [Model]: Entry } = {}
local connection: RBXScriptConnection? = nil

local function step()
	local t = os.clock()
	for model, entry in active do
		if not model.Parent then
			active[model] = nil
			continue
		end
		local phase = t * 3 + entry.offset
		local hop = math.abs(math.sin(phase)) * 0.6
		local squish = 1 - math.abs(math.cos(phase)) * 0.04
		local wiggle = math.sin(t * 1.3 + entry.offset) * math.rad(15)
		model:PivotTo(entry.base * CFrame.new(0, hop * squish, 0) * CFrame.Angles(0, wiggle, 0))

		if entry.rainbow then
			local hue = (t * 0.25 + entry.offset) % 1
			local color = Color3.fromHSV(hue, 0.55, 1)
			for _, part in entry.tintParts do
				part.Color = color
			end
		end
	end
end

function PetAnimator.add(model: Model)
	local tintParts = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Tint") then
			table.insert(tintParts, d)
		end
	end
	active[model] = {
		base = model:GetPivot(),
		offset = math.random() * math.pi * 2,
		tintParts = tintParts,
		rainbow = model:GetAttribute("Rainbow") == true,
	}
	if not connection then
		connection = RunService.Heartbeat:Connect(step)
	end
end

function PetAnimator.remove(model: Model)
	active[model] = nil
end

return PetAnimator

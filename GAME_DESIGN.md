# Plushie Pals — Game Design Notes

> Working title. A cozy "collect, grow, and trade" game about cute plush pets.

## The one-sentence pitch
Hatch adorable plushie pets from eggs, let them grow while you're away, and trade for the rare **Golden** and **Rainbow** ones everyone wants.

## Why this can work (based on what makes Roblox hits)
| Viral ingredient | How Plushie Pals does it |
|---|---|
| Fun in 30 seconds | Spawn holding a free egg, it hatches in 10 seconds |
| Simple but deep | Click to hatch; depth comes from rarities, mutations, trading |
| Clippable moments | Rainbow mutation reveal, giant pets, server-wide "Plush Rain" event |
| Social | Trading, showing off pets that follow you, visiting friends' cottages |
| Reasons to return | Pets grow offline, egg shop restocks every 5 min, daily gift box |
| Scheduled events | Weekend "Starfall" event, everyone online at the same time |
| Scarcity | Limited eggs that leave the shop forever |
| Fair monetization | Pay for speed and cosmetics, never for power over other players |

## Core loop
1. **Buy egg** from the shop (coins) → 2. **Hatch** it (short timer, big reveal animation)
3. Pet goes to your **Cottage** and **grows** over real time (Baby → Teen → Big)
4. Bigger pets make more **coins** → buy better eggs
5. Rare / mutated pets → **trade** or **show off**

## Pets (first batch — see `src/shared/PetData.lua`)
| Pet | Look | Rarity |
|---|---|---|
| Bun Bun | Tall pink bean bunny, long ears, buck teeth, puff tail | Common |
| Mochi | Wide squishy white loaf cat, happy ^^ eyes, whiskers, calico spots, curly tail | Common |
| Puddle Pup | Blue puppy, floppy ears, snout + tongue, eye patch, wagging tail | Common |
| Froggo | Wide flat frog, eyes on top, big smile, spots, webbed feet | Uncommon |
| Honey Bear | Big round bear, snout, honey pot + honey on its head | Uncommon |
| Ducky | Yellow duck, beak, little wings, hair tuft, tail feather, orange feet | Uncommon |
| Strawbunny | Strawberry-shaped bunny, seeds, leaf hat, sparkly green eyes | Rare |
| Cloud Lamb | Floating fluffy cloud lamb, sleepy eyes, peach face, curly horns | Rare |
| Boba Panda | Extra chubby panda hugging a boba tea | Epic |
| Star Kitty | Slim cat sitting tall, sparkle eyes, star mark, bell collar, star-tipped tail | Legendary |
| Moon Bun | Sleeping floating bunny with a giant crescent moon and orbiting stars | Mythic |

## Eggs
- **Cozy Egg** (cheap, always in stock): Bun Bun, Mochi, Puddle Pup, Froggo
- **Sweet Egg** (mid): Honey Bear, Ducky, Strawbunny, Cloud Lamb
- **Starry Egg** (expensive, restocks rarely): Cloud Lamb, Boba Panda, Star Kitty, Moon Bun

## Mutations (rolled on hatch, stack with rarity)
| Mutation | Chance | Effect |
|---|---|---|
| Shiny | 1 in 20 | Sparkles, x2 coins |
| Golden | 1 in 100 | Gold body, x5 coins |
| Rainbow | 1 in 500 | Color-cycling body, x10 coins |
| Evil | 1 in 200 | Dark colors, red glowing eyes, horns, bat wings, fangs, devil tail, purple aura, own evil name, x4 coins |
| Giant | 1 in 50 | 2x size, x3 coins |
| Tiny | 1 in 50 | Half size (just cute, collectors love it) |

## Evil pets 😈
Any pet can hatch **Evil** (1 in 200). It gets an evil look and its own name:

| Pet | Evil name |
|---|---|
| Bun Bun | Doom Bun |
| Mochi | Mochi Menace |
| Puddle Pup | Shadow Pup |
| Froggo | Grimfrog |
| Honey Bear | Hex Bear |
| Ducky | Duck of Darkness |
| Strawbunny | Rotberry |
| Cloud Lamb | Storm Lamb |
| Boba Panda | Toxic Boba Panda |
| Star Kitty | Black Hole Kitty |
| Moon Bun | Blood Moon Bun |

Evil ideas to build next:
- **Blood Moon event** (random night, ~10 min): sky turns red, Evil chance x5, spooky music. Big "everyone log in now" moment.
- **Cursed Egg**: only sold during Blood Moon, always hatches Evil.
- **Cute vs Evil teams**: players pick a side each week, the side with more hatches wins a server-wide boost.
- **Purify / Corrupt machine**: trade an Evil pet + coins to turn it back cute (or the reverse). Gives both versions value.
- Evil pets leave little purple footprints when they follow you.

## Retention features
- **Offline growth** — pets grow and earn while you're gone (capped at 8h)
- **Egg shop restock** every 5 minutes with a countdown everyone can see
- **Daily gift box** — streak rewards, day 7 = guaranteed Sweet Egg
- **Pet index** — collect every pet + every mutation, with rewards per page
- **Quests** — "Hatch 3 eggs", "Trade once", "Get a Shiny"

## Social / viral features
- Pets follow you around and bounce
- **Trading booth** with a trade-history board
- **Plush Rain** (random server event): plush coins fall from the sky for 60s
- **Starfall weekend event**: Starry Egg in stock for everyone, boosted mutation chances
- Server announcement when someone hatches Mythic or Rainbow ("@player hatched a RAINBOW Moon Bun!")

## Monetization (fair)
- Gamepasses: Auto-Hatch, +2 Pet Slots, Faster Growth (x2), VIP cottage decor
- Dev products: Instant Restock (personal), Coin packs
- Cosmetics: hats/bows for pets
- **Not sold:** guaranteed Mythic or Rainbow pets (keeps trading fair and exciting)

## Update plan (first 90 days)
| Week | Update |
|---|---|
| 1 | Launch: 11 pets, 3 eggs, trading, mutations |
| 2 | Pet hats + daily gift box |
| 3 | Cottage decorating |
| 4 | **Ocean Update**: 5 sea pets + Bubble Egg (limited) |
| 6 | Pet fusion: merge 3 of the same into a Big one |
| 8 | **Candy Update** + Halloween/holiday event eggs |
| 10+ | Weekly limited egg, rotating events |

## Thumbnail / icon ideas
- Close-up of a Rainbow Moon Bun with sparkles, big shiny eyes, pastel background
- Bold text: "HATCH A RAINBOW!"
- Swap thumbnails for each update so returning players notice

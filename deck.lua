local FACE_URL =
    "https://raw.githubusercontent.com/YukinagaS/tts-assets/refs/heads/main/test/sheet-001.jpg"

local BACK_URL =
    "https://raw.githubusercontent.com/YukinagaS/tts-assets/refs/heads/main/test/back.png"

local COLUMNS = 4
local ROWS = 3
local CARD_COUNT = 8

function onLoad()
    self.createButton({
        click_function = "createDeck",
        function_owner = self,
        label = "Create Deck",
        position = {0, 0.6, 0},
        width = 1800,
        height = 450,
        font_size = 250,
        tooltip = "Summon deck"
    })
end

function createDeck(buttonObject, playerColor, altClick)
    if altClick then
        return
    end

    local p = self.getPosition()

    local deck = spawnObject({
        type = "DeckCustom",

        -- Spawn beside the button object and above the table.
        position = {p.x + 4, p.y + 3, p.z},

        -- Face down. Use {0, 180, 0} for face up.
        rotation = {0, 180, 180},

        callback_function = function(spawnedDeck)
            spawnedDeck.setName("Deck")

            -- Optional:
            -- spawnedDeck.shuffle()
        end
    })

    -- Apply immediately after spawning.
    deck.setCustomObject({
        face = FACE_URL,
        back = BACK_URL,
        width = COLUMNS,
        height = ROWS,
        number = CARD_COUNT,
        unique_back = false,
        sideways = false,
        back_is_hidden = true
    })
end
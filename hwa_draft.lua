local HWA_DRAFT_URL = "https://api.github.com/repos/YukinagaS/tts-assets/contents/hwa/draft?ref=main"

local BACK_URL =
    "https://raw.githubusercontent.com/YukinagaS/tts-assets/refs/heads/main/hwa/hwa_cardback.png"

local COLUMNS = 6
local ROWS = 4

local building = false

--Initialize button
function onLoad()
    self.createButton({
        click_function = "createDecks",
        function_owner = self,
        label = "Summon Decks",
        position = {0, 0.6, 0},
        width = 1800,
        height = 450,
        font_size = 250,
        tooltip = "Summon deck"
    })
end

-- Get deck spawning info from filename
function parseFileName(filename)
  local sheetId, copies, label, cardCount =
    filename:match("^(%d+)x(%d+)_(.+)_(%d+)%.webp$")

  assert(sheetId, "Invalid sheet filename: " .. filename)

  copies = tonumber(copies)
  cardCount = tonumber(cardCount)
  assert(copies > 0 and cardCount > 0, "Invalid counts: " .. filename)

  return {
    id = sheetId,
    copies = copies,
    label = label:gsub("_", " "),
    cardCount = cardCount
  }
end

-- Fetch card sheets from repo
local function fetchSheets(callback)
  WebRequest.get(HWA_DRAFT_URL, function(request)
    if request.is_error then
      callback(nil, request.error)
      return
    end

    if request.response_code ~= 200 then
      callback(nil, "GitHub HTTP " .. request.response_code)
      return
    end

    local ok, entries = pcall(JSON.decode, request.text)

    if not ok or type(entries) ~= "table" then
      callback(nil, "Invalid directory response")
      return
    end

    local sheets = {}

    for _, entry in ipairs(entries) do
      local name = string.lower(entry.name or "")

      if entry.type == "file"
        and name:match("%.webp$")
        and type(entry.download_url) == "string"
      then
        table.insert(sheets, entry)
      end
    end

    table.sort(sheets, function(a, b)
      return a.name < b.name
    end)

    callback(sheets, nil)
  end)
end

-- Spawn the decks from card sheets
function spawnDecks(sheets)
  local decks = {}
  local completed = 0
  local p = self.getPosition()
  local baseZ = p.z - (#sheets / 2) * 4

  for i, sheet in ipairs(sheets) do
    local index = i
    local deckInfo = parseFileName(sheet.name)

    local deck = spawnObject({
      type = "DeckCustom",
      position = {
        p.x + 4,
        p.y + 3,
        baseZ + (index - 1) * 4
      },
      rotation = {0, 90, 180},
      callback_function = function(spawnedDeck)
        spawnedDeck.setName(deckInfo.label)
      end,
    })

    local cardCount = assert(
      tonumber(sheet.name:match("[_%-](%d+)%.%w+$")),
      "Missing card count in " .. sheet.name
    )

    deck.setCustomObject({
      face = sheet.download_url,
      back = BACK_URL,
      width = COLUMNS,
      height = ROWS,
      number = deckInfo.cardCount,
      unique_back = false,
      sideways = false,
      back_is_hidden = true
    })

  end
end

function createDecks(buttonObject, playerColor, altClick)
  if altClick or building then
      return
  end

  building = true

  fetchSheets(function(sheets, err)
    if err then
      print("Deck building failed: " .. err)
      building = false
      return
    end

    if #sheets == 0 then
      print("No sheets found.")
      building = false
      return
    end

    print("Found " .. #sheets .. " card sheets.")
    spawnDecks(sheets)
    building = false
  end)
end
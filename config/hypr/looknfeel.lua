-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 15,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- Katmanlar (launcher, menü, bildirim) için kullanılan eğriler.
hl.curve("macOSOpen", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("macOSClose", { type = "bezier", points = { { 0.4, 0 }, { 0.68, 0.06 } } })

-- Pencere açılış/kapanış animasyonu yok, anlık belir/kaybol.
hl.animation({ leaf = "windowsIn", enabled = false })
hl.animation({ leaf = "fadeIn", enabled = false })
hl.animation({ leaf = "windowsOut", enabled = false })
hl.animation({ leaf = "fadeOut", enabled = false })

-- Katmanlar (launcher, menüler, bildirimler) da aynı hisle açılıp kapansın.
hl.animation({ leaf = "layersIn", enabled = true, speed = 4.5, bezier = "macOSOpen", style = "popin 85%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 5.5, bezier = "macOSClose", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 4.5, bezier = "macOSOpen" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 5.5, bezier = "macOSClose" })

-- Disable workspace transition animations.
hl.animation({ leaf = "workspaces", enabled = false })


-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Personal environment variables

-- GTK4 rendering. "cairo" forces software (CPU) rendering and was likely a
-- workaround for a display bug. "ngl" is GPU-accelerated and the most
-- conservative GPU option; if artifacts return, try "vulkan" before "cairo".
hl.env("GSK_RENDERER", "ngl")
hl.env("OMARCHY_OCR_LANGS", "tur+eng")

-- Cursor theme (overrides Omarchy default; size stays at Omarchy's default of 24).
hl.env("XCURSOR_THEME", "macos-tahoe-cursor")
hl.env("HYPRCURSOR_THEME", "macos-tahoe-cursor")

-- Make ~/.local/bin win over Omarchy's own bin dir for the running session too
-- (~/.config/uwsm/env sets this correctly for future logins, but only applies
-- at session start; this makes it take effect immediately on `hyprctl reload`).
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("PATH"))

-- The session renders on the Intel iGPU (default; the panel is wired to it).
-- The GTX 1650 stays idle until something asks for it via prime-run.
-- To put the whole session back on the NVIDIA GPU, add:
--   hl.env("AQ_DRM_DEVICES", "/dev/dri/nvidia-card:/dev/dri/intel-card")
-- (stable names come from /etc/udev/rules.d/90-gpu-symlinks.rules; never use
-- /dev/dri/by-path/* here — aquamarine splits on ":" and those paths contain
-- colons, which breaks startup with an SDDM login loop.)


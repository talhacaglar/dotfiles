local function rebind(keys, description, dispatcher, options)
	hl.unbind(keys)
	o.bind(keys, description, dispatcher, options)
end

-- Application bindings from talhacaglar/hyprland-keybinds.
rebind("SUPER + ALT + RETURN", "Tmux", [[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new]])
rebind("SUPER + RETURN", "Terminal", [[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"]])
rebind("SUPER + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
rebind("SUPER + SHIFT + F", "File manager", "nautilus --new-window")
rebind(
	"SUPER + ALT + SHIFT + F",
	"File manager (cwd)",
	[[nautilus --new-window "$(omarchy-cmd-terminal-cwd)"]]
)
-- Zen'i launch-or-focus ile ac: ham "zen-browser" her basista yeni surec
-- doguruyordu ve hizli/cift basista Firefox remoting yarisi yuzunden iki
-- pencere aciliyordu. Zaten acikken artik yeni surec baslatmadan odaklanir.
rebind("SUPER + B", "Browser", [[omarchy-launch-or-focus "^zen$" "uwsm-app -- zen-browser"]])
rebind("SUPER + M", "Music", "omarchy-launch-or-focus spotify")
rebind("SUPER + SHIFT + T", "Activity", "omarchy-launch-tui btop")
rebind("SUPER + D", "Docker", "omarchy-launch-tui lazydocker")
rebind(
	"SUPER + SHIFT + O",
	"Obsidian",
	[[omarchy-launch-or-focus "^obsidian$" "uwsm-app -- obsidian -disable-gpu --enable-wayland-ime"]]
)
rebind("SUPER + SHIFT + B", "Passwords", "uwsm-app -- bitwarden-desktop")
rebind("SUPER + SHIFT + L", "Lock", "hyprlock")

-- Utility and screenshots.
rebind("SUPER + V", "Clipboard manager", { omarchy = "walker -m clipboard" })
rebind("SUPER + Z", "Screenshot", "omarchy-capture-screenshot")
rebind("SUPER + CTRL + Z", "Extract text (OCR) from screenshot", "omarchy-capture-text-extraction")
rebind(
	"SUPER + ccedilla",
	"Translate",
	"omarchy-launch-tui ceviri"
)

-- AI tools.
rebind("SUPER + N", "Notebook LM", [[omarchy-launch-webapp "https://notebooklm.google.com/"]])
rebind("SUPER + SHIFT + C", "Claude", [[omarchy-launch-webapp "https://claude.ai/new"]])
rebind("SUPER + SHIFT + G", "Gemini", [[omarchy-launch-webapp "https://gemini.google.com"]])
rebind("SUPER + A", "ChatGPT", [[omarchy-launch-webapp "https://chatgpt.com/"]])
rebind("SUPER + SHIFT + A", "Grok", [[omarchy-launch-webapp "https://grok.com"]])
rebind("SUPER + SHIFT + D", "DeepSeek", [[omarchy-launch-webapp "https://chat.deepseek.com/"]])

-- Web apps.
rebind(
	"SUPER + C",
	"Calendar",
	[[omarchy-launch-or-focus-webapp "Google Calendar" "https://calendar.google.com/calendar"]]
)
rebind("SUPER + E", "Email", [[omarchy-launch-or-focus-webapp "Gmail" "https://mail.google.com/"]])
rebind("SUPER + SHIFT + W", "WhatsApp", [[omarchy-launch-or-focus-webapp "WhatsApp" "https://web.whatsapp.com"]])
rebind(
	"SUPER + ALT + G",
	"Google Messages",
	[[omarchy-launch-or-focus-webapp "Google Messages" "https://messages.google.com/web/conversations"]]
)
rebind("SUPER + ALT + T", "Google Tasks", [[omarchy-launch-or-focus-webapp "Google Tasks" "https://tasks.google.com"]])
rebind("SUPER + SHIFT + K", "Kairu", [[omarchy-launch-or-focus-webapp "Kairu" "https://kairu.app/focus"]])
rebind("SUPER + Y", "YouTube", [[omarchy-launch-or-focus-webapp "YouTube" "https://youtube.com"]])

-- Native apps (launch-or-focus).
rebind("SUPER + ALT + M", "Signal", [[omarchy-launch-or-focus "^signal$" "uwsm-app -- signal-desktop"]])
rebind("SUPER + ALT + D", "Discord", [[omarchy-launch-or-focus "^discord$" "env http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 uwsm-app -- discord --proxy-server=http://127.0.0.1:8118"]])
rebind("SUPER + ALT + N", "Notion", "/home/clar/.local/bin/notion-toggle")

-- Passthrough submap for VMs.
rebind("SUPER + P", "Passthrough submap", hl.dsp.submap("passthru"))
hl.define_submap("passthru", function()
	hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)

-- Cycle windows with Super + mouse wheel.
rebind("SUPER + mouse_down", "Cycle next window", hl.dsp.window.cycle_next())
rebind("SUPER + mouse_up", "Cycle previous window", hl.dsp.window.cycle_next({ next = false }))

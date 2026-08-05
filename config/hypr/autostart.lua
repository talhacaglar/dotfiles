-- Extra autostart processes.
-- Start Tuxedo Control Center in tray mode with a brief delay so the system tray is fully ready
o.exec_on_start("sleep 2.5 && tuxedo-control-center --tray")

-- Delayed Waybar start to prevent race conditions on boot
o.exec_on_start("sleep 1.5 && omarchy-restart-waybar")

-- Keep clipboard content after apps are closed
o.launch_on_start("wl-paste --watch cliphist store")

-- Walker'in veri saglayicisi elephant'i onceden baslat.
-- Aksi halde elephant yalnizca omarchy-launch-walker icinde tembel olarak
-- baslatiliyor ve walker onu beklemeden aciliyordu; bu yuzden boot sonrasi
-- ILK menude (Super+Alt+Space) tiklama kayboluyor ve menu kapaniyordu.
-- Ikinci acilista elephant ayakta oldugu icin sorun kendiliginden duzeliyordu.
o.launch_on_start("elephant")

-- $Id$

global number_of_variations

on run argv
	set save_delims to text item delimiters of AppleScript
	set text item delimiters of AppleScript to " "
	set configure_args to argv as string
	set text item delimiters of AppleScript to ";"
	set number_of_variations to count of every text item of configure_args
	set text item delimiters of AppleScript to save_delims
	
	delay 2 -- wait for Mini vMac to start launching
	
	activate application "Mini vMac"
	tell application "System Events"
		tell process "Mini vMac"
			key down control -- open Mini vMac control menu
			my key_code(1) -- "S" -- speed submenu
			my key_code(0) -- "A" -- as fast as possible
			my key_code(1) -- "S" -- speed submenu
			my key_code(11) -- "B" -- run in background too
			key up control -- close Mini vMac control menu
		end tell
	end tell
	
	delay 2 -- wait for system software to finish starting up
	
	my key_code(22) -- "6" -- select the 6-ClipIn program
	set the clipboard to configure_args -- copy the configure args to the clipboard
	my menu_file_open() -- open ClipIn, transferring the clipboard into the emulated machine; ClipIn auto-quits
	my menu_file_close() -- close Finder window
	
	my key_code(11) -- "B" -- select the Build program
	my menu_file_open() -- open it
	my menu_edit_paste() -- paste the clipboard contents into the window
	my menu_file_go() -- do the build
	my menu_file_quit() -- quit
	my menu_file_close() -- close Finder window
	my menu_file_put_away() -- eject the minivmac disk
	
	activate application "Mini vMac"
	tell application "System Events"
		tell process "Mini vMac"
			key down control -- open Mini vMac control menu
			my key_code(12) -- "Q" -- quit
			my key_code(16) -- "Y" -- yes, really quit
			key up control -- close Mini vMac control menu
		end tell
	end tell
end run

on key_code(key_code)
	my key_code_with_modifiers(key_code, {})
end key_code

-- Key codes are used instead of keystrokes because keystrokes would be
-- translated through the currently-selected Mac OS X keyboard layout
-- but the system software being used on the emulated machine is using
-- the US English keyboard layout.
on key_code_with_modifiers(key_code, key_modifiers)
	activate application "Mini vMac"
	tell application "System Events"
		tell process "Mini vMac"
			delay 0.3
			key code key_code using key_modifiers
		end tell
	end tell
end key_code_with_modifiers

on menu_file_open()
	my key_code_with_modifiers(31, {command down}) -- "Command-O"
	delay 0.5 -- wait for zoomrects to draw
end menu_file_open

on menu_file_close()
	my key_code_with_modifiers(13, {command down}) -- "Command-W"
	delay 0.5 -- wait for zoomrects to draw
end menu_file_close

on menu_file_put_away()
	my key_code_with_modifiers(16, {command down}) -- "Command-Y"
	delay 0.5 -- wait for zoomrects to draw
end menu_file_put_away

on menu_file_go()
	my key_code_with_modifiers(5, {command down}) -- "Command-G"
	delay 0.5 * number_of_variations -- wait for configuration to run
end menu_file_go

on menu_file_quit()
	my key_code_with_modifiers(12, {command down}) -- "Command-Q"
end menu_file_quit

on menu_edit_paste()
	my key_code_with_modifiers(9, {command down}) -- "Command-V"
end menu_edit_paste

extends Node

func share_score(score: int, level: int):
	var share_text = "Ben Astro Crush oyununda " + str(level) + ". seviyeye ulaştım ve " + str(score) + " puan yaptım! Sıra sende, uzayı keşfet!"
	
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Note: For real Godot 4 mobile sharing, you typically use a plugin (like godot-share plugin).
		# We'll mock the print for now, and try to use OS.shell_open for a web fallback if possible.
		var url = "https://twitter.com/intent/tweet?text=" + share_text.uri_encode()
		OS.shell_open(url)
	else:
		# Fallback for Desktop: Open Twitter share link
		var url = "https://twitter.com/intent/tweet?text=" + share_text.uri_encode()
		OS.shell_open(url)
		print("Shared: ", share_text)

# Figlet eggdrop script
#
# Matt Schiros <schiros@invisihosting.com> 2013
# include "bsd_license"
#
# v 0.1
# Pretty simple eggdrop script to pipe some text input
# to figlet (http://www.figlet.org/), and then output the 
# fancy formatted text to the channel/person who prompted it.
# 
# Format is:
# $trigger [font::]<text_to_prettify>
#
# font is any font available to your local figlet install
#
# Configurable character count cutoffs, default font for figlet,
# output width max
#

set channelTrigger "!pretty"
set msgTrigger "pretty"
set characterLimit 20
set defaultFont "standard"
set outputWidthMax 160

namespace eval figlet {
	global channelTrigger
	global msgTrigger
	bind pub -|- $channelTrigger figlet::prettifyChannel
	bind msg -|- $msgTrigger figlet::prettifyMsg
}


proc figlet::prettifyChannel {nick host handle channel text} {
	figlet::prettify $channel $text
}

proc figlet::prettifyMsg {nick host handle text} {
	figlet::prettify $nick $text
}

proc figlet::prettify {target text} {
	global characterLimit
	global defaultFont
	global outputWidthMax

	set hasFont [string first "::" $text]
	if {$hasFont > 0} {
		set textArray [split $text "::"]
		set font [lindex $textArray 0]
		set textToPrettify [lindex $textArray 2]
	} else {
		set font $defaultFont
		set textToPrettify $text
	}

	if {[string length $textToPrettify] >= $characterLimit} {
		set rangeMax $characterLimit-3
		set textToPrettify [concat [string range $textToPrettify 0 $rangeMax] "..."]
	}

	set prettyText [exec echo -n $textToPrettify | figlet -p -f $font -w $outputWidthMax]
	set prettyArray [split $prettyText "\n"]
	foreach pt $prettyArray {
		# using putquick here b/c otherwise output is sort of slow, but if your network/server 
		# is persnickety about flooding, you can switch it to putserv
		putquick [concat "PRIVMSG " $target "  :$pt"]
	}
}

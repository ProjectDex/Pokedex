#!/bin/sh
# The next line restarts using wish \
exec wish "$0" ${1+"$@"}

# This is my first try at programming a Pokédex, and I hope it'll be awesome! 
# It will be written in Tcl/Tk and if there are things that I don't like, I
# will probably switch to Python or something...

#######################################################
#       ____          __     __       __              #
#      / __ \ ____   / /__ _/_/  ____/ /___   _  __   #
#     / /_/ // __ \ / //_// _ \ / __  // _ \ | |/_/   #
#    / ____// /_/ // ,<  /  __// /_/ //  __/_>  <     #
#   /_/     \____//_/|_| \___/ \____/ \___//_/|_|     #
#                                                     #
#######################################################

### Import libraries
package require Tcl 8.5
package require Tk  8.5
package require Ttk
package require msgcat
package require Img

### Pokédex version
set version 0.01

### Safeguard cleaning everything on startup
catch {destroy [winfo children .]}

### Location of script
set pokeDir [file join [pwd] [file dirname [info script]]]

### Set up translations
::msgcat::mcload $pokeDir
namespace import ::msgcat::mc

### Import procedures
source "$pokeDir/lib.tcl"

### Window configurations
wm title . [mc "Pok\u00E9dex v%s" $version]
wm iconname . [mc "Pok\u00E9dex"]
#wm iconbitmap . -default "favicon.ico"

###
# Menu settings
###
set menu .menu
menu $menu -tearoff 0

### File
set m $menu.file
menu $m -tearoff 0
$menu add cascade -label [mc "File"] -menu $m -underline 0
$m add command -label [mc "Import mod"] -command {error "just testing"} \
  -accelerator Ctrl+I
$m add command -label [mc "Language"] -command {error "just testing"}
$m add separator
$m add command -label [mc "Close"] -command {exit} -accelerator Ctrl+Q

bind . <Control-KeyPress-I> {error "just testing"}
bind . <Alt-KeyPress-F4> {exit}
bind . <Control-KeyPress-Q> {exit}

### Tools
set m $menu.tools
menu $m -tearoff 0
$menu add cascade -label [mc "Tools"] -menu $m -underline 0
$m add command -label [mc "Search Pok\u00E9mon"] -command {error "just testing"}
$m add command -label [mc "Search Abilities"] -command {error "just testing"}
$m add command -label [mc "Search Moves"] -command {error "just testing"}
$m add command -label [mc "Search Items"] -command {error "just testing"}
$m add separator
$m add command -label [mc "Type matchup chart"] -command {error "just testing"}
$m add command -label [mc "Damage calculator"] -command {error "just testing"}
$m add command -label [mc "Compare Pok\u00E9mon"] -command {error "just testing"}

### About
set m $menu.about
menu $m -tearoff 0
$menu add cascade -label [mc "About"] -menu $m -underline 0
$m add command -label [mc "Help"] -command {error "just testing"}
$m add command -label [mc "Credits"] -command poke_credits

. configure -menu $menu

### Get Pokémon species list
set pokemonFile [open "$pokeDir/pokemon.txt" r]
fconfigure $pokemonFile -encoding utf-8
set pokeList [split [read $pokemonFile] "\n"]
close $pokemonFile

### Frames for animations
set frames [list]

### Left part of app
pack [ttk::frame .sidepane -padding 5] -fill y -side left

### Upper left being entry box
pack [ttk::frame .sidepane.top] -fill x -side top
pack [entry .sidepane.top.entry -width 16 -textvariable pokemonSpecies \
  -validate all -validatecommand {poke_autocomplete %W %d %v %P $pokeList}] \
  -pady {0 5} -expand 1 -fill x

### Lower left being list display of Pokémon
pack [ttk::frame .sidepane.bottom] -fill both -side top -expand 1
listbox .sidepane.bottom.list -yscrollcommand ".sidepane.bottom.scroll set" \
  -activestyle dotbox -selectmode browse -listvariable $pokeList
scrollbar .sidepane.bottom.scroll -command ".sidepane.bottom.list yview"
pack .sidepane.bottom.list .sidepane.bottom.scroll -side left -fill y -expand 1
.sidepane.bottom.list insert 0 {*}[lreplace $pokeList 0 0]

### Main part where information will be displayed
ttk::frame .mainpane
pack .mainpane -fill both -expand 1 -side right

### Insert tabs
ttk::notebook .mainpane.note
set note .mainpane.note

### Configure tab width and frame
#ttk::style configure Wider.TNotebook -mintabwidth 40
#$note configure -style Wider.TNotebook

pack $note -fill both -expand 1
ttk::notebook::enableTraversal $note

### Insert tabs
foreach {a b} {1 I 2 II 3 III 4 IV 5 V 6 VI} {
  ttk::frame $note.gen$a
  $note add $note.gen$a -text " Gen $b "
}

foreach i {2 3 4 5 6} {
  labelframe $note.gen$i.lab -text "Pokemon" -labelanchor n
  pack [label $note.gen$i.lab.sprite -image ""]
  grid $note.gen$i.lab -row 0 -column 0 -sticky nw
  grid columnconfigure $note.gen$i 0 -weight 1 -minsize 211
  grid rowconfigure $note.gen$i 0 -weight 1 -minsize 240
}

after idle [wm minsize . [winfo width .] [winfo height .]]



# Binds
bind .sidepane.top.entry <KeyPress-Return> [list poke_populate $pokemonSpecies]
bind .sidepane.top.entry <KeyPress-Down> [list poke_focus $pokeList]
bind .sidepane.bottom.list <Double-ButtonPress-1> [list poke_entry %W $pokeList]
bind .sidepane.bottom.list <KeyPress-Return> [list list_populate_entry %W $pokeList]











































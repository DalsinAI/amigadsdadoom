DSDA-Doom for AmigaOS 3.x
=========================

DSDA-Doom 0.24.3 (upstream https://github.com/kraflab/dsda-doom, commit
30f7a2dbf0f2aab3fd4b79194d56fc1a3b4e5bb3, tag v0.24.3, GPL-2.0-or-later),
the PrBoom+ speedrunning and demo port, for AmigaOS 3.2 on a 68040 or
68060 with an FPU. Software renderer only. Plays Doom, Doom II, Final Doom,
Freedoom, Heretic and Hexen, with Boom, MBF, MBF21, UMAPINFO and DSDA's
demo tools.

Status: builds and links; not yet run on an Amiga.


Why 0.24.3
----------

It is the last release that builds without OpenGL. From 0.25.0 on,
upstream's CMake makes OpenGL required and the GL_DOOM switch is gone: the
GL renderer is built into every program and called from the software
code. 0.24.3 still has BUILD_GL and every GL call behind #ifdef GL_DOOM, so
the AmigaOS build leaves the GL renderer out entirely and needs neither
GL.module nor SDL's OpenGL half. Like every DSDA release it has two small
C++ files (UMAPINFO and its scanner), which GFOpenAmigaGCC's g++ builds.


What you need
-------------

- AmigaOS 3.2 (or OS 3.2.3 with GFOpenUp), a 68040/68060 with an FPU, an
  RTG or AGA screen that SDL 2 can open (320x200 full screen at first).
- OpenGPU's runtime, which OpenUp installs: LIBS:OpenGPU/SDL2.module and
  LIBS:OpenGPU/SDL2_mixer.module (and opengpu.library). GL.module is not
  needed.
- A game's IWAD: none comes with the game. See IWAD-ReadMe in the drawer.
- dsda-doom.wad, beside the program (it is in the drawer): DSDA-Doom's own
  resource file, built from upstream's GPL sources in prboom2/data.


Using it
--------

Put the DSDADoom drawer inside another drawer (not at a volume's root: the
program makes its files with "drawer/name"), put an IWAD in it and open
dsda-doom's icon, or from a Shell:

    cd Work:Games/DSDADoom
    dsda-doom                       ; finds doom2.wad, doom.wad, ... here
    dsda-doom -iwad Work:WADs/doom2.wad -file mymap.wad -complevel 9
    dsda-doom -iwad doom2.wad -fastdemo mydemo.lmp

An ARGS tool type on the program's icon (ARGS=-skill 4 -warp 1) is read as
the Shell's arguments; a WAD's project icon with dsda-doom as its default
tool starts it with -iwad and that WAD. dsda-doom.cfg, screenshots,
autoload/ and dsda_doom_data/ (saves, splits, per-WAD data) are made in
the program's drawer. DOOMWADDIR, DOOMWADPATH (drawers separated by ';')
and DOOMDATADIR are read from ENV:; temporary files go to T:.

Amiga defaults (all in the menus and dsda-doom.cfg, as elsewhere):
320x200 full screen, Doom's own 35 frames a second (uncapped_framerate 0:
interpolated frames are more than a 68040 can draw), 22050 Hz sound with
Doom's 8 channels, OPL2 music, the first game pad on.


How it is built: the route
--------------------------

The same as the Chocolate Doom port (DalsinAI/amigachocolatedoom) and the
Crispy Doom port: DSDA's own SDL 2 code (prboom2/src/SDL), unchanged in
what it does, linked with OpenGPU's SDL 2 developer kit. libSDL2.a and
libSDL2_mixer.a are the program's halves; SDL2.module and SDL2_mixer.module
do the work (screen, keyboard, mouse, pads through GFOpenInput, AHI sound).
DSDA mixes its own sound effects and plays MUS/MIDI through its OPL2
emulation, into SDL_mixer's music hook.

Build (GFOpenAmigaGCC 16.2.0-open4 or later, with g++; a C compiler and
Python 3 for the build machine):

    make -f amiga/Makefile.amigaos \
         STOVE=$HOME/CradleLab/toolchain/openamigagcc-16.2.0-open4-x86_64-linux \
         NDK=$HOME/CradleLab/gfopensdk/OpenNDK/Include_H \
         SDL2KIT=/mnt/amigachrome/team2/deps/opengpu-sdk \
         ZLIB=$HOME/CradleLab/zlib-1.3.1

Output: build/amigaos/DSDADoom/ (dsda-doom, dsda-doom.wad, ReadMe,
IWAD-ReadMe, COPYING.txt and their icons) and build/amigaos/DSDADoom.info.

- amiga/config.h replaces the config.h CMake makes: WORDS_BIGENDIAN (from
  the compiler's byte order; it stops the build on a little-endian
  target), no GL_DOOM, SDL2_mixer, zlib's inflate built in for compressed
  ZDBSP nodes.
- dsda-doom.wad is made as CMake makes it: rdatawad (prboom2/data, built
  with HOSTCC for the build machine) with the lump list read from upstream's
  prboom2/data/CMakeLists.txt by amiga/wadargs.py.
- Left out: the gl_*.c renderer, the Windows launcher, opendir and main,
  w_mmap.c (w_memcache.c reads lumps instead).
- amiga/pthread_stubs.c: what libstdc++ and libgcc's unwinder ask of POSIX
  threads, for the two C++ files, which run on the game's task only.
- Flags: -noixemul -m68040 -m68881 -O2 -fomit-frame-pointer and GCC 16's
  -fno-tree-loop-distribute-patterns; upstream's -ffast-math is left out
  (with -m68881 it brings in FPU instructions a 68040 emulates). The
  warnings left off are listed, with why, in amiga/Makefile.amigaos; the
  build has none.

Icons: amiga/icons/icons.json, from DSDA-Doom's own prboom2/ICONS/
dsda-doom.png (cropped square, 128 x 128):

    python3 AMICRADLE/scripts/port_icons.py amiga/icons/icons.json --out amiga/icons


Changes to upstream
-------------------

Under #ifdef __amigaos__:

- prboom2/src/SDL/i_main.c: a 1 MB stack (libnix moves to it), a console
  window that opens only when something is printed, a Workbench start's
  arguments (from the Chocolate and Crispy ports).
- prboom2/src/SDL/i_system.c: the program's drawer by its full name
  (NameFromLock of PROGDIR:) as the config and data directory, T: for
  temporary files, ';' between DOOMWADPATH drawers.
- prboom2/src/dsda/data_organizer.c: no '/' after a name ending in ':'.
- prboom2/src/i_capture.c: -viddump's encoder pipes (fork and exec) fail
  with a message, as on a system without the encoders.
- prboom2/src/m_misc.c: the Amiga defaults above.
- Byte order fixes, below (r_demo.c, dsda/ghost.c, MUSIC/oplplayer.c).
- prboom2/src/p_setup.c: room for "GL_" and an 8-character map name.
- prboom2/src/dsda/key_frame.c: time_t is 32 bits; cast for %lld.

Under #ifdef GL_DOOM (upstream's own switch; 0.24.3's build without
OpenGL no longer compiled):

- prboom2/src/m_menu.c: the two OpenGL option pages, whose callbacks are
  in the GL renderer, are left out; Display goes on to Emulation.
- prboom2/src/SDL/i_video.c: SDL_GL_DeleteContext only with the GL
  renderer (there is never a context otherwise; the call brought SDL's
  OpenGL half, and GL.module, into the program).


Byte order
----------

The 68k is big-endian; WADs, demos, demo footers, MUS, GENMIDI, ACS and
ghost files are little-endian. DSDA reads WAD data through LittleShort()
and LittleLong() (m_swap.h), which swap when WORDS_BIGENDIAN is defined
(md5.c, MUSIC/midifile.c and xs_Float.h use it too); amiga/config.h
defines it. Checked by reading the code DSDA adds to PrBoom+ and the parts
PrBoom+ never ran big-endian:

- Map loading (p_setup.c): Doom and Hexen things and linedefs, DeePBSP and
  ZDBSP/XNOD/ZNOD nodes (zlib), blockmap, reject: all swapped; the
  on-disk structures are packed, so the 68k's 2-byte alignment doesn't
  change their size.
- Hexen ACS (hexen/p_acs.c): every int read through LittleLong.
- WAD directory, demo headers and tics, savegames (written and read on
  the same machine), DeHackEd/BEX and MBF21, UMAPINFO, MAPINFO, SNDINFO
  and SNDSEQ (text), the trig tables in dsda-doom.wad (checked and swapped
  at load), DMX sound headers (bytes put together by hand): correct.
- Fixed: the demo footer (r_demo.c), a PWAD that DSDA appends to recorded
  demos (command line, files, mouse look). It was written with its header,
  directory and MLOOK shorts in the machine's order, and when read back
  the header was swapped in place and the directory not at all, so on the
  68k every footer would have been "corrupted" and a demo's own footer
  unreadable on a PC. Now written and read little-endian.
- Fixed: ghost files (dsda/ghost.c, -export_ghost / -import_ghost) are
  ints written as they lie in memory; swapped on the 68k, so ghosts from
  other systems play here and the other way round.
- Fixed: the OPL player tested GENMIDI's flags (a little-endian short)
  unswapped, so fixed-note percussion and two-voice instruments would
  have been wrong; base_note_offset beside it was already swapped.


Not done / dropped
------------------

- OpenGL renderer (above), and so hi-res textures and detail textures;
  no SDL2_image, so screenshots are BMP, not PNG.
- Music: only DSDA's OPL2 emulation (Doom's "SB" music) for MUS and MIDI.
  No FluidSynth, PortMidi, libmad (MP3), vorbisfile (Ogg) or DUMB
  (tracker music). OPL costs CPU on a 68040: set snd_midiplayer or the
  music volume down in the menu if the game slows. opl3.library (a real
  OPL3) is a later step.
- No network game, no PCRE (the demo-pattern matching of -auto), no
  -viddump video capture.
- Key frames (rewind) and saved games are in the machine's own order: they
  are for the machine that made them, as upstream intends.


What to check first
-------------------

1. The program starts from a Shell with doom1.wad (or freedoom2.wad) in
   the drawer and dsda-doom.wad beside it: title, demo, menu; then from
   its icon. dsda-doom.cfg appears in the drawer.
2. E1M1 at 35 frames a second at 320x200 (type the cheat IDRATE in the
   game); then at 640x400.
3. Sound effects and OPL music through AHI; drums in DOOM2's MAP01 sound
   like drums (the GENMIDI fix).
4. The IWAD's own demos play in sync (demo1..3), and -fastdemo of a PC
   demo; record a demo with -record and play it back here and on a PC
   (the demo footer fix).
5. Save, quit, restart, load: dsda_doom_data/IWADNAME/ appears.
6. A PWAD with ZDBSP compressed nodes (zlib), one with UMAPINFO, and a
   Hexen map (ACS scripts: doors and lifts in Winnowing Hall).

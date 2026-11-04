/* config.h for the AmigaOS 3.x build (amiga/Makefile.amigaos), in place of
 * the one CMake makes from prboom2/cmake/config.h.cin. Software renderer
 * only (no GL_DOOM), SDL2 and SDL2_mixer from the OpenGPU kit, zlib's
 * inflate for compressed ZDBSP nodes. No SDL2_image, PCRE, libmad,
 * FluidSynth, DUMB, vorbisfile or PortMidi. */
#define PACKAGE_NAME "dsda-doom"
#define PACKAGE_TARNAME "dsda-doom"
#define WAD_DATA "dsda-doom.wad"
#define PACKAGE_VERSION "0.24.3"
#define PACKAGE_STRING "dsda-doom 0.24.3"

/* No build-time WAD directory: the search starts at PROGDIR: (the
 * program's drawer), then DOOMWADDIR and DOOMWADPATH from ENV:. */
#define DOOMWADDIR "PROGDIR:"

/* WADs, demos and the rest are little-endian; the 68k is not. m_swap.h's
 * LittleLong/LittleShort (and md5.c, midifile.c, xs_Float.h) swap only
 * when this is defined. */
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define WORDS_BIGENDIAN
#else
#error "the AmigaOS build expects a big-endian target"
#endif

#define HAVE_UNISTD_H
#define HAVE_DIRENT_H

#define HAVE_SDL_JOYSTICKGETAXIS
#define HAVE_LIBSDL2_MIXER
#define HAVE_LIBZ

#define SIMPLECHECKS

#ifdef USE_CURSES_HEADER
#include <curses.h>
#elif USE_NCURSES_HEADER
#include <ncurses.h>
#else
#error curses header not defined
#endif

int main(int argc, char *argv[])
{
	termname();

	return 0;
}

#ifdef USE_LZO1_HEADER
#include <lzoconf.h>
#elif USE_LZO2_HEADER
#include <lzo/lzoconf.h>
#else
#error lzo header not defined
#endif

int main(int argc, char *argv[])
{
	lzo_version();

	return 0;
}

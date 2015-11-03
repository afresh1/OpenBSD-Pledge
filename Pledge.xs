#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define PLEDGENAMES
#include <sys/pledge.h>

MODULE = OpenBSD::Pledge		PACKAGE = OpenBSD::Pledge

AV *
pledgenames()
    INIT:
        int i;
    CODE:
        for (i = 0; pledgenames[i].bits != 0; i++)
            XPUSHs( sv_2mortal(
                newSVpv(pledgenames[i].name, strlen(pledgenames[i].name))
            ) );
        XSRETURN(i);

int
_pledge(char * flags, SV * paths)
	CODE:
        RETVAL = pledge(flags, NULL) != -1;
	OUTPUT:
		RETVAL

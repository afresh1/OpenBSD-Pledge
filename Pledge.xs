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
_pledge(const char * flags, SV * paths)
    INIT:
        SSize_t numpaths = 0, n;

	CODE:
        if (SvOK(paths)) {
            if (SvTYPE(SvRV(paths)) != SVt_PVAV)
                croak("not an ARRAY reference");

            numpaths = av_top_index((AV *)SvRV(paths));

            const char *pledge_paths[ numpaths + 1 ];
            pledge_paths[ numpaths + 1 ] = NULL;

            for (n = 0; n <= numpaths; n++)
                pledge_paths[n]
                    = SvPV_nolen(*av_fetch((AV *)SvRV(paths), n, 0));

            RETVAL = pledge(flags, pledge_paths) != -1;
        }
        else
            RETVAL = pledge(flags, NULL) != -1;
	OUTPUT:
		RETVAL

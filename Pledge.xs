#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define PLEDGENAMES
#include <sys/pledge.h>

MODULE = OpenBSD::Pledge		PACKAGE = OpenBSD::Pledge


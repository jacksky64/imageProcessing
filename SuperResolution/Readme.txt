  Author: Victor May
  Contact: mayvic(at)gmail(dot)com
  $Date: 2011-11-19 $
  $Revision: $

Copyright 2011, Victor May

                         All Rights Reserved

All commercial use of this software, whether direct or indirect, is
strictly prohibited including, without limitation, incorporation into in
a commercial product, use in a commercial service, or production of other
artifacts for commercial purposes.     

Permission to use, copy, modify, and distribute this software and its
documentation for research purposes is hereby granted without fee,
provided that the above copyright notice appears in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of the author 
not be used in advertising or publicity pertaining to
distribution of the software without specific, written prior permission.        

For commercial uses contact the author.

THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO
THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR BE 
LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL
DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.

===========================================================================
This project is a simple implementation of the Iterative Back-Projection (IBP) 
algorithm for solving the Super-Resolution problem. It was first proposed
by Michal Irani in her 1991 paper "Improving resolution by image 
registration". The imaging model being used is described by a paper by 
Michael Elad, "Super-Resolution Reconstruction of an image". Both papers
can easily be found through a search in Google Scholar. 

I've done two simplifications to the imaging model:
1) The image blur is assumed to be spatially invariant.
2) The spatial transformation model is a global translation.

To run the example code, follow the following steps:
1) Run SRSetup.m
2) Run SRExample.m

The example code operates on a dataset that is generated synthetically from
a reference image. Thus, the exact values for the blur sigma and the
translatoin offsets are being used.
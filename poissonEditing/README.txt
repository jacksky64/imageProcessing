An implementation of Poisson Editing algorithms
===============================================

Version 1 - December 21, 2015
by Matias di Martino <matiasdm@fing.edu.uy>


Introduction
------------

This is an implementation of several algorithms and criteria for Poisson
Editing.  The methods are detailed on the associated IPOL paper:

	"Poisson Image Editing"
	Matias di Martino, Gabriele Facciolo, Enric Meinhardt-Llopis
	Image Processing On Line, 2016. DOI: XXX COMPLETE XXX
	http://dx.doi.org/ XXX COMPLETE XXX



Files
-----

README.txt                  - This file.
LICENSE.txt                 - GNU AFFERO GENERAL PUBLIC LICENSE Version 3.
src/main_SeamlessCloning.m  - Algorithm for seamless cloning
src/main_FiltImage.m        - Algorithms for various gradient-level filters
src/lib/ComputeGradient.m   - Algorithms for computing the gradient of an image
src/lib/CombineGradients.m  - Algorithms for combining two gradient fields
src/lib/SolvePoissonEq_I.m  - Poisson Solver using Fourier transforms
src/lib/SolvePoissonEq_II.m - Poisson Solver using finite diferences
src/lib/normalize.m         - Auxiliary function to normalize an image
src/lib/mt_printtime.m      - Auxiliary function to print a time interval
src/make_matlab.m           - Script to compile the M-code files (optional)
src/Makefile                - Makefile for the compilation (optional)
examples.m                  - Examples of computation
images/*.png                - Images necessary for running the examples

The M-code files inside the folders "src/" and "src/lib" will be subjected to
the IPOL peer-review process.


Usage
-----

See the file "examples.m" for three examples of Poisson Image Editing using the
provided codes.


Portability
-----------

This implementation is intended to be compatible with ALL versions of Octave
and Matlab.

The only requirement is the Image Package for Octave or the Image Processing 
Toolkit for Matlab.  These requirements are only necessary for reading 

Any case of non-portability is considered a serious bug, and the authors would
like to be notified so that they can amend it.


Copyright and License
---------------------

Copyright (C) 2015,
 Matias Di Martino <matiasdm@fing.edu.uy>
 Gabriele Facciolo <facciolo@cmla.ens-cachan.fr>
 Enric Meinhardt   <enric.meinhardt@cmla.ens-cachan.fr>

This is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

These files are distributed in the hope that they will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.



Thanks
------

The authors would be grateful to recieve any comment, especially about
portability issues, errors, bugs or strange results.

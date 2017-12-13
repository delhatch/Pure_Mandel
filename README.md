# Pure_Mandel

Author

Del Hatch

Theory

The famous Mandelbrot set is a set of points in the complex plane. In essence, what we want to find out is if the iterative function C below will converge to some constant or diverge to infinity.

The function is

C_{n+1} = C_{n}^2 + C_{0}

with the initial condition simply formed by taking the coordinates in the complex plane,

C_{0} = x + iy

If C has not exceeded the threshold value after a predetermined number of iterations, it is assumed that the current x,y location makes the function converge. In this case, plot a non-black pixel at the current location.

** FPGA Implementation

The Verilog code creates the logic necessary to implement the function for each pixel and create a 640x480 pixel VGA output.

The heart of the implementation is the "pool" of up to 12 (tested) calculation engines. The engines run a state machine operating on Q8.24 integers. Each iteration requires 4 clock cycles.

Using the Altera EP4CE115F29C7 FPGA on the DE2-115 kit, up to 12 engines can be instantiated. See the performance metrics below.

The module "coor_gen.v" generates the x,y coordinate pairs, and feeds them to engines as they become ready.

The module "Engine2VGA.v" operates on engines that have a result available. This module creates the signals required to write that engine's result into the proper location in the VGA frame buffer created from (internal) dual-port RAM.

The VGA.v together with the VGA_controller.v modules create the 640x480 color VGA signal to be displayed on a monitor. These modules read the frame buffer, look up the 24-bit colors from the look-up table, and then create the VGA waveform.

** Performance

As more engines are instantiated, the image frame rate increases.

4 engines -> 5.04 frames per second

8 engines -> 9.37 frames per second

12 engines -> 13.56 frames per second

Note: This compares very favorably to a pure NIOS II soft-core processor running at 50 MHz that takes over 12 minutes to calculate a single frame.(!)

** Improvements

There are a few areas where improvements are possible:

1) I think it is possible to reduce the number of multiplications in the engine algorithm. This could allow for faster calculations.

2) The engines consume 20 of the 9-bit embedded multiplier blocks. With 12 engines, 93% of them are used, so if any reductions are possible here it would allow for more engines to be instantiated.

3) It would be interesting to implement the ability to use the DE2-15 buttons to zoom in on the mandelbrot image.

4) Coloring improvements. There are various coloring algorithms that would be an improvement. Would require changing the imag_index.v ROM pre-loaded lookup table. File is index_logo1151.mif.





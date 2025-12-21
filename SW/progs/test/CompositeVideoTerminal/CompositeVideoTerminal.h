/*
 * UnoCompositeVideo.h
 *
 * Created: 13/12/2020 12:20:42
 *  Author: ceptimus
 */ 

#ifndef UNOCOMPOSITEVIDEO_H_
#define UNOCOMPOSITEVIDEO_H_

#define BYTES_PER_RASTER 46
#define PIXELS_PER_CHARACTER 9
#define CHARACTER_ROWS 29

// time into scanline when pixel pumper awakes (but it takes time to get going because of the interrupt handler etc.
// Units: us * 16
#define LEFT_EDGE 116
// scan line at which pixel pumper is enabled. 30 minimum to be on-screen on 7-inch monitor
#define TOP_EDGE 32
// and when it's stopped. 303 maximum to be on-screen on 7-inch monitor
#define BOTTOM_EDGE (TOP_EDGE + CHARACTER_ROWS * PIXELS_PER_CHARACTER - 1)

#endif /* UNOCOMPOSITEVIDEO_H_ */

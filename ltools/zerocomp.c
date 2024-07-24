/*
zerocomp - EDR-DOS zero runs compression for unframed payload file

MIT License

Copyright (c) 2024 Bernd Boeckmann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


/*
zerocomp encodes regions of zero as a 16-bit count with the highest bit set
to one. So, if 16 zeroes are encoded this becomes 0x8010. Data regions that
are to be copied literally are preceeded by the 16-bit byte count, with
the highest bit cleared. So 32 bytes to be copied are encoded as 0x0020
followed by the actual bytes. The end of the compressed region is encoded by
0x0000.
*/


/* To allow input size >= 64 KiB this tool must be compiled on a 32-bit
   or 64-bit host. Compilation for 86 Mode DOS is possible but may
   truncate the data if it is too large, as size_t is likely a 16-bit
   type and the near buffer in read_file may be limited to < 64 KiB.

   Running for large files on 16-bit DOS would require to change the
   packer to stream data rather than working with entire-file buffers. */


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#ifdef __FAR
 #include <libi86/malloc.h>
 #define farkeyword __far
 #define farmemcpy _fmemcpy
 #define farfree _ffree
#else
 #define farkeyword
 #define farmemcpy memcpy
 #define farfree free
#endif

#include "zerocomp.h"


int main( int argc, char *argv[] )
{
   farkeyword char *in_data, *in_ptr;
   char *out_data, *out_ptr;
   unsigned long in_size, out_size;
   uint16_t comp_start;

   if ( argc != 3 ) {
      puts( "Usage: zerocomp in-file out-file" );
      return 1;
   }

   in_data = read_file( argv[1], &in_size );
   if ( !in_data ) {
      puts( "error: can not read input file" );
      return 1;
   }

   /* get start offset of data to be compressed */
   comp_start = 0;

   out_data = malloc( in_size );
   if ( !out_data ) {
      puts( "allocation error" );
      return 1;
   }

   /* copy uncompressed part of file */
   farmemcpy( out_data, in_data, comp_start );

   /* zero-compress file... */
   in_ptr = in_data + comp_start;
   out_ptr = out_data + comp_start;
   zerocomp( in_ptr, in_size - comp_start, out_ptr, &out_size, 1 );
   printf( "in-size: %lu, out-size: %lu\n ", in_size - comp_start, out_size );

   /* ...and write everything to output file */
   if ( !write_file( argv[2], out_data, comp_start + out_size ) ) {
      puts( "error: could not write output file" );
      free( out_data );
      farfree( in_data );
      return 1;
   }

   free( out_data );
   farfree( in_data );
   return 0;
}

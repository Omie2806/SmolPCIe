 /*  -------------------------------------------------------------------------

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Copyright: Levent Ozturk crc@leventozturk.com
    https://leventozturk.com/engineering/crc/

    Polynomial: x32+x26+x23+x22+x16+x12+x11+x10+x8+x7+x5+x4+x2+x1+1
    d0 is the first data processed

    c is internal LFSR state and the CRC output. Not needed for other modules than CRC.
    c width is always same as polynomial width.
    o is the output of all modules except CRC. Not needed for CRC.
    o width is always same as data width width

  -------------------------------------------------------------------------*/

module CRC_Gen #(
	parameter SEED =  32'b11111111111111111111111111111111
)(
	input               clk,
	input               reset,
	input               fd, // First data. 1: SEED is used (initialise and calculate), 0: Previous CRC is used (continue and calculate)
	input               nd, // New Data. d input has a valid data. Calculate new CRC
	output reg          rdy,
	input       [ 31:0] d, // Data in
	output reg  [ 31:0] o, // Data
	output reg  [ 31:0] c, // CRC
    output reg  [ 31:0] c_out //after byte level bit reversal 
);
	reg                 nd_q;
	reg                 fd_q;
	reg         [ 31:0] dq;
	always @(posedge clk) begin
		nd_q <= nd;
		fd_q <= fd;

		dq[  0] <= d[  0] ^ d[  1] ^ d[  2] ^ d[  3] ^ d[  5] ^ d[  6] ^ d[  7] ^ d[ 15] ^ d[ 19] ^ d[ 21] ^ d[ 22] ^ d[ 25] ^ d[ 31];
		dq[  1] <= d[  3] ^ d[  4] ^ d[  7] ^ d[ 14] ^ d[ 15] ^ d[ 18] ^ d[ 19] ^ d[ 20] ^ d[ 22] ^ d[ 24] ^ d[ 25] ^ d[ 30] ^ d[ 31];
		dq[  2] <= d[  0] ^ d[  1] ^ d[  5] ^ d[  7] ^ d[ 13] ^ d[ 14] ^ d[ 15] ^ d[ 17] ^ d[ 18] ^ d[ 22] ^ d[ 23] ^ d[ 24] ^ d[ 25] ^ d[ 29] ^ d[ 30] ^ d[ 31];
		dq[  3] <= d[  0] ^ d[  4] ^ d[  6] ^ d[ 12] ^ d[ 13] ^ d[ 14] ^ d[ 16] ^ d[ 17] ^ d[ 21] ^ d[ 22] ^ d[ 23] ^ d[ 24] ^ d[ 28] ^ d[ 29] ^ d[ 30];
		dq[  4] <= d[  0] ^ d[  1] ^ d[  2] ^ d[  6] ^ d[  7] ^ d[ 11] ^ d[ 12] ^ d[ 13] ^ d[ 16] ^ d[ 19] ^ d[ 20] ^ d[ 23] ^ d[ 25] ^ d[ 27] ^ d[ 28] ^ d[ 29] ^ d[ 31];
		dq[  5] <= d[  2] ^ d[  3] ^ d[  7] ^ d[ 10] ^ d[ 11] ^ d[ 12] ^ d[ 18] ^ d[ 21] ^ d[ 24] ^ d[ 25] ^ d[ 26] ^ d[ 27] ^ d[ 28] ^ d[ 30] ^ d[ 31];
		dq[  6] <= d[  1] ^ d[  2] ^ d[  6] ^ d[  9] ^ d[ 10] ^ d[ 11] ^ d[ 17] ^ d[ 20] ^ d[ 23] ^ d[ 24] ^ d[ 25] ^ d[ 26] ^ d[ 27] ^ d[ 29] ^ d[ 30];
		dq[  7] <= d[  2] ^ d[  3] ^ d[  6] ^ d[  7] ^ d[  8] ^ d[  9] ^ d[ 10] ^ d[ 15] ^ d[ 16] ^ d[ 21] ^ d[ 23] ^ d[ 24] ^ d[ 26] ^ d[ 28] ^ d[ 29] ^ d[ 31];
		dq[  8] <= d[  0] ^ d[  3] ^ d[  8] ^ d[  9] ^ d[ 14] ^ d[ 19] ^ d[ 20] ^ d[ 21] ^ d[ 23] ^ d[ 27] ^ d[ 28] ^ d[ 30] ^ d[ 31];
		dq[  9] <= d[  2] ^ d[  7] ^ d[  8] ^ d[ 13] ^ d[ 18] ^ d[ 19] ^ d[ 20] ^ d[ 22] ^ d[ 26] ^ d[ 27] ^ d[ 29] ^ d[ 30];
		dq[ 10] <= d[  0] ^ d[  2] ^ d[  3] ^ d[  5] ^ d[ 12] ^ d[ 15] ^ d[ 17] ^ d[ 18] ^ d[ 22] ^ d[ 26] ^ d[ 28] ^ d[ 29] ^ d[ 31];
		dq[ 11] <= d[  0] ^ d[  3] ^ d[  4] ^ d[  5] ^ d[  6] ^ d[  7] ^ d[ 11] ^ d[ 14] ^ d[ 15] ^ d[ 16] ^ d[ 17] ^ d[ 19] ^ d[ 22] ^ d[ 27] ^ d[ 28] ^ d[ 30] ^ d[ 31];
		dq[ 12] <= d[  0] ^ d[  1] ^ d[  4] ^ d[  7] ^ d[ 10] ^ d[ 13] ^ d[ 14] ^ d[ 16] ^ d[ 18] ^ d[ 19] ^ d[ 22] ^ d[ 25] ^ d[ 26] ^ d[ 27] ^ d[ 29] ^ d[ 30] ^ d[ 31];
		dq[ 13] <= d[  0] ^ d[  3] ^ d[  6] ^ d[  9] ^ d[ 12] ^ d[ 13] ^ d[ 15] ^ d[ 17] ^ d[ 18] ^ d[ 21] ^ d[ 24] ^ d[ 25] ^ d[ 26] ^ d[ 28] ^ d[ 29] ^ d[ 30];
		dq[ 14] <= d[  2] ^ d[  5] ^ d[  8] ^ d[ 11] ^ d[ 12] ^ d[ 14] ^ d[ 16] ^ d[ 17] ^ d[ 20] ^ d[ 23] ^ d[ 24] ^ d[ 25] ^ d[ 27] ^ d[ 28] ^ d[ 29];
		dq[ 15] <= d[  1] ^ d[  4] ^ d[  7] ^ d[ 10] ^ d[ 11] ^ d[ 13] ^ d[ 15] ^ d[ 16] ^ d[ 19] ^ d[ 22] ^ d[ 23] ^ d[ 24] ^ d[ 26] ^ d[ 27] ^ d[ 28];
		dq[ 16] <= d[  1] ^ d[  2] ^ d[  5] ^ d[  7] ^ d[  9] ^ d[ 10] ^ d[ 12] ^ d[ 14] ^ d[ 18] ^ d[ 19] ^ d[ 23] ^ d[ 26] ^ d[ 27] ^ d[ 31];
		dq[ 17] <= d[  0] ^ d[  1] ^ d[  4] ^ d[  6] ^ d[  8] ^ d[  9] ^ d[ 11] ^ d[ 13] ^ d[ 17] ^ d[ 18] ^ d[ 22] ^ d[ 25] ^ d[ 26] ^ d[ 30];
		dq[ 18] <= d[  0] ^ d[  3] ^ d[  5] ^ d[  7] ^ d[  8] ^ d[ 10] ^ d[ 12] ^ d[ 16] ^ d[ 17] ^ d[ 21] ^ d[ 24] ^ d[ 25] ^ d[ 29];
		dq[ 19] <= d[  2] ^ d[  4] ^ d[  6] ^ d[  7] ^ d[  9] ^ d[ 11] ^ d[ 15] ^ d[ 16] ^ d[ 20] ^ d[ 23] ^ d[ 24] ^ d[ 28];
		dq[ 20] <= d[  1] ^ d[  3] ^ d[  5] ^ d[  6] ^ d[  8] ^ d[ 10] ^ d[ 14] ^ d[ 15] ^ d[ 19] ^ d[ 22] ^ d[ 23] ^ d[ 27];
		dq[ 21] <= d[  0] ^ d[  2] ^ d[  4] ^ d[  5] ^ d[  7] ^ d[  9] ^ d[ 13] ^ d[ 14] ^ d[ 18] ^ d[ 21] ^ d[ 22] ^ d[ 26];
		dq[ 22] <= d[  0] ^ d[  2] ^ d[  4] ^ d[  5] ^ d[  7] ^ d[  8] ^ d[ 12] ^ d[ 13] ^ d[ 15] ^ d[ 17] ^ d[ 19] ^ d[ 20] ^ d[ 22] ^ d[ 31];
		dq[ 23] <= d[  0] ^ d[  2] ^ d[  4] ^ d[  5] ^ d[ 11] ^ d[ 12] ^ d[ 14] ^ d[ 15] ^ d[ 16] ^ d[ 18] ^ d[ 22] ^ d[ 25] ^ d[ 30] ^ d[ 31];
		dq[ 24] <= d[  1] ^ d[  3] ^ d[  4] ^ d[ 10] ^ d[ 11] ^ d[ 13] ^ d[ 14] ^ d[ 15] ^ d[ 17] ^ d[ 21] ^ d[ 24] ^ d[ 29] ^ d[ 30];
		dq[ 25] <= d[  0] ^ d[  2] ^ d[  3] ^ d[  9] ^ d[ 10] ^ d[ 12] ^ d[ 13] ^ d[ 14] ^ d[ 16] ^ d[ 20] ^ d[ 23] ^ d[ 28] ^ d[ 29];
		dq[ 26] <= d[  0] ^ d[  3] ^ d[  5] ^ d[  6] ^ d[  7] ^ d[  8] ^ d[  9] ^ d[ 11] ^ d[ 12] ^ d[ 13] ^ d[ 21] ^ d[ 25] ^ d[ 27] ^ d[ 28] ^ d[ 31];
		dq[ 27] <= d[  2] ^ d[  4] ^ d[  5] ^ d[  6] ^ d[  7] ^ d[  8] ^ d[ 10] ^ d[ 11] ^ d[ 12] ^ d[ 20] ^ d[ 24] ^ d[ 26] ^ d[ 27] ^ d[ 30];
		dq[ 28] <= d[  1] ^ d[  3] ^ d[  4] ^ d[  5] ^ d[  6] ^ d[  7] ^ d[  9] ^ d[ 10] ^ d[ 11] ^ d[ 19] ^ d[ 23] ^ d[ 25] ^ d[ 26] ^ d[ 29];
		dq[ 29] <= d[  0] ^ d[  2] ^ d[  3] ^ d[  4] ^ d[  5] ^ d[  6] ^ d[  8] ^ d[  9] ^ d[ 10] ^ d[ 18] ^ d[ 22] ^ d[ 24] ^ d[ 25] ^ d[ 28];
		dq[ 30] <= d[  1] ^ d[  2] ^ d[  3] ^ d[  4] ^ d[  5] ^ d[  7] ^ d[  8] ^ d[  9] ^ d[ 17] ^ d[ 21] ^ d[ 23] ^ d[ 24] ^ d[ 27];
		dq[ 31] <= d[  0] ^ d[  1] ^ d[  2] ^ d[  3] ^ d[  4] ^ d[  6] ^ d[  7] ^ d[  8] ^ d[ 16] ^ d[ 20] ^ d[ 22] ^ d[ 23] ^ d[ 26];
	end

	always @(posedge clk or posedge reset) begin
		if(reset) begin
			c <= SEED;
			rdy <= 1'h0;
		end else begin
			rdy <= nd_q;
			if(nd_q) begin
				if (fd_q) begin
					c[  0] <= SEED[  0] ^ SEED[  6] ^ SEED[  9] ^ SEED[ 10] ^ SEED[ 12] ^ SEED[ 16] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[  0];
					c[  1] <= SEED[  0] ^ SEED[  1] ^ SEED[  6] ^ SEED[  7] ^ SEED[  9] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 13] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 24] ^ SEED[ 27] ^ SEED[ 28] ^ dq[  1];
					c[  2] <= SEED[  0] ^ SEED[  1] ^ SEED[  2] ^ SEED[  6] ^ SEED[  7] ^ SEED[  8] ^ SEED[  9] ^ SEED[ 13] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 30] ^ SEED[ 31] ^ dq[  2];
					c[  3] <= SEED[  1] ^ SEED[  2] ^ SEED[  3] ^ SEED[  7] ^ SEED[  8] ^ SEED[  9] ^ SEED[ 10] ^ SEED[ 14] ^ SEED[ 15] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 25] ^ SEED[ 27] ^ SEED[ 31] ^ dq[  3];
					c[  4] <= SEED[  0] ^ SEED[  2] ^ SEED[  3] ^ SEED[  4] ^ SEED[  6] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 15] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[  4];
					c[  5] <= SEED[  0] ^ SEED[  1] ^ SEED[  3] ^ SEED[  4] ^ SEED[  5] ^ SEED[  6] ^ SEED[  7] ^ SEED[ 10] ^ SEED[ 13] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 24] ^ SEED[ 28] ^ SEED[ 29] ^ dq[  5];
					c[  6] <= SEED[  1] ^ SEED[  2] ^ SEED[  4] ^ SEED[  5] ^ SEED[  6] ^ SEED[  7] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 14] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 25] ^ SEED[ 29] ^ SEED[ 30] ^ dq[  6];
					c[  7] <= SEED[  0] ^ SEED[  2] ^ SEED[  3] ^ SEED[  5] ^ SEED[  7] ^ SEED[  8] ^ SEED[ 10] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 28] ^ SEED[ 29] ^ dq[  7];
					c[  8] <= SEED[  0] ^ SEED[  1] ^ SEED[  3] ^ SEED[  4] ^ SEED[  8] ^ SEED[ 10] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 17] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 28] ^ SEED[ 31] ^ dq[  8];
					c[  9] <= SEED[  1] ^ SEED[  2] ^ SEED[  4] ^ SEED[  5] ^ SEED[  9] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 13] ^ SEED[ 18] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 29] ^ dq[  9];
					c[ 10] <= SEED[  0] ^ SEED[  2] ^ SEED[  3] ^ SEED[  5] ^ SEED[  9] ^ SEED[ 13] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 19] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 10];
					c[ 11] <= SEED[  0] ^ SEED[  1] ^ SEED[  3] ^ SEED[  4] ^ SEED[  9] ^ SEED[ 12] ^ SEED[ 14] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 20] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 31] ^ dq[ 11];
					c[ 12] <= SEED[  0] ^ SEED[  1] ^ SEED[  2] ^ SEED[  4] ^ SEED[  5] ^ SEED[  6] ^ SEED[  9] ^ SEED[ 12] ^ SEED[ 13] ^ SEED[ 15] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 21] ^ SEED[ 24] ^ SEED[ 27] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 12];
					c[ 13] <= SEED[  1] ^ SEED[  2] ^ SEED[  3] ^ SEED[  5] ^ SEED[  6] ^ SEED[  7] ^ SEED[ 10] ^ SEED[ 13] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 22] ^ SEED[ 25] ^ SEED[ 28] ^ SEED[ 31] ^ dq[ 13];
					c[ 14] <= SEED[  2] ^ SEED[  3] ^ SEED[  4] ^ SEED[  6] ^ SEED[  7] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 14] ^ SEED[ 15] ^ SEED[ 17] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 23] ^ SEED[ 26] ^ SEED[ 29] ^ dq[ 14];
					c[ 15] <= SEED[  3] ^ SEED[  4] ^ SEED[  5] ^ SEED[  7] ^ SEED[  8] ^ SEED[  9] ^ SEED[ 12] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 18] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 24] ^ SEED[ 27] ^ SEED[ 30] ^ dq[ 15];
					c[ 16] <= SEED[  0] ^ SEED[  4] ^ SEED[  5] ^ SEED[  8] ^ SEED[ 12] ^ SEED[ 13] ^ SEED[ 17] ^ SEED[ 19] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 29] ^ SEED[ 30] ^ dq[ 16];
					c[ 17] <= SEED[  1] ^ SEED[  5] ^ SEED[  6] ^ SEED[  9] ^ SEED[ 13] ^ SEED[ 14] ^ SEED[ 18] ^ SEED[ 20] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 25] ^ SEED[ 27] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 17];
					c[ 18] <= SEED[  2] ^ SEED[  6] ^ SEED[  7] ^ SEED[ 10] ^ SEED[ 14] ^ SEED[ 15] ^ SEED[ 19] ^ SEED[ 21] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 31] ^ dq[ 18];
					c[ 19] <= SEED[  3] ^ SEED[  7] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 20] ^ SEED[ 22] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 27] ^ SEED[ 29] ^ dq[ 19];
					c[ 20] <= SEED[  4] ^ SEED[  8] ^ SEED[  9] ^ SEED[ 12] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 21] ^ SEED[ 23] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 30] ^ dq[ 20];
					c[ 21] <= SEED[  5] ^ SEED[  9] ^ SEED[ 10] ^ SEED[ 13] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 22] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 21];
					c[ 22] <= SEED[  0] ^ SEED[  9] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 22];
					c[ 23] <= SEED[  0] ^ SEED[  1] ^ SEED[  6] ^ SEED[  9] ^ SEED[ 13] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 23];
					c[ 24] <= SEED[  1] ^ SEED[  2] ^ SEED[  7] ^ SEED[ 10] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 30] ^ dq[ 24];
					c[ 25] <= SEED[  2] ^ SEED[  3] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 15] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 25];
					c[ 26] <= SEED[  0] ^ SEED[  3] ^ SEED[  4] ^ SEED[  6] ^ SEED[ 10] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 31] ^ dq[ 26];
					c[ 27] <= SEED[  1] ^ SEED[  4] ^ SEED[  5] ^ SEED[  7] ^ SEED[ 11] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ dq[ 27];
					c[ 28] <= SEED[  2] ^ SEED[  5] ^ SEED[  6] ^ SEED[  8] ^ SEED[ 12] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 30] ^ dq[ 28];
					c[ 29] <= SEED[  3] ^ SEED[  6] ^ SEED[  7] ^ SEED[  9] ^ SEED[ 13] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 29];
					c[ 30] <= SEED[  4] ^ SEED[  7] ^ SEED[  8] ^ SEED[ 10] ^ SEED[ 14] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 30] ^ dq[ 30];
					c[ 31] <= SEED[  5] ^ SEED[  8] ^ SEED[  9] ^ SEED[ 11] ^ SEED[ 15] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 31];


					o[  0] <= SEED[ 31] ^ dq[  0];
					o[  1] <= SEED[ 30] ^ dq[  1];
					o[  2] <= SEED[ 29] ^ dq[  2];
					o[  3] <= SEED[ 28] ^ dq[  3];
					o[  4] <= SEED[ 27] ^ dq[  4];
					o[  5] <= SEED[ 26] ^ dq[  5];
					o[  6] <= SEED[ 25] ^ SEED[ 31] ^ dq[  6];
					o[  7] <= SEED[ 24] ^ SEED[ 30] ^ dq[  7];
					o[  8] <= SEED[ 23] ^ SEED[ 29] ^ dq[  8];
					o[  9] <= SEED[ 22] ^ SEED[ 28] ^ SEED[ 31] ^ dq[  9];
					o[ 10] <= SEED[ 21] ^ SEED[ 27] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 10];
					o[ 11] <= SEED[ 20] ^ SEED[ 26] ^ SEED[ 29] ^ SEED[ 30] ^ dq[ 11];
					o[ 12] <= SEED[ 19] ^ SEED[ 25] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 12];
					o[ 13] <= SEED[ 18] ^ SEED[ 24] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 30] ^ dq[ 13];
					o[ 14] <= SEED[ 17] ^ SEED[ 23] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ dq[ 14];
					o[ 15] <= SEED[ 16] ^ SEED[ 22] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 28] ^ dq[ 15];
					o[ 16] <= SEED[ 15] ^ SEED[ 21] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 27] ^ SEED[ 31] ^ dq[ 16];
					o[ 17] <= SEED[ 14] ^ SEED[ 20] ^ SEED[ 23] ^ SEED[ 24] ^ SEED[ 26] ^ SEED[ 30] ^ dq[ 17];
					o[ 18] <= SEED[ 13] ^ SEED[ 19] ^ SEED[ 22] ^ SEED[ 23] ^ SEED[ 25] ^ SEED[ 29] ^ dq[ 18];
					o[ 19] <= SEED[ 12] ^ SEED[ 18] ^ SEED[ 21] ^ SEED[ 22] ^ SEED[ 24] ^ SEED[ 28] ^ dq[ 19];
					o[ 20] <= SEED[ 11] ^ SEED[ 17] ^ SEED[ 20] ^ SEED[ 21] ^ SEED[ 23] ^ SEED[ 27] ^ dq[ 20];
					o[ 21] <= SEED[ 10] ^ SEED[ 16] ^ SEED[ 19] ^ SEED[ 20] ^ SEED[ 22] ^ SEED[ 26] ^ dq[ 21];
					o[ 22] <= SEED[  9] ^ SEED[ 15] ^ SEED[ 18] ^ SEED[ 19] ^ SEED[ 21] ^ SEED[ 25] ^ dq[ 22];
					o[ 23] <= SEED[  8] ^ SEED[ 14] ^ SEED[ 17] ^ SEED[ 18] ^ SEED[ 20] ^ SEED[ 24] ^ dq[ 23];
					o[ 24] <= SEED[  7] ^ SEED[ 13] ^ SEED[ 16] ^ SEED[ 17] ^ SEED[ 19] ^ SEED[ 23] ^ SEED[ 31] ^ dq[ 24];
					o[ 25] <= SEED[  6] ^ SEED[ 12] ^ SEED[ 15] ^ SEED[ 16] ^ SEED[ 18] ^ SEED[ 22] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 25];
					o[ 26] <= SEED[  5] ^ SEED[ 11] ^ SEED[ 14] ^ SEED[ 15] ^ SEED[ 17] ^ SEED[ 21] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 26];
					o[ 27] <= SEED[  4] ^ SEED[ 10] ^ SEED[ 13] ^ SEED[ 14] ^ SEED[ 16] ^ SEED[ 20] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 30] ^ dq[ 27];
					o[ 28] <= SEED[  3] ^ SEED[  9] ^ SEED[ 12] ^ SEED[ 13] ^ SEED[ 15] ^ SEED[ 19] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 31] ^ dq[ 28];
					o[ 29] <= SEED[  2] ^ SEED[  8] ^ SEED[ 11] ^ SEED[ 12] ^ SEED[ 14] ^ SEED[ 18] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 28] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 29];
					o[ 30] <= SEED[  1] ^ SEED[  7] ^ SEED[ 10] ^ SEED[ 11] ^ SEED[ 13] ^ SEED[ 17] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 27] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 30];
					o[ 31] <= SEED[  0] ^ SEED[  6] ^ SEED[  9] ^ SEED[ 10] ^ SEED[ 12] ^ SEED[ 16] ^ SEED[ 24] ^ SEED[ 25] ^ SEED[ 26] ^ SEED[ 28] ^ SEED[ 29] ^ SEED[ 30] ^ SEED[ 31] ^ dq[ 31];
				end else begin
					c[  0] <= c[  0] ^ c[  6] ^ c[  9] ^ c[ 10] ^ c[ 12] ^ c[ 16] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 28] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[  0];
					c[  1] <= c[  0] ^ c[  1] ^ c[  6] ^ c[  7] ^ c[  9] ^ c[ 11] ^ c[ 12] ^ c[ 13] ^ c[ 16] ^ c[ 17] ^ c[ 24] ^ c[ 27] ^ c[ 28] ^ dq[  1];
					c[  2] <= c[  0] ^ c[  1] ^ c[  2] ^ c[  6] ^ c[  7] ^ c[  8] ^ c[  9] ^ c[ 13] ^ c[ 14] ^ c[ 16] ^ c[ 17] ^ c[ 18] ^ c[ 24] ^ c[ 26] ^ c[ 30] ^ c[ 31] ^ dq[  2];
					c[  3] <= c[  1] ^ c[  2] ^ c[  3] ^ c[  7] ^ c[  8] ^ c[  9] ^ c[ 10] ^ c[ 14] ^ c[ 15] ^ c[ 17] ^ c[ 18] ^ c[ 19] ^ c[ 25] ^ c[ 27] ^ c[ 31] ^ dq[  3];
					c[  4] <= c[  0] ^ c[  2] ^ c[  3] ^ c[  4] ^ c[  6] ^ c[  8] ^ c[ 11] ^ c[ 12] ^ c[ 15] ^ c[ 18] ^ c[ 19] ^ c[ 20] ^ c[ 24] ^ c[ 25] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[  4];
					c[  5] <= c[  0] ^ c[  1] ^ c[  3] ^ c[  4] ^ c[  5] ^ c[  6] ^ c[  7] ^ c[ 10] ^ c[ 13] ^ c[ 19] ^ c[ 20] ^ c[ 21] ^ c[ 24] ^ c[ 28] ^ c[ 29] ^ dq[  5];
					c[  6] <= c[  1] ^ c[  2] ^ c[  4] ^ c[  5] ^ c[  6] ^ c[  7] ^ c[  8] ^ c[ 11] ^ c[ 14] ^ c[ 20] ^ c[ 21] ^ c[ 22] ^ c[ 25] ^ c[ 29] ^ c[ 30] ^ dq[  6];
					c[  7] <= c[  0] ^ c[  2] ^ c[  3] ^ c[  5] ^ c[  7] ^ c[  8] ^ c[ 10] ^ c[ 15] ^ c[ 16] ^ c[ 21] ^ c[ 22] ^ c[ 23] ^ c[ 24] ^ c[ 25] ^ c[ 28] ^ c[ 29] ^ dq[  7];
					c[  8] <= c[  0] ^ c[  1] ^ c[  3] ^ c[  4] ^ c[  8] ^ c[ 10] ^ c[ 11] ^ c[ 12] ^ c[ 17] ^ c[ 22] ^ c[ 23] ^ c[ 28] ^ c[ 31] ^ dq[  8];
					c[  9] <= c[  1] ^ c[  2] ^ c[  4] ^ c[  5] ^ c[  9] ^ c[ 11] ^ c[ 12] ^ c[ 13] ^ c[ 18] ^ c[ 23] ^ c[ 24] ^ c[ 29] ^ dq[  9];
					c[ 10] <= c[  0] ^ c[  2] ^ c[  3] ^ c[  5] ^ c[  9] ^ c[ 13] ^ c[ 14] ^ c[ 16] ^ c[ 19] ^ c[ 26] ^ c[ 28] ^ c[ 29] ^ c[ 31] ^ dq[ 10];
					c[ 11] <= c[  0] ^ c[  1] ^ c[  3] ^ c[  4] ^ c[  9] ^ c[ 12] ^ c[ 14] ^ c[ 15] ^ c[ 16] ^ c[ 17] ^ c[ 20] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 27] ^ c[ 28] ^ c[ 31] ^ dq[ 11];
					c[ 12] <= c[  0] ^ c[  1] ^ c[  2] ^ c[  4] ^ c[  5] ^ c[  6] ^ c[  9] ^ c[ 12] ^ c[ 13] ^ c[ 15] ^ c[ 17] ^ c[ 18] ^ c[ 21] ^ c[ 24] ^ c[ 27] ^ c[ 30] ^ c[ 31] ^ dq[ 12];
					c[ 13] <= c[  1] ^ c[  2] ^ c[  3] ^ c[  5] ^ c[  6] ^ c[  7] ^ c[ 10] ^ c[ 13] ^ c[ 14] ^ c[ 16] ^ c[ 18] ^ c[ 19] ^ c[ 22] ^ c[ 25] ^ c[ 28] ^ c[ 31] ^ dq[ 13];
					c[ 14] <= c[  2] ^ c[  3] ^ c[  4] ^ c[  6] ^ c[  7] ^ c[  8] ^ c[ 11] ^ c[ 14] ^ c[ 15] ^ c[ 17] ^ c[ 19] ^ c[ 20] ^ c[ 23] ^ c[ 26] ^ c[ 29] ^ dq[ 14];
					c[ 15] <= c[  3] ^ c[  4] ^ c[  5] ^ c[  7] ^ c[  8] ^ c[  9] ^ c[ 12] ^ c[ 15] ^ c[ 16] ^ c[ 18] ^ c[ 20] ^ c[ 21] ^ c[ 24] ^ c[ 27] ^ c[ 30] ^ dq[ 15];
					c[ 16] <= c[  0] ^ c[  4] ^ c[  5] ^ c[  8] ^ c[ 12] ^ c[ 13] ^ c[ 17] ^ c[ 19] ^ c[ 21] ^ c[ 22] ^ c[ 24] ^ c[ 26] ^ c[ 29] ^ c[ 30] ^ dq[ 16];
					c[ 17] <= c[  1] ^ c[  5] ^ c[  6] ^ c[  9] ^ c[ 13] ^ c[ 14] ^ c[ 18] ^ c[ 20] ^ c[ 22] ^ c[ 23] ^ c[ 25] ^ c[ 27] ^ c[ 30] ^ c[ 31] ^ dq[ 17];
					c[ 18] <= c[  2] ^ c[  6] ^ c[  7] ^ c[ 10] ^ c[ 14] ^ c[ 15] ^ c[ 19] ^ c[ 21] ^ c[ 23] ^ c[ 24] ^ c[ 26] ^ c[ 28] ^ c[ 31] ^ dq[ 18];
					c[ 19] <= c[  3] ^ c[  7] ^ c[  8] ^ c[ 11] ^ c[ 15] ^ c[ 16] ^ c[ 20] ^ c[ 22] ^ c[ 24] ^ c[ 25] ^ c[ 27] ^ c[ 29] ^ dq[ 19];
					c[ 20] <= c[  4] ^ c[  8] ^ c[  9] ^ c[ 12] ^ c[ 16] ^ c[ 17] ^ c[ 21] ^ c[ 23] ^ c[ 25] ^ c[ 26] ^ c[ 28] ^ c[ 30] ^ dq[ 20];
					c[ 21] <= c[  5] ^ c[  9] ^ c[ 10] ^ c[ 13] ^ c[ 17] ^ c[ 18] ^ c[ 22] ^ c[ 24] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ c[ 31] ^ dq[ 21];
					c[ 22] <= c[  0] ^ c[  9] ^ c[ 11] ^ c[ 12] ^ c[ 14] ^ c[ 16] ^ c[ 18] ^ c[ 19] ^ c[ 23] ^ c[ 24] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ c[ 31] ^ dq[ 22];
					c[ 23] <= c[  0] ^ c[  1] ^ c[  6] ^ c[  9] ^ c[ 13] ^ c[ 15] ^ c[ 16] ^ c[ 17] ^ c[ 19] ^ c[ 20] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ c[ 31] ^ dq[ 23];
					c[ 24] <= c[  1] ^ c[  2] ^ c[  7] ^ c[ 10] ^ c[ 14] ^ c[ 16] ^ c[ 17] ^ c[ 18] ^ c[ 20] ^ c[ 21] ^ c[ 27] ^ c[ 28] ^ c[ 30] ^ dq[ 24];
					c[ 25] <= c[  2] ^ c[  3] ^ c[  8] ^ c[ 11] ^ c[ 15] ^ c[ 17] ^ c[ 18] ^ c[ 19] ^ c[ 21] ^ c[ 22] ^ c[ 28] ^ c[ 29] ^ c[ 31] ^ dq[ 25];
					c[ 26] <= c[  0] ^ c[  3] ^ c[  4] ^ c[  6] ^ c[ 10] ^ c[ 18] ^ c[ 19] ^ c[ 20] ^ c[ 22] ^ c[ 23] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 28] ^ c[ 31] ^ dq[ 26];
					c[ 27] <= c[  1] ^ c[  4] ^ c[  5] ^ c[  7] ^ c[ 11] ^ c[ 19] ^ c[ 20] ^ c[ 21] ^ c[ 23] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ dq[ 27];
					c[ 28] <= c[  2] ^ c[  5] ^ c[  6] ^ c[  8] ^ c[ 12] ^ c[ 20] ^ c[ 21] ^ c[ 22] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 27] ^ c[ 28] ^ c[ 30] ^ dq[ 28];
					c[ 29] <= c[  3] ^ c[  6] ^ c[  7] ^ c[  9] ^ c[ 13] ^ c[ 21] ^ c[ 22] ^ c[ 23] ^ c[ 25] ^ c[ 26] ^ c[ 27] ^ c[ 28] ^ c[ 29] ^ c[ 31] ^ dq[ 29];
					c[ 30] <= c[  4] ^ c[  7] ^ c[  8] ^ c[ 10] ^ c[ 14] ^ c[ 22] ^ c[ 23] ^ c[ 24] ^ c[ 26] ^ c[ 27] ^ c[ 28] ^ c[ 29] ^ c[ 30] ^ dq[ 30];
					c[ 31] <= c[  5] ^ c[  8] ^ c[  9] ^ c[ 11] ^ c[ 15] ^ c[ 23] ^ c[ 24] ^ c[ 25] ^ c[ 27] ^ c[ 28] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[ 31];


					o[  0] <= c[ 31] ^ dq[  0];
					o[  1] <= c[ 30] ^ dq[  1];
					o[  2] <= c[ 29] ^ dq[  2];
					o[  3] <= c[ 28] ^ dq[  3];
					o[  4] <= c[ 27] ^ dq[  4];
					o[  5] <= c[ 26] ^ dq[  5];
					o[  6] <= c[ 25] ^ c[ 31] ^ dq[  6];
					o[  7] <= c[ 24] ^ c[ 30] ^ dq[  7];
					o[  8] <= c[ 23] ^ c[ 29] ^ dq[  8];
					o[  9] <= c[ 22] ^ c[ 28] ^ c[ 31] ^ dq[  9];
					o[ 10] <= c[ 21] ^ c[ 27] ^ c[ 30] ^ c[ 31] ^ dq[ 10];
					o[ 11] <= c[ 20] ^ c[ 26] ^ c[ 29] ^ c[ 30] ^ dq[ 11];
					o[ 12] <= c[ 19] ^ c[ 25] ^ c[ 28] ^ c[ 29] ^ c[ 31] ^ dq[ 12];
					o[ 13] <= c[ 18] ^ c[ 24] ^ c[ 27] ^ c[ 28] ^ c[ 30] ^ dq[ 13];
					o[ 14] <= c[ 17] ^ c[ 23] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ dq[ 14];
					o[ 15] <= c[ 16] ^ c[ 22] ^ c[ 25] ^ c[ 26] ^ c[ 28] ^ dq[ 15];
					o[ 16] <= c[ 15] ^ c[ 21] ^ c[ 24] ^ c[ 25] ^ c[ 27] ^ c[ 31] ^ dq[ 16];
					o[ 17] <= c[ 14] ^ c[ 20] ^ c[ 23] ^ c[ 24] ^ c[ 26] ^ c[ 30] ^ dq[ 17];
					o[ 18] <= c[ 13] ^ c[ 19] ^ c[ 22] ^ c[ 23] ^ c[ 25] ^ c[ 29] ^ dq[ 18];
					o[ 19] <= c[ 12] ^ c[ 18] ^ c[ 21] ^ c[ 22] ^ c[ 24] ^ c[ 28] ^ dq[ 19];
					o[ 20] <= c[ 11] ^ c[ 17] ^ c[ 20] ^ c[ 21] ^ c[ 23] ^ c[ 27] ^ dq[ 20];
					o[ 21] <= c[ 10] ^ c[ 16] ^ c[ 19] ^ c[ 20] ^ c[ 22] ^ c[ 26] ^ dq[ 21];
					o[ 22] <= c[  9] ^ c[ 15] ^ c[ 18] ^ c[ 19] ^ c[ 21] ^ c[ 25] ^ dq[ 22];
					o[ 23] <= c[  8] ^ c[ 14] ^ c[ 17] ^ c[ 18] ^ c[ 20] ^ c[ 24] ^ dq[ 23];
					o[ 24] <= c[  7] ^ c[ 13] ^ c[ 16] ^ c[ 17] ^ c[ 19] ^ c[ 23] ^ c[ 31] ^ dq[ 24];
					o[ 25] <= c[  6] ^ c[ 12] ^ c[ 15] ^ c[ 16] ^ c[ 18] ^ c[ 22] ^ c[ 30] ^ c[ 31] ^ dq[ 25];
					o[ 26] <= c[  5] ^ c[ 11] ^ c[ 14] ^ c[ 15] ^ c[ 17] ^ c[ 21] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[ 26];
					o[ 27] <= c[  4] ^ c[ 10] ^ c[ 13] ^ c[ 14] ^ c[ 16] ^ c[ 20] ^ c[ 28] ^ c[ 29] ^ c[ 30] ^ dq[ 27];
					o[ 28] <= c[  3] ^ c[  9] ^ c[ 12] ^ c[ 13] ^ c[ 15] ^ c[ 19] ^ c[ 27] ^ c[ 28] ^ c[ 29] ^ c[ 31] ^ dq[ 28];
					o[ 29] <= c[  2] ^ c[  8] ^ c[ 11] ^ c[ 12] ^ c[ 14] ^ c[ 18] ^ c[ 26] ^ c[ 27] ^ c[ 28] ^ c[ 30] ^ c[ 31] ^ dq[ 29];
					o[ 30] <= c[  1] ^ c[  7] ^ c[ 10] ^ c[ 11] ^ c[ 13] ^ c[ 17] ^ c[ 25] ^ c[ 26] ^ c[ 27] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[ 30];
					o[ 31] <= c[  0] ^ c[  6] ^ c[  9] ^ c[ 10] ^ c[ 12] ^ c[ 16] ^ c[ 24] ^ c[ 25] ^ c[ 26] ^ c[ 28] ^ c[ 29] ^ c[ 30] ^ c[ 31] ^ dq[ 31];
				end
			end
		end
	end

    always_comb begin
        for (integer i = 0; i < 8; i++) begin
            c_out[i]      = c[7 - i];
        end
        for (integer i = 0; i < 8; i++) begin
            c_out[i + 8]  = c[15 - i];
        end
        for (integer i = 0; i < 8; i++) begin
            c_out[i + 16] = c[23 - i];
        end
        for (integer i = 0; i < 8; i++) begin
            c_out[i + 24] = c[31 - i];
        end
    end
endmodule
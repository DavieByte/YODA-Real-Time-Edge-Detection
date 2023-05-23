`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Applying noise reduction  using a Median Filter
//////////////////////////////////////////////////////////////////////////////////


module medianFilter(
input i_clk,
input [71:0] i_pixel_data,
input i_pixel_data_valid,
output reg [7:0] o_median_data,
output reg o_median_data_valid
);

always @(posedge i_clk)
begin
    if(i_pixel_data_valid)
    begin
        o_median_data = median_2 (i_pixel_data[7:0],   i_pixel_data[15:8],  i_pixel_data[23:16], 
                                  i_pixel_data[31:24], i_pixel_data[39:32], i_pixel_data[47:40],
                                  i_pixel_data[55:48], i_pixel_data[63:56], i_pixel_data[71:64]);
        o_median_data_valid <= 1;
    end
end

function [0:7] median_1;
input [0:7] p_1;
input [0:7] p_2;
input [0:7] p_3;
begin
    if(p_1>=p_3 && p_1<=p_2)  // 3 1 2
		median_1=p_1;
	else if(p_1>=p_2 && p_1<=p_3)  // 2 1 3 
		median_1=p_1;
	else if(p_2>=p_1 && p_2<=p_3)  // 1 2 3 
		median_1=p_2;
	else if(p_2>=p_3 && p_2<=p_1)  // 3 2 1 
		median_1=p_2;
	else if(p_3>=p_1 && p_3<=p_2)  // 1 3 2
		median_1=p_3;
	else if(p_3>=p_2 && p_3<=p_1)  // 2 3 1
		median_1=p_3;
end
endfunction

function [0:7] median_2;
input	 [0:7] p11;  
input	 [0:7] p12;
input	 [0:7] p13;
input	 [0:7] p21;
input	 [0:7] p22;
input	 [0:7] p23;
input	 [0:7] p31;
input	 [0:7] p32;
input	 [0:7] p33;
reg   	[0:7] L1;
reg     [0:7] L2;
reg     [0:7] L3;
begin
    L1 = median_1(p11, p12, p13);
    L2 = median_1(p21, p22, p23);
    L3 = median_1(p31, p32, p33);
    median_2 = median_1(L1, L2, L3);
end
endfunction



endmodule

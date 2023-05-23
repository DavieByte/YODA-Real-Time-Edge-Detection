`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Setting up the top module
//////////////////////////////////////////////////////////////////////////////////


module ImageProcessTop(
input axi_clk,
input axi_reset_n,
// slave interface
input i_data_valid,
input [7:0] i_data,
output o_data_ready,
// master interface
output o_data_valid,
output [7:0] o_data,
input i_data_ready,
// interupt
output m_intr,
output s_intr
);
// ////////////////////////////////////////////////////
// instantiating components for the different modules
// ///////////////////////////////////////////////////
// line buffer for median filter (Image Control)
wire [71:0] pixel_data;
wire pixel_data_valid;
// median filter 
wire [7:0] median_data;
wire median_data_valid;
// line buffer from median filter to sobel (Image Control)
wire [71:0] median_pixel_data;
wire median_pixel_data_valid;
// sobel operator 
wire [7:0] sobel_data;
wire sobel_data_valid;

wire axis_prog_full;
assign o_data_ready = !axis_prog_full;

// instantiating control module
imageControl medianIC(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(i_data),
    .i_pixel_data_valid(i_data_valid),
    .o_pixel_data(pixel_data),
    .o_pixel_data_valid(pixel_data_valid),
    .o_intr(m_intr)
);    

// instantiating median filter module
medianFilter median(
    .i_clk(axi_clk),
    .i_pixel_data(pixel_data),
    .i_pixel_data_valid(pixel_data_valid),
    .o_median_data(median_data),
    .o_median_data_valid(median_data_valid)
);

imageControl sobelIC(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(median_data),
    .i_pixel_data_valid(median_data_valid),
    .o_pixel_data(median_pixel_data),
    .o_pixel_data_valid(median_pixel_data_valid),
    .o_intr(s_intr)
);   

// instantiating sobel operator module
sobel sobelOperator(
    .i_clk(axi_clk),
    .i_pixel_data(median_pixel_data),
    .i_pixel_data_valid(median_pixel_data_valid),
    .o_sobel_data(sobel_data),
    .o_sobel_data_valid(sobel_data_valid)
);

outputBuffer OB (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(sobel_data_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(sobel_data),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(i_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);


endmodule

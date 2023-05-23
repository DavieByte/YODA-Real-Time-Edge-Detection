`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Test bench for all the modules
//////////////////////////////////////////////////////////////////////////////////

`define headerSize  1080// parameter used for skipping header lines in the file
`define imageSize 226*400

module tb(

);

integer inFile;
integer inScan;
integer outFile;
integer outScan;
integer i;
integer receivedData = 0;

reg clk;
reg reset;
reg [7:0] imgData;
reg imgDataValid;
integer sentSize;
wire m_intr;
wire s_intr;
wire [7:0] outData;
wire outDataValid;

// setting up clock signal
initial
begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk; // every 5 nano seconds
    end
end

// logic to get pixel data from input file and write to output file
initial 
begin
    // setting reset input after 100ns
    reset = 0;
    sentSize = 0;
    imgDataValid = 0;
    #100;
    reset = 1;
    #100;

    // reading from file
    inFile  = $fopen("grayFrame.txt", "rb");
    outFile = $fopen("outGrayFrame.txt", "wb"); //need to make output file to write to
    // sending in pixel data from inFile, filling up buffers
    for(i = 0; i < 4*400; i = i + 1)
    begin
        @(posedge clk);
        inScan = $fscanf(inFile, "%h\n", imgData);
        imgDataValid <= 1'b1;
    end
    sentSize = 4*400;
    @(posedge clk);
    imgDataValid <= 1'b0;
    // setting up interupts to read in next line of pixel data
    while(sentSize < `imageSize)
    begin
        @(posedge m_intr);
        for(i = 0; i < 400; i = i + 1)
        begin
            @(posedge clk);
            inScan = $fscanf(inFile, "%h\n", imgData);
            imgDataValid <= 1'b1;
        end 
        @(posedge clk);
        imgDataValid <= 1'b0;  
        sentSize = sentSize + 400; 
    end
    // the entire file should be loaded in at this point
    // adding padding to the convolution process
    // should prevent the first and last pixel row to be missing in output image
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge m_intr);
    for(i = 0; i < 400; i = i + 1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;    
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge m_intr);
    for(i = 0; i < 400; i = i + 1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;    
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    $fclose(inFile);
end

// setting up logic for capturing data from IP
always @(posedge clk)
begin
    if(outDataValid)
    begin
        $fwrite(outFile, "%h\n", outData);
        receivedData = receivedData + 1;
    end
    if(receivedData == `imageSize)
    begin
        $fclose(outFile);
        $stop;
    end
end
    
ImageProcessTop dut(
.axi_clk(clk),
.axi_reset_n(reset),
// slave interface
.i_data_valid(imgDataValid),
.i_data(imgData),
.o_data_ready(), 
// master interface
.o_data_valid(outDataValid),
.o_data(outData),
.i_data_ready(1'b1), // don't do this for real life application
// interupt
.m_intr(m_intr),
.s_intr(s_intr)
);    
    
endmodule

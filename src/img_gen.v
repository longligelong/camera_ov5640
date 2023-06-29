`timescale 1ns/1ps

module img_gen
#(
    parameter   ACTIVE_IW = 1280,
    parameter   ACTIVE_IH = 720,
    parameter   TOTAL_IW  = 1650,
    parameter   TOTAL_IH  = 750,
    parameter   H_START   = 110,
    parameter   V_START   = 10

)
(
    input                   clk,
    input                   rst_n,

    output  reg             pre_vs,
    output  reg             pre_de,
    output  reg [7:0]       pre_data

/*     input                   wr_start,
    output  reg             rd_start */
);

/**************************wire***************************/
wire    pixel_valid;
/**************************reg***************************/
reg     [7:0]   raw_array   [ACTIVE_IH*ACTIVE_IW-1:0];
reg     [10:0]  hs_cnt;
reg     [10:0]  vs_cnt;
reg             hvcnt_de;
reg             hs_de;
reg             vs_de;
reg             index_de;
reg     [19:0]  index;
reg	    [31:0]	cnt_delay	;
/**************************initial***************************/
/* integer i;
initial begin
    for(i=0;i<ACTIVE_IH*ACTIVE_IW;i=i+1)
        raw_array[i] = 0;
end

initial begin
    $readmemh("D:/lesson/lesson6/data/pre.txt",raw_array);
end */
/**************************assign***************************/

/**************************process***************************/

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt_delay <= 'd0;
	else if(cnt_delay==1000*5-1)
		cnt_delay <= cnt_delay;
	else
		cnt_delay <= cnt_delay + 1'b1;

always@(posedge clk)
begin
    if(!rst_n)
        hvcnt_de <= 'b0;
    else if(cnt_delay==1000*5-1)
        hvcnt_de <= 'b1;
    else
        hvcnt_de <= hvcnt_de;
end

always@(posedge clk)
begin
    if(!rst_n)
        hs_cnt <= 'd0;
    else if(hs_cnt == TOTAL_IW-1)
        hs_cnt <= 'd0;
    else if(hvcnt_de)
        hs_cnt <= hs_cnt + 'd1;
    else
        hs_cnt <= hs_cnt;
end

always@(posedge clk)
begin
    if(!rst_n)
        vs_cnt <= 'd0;
    else if((vs_cnt == TOTAL_IH-1)&&(hs_cnt == TOTAL_IW-1))
        vs_cnt <= 'd0;
    else if(hs_cnt == TOTAL_IW-1)
        vs_cnt <= vs_cnt + 'b1;
    else
        vs_cnt <= vs_cnt;
end

always@(posedge clk)
begin
    if(!rst_n)
        pre_vs <= 'b0;
    else if(vs_cnt >= 2)
        pre_vs <= 'b1;
    else
        pre_vs <= 'b0;
end

always@(posedge clk)
begin
    if(!rst_n)
        hs_de <= 'd0;
    else if((hs_cnt >= H_START)&&(hs_cnt<H_START+ACTIVE_IW))
        hs_de <= 'b1;
    else
        hs_de <= 'b0;
end

always@(posedge clk)
begin
    if(!rst_n)
        vs_de <= 0;
    else if((vs_cnt>=V_START)&&(vs_cnt<V_START+ACTIVE_IH))
        vs_de <= 'b1;
    else
        vs_de <= 'b0;
end

/* always@(posedge clk)
    if(!rst_n)
        rd_start <= 'b0;
    else if(vs_cnt>=10)
        rd_start <= 'b1;
    else
        rd_start <= rd_start; */

always@(posedge clk)
begin
    if(!rst_n)
        index_de <= 'b0;
    else if(vs_de & hs_de)
        index_de <= 'b1;
    else
        index_de <= 'b0;
end



always@(posedge clk)
begin
    if(!rst_n)
        index <= 'd0;
    else if(index == ACTIVE_IH*ACTIVE_IW-1)
        index <= 'd0;
    else if(index_de)
        index <= index+1;
    else
        index <= index;
end

always@(posedge clk)
begin
    if(index_de)
        pre_data <= index;
    else
        pre_data <= 0;
end

/* always@(posedge clk)
begin
    if(index_de)
        pre_data <= index;
    else
        pre_data <= 0;
end */

always@(posedge clk)
begin
    if(!rst_n)
        pre_de <= 'b0;
    else
        pre_de <= index_de;
end


endmodule
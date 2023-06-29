 /*相机输出RGB565数据 每一次传输八位 将两字节数据拼成24位RGB888格式*/
module data_joint(
	input						tpclk       ,
	input						rst_n	    ,

	input	[7:0]				data_in		,
	input						vs  		,		//帧同步信号
	input						de       	,		//为高代表图像数据有效

	output 		 				de_o		,
	output  reg	[15:0] 			data_out	,
	output  reg					pclk_2x     ,
	output						vs_o		
);
/*********************wire****************/

/********************reg*******************/
reg	[15:0]	data_16		;
reg	[2:0]	data_cnt 	;
reg	[2:0]	de_r		;
reg	[2:0]	vs_r		;

/********************assign*******************/
assign	de_o=de_r[2]	;	
assign	vs_o=vs_r[2]	;

/********************process*******************/
always@(posedge tpclk)
	if(!rst_n)
		data_cnt<='d0;
	else if(de==1'b1&&data_cnt==3'd2)
		data_cnt<='d1;
	else if(de==1'b1)
		data_cnt<=data_cnt+1'd1;
	else
		data_cnt<='d0;
		

always@(posedge tpclk)
	if(!rst_n)
		data_16<=16'b0;
	else if(de==1'b1)
		data_16<={data_16[7:0],data_in};
	else
		data_16<=16'd0;

always@(posedge tpclk)
	if(!rst_n)
		data_out<=16'd0;
	else if(data_cnt==3'd2)
		data_out<=data_16;
	else
		data_out<=data_out;

always@(posedge tpclk)
	if(!rst_n)
		de_r<=3'b0;
	else
		de_r<={de_r[1:0],de};

always@(posedge tpclk)
	if(!rst_n)
		vs_r<=3'b0;
	else
		vs_r<={vs_r[1:0],vs};


always@(posedge tpclk)
	if(!rst_n)
		pclk_2x<='b0;
	else
		pclk_2x<=~pclk_2x;

endmodule
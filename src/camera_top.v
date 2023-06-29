module camera_top(
	input	              clk_50M     ,
  input               rst_n       ,

	output	            scl         ,
	inout	              sda         ,

	input	  [7:0]	      data_in     ,
	input	              tpclk       ,
	input	              vsync       ,
	input	              href        ,
  output  reg         cam_rest    ,
  output              pwdn        
        
/*
  output              xclk        ,    
  output              init_over   ,
	output	[15:0]	    pre_data    ,
	output	            pre_clk     ,
	output	            pre_de      ,
  output              vs_o     */    
);

/***********************reg**************************/
reg [19:0]              lock_cnt        ;

reg		[15:0]	hcnt			                ;
reg		[15:0]	vcnt		                  ;

reg		[31:0]	cnt_1s			              ;
reg		[7:0]   fps_cnt			              ;
reg		[7:0]   cmos_fps		              ;  

reg   [3:0]   vs_d                      ;
wire           pos_vs                   ;

localparam IW = 1280;
localparam IH = 720;
localparam _1s = 70000000;



/***********************wire**************************/
wire            xclk                ;
wire            init_over           ;
wire   [15:0]   pre_data            ;
wire            pre_clk             ;
wire            pre_de              ;
wire            vs_o                ;


wire      clock_100k_test     ;
wire      sda_o               ; 
wire      sda_release         ;




/***********************assign**************************/
assign xclk = 1'b1                                     ;
assign pwdn = (lock_cnt >= 20'd30_0000) ? 1'b0 : 1'b1  ;
assign sda  = sda_release ? 1'bz : sda_o               ; 

assign pos_vs=~vs_d[2]&&vs_d[1];



/***********************exp**************************/



data_joint u_data_joint(
.tpclk		        (tpclk      )     ,
.rst_n		        (init_over  )     ,
.data_in	        (data_in    )     ,		
.vs		            (vsync      )     ,		//帧同步信号
.de		            (href       )     ,		//为高代表图像数据有效
.de_o		          (pre_de     )     ,		
.data_out	        (pre_data   )     ,
.pclk_2x       	  (pre_clk    )     ,
.vs_o             (vs_o       )
);

reg_config     u_reg_config(
.clk_50M		      (clk_50M    )     ,
.rst_n		        (cam_rest   )     ,
.init_over		    (init_over  )     ,	//input
.scl			        (scl        )     ,
.sda            	(sda_o      )     ,
.sda_release      (sda_release)     ,
.clock_100k_test  (clock_100k_test)  

);


/***********************process**************************/

always @(posedge clk_50M) begin
  if(!rst_n)
    lock_cnt<='d0;
  else if(lock_cnt  >= 20'd50_0000)
    lock_cnt <= lock_cnt;
  else
    lock_cnt <= lock_cnt + 1'b1;

end

always @(posedge clk_50M)  begin
  if(lock_cnt >= 20'd50_0000)
      cam_rest <= 1'b1;
  else
      cam_rest   <= 1'b0;
end


always@(posedge tpclk)
  if(!rst_n)
    vs_d<=4'b0;
  else
    vs_d<={vs_d[2:0],vs_o};



always @(posedge tpclk or negedge rst_n)
	if(!rst_n)
		hcnt <= 'd0;
	else if(pos_vs==1'b1)
		hcnt <= 'd0;
	else if(hcnt==IW-1&&pre_de==1'b1)
		hcnt <= 'd0;
	else if(pre_de==1'b1)
		hcnt <= hcnt + 1'b1;
	else
		hcnt <= hcnt;	

always @(posedge tpclk or negedge rst_n)
	if(!rst_n)
		vcnt <= 'd0;
	else if(pos_vs==1'b1)
		vcnt <= 'd0;
	else if(hcnt==IW-1'b1&&pre_de==1'b1)
		vcnt <= vcnt + 1'b1;
	else
		vcnt <= vcnt;

always@(posedge tpclk or negedge rst_n)
	if(!rst_n)
		cnt_1s <= 'd0;
	else if(cnt_1s==_1s-1)
		cnt_1s <= 'd0;
	else
		cnt_1s <= cnt_1s + 1'b1;

  always@(posedge tpclk or negedge rst_n)
	if(!rst_n)
		fps_cnt <= 'd0;
	else if(cnt_1s==_1s-1)
		fps_cnt <= 'd0;
	else if(pos_vs==1'b1)	
		fps_cnt <= fps_cnt + 1'b1;	
	else
		fps_cnt <= fps_cnt;

  always@(posedge tpclk or negedge rst_n)
	if(!rst_n)
		cmos_fps <= 'd0;
	else if(cnt_1s==_1s-1)
		cmos_fps <= fps_cnt;
	else
		cmos_fps <= cmos_fps;

ila_0 u_ila (
	.clk(tpclk), // input wire clk


	.probe0({ vs_o    		,   		
		        pre_de     		,   		
		        pre_data     		,   		
		        cam_rest    		,   		
		        pwdn     		,

		        href		,     
            pos_vs    ,
		        vsync	,  
		        data_in  	,

		        //cnt_1s				,
		        fps_cnt	            ,
		        cmos_fps			,

		        hcnt				,
		        vcnt	
            }) // input wire [199:0] probe0
);

endmodule
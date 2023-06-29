`timescale 1ns/1ps
module tb_camera();
reg                 clk         ;
reg                 tpclk       ;   
reg                 rst_n       ;	
wire     [7:0]      data_in     ;	
wire                vs          ;  	
wire                de          ;

wire                de_o	    ;
wire    [15:0]      data_out    ;
wire                pclk_2x     ;
wire                vs_o	    ;
wire                init_over   ;


wire                scl         ;       
wire                sda         ;            
wire                cam_rest    ; 
wire                pwdn        ;
wire                xclk        ;   
 
      

integer	outfile;

initial begin
    tpclk='b0;
    clk='b0;
    rst_n='b0;
    #200
    rst_n='b1;
    #100

	outfile = $fopen("D:/lesson/camera/data/post.txt","w");
end

always#10 tpclk=~tpclk;
always#10 clk=~clk;


img_gen #(
    .ACTIVE_IW      (640    )      ,
    .ACTIVE_IH      (480    )      ,
    .TOTAL_IW       (800    )      ,
    .TOTAL_IH       (600    )      ,
    .H_START        (50     )      ,
    .V_START        (30     )      
)
u_img_gen(
.clk            (tpclk      )       ,
.rst_n          (init_over  )       ,
.pre_vs         (vs         )       ,
.pre_de         (de         )       ,
.pre_data       (data_in    )
);



camera_top  u_camera_top(
    .clk_50M            (clk         )      ,
    .rst_n              (rst_n       )      ,
    .scl                (scl         )      ,
    .sda                (sda         )      ,
    .data_in            (data_in     )      ,
    .tpclk              (tpclk       )      ,
    .vsync              (vs          )      ,
    .href               (de          )      ,
    .cam_rest           (cam_rest    )      ,
    .pwdn               (pwdn        )      ,
    .xclk               (xclk        )      ,
    .init_over          (init_over   )      ,
    .pre_data           (data_out    )      ,
    .pre_clk            (pclk_2x     )      ,
    .pre_de             (de_o        )      ,
    .vs_o               (vs_o        )
);

reg vs_o_r;

always@(posedge pclk_2x)
    if(!rst_n)
        vs_o_r<='b0;
    else
        vs_o_r<=vs_o;

always@(posedge pclk_2x)
    if(vs_o_r&&~vs_o)
        begin
            $stop;
        end

always @(posedge pclk_2x)
	if(de_o==1)
		begin
			$fdisplay(outfile,"%h",data_out);
		end 

endmodule






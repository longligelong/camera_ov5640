`timescale 1ns/1ps
module tb_data_joint();
reg                 tpclk       ;   
reg                 rst_n       ;	
wire     [7:0]      data_in     ;	
wire                vs          ;  	
wire                de          ;      
wire                de_o	    ;
wire    [15:0]      data_out    ;
wire                pclk_2x     ;
wire                vs_o	    ;

integer	outfile;

initial begin
    tpclk='b0;
    rst_n='b0;
    #200
    rst_n='b1;
    #100

	outfile = $fopen("D:/lesson/camera/data/post.txt","w");
end

always#10 tpclk=~tpclk;


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
.rst_n          (rst_n      )       ,
.pre_vs         (vs         )       ,
.pre_de         (de         )       ,
.pre_data       (data_in    )
);



data_joint  u_data_joint(
    .tpclk       (tpclk     )   ,
    .rst_n       (rst_n     )   ,
    .data_in     (data_in   )   ,
    .vs          (vs        )   ,
    .de          (de        )   ,
    .de_o	     (de_o	    )   ,
    .data_out    (data_out  )   ,
    .pclk_2x     (pclk_2x   )   ,
    .vs_o	     (vs_o	    )
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

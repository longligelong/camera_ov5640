`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/30 16:18:52
// Design Name: Li
// Module Name: IIC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IIC(
	output				scl					,	
	output				sda					,

	output	reg			sda_release			,

	input				clk_4x				,	/*50M*/
	input				rst					,
	input	[7:0]		dev_addr			,	/*设备地址*/
	input				exce_st				,	/*开始执行*/
	input				ctrl_w_r			,	/*读写控制  0 写   1 读  */
	input				addr_bit			,	/*数据地址位宽  0 八位    1  16位*/
	input	[2:0]		wr_model			,	/*读写模式	001 单次写	  010 当前地址读   100 随机读  */
	input				series				,		/*读写是否连续  0 单次   1  连续*/

	input	[15:0]		data_addr			,	/*数据地址*/
	input	[7:0]		data_in				,	
	output	reg	[7:0]	data_out			,	
	output	reg			bit_done			,	/*写或读完一个字节*/
	output	reg			exce_done				/*完成一次完整操作*/
	
    );




/*状态定义*/
parameter	st_idle	= 8'b0000_0001;
parameter	st_dev	= 8'b0000_0010;
parameter	st_addr8 = 8'b0000_0100;
parameter	st_addr16 = 8'b0000_1000;
parameter	st_data_w = 8'b0001_0000;
parameter	st_dev_r = 8'b0010_0000;
parameter	st_data_r = 8'b0100_0000;
parameter	st_done = 8'b1000_0000;

reg	[7:0]	state;
reg	[7:0]	state_next;	
reg			scl_o;
reg			sda_o;
reg			state_done;
//reg			sda_release;
reg	[7:0]	data_rd;
reg	[10:0]	y_cnt;

wire		sda_in;

//assign	sda = sda_release ? 1'bz : sda_o;
assign	sda = sda_o	;
assign	sda_in=1'bz	;
assign	scl = scl_o	;


/*三段式状态机*/
/*状态更新*/
always @(posedge clk_4x or negedge rst) begin
	if(!rst)
		state <= st_idle;
	else
		state <= state_next;
end

/*状态判断*/
always @(*) begin
	if(!rst)
		state_next <= st_idle;
	else begin
		case(state)
			st_idle     :begin
						if(exce_st == 1'b1)
							state_next <= st_dev;
						else 
							state_next <= st_idle;
						end
			st_dev      :begin
						if(state_done == 1) begin
							if(wr_model == 3'b010)
								state_next <= st_data_r;
							else if(addr_bit == 0)
								state_next <= st_addr8;
							else if(addr_bit <= 1)
								state_next <= st_addr16;
							end
						else
							state_next <= st_dev;
						end
			st_addr8  :begin
						if(state_done == 1) begin
							if(ctrl_w_r == 1'b0)
								state_next <= st_data_w;
							else if(ctrl_w_r == 1'b1)
								state_next <= st_dev_r;
							end
						else
							state_next <= st_addr8;
						end
			st_addr16   :begin
						if(state_done == 1) 
							state_next <= st_addr8;
						else
							state_next <= st_addr16;
						end
			st_dev_r     :begin
						if(state_done == 1)
							state_next <= st_data_r;
						else 
							state_next <=  st_dev_r;
						end
			st_data_w   :begin
						if(state_done == 1) begin
							if(series == 1)
								state_next <= st_data_w;
							else	
								state_next <= st_done;
						end
						else
							state_next <= st_data_w;
						end
			st_data_r   :begin
						if(state_done == 1) begin
							if(series == 1)
								state_next <= st_data_r;
							else	
								state_next <= st_done;
						end
						else
							state_next <= st_data_r;
						end
			st_done     :begin
						if(state_done == 1)
							state_next <= st_idle;
						else
							state_next <= st_done;
						end
			default :	state_next <= st_idle;
		endcase
	end
end

/*状态赋值*/
always @(posedge clk_4x or negedge rst) begin
	if(!rst) begin
		scl_o <= 1'b1;
		sda_o <= 1'b1;
		data_rd <= 8'd0;
		sda_release <= 1'b0;
		y_cnt <= 0;
		state_done <= 1'b0;
		bit_done <= 1'b0;
		exce_done <= 1'b0;
	end
	else begin
		state_done <= 1'b0;
		y_cnt <= y_cnt + 1;
		case(state) 
			st_idle:begin
					if(exce_st == 1'b1) begin
						scl_o <= 1'b1;
						sda_o <= 1'b0;
					end
					else begin
						scl_o <= 1'b1;
						sda_o <= 1'b1;
					end
					y_cnt <= 1;
					end
			st_dev:begin
					case(y_cnt)
						11'd1:sda_release <= 1'b0;
						11'd2:scl_o <= 1'b0;
						11'd3:sda_o <= dev_addr[7];	/*1*/
						11'd4:scl_o <= 1'b1;
						11'd6:scl_o <= 1'b0;	
						11'd7:sda_o <= dev_addr[6];	/*0*/
						11'd8:scl_o <= 1'b1;
						11'd10:scl_o <= 1'b0;
						11'd11:sda_o <= dev_addr[5];	/*1*/
						11'd12:scl_o <= 1'b1;
						11'd14:scl_o <= 1'b0;
						11'd15:sda_o <= dev_addr[4];	/*0*/
						11'd16:scl_o <= 1'b1;
						11'd18:scl_o <= 1'b0;
						11'd19:sda_o <= dev_addr[3];	/*A2*/
						11'd20:scl_o <= 1'b1;
						11'd22:scl_o <= 1'b0;
						11'd23:sda_o <= dev_addr[2];	/*A1*/
						11'd24:scl_o <= 1'b1;
						11'd26:scl_o <= 1'b0;
						11'd27:sda_o <= dev_addr[1];	/*A0*/
						11'd28:scl_o <= 1'b1;
						11'd30:scl_o <= 1'b0;
						11'd31:begin
								if(wr_model == 3'b100)	/*对随机读的写操作*/
									sda_o <= 0;	
								else
									sda_o <= ctrl_w_r;	/*读写位*/
								end
						11'd32:scl_o <= 1'b1;
						11'd34:scl_o <= 1'b0;
						11'd35:sda_release <=  1'b1;	/*释放sda 准备判断应答位*/
						11'd36:scl_o <= 1'b1;
						11'd37:begin
								//if(sda_in == 1'b0)
									state_done <= 1'b1;
							       end	
						11'd38:begin
								state_done <= 1'b0;
								scl_o <= 1'b0;
								y_cnt <= 11'd0;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end
			st_addr8:begin
					  case(y_cnt)
						11'd1:begin
								sda_release <= 1'b0;	/*收回sda*/
								sda_o <= data_addr[7];	/*ddr 8*/
							    end
						11'd2:scl_o <= 1'b1;
						11'd4:scl_o <= 1'b0;
						11'd5:sda_o <= data_addr[6];	/*ddr 7*/
						11'd6:scl_o <= 1'b1;
						11'd8:scl_o <= 1'b0;
						11'd9:sda_o <= data_addr[5];	/*ddr 6*/
						11'd10:scl_o <= 1'b1;
						11'd12:scl_o <= 1'b0;
						11'd13:sda_o <= data_addr[4];	/*ddr 5*/
						11'd14:scl_o <= 1'b1;
						11'd16:scl_o <= 1'b0;
						11'd17:sda_o <= data_addr[3];	/*ddr 4*/
						11'd18:scl_o <= 1'b1;
						11'd20:scl_o <= 1'b0;
						11'd21:sda_o <= data_addr[2];	/*ddr 3*/
						11'd22:scl_o <= 1'b1;
						11'd24:scl_o <= 1'b0;
						11'd25:sda_o <= data_addr[1];	/*ddr 2*/
						11'd26:scl_o <= 1'b1;
						11'd28:scl_o <= 1'b0;
						11'd29:sda_o <= data_addr[0];	/*ddr 1*/
						11'd30:scl_o <= 1'b1;
						11'd32:scl_o <= 1'b0;
						11'd33:sda_release <=  1'b1;	/*释放sda 准备判断应答位*/
						11'd34:scl_o <= 1'b1;
						11'd35:begin
								//if(sda_in == 1'b0)
									state_done <= 1'b1;
							       end
						11'd36:begin
								scl_o <= 1'b0;
								state_done <= 1'b0;						
								y_cnt <= 11'd1;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end								   
			st_addr16:begin
					  case(y_cnt)
						11'd1:begin
								sda_release <= 1'b0;	/*收回sda*/
								sda_o <= data_addr[15];	/*ddr 16*/
							    end
						11'd2:scl_o <= 1'b1;
						11'd4:scl_o <= 1'b0;
						11'd5:sda_o <= data_addr[14];	/*ddr 15*/
						11'd6:scl_o <= 1'b1;
						11'd8:scl_o <= 1'b0;
						11'd9:sda_o <= data_addr[13];	/*ddr 14*/
						11'd10:scl_o <= 1'b1;
						11'd12:scl_o <= 1'b0;
						11'd13:sda_o <= data_addr[12];	/*ddr 13*/
						11'd14:scl_o <= 1'b1;
						11'd16:scl_o <= 1'b0;
						11'd17:sda_o <= data_addr[11];	/*ddr 12*/
						11'd18:scl_o <= 1'b1;
						11'd20:scl_o <= 1'b0;
						11'd21:sda_o <= data_addr[10];	/*ddr 11*/
						11'd22:scl_o <= 1'b1;
						11'd24:scl_o <= 1'b0;
						11'd25:sda_o <= data_addr[9];	/*ddr 10*/
						11'd26:scl_o <= 1'b1;
						11'd28:scl_o <= 1'b0;
						11'd29:sda_o <= data_addr[8];	/*ddr 9*/
						11'd30:scl_o <= 1'b1;
						11'd32:scl_o <= 1'b0;
						11'd33:sda_release <=  1'b1;	/*释放sda 准备判断应答位*/
						11'd34:scl_o <= 1'b1;
						11'd35:begin
								//if(sda_in == 1'b0)
									state_done <= 1'b1;
							       end
						11'd36:begin
								scl_o <= 1'b0;
								state_done <= 1'b0;						
								y_cnt <= 11'd1;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end
			st_dev_r: begin
					    case(y_cnt)
						11'd1:sda_o <= 1'b0;
						11'd2:scl_o <= 1'b1;
						11'd3:sda_o <= 1'b1;
						11'd5:sda_o <= 1'b0;
						11'd7:scl_o <= 1'b0;
						11'd8:sda_o <= dev_addr[7];
						11'd9:scl_o <= 1'b1;
						11'd11:scl_o <= 1'b0;
						11'd12:sda_o <= dev_addr[6];
						11'd13:scl_o <= 1'b1;
						11'd15:scl_o <= 1'b0;
						11'd16:sda_o <= dev_addr[5];
						11'd17:scl_o <= 1'b1;
						11'd19:scl_o <= 1'b0;
						11'd20:sda_o <= dev_addr[4];						
						11'd21:scl_o <= 1'b1;
						11'd23:scl_o <= 1'b0;
						11'd24:sda_o <= dev_addr[3];								
						11'd25:scl_o <= 1'b1;
						11'd27:scl_o <= 1'b0;
						11'd28:sda_o <= dev_addr[2];								
						11'd29:scl_o <= 1'b1;
						11'd31:scl_o <= 1'b0;
						11'd32:sda_o <= dev_addr[1];		
						11'd33:scl_o <= 1'b1;
						11'd35:scl_o <= 1'b0;
						11'd36:sda_o <= dev_addr[0];		
						11'd37:scl_o <= 1'b1;
						11'd39:scl_o <= 1'b0;
						11'd40:sda_o <= 1'b1;		
						11'd41:scl_o <= 1'b1;
						11'd43:scl_o <= 1'b0;
						11'd44:sda_release <=  1'b1;	/*释放sda 准备判断应答位*/
						11'd45:scl_o <= 1'b1;
						11'd46:begin
								//if(sda_in == 1'b0)
									state_done <= 1'b1;
							       end	
						11'd47:begin
								scl_o <= 1'b0;
								state_done <= 1'b0;
								y_cnt <= 11'd1;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end
						
			st_data_w:begin
					case(y_cnt)
						11'd1:begin
								sda_release <= 1'b0;	/*收回sda*/
								sda_o <= data_in[7];	/*data 8*/
							    end
						11'd2:scl_o <= 1'b1;
						11'd4:scl_o <= 1'b0;
						11'd5:sda_o <= data_in[6];	/*data 7*/
						11'd6:scl_o <= 1'b1;
						11'd8:scl_o <= 1'b0;
						11'd9:sda_o <= data_in[5];	/*data 6*/
						11'd10:scl_o <= 1'b1;
						11'd12:scl_o <= 1'b0;
						11'd13:sda_o <= data_in[4];	/*data 5*/
						11'd14:scl_o <= 1'b1;
						11'd16:scl_o <= 1'b0;
						11'd17:sda_o <= data_in[3];	/*data 4*/
						11'd18:scl_o <= 1'b1;
						11'd20:scl_o <= 1'b0;
						11'd21:sda_o <= data_in[2];	/*data 3*/
						11'd22:scl_o <= 1'b1;
						11'd24:scl_o <= 1'b0;
						11'd25:sda_o <= data_in[1];	/*data 2*/
						11'd26:scl_o <= 1'b1;
						11'd28:scl_o <= 1'b0;
						11'd29:sda_o <= data_in[0];	/*data 1*/
						11'd30:scl_o <= 1'b1;
						11'd32:scl_o <= 1'b0;
						11'd33:sda_release <=  1'b1;	/*释放sda 准备判断应答位*/
						11'd34:scl_o <= 1'b1;
						11'd35:begin
								//if(sda_in == 1'b0) 
									begin
									state_done <= 1'b1;
									bit_done <= 1'b1;
									end
							       end
						11'd36:begin
								scl_o <= 1'b0;
								state_done <= 1'b0;						
								y_cnt <= 11'd1;
								bit_done <= 1'b0;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end	
			st_data_r:begin
					  case(y_cnt)
						11'd1:sda_release <= 1'b1;	/*释放sda*/
						11'd2:scl_o <= 1'b1;
						11'd3:data_rd <= {data_rd[6:0],sda_in};	/*接收第8位*/
						11'd4:scl_o <= 1'b0;
						11'd6:scl_o <= 1'b1;
						11'd7:data_rd <= {data_rd[6:0],sda_in};	/*接收第7位*/
						11'd8:scl_o <= 1'b0;					
						11'd10:scl_o <= 1'b1;
						11'd11:data_rd <= {data_rd[6:0],sda_in};	/*接收第6位*/						
						11'd12:scl_o <= 1'b0;
						11'd14:scl_o <= 1'b1;
						11'd15:data_rd <= {data_rd[6:0],sda_in};	/*接收第5位*/						
						11'd16:scl_o <= 1'b0;
						11'd18:scl_o <= 1'b1;
						11'd19:data_rd <= {data_rd[6:0],sda_in};	/*接收第4位*/						
						11'd20:scl_o <= 1'b0;
						11'd22:scl_o <= 1'b1;
						11'd23:data_rd <= {data_rd[6:0],sda_in};	/*接收第3位*/
						11'd24:scl_o <= 1'b0;
						11'd26:scl_o <= 1'b1;
						11'd27:data_rd <= {data_rd[6:0],sda_in};	/*接收第2位*/
						11'd28:scl_o <= 1'b0;
						11'd30:scl_o <= 1'b1;
						11'd31:data_rd <= {data_rd[6:0],sda_in};	/*接收第1位*/
						11'd32:begin
								scl_o <= 1'b0;
								data_out <= data_rd;
							        end
						11'd33:begin
								sda_release <=  1'b0;	/*收回sda 主机准备回答应答位*/
								if(series == 1)
									sda_o <= 1'b0;
								else
									sda_o <= 1'b1;
								end								
						11'd34:scl_o <= 1'b1;
						11'd35:begin
								state_done <= 1'b1;
								bit_done <= 1'b1;
							       end
						11'd36:begin
								scl_o <= 1'b0;
								state_done <= 1'b0;						
								y_cnt <= 11'd1;
								bit_done <= 1'b0;
								end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end					
			st_done:begin
					case(y_cnt)
						11'd1:begin
								sda_release <= 1'b0;	/*收回sda*/
								sda_o <= 1'b0;	/*开始结束操作*/
								//exce_done <= 1'b0;	/*回复已结束一次完整操作*/							
							    end						
						11'd2:
								scl_o <= 1'b1;
						
						11'd4:	sda_o <= 1'b1;

						11'd28:begin
								state_done <= 1'b1;
								exce_done <= 1'b1;
							     end
						11'd29:begin
								exce_done <= 1'b0;
								state_done <= 1'b0;
								y_cnt <= 11'd0;
							     end
						default:begin
								scl_o <= scl_o;
								sda_o <= sda_o;
								end
					endcase
					end	
		endcase
	end				
end

endmodule

module SCCB#()
(
	input					clk_80K		,
	input					rst_n		,

	input	[31:0]			reg_data	,	
	output	reg				scl			,
	output	reg				bit_over	,
	output	reg				sda			,
	output	reg				sda_release
);

/********************reg*******************/
reg	[5:0]	cnt			;


/********************wire*******************/


/********************exp*******************/

/********************assign*******************/


/********************process*******************/

always @(posedge clk_80K or negedge rst_n) begin
	if(!rst_n)
		cnt <= 6'b1;
	else begin
		if(cnt == 6'd41)
			cnt <= 6'd1;
		else
			cnt <= cnt + 1'b1;
	end
end

always @(posedge clk_80K or negedge rst_n) begin
	if(!rst_n) begin
		scl <= 1'b1;
		sda <= 1'b1;
		sda_release <= 1'b0;
		bit_over<='b0;
	end
	else begin
		case(cnt) 
		6'd1:sda<='b0;		/*起始标志*/
		6'd3:scl<='b0;
		6'd4:sda <= reg_data[31];
		6'd5:scl <= 'b1;
		6'd7:scl <= 'b0;
		6'd8:sda <= reg_data[30];
		6'd9:scl <= 'b1;
		6'd11:scl <= 'b0;
		6'd12:sda <= reg_data[29];
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[27]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[26]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[25]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[24]



		
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[23]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[22]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[21]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[20]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]
		6'd13:scl <= 'b1;
		6'd15:scl <= 'b0;
		6'd16:sda <= reg_data[28]





		6'd4:sda <= reg_data[30];
		6'd5:sda <= reg_data[29];
		6'd6:sda <= reg_data[28];
		6'd7:sda <= reg_data[27];
		6'd8:sda <= reg_data[26];			
		6'd9:sda <= reg_data[25];
		6'd10:sda_out <= reg_data[24];
		/*发送完器件地址地址 释放总线*/
		6'd11:sda_release <= 1'b1;
		/*收回总线 发送前八位地址*/
		6'd12:begin
				sda_out <= reg_data[23];
				sda_release <= 1'b0;
				end
		6'd13:sda_out <= reg_data[22];
		6'd14:sda_out <= reg_data[21];
		6'd15:sda_out <= reg_data[20];
		6'd16:sda_out <= reg_data[19];
		6'd17:sda_out <= reg_data[18];
		6'd18:sda_out <= reg_data[17];
		6'd19:sda_out <= reg_data[16];
		/*发送完地址前八位 释放总线*/
		6'd20:sda_release <= 1'b1;
		/*收回总线 发送后八位地址*/
		6'd21:begin
				sda_out <= reg_data[15];
				sda_release <= 1'b0;
				end
		6'd22:sda_out <= reg_data[14];
		6'd23:sda_out <= reg_data[13];
		6'd24:sda_out <= reg_data[12];
		6'd25:sda_out <= reg_data[11];
		6'd26:sda_out <= reg_data[10];
		6'd27:sda_out <= reg_data[9];
		6'd28:sda_out <= reg_data[8];
		/*发送完地址后八位 释放总线*/
		6'd29:sda_release <= 1'b1;
		/*收回总线 发送八位数据*/
		6'd30:begin
				sda_out <= reg_data[7];
				sda_release <= 1'b0;
				end	
		6'd31:sda_out <= reg_data[6];
		6'd32:sda_out <= reg_data[5];	
		6'd33:sda_out <= reg_data[4];
		6'd34:sda_out <= reg_data[3];
		6'd35:sda_out <= reg_data[2];
		6'd36:sda_out <= reg_data[1];
		6'd37:sda_out <= reg_data[0];
		/*发送完八位数据 释放总线*/
		6'd38:sda_release <= 1'b1;
		/*开始结束标志*/
		6'd39:begin
				sda_out <= 1'b0;
				sda_release <= 1'b0;
				end
		6'd40:begin
				sda_out <= 1'b1;
				bit_over <= 1'b1;
				end
		6'd41:bit_over <= 1'b0;
		default: ;
	endcase
	end
end
endmodule
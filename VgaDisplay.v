module VgaDisplay(

			//50MHz
			clk,
			
			rst,
			mode,
			hsync,
			vsync,
			r,
			g,
			b
		);
	input clk,rst,mode;
	output hsync,vsync;
	output r,g,b;

	//--------------------------------------------------
	reg r,g,b;
	reg[10:0] x_cnt; 
	reg[9:0] y_cnt;
	reg [1:0] md;
	reg [2:0] color_bar_h,color_bar_v;
	wire color_bar_cross,ncu_logo;
	always @(negedge mode)
		begin
			if(md==3)
				md<=0;
			else
				md<=md+1;
		end
	always @ (posedge clk or negedge rst)
	 if(!rst) x_cnt <= 11'd0;
	 else if(x_cnt == 11'd1039) x_cnt <= 11'd0;
	 else x_cnt <= x_cnt+1'b1;

	always @ (posedge clk or negedge rst)
	 if(!rst) y_cnt <= 10'd0;
	 else if(y_cnt == 10'd665) y_cnt <= 10'd0;
	 else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;

	//--------------------------------------------------
	wire[9:0] xpos,ypos; 
	
	assign xpos = x_cnt-11'd187;
	assign ypos = y_cnt-10'd31;

	//--------------------------------------------------
	reg hsync_r,vsync_r; 

	always @ (posedge clk or negedge rst)
	 if(!rst) hsync_r <= 1'b1;
	 else if(x_cnt == 11'd0) hsync_r <= 1'b0; 
	 else if(x_cnt == 11'd120) hsync_r <= 1'b1;
 
	always @ (posedge clk or negedge rst)
	 if(!rst) vsync_r <= 1'b1;
	 else if(y_cnt == 10'd0) vsync_r <= 1'b0; 
	 else if(y_cnt == 10'd6) vsync_r <= 1'b1;

	assign hsync = hsync_r;
	assign vsync = vsync_r;

	//--------------------------------------------------
	always @(xpos)
		if(xpos<100) begin
			color_bar_v<=3'b100;
		end
		else if(xpos<200) begin
			color_bar_v<=3'b010;
		end
		else if(xpos<300) begin
			color_bar_v<=3'b001;
		end
		else if(xpos<400) begin
			color_bar_v<=3'b100;
		end
		else if(xpos<500) begin
			color_bar_v<=3'b010;
		end
		else if(xpos<600) begin
			color_bar_v<=3'b001;
		end
		else if(xpos<700) begin
			color_bar_v<=3'b100;
		end
		else if(xpos<800) begin
			color_bar_v<=3'b010;
		end
	always @(ypos)
		if(ypos<75) begin
			color_bar_h<=3'b100;
		end
		else if(ypos<150) begin
			color_bar_h<=3'b010;
		end
		else if(ypos<225) begin
			color_bar_h<=3'b001;
		end
		else if(ypos<300) begin
			color_bar_h<=3'b100;
		end
		else if(ypos<375) begin
			color_bar_h<=3'b010;
		end
		else if(ypos<450) begin
			color_bar_h<=3'b001;
		end
		else if(ypos<525) begin
			color_bar_h<=3'b100;
		end
		else if(ypos<600) begin
			color_bar_h<=3'b010;
		end

	reg [15:0] addr;
	wire [15:0] ad=addr;
	always @ (posedge clk ) begin
	if((ypos >= 150'd0 && ypos <= 10'd300)&&(xpos >= 10'd0 && xpos <= 10'd180))
		addr<= (ypos-100)*180 + (xpos-165);
   else 
		addr<=0;
	end
	ROM rom(.address(ad),.clock(clk),.q(ncu_logo));

	assign color_bar_cross=(color_bar_v==color_bar_h)?color_bar_h:color_bar_v;
	always @(md)
	 case (md)
	 	0:{r,g,b}<=color_bar_cross;
	 	1:{r,g,b}<=color_bar_v;
	 	2:{r,g,b}<=color_bar_h;
	 	3:{r,g,b}<=ncu_logo;
	 endcase
	 // assign {r,g,b}=color_bar_h;

endmodule
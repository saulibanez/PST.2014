--Por Saul Ibañez Cerro


with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Client_Lists;
with Ada.Exceptions;
with Ada.Calendar;
with Ada.Command_Line;

package body Handlers is

	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use Client_Lists;
	Usage_Error: exception;
	use Ada.Strings.Unbounded;


	procedure Client_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		Mess : CM.Message_Type;
		Nick : ASU.Unbounded_String;
		Request : ASU.Unbounded_String;
	begin
		-- saca del Buffer P_Buffer.all un Unbounded_String
		Mess :=CM.Message_Type'Input(P_Buffer.all'Access);
		Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
		Request := ASU.Unbounded_String'Input (P_Buffer.all'Access);
		
		if Mess = CM.Server then
			Ada.Text_IO.Put_Line((">> ") & ASU.To_String(Nick) & (": ") & ASU.To_String(Request));
			LLU.Reset (P_Buffer.all);
		end if;
		
	end Client_Handler;

end Handlers;
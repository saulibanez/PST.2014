--Por Saul Ibañez Cerro

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Client_Lists;
with Ada.Calendar;

package Handlers is

	package LLU renames Lower_Layer_UDP;	
	
	procedure Client_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);

end Handlers;

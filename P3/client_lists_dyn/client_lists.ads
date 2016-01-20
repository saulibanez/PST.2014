--Por Sa�l Ib��ez Cerro

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;

package Client_Lists is
   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;


   type Client_List_Type is private;

   Client_List_Error: exception;

   procedure Add_Client (List: in out Client_List_Type;
			EP: in LLU.End_Point_Type;
			Nick: in ASU.Unbounded_String);

   procedure Delete_Client (List: in out Client_List_Type;
			Nick: in ASU.Unbounded_String);

   function Search_Client (List: in Client_List_Type;
			EP: in LLU.End_Point_Type)
                        return ASU.Unbounded_String;

   procedure Send_To_All (List: in Client_List_Type;
			P_Buffer: access LLU.Buffer_Type;
			EP_Not_Send: in LLU.End_Point_Type);

   function List_Image (List: in Client_List_Type) return String;
   
   procedure Update_Client (List: in out Client_List_Type;
			EP: in LLU.End_Point_Type);
			  
   procedure Remove_Oldest (List: in out Client_List_Type);
   
   function Count (List: in Client_List_Type) return Natural;


private
   
   type Cell;
	type Cell_A is access Cell;
	
	type Cell is record
		Client_EP : LLU.End_Point_Type;
		Nick : ASU.Unbounded_String;
		Hora_Del_Cliente: Ada.Calendar.Time;
		Next : Cell_A;
	end record;
	
	type Client_List_Type is record
		P_First: Cell_A;
		Number_Clients: Natural := 0;
	end record;
end Client_Lists;

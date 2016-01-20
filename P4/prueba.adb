with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
--with Chat_Messages;
with Ada.Calendar;
with Maps_G;
with Maps_Protector_G;
with Time_String;

procedure Prueba is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	type Seq_N_T is mod Integer'Last;
	--NOTA: Instanciación en orden de todas las variables que hay en el maps_g.ads
			--creando como Key_type un LLU.End_Point_Type, y Value_type como Ada.Calendar.Time
	package NP_Neighbors is new Maps_G (LLU.End_Point_Type, Ada.Calendar.Time, null, Ada.Calendar.Clock, 10,
				LLU."=", LLU.Image, Time_String.Image_1);
				
	--NOTA: Instanciación en orden de todas las variables que hay en el maps_g.ads
			--creando como Key_type un LLU.End_Point_Type, y Value_type como Seq_N_T
	package NP_Latest_Msgs is new Maps_G (LLU.End_Point_Type, Seq_N_T, null, 0, 50, LLU."=", LLU.Image,
				Seq_N_T'Image);

	--NOTA: Para el acceso concurrente a variables compartidas, nos lo dan en el enunciado.
	package Neighbors is new Maps_Protector_G (NP_Neighbors);
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	Lista1_N: Neighbors.Prot_Map;
	Lista2_L: Latest_Msgs.Prot_Map;
	Array1_Nk: Neighbors.Keys_Array_Type;
	Array2_NV: Neighbors.Values_Array_Type;
	
	Array1_LK: Latest_Msgs.Keys_Array_Type;
	Array2_LV: Latest_Msgs.Values_Array_Type;
	
	EP: LLU.End_Point_Type;
	Ok: Boolean;
	Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	Reloj:Ada.Calendar.Time;
	
begin
	Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name); 
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	EP := LLU.Build(ASU.To_String(Dir_IP), 4001);
	
	Neighbors.Put(Lista1_N, EP, Ada.Calendar.Clock, Ok);
	Neighbors.Print_Map(Lista1_N);
	
	Ada.Text_IO.Put_Line("----------------------------------------------------");
	
	Neighbors.Get(Lista1_N, EP, Reloj, Ok);
	Ada.Text_IO.Put(Time_String.Image_1(Reloj));
	
	Ada.Text_IO.Put_Line("----------------------------------------------------");
	
	Latest_Msgs.Put(Lista2_L, EP, 5, Ok);
	Latest_Msgs.Print_Map(Lista2_L);
	
	Ada.Text_IO.Put_Line("----------------------------------------------------");

	
	
	


end Prueba;
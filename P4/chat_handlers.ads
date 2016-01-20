--Por Saúl Ibáñez

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Calendar;
with Maps_G;
with Maps_Protector_G;
with Lower_Layer_UDP;
with Time_String;

package Chat_Handlers is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	type Seq_N_T is mod Integer'Last;


	--NOTA: Instanciación en orden de todas las variables que hay en el maps_g.ads
			--creando como Key_type un LLU.End_Point_Type, y Value_type como Ada.Calendar.Time
	package NP_Neighbors is new Maps_G (LLU.End_Point_Type, Ada.Calendar.Time, null, Ada.Calendar.Clock, 10,
				LLU."=", LLU.Image, Time_String.Image_1);		--Paquete Time_String para mirar lo de Image
				
	--NOTA: Instanciación en orden de todas las variables que hay en el maps_g.ads
			--creando como Key_type un LLU.End_Point_Type, y Value_type como Seq_N_T
	package NP_Latest_Msgs is new Maps_G (LLU.End_Point_Type, Seq_N_T, null, 0, 50, LLU."=", LLU.Image,
				Seq_N_T'Image);

	--NOTA: Para el acceso concurrente a variables compartidas, nos lo dan en el enunciado.
	package Neighbors is new Maps_Protector_G (NP_Neighbors);
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	Vecinos: Neighbors.Prot_Map;
	Mensajes: Latest_Msgs.Prot_Map;
	Seq_N: Seq_N_T := 0;		--mi secuencia que debo incrementar cada vez que mando un mensaje
	Seq_N_Sacado: Seq_N_T;
	Seq_N_Lista: Seq_N_T;
	Mi_Nick : ASU.Unbounded_String;
	Mi_EP_Handler: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	
	procedure P2P_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);


end Chat_Handlers;
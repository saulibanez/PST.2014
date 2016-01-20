--Por Saúl Ibáñez

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Calendar;
with Maps_G;
with Maps_Protector_G;
with Lower_Layer_UDP;
with Time_String;
with Herramientas;
with Debug;
with Pantalla;
with Implementacion_Ordered;
with Ordered_Maps_Protector_G;
with Ordered_Maps_G;
with Timed_Handlers;


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
	package NP_Latest_Msgs is new Maps_G (LLU.End_Point_Type, Implementacion_Ordered.Seq_N_T, null, 0, 50, LLU."=", LLU.Image,
				Implementacion_Ordered.Seq_N_T'Image);

	--NOTA: Para el acceso concurrente a variables compartidas, nos lo dan en el enunciado.
	package Neighbors is new Maps_Protector_G (NP_Neighbors);
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	--NOTA: Instanciación en orden de todas las variables que hay en el ordered_maps_g.ads
			--creando como Key_type un Mess_Id_T, y Value_type como Destinations_T
	package NP_Sender_Dests is new Ordered_Maps_G (Implementacion_Ordered.Mess_Id_T, Implementacion_Ordered.Destinations_T,
											Implementacion_Ordered.Mess_Equal, Implementacion_Ordered.Mess_Less,
											Implementacion_Ordered.Key_To_String, Implementacion_Ordered.Destinations);
											
	--NOTA: Instanciación en orden de todas las variables que hay en el ordered_maps_g.ads
			--creando como Key_type un Ada.Calendar.Time, y Value_type como Value_T
	package NP_Sender_Buffering is new Ordered_Maps_G (Ada.Calendar.Time, Implementacion_Ordered.Value_T, Ada.Calendar."=",
												Ada.Calendar."<", Implementacion_Ordered.Tiempo, Implementacion_Ordered.Value_To_String);	
												--En Implementacion_Ordered.Tiempo, puedo poner Time_String.Image_1?
	
	--NOTA: Para el acceso concurrente a variables compartidas, nos lo dan en el enunciado.
	package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests);
	package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);
	
	Vecinos: Neighbors.Prot_Map;
	Mensajes: Latest_Msgs.Prot_Map;
	Seq_N: Implementacion_Ordered.Seq_N_T := 0;		--mi secuencia que debo incrementar cada vez que mando un mensaje
	Seq_N_Sacado: Implementacion_Ordered.Seq_N_T;
	Seq_N_Lista: Implementacion_Ordered.Seq_N_T;
	Mi_Nick : ASU.Unbounded_String;
	Mi_EP_Handler: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Plazo_Retransmision: Duration;
	Plazo_Reject: Duration;
	Plazo_Logout: Duration;
	Mapa_Sender_Buffering: Sender_Buffering.Prot_Map;	--mapa de sender buffering
	Mapa_Sender_Dests: Sender_Dests.Prot_Map;			--mapa de sender dest
	Max : Float;
	Value_Destination: Implementacion_Ordered.Destinations_T;
	Enviado: Boolean;
	
	procedure P2P_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);
	procedure Retransmision (Time: in Ada.Calendar.Time);
	

end Chat_Handlers;
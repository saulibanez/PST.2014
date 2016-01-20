--Por Saúl Ibáñez Cerro
--Paquete en el que guardare todas las funciones repetidas, lo llamamos herramientas
--Me va a servier tanto para el programa chat_peer, como para el chat_handler

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Debug;
with Chat_Messages;
with Pantalla;
with Time_String;
with Implementacion_Ordered;
with Ada.Calendar;
with Timed_Handlers;
with Implementacion_Ordered;

package Herramientas is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use Lower_Layer_UDP;
	use Ada.Strings.Unbounded;
	use type Ada.Calendar.Time;
	use type Implementacion_Ordered.Seq_N_T;
	
procedure Enviar_Mensaje_Init(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							EP_Receive: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean);
procedure Enviar_Mensaje_Reject(EP_Handler_Creat: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type);
procedure Enviar_Mensaje_Confirm(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type;  
							EP_Handler_Rsnd: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean);
procedure Enviar_Mensaje_Writer(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; Text: in ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean);
procedure Enviar_Mensaje_Logout(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Confirm: in Boolean; Enviado: in out Boolean);
procedure Enviar_Mensaje_ACK(EP_Handler_ACKer: in LLU.End_Point_Type; EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; EP_Handler_Rsnd: in LLU.End_Point_Type;
							P_Buffer: in out LLU.Buffer_Type);
procedure Modo_Interactivo(Request: in ASU.Unbounded_String; Nick: ASU.Unbounded_String; Mi_EP_Handler: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type;
							Activo_Desactivo: in out Boolean);
function Obtener_IP (EP: in LLU.End_Point_Type) return String;
procedure Guardar_Sender (Enviado: in out Boolean; EP: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; P_Buffer: in out Implementacion_Ordered.Buffer_A_T);

procedure Ctrl_C_Handler;


end Herramientas;




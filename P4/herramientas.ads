--Por Saúl Ibáñez Cerro
--Paquete en el que guardare todas las funciones repetidas, lo llamamos herramientas
--Me va a servier tanto para el programa chat_peer, como para el chat_handler

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Chat_Handlers;
with Debug;
with Chat_Messages;
with Pantalla;
with Time_String;

package Herramientas is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use Lower_Layer_UDP;
	use Ada.Strings.Unbounded;

procedure Enviar_Mensaje_Init(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							EP_Receive: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type);
procedure Enviar_Mensaje_Reject(EP_Handler_Creat: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type);
procedure Enviar_Mensaje_Confirm(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type;  
							EP_Handler_Rsnd: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type);
procedure Enviar_Mensaje_Writer(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; Text: in ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type);
procedure Enviar_Mensaje_Logout(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type; Confirm: in Boolean);
procedure Modo_Interactivo(Request: in ASU.Unbounded_String; Nick: ASU.Unbounded_String; Mi_EP_Handler: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type;
							Activo_Desactivo: in out Boolean);
function Obtener_IP (EP: in LLU.End_Point_Type) return String;

end Herramientas;




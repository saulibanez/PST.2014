--Por Saúl Ibáñez Cerro
--Paquete en el que guardare todas las funciones repetidas, lo llamamos herramientas
--Me va a servier tanto para el programa chat_peer, como para el chat_handler

with Ada.Text_IO;

package body Herramientas is

	procedure Enviar_Mensaje_Init(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T;Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							EP_Receive: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type) is

		Mess : CM.Message_Type:=CM.Init;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output(P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_Creat);		--EP_H del que creo el mensaje
		Chat_Handlers.Seq_N_T'Output(P_Buffer'Access, Seq_N);				--Numero de secuencia asignado al que creo el mensaje
		LLU.End_Point_Type'Output(P_Buffer'Access, Mi_EP_Handler);		--EP_H del nodo que ha reenviado el mensaje, pongo Mi_EP porque es el que va a reenviar el mensaje
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Receive);				--EP_R del nodo que creo el mensaje
		ASU.Unbounded_String'Output(P_Buffer'Access, Nick);				--Nick del que creo el mensaje
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop		--De 1 hasta todos los vecinos que tenga
			if EP_Handler_Rsnd /= Key(k) then
				--Debug.Put_Line(LLU.Image(Key(k)), Pantalla.Rojo);
				LLU.Send(Key(k), P_Buffer'Access);							--Le mando el Key (LLU) a todos los vecinos menos a mi
			end if;
		end loop;
		
	end Enviar_Mensaje_Init;


	procedure Enviar_Mensaje_Reject(EP_Handler_Creat: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type) is
		Mess : CM.Message_Type:=CM.Reject;
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output (P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output (P_Buffer'Access, EP_Handler_Creat);
		ASU.Unbounded_String'Output (P_Buffer'Access, Nick);
		LLU.Send (EP_Receive, P_Buffer'Access);
		LLU.Reset(P_Buffer);
	end Enviar_Mensaje_Reject;
	
	
	procedure Enviar_Mensaje_Confirm(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type;
							EP_Handler_Rsnd: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type) is
		Mess : CM.Message_Type:=CM.Confirm;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output(P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_Creat);
		Chat_Handlers.Seq_N_T'Output(P_Buffer'Access, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer'Access, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer'Access, Nick);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) then
				LLU.Send(Key(k), P_Buffer'Access);
			end if;
		end loop;
		LLU.Reset(P_Buffer);
	end Enviar_Mensaje_Confirm;
	
	
	
	procedure Enviar_Mensaje_Writer(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; Text: in ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type) is
		Mess : CM.Message_Type:=CM.Writer;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output(P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_Creat);
		Chat_Handlers.Seq_N_T'Output(P_Buffer'Access, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer'Access, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer'Access, Nick);
		ASU.Unbounded_String'Output(P_Buffer'Access, Text);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) then
				LLU.Send(Key(k), P_Buffer'Access);
			end if;
		end loop;
		LLU.Reset(P_Buffer);
	end Enviar_Mensaje_Writer;
	
	procedure Enviar_Mensaje_Logout(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Chat_Handlers.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; P_Buffer: in out LLU.Buffer_Type; Confirm: in Boolean) is
		Mess : CM.Message_Type:=CM.Logout;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;					
							
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output(P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_Creat);
		Chat_Handlers.Seq_N_T'Output(P_Buffer'Access, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer'Access, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer'Access, Nick);
		Boolean'Output(P_Buffer'Access, Confirm);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		--Ada.Text_IO.Put_Line("Vecinos que tengo en el logout");
		--Chat_Handlers.Neighbors.Print_Map(Chat_Handlers.Vecinos);
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) then
				LLU.Send(Key(k), P_Buffer'Access);
			end if;
		end loop;
		LLU.Reset(P_Buffer);
	
	end Enviar_Mensaje_Logout;
	
	procedure Modo_Interactivo(Request: in ASU.Unbounded_String; Nick: ASU.Unbounded_String; Mi_EP_Handler: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type;
							Activo_Desactivo: in out Boolean) is
		Print:ASU.Unbounded_String;
	
	begin
		if ASU.To_String(Request) = ".h" or ASU.To_String(Request) = ".help" then
			Debug.Put_Line("      Commands               Effect", Pantalla.Rojo);
			Debug.Put_Line("      ===============        ======", Pantalla.Rojo);
			Debug.Put_Line("      .nb  .neighbors        Shows neighbors list", Pantalla.Rojo);
			Debug.Put_Line("      .lm  .latest_msg       Shows latest messages list", Pantalla.Rojo);
			Debug.Put_Line("      .debug                 Toggles debug info", Pantalla.Rojo);
			Debug.Put_Line("      .wai  .whoami          Show: nick | EP_H | EP_R", Pantalla.Rojo);
			Debug.Put_Line("      .prompt                Toggles showing prompt", Pantalla.Rojo);
			Debug.Put_Line("      .h  .help              Shows this help info", Pantalla.Rojo);
			Debug.Put_Line("      .quit                  Quits program", Pantalla.Rojo);
		elsif ASU.To_String(Request) = ".nb" or ASU.To_String(Request) = ".neighbors" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("      Neighbors");
			Ada.Text_IO.Put_Line("      --------------------");
			Ada.Text_IO.Put("     ");
			Chat_Handlers.Neighbors.Print_Map(Chat_Handlers.Vecinos);
			--me imprime todos los vecinos, eso bien, tengo que usar el Obtener para que este perfecto, y tambien usar el paquete 
			--Time string, para que me diga la hora, dia y año
			--Nota: Lo tengo que poner asi:			 [ (127.0.1.1:2222), Sat Dec 13 10:27:31 2014 ]
			--IP vecino, con su puerto, y la fecha de cuando he marcado el .nb
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".lm" or ASU.To_String(Request) = ".latest_msg" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("      Latest_Msgs");
			Ada.Text_IO.Put_Line("      --------------------");
			--Debug.Put_Line(Obtener_IP(Mi_EP_Handler));
			Chat_Handlers.Latest_Msgs.Print_Map(Chat_Handlers.Mensajes);
			--Nota: lo tengo que poner asi  		[ (127.0.1.1:2222),  2 ]
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".debug" then 
			if Debug.Get_Status = True then
				Debug.Put_Line("Debug info deactivated",Pantalla.Rojo);
				Debug.Set_Status(False); 
			else
				Debug.Set_Status(True);
				Debug.Put_Line("Debug info activated",Pantalla.Rojo);
			end if;
		elsif ASU.To_String(Request) = ".wai" or ASU.To_String(Request) = ".whoami" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("Nick: "& ASU.To_String(Nick) & " |   | EP_H: " & Obtener_IP(Mi_EP_Handler) & " |   | EP_R: " & Obtener_IP(EP_Receive) & " |");
			Pantalla.Poner_Color(Pantalla.Cierra);
			--Nick: Saul | EP_H: 127.0.1.1:9001 | EP_R: 127.0.1.1:41135
		elsif ASU.To_String(Request) = ".prompt" then
			if Activo_Desactivo = True then
				Debug.Put_Line("Prompt activated",Pantalla.Rojo);
				Activo_Desactivo := False;
			else
				Activo_Desactivo := True;
				Debug.Put_Line("Prompt deactivated",Pantalla.Rojo);
			end if;
		end if;
		
	end Modo_Interactivo;
	
	
	function Obtener_IP (EP: in LLU.End_Point_Type) return String is
		Texto:ASU.Unbounded_String;
		N : Natural:=0;
		R:ASU.Unbounded_String;
		P:Natural:=0;
		Q:ASU.Unbounded_String;
		T:ASU.Unbounded_String;
		Otra:Natural:=0;
	begin
		Texto:=ASU.To_Unbounded_String(LLU.Image(EP));		--LLU_image lo convierto a unbounded_string
		--Ada.Text_IO.Put_Line(ASU.To_String(Texto));		--Cojo todo el LLU
		N:= ASU.Index (Texto,":");					
		R:=ASU.Tail(Texto,ASU.Length(Texto)-N-1);		--En R queda guardado: 127.0.1.1, Port: 50123  	*Nota: La IP y puerto son un ejemplo
		P:=Index(R,",");
		T:=ASU.Head(R,P-1);						--En T queda guardado: 127.0.1.1
		Otra:=Index(R,":");
		Q:=ASU.Tail(R,ASU.Length(R)-Otra-1);			--En Q queda guardado 50123
		Texto:=ASU.To_Unbounded_String(ASU.To_String(T) & ":" &  ASU.To_String(Q));
		
		--Ada.Text_IO.Put_Line(ASU.To_String(T)&":"& ASU.To_String(Q)& (" "));
		
		return ASU.To_String(Texto);
		
	end Obtener_IP;
	
	

end Herramientas;
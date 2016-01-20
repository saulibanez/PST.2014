--Por Sa�l Ib��ez Cerro
--Paquete en el que guardare todas las funciones repetidas, lo llamamos herramientas
--Me va a servier tanto para el programa chat_peer, como para el chat_handler

with Ada.Text_IO;
with Chat_Handlers;

package body Herramientas is

	procedure Enviar_Mensaje_Init(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T;Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							EP_Receive: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean) is

		Mess : CM.Message_Type:=CM.Init;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_Handler_Creat);		--EP_H del que creo el mensaje
		Implementacion_Ordered.Seq_N_T'Output(P_Buffer, Seq_N);				--Numero de secuencia asignado al que creo el mensaje
		LLU.End_Point_Type'Output(P_Buffer, Mi_EP_Handler);		--EP_H del nodo que ha reenviado el mensaje, pongo Mi_EP porque es el que va a reenviar el mensaje
		LLU.End_Point_Type'Output(P_Buffer, EP_Receive);				--EP_R del nodo que creo el mensaje
		ASU.Unbounded_String'Output(P_Buffer, Nick);				--Nick del que creo el mensaje
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop		--De 1 hasta todos los vecinos que tenga
			if EP_Handler_Rsnd /= Key(k) and Key(k) /= null then
				--Debug.Put_Line(LLU.Image(Key(k)), Pantalla.Rojo);
				LLU.Send(Key(k), P_Buffer);							--Le mando el Key (LLU) a todos los vecinos menos a mi
				Enviado := True;
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
	
	
	procedure Enviar_Mensaje_Confirm(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type;
							EP_Handler_Rsnd: in LLU.End_Point_Type; Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean) is
		Mess : CM.Message_Type:=CM.Confirm;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
	
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_Handler_Creat);
		Implementacion_Ordered.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) and Key(k) /= null then
				LLU.Send(Key(k), P_Buffer);
				Enviado:= True;
			end if;
		end loop;
	
	end Enviar_Mensaje_Confirm;
	
	
	
	procedure Enviar_Mensaje_Writer(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; Text: in ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Enviado: in out Boolean) is
		Mess : CM.Message_Type:=CM.Writer;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;
	begin
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_Handler_Creat);
		Implementacion_Ordered.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
		ASU.Unbounded_String'Output(P_Buffer, Text);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) and Key(k) /= null then
				LLU.Send(Key(k), P_Buffer);
				Debug.Put_Line("enviado a: " & Obtener_IP(Key(k)));
				Enviado:= True;
			end if;
		end loop;

	end Enviar_Mensaje_Writer;
	
	procedure Enviar_Mensaje_Logout(EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; Mi_EP_Handler: in LLU.End_Point_Type; EP_Handler_Rsnd: in LLU.End_Point_Type; 
							Nick: ASU.Unbounded_String; P_Buffer: in out Implementacion_Ordered.Buffer_A_T; Confirm: in Boolean; Enviado: in out Boolean) is
		Mess : CM.Message_Type:=CM.Logout;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;					
							
	begin
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_Handler_Creat);
		Implementacion_Ordered.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, Mi_EP_Handler);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
		Boolean'Output(P_Buffer, Confirm);
		
		Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
		--Ada.Text_IO.Put_Line("Vecinos que tengo en el logout");
		--Chat_Handlers.Neighbors.Print_Map(Chat_Handlers.Vecinos);
		for K in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
			if EP_Handler_Rsnd /= Key(k) and Key(k) /= null then
				LLU.Send(Key(k), P_Buffer);
				Enviado:= True;
			end if;
		end loop;

	end Enviar_Mensaje_Logout;
	
	
	procedure Enviar_Mensaje_ACK(EP_Handler_ACKer: in LLU.End_Point_Type; EP_Handler_Creat: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; EP_Handler_Rsnd: in LLU.End_Point_Type;
								P_Buffer: in out LLU.Buffer_Type) is
		Mess : CM.Message_Type:=CM.Ack;
	begin
		LLU.Reset(P_Buffer);
		CM.Message_Type'Output(P_Buffer'Access, Mess);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_ACKer);
		LLU.End_Point_Type'Output(P_Buffer'Access, EP_Handler_Creat);
		Implementacion_Ordered.Seq_N_T'Output(P_Buffer'Access, Seq_N);
		LLU.Send(EP_Handler_Rsnd, P_Buffer'Access);
		Debug.Put_Line("Send ACK: " & Herramientas.Obtener_IP(EP_Handler_ACKer)&" ,Seq: "& Implementacion_Ordered.Seq_N_T'Image(Seq_N) & ", " & Herramientas.Obtener_IP(EP_Handler_Rsnd), Pantalla.Azul);
	end Enviar_Mensaje_ACK;
	
	
	
	
	procedure Modo_Interactivo(Request: in ASU.Unbounded_String; Nick: ASU.Unbounded_String; Mi_EP_Handler: in LLU.End_Point_Type; EP_Receive: in LLU.End_Point_Type;
							Activo_Desactivo: in out Boolean) is
		Print:ASU.Unbounded_String;
	
	begin
		if ASU.To_String(Request) = ".h" or ASU.To_String(Request) = ".help" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("      Commands               Effect");
			Ada.Text_IO.Put_Line("      ===============        ======");
			Ada.Text_IO.Put_Line("      .nb  .neighbors        Shows neighbors list");
			Ada.Text_IO.Put_Line("      .lm  .latest_msg       Shows latest messages list");
			Ada.Text_IO.Put_Line("      .debug                 Toggles debug info");
			Ada.Text_IO.Put_Line("      .wai  .whoami          Show: nick | EP_H | EP_R");
			Ada.Text_IO.Put_Line("      .prompt                Toggles showing prompt");
			Ada.Text_IO.Put_Line("      .sb                    Shows Sender_Buffering");
			Ada.Text_IO.Put_Line("      .sd                    Shows Sender_Dests");
			Ada.Text_IO.Put_Line("      .h  .help              Shows this help info");
			Ada.Text_IO.Put_Line("      .quit                  Quits program");
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".nb" or ASU.To_String(Request) = ".neighbors" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("      Neighbors");
			Ada.Text_IO.Put_Line("      --------------------");
			Ada.Text_IO.Put("     ");
			Chat_Handlers.Neighbors.Print_Map(Chat_Handlers.Vecinos);
			--me imprime todos los vecinos, eso bien, tengo que usar el Obtener para que este perfecto, y tambien usar el paquete 
			--Time string, para que me diga la hora, dia y a�o
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
			Pantalla.Poner_Color(Pantalla.Rojo);
			if Debug.Get_Status = True then
				Ada.Text_IO.Put_Line("Debug info deactivated");
				Debug.Set_Status(False); 
				Activo_Desactivo := False;
			else
				Debug.Set_Status(True);
				Ada.Text_IO.Put_Line("Debug info activated");
				Activo_Desactivo := True;
			end if;
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".wai" or ASU.To_String(Request) = ".whoami" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put_Line("Nick: "& ASU.To_String(Nick) & " |   | EP_H: " & Obtener_IP(Mi_EP_Handler) & " |   | EP_R: " & Obtener_IP(EP_Receive) & " |");
			Pantalla.Poner_Color(Pantalla.Cierra);
			--Nick: Saul | EP_H: 127.0.1.1:9001 | EP_R: 127.0.1.1:41135
		elsif ASU.To_String(Request) = ".prompt" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			if Activo_Desactivo = True then
				Ada.Text_IO.Put_Line("Prompt activated");
				Activo_Desactivo := False;
			else
				Activo_Desactivo := True;
				Ada.Text_IO.Put_Line("Prompt deactivated");
			end if;
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".sb" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put("Sender Buffering: ");
			Chat_Handlers.Sender_Buffering.Print_Map(Chat_Handlers.Mapa_Sender_Buffering);
			Pantalla.Poner_Color(Pantalla.Cierra);
		elsif ASU.To_String(Request) = ".sd" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Ada.Text_IO.Put("Sender Dests: ");
			Chat_Handlers.Sender_Dests.Print_Map(Chat_Handlers.Mapa_Sender_Dests);
			Pantalla.Poner_Color(Pantalla.Cierra);
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
	
	procedure Guardar_Sender (Enviado: in out Boolean; EP: in LLU.End_Point_Type; Seq_N: in Implementacion_Ordered.Seq_N_T; P_Buffer: in out Implementacion_Ordered.Buffer_A_T) is 
		Time: Ada.Calendar.Time;
		Rellenar_Value_T: Implementacion_Ordered.Value_T;
		Pasar_Elemento_Mess_Id_T: Implementacion_Ordered.Mess_Id_T;
		Key: Chat_Handlers.Neighbors.Keys_Array_Type;	
		Envio: Boolean:=False;
		
	begin

			if Enviado = True then
--Debug.Put_Line(" entro en guardar sender", Pantalla.Amarillo);
		--Este paquete lo voy a usar para programar lo que voy a reenviar, es decir, guardar en los senders.
		--En buffering se guarda el mensaje y en dest a quien env�o

				Key := Chat_Handlers.Neighbors.Get_Keys(Chat_Handlers.Vecinos);
				Time:= Ada.Calendar.Clock + Chat_Handlers.Plazo_Retransmision;
				Rellenar_Value_T.EP_H_Creat:= EP;
				Rellenar_Value_T.Seq_N:= Seq_N;
				Rellenar_Value_T.P_Buffer:= P_Buffer;
				--aqui a�ado el mapa de sender_Buffering, el tiempo (time) y lo que voy a a�adir
				Chat_Handlers.Sender_Buffering.Put(Chat_Handlers.Mapa_Sender_Buffering, Time, Rellenar_Value_T);
				Pasar_Elemento_Mess_Id_T.EP:= EP;
				Pasar_Elemento_Mess_Id_T.Seq:= Seq_N; 
				for k in 1..Chat_Handlers.Neighbors.Map_Length(Chat_Handlers.Vecinos) loop
					if EP /= Key(k) and Key(k) /= null then
						Chat_Handlers.Value_Destination(k).EP := Key(k);
						Chat_Handlers.Value_Destination(k).Retries := 0;
					end if;
				end loop;
				Chat_Handlers.Sender_Dests.Put(Chat_Handlers.Mapa_Sender_Dests, Pasar_Elemento_Mess_Id_T, Chat_Handlers.Value_Destination);
				Timed_Handlers.Set_Timed_Handler(Time, Chat_Handlers.Retransmision'Access);
--Debug.Put_Line("programada la retransmision", Pantalla.Amarillo);
			end if;
	end Guardar_Sender;
	
	procedure Ctrl_C_Handler is
		Agregar: Boolean;
		Confirm: Boolean;
		Enviado: Boolean:= False;
	begin
		Pantalla.Poner_Color(Pantalla.Rojo);
		Ada.Text_IO.Put_Line ("Han pulsado CTRL-C... terminamos");
		Pantalla.Poner_Color(Pantalla.Cierra);
		
		Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
		Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
		Confirm:=True;
		CM.P_Buffer_Main := new LLU.Buffer_type(1024);
		Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
										Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
		Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);

		delay Chat_Handlers.Plazo_Logout;
		
		LLU.Finalize;
		Timed_Handlers.Finalize;
		raise Program_Error;
	end Ctrl_C_Handler;


end Herramientas;

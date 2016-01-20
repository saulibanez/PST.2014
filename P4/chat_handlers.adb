with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Calendar;
with Maps_G;
with Maps_Protector_G;
with Lower_Layer_UDP;
with Herramientas;
with Debug;
with Pantalla;

package body Chat_Handlers is

	package CM renames Chat_Messages;
	use Ada.Strings.Unbounded;
	use type CM.Message_Type;
	use Lower_Layer_UDP;

	procedure P2P_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		Mess : CM.Message_Type;
		Nick : ASU.Unbounded_String;
		EP_Handler_Creat: LLU.End_Point_Type;
		EP_Handler_Reenvio: LLU.End_Point_Type;
		EP_Receive: LLU.End_Point_Type;
		Request : ASU.Unbounded_String;
		Success: Boolean := False;
		Confirm: Boolean;
		Agregar: Boolean;
		Hora:Ada.Calendar.Time;
		
	begin
		Mess :=CM.Message_Type'Input(P_Buffer.all'Access);
		
		if Mess = CM.Init then
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("RCV Init ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			--sacar el EP_H del que creo el mensaje
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el Numero de secuencia asignado al que creo el mensaje
			Seq_N_Sacado:= Seq_N_T'Input(P_Buffer.all'Access);
			--sacar el EP_H del nodo que ha reenviado el mensaje
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el EP_R del nodo que creo el mensaje
			EP_Receive := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			
			-- compruebo si el mensaje está en mi lista de mensajes
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			if Success = False then
				--compruebo el nick
				if Mi_Nick /= Nick then
					Hora := Ada.Calendar.Clock;
					--como es un init, nunca he recibido mensaje de el antes, y lo añado a mi lista de vecinos
					if EP_Handler_Creat = EP_Handler_Reenvio then
						Neighbors.Put(Vecinos, EP_Handler_Creat, Hora, Success);
					end if;
					--sea vecino o no, voy a añadirlo siempre a mi lista de mensajes
					Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado,Agregar);
					
					Herramientas.Enviar_Mensaje_Init(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, EP_Receive, Nick, Buffer);
					
					Pantalla.Poner_Color(Pantalla.Verde);
					Ada.Text_IO.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) &" ... " & ASU.To_String(Nick));
					Ada.Text_IO.Put_Line("     Adding to neighbors " &  Herramientas.Obtener_IP(EP_Handler_Creat));
					Ada.Text_IO.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado));
					Pantalla.Poner_Color(Pantalla.Cierra);
					Pantalla.Poner_Color(Pantalla.Amarillo);
					Ada.Text_IO.Put("     FLOOD Init ");
					Pantalla.Poner_Color(Pantalla.Cierra);
					Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " ... " & ASU.To_String(Nick), Pantalla.Verde);
			
				else
					--Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado,Agregar);
					Herramientas.Enviar_Mensaje_Reject(Mi_EP_Handler, EP_Receive, Mi_Nick, Buffer);
				end if;
			end if;
			
		elsif Mess = CM.Confirm then
			Ada.Text_IO.New_Line;
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("RCV Confirm ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el Numero de secuencia asignado al que creo el mensaje
			Seq_N_Sacado:= Seq_N_T'Input(P_Buffer.all'Access);
			--sacar el EP_H del nodo que ha reenviado el mensaje
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) &" ... " & ASU.To_String(Nick), Pantalla.Verde);
			
			
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			
			if Seq_N_Sacado > Seq_N_Lista then
			--si la secuencia que he sacado es mayor que la de mi lista, lo envio, si no, lo ignoro
				Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Agregar);
				Herramientas.Enviar_Mensaje_Confirm(EP_Handler_Creat, Seq_N, Mi_EP_Handler, EP_Handler_Reenvio, Nick, Buffer);
				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " joins the chat");
				Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
				Pantalla.Poner_Color(Pantalla.Amarillo);
				Ada.Text_IO.Put("     FLOOD Confirm ");
				Pantalla.Poner_Color(Pantalla.Cierra);
				Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " & ASU.To_String(Nick), Pantalla.Verde);
			end if;
			
		elsif Mess = CM.Writer then
			Ada.Text_IO.New_Line;
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("RCV Writer ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Seq_N_Sacado:= Seq_N_T'Input(P_Buffer.all'Access);
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			Request := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) &" " & ASU.To_String(Nick) &" " & ASU.To_String(Request), Pantalla.Verde);
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			--Ada.Text_IO.Put_Line(Seq_N_T'Image(Seq_N_Sacado) & Seq_N_T'Image(Seq_N_Lista));

			if Success = True then
				if Seq_N_Sacado > Seq_N_Lista then		--si la secuencia que he sacado es mayor que la de mi lista, lo envio, si no, lo ignoro
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (": ")& ASU.To_String(Request));
					Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Agregar);
					Herramientas.Enviar_Mensaje_Writer(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, Request, Buffer);						
				end if;
			elsif Success = False then
				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (": ")& ASU.To_String(Request));
				Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Agregar);
				Herramientas.Enviar_Mensaje_Writer(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, Request, Buffer);						

			end if;
			Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("     FLOOD Writer ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " 
						& ASU.To_String(Nick)& " " & ASU.To_String(Request), Pantalla.Verde);
			
		elsif Mess = CM.Logout then
			Ada.Text_IO.New_Line;
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("RCV Logout ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Seq_N_Sacado:= Seq_N_T'Input(P_Buffer.all'Access);
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			Confirm := Boolean'Input(P_Buffer.all'Access);
			--Neighbors.Print_Map(Vecinos);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) &" " & ASU.To_String(Nick) & " " & Boolean'Image(Confirm), Pantalla.Verde);
			
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			if Success = True then
			
				if Seq_N_Sacado > Seq_N_Lista then
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (" joins the chat"));
					if EP_Handler_Creat = EP_Handler_Reenvio then
						Debug.Put_Line("     Deleting from neighbors: " & Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Verde);
						Neighbors.Delete(Vecinos,EP_Handler_Creat, Confirm);
					end if;
					
					Debug.Put_Line("     Deleting from latest_msgs: " & Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Verde);
					Latest_Msgs.Delete(Mensajes, EP_Handler_Creat, Success);
					Herramientas.Enviar_Mensaje_Logout(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, Buffer, Confirm);
					
				end if;

			end if;
			
			Pantalla.Poner_Color(Pantalla.Amarillo);
			Ada.Text_IO.Put("     FLOOD Logout ");
			Pantalla.Poner_Color(Pantalla.Cierra);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " & 
						ASU.To_String(Nick) & " TRUE", Pantalla.Verde);
			LLU.Reset(Buffer);
			
		end if;

	end P2P_Handler;
	
end Chat_Handlers;
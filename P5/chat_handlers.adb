--Por Saul Ib��ez

package body Chat_Handlers is

	package CM renames Chat_Messages;
	use Ada.Strings.Unbounded;
	use type CM.Message_Type;
	use Lower_Layer_UDP;
	use Implementacion_Ordered;
	use type Ada.Calendar.Time;
	
	procedure P2P_Handler (From : in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		Mess : CM.Message_Type;
		Nick : ASU.Unbounded_String;
		EP_Handler_Creat: LLU.End_Point_Type;
		EP_Handler_Reenvio: LLU.End_Point_Type;
		EP_Receive: LLU.End_Point_Type;
		Request : ASU.Unbounded_String;
		Success: Boolean := False;
		Confirm: Boolean;
		--Agregar: Boolean;
		Hora:Ada.Calendar.Time;
		EP_Handler_ACKer: LLU.End_Point_Type;
		Key: Implementacion_Ordered.Mess_Id_T;
		Value: Implementacion_Ordered.Destinations_T;
		Mandadas_Todas_Retransmisiones: Boolean:=True;
		Array_Msgs:Latest_Msgs.Keys_Array_Type;
		
	begin
		Mess :=CM.Message_Type'Input(P_Buffer.all'Access);
		
		if Mess = CM.Init then
			Debug.Put("RCV Init ", Pantalla.Amarillo);
			--sacar el EP_H del que creo el mensaje
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el Numero de secuencia asignado al que creo el mensaje
			Seq_N_Sacado:= Implementacion_Ordered.Seq_N_T'Input(P_Buffer.all'Access);
			--sacar el EP_H del nodo que ha reenviado el mensaje
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el EP_R del nodo que creo el mensaje
			EP_Receive := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			
			-- compruebo si el mensaje est� en mi lista de mensajes
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			if Success = False then
				if (Success = False and ((Seq_N_Sacado - Seq_N_Lista) = 1)) or (Success = False and Mess /= CM.Logout) then
					Debug.Put_Line(" Send ACK Init", Pantalla.Azul);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
					--compruebo el nick
					if Mi_Nick /= Nick then
						Hora := Ada.Calendar.Clock;
						--como es un init, nunca he recibido mensaje de el antes, y lo a�ado a mi lista de vecinos
						if EP_Handler_Creat = EP_Handler_Reenvio then
							Debug.Put_Line("     Adding to neighbors " &  Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Verde);
							Neighbors.Put(Vecinos, EP_Handler_Creat, Hora, Success);
						end if;
							
							--sea vecino o no, voy a a�adirlo siempre a mi lista de mensajes
							Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
							Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado,Success);
							CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
							Herramientas.Enviar_Mensaje_Init(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, EP_Receive, Nick, CM.P_Buffer_Handler, Enviado);
							Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
							
							Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) &" ... " & ASU.To_String(Nick), Pantalla.Verde);

							Debug.Put("     FLOOD Init ", Pantalla.Amarillo);
							Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " ... " & ASU.To_String(Nick), Pantalla.Verde);
					else
						Herramientas.Enviar_Mensaje_Reject(Mi_EP_Handler, EP_Receive, Mi_Nick, Buffer);
					end if;
					
				elsif Seq_N_Sacado > (Seq_N_Lista +1) then
					Debug.Put_Line("Mensaje Futuro, no hacemos nada",Pantalla.Blanco);
				else
					Debug.Put_Line("Mensaje Pasado, volvemos a enviar Ack Init",Pantalla.Blanco);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				end if;
			elsif Success = True then
				Debug.Put_Line(" Send ACK Init, El mensaje sigue sin estar en la lista", Pantalla.Azul);
				Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
			end if;
		
		elsif Mess = CM.Ack then
			EP_Handler_ACKer := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Seq_N_Sacado:= Implementacion_Ordered.Seq_N_T'Input(P_Buffer.all'Access);

			Key.EP:=EP_Handler_Creat;
			Key.Seq:=Seq_N_Sacado;
			Debug.Put_Line("Recive ACK de: " & Herramientas.Obtener_IP(EP_Handler_ACKer)&" ,Seq: "& Implementacion_Ordered.Seq_N_T'Image(Key.Seq)
							& " Para: " & Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Magenta);

			Sender_Dests.Get(Mapa_Sender_Dests, Key, Value, Success);
			
			if Success = True then
				for k in 1..10 loop
					if EP_Handler_ACKer= Value(k).Ep then
						Value(k).Ep :=null;
					end if;
					if Value(k).EP /= null and Value(k).Retries < Integer(Max) then
						Mandadas_Todas_Retransmisiones:=False;
					end if;
				end loop;
				--si aun tenemos valores nulos, actualizamos sender dest
				if Mandadas_Todas_Retransmisiones = False then
					--en sender dest vamos marcando que vecinos van asintiendo el mensaje
					Sender_Dests.Put(Mapa_Sender_Dests, Key, Value);
				else
					
					Sender_Dests.Delete(Mapa_Sender_Dests, Key, Success);
						if Success then
							Debug.Put_Line("Borrando Sender_Dests", Pantalla.Gris_Oscuro);
						end if;
				end if;
			end if;


		elsif Mess = CM.Confirm then
			Ada.Text_IO.New_Line;
			Debug.Put("RCV Confirm ", Pantalla.Amarillo);
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			--sacar el Numero de secuencia asignado al que creo el mensaje
			Seq_N_Sacado:= Implementacion_Ordered.Seq_N_T'Input(P_Buffer.all'Access);
			--sacar el EP_H del nodo que ha reenviado el mensaje
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) &" ... " & ASU.To_String(Nick), Pantalla.Verde);
			
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			
			if Success = True then
				if (Success = True and ((Seq_N_Sacado - Seq_N_Lista) = 1)) then
				--si es un mensaje del futuro no entra, entrara cuando sea del pasado o justo el siguiente, si entro mando ack y luego miro el siguiente
				--if (Seq_N_Sacado - Seq_N_Lista) < 2 then
					Debug.Put_Line(" Send ACK Confirm", Pantalla.Azul);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);

					--if Seq_N_Sacado > Seq_N_Lista then
					--si la secuencia que he sacado es mayor que la de mi lista, lo envio, si no, lo ignoro
						Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Success);
						CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
						Herramientas.Enviar_Mensaje_Confirm(EP_Handler_Creat, Seq_N, Mi_EP_Handler, EP_Handler_Reenvio, Nick, CM.P_Buffer_Handler, Enviado);
						Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
						Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " joins the chat");
						Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
						Debug.Put("     FLOOD Confirm ", Pantalla.Amarillo);
						Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " & ASU.To_String(Nick), Pantalla.Verde);
					--end if;
				elsif Seq_N_Sacado > (Seq_N_Lista +1) then
					Debug.Put_Line("Mensaje Futuro, no hacemos nada",Pantalla.Blanco);
				else
					Debug.Put_Line("Mensaje Pasado, volvemos a enviar Ack Confirm",Pantalla.Blanco);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				end if;
				
			elsif Success = False then
				Debug.Put_Line(" Send ACK Confirm, El mensaje sigue sin estar asentido", Pantalla.Azul);
				--he recibido el mensaje, y voy a mandar el ack
				Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				--actualizo la lista de latest_msgs
				Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Success);
				CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
				Herramientas.Enviar_Mensaje_Confirm(EP_Handler_Creat, Seq_N, Mi_EP_Handler, EP_Handler_Reenvio, Nick, CM.P_Buffer_Handler, Enviado);
				Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
			end if;
			
			
			
		elsif Mess = CM.Writer then
			Ada.Text_IO.New_Line;
			Debug.Put("RCV Writer ", Pantalla.Amarillo);
			
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Seq_N_Sacado:= Implementacion_Ordered.Seq_N_T'Input(P_Buffer.all'Access);
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			Request := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			LLU.Reset(Buffer);
			
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) &" " & ASU.To_String(Nick) &" " & ASU.To_String(Request), Pantalla.Verde);
			
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			--Ada.Text_IO.Put_Line(Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Lista));
			--Debug.Put_Line("Seq_N_Sacado: " &Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) &", Seq_N_Lista: " & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Lista));
			
			if Success = True then
				if (Seq_N_Sacado - Seq_N_Lista) = 1 then
				--if (Seq_N - Seq_N_Sacado) < 2 then
				Debug.Put_Line(" Send ACK Writer", Pantalla.Azul);
				Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);

				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (": ")& ASU.To_String(Request));
				Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Success);
				CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
				Herramientas.Enviar_Mensaje_Writer(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, Request, CM.P_Buffer_Handler, Enviado);
				Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
				Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
				Debug.Put("     FLOOD Writer ", Pantalla.Amarillo);
				Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " 
						& ASU.To_String(Nick)& " " & ASU.To_String(Request), Pantalla.Verde);
				
				elsif Seq_N_Sacado > (Seq_N_Lista +1) then
					Debug.Put_Line("Mensaje Futuro, no hacemos nada",Pantalla.Blanco);
				else 
					Debug.Put_Line("Mensaje Pasado, volvemos a enviar Ack Writer",Pantalla.Blanco);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				end if;

			--no lo tengo en la lista
			else

				Debug.Put_Line(" Send ACK Writer, El mensaje sigue sin estar asentido", Pantalla.Azul);
				Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (": ")& ASU.To_String(Request));
				Latest_Msgs.Put(Mensajes, EP_Handler_Creat,Seq_N_Sacado, Success);
				CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
				Herramientas.Enviar_Mensaje_Writer(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, Request, CM.P_Buffer_Handler, Enviado);
				Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
				Debug.Put_Line("     Adding to latest_messages " &  Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado), Pantalla.Verde);
				Debug.Put("     FLOOD Writer ", Pantalla.Amarillo);
				Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " 
						& ASU.To_String(Nick)& " " & ASU.To_String(Request), Pantalla.Verde);
			end if;
		
			
			
		elsif Mess = CM.Logout then
			Ada.Text_IO.New_Line;
			Debug.Put("RCV Logout ", Pantalla.Amarillo);
			
			EP_Handler_Creat := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Seq_N_Sacado:= Implementacion_Ordered.Seq_N_T'Input(P_Buffer.all'Access);
			EP_Handler_Reenvio := LLU.End_Point_Type'Input(P_Buffer.all'Access);
			Nick := ASU.Unbounded_String'Input (P_Buffer.all'Access);
			Confirm := Boolean'Input(P_Buffer.all'Access);
			--Neighbors.Print_Map(Vecinos);
			Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) &" " & ASU.To_String(Nick) & " " & Boolean'Image(Confirm), Pantalla.Verde);
			
			Latest_Msgs.Get(Mensajes, EP_Handler_Creat, Seq_N_Lista, Success);
			if Success = True then
				if Seq_N_Sacado = (1 + Seq_N_Lista) then
					Debug.Put_Line(" Send ACK Logout", Pantalla.Azul);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);

					if EP_Handler_Creat = EP_Handler_Reenvio then
						Debug.Put_Line("     Deleting from neighbors: " & Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Verde);
						Neighbors.Delete(Vecinos,EP_Handler_Creat, Confirm);
					end if;
					
					Debug.Put_Line("     Deleting from latest_msgs: " & Herramientas.Obtener_IP(EP_Handler_Creat), Pantalla.Verde);
					Latest_Msgs.Delete(Mensajes, EP_Handler_Creat, Success);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & (" ha abandonado el chat"));
					
					
					CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
					Herramientas.Enviar_Mensaje_Logout(EP_Handler_Creat, Seq_N_Sacado,Mi_EP_Handler, EP_Handler_Reenvio, Nick, CM.P_Buffer_Handler, Confirm, Enviado);
					Herramientas.Guardar_Sender(Enviado, EP_Handler_Creat, Seq_N_Sacado,CM.P_Buffer_Handler);
					
					Debug.Put("     FLOOD Logout ", Pantalla.Amarillo);
					Debug.Put_Line(Herramientas.Obtener_IP(EP_Handler_Creat) & Implementacion_Ordered.Seq_N_T'Image(Seq_N_Sacado) & " " & Herramientas.Obtener_IP(Mi_EP_Handler) & " " & 
					ASU.To_String(Nick) & Boolean'Image(Confirm), Pantalla.Verde);

				elsif Seq_N_Sacado > (Seq_N_Lista +1) then
					Debug.Put_Line("Mensaje Futuro, no hacemos nada",Pantalla.Blanco);
				else
					Debug.Put_Line("Mensaje Pasado, volvemos a enviar Ack Logout",Pantalla.Blanco);
					Herramientas.Enviar_Mensaje_ACK(Mi_EP_Handler, EP_Handler_Creat, Seq_N_Sacado, EP_Handler_Reenvio, Buffer);
				end if;
				
			--no lo tengo en la lista
			elsif Success = False then
				Debug.Put_Line(" No lo tengo en la lista, asique lo ignoro", Pantalla.Rojo);
			end if;

		end if;
		
		--LLU.Reset(P_Buffer.all);
		
	end P2P_Handler;
	
	
	procedure Retransmision (Time: in Ada.Calendar.Time) is
		Rellenar_Value_T: Implementacion_Ordered.Value_T;
		Success: Boolean;
		Success_Dest: Boolean;
		Pasar_Elemento_Mess_Id_T: Implementacion_Ordered.Mess_Id_T;
		Rellenar_Destination: Implementacion_Ordered.Destinations_T;
		Quedan_EP:Boolean;
		Nuevo_Time: Ada.Calendar.Time;
	
	begin

		Quedan_EP:=False;
		--busco el elemento en sender buffering correspondiente al mensaje a transmitir
		Sender_Buffering.Get(Mapa_Sender_Buffering, Time, Rellenar_Value_T, Success);
		
		if Success = True then
			--asigno las variables a mess id t
			Pasar_Elemento_Mess_Id_T.EP:=Rellenar_Value_T.EP_H_Creat;
			Pasar_Elemento_Mess_Id_T.Seq:=Rellenar_Value_T.Seq_N;
			--Borro el elemento que he buscado
			Debug.Put_Line("Borrando Sender_Buffering", Pantalla.Gris_Oscuro);
			Sender_Buffering.Delete(Mapa_Sender_Buffering, Time, Success);
		
		
		--busco en sender dest con los campos obtenidos de sender buffering (EP, seq)
		Sender_Dests.Get(Mapa_Sender_Dests, Pasar_Elemento_Mess_Id_T, Rellenar_Destination, Success_Dest);
			if Success_Dest = True then
				for k in 1..Rellenar_Destination'Length loop
					
					if Rellenar_Destination(k).EP /= null and Rellenar_Destination(k).Retries <= Integer(Max) then
						--como no es nulo, lo envio
--Debug.Put_Line("Array Destination:" & Herramientas.Obtener_IP(Rellenar_Destination(k).EP), Pantalla.Rojo);
						Debug.Put_Line("Retransmision enviada a:" & Herramientas.Obtener_IP(Rellenar_Destination(k).EP)
									& ", con secuencia: " & Implementacion_Ordered.Seq_N_T'Image(Pasar_Elemento_Mess_Id_T.Seq));
						LLU.Send(Rellenar_Destination(k).EP, Rellenar_Value_T.P_Buffer);
						Rellenar_Destination(k).Retries:=Rellenar_Destination(k).Retries +1;
						if Rellenar_Destination(k).Retries <= Integer(Max) then
--Debug.Put_Line("entro en quedan");
							--comprobamos si hay algun EP y el numero de secuencias
							Quedan_EP:=True;
						end if;
					end if;
				end loop;
			end if;
--Debug.Put_Line("salgo del bucle");	
--Debug.Put_Line(Boolean'Image(Quedan_EP));
	
			if Quedan_EP = True then
--Debug.Put_Line("entro en quedan 2");
				--programa de retransmision
				--la tabla de simbolos la necesitamos para almacenar los mensajes pendientes de ser asentidos
					Nuevo_Time:= Ada.Calendar.Clock + Plazo_Retransmision;
					Timed_Handlers.Set_Timed_Handler(Nuevo_Time, Retransmision'Access);

					Debug.Put_Line(" Actualizamos Sender_Dest", Pantalla.Blanco);
					Sender_Dests.Put(Mapa_Sender_Dests, Pasar_Elemento_Mess_Id_T, Rellenar_Destination);
					Sender_Buffering.Put(Mapa_Sender_Buffering, Nuevo_Time, Rellenar_Value_T);
			else
				CM.Free(Rellenar_Value_T.P_Buffer);
				Debug.Put_Line("Free activado", Pantalla.Gris_Oscuro);
				Sender_Dests.Delete(Mapa_Sender_Dests, Pasar_Elemento_Mess_Id_T, Success_Dest);
				Sender_Buffering.Delete(Mapa_Sender_Buffering, Time, Success);
			end if;
		
			
		end if;
		
	end Retransmision;
	
	
end Chat_Handlers;

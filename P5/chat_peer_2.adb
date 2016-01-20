--Por Saúl Ibáñez Cerro

--Se realizará un programa en Ada que ofrezca un servicio de chat entre usuarios uilizando 
--el mdelo P2P descentralizado

--gnatmake -I/usr/local/ll/lib chat_peer_2.adb
--./chat_peer_2 9001 nickname 2 25 50
--./chat_peer_2 2222 saul 2 20 50 saul-VirtualBox 9001


with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;
with Chat_Handlers;
with Debug;
with Pantalla;
with Maps_Protector_G;
with Maps_G;
with Ada.Calendar;
with Herramientas;
with Timed_Handlers;
with Implementacion_Ordered;
with Gnat.Ctrl_C;

procedure Chat_Peer_2 is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	type Seq_N_T is mod Integer'Last;
	use type Implementacion_Ordered.Seq_N_T;
	use Ada.Strings.Unbounded;
	use Implementacion_Ordered;
	
	Opcion: ASU.Unbounded_String;
	Usage_Error: exception;
	Request: ASU.Unbounded_String;
	
	Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	--Nick : ASU.Unbounded_String;
	EP_Receive : LLU.End_Point_Type;
	--EP_Handler_Rsnd: LLU.End_Point_Type; 
	Min_Delay: Integer;
	Max_Delay: Integer;
	Fault_Pct: Natural;
	
	Nombre_Maquina_Vecino1 : ASU.Unbounded_String;
	Nombre_Maquina_Vecino2 : ASU.Unbounded_String;
	EP_Vecino1: LLU.End_Point_Type;
	EP_Vecino2: LLU.End_Point_Type;
	
	Buffer : aliased LLU.Buffer_Type(1024);
	Mess : CM.Message_Type;
	Agregar: Boolean;
	Hora: Ada.Calendar.Time;
	Confirm: Boolean;
	Expired: Boolean;
	Success: Boolean;
	Activo_Desactivo: Boolean:=True;
	Enviado: Boolean:= False;
	
	procedure Leer_Entrada (Opcion: out ASU.Unbounded_String) is
	begin
		Chat_Handlers.Mi_Nick := ASU.To_Unbounded_String(Ada.Command_Line.Argument(2));
		Hora:= Ada.Calendar.Clock;
		
		if Ada.Command_Line.Argument_Count = 5 then
			--De momento solo hay uno y no tiene ningun vecino
			Debug.Put_Line("NOT following admission protocol because we have no initial contacts ...", Pantalla.Verde);
			Ada.Text_IO.Put_Line("Chat-Peer");
			Ada.Text_IO.Put_Line("============");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Logging into chat with nick: " & ASU.To_String(Chat_Handlers.Mi_Nick));
			Ada.Text_IO.Put_Line(".h for help");
			
			Chat_Handlers.Seq_N:=2;
			
			while ASU.To_String(Request) /= ".quit" loop
				--Ada.Text_IO.Put_Line(Boolean'Image(Activo_Desactivo));
				if Activo_Desactivo = False then
					Ada.Text_IO.Put(ASU.To_String(Chat_Handlers.Mi_Nick) & " >> ");
				end if;
				
				Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					
				if ASU.To_String(Request) = ".h" or ASU.To_String(Request) = ".help" or ASU.To_String(Request) = ".nb" or ASU.To_String(Request) = ".neighbors" or 
					ASU.To_String(Request) = ".lm" or ASU.To_String(Request) = ".latest_msg" or ASU.To_String(Request) = ".debug" or 
					ASU.To_String(Request) = ".wai" or ASU.To_String(Request) = ".whoami" or ASU.To_String(Request) = ".prompt" or 
					ASU.To_String(Request) = ".sb" or ASU.To_String(Request) = ".sd" then
					
					Herramientas.Modo_Interactivo(Request, Chat_Handlers.Mi_Nick, Chat_Handlers.Mi_EP_Handler, EP_Receive, Activo_Desactivo);
						
				elsif ASU.To_String(Request) /= ".quit" then
					Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
					Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
					CM.P_Buffer_Main := new LLU.Buffer_type(1024);
					Herramientas.Enviar_Mensaje_Writer(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler,
													Chat_Handlers.Mi_Nick, Request, CM.P_Buffer_Main, Enviado);
					Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
					
				else
					Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
					Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
					Confirm:=True;
					CM.P_Buffer_Main := new LLU.Buffer_type(1024);
					Herramientas.Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
													Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
					Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);

					delay Chat_Handlers.Plazo_Logout;

				end if;
			end loop;
				
		elsif Ada.Command_Line.Argument_Count = 7 then
			--Voy a tener un vecino
			Nombre_Maquina_Vecino1:=ASU.To_Unbounded_String(Ada.Command_Line.Argument(6));
			EP_Vecino1 := LLU.Build(LLU.To_IP(ASU.To_String(Nombre_Maquina_Vecino1)), Natural'Value(Ada.Command_Line.Argument(7)));
			Chat_Handlers.Neighbors.Put(Chat_Handlers.Vecinos, EP_Vecino1, Hora, Success);
			--Chat_Handlers.Neighbors.Print_Map(Chat_Handlers.Vecinos);			--ver los vecinos que tengo
			Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
			Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);		--Mensajes esta declarado en handlers.ads
			--Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, EP_Vecino1,2,Agregar);
			Debug.Put_Line("Adding to neighbors " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
			Ada.Text_IO.New_Line;
			Debug.Put_Line("Admission protocol started ...", Pantalla.Verde);
			Debug.Put_Line("Adding to latest_messages " &  Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N), Pantalla.Verde);
			CM.P_Buffer_Main := new LLU.Buffer_type(1024);
			Herramientas.Enviar_Mensaje_Init(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N,Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, EP_Receive,
											Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Enviado);
			Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);

			Debug.Put("FLOOD Init ", Pantalla.Amarillo);
			Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" ... " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
			Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
			
			LLU.Receive(EP_Receive, Buffer'Access, 2.0, Expired);
				if Expired then
					Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;		--vuelvo a aumentar la secuencia y lo guardo en su tabla
					Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
					CM.P_Buffer_Main := new LLU.Buffer_type(1024);
					Herramientas.Enviar_Mensaje_Confirm(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
														Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Enviado);	
					Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
					Ada.Text_IO.New_Line;
					Debug.Put_Line("Adding to latest_msgs " & Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N), Pantalla.Verde);
					Debug.Put("FLOOD Confirm ", Pantalla.Amarillo);
					Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
					Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
					Ada.Text_IO.New_Line;
					Debug.Put_Line("Admission protocol finished. ", Pantalla.Verde);
					Ada.Text_IO.New_Line;
					Ada.Text_IO.Put_Line("Chat-Peer");
					Ada.Text_IO.Put_Line("============");
					Ada.Text_IO.New_Line;
					Ada.Text_IO.Put_Line("Logging into chat with nick: " & ASU.To_String(Chat_Handlers.Mi_Nick));
					Ada.Text_IO.Put_Line(".h for help");
					
					while ASU.To_String(Request) /= ".quit" loop
					
						if Activo_Desactivo = False then
							Ada.Text_IO.Put(ASU.To_String(Chat_Handlers.Mi_Nick) & " >> ");
						end if;
						
						Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
						
						if ASU.To_String(Request) = ".h" or ASU.To_String(Request) = ".help" or ASU.To_String(Request) = ".nb" or ASU.To_String(Request) = ".neighbors" or 
							ASU.To_String(Request) = ".lm" or ASU.To_String(Request) = ".latest_msg" or ASU.To_String(Request) = ".debug" or 
							ASU.To_String(Request) = ".wai" or ASU.To_String(Request) = ".whoami" or ASU.To_String(Request) = ".prompt" or 
							ASU.To_String(Request) = ".sb" or ASU.To_String(Request) = ".sd" then
							
							Herramientas.Modo_Interactivo(Request, Chat_Handlers.Mi_Nick, Chat_Handlers.Mi_EP_Handler, EP_Receive, Activo_Desactivo);
							
						elsif ASU.To_String(Request) /= ".quit" then
							Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
							Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
							CM.P_Buffer_Main := new LLU.Buffer_type(1024);
							Herramientas.Enviar_Mensaje_Writer(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
															Chat_Handlers.Mi_Nick, Request, CM.P_Buffer_Main, Enviado);
							Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
						
							Debug.Put_Line("Adding to latest_msgs " & Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N), Pantalla.Verde);
							Debug.Put("FLOOD Writer ", Pantalla.Amarillo);
							Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
										ASU.To_String(Chat_Handlers.Mi_Nick) & " " & ASU.To_String(Request), Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
							Ada.Text_IO.New_Line;
						else
							Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
							Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
							Confirm:=True;
							CM.P_Buffer_Main := new LLU.Buffer_type(1024);
							Herramientas.Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler,
															Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
							Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
							Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
							Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
										ASU.To_String(Chat_Handlers.Mi_Nick) & " TRUE", Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
							delay Chat_Handlers.Plazo_Logout;
						end if;
					end loop;
					
				else
					Mess :=CM.Message_Type'Input(Buffer'Access);
					if Mess = CM.Reject then
						Confirm:=False;
						--Ada.Text_IO.Put_Line("cliente no admitido");
						Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
						Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N, Success);
						CM.P_Buffer_Main := new LLU.Buffer_type(1024);
						--Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
						Herramientas.Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler,
														Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
						Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
					
						Debug.Put_Line("RCV Reject " & Herramientas.Obtener_IP(EP_Vecino1) & " " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
						Debug.Put_Line("User rejected because" & Herramientas.Obtener_IP(EP_Vecino1) & " is using the same nick", Pantalla.Blanco);
						Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
						Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
										ASU.To_String(Chat_Handlers.Mi_Nick) & " FALSE", Pantalla.Verde);
						Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
						Ada.Text_IO.New_Line;
						Debug.Put_Line("Admission protocol finished. ", Pantalla.Verde);
					end if;
					delay Chat_Handlers.Plazo_Reject;
				end if;
					
			elsif Ada.Command_Line.Argument_Count = 9 then
				--Voy a tener 2 vecinos
				Nombre_Maquina_Vecino1:=ASU.To_Unbounded_String(Ada.Command_Line.Argument(6));
				EP_Vecino1 := LLU.Build(LLU.To_IP(ASU.To_String(Nombre_Maquina_Vecino1)), Natural'Value(Ada.Command_Line.Argument(7)));
				Nombre_Maquina_Vecino2:=ASU.To_Unbounded_String(Ada.Command_Line.Argument(8));
				EP_Vecino2 := LLU.Build(LLU.To_IP(ASU.To_String(Nombre_Maquina_Vecino2)), Natural'Value(Ada.Command_Line.Argument(9)));
				Chat_Handlers.Neighbors.Put(Chat_Handlers.Vecinos, EP_Vecino1, Hora, Success);
				Chat_Handlers.Neighbors.Put(Chat_Handlers.Vecinos, EP_Vecino2, Hora, Success);
				
				Chat_Handlers.Seq_N := Chat_Handlers.Seq_N +1;
				Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);		--Mensajes esta declarado en handlers.ads
				--Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, EP_Vecino1,2,Agregar);
				
				Pantalla.Poner_Color(Pantalla.Verde);
				Ada.Text_IO.Put_Line("Adding to neighbors " & Herramientas.Obtener_IP(EP_Vecino1));
				Ada.Text_IO.Put_Line("Adding to neighbors " & Herramientas.Obtener_IP(EP_Vecino2));
				Ada.Text_IO.New_Line;
				Ada.Text_IO.Put_Line("Admission protocol started ...");
				Ada.Text_IO.Put_Line("Adding to latest_messages " &  Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N));
				Pantalla.Poner_Color(Pantalla.Cierra);
				
				CM.P_Buffer_Main := new LLU.Buffer_type(1024);
				Herramientas.Enviar_Mensaje_Init(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N,Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, EP_Receive, 
											Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Enviado);
				Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
				
				Debug.Put("FLOOD Init ", Pantalla.Amarillo);
				Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" ... " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
				Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
				Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino2), Pantalla.Verde);
				
				LLU.Receive(EP_Receive, Buffer'Access, 2.0, Expired);
				if Expired then
					Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;		--vuelvo a aumentar la secuencia y lo guardo en su tabla
					Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
					CM.P_Buffer_Main := new LLU.Buffer_type(1024);
					Herramientas.Enviar_Mensaje_Confirm(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
													Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Enviado);					
					Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
					
					Ada.Text_IO.New_Line;
					Debug.Put_Line("Adding to latest_msgs " & Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N), Pantalla.Verde);
					Debug.Put("FLOOD Confirm ", Pantalla.Amarillo);
					Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
					Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
					Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino2), Pantalla.Verde);
					Ada.Text_IO.New_Line;
					Debug.Put_Line("Admission protocol finished. ", Pantalla.Verde);
					Ada.Text_IO.New_Line;
					Ada.Text_IO.Put_Line("Chat-Peer");
					Ada.Text_IO.Put_Line("============");
					Ada.Text_IO.New_Line;
					Ada.Text_IO.Put_Line("Logging into chat with nick: " & ASU.To_String(Chat_Handlers.Mi_Nick));
					Ada.Text_IO.Put_Line(".h for help");
					
					while ASU.To_String(Request) /= ".quit" loop
					
						if Activo_Desactivo = False then
							Ada.Text_IO.Put(ASU.To_String(Chat_Handlers.Mi_Nick) & " >> ");
						end if;
						
						Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
						
						if ASU.To_String(Request) = ".h" or ASU.To_String(Request) = ".help" or ASU.To_String(Request) = ".nb" or ASU.To_String(Request) = ".neighbors" or 
							ASU.To_String(Request) = ".lm" or ASU.To_String(Request) = ".latest_msg" or ASU.To_String(Request) = ".debug" or 
							ASU.To_String(Request) = ".wai" or ASU.To_String(Request) = ".whoami" or ASU.To_String(Request) = ".prompt" or 
							ASU.To_String(Request) = ".sb" or ASU.To_String(Request) = ".sd" then
							
							Herramientas.Modo_Interactivo(Request, Chat_Handlers.Mi_Nick, Chat_Handlers.Mi_EP_Handler, EP_Receive, Activo_Desactivo);
							
						elsif ASU.To_String(Request) /= ".quit" then
							Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
							Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
							CM.P_Buffer_Main := new LLU.Buffer_type(1024);
							Herramientas.Enviar_Mensaje_Writer(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
															Chat_Handlers.Mi_Nick, Request, CM.P_Buffer_Main, Enviado);
							Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
							
							Debug.Put_Line("Adding to latest_msgs " & Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N), Pantalla.Verde);
							Debug.Put("FLOOD Writer ", Pantalla.Amarillo);
							Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
										ASU.To_String(Chat_Handlers.Mi_Nick) & " " & ASU.To_String(Request), Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino2), Pantalla.Verde);
							Ada.Text_IO.New_Line;
						else
							Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
							Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
							Confirm:=True;
							CM.P_Buffer_Main := new LLU.Buffer_type(1024);
							Herramientas.Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
															Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
							Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
							Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
							Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
											ASU.To_String(Chat_Handlers.Mi_Nick) & " TRUE", Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
							Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino2), Pantalla.Verde);
							delay Chat_Handlers.Plazo_Logout;
						end if;
					end loop;
					
				else
					Mess :=CM.Message_Type'Input(Buffer'Access);
					if Mess = CM.Reject then
						Confirm:=False;
						--Ada.Text_IO.Put_Line("cliente no admitido");
						Chat_Handlers.Seq_N:=Chat_Handlers.Seq_N +1;
						Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N, Success);

						--Chat_Handlers.Latest_Msgs.Put(Chat_Handlers.Mensajes, Chat_Handlers.Mi_EP_Handler,Chat_Handlers.Seq_N,Agregar);
						CM.P_Buffer_Main := new LLU.Buffer_type(1024);
						Herramientas.Enviar_Mensaje_Logout(Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Mi_EP_Handler, 
														Chat_Handlers.Mi_Nick, CM.P_Buffer_Main, Confirm, Enviado);
						Herramientas.Guardar_Sender(Enviado, Chat_Handlers.Mi_EP_Handler, Chat_Handlers.Seq_N, CM.P_Buffer_Main);
						
						Debug.Put_Line("RCV Reject " & Herramientas.Obtener_IP(EP_Vecino1) & " " & ASU.To_String(Chat_Handlers.Mi_Nick), Pantalla.Verde);
						Debug.Put_Line("User rejected because" & Herramientas.Obtener_IP(EP_Vecino1) & " is using the same nick", Pantalla.Blanco);
						Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
						Debug.Put_Line(Herramientas.Obtener_IP(Chat_Handlers.Mi_EP_Handler) & Implementacion_Ordered.Seq_N_T'Image(Chat_Handlers.Seq_N) &" " & 
										ASU.To_String(Chat_Handlers.Mi_Nick) & " FALSE", Pantalla.Verde);
						Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino1), Pantalla.Verde);
						Debug.Put_Line("    send to: " & Herramientas.Obtener_IP(EP_Vecino2), Pantalla.Verde);
						Ada.Text_IO.New_Line;
						Debug.Put_Line("Admission protocol finished. ", Pantalla.Verde);
					end if;
					delay Chat_Handlers.Plazo_Reject;
				end if;
				
		end if;
		
	end Leer_Entrada;
	
begin
	Gnat.Ctrl_C.Install_Handler (Herramientas.Ctrl_C_Handler'Access);
	--Ada.Text_IO.Put_Line("entro con los argumentos: " & Integer'Image(Ada.Command_Line.Argument_Count));
	if Ada.Command_Line.Argument_Count <5 or Ada.Command_Line.Argument_Count > 9 then
		raise Usage_Error;
	elsif  Ada.Command_Line.Argument_Count = 6 or Ada.Command_Line.Argument_Count = 8 then
		raise Usage_Error;
	end if;
	
	Maquina:=ASU.To_Unbounded_String(LLU.Get_Host_Name);
	Dir_IP:=ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	Chat_Handlers.Mi_EP_Handler := LLU.Build(ASU.To_String(Dir_IP), Natural'Value(Ada.Command_Line.Argument(1)));
	LLU.Bind (Chat_Handlers.Mi_EP_Handler, Chat_Handlers.P2P_Handler'Access);
	LLU.Bind_Any(EP_Receive);
	LLU.Reset(Buffer);
	Min_Delay := Integer'Value(Ada.Command_Line.Argument(3));
	Max_Delay := Integer'Value(Ada.Command_Line.Argument(4));
	Fault_Pct := Integer'Value(Ada.Command_Line.Argument(5));
	
	if Fault_Pct > 100 then
		raise Usage_Error;
	end if;
	
	LLU.Set_Faults_Percent(Fault_Pct);
	LLU.Set_Random_Propagation_Delay(Min_Delay, Max_Delay);

	--El plazo de retransmision:
	Chat_Handlers.Plazo_Retransmision := 2 * Duration(Max_Delay) / 1000;
	Chat_Handlers.Plazo_Reject := 0.5 + (6 * Duration(Max_Delay) / 1000);

	Chat_Handlers.Max := 10.0 + ((Float(Fault_Pct)/10.0)*(Float(Fault_Pct)/10.0));
	Chat_Handlers.Plazo_Logout := Duration(Chat_Handlers.Max) * Chat_Handlers.Plazo_Retransmision;
	
	--Pantalla.Poner_Color(Pantalla.Blanco);
	Leer_Entrada(Opcion);
	--Pantalla.Poner_Color(Pantalla.Cierra);
	Timed_Handlers.Finalize;
	LLU.Finalize;
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
	
end Chat_Peer_2;
--Por Saúl Ibáñez Cerro

--Se realizará un programa en Ada siguiendo el modelo servidor que permita implementar
--un pequeño chat entre usuarios

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;
with Client_Lists;

procedure Chat_Server is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use Ada.Strings.Unbounded;
	use Lower_Layer_UDP;
	use Client_Lists;
	Opcion: ASU.Unbounded_String;
	Usage_Error: exception;


	--NOTA: En este caso, no voy a usar este procedimiento, que solo me leería cuando pusiera el puerto 9001
			--Ahora, con Natural'Value(Ada.Command_Line.Argument(1)) me lee cualquier puerto
	procedure Leer_Entrada (Opcion :  out ASU.Unbounded_String) is
	begin
		if Ada.Command_Line.Argument(1) = "9001" then
			Opcion := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
		else
			raise Usage_Error;
		end if;
			
	end Leer_Entrada;

	Client_EP : LLU.End_Point_Type;
	Server_EP : LLU.End_Point_Type;
	Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	Nick:ASU.Unbounded_String;
	Buffer : aliased LLU.Buffer_Type(1024);
	Request : ASU.Unbounded_String;
	Reply : ASU.Unbounded_String := ASU.To_Unbounded_String("Bienvenido");
	Mess : CM.Message_Type;
	Puntero : Client_Lists.Client_List_Type;
	P_Aux: Client_Lists.Cell_A;
	Expired : Boolean;
	Salir:Boolean := False;
	
begin
	
	--Leer_Entrada(Opcion);
	
	Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	--Ada.Text_IO.Put_Line("Dir IP " & (ASU.To_String(Dir_IP)));
	Server_EP := LLU.Build (ASU.To_String(Dir_IP), Natural'Value(Ada.Command_Line.Argument(1)));
	LLU.Bind (Server_EP);
	
	loop
		LLU.Reset(Buffer);
		LLU.Receive(Server_EP, Buffer'Access, 1000.0, Expired);
		--Ada.Text_IO.Put("conectado");
		if Expired then
			Ada.Text_IO.Put_Line("plazo expirado, vuelve a intentarlo");
		else
			Mess := CM.Message_Type'Input(Buffer'Access);
			Client_EP := LLU.End_Point_Type'Input(Buffer'Access);		

			--Ada.Text_IO.Put(LLU.Image(Client_EP));		--De quien viene la petición
			--LLU.Reset(Buffer);
			
			if Mess = CM.Init then

				begin
					Nick:=ASU.Unbounded_String'Input(Buffer'Access);
					Ada.Text_IO.Put("INIT received from ");
					Ada.Text_IO.Put(ASU.To_String(Nick));
					Ada.Text_IO.Put_Line ("");
					Client_Lists.Add_Client(Puntero, Client_EP, Nick);
					if Request = ".quit" then
						Puntero.Total:= Puntero.Total -1;
					end if;
					
					exception
					when Client_List_Error =>
						Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick) &". IGNORED, nick already used");
				end;
				
				--NOTA: con la funcion de abajo me va a imprimir la IP, Puerto y nombre del cliente que he ejecutado.
						--la dejo como comentario ya que no era obligatoria implementarla, pero si crearla.
				--ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String(Client_Lists.List_Image(Puntero)));
				
			elsif Mess = CM.Writer then
				P_Aux:= Puntero.P_First;
				begin

					Request:=ASU.Unbounded_String'Input(Buffer'Access);
					Mess:=CM.Server;									--Covierto Mess server
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access,Mess);			--Meto en el buffer el mess

					while P_Aux/=null  loop								
						if P_Aux.Client_EP = Client_EP then
							Nick:= P_Aux.Nick;
							Salir:= True;
						end if;
							Salir:= True;
							P_Aux:=P_Aux.Next;
						end loop;

					ASU.Unbounded_String'Output(Buffer'Access,Nick);
					ASU.Unbounded_String'Output(Buffer'Access,Request);		--Introduzco el mensaje en el Buffer
					Client_Lists.Send_To_Readers(Puntero, Buffer'Access);
					ASU.Unbounded_String'Output(Buffer'Access, Client_Lists.Search_Client(Puntero, Client_EP));
					Ada.Text_IO.Put_Line(ASU.To_String(Request));
					
					exception
					when Client_List_Error =>
						Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
				end;
			end if;
			LLU.Reset(Buffer);
			
		end if;
	end loop;
	
	LLU.Finalize;
	
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("Debes poner un puerto");

		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("Debes poner un puerto");


end Chat_Server;
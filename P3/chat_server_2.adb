--Por Sa�l Ib��ez Cerro

--Se realizar� un programa en Ada siguiendo el modelo servidor 2 que permita implementar
--un peque�o chat entre usuarios

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;
with Client_Lists;
with Handlers;
with Ada.Calendar;

procedure Chat_Server_2 is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use Ada.Strings.Unbounded;
	use Lower_Layer_UDP;
	Opcion: ASU.Unbounded_String;
	Usage_Error: exception;
	use Client_Lists;

	procedure Leer_Entrada (Opcion :  out ASU.Unbounded_String) is
	begin
		if Natural'Value(Ada.Command_Line.Argument(2)) >= 2 or Natural'Value(Ada.Command_Line.Argument(2)) <=50 then
			Opcion := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
		else
			raise Usage_Error;
		end if;
			
	end Leer_Entrada;

	Server_EP : LLU.End_Point_Type;
	Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	
	Mess : CM.Message_Type;
	Client_EP_Receive : LLU.End_Point_Type;
	Client_EP_Handler : LLU.End_Point_Type;
	Nick : ASU.Unbounded_String;
	Request : ASU.Unbounded_String;
	Buffer : aliased LLU.Buffer_Type(1024);
	
	Puntero: Client_Lists.Client_List_Type;
	Acogido: Boolean:=True;
	Salir: Boolean:=False;
	Expired : Boolean;
	Numero_Max_Clientes :Natural;
	Contador_Clientes:Natural:=0;
begin
	
	Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	--Ada.Text_IO.Put_Line("Dir IP " & (ASU.To_String(Dir_IP)));
	Server_EP := LLU.Build (ASU.To_String(Dir_IP), Natural'Value(Ada.Command_Line.Argument(1)));
	Leer_Entrada(Opcion);	
	LLU.Bind (Server_EP);
	--Ada.Text_IO.Put(LLU.Image(Server_EP));
	Numero_Max_Clientes := Natural'Value(Ada.Command_Line.Argument(2));
	
	loop
		Contador_Clientes:=Client_Lists.Count(Puntero);
		LLU.Reset(Buffer);
		LLU.Receive(Server_EP, Buffer'Access, 1000.0, Expired);
		--Ada.Text_IO.Put("conectado");
		if Expired then
			Ada.Text_IO.Put_Line("plazo expirado, vuelve a intentarlo");
		else

			Mess := CM.Message_Type'Input(Buffer'Access);

			if Mess = CM.Init then
			
				begin
					Mess:=CM.Welcome;
					
					Client_EP_Receive := LLU.End_Point_Type'Input(Buffer'Access);
					Client_EP_Handler := LLU.End_Point_Type'Input(Buffer'Access);
					Nick:=ASU.Unbounded_String'Input(Buffer'Access);
					if Contador_Clientes >= Numero_Max_Clientes then
						Remove_Oldest(Puntero);
					end if;
					
					Client_Lists.Add_Client(Puntero, Client_EP_Handler, Nick);
					Ada.Text_IO.Put_Line(("INIT received from ")& ASU.To_String(Nick)&(" : ")&("ACOGIDO"));

					--NOTA: con la funcion de abajo me va a imprimir la IP, Puerto y nombre del cliente que he ejecutado.
								--la dejo como comentario ya que no era obligatoria implementarla, pero si crearla.
					--ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String(Client_Lists.List_Image(Puntero)));
					
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access,Mess);
					Boolean'Output(Buffer'Access, Acogido);
					LLU.Send(Client_EP_Receive, Buffer'Access);
					
					--Esta parte de codigo sirve para decirle a los otros escritores quien ha entrado en el chat
					LLU.Reset(Buffer);
					Request:=ASU.To_Unbounded_String("ha entrado en el chat");
					Mess:=CM.Server;
					CM.Message_Type'Output(Buffer'Access,Mess);
					ASU.Unbounded_String'Output(Buffer'Access,Nick);
					ASU.Unbounded_String'Output(Buffer'Access,Request);		
					Client_Lists.Send_To_All(Puntero, Buffer'Access, Client_EP_Handler);
					
				exception
					when Client_List_Error =>
						Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick) &": RECHAZADO");
				end;
			
			elsif Mess = CM.Writer then
				begin
					Client_EP_Handler := LLU.End_Point_Type'Input(Buffer'Access);
					Request:=ASU.Unbounded_String'Input(Buffer'Access);
					Mess:=CM.Server;									--Covierto Mess server
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access,Mess);			--Meto en el buffer el mess
					Ada.Text_IO.Put("WRITER received from ");
					Nick:=ASU.Unbounded_String(Client_Lists.Search_Client(Puntero, Client_EP_Handler));
					Ada.Text_IO.Put(ASU.To_String(Nick) & (": "));
					Client_Lists.Update_Client(Puntero, Client_EP_Handler);
					ASU.Unbounded_String'Output(Buffer'Access,Nick);
					ASU.Unbounded_String'Output(Buffer'Access,Request);		--Introduzco el mensaje en el Buffer
					
					Client_Lists.Send_To_All(Puntero, Buffer'Access, Client_EP_Handler);
					Ada.Text_IO.Put_Line(ASU.To_String(Request));
				exception
					when Client_List_Error =>
						Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
				end;
			elsif Mess= CM.Logout then
						
					Client_EP_Handler := LLU.End_Point_Type'Input(Buffer'Access);
					Mess:=CM.Server;									--Covierto Mess server
					LLU.Reset(Buffer);
					
					CM.Message_Type'Output(Buffer'Access,Mess);			--Meto en el buffer el mess
					Nick:=ASU.Unbounded_String(Client_Lists.Search_Client(Puntero, Client_EP_Handler));
					Request:=ASU.To_Unbounded_String("leaves the chat");
					ASU.Unbounded_String'Output(Buffer'Access,Nick);
					ASU.Unbounded_String'Output(Buffer'Access,Request);		--Introduzco el mensaje en el Buffer
					Client_Lists.Send_To_All(Puntero, Buffer'Access, Client_EP_Handler);
					
					Ada.Text_IO.Put_Line("LOGOUT received from " & ASU.To_String(Nick));
					LLU.Reset(Buffer);
			end if;
		end if;
	end loop;


	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("Debes poner un puerto");

		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("Debes poner un puerto");


end Chat_Server_2;
--Por Sa�l Ib��ez Cerro

--Se realizar� un programa en Ada siguiendo el modelo cliente 2 que permita implementar
--un peque�o chat entre usuarios

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;
with Handlers;

procedure Chat_Client_2 is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	
	
	Opcion: ASU.Unbounded_String;
	Usage_Error: exception;
	Client_EP_Receive : LLU.End_Point_Type;
	Client_EP_Handler:  LLU.End_Point_Type;
	Server_EP : LLU.End_Point_Type;
	
	--Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	
	Buffer : aliased LLU.Buffer_Type(1024);
	Request : ASU.Unbounded_String;
	Reply : ASU.Unbounded_String;
	Expired : Boolean;
	Nick : ASU.Unbounded_String;
	Mess : CM.Message_Type;
	Acogido: Boolean;
	
	procedure Leer_Entrada (Opcion: out ASU.Unbounded_String) is
	begin
		Opcion := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
		--Ada.Text_IO.Put_Line("Introduce una cadena de caracteres");
		Mess := CM.Init;
		CM.Message_Type'Output(Buffer'Access, Mess);				--el atributo 'Output tipo de dato que queremos introducir
															--en el buffer. Se introduce el End_Point del cliente en el buffer
															--para que el servidor sepa donde puede responder
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
		Nick := ASU.To_Unbounded_String(Ada.Command_Line.Argument(3));
		ASU.Unbounded_String'Output(Buffer'Access, Nick);
		LLU.Send(Server_EP, Buffer'Access);						--Env�a el conteindo del buffer
		LLU.Reset(Buffer);
		LLU.Receive(Client_EP_Receive, Buffer'Access, 1000.0, Expired);
		
		if Expired then
			Ada.Text_IO.Put_Line ("Plazo expirado");
		else
			Acogido := Boolean'Input(Buffer'Access);
			Mess:=CM.Message_Type'Input(Buffer'Access);
			
			if Acogido = False then
				Ada.Text_IO.Put_Line("IGNORED new user" & ASU.To_String(Nick) &", nick already used");
			else
				Ada.Text_IO.Put_Line ("Mini-Chat v2.0: Welcome " & ASU.To_String(Nick));
				LLU.Reset(Buffer);
				while ASU.To_String(Request) /= ".quit" loop
					Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					if ASU.To_String(Request) /= ".quit" then
						Mess := CM.Writer;
						CM.Message_Type'Output(Buffer'Access, Mess);
						LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
						ASU.Unbounded_String'Output(Buffer'Access, Request);
						LLU.Send(Server_EP, Buffer'Access);
						LLU.Reset(Buffer);
					else
						Mess:= CM.Logout;
						CM.Message_Type'Output(Buffer'Access, Mess);
						LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
						LLU.Send(Server_EP, Buffer'Access);
						LLU.Reset(Buffer);
					end if;
				end loop;
	
			end if;
		end if;

	end Leer_Entrada;


begin
	
	--Devuelve el nombre DNS de la maquina
	--Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name); 
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(Ada.Command_Line.Argument(1)));
	Server_EP := LLU.Build(ASU.To_String(Dir_IP), Natural'Value(Ada.Command_Line.Argument(2)));
	
	LLU.Bind_Any(Client_EP_Receive);		-- Construye un End Point libre cualquiera y lo ata a el
	
	LLU.Bind_Any(Client_EP_Handler, Handlers.Client_Handler'Access);
	LLU.Reset(Buffer); 		--Vaciara los datos que haya en el buffer						

	--Ada.Text_IO.Put(LLU.Image(Server_EP));
	
	if  Ada.Command_Line.Argument_Count /=3 then
		raise Usage_Error;
	end if;
	
	Leer_Entrada(Opcion);
		
	LLU.Finalize;
	
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("<Nombre del pc> <Puerto igual que el Server> <Nick del usuario>");
			Ada.Text_IO.Put_Line("Server unreachable");
		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("<Nombre del pc> <Puerto igual que el Server> <Nick del usuario>");
			Ada.Text_IO.Put_Line("Server unreachable");

end Chat_Client_2;
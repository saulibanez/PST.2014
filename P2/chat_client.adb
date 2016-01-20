--Por Saúl Ibáñez Cerro

--Se realizará un programa en Ada siguiendo el modelo cliente que permita implementar
--un pequeño chat entre usuarios

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Exceptions;
with Chat_Messages;

procedure Chat_Client is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	
	
	Opcion: ASU.Unbounded_String;
	Usage_Error: exception;
	Client_EP : LLU.End_Point_Type;
	Server_EP : LLU.End_Point_Type;
	
	Maquina : ASU.Unbounded_String;
	Dir_IP : ASU.Unbounded_String;
	
	Buffer : aliased LLU.Buffer_Type(1024);
	Request : ASU.Unbounded_String;
	Reply : ASU.Unbounded_String;
	Expired : Boolean;
	Nick : ASU.Unbounded_String;
	Mess : CM.Message_Type;
	
	procedure Leer_Entrada (Opcion: out ASU.Unbounded_String) is
	begin
		if Ada.Command_Line.Argument(1) = ASU.To_String(Maquina) and Ada.Command_Line.Argument(3) /= "reader" then
			Opcion := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			--Ada.Text_IO.Put_Line("Introduce una cadena de caracteres");
			
			Mess := CM.Init;
			CM.Message_Type'Output(Buffer'Access, Mess);				--el atributo 'Output tipo de dato que queremos introducir
																--en el buffer. Se introduce el End_Point del cliente en el buffer
																--para que el servidor sepa donde puede responder
			LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
			Nick := ASU.To_Unbounded_String(Ada.Command_Line.Argument(3));
			ASU.Unbounded_String'Output(Buffer'Access, Nick);
			LLU.Send(Server_EP, Buffer'Access);		--Envía el conteindo del buffer
			LLU.Reset(Buffer);
				
			while ASU.To_String(Request) /= ".quit" loop
				Mess := CM.Writer;
				CM.Message_Type'Output(Buffer'Access, Mess);
				LLU.End_Point_Type'Output(Buffer'Access, Client_EP);		
				Ada.Text_IO.Put("Mensaje: ");
				Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				ASU.Unbounded_String'Output(Buffer'Access, Request);
				LLU.Send(Server_EP, Buffer'Access);		
				LLU.Reset(Buffer);
		
			end loop;
			
		elsif Ada.Command_Line.Argument(1) = ASU.To_String(Maquina) and Ada.Command_Line.Argument(3) = "reader" then
			Opcion := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			
				Mess := CM.Init;
				CM.Message_Type'Output(Buffer'Access, Mess);
				LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
				ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("reader"));
				LLU.Send(Server_EP, Buffer'Access);
				LLU.Reset(Buffer);
				loop
					--LLU.Reset(Buffer);
					LLU.Receive(Client_EP, Buffer'Access, 1000.0, Expired);
						if Expired then
							Ada.Text_IO.Put_Line ("Plazo expirado");
						else
							if CM.Message_Type'Input(Buffer'Access) = CM.Server then
								Nick := ASU.Unbounded_String'Input(Buffer'Access);
								Reply := ASU.Unbounded_String'Input(Buffer'Access);
								Ada.Text_IO.Put(ASU.To_String(Nick) & ": ");
								Ada.Text_IO.Put_Line(ASU.To_String(Reply));
							end if;
						end if;
				end loop;		
						
		elsif Ada.Command_Line.Argument(1) /= ASU.To_String(Maquina) then
			raise Usage_Error;
			
		end if;
			
	end Leer_Entrada;


begin
	
	--Devuelve el nombre DNS de la maquina
	Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name); 
	Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	Server_EP := LLU.Build(ASU.To_String(Dir_IP), Natural'Value(Ada.Command_Line.Argument(2)));
	
	LLU.Bind_Any(Client_EP);		-- Construye un End Point libre cualquiera y lo ata a el
	
	LLU.Reset(Buffer); 		--Vaciara los datos que haya en el buffer						
	
	Leer_Entrada(Opcion);
		
	LLU.Finalize;
	
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("<Nombre del pc> <Puerto igual que el Server> <Nick del usuario>");
		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Te has equivocado de comando.");
			Ada.Text_IO.Put_Line("<Nombre del pc> <Puerto igual que el Server> <Nick del usuario>");

end Chat_Client;
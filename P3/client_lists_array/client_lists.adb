--Por Saúl Ibáñez Cerro

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;
with Ada.Command_Line;

package body Client_Lists is

	use Ada.Strings.Unbounded;
	use Lower_Layer_UDP;
	use Ada.Calendar;
	
	procedure Add_Client (List: in out Client_List_Type; EP: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
		Hora : Ada.Calendar.Time:=Ada.Calendar.Clock;
		
	begin		
		for k in 1..Contador_Clientes loop
			if List(k).Nick = Nick then 
				raise Client_List_Error;
			end if;
		end loop;
		
		List(Posicion_Clientes).Nick := Nick;				--El nick ha sido insertado en el array
		List(Posicion_Clientes).Client_EP := EP;			--El End Point ha sido insertado en el array
		List(Posicion_Clientes).Hora_Del_Cliente := Hora;	--Inserto la hora en el array
		Contador_Clientes := Posicion_Clientes;
		Posicion_Clientes := Posicion_Clientes +1;

		--for i in 1..Contador_Clientes loop
			--Ada.Text_IO.Put_Line(ASU.To_String(List(i).Nick));
		--end loop;
		
	end Add_Client;



	function Search_Client (List: in Client_List_Type; EP: in LLU.End_Point_Type) return ASU.Unbounded_String is
		Salir : boolean := False;
		Nick:ASU.Unbounded_String;
		
	begin
		for k in 1..Contador_Clientes loop
			--Ada.Text_IO.Put_Line(LLU.Image(P_Aux.Client_EP));
			--Ada.Text_IO.Put_Line(LLU.Image(EP));
			
			if List(k).Client_EP = EP then
				Nick:= List(k).Nick;
				Salir:=True;
			end if;
		end loop;
		
		if Salir = False then
			raise Client_List_Error;
		end if;
		return Nick;

	end Search_Client;
	


	procedure Send_To_All (List: in Client_List_Type; P_Buffer: access LLU.Buffer_Type; EP_Not_Send: in LLU.End_Point_Type) is
	begin
		
		for k in 1..Contador_Clientes loop 				--Corre la lista y manda mensaje a los escritores
			
			if List(k).Client_EP /= EP_Not_Send then
				LLU.Send(List(k).Client_EP, P_Buffer.all'Access);
			end if;
			
		end loop;
		LLU.Reset (P_Buffer.all);
	end Send_To_All;
	

	
	function Count (List: in Client_List_Type) return Natural is
	begin

		return Contador_Clientes;
	
	end Count;
	
	
	--El procedimiento Update_Client actualizara en la lista la hora almacenada para el cliente cuyo EP recibe como
	--parámetro . Si no encuentra en la lista ese EP, elevara la excepción Client_List_Error.
	
	procedure Update_Client (List: in out Client_List_Type; EP: in LLU.End_Point_Type) is
		Hora_Almacenada:Ada.Calendar.Time;
		Salir:Boolean:=False;
		
	begin
		
		for k in 1..Contador_Clientes loop
			if List(k).Client_EP = EP then
				Hora_Almacenada := Ada.Calendar.Clock;
				List(K).Hora_Del_Cliente:=Hora_Almacenada;
				Salir:=True;
			end if;
		end loop;
	
	if Salir = False then
			raise Client_List_Error;
		end if;

	end Update_Client;
	
	
	--El procedimiento Remove_Oldest borrara del la lista al cliente que tenga almacenada la hora mas antigua, y
	--devolvera su EP y su nick. Si la lista esta vacia, elevara la excepción Client_List_Error.
	
	procedure Remove_Oldest (List: in out Client_List_Type) is
		Hora_Mas_Antigua:Ada.Calendar.Time:=Ada.Calendar.Clock;
	begin
		
		--Introduzco en una variable la hora mas antigua para poder compararla despues
		if Contador_Clientes = 0 then
			raise Client_List_Error;
		end if;
			
		for k in 1..Contador_Clientes loop	
			if List(k).Hora_Del_Cliente <  Hora_Mas_Antigua then
				Hora_Mas_Antigua:=List(k).Hora_Del_Cliente;
			end if;
		end loop;
	
		--Me recorro la lista para encontrar cual tiene el tiempo menor y asi poder eliminarlo
		--Para borrar una celda de un array, debo desplazar a la posición que quiero eliminar, las siguientes celdas
		
		for k in 1..Contador_Clientes loop
			if List(k).Hora_Del_Cliente = Hora_Mas_Antigua then
				for i in k..Contador_Clientes loop
					List(i) := List(k+1);
				end loop;
			end if;
		end loop;
		
		Posicion_Clientes:=Posicion_Clientes -1;
		Contador_Clientes:=Contador_Clientes -1;
		
	end Remove_Oldest;
	
	
	
	procedure Delete_Client (List: in out Client_List_Type; Nick: in ASU.Unbounded_String) is		
	begin
	
		for k in 1..Contador_Clientes loop
			if List(k).Nick = Nick then
				for i in k..Contador_Clientes loop
					List(i) := List(k+1);
				end loop;
			end if;
		end loop;

	end Delete_Client;
	
	
	
	function List_Image (List: in Client_List_Type) return String is
		Texto:ASU.Unbounded_String;
		N : Natural:=0;
		R:ASU.Unbounded_String;
		P:Natural:=0;
		Q:ASU.Unbounded_String;
		T:ASU.Unbounded_String;
		Otra:Natural:=0;
	begin
	
		for k in 1..Contador_Clientes loop
			Texto:=ASU.To_Unbounded_String(LLU.Image(List(k).Client_EP));		--LLU_image lo convierto a unbounded_string
			--Ada.Text_IO.Put_Line(ASU.To_String(Texto));	--Cojo todo el LLU
			N:= ASU.Index (Texto,":");					
			R:=ASU.Tail(Texto,ASU.Length(Texto)-N-1);		--En R queda guardado: 127.0.1.1, Port: 50123  	*Nota: La IP y puerto son un ejemplo
			P:=Index(R,",");
			T:=ASU.Head(R,P-1);						--En T queda guardado: 127.0.1.1
			Otra:=Index(R,":");
			Q:=ASU.Tail(R,ASU.Length(R)-Otra-1);			--En Q queda guardado 50123
			
			Ada.Text_IO.Put_Line(ASU.To_String(T)&":"&ASU.To_String(Q)& " " &ASU.To_String(List(k).Nick));
		end loop;
		return ASU.To_String(Texto);
		
	end List_Image;
			 
end Client_Lists;
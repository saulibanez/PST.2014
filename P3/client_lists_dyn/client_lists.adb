--Por Saúl Ibáñez Cerro

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;

package body Client_Lists is

	use Ada.Strings.Unbounded;
	use Lower_Layer_UDP;
	use Ada.Calendar;
	
	procedure Add_Client (List: in out Client_List_Type; EP: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
	P_Aux : Cell_A:= List.P_First;
	EstaLaPalabraRepetida:Boolean := False;
	Salir:boolean:=False;
	Hora : Ada.Calendar.Time:=Ada.Calendar.Clock;
	begin
		if List.P_First = null then
			List.P_First := new Cell'(EP,Nick,Hora,null);
			List.Number_Clients:=List.Number_Clients +1;
		else
			P_Aux:= List.P_First;
			while EstaLaPalabraRepetida = False and P_Aux.Next/=null loop 
				if P_Aux.Nick = Nick then 
					EstaLaPalabraRepetida := True;
					raise Client_List_Error;
				else
					P_Aux:= P_Aux.Next;
				end if;
			end loop;
				
			if P_Aux.Nick = Nick then			--Aqui repito el bucle de arriba para que me pueda imprimir las palabras
												--iguales que existan en la primera linea.
				EstaLaPalabraRepetida := True;
				raise Client_List_Error;
			end if;
			P_Aux:= List.P_First;
			if EstaLaPalabraRepetida = False then
				List.P_First:= new Cell'(EP, Nick,Hora, null);
				List.Number_Clients:=List.Number_Clients +1;
				List.P_First.Next:=P_Aux;
			end if;
			
		end if;
		
		--Uso estas lineas comentadas para saber si me imprime en orden inverso, para comprobar el tiempo y para saber los EP de cada uno
		
		--P_Aux:=List.P_First;
		--		while P_Aux/=null loop
		--			Ada.Text_IO.Put_Line("El nombre del escritor es   " & ASU.To_String(P_Aux.Nick));
		--			Ada.Text_IO.Put_Line ("hora de inicio: " & Duration'Image(Ada.Calendar.Clock - P_Aux.Hora_Del_Cliente));
		--			Ada.Text_IO.Put(LLU.Image(P_Aux.Client_EP));
		--			P_Aux:=P_Aux.Next;
		--		end loop;
		
	end Add_Client;



	function Search_Client (List: in Client_List_Type; EP: in LLU.End_Point_Type) return ASU.Unbounded_String is
		P_Aux : Cell_A := List.P_First;
		Salir : boolean := False;
		k : Integer := 1;
		Nick:ASU.Unbounded_String;
		
	begin
		while P_Aux /= null and Salir = False  loop		
			--Ada.Text_IO.Put_Line(LLU.Image(P_Aux.Client_EP));
			--Ada.Text_IO.Put_Line(LLU.Image(EP));
			if P_Aux.Client_EP /= EP then
				P_Aux:=P_Aux.Next;
			else
				Nick:= P_Aux.Nick;
				P_Aux:=P_Aux.Next;	
				Salir := True;	
				
			end if;
		end loop;
		
		if Salir = False then
			raise Client_List_Error;
		end if;
		return Nick;

	end Search_Client;
	


	procedure Send_To_All (List: in Client_List_Type; P_Buffer: access LLU.Buffer_Type; EP_Not_Send: in LLU.End_Point_Type) is
	P_Aux : Cell_A := List.P_First;
	Contador_Clientes:Natural;
	begin

		--Ada.Text_IO.Put_Line("numero clientes" & Integer'Image(List.Number_Clients));
		Contador_Clientes:=Count(List);
		
		for k in 1..Contador_Clientes loop 				--Corre la lista y manda mensaje a los escritores
			
			if P_Aux.Client_EP /= EP_Not_Send then
				LLU.Send(P_Aux.Client_EP, P_Buffer.all'Access);
			end if;
				P_Aux:=P_Aux.Next;
		end loop;
		LLU.Reset (P_Buffer.all);
	end Send_To_All;
	

	
	function Count (List: in Client_List_Type) return Natural is
	begin

		return List.Number_Clients;
	
	end Count;
	
	
	--El procedimiento Update_Client actualizara en la lista la hora almacenada para el cliente cuyo EP recibe como
	--parámetro . Si no encuentra en la lista ese EP, elevara la excepción Client_List_Error.
	
	procedure Update_Client (List: in out Client_List_Type; EP: in LLU.End_Point_Type) is
		Hora_Almacenada:Ada.Calendar.Time;
		P_Aux:Cell_A;
		Salir:Boolean:=False;
	begin
		P_Aux:=List.P_First;
		While P_Aux /= null and Salir=False loop
			if P_Aux.Client_EP = EP then
				Hora_Almacenada := Ada.Calendar.Clock;
				P_Aux.Hora_Del_Cliente:=Hora_Almacenada;
				P_Aux:=P_Aux.Next;
				Salir:=True;
			else 
				P_Aux:=P_Aux.Next;
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
		P_Aux:Cell_A:= List.P_First;
		P_Elem : Cell_A:= null;
		procedure Free is new Ada.Unchecked_Deallocation(Cell, Cell_A);
	begin
		
		--Introduzco en una variable la hora mas antigua para poder compararla despues
		if List.P_First=null then
			raise Client_List_Error;
		end if;
			
		while P_Aux /= null loop	
			
			if P_Aux.Hora_Del_Cliente <  Hora_Mas_Antigua then
				Hora_Mas_Antigua:=P_Aux.Hora_Del_Cliente;
				P_Aux:= P_Aux.Next;
			else
				P_Aux:= P_Aux.Next;
			end if;
		end loop;
	
	
		--Me recorro la lista para encontrar cual tiene el tiempo menor y asi poder eliminarlo
		P_Aux:=List.P_First;
		
		If List.P_First /= null then
			while P_Aux.Hora_Del_Cliente /= Hora_Mas_Antigua and List.P_First /= null loop
				P_Elem:=P_Aux;
				P_Aux:=P_Aux.Next;
			end loop;
			
			if P_Aux = List.P_First and P_Aux.Hora_Del_Cliente = Hora_Mas_Antigua then
				List.P_First:=P_Aux.Next;
				Free(P_Aux);
			else
				P_Elem.Next:=P_Aux.Next;	
				Free(P_Aux);
			end if;	
		end if;
		
		List.Number_Clients:=List.Number_Clients -1;
		
	end Remove_Oldest;
	
	
	
	procedure Delete_Client (List: in out Client_List_Type; Nick: in ASU.Unbounded_String) is
		P_Aux:Cell_A:= List.P_First;
		P_Elem : Cell_A:= null;
		procedure Free is new Ada.Unchecked_Deallocation(Cell, Cell_A);
		
	begin

		If List.P_First /= null then
			while P_Aux.Nick /= Nick and then List.P_First /= null loop
				P_Elem:=P_Aux;
				P_Aux:=P_Aux.Next;
			end loop;
		
			if P_Aux = List.P_First and P_Aux.Nick = Nick then
				List.P_First:=P_Aux.Next;
				Free(P_Aux);
			else
				P_Elem.Next:=P_Aux.Next;
				Free(P_Aux);
			end if;					
		end if;
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
		Texto:=ASU.To_Unbounded_String(LLU.Image(List.P_First.Client_EP));		--LLU_image lo convierto a unbounded_string
		--Ada.Text_IO.Put_Line(ASU.To_String(Texto));		--Cojo todo el LLU
		N:= ASU.Index (Texto,":");					
		R:=ASU.Tail(Texto,ASU.Length(Texto)-N-1);		--En R queda guardado: 127.0.1.1, Port: 50123  	*Nota: La IP y puerto son un ejemplo
		P:=Index(R,",");
		T:=ASU.Head(R,P-1);						--En T queda guardado: 127.0.1.1
		Otra:=Index(R,":");
		Q:=ASU.Tail(R,ASU.Length(R)-Otra-1);			--En Q queda guardado 50123
		
		Ada.Text_IO.Put_Line(ASU.To_String(T)&":"&ASU.To_String(Q)& " " &ASU.To_String(List.P_First.Nick));
		
		return ASU.To_String(Texto);
		
	end List_Image;
			 
end Client_Lists;
--Por Saúl Ibáñez Cerro

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

package body Client_Lists is

	use Ada.Strings.Unbounded;
	use Lower_Layer_UDP;

	procedure Add_Client (List: in out Client_List_Type; EP: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String) is
	P_Aux : Cell_A;
	EstaLaPalabraRepetida:Boolean := False;
	Salir:boolean:=False;

	begin
		if List.P_First = null then
			List.P_First := new Cell'(EP,Nick,null);
			List.Total:=List.Total +1;		
		else
			P_Aux:= List.P_First;
			while EstaLaPalabraRepetida = False and P_Aux.Next/=null loop 
				if P_Aux.Nick = Nick and Nick /= "reader" then 			--and Nick /= "lector"
					--Ada.Text_IO.Put_Line("Entro en Nick repetido");
					EstaLaPalabraRepetida := True;
					raise Client_List_Error;
				else
					--Ada.Text_IO.Put_Line("Entro en Nick no repetido");
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
				--Ada.Text_IO.Put_Line("no repetido");
				List.P_first:= new Cell'(EP, Nick, null);
				List.Total:=List.Total +1;
				List.P_First.Next:=P_Aux;
			end if;

		end if;

		--NOTA: Las siguientes lineas de código puestas como comentario me comprueban que la lista se guarda en orden inverso.
			
		--P_Aux:=List.P_First;
				--while P_Aux/=null loop
					--Ada.Text_IO.Put_Line("El nombre del escritor es   " & ASU.To_String(P_Aux.Nick));
					--P_Aux:=P_Aux.Next;
				--end loop;

	end Add_Client;



	function Search_Client (List: in Client_List_Type; EP: in LLU.End_Point_Type) return ASU.Unbounded_String is
		P_Aux : Cell_A := List.P_First;
		Salir : boolean := False;
		k : Integer := 1;
		Nick:ASU.Unbounded_String;
		Puntero : Client_Lists.Client_List_Type;
	begin
		while P_Aux /= null and Salir = False  loop						
			if P_Aux.Client_EP /= Ep then
				P_Aux:=P_Aux.Next;
			else
				Nick:= P_Aux.Nick;
				Ada.Text_IO.Put("WRITER received from ");
				Ada.Text_IO.Put(ASU.To_String(Nick) & (": "));
				P_Aux:=P_Aux.Next;	
				Salir := True;			
			end if;
		end loop;
		
		if Salir = False then
			raise Client_List_Error;
		end if;
		
		return List.P_First.Nick;

	end Search_Client;
	


	procedure Send_To_Readers (List: in Client_List_Type; P_Buffer: access LLU.Buffer_Type) is
	P_Aux : Cell_A := List.P_First;
	begin
		--Ada.Text_IO.Put_Line("numero clientes" & Integer'Image(List.Number_Clients));
		for k in 1.. List.Total loop 				--Corre la lista viendo si es reader, y si lo es, manda mensaje a los escritores

		--Ada.Text_IO.Put_Line("El nombre del escritor es   " & ASU.To_String(P_Aux.Nick));
			if P_Aux.Nick /= "reader" then
				P_Aux:= P_Aux.Next;
			elsif P_Aux.Nick = "reader" then
				LLU.Send(P_Aux.Client_EP, P_Buffer.all'Access);
				LLU.Reset (P_Buffer.all);
				P_Aux:= P_Aux.Next;
			end if;

		end loop;
	end Send_To_Readers;
	

	
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
		--P_Aux:Cell_A:=null;
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
		--Ada.Text_IO.Put_Line(ASU.To_String(R));
		P:=Index(R,",");
		T:=ASU.Head(R,P-1);						--En T queda guardado: 127.0.1.1
		--Ada.Text_IO.Put_Line(ASU.To_String(T));
		Otra:=Index(R,":");
		Q:=ASU.Tail(R,ASU.Length(R)-Otra-1);			--En Q queda guardado 50123
		--Ada.Text_IO.Put_Line(ASU.To_String(Q));
		--P_Aux:=List.P_First;
		Ada.Text_IO.Put_Line(ASU.To_String(T)&":"&ASU.To_String(Q)& " " &ASU.To_String(List.P_First.Nick));
		
		return ASU.To_String(Texto);
		
	end List_Image;
	
			 
end Client_Lists;
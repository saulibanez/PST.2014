--Programador: Saúl Ibáñez Cerro

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;
with Ada.Unchecked_Deallocation;

package body Word_Lists is
	package ASF renames Ada.Strings.Fixed;
	package ASMC renames Ada.Strings.Maps.Constants;
	use Ada.Strings.Unbounded;


	procedure Add_Word (Word: in ASU.Unbounded_String; P_First: in out Word_List_Type) is
		P_Aux : Word_List_Type := P_First;
		Name : ASU.Unbounded_String;
		EstaLaPalabraRepetida:Boolean := False;
	begin
		--Con la siguiente linea, lo que conseguiremos es pasar las palabras que contengan alguna mayúscula a minúscula.
		Name := ASU.To_Unbounded_String(ASF.Translate( ASU.To_String(Word), ASMC.Lower_Case_Map));
		if P_First = null then
			P_First := new Cell'(Name, 1, null);
		else
			while P_Aux.Next /= null loop
				if P_Aux.Word = Name then		--Este bucle le realizo para que me pueda contar palabras iguales
												--en distintas lineas.
					EstaLaPalabraRepetida := True;
					P_Aux.Count := P_Aux.Count +1;
				end if;
				P_Aux:= P_Aux.Next;
			end loop;
			
			if P_Aux.Word = Name then			--Aqui repito el bucle de arriba para que me pueda imprimir las palabras
												--iguales que existan en la primera linea.
				EstaLaPalabraRepetida := True;
				P_Aux.Count := P_Aux.Count +1;
			end if;
			
			if EstaLaPalabraRepetida = False then
				P_Aux.Next := new Cell'(Name, 1, null);
			end if;
		end if;
		
	end Add_Word;
   
   --Word_List_Error: exception; 
   
   
	procedure Delete_Word (P_First: in out Word_List_Type; Word: in ASU.Unbounded_String) is
		P_Aux : Word_List_Type := P_First;
		P_Elem : Word_List_Type:= null;
		Name : ASU.Unbounded_String;
		EstaLaPalabraRepetida:Boolean := False;
		procedure Free is new Ada.Unchecked_Deallocation(Cell, Word_List_Type);
		
	begin
		Name := ASU.To_Unbounded_String(ASF.Translate( ASU.To_String(Word), ASMC.Lower_Case_Map));

		If P_First /= null then
			while P_Aux.Word /= Name and then P_First /= null loop
				P_Elem:=P_Aux;
				P_Aux:=P_Aux.Next;
			end loop;
		
			if P_Aux = P_First and P_Aux.Word = Name then
				P_First:=P_Aux.Next;
				Free(P_Aux);
			else
				P_Elem.Next:=P_Aux.Next;
				Free(P_Aux);
			end if;					
		end if;
	end Delete_Word;
   
   
   
	procedure Search_Word (P_First: in Word_List_Type; Word: in ASU.Unbounded_String; Count: out Natural) is
		P_Aux : Word_List_Type := P_First;
		Name : ASU.Unbounded_String;
		EstaLaPalabraRepetida:Boolean := False;
	
	begin
		Name := ASU.To_Unbounded_String(ASF.Translate( ASU.To_String(Word), ASMC.Lower_Case_Map));
		if P_Aux /= null then
			while P_Aux.Next /= null loop
				if P_Aux.Word = Name then
					EstaLaPalabraRepetida := True;
					Ada.Text_IO.Put_Line( "|" & ASU.To_String(P_Aux.Word) &  "|" & " - " & Natural'Image(P_Aux.Count));
				end if;
				P_Aux:= P_Aux.Next;
			end loop;
		end if;
		if P_Aux.Next = null and P_Aux.Word = Name then
			Ada.Text_IO.Put_Line( "|" & ASU.To_String(P_Aux.Word) &  "|" & " - " & Natural'Image(P_Aux.Count));
		end if;
	end Search_Word;

   
   
	procedure Max_Word (P_First: in Word_List_Type; Word: out ASU.Unbounded_String; Count: out Natural) is 
		P_Elem : Word_List_Type := P_First;
		P_Aux : Word_List_Type := P_First;
		Esta_Mas_Veces_Repetida:Boolean:=False;
		Maximo:Natural:=0;
		
		begin
		
		if P_Aux /= null then
			--Ada.Text_IO.Put_Line(" ");
			--Ada.Text_IO.Put_Line("Palabra");
			--Ada.Text_IO.Put_Line("--------");
			
			while P_Aux.Next /= null loop
				if P_Aux.Count > P_Elem.Count then
					Word:=P_Aux.Word;
					Maximo:=P_Aux.Count;
					P_Elem:=P_Aux;
				elsif P_Elem.Count >= P_Aux.Count then
					Word:=P_Elem.Word;
					Maximo:=P_Elem.Count;
				end if;
				P_Aux := P_Aux.Next;
			end loop;
			Ada.Text_IO.Put_Line( "|" & ASU.To_String(Word) & "|" & " - " & Natural'Image(Maximo));
		end if;
		
	end Max_Word;
   
   
   
	procedure Print_All (P_First: in Word_List_Type) is
		P_Aux : Word_List_Type := P_First;	
	begin
		if P_Aux /= null then
			Ada.Text_IO.Put_Line(" ");
			Ada.Text_IO.Put_Line("Palabras");
			Ada.Text_IO.Put_Line("--------");
			
			while P_Aux.Next /= null loop
				Ada.Text_IO.Put_Line( "|" & ASU.To_String(P_Aux.Word) &  "|" & " - " & Natural'Image(P_Aux.Count));
				P_Aux := P_Aux.Next;
			end loop;
			Ada.Text_IO.Put_Line( "|" & ASU.To_String(P_Aux.Word) &  "|" & " - " & Natural'Image(P_Aux.Count));
		end if;
	end Print_All;
   
end Word_Lists;

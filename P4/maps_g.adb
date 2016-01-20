with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;


   procedure Put (M : in out Map; Key : Key_Type; Value : Value_Type; Success : out Boolean) is
	P_Aux : Cell_A;
	Found : Boolean;
	P_Elem : Cell_A;
     
   begin
      -- Si ya existe Key, cambiamos su Value
	P_Aux := M.P_First;
	Found := False;
	Success:=False;
	if Map_Length(M)<Max_Length then
      
		while not Found and P_Aux /= null loop
			if P_Aux.Key = Key then
				P_Aux.Value := Value;
				Found := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;

		-- Si no hemos encontrado Key aniadimos al principio
		if not Found then
			--En esta parte hacemos la lista doblemente enlazada, el M.P_First, lo dejo en comentario porque lo tenia asi de f�brica
			P_Elem := new Cell'(Key, Value, M.P_First, null);
			--M.P_First := new Cell'(Key, Value, M.P_First, null);
			if M.P_First = null then
				M.P_First:=P_Elem;
				M.P_Ultimo:=P_Elem;
			else
				P_Elem.Next:=M.P_First;
				M.P_First.Prev := P_Elem;
				M.P_First := P_Elem;
			end if;
				
			M.Length := M.Length + 1;
			Success:=True;
		end if;
	end if;
   end Put;



	procedure Delete (M : in out Map; Key : in  Key_Type; Success : out Boolean) is
		P_Current  : Cell_A;
		P_Previous : Cell_A;
	begin
		Success := False;
		P_Previous := null;
		P_Current  := M.P_First;
		while not Success and P_Current /= null  loop
			if P_Current.Key = Key then
				Success := True;
				M.Length := M.Length - 1;
				if P_Previous /= null then
					P_Previous.Next := P_Current.Next;
					if P_Current.Next /= null then
						P_Current.Next.Prev := P_Previous;
					else
						M.P_Ultimo := P_Previous;
					end if;
				end if;
				if M.P_First = P_Current then
					M.P_First := M.P_First.Next;
				end if;
				Free (P_Current);
			else
				P_Previous := P_Current;
				P_Current := P_Current.Next;
			end if;
		end loop;

	end Delete;


	function Get_Keys ( M:Map) return Keys_Array_Type is
	Key:Keys_Array_Type;
	P_Aux:Map:=M;
	begin
		for k in 1..Map_Length(M) loop
			Key(k) := P_Aux.P_First.Key;
			P_Aux.P_First:=P_Aux.P_First.Next;
		end loop;
			
		return key;
	end Get_Keys;


	function Get_Values ( M:Map) return Values_Array_Type is
	Value:Values_Array_Type;
	P_Aux:Map:=M;
	begin
		for k in 1..Map_Length(M) loop
			Value(k) := P_Aux.P_First.Value;
			P_Aux.P_First:=P_Aux.P_First.Next;
		end loop;
			
		return Value;
	
	end Get_Values;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   procedure Print_Map (M : Map) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;

      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Key_To_String(P_Aux.Key) & " " &
                                 VAlue_To_String(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_Map;

end Maps_G;

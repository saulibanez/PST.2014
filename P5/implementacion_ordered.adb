--Por Saúl Ibáñez
--Este paquete me permitira usar las funciones del paquete ordered_maps_g para poder implementar
	--las tablas de sender_buffering y sender_dest

package body Implementacion_Ordered is

	function Mess_Equal (K1 : Mess_Id_T; K2 : Mess_Id_T) return Boolean is
	begin
		if LLU.Image(K1.EP) = LLU.Image(K2.EP) then
			if k1.Seq = k2.Seq then
				return True;
			end if;
			return False;
		else
			return False;
		end if;
	end Mess_Equal;
	
	
	function Mess_Less (K1 : Mess_Id_T; K2 : Mess_Id_T) return Boolean is
	begin
		if LLU.Image(K1.EP) < LLU.Image(K2.EP) then			
			return True;
		elsif LLU.Image(K1.EP) = LLU.Image(K2.EP) and k1.Seq < k2.Seq then
			return True;
		else
			return False;
		end if;
	end Mess_Less;
	
	
	function Key_To_String (K : Mess_Id_T) return String is
		Texto : ASU.Unbounded_String;
	begin
		Texto := ("EP_H_Creat: " & LLU.Image(K.EP) & ASU.To_Unbounded_String(", Seq: ") & Seq_N_T'Image(k.Seq));
		return ASU.To_String(Texto);
	end Key_To_String;
	
	
	function Destinations (Dest : Destinations_T) return String is
		Destino: ASU.Unbounded_String;
	begin
		for K in 1..10 loop
			if Dest(K).EP /= null then
				Destino:= ASU.To_Unbounded_String("EP: " & LLU.Image(Dest(K).EP) & (", Retries: ") & Integer'Image(Dest(K).Retries));
			end if;
		end loop;
		return ASU.To_String(Destino);
	end Destinations;
	
		
	function Tiempo (Time : Ada.Calendar.Time) return String is
	begin
		return Gnat.Calendar.Time_IO.Image(Time, "%c"); 
	end Tiempo;
	
	
	function Value_To_String (K : Value_T) return String is
		Texto: ASU.Unbounded_String;
	begin
		
		Texto:= ASU.To_Unbounded_String("EP_H_Creat: " & LLU.Image(K.EP_H_Creat) & (", Seq: ") & Seq_N_T'Image(K.Seq_N));
		return ASU.To_String(Texto);
	end Value_To_String;	

end Implementacion_Ordered;

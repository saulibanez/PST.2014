--Por Saúl Ibáñez
--Este paquete me permitira usar las funciones del paquete ordered_maps_g para poder implementar
	--las tablas de sender_buffering y sender_dest

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;

package Implementacion_Ordered is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	use LLU;
	use Ada.Strings.Unbounded;
	
	type Seq_N_T is mod Integer'Last;
	
	type Mess_Id_T is record
		EP : LLU.End_Point_Type;
		Seq : Seq_N_T;
	end record;

	type Destination_T is record
		EP : LLU.End_Point_Type := null;
		Retries : Natural := 0;
	end record;

	type Destinations_T is array (1..10) of Destination_T;

	type Buffer_A_T is access LLU.Buffer_Type;

	type Value_T is record
		EP_H_Creat : LLU.End_Point_Type;
		Seq_N : Seq_N_T;
		P_Buffer : Buffer_A_T;
	end record;
	
	function Mess_Equal (K1 : Mess_Id_T; K2 : Mess_Id_T) return Boolean;
	function Mess_Less (K1 : Mess_Id_T; K2 : Mess_Id_T) return Boolean;
	--Del enunciado: definirse una función que para un Mess_Id_T devuelva un String
	function Key_To_String (K : Mess_Id_T) return String;
	--Del enunciado: para un Destinations_T devuelva un String.
	function Destinations (Dest : Destinations_T) return String;
	--Del enunciado: función que para un Ada.Calendar.Time devuelva un String
	function Tiempo (Time : Ada.Calendar.Time) return String;
	--Del enunciado: para un Value_T devuelva un String.
	function Value_To_String (K : Value_T) return String;
	
	
end Implementacion_Ordered;
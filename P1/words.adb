--Programador: Saúl Ibáñez Cerro

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;
with Word_Lists;

procedure Words is

	package ASU renames Ada.Strings.Unbounded;
	package T_IO renames Ada.Text_IO;
	use type ASU.Unbounded_String;
	package ASF renames Ada.Strings.Fixed;
	package ASMC renames Ada.Strings.Maps.Constants;
	
	type Cell;
   
	type Word_List_Type is access Cell;

	type Cell is record
		Word: ASU.Unbounded_String;
		Count: Natural := 0;
		Next: Word_List_Type;
	end record;

	File : Ada.Text_IO.File_Type;
	Texto:  ASU.Unbounded_String;
	TextoAux: ASU.Unbounded_String;
	ContarLineas: Natural := 0;
	Caracteres: Natural:= 0;
	N : Natural:=0;
	Palabras:Natural:=0;
	PunteroLista: Word_Lists.Word_List_Type;
	OpcionIoL: ASU.Unbounded_String;		--lo voy a utilizar para cuando ejecute el programa tenga el comando -l, -i o ambas

	Usage_Error: exception;
	
	Opcion1: ASU.Unbounded_String;
	Opcion2: ASU.Unbounded_String;
	Opcion3: ASU.Unbounded_String;

	procedure Contemos (Texto: in out ASU.Unbounded_String) is
	begin
		
		N:= ASU.Index (Texto," ");	--este comando no solo me dice si hay o no espacios,
									--sino también en la posición en la que está.
		
		case N is
		
		when 0 =>		--Cuando N sea 0 y en el texto al final no exista ningun espacio, me imprimirá 
						--en pantalla la ultima palabra del texto, y además, le sumaré uno a las palabra.
			if ASU.To_String(Texto) /= "" then		--Al hacer el bucle sabremos si al final acaba con espacio
												--o no, si pusiera /= " " me sumaria a palabra uno mas y
												--aparte me imprimiría en pantalla otro | | que no quiero.
				
				Palabras := Palabras +1;
				Word_Lists.Add_Word(Texto, PunteroLista);
			end if;

		when 1 => 		--Cuando N sea 1 estoy buscando si existen espacios al principio del texto
						--y si existen, habrá que sumar uno a espacios
			TextoAux:=ASU.Tail(Texto, ASU.Length(Texto)-N);		--con Tail, me devuelve tantos
																--caraceteres empezando por el 
																--final como dice su segundo parametro.
			Texto := TextoAux;
			Contemos (Texto);
			
		when others =>	--Los casos restantes seria la palabra con la que empieza el texto, asi como las
							--siguientes además de los espacios que existieran tanto en medio del texto
							--como al final.
			TextoAux:= ASU.Head (Texto,N-1);		--Con Head, me devuelve tantos caracteres empezando
												--desde el principio como dice su parámetro (debería ser la
												--posición de entrada -1).
			Word_Lists.Add_Word(TextoAux, PunteroLista);	
			TextoAux := ASU.Tail(Texto, ASU.Length(Texto)-N);
			Texto := TextoAux;
			Palabras:= Palabras +1;
			Contemos (Texto);	

			
		end case;
		
	end Contemos;
	
	
	procedure Leer_Entrada_Con_IoL (OpcionIoL :  out ASU.Unbounded_String) is	--La entrada del programa llevara
																				-- -l, -i o ambas para su utilización
	begin
		if Ada.Command_Line.Argument(1) /= "-l"  and Ada.Command_Line.Argument(1) /= "-i" then	--./words fi.txt
			OpcionIoL := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Ada.Command_Line.Argument(1));
		elsif (Ada.Command_Line.Argument(1) = "-i" and Ada.Command_Line.Argument(2) = "-l") or (Ada.Command_Line.Argument(1) = "-l" and Ada.Command_Line.Argument(2) = "-i") then
			OpcionIoL := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Ada.Command_Line.Argument(3));
		elsif Ada.Command_Line.Argument(1) = "-l"  then										--./words -l fi.txt
			OpcionIoL := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Ada.Command_Line.Argument(2));		--Con esta linea abrimos fichero
		elsif Ada.Command_Line.Argument(1) = "-i" then
			OpcionIoL := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
			Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Ada.Command_Line.Argument(2));
		else
			raise Constraint_Error;		--raised CONSTRAINT_ERROR : a-comlin.adb:65 explicit raise
		end if;
			
	end Leer_Entrada_Con_IoL;
	
	--if (Ada.Command_Line.Argument_Count < 2)

begin

	Leer_Entrada_Con_IoL(OpcionIoL);

	while not Ada.Text_IO.End_Of_File (File) loop
		Texto := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line(File));
		Caracteres:= Caracteres + ASU.Length(Texto) +1;  		-- Le sumo mas 1 porque el fin de linea es un caracter
		ContarLineas := ContarLineas + 1;
		Contemos (Texto);
	end loop;

	Ada.Text_IO.Close (File);								--Con esta línea cerramos el fichero	
	
	if Ada.Command_Line.Argument(1) /= "-l"  and Ada.Command_Line.Argument(1) /= "-i" then
		Ada.Text_IO.Put("La palabra mas frecuente es: ");
		Word_Lists.Max_Word(PunteroLista, Texto, Palabras);
	
	elsif (Ada.Command_Line.Argument(1) = "-i" and Ada.Command_Line.Argument(2) = "-l") or (Ada.Command_Line.Argument(1) = "-l" and Ada.Command_Line.Argument(2) = "-i") then
		
		Word_Lists.Print_All(PunteroLista);
		Opcion1 := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
		Ada.Text_IO.Put_Line(" ");
		Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
		Ada.Text_IO.Put_Line("1: Add Word");
		Ada.Text_IO.Put_Line("2: Delete Word");
		Ada.Text_IO.Put_Line("3: Search Word");
		Ada.Text_IO.Put_Line("4: Show all Word");
		Ada.Text_IO.Put_Line("5: Quit");
		Ada.Text_IO.Put_Line(" ");
		Ada.Text_IO.Put("Que opcion eliges?: ");
		
		while Opcion2 /= "5" loop
			
			Opcion2:=ASU.To_Unbounded_String(T_IO.Get_Line);
		
			if Opcion2 = "1" then
				Ada.Text_IO.Put("Palabra: " );
				Ada.Text_IO.Open (File, Ada.Text_IO.Append_File, Ada.Command_Line.Argument(3));
				Opcion3 := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Word_Lists.Add_Word(Opcion3, PunteroLista);
				Ada.Text_IO.Put_Line(File, ASU.To_String(Opcion3));
				Ada.Text_IO.Close (File);
				Ada.Text_IO.Put_Line("|" &  ASU.To_String(Opcion3)  & "|" & " Palabra Aniadida");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2="4" then
				Word_Lists.Print_All(PunteroLista);
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2 ="3" then
				Ada.Text_IO.Put("Palabra: " );
				Texto := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line);
				Word_Lists.Search_Word(PunteroLista, Texto, Palabras);
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2 ="2" then		
				Ada.Text_IO.Put("Palabra: " );
				Texto := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line);
				Word_Lists.Delete_Word(PunteroLista, Texto);
				Ada.Text_IO.Put_Line( "|" &  ASU.To_String(Texto)  & "|" &   " Palabra Borrada");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			end if;
		
		end loop;
		
		if Opcion2 = "5" then
			Ada.Text_IO.Put("La Palabra mas repetida es:  ");
			Word_Lists.Max_Word(PunteroLista, Texto, Palabras);
		end if;
	
	elsif Ada.Command_Line.Argument(1) = "-l" then
		Word_Lists.Print_All(PunteroLista);
		Ada.Text_IO.Put("La palabra mas frecuente es: ");
		Word_Lists.Max_Word(PunteroLista, Texto, Palabras);
	elsif Ada.Command_Line.Argument(1) = "-i" then
		
		Opcion1 := ASU.To_Unbounded_String(Ada.Command_Line.Argument(1));
		Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
		Ada.Text_IO.Put_Line("1: Add Word");
		Ada.Text_IO.Put_Line("2: Delete Word");
		Ada.Text_IO.Put_Line("3: Search Word");
		Ada.Text_IO.Put_Line("4: Show all Word");
		Ada.Text_IO.Put_Line("5: Quit");
		Ada.Text_IO.Put_Line(" ");
		Ada.Text_IO.Put("Que opcion eliges?: ");
		
		while Opcion2 /= "5" loop
			
			Opcion2:=ASU.To_Unbounded_String(T_IO.Get_Line);
		
			if Opcion2="4" then
				Word_Lists.Print_All(PunteroLista);
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2 = "1" then
				Ada.Text_IO.Put("Palabra: " );
				Ada.Text_IO.Open (File, Ada.Text_IO.Append_File, Ada.Command_Line.Argument(2));
				Opcion3 := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Word_Lists.Add_Word(Opcion3, PunteroLista);
				Ada.Text_IO.Put_Line(File, ASU.To_String(Opcion3));
				Ada.Text_IO.Close (File);
				Ada.Text_IO.Put_Line("|" &  ASU.To_String(Opcion3)  & "|" & " Palabra Aniadida");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2 ="3" then
				Ada.Text_IO.Put("Palabra: " );
				Texto := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line);
				Word_Lists.Search_Word(PunteroLista, Texto, Palabras);
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			elsif Opcion2 ="2" then		
				Ada.Text_IO.Put("Palabra: " );
				Texto := ASU.To_Unbounded_String (Ada.Text_IO.Get_Line);
				Word_Lists.Delete_Word(PunteroLista, Texto);
				Ada.Text_IO.Put_Line( "|" &  ASU.To_String(Texto)  & "|" &   " Palabra Borrada");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put_Line("Elige una de estas opciones: ");
				Ada.Text_IO.Put_Line("1: Add Word");
				Ada.Text_IO.Put_Line("2: Delete Word");
				Ada.Text_IO.Put_Line("3: Search Word");
				Ada.Text_IO.Put_Line("4: Show all Word");
				Ada.Text_IO.Put_Line("5: Quit");
				Ada.Text_IO.Put_Line(" ");
				Ada.Text_IO.Put("Que opcion eliges?: ");
			end if;
		
		end loop;
		
		if Opcion2 = "5" then
			Ada.Text_IO.Put("La Palabra mas repetida es:  ");
			Word_Lists.Max_Word(PunteroLista, Texto, Palabras);
		end if;
	

	end if;
	
	exception
		when Usage_Error =>
			Ada.Text_IO.Put_Line("Fallos comunes: ");
			Ada.Text_IO.Put_Line("El programa debe continuar con: -i o -l mas el nombre del fichero");
			Ada.Text_IO.Put_Line("La palabra que has escrito no existe en el fichero");
		when Constraint_Error =>
			Ada.Text_IO.Put_Line("Fallos comunes: ");
			Ada.Text_IO.Put_Line("El programa debe continuar con: -i o -l mas el nombre del fichero");
			Ada.Text_IO.Put_Line("La palabra que has escrito no existe en el fichero");
			
end Words;
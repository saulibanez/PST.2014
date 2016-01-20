--Por Saúl Ibáñez Cerro

with Ada.Unchecked_Deallocation;
with Implementacion_Ordered;
with Lower_Layer_UDP;

package Chat_Messages is
	package LLU renames Lower_Layer_UDP;

	type Message_Type is (Init, Reject, Confirm, Writer, Logout, Ack);
	
	P_Buffer_Main: Implementacion_Ordered.Buffer_A_T;
	P_Buffer_Handler: Implementacion_Ordered.Buffer_A_T;
	P_Buffer:  Implementacion_Ordered.Buffer_A_T;
	procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type, Implementacion_Ordered.Buffer_A_T);
	
	--no se donde me falla, pero creo que es porque no tengo un .adb de chat_messages, por lo que creo que deberia ponerlo en implementacion_ordered
	--de momento lo dejo asi, a ver si se me ocurre algo despues, porque si quito todo, me dice que hay "circular unit dependency" con chat_handlers
end Chat_Messages;
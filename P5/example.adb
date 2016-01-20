with Ada.Text_IO;
with Ada.Strings.Unbounded;
with example_handlers;
with Timed_Handlers;
with Ada.Calendar;

procedure Example is
Hora1: Ada.Calendar.Time;
begin
Example_Handlers.H2(Hora1);
end Example;

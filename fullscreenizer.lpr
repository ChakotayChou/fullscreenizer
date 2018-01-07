program fullscreenizer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Fullscreenizer';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.


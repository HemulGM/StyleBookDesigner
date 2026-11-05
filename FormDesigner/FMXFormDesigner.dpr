program FMXFormDesigner;

uses
  System.StartUpCopy,
  FMX.Forms,
  HGM.FormDesigner in 'HGM.FormDesigner.pas' {FormDesigner},
  HGM.FormDocument in 'HGM.FormDocument.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormDesigner, FormDesigner);
  Application.Run;
end.

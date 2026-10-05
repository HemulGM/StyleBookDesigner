unit SBD.ColorDialog;

interface

uses
  System.Classes, System.UITypes;

function ChooseColor(Owner: TComponent; var Color: TAlphaColor): Boolean;

implementation

uses
  System.SysUtils, FMX.Types, FMX.Forms, SBD.Localization, WinUI3.Dialogs;

function ChooseColor(Owner: TComponent; var Color: TAlphaColor): Boolean;
var
  Params: TDialogColorParams;
  Answer: TDialogColorResult;
  ParentForm: TCustomForm;
begin
  if Owner is TCustomForm then
    ParentForm := TCustomForm(Owner)
  else
    ParentForm := Application.MainForm as TCustomForm;
  Params := Default(TDialogColorParams);
  Params.Title := Translate('Выберите цвет и прозрачность');
  Params.Color := Color;
  Params.Alpha := True;
  Params.Buttons := [Translate('Применить'), Translate('Отмена')];
  Params.AccentId := 0;
  Params.DefaultId := 0;
  Params.CanClose := True;
  Params.FrameColor := TColors.Null;
  Answer := TWinUIDialog.Show(ParentForm, Params);
  Result := Answer.Result = 0;
  if Result then
    Color := Answer.Color;
end;

end.


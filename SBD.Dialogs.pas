unit SBD.Dialogs;

interface

uses
  System.Classes, System.UITypes, FMX.Forms, FMX.Graphics, WinUI3.Form;

type
  // Editor windows share the WinUI keyboard focus and theme behaviour.
  TAppDialogForm = class(TWinUIForm)
  protected
    procedure DoOnSettingChange; override;
  end;

procedure ShowAppMessage(Owner: TCustomForm; const Body: string);

function AskAppText(Owner: TCustomForm; const Title, Prompt: string; var Text: string): Boolean;

function ChooseAppFont(Owner: TCustomForm; Font: TFont): Boolean;

implementation

uses
  System.SysUtils, FMX.Types, WinUI3.Dialogs, WinUI3.Frame.Dialog.Font;

procedure TAppDialogForm.DoOnSettingChange;
begin
  SystemBackdropType := TWindowBackdropType.Disable;
  inherited;
  Fill.Kind := TBrushKind.Solid;
  if IsDark then
    Fill.Color := $FF2B2B2B
  else
    Fill.Color := $FFFFFFFF;
  if Owner is TCustomForm then
    StyleBook := TCustomForm(Owner).StyleBook;
end;

procedure ShowAppMessage(Owner: TCustomForm; const Body: string);
begin
  TWinUIDialog.Show(Owner, Application.Title, Body,
    [Translate('Закрыть')], -1, 0, True);
end;

function AskAppText(Owner: TCustomForm; const Title, Prompt: string; var Text: string): Boolean;
var
  Params: TDialogInputParams;
  Answer: TDialogInputResult;
begin
  Params := Default(TDialogInputParams);
  Params.Title := Title;
  Params.InputTitle := Prompt;
  Params.InputText := Text;
  Params.Buttons := [Translate('Применить'), Translate('Отмена')];
  Params.AccentId := 0;
  Params.DefaultId := 0;
  Params.CanClose := True;
  Params.FrameColor := TColors.Null;
  Answer := TWinUIDialog.Show(Owner, Params);
  Result := Answer.Result = 0;
  if Result then
    Text := Answer.Input;
end;

function ChooseAppFont(Owner: TCustomForm; Font: TFont): Boolean;
var
  Params: TDialogFontParams;
  Body: TFrameDialogFont;
  Data: TDialogFramedParams;
begin
  Params := Default(TDialogFontParams);
  Params.Title := Translate('Шрифт');
  Params.Family := Font.Family;
  Params.Size := Font.Size;
  Params.StyleExt := Font.StyleExt;
  Params.Buttons := [Translate('Применить'), Translate('Отмена')];
  Params.AccentId := 0;
  Params.DefaultId := 0;
  Params.CanClose := True;
  Params.FrameColor := TColors.Null;
  Body := TFrameDialogFont.Create(Owner);
  try
    Body.Fill(Params);
    Body.CheckBoxBold.Text := Translate('Полужирный');
    Body.CheckBoxItalic.Text := Translate('Курсив');
    Body.CheckBoxUnderline.Text := Translate('Подчёркнутый');
    Body.CheckBoxStrikeout.Text := Translate('Зачёркнутый');
    Body.LabelFontSize.Text := Translate('Размер');
    Body.Label1.Text := Translate('Начертание');
    Body.Label2.Text := Translate('Семейство');
    Body.Label4.Text := Translate('Образец');
    Body.SearchBoxFont.TextPrompt := Translate('Поиск');
    Data := Default(TDialogFramedParams);
    Data.Title := Params.Title;
    Data.Body := Body;
    Data.Buttons := Params.Buttons;
    Data.AccentId := Params.AccentId;
    Data.DefaultId := Params.DefaultId;
    Data.CanClose := Params.CanClose;
    Data.FrameColor := Params.FrameColor;
    Result := TWinUIDialog.Show(Owner, Data).Result = 0;
    if Result then
    begin
      Font.Family := Body.Family;
      Font.Size := Body.Size;
      Font.StyleExt := Body.StyleExt;
    end;
  finally
    Body.Free;
  end;
end;

end.


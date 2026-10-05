unit SBD.ColorDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Math, FMX.Types, FMX.Controls, FMX.Forms, SBD.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.ListBox, FMX.Grid, FMX.Grid.Style, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Memo, FMX.ScrollBox, FMX.Colors;

type
  TColorEditorForm = class(TAppDialogForm)
    DialogHeader: TLayout;
    DialogTitle: TLabel;
    HelpLabel: TLabel;
    Actions: TPanel;
    CancelButton: TButton;
    ApplyButton: TButton;
    DialogBody: TLayout;
    ColorPanel: TColorPanel;
  public
    constructor Create(AOwner: TComponent); override;
  protected
    procedure Loaded; override;
  end;

function ChooseColor(Owner: TComponent; var Color: TAlphaColor): Boolean;

implementation

uses
  SBD.Main, SBD.PropertyInspector, SBD.Localization, WinUI3.Dialogs;

{$R *.fmx}

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

constructor TColorEditorForm.Create(AOwner: TComponent);
begin
  inherited;
  TranslateForm(Self);
end;

procedure TColorEditorForm.Loaded;
begin
  inherited;
  EnableSmoothScrolling(Self);
end;

end.


unit SBD.TextDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Math, FMX.Types, FMX.Controls, FMX.Forms, SBD.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.ListBox, FMX.Grid, FMX.Grid.Style, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Memo, FMX.ScrollBox, FMX.Colors, FMX.Memo.Types;

type
  TTextEditorForm = class(TAppDialogForm)
    DialogHeader: TLayout;
    DialogTitle: TLabel;
    HelpLabel: TLabel;
    Actions: TPanel;
    CancelButton: TButton;
    ApplyButton: TButton;
    DialogBody: TLayout;
    TextMemo: TMemo;
    WrapOptions: TLayout;
    WordWrapCheck: TCheckBox;
    procedure WordWrapChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  protected
    procedure Loaded; override;
  end;

implementation

uses
  SBD.PropertyInspector, SBD.Localization;

{$R *.fmx}

constructor TTextEditorForm.Create(AOwner: TComponent);
begin
  inherited;
  TranslateForm(Self);
  WordWrapChanged(nil);
end;

procedure TTextEditorForm.WordWrapChanged(Sender: TObject);
begin
  TextMemo.WordWrap := WordWrapCheck.IsChecked;
end;

procedure TTextEditorForm.Loaded;
begin
  inherited;
  EnableSmoothScrolling(Self);
end;

end.


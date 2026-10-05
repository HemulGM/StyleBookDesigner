unit SBD.ValuesDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Math, System.Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  SBD.Dialogs, FMX.Layouts, FMX.StdCtrls, FMX.ListBox, FMX.Grid, FMX.Grid.Style,
  FMX.Dialogs, FMX.Controls.Presentation, FMX.Consts, SBD.Main, FMX.ScrollBox;

type
  TNamedValuesDialog = class(TAppDialogForm)
  published
    DialogHeader: TLayout;
    DialogTitle: TLabel;
    HelpLabel: TLabel;
    Actions: TPanel;
    CollectionTools: TLayout;
    FKind: TComboBox;
    AddButton: TButton;
    DeleteButton: TButton;
    CancelButton: TButton;
    ApplyButton: TButton;
    DialogBody: TLayout;
    ValidationError: TLabel;
    FGrid: TStringGrid;
    NameColumn: TStringColumn;
    KindColumn: TPopupColumn;
    ValueColumn: TStringColumn;
    DarkValueColumn: TStringColumn;
    CountColumn: TStringColumn;
    procedure EditValue(Sender: TObject; const Col, Row: Integer; const Value: TValue);
    procedure ResourceAction(Sender: TObject);
    procedure ValueDblClick(Sender: TObject);
  private
    FEditor: TFormMain;
    FUpdating: Boolean;
    FValues: TObjectList<TNamedStyleValue>;
    FBindings: TObjectList<TStyleValueBinding>;
    function FindValue(const Name: string): TNamedStyleValue;
    procedure UpdateGrid;
  public
    constructor CreateEditor(Editor: TFormMain);
    destructor Destroy; override;
    function IsChanged: Boolean;
    property Values: TObjectList<TNamedStyleValue> read FValues;
    property Bindings: TObjectList<TStyleValueBinding> read FBindings;
  end;

implementation

uses
  SBD.PropertyInspector, SBD.ColorDialog, SBD.Localization;

{$R *.fmx}

function DefaultNamedValue(const Kind: string): string;
begin
  if SameText(Kind, 'Цвет') then
    Result := '#FF247AC4'
  else if SameText(Kind, 'Логическое') then
    Result := 'True'
  else if SameText(Kind, 'Текст') then
    Result := 'Текст'
  else
    Result := '0';
end;

constructor TNamedValuesDialog.CreateEditor(Editor: TFormMain);
begin
  FUpdating := True;
  inherited Create(Editor);
  TranslateForm(Self);
  for var I := 0 to FKind.Items.Count - 1 do
    FKind.Items[I] := Translate(FKind.Items[I]);
  for var I := 0 to KindColumn.Items.Count - 1 do
    KindColumn.Items[I] := Translate(KindColumn.Items[I]);
  EnableSmoothScrolling(Self);
  FEditor := Editor;
  FValues := TObjectList<TNamedStyleValue>.Create;
  FBindings := TObjectList<TStyleValueBinding>.Create;
  for var Source in Editor.NamedValues do
  begin
    var Copy := TNamedStyleValue.Create;
    Copy.Name := Source.Name;
    Copy.Kind := Source.Kind;
    Copy.LightValue := Source.LightValue;
    Copy.DarkValue := Source.DarkValue;
    Copy.Theme := Editor.ResourceTheme;
    FValues.Add(Copy);
  end;
  for var Source in Editor.ValueBindings do
  begin
    var Copy := TStyleValueBinding.Create;
    Copy.TargetName := Source.TargetName;
    Copy.PropertyPath := Source.PropertyPath;
    Copy.ResourceName := Source.ResourceName;
    FBindings.Add(Copy);
  end;
  StyleBook := Editor.StyleBook;
  FGrid.OnSetValue := EditValue;
  FGrid.OnDblClick := ValueDblClick;
  UpdateGrid;
end;

destructor TNamedValuesDialog.Destroy;
begin
  FUpdating := True;
  if FGrid <> nil then
  begin
    FGrid.OnSetValue := nil;
    FGrid.OnDblClick := nil;
  end;
  FValues.Free;
  FBindings.Free;
  inherited;
end;

function TNamedValuesDialog.FindValue(const Name: string): TNamedStyleValue;
begin
  Result := nil;
  for var Value in FValues do
    if SameText(Value.Name, Name) then
      Exit(Value);
end;

function TNamedValuesDialog.IsChanged: Boolean;
begin
  Result := True;
  if (FValues.Count <> FEditor.NamedValues.Count) or (FBindings.Count <> FEditor.ValueBindings.Count) then
    Exit;
  for var I := 0 to FValues.Count - 1 do
    if (FValues[I].Name <> FEditor.NamedValues[I].Name) or
      (FValues[I].Kind <> FEditor.NamedValues[I].Kind) or
      (FValues[I].LightValue <> FEditor.NamedValues[I].LightValue) or
      (FValues[I].DarkValue <> FEditor.NamedValues[I].DarkValue) then
      Exit;
  for var I := 0 to FBindings.Count - 1 do
    if (FBindings[I].TargetName <> FEditor.ValueBindings[I].TargetName) or
      (FBindings[I].PropertyPath <> FEditor.ValueBindings[I].PropertyPath) or
      (FBindings[I].ResourceName <> FEditor.ValueBindings[I].ResourceName) then
      Exit;
  Result := False;
end;

procedure TNamedValuesDialog.UpdateGrid;
var
  I, Count: Integer;
  Value: TNamedStyleValue;
begin
  FUpdating := True;
  try
    FGrid.RowCount := FValues.Count;
    for I := 0 to FValues.Count - 1 do
    begin
      Value := FValues[I];
      FGrid.Cells[0, I] := Value.Name;
      FGrid.Cells[1, I] := Translate(Value.Kind);
      FGrid.Cells[2, I] := Value.LightValue;
      FGrid.Cells[3, I] := Value.DarkValue;
      Count := 0;
      for var Binding in FBindings do
        if SameText(Binding.ResourceName, Value.Name) then
          Inc(Count);
      FGrid.Cells[4, I] := Count.ToString;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TNamedValuesDialog.EditValue(Sender: TObject; const Col, Row: Integer; const Value: TValue);
var
  Candidate: TNamedStyleValue;
  Resource: TNamedStyleValue;
begin
  if FUpdating or (Col > 3) or (Row < 0) or (Row >= FValues.Count) then
    Exit;
  ValidationError.Visible := False;
  ValidationError.Text := '';
  Resource := FValues[Row];
  Candidate := TNamedStyleValue.Create;
  try
    Candidate.Name := Resource.Name;
    Candidate.Kind := Resource.Kind;
    Candidate.LightValue := Resource.LightValue;
    Candidate.DarkValue := Resource.DarkValue;
    Candidate.Theme := FEditor.ResourceTheme;
    case Col of
      0:
        Candidate.Name := Trim(Value.ToString);
      1:
        begin
          Candidate.Kind := CanonicalValueKind(Value.ToString);
          Candidate.LightValue := DefaultNamedValue(Candidate.Kind);
          Candidate.DarkValue := Candidate.LightValue;
        end;
      2:
        Candidate.LightValue := Value.ToString;
      3:
        Candidate.DarkValue := Value.ToString;
    end;
    try
      FEditor.ValidateNamedValue(Candidate);
      for var Other in FValues do
        if (Other <> Resource) and SameText(Other.Name, Candidate.Name) then
          raise Exception.Create(Translate('Ресурс с таким именем уже существует.'));
      for var Binding in FBindings do
        if SameText(Binding.ResourceName, Resource.Name) then
          FEditor.ValidateBinding(Candidate, Binding);
      for var Binding in FBindings do
        if SameText(Binding.ResourceName, Resource.Name) then
          Binding.ResourceName := Candidate.Name;
      Resource.Name := Candidate.Name;
      Resource.Kind := Candidate.Kind;
      Resource.LightValue := Candidate.LightValue;
      Resource.DarkValue := Candidate.DarkValue;
    except
      on E: Exception do
      begin
        ValidationError.Text := E.Message;
        ValidationError.Visible := True;
      end;
    end;
  finally
    Candidate.Free;
  end;
  UpdateGrid;
end;

procedure TNamedValuesDialog.ResourceAction(Sender: TObject);
var
  Resource: TNamedStyleValue;
  Index: Integer;
  Name: string;
begin
  case TComponent(Sender).Tag of
    1:
      begin
        Index := 1;
        repeat
          Name := 'Resource' + Index.ToString;
          Inc(Index);
        until FindValue(Name) = nil;
        Resource := TNamedStyleValue.Create;
        Resource.Name := Name;
        Resource.Kind := CanonicalValueKind(FKind.Items[FKind.ItemIndex]);
        Resource.Value := DefaultNamedValue(Resource.Kind);
        Resource.Theme := FEditor.ResourceTheme;
        FValues.Add(Resource);
      end;
    2:
      if (FGrid.Selected >= 0) and (FGrid.Selected < FValues.Count) then
      begin
        Resource := FValues[FGrid.Selected];
        for var I := FBindings.Count - 1 downto 0 do
          if SameText(FBindings[I].ResourceName, Resource.Name) then
            FBindings.Delete(I);
        FValues.Delete(FGrid.Selected);
      end;
  end;
  UpdateGrid;
end;

procedure TNamedValuesDialog.ValueDblClick(Sender: TObject);
var
  Color: TAlphaColor;
begin
  if (FGrid.Selected < 0) or (FGrid.Selected >= FValues.Count) then
    Exit;
  var Resource := FValues[FGrid.Selected];
  if not SameText(Resource.Kind, 'Цвет') then
    Exit;
  var Column := FGrid.ColumnIndex;
  if not (Column in [2, 3]) then
    Exit;
  var Text := Resource.LightValue;
  if Column = 3 then
    Text := Resource.DarkValue;
  Color := TAlphaColor(StrToInt64(Text.Replace('#', '$')));
  if ChooseColor(Self, Color) then
    EditValue(Self, Column, FGrid.Selected, TValue.From<string>('#' + IntToHex(Color, 8)));
end;

end.


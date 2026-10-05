unit SBD.GradientDialog;

interface

uses
  System.Classes, System.Types, System.UITypes, FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Graphics, FMX.Layouts, FMX.StdCtrls, FMX.ListBox, FMX.Edit,
  FMX.Controls.Presentation, FMX.Objects, FMX.SpinBox, FMX.ScrollBox,
  SBD.Dialogs, FMX.EditBox;

type
  TGradientEditorForm = class(TAppDialogForm)
    DialogHeader: TLayout;
    DialogTitle: TLabel;
    HelpLabel: TLabel;
    DialogBody: TVertScrollBox;
    BodyContent: TLayout;
    PreviewRow: TLayout;
    Preview: TPaintBox;
    Geometry: TLayout;
    TypeLabel: TLabel;
    TypeCombo: TComboBox;
    AngleLabel: TLabel;
    AngleDial: TArcDial;
    AngleEdit: TSpinBox;
    AngleHelp: TLabel;
    CenterXLabel: TLabel;
    CenterYLabel: TLabel;
    CenterXEdit: TSpinBox;
    CenterYEdit: TSpinBox;
    PointsTitle: TLabel;
    PointsRow: TLayout;
    PointList: TListBox;
    PointTools: TLayout;
    OffsetLabel: TLabel;
    OffsetEdit: TSpinBox;
    ColorButton: TButton;
    AddButton: TButton;
    DeleteButton: TButton;
    ReverseButton: TButton;
    ValidationError: TLabel;
    Actions: TPanel;
    CancelButton: TButton;
    ApplyButton: TButton;
    procedure PreviewPaint(Sender: TObject; Canvas: TCanvas);
    procedure GeometryResize(Sender: TObject);
    procedure TypeChanged(Sender: TObject);
    procedure AngleChanged(Sender: TObject);
    procedure CenterChanged(Sender: TObject);
    procedure PointSelected(Sender: TObject);
    procedure OffsetChanged(Sender: TObject);
    procedure ColorClick(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure ReverseClick(Sender: TObject);
  private
    FValue: TGradient;
    FUpdating: Boolean;
    function SelectedPoint: TGradientPoint;
    procedure UpdatePreview;
    procedure RebuildPoints(Selected: TGradientPoint = nil);
    procedure LoadControls;
    procedure PointItemStyle(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEditor(AOwner: TComponent; Source: TGradient);
    destructor Destroy; override;
    procedure SetAngle(const Degrees: Single);
    function AddPoint(const Offset: Single): TGradientPoint;
    procedure DeletePoint;
    procedure ReversePoints;
    property Value: TGradient read FValue;
  end;

// FMX Assign omits inactive geometry and the radial rotation angle.
procedure CopyGradient(Target, Source: TGradient);

function SameGradient(Left, Right: TGradient): Boolean;

implementation

uses
  System.SysUtils, System.Math, SBD.Localization, SBD.ColorDialog;

{$R *.fmx}

type
  TTransformAccess = class(TTransform);

procedure CopyGradient(Target, Source: TGradient);
begin
  if Target = Source then
    Exit;
  Target.Assign(Source);
  Target.StartPosition.Assign(Source.StartPosition);
  Target.StopPosition.Assign(Source.StopPosition);
  Target.RadialTransform.Assign(Source.RadialTransform);
  Target.RadialTransform.RotationAngle := Source.RadialTransform.RotationAngle;
end;

function SameGradient(Left, Right: TGradient): Boolean;

  function SamePosition(A, B: TPosition): Boolean;
  begin
    Result := SameValue(A.X, B.X, 0.000001) and SameValue(A.Y, B.Y, 0.000001);
  end;

begin
  Result := False;
  if (Left.Style <> Right.Style) or (Left.Points.Count <> Right.Points.Count) then
    Exit;
  for var I := 0 to Left.Points.Count - 1 do
    if (Left.Points[I].Color <> Right.Points[I].Color) or
      not SameValue(Left.Points[I].Offset, Right.Points[I].Offset, 0.000001) then
      Exit;
  Result := SamePosition(Left.StartPosition, Right.StartPosition) and
    SamePosition(Left.StopPosition, Right.StopPosition) and
    SamePosition(Left.RadialTransform.Position, Right.RadialTransform.Position) and
    SamePosition(Left.RadialTransform.Scale, Right.RadialTransform.Scale) and
    SamePosition(Left.RadialTransform.RotationCenter, Right.RadialTransform.RotationCenter) and
    SamePosition(TTransformAccess(Left.RadialTransform).Skew, TTransformAccess(Right.RadialTransform).Skew) and
    SameValue(Left.RadialTransform.RotationAngle, Right.RadialTransform.RotationAngle, 0.000001);
end;

constructor TGradientEditorForm.Create(AOwner: TComponent);
begin
  inherited;
  FValue := TGradient.Create;
  TranslateForm(Self);
  if AOwner is TCustomForm then
    StyleBook := TCustomForm(AOwner).StyleBook;
  LoadControls;
end;

constructor TGradientEditorForm.CreateEditor(AOwner: TComponent; Source: TGradient);
begin
  Create(AOwner);
  CopyGradient(FValue, Source);
  LoadControls;
end;

destructor TGradientEditorForm.Destroy;
begin
  FreeAndNil(FValue);
  inherited;
end;

procedure TGradientEditorForm.LoadControls;
begin
  GeometryResize(nil);
  FUpdating := True;
  try
    TypeCombo.ItemIndex := Ord(FValue.Style);
    AngleDial.Value := RadToDeg(ArcTan2(-(FValue.StopPosition.Y - FValue.StartPosition.Y),
        FValue.StopPosition.X - FValue.StartPosition.X));
    AngleEdit.Value := AngleDial.Value;
    CenterXEdit.Value := FValue.RadialTransform.RotationCenter.X * 100;
    CenterYEdit.Value := FValue.RadialTransform.RotationCenter.Y * 100;
  finally
    FUpdating := False;
  end;
  RebuildPoints;
  UpdatePreview;
end;

procedure TGradientEditorForm.GeometryResize(Sender: TObject);
begin
  if Preview <> nil then
    Preview.Width := Max(128, Min(224, PreviewRow.Width - 448));
end;

function TGradientEditorForm.SelectedPoint: TGradientPoint;
begin
  Result := nil;
  if PointList.Selected <> nil then
    Result := TGradientPoint(PointList.Selected.TagObject);
end;

procedure TGradientEditorForm.RebuildPoints(Selected: TGradientPoint);
var
  Item: TListBoxItem;
  Swatch: TRectangle;
begin
  FUpdating := True;
  PointList.BeginUpdate;
  try
    PointList.Clear;
    for var I := 0 to FValue.Points.Count - 1 do
    begin
      Item := TListBoxItem.Create(PointList);
      Item.TagObject := FValue.Points[I];
      Item.Text := Format('%.1f%%   #%s', [FValue.Points[I].Offset * 100,
          IntToHex(FValue.Points[I].Color, 8)]);
      Item.Height := 36;
      Item.TextSettings.HorzAlign := TTextAlign.Leading;
      Item.OnApplyStyleLookup := PointItemStyle;
      PointList.AddObject(Item);
      Swatch := TRectangle.Create(Item);
      Swatch.Parent := Item;
      Swatch.SetBounds(8, 8, 24, 20);
      Swatch.Fill.Color := FValue.Points[I].Color;
      Swatch.Stroke.Color := $FF808080;
      Swatch.HitTest := False;
      if FValue.Points[I] = Selected then
        PointList.ItemIndex := I;
    end;
    if (PointList.ItemIndex < 0) and (PointList.Count > 0) then
      PointList.ItemIndex := 0;
  finally
    PointList.EndUpdate;
    FUpdating := False;
  end;
  PointSelected(nil);
  UpdatePreview;
end;

procedure TGradientEditorForm.PointItemStyle(Sender: TObject);
begin
  var Text := TListBoxItem(Sender).FindStyleResource('text');
  if Text is TText then
    TText(Text).Margins.Left := 40;
end;

procedure TGradientEditorForm.PointSelected(Sender: TObject);
var
  Point: TGradientPoint;
begin
  if FUpdating or (FValue = nil) then
    Exit;
  Point := SelectedPoint;
  FUpdating := True;
  try
    OffsetEdit.Enabled := Point <> nil;
    ColorButton.Enabled := Point <> nil;
    DeleteButton.Enabled := (Point <> nil) and (FValue.Points.Count > 2);
    if Point <> nil then
    begin
      OffsetEdit.Value := Point.Offset * 100;
      ColorButton.Text := Translate('Цвет') + '  #' + IntToHex(Point.Color, 8);
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TGradientEditorForm.UpdatePreview;
var
  Linear: Boolean;
begin
  Linear := FValue.Style = TGradientStyle.Linear;
  AngleDial.Enabled := Linear;
  AngleEdit.Enabled := Linear;
  CenterXEdit.Enabled := not Linear;
  CenterYEdit.Enabled := not Linear;
  ValidationError.Text := '';
  if FValue.Points.Count < 2 then
    ValidationError.Text := Translate('Добавьте как минимум две цветовые точки')
  else if Linear and (FValue.StartPosition.Point.Distance(FValue.StopPosition.Point) < 0.000001) then
    ValidationError.Text := Translate('Выберите угол, чтобы задать направление градиента');
  ApplyButton.Enabled := ValidationError.Text.IsEmpty;
  Preview.Repaint;
end;

procedure TGradientEditorForm.SetAngle(const Degrees: Single);
var
  DX, DY, Factor: Single;
begin
  // TArcDial uses counterclockwise degrees; FMX coordinates grow downward.
  DX := Cos(DegToRad(Degrees));
  DY := -Sin(DegToRad(Degrees));
  Factor := 0.5 / Max(Abs(DX), Abs(DY));
  FValue.StartPosition.Point := PointF(0.5 - DX * Factor, 0.5 - DY * Factor);
  FValue.StopPosition.Point := PointF(0.5 + DX * Factor, 0.5 + DY * Factor);
  FUpdating := True;
  try
    AngleDial.Value := Degrees;
    AngleEdit.Value := AngleDial.Value;
  finally
    FUpdating := False;
  end;
  UpdatePreview;
end;

procedure TGradientEditorForm.AngleChanged(Sender: TObject);
begin
  if FUpdating or (FValue = nil) then
    Exit;
  if Sender = AngleDial then
    SetAngle(AngleDial.Value)
  else
    SetAngle(AngleEdit.Value);
end;

procedure TGradientEditorForm.TypeChanged(Sender: TObject);
begin
  if FUpdating or (FValue = nil) or (TypeCombo.ItemIndex < 0) then
    Exit;
  FValue.Style := TGradientStyle(TypeCombo.ItemIndex);
  UpdatePreview;
end;

procedure TGradientEditorForm.CenterChanged(Sender: TObject);
begin
  if FUpdating or (FValue = nil) then
    Exit;
  FValue.RadialTransform.RotationCenter.Point := PointF(CenterXEdit.Value / 100, CenterYEdit.Value / 100);
  UpdatePreview;
end;

procedure TGradientEditorForm.OffsetChanged(Sender: TObject);
var
  Point: TGradientPoint;
begin
  if FUpdating or (FValue = nil) then
    Exit;
  Point := SelectedPoint;
  if Point = nil then
    Exit;
  // Changing Offset sorts the FMX collection. Keep selection by identity.
  Point.Offset := OffsetEdit.Value / 100;
  RebuildPoints(Point);
end;

procedure TGradientEditorForm.ColorClick(Sender: TObject);
var
  Point: TGradientPoint;
  Color: TAlphaColor;
begin
  Point := SelectedPoint;
  if Point = nil then
    Exit;
  Color := Point.Color;
  if ChooseColor(Self, Color) then
  begin
    Point.Color := Color;
    RebuildPoints(Point);
  end;
end;

function TGradientEditorForm.AddPoint(const Offset: Single): TGradientPoint;
var
  Color: TAlphaColor;
begin
  if FValue.Points.Count = 0 then
    Color := TAlphaColors.Black
  else if FValue.Points.Count = 1 then
    Color := FValue.Points[0].Color
  else
    Color := FValue.InterpolateColor(EnsureRange(Offset, 0, 1));
  Result := TGradientPoint(FValue.Points.Add);
  Result.Color := Color;
  Result.Offset := EnsureRange(Offset, 0, 1);
  RebuildPoints(Result);
end;

procedure TGradientEditorForm.AddClick(Sender: TObject);
var
  Point: TGradientPoint;
  Offset: Single;
begin
  Point := SelectedPoint;
  Offset := 0.5;
  if Point <> nil then
    if Point.Index < FValue.Points.Count - 1 then
      Offset := (Point.Offset + FValue.Points[Point.Index + 1].Offset) / 2
    else if Point.Offset < 1 then
      Offset := (Point.Offset + 1) / 2
    else if FValue.Points.Count > 1 then
      Offset := (FValue.Points[Point.Index - 1].Offset + Point.Offset) / 2
    else
      Offset := 0;
  AddPoint(Offset);
end;

procedure TGradientEditorForm.DeletePoint;
begin
  if (SelectedPoint = nil) or (FValue.Points.Count <= 2) then
    Exit;
  SelectedPoint.Free;
  RebuildPoints;
end;

procedure TGradientEditorForm.DeleteClick(Sender: TObject);
begin
  DeletePoint;
end;

procedure TGradientEditorForm.ReversePoints;
var
  Points: TArray<TGradientPoint>;
  Selected: TGradientPoint;
begin
  Selected := SelectedPoint;
  SetLength(Points, FValue.Points.Count);
  for var I := 0 to High(Points) do
    Points[I] := FValue.Points[I];
  for var Point in Points do
    Point.Offset := 1 - Point.Offset;
  RebuildPoints(Selected);
end;

procedure TGradientEditorForm.ReverseClick(Sender: TObject);
begin
  ReversePoints;
end;

procedure TGradientEditorForm.PreviewPaint(Sender: TObject; Canvas: TCanvas);
var
  State: TCanvasSaveState;
  R: TRectF;
  Side: Single;
begin
  if (FValue = nil) or (Preview.Width <= 0) or (Preview.Height <= 0) then
    Exit;
  Side := Min(Preview.Width, Preview.Height);
  R := RectF((Preview.Width - Side) / 2, 0, (Preview.Width + Side) / 2, Side);
  State := Canvas.SaveState;
  try
    Canvas.Fill.Kind := TBrushKind.Solid;
    for var Y := 0 to Ceil(Side / 12) - 1 do
      for var X := 0 to Ceil(Side / 12) - 1 do
      begin
        if Odd(X + Y) then
          Canvas.Fill.Color := $FFCFCFCF
        else
          Canvas.Fill.Color := $FFFFFFFF;
        Canvas.FillRect(RectF(R.Left + X * 12, Y * 12,
            Min(R.Right, R.Left + (X + 1) * 12), Min(Side, (Y + 1) * 12)), 0, 0, [], 1);
      end;
    if ApplyButton.Enabled then
    begin
      Canvas.Fill.Kind := TBrushKind.Gradient;
      CopyGradient(Canvas.Fill.Gradient, FValue);
      Canvas.FillRect(R, 0, 0, [], 1);
    end;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $FF808080;
    Canvas.DrawRect(R, 0, 0, [], 1);
  finally
    Canvas.RestoreState(State);
  end;
end;

end.


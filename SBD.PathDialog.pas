unit SBD.PathDialog;

interface

uses
  System.Classes, System.Types, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Layouts, FMX.StdCtrls, FMX.Memo, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Controls.Presentation, FMX.Objects, SBD.Dialogs;

type
  TPathEditorForm = class(TAppDialogForm)
    LayoutHeader: TLayout;
    LabelTitle: TLabel;
    LabelHelp: TLabel;
    LayoutBody: TLayout;
    LayoutPreview: TLayout;
    LabelPreview: TLabel;
    PaintBoxPreview: TPaintBox;
    MemoData: TMemo;
    LabelValidation: TLabel;
    PanelActions: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    procedure DataChanged(Sender: TObject);
    procedure PreviewPaint(Sender: TObject; Canvas: TCanvas);
    procedure ApplyClick(Sender: TObject);
  private
    FValue: TPathData;
    FValid: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEditor(AOwner: TComponent; Source: TPathData);
    destructor Destroy; override;
    property Value: TPathData read FValue;
    property Valid: Boolean read FValid;
  end;

// Strict SVG command reader: FMX accepts incomplete commands and junk.
// Destination is changed only after the complete path has passed validation.
function TryParsePathData(const Text: string; Destination: TPathData;
  out Error: string): Boolean;

implementation

uses
  System.SysUtils, System.Math, System.UITypes, System.Generics.Collections, SBD.Localization;

{$R *.fmx}

function CheckedPoint(X, Y: Double): TPointF;
begin
  if IsNan(X) or IsInfinite(X) or IsNan(Y) or IsInfinite(Y) or
    (Abs(X) > 1E12) or (Abs(Y) > 1E12) then
    raise EConvertError.Create(Translate('Координаты контура вне допустимого диапазона.'));
  Result := PointF(X, Y);
end;

// Use double precision and bounded subdivision. FMX's single precision SVG arc
// conversion can produce NaN and enter an unbounded loop for extreme radii.
procedure AppendSvgArc(Path: TPathData; RadiusX, RadiusY, Degrees: Double;
  LargeArc, Sweep: Boolean; const Endpoint: TPointF);
var
  Startpoint, CP1, CP2, Finish: TPointF;
  RX, RY, CosPhi, SinPhi, DX, DY, X, Y, U, V, Den, Factor: Double;
  CX, CY, UX, UY, VX, VY, Angle, Delta, Step, K: Double;
  X0, Y0, X1, Y1, D0X, D0Y, D1X, D1Y: Double;
  Segments: Integer;

  procedure Sample(T: Double; out PX, PY, TX, TY: Double);
  var
    C, S: Double;
  begin
    C := Cos(T);
    S := Sin(T);
    PX := CX + RX * C * CosPhi - RY * S * SinPhi;
    PY := CY + RX * C * SinPhi + RY * S * CosPhi;
    TX := -RX * S * CosPhi - RY * C * SinPhi;
    TY := -RX * S * SinPhi + RY * C * CosPhi;
  end;

begin
  Startpoint := Path.LastPoint;
  if Startpoint = Endpoint then
    Exit;
  RX := Abs(RadiusX);
  RY := Abs(RadiusY);
  if (RX = 0) or (RY = 0) then
  begin
    Path.LineTo(Endpoint);
    Exit;
  end;
  SinPhi := Sin(DegToRad(Degrees));
  CosPhi := Cos(DegToRad(Degrees));
  DX := (Double(Startpoint.X) - Endpoint.X) / 2;
  DY := (Double(Startpoint.Y) - Endpoint.Y) / 2;
  X := CosPhi * DX + SinPhi * DY;
  Y := -SinPhi * DX + CosPhi * DY;
  U := X / RX;
  V := Y / RY;
  Den := U * U + V * V;
  if Den > 1 then
  begin
    Factor := Sqrt(Den);
    RX := RX * Factor;
    RY := RY * Factor;
    U := X / RX;
    V := Y / RY;
    Den := U * U + V * V;
  end;
  if (Den <= 0) or IsNan(Den) or IsInfinite(Den) or
    (RX > 1E12) or (RY > 1E12) then
    raise EConvertError.Create(Translate('Координаты контура вне допустимого диапазона.'));
  Factor := Sqrt(Max(0.0, (1 - Den) / Den));
  if LargeArc = Sweep then
    Factor := -Factor;
  CX := Factor * RX * V;
  CY := -Factor * RY * U;
  UX := (X - CX) / RX;
  UY := (Y - CY) / RY;
  VX := (-X - CX) / RX;
  VY := (-Y - CY) / RY;
  Angle := ArcTan2(UY, UX);
  Delta := ArcTan2(UX * VY - UY * VX, UX * VX + UY * VY);
  X := CX;
  Y := CY;
  CX := CosPhi * X - SinPhi * Y + (Double(Startpoint.X) + Endpoint.X) / 2;
  CY := SinPhi * X + CosPhi * Y + (Double(Startpoint.Y) + Endpoint.Y) / 2;
  if Sweep and (Delta < 0) then
    Delta := Delta + 2 * Pi
  else if not Sweep and (Delta > 0) then
    Delta := Delta - 2 * Pi;
  if IsNan(Angle) or IsInfinite(Angle) or IsNan(Delta) or IsInfinite(Delta) then
    raise EConvertError.Create(Translate('Координаты контура вне допустимого диапазона.'));
  Segments := EnsureRange(Ceil(Abs(Delta) / (Pi / 2)), 1, 4);
  Step := Delta / Segments;
  K := 4 / 3 * Tan(Step / 4);
  for var I := 0 to Segments - 1 do
  begin
    Sample(Angle, X0, Y0, D0X, D0Y);
    Angle := Angle + Step;
    Sample(Angle, X1, Y1, D1X, D1Y);
    CP1 := CheckedPoint(X0 + K * D0X, Y0 + K * D0Y);
    CP2 := CheckedPoint(X1 - K * D1X, Y1 - K * D1Y);
    if I = Segments - 1 then
      Finish := Endpoint
    else
      Finish := CheckedPoint(X1, Y1);
    Path.CurveTo(CP1, CP2, Finish);
  end;
end;

function TryParsePathData(const Text: string; Destination: TPathData;
  out Error: string): Boolean;
const
  MaxTextLength = 262144;
  MaxGroups = 16384;
  MaxCoordinate = 1E9;
var
  Pos, Start, Digits, Arity, Groups: Integer;
  Command, Previous: Char;
  First, HasCommand: Boolean;
  Numbers: array[0..6] of Double;
  Origin, LastCubic, LastQuadratic, Control, Finish: TPointF;
  Candidate: TPathData;

  procedure Invalid;
  begin
    raise EConvertError.CreateFmt(Translate('Некорректные данные контура (позиция %d).'), [Pos]);
  end;

  procedure SkipSpace;
  begin
    while (Pos <= Length(Text)) and CharInSet(Text[Pos], [#9, #10, #13, ' ']) do
      Inc(Pos);
  end;

  function ReadNumber(AllowComma, Flag: Boolean): Double;
  begin
    SkipSpace;
    if (Pos <= Length(Text)) and (Text[Pos] = ',') then
    begin
      if not AllowComma then
        Invalid;
      Inc(Pos);
      SkipSpace;
    end;
    if Pos > Length(Text) then
      Invalid;
    Start := Pos;
    if Flag then
    begin
      if not CharInSet(Text[Pos], ['0', '1']) then
        Invalid;
      Result := Ord(Text[Pos]) - Ord('0');
      Inc(Pos);
      Exit;
    end;
    if CharInSet(Text[Pos], ['+', '-']) then
      Inc(Pos);
    Digits := 0;
    while (Pos <= Length(Text)) and CharInSet(Text[Pos], ['0'..'9']) do
    begin
      Inc(Pos);
      Inc(Digits);
    end;
    if (Pos <= Length(Text)) and (Text[Pos] = '.') then
    begin
      Inc(Pos);
      while (Pos <= Length(Text)) and CharInSet(Text[Pos], ['0'..'9']) do
      begin
        Inc(Pos);
        Inc(Digits);
      end;
    end;
    if Digits = 0 then
      Invalid;
    if (Pos <= Length(Text)) and CharInSet(Text[Pos], ['e', 'E']) then
    begin
      Inc(Pos);
      if (Pos <= Length(Text)) and CharInSet(Text[Pos], ['+', '-']) then
        Inc(Pos);
      Digits := 0;
      while (Pos <= Length(Text)) and CharInSet(Text[Pos], ['0'..'9']) do
      begin
        Inc(Pos);
        Inc(Digits);
      end;
      if Digits = 0 then
        Invalid;
    end;
    if not TryStrToFloat(Copy(Text, Start, Pos - Start), Result, TFormatSettings.Invariant) then
      Invalid;
    if IsNan(Result) or IsInfinite(Result) or (Abs(Result) > MaxCoordinate) or
      ((Result <> 0) and (Abs(Result) < 1E-30)) then
      Invalid;
  end;

  function ReadPoint(Index: Integer): TPointF;
  var
    X, Y: Double;
  begin
    X := Numbers[Index];
    Y := Numbers[Index + 1];
    if Command <> UpCase(Command) then
    begin
      X := X + Origin.X;
      Y := Y + Origin.Y;
    end;
    Result := CheckedPoint(X, Y);
  end;

begin
  Result := False;
  Error := '';
  Candidate := TPathData.Create;
  try
    try
      if Length(Text) > MaxTextLength then
        raise EConvertError.Create(Translate('Слишком большой контур (максимум 256 КБ текста).'));
      Pos := 1;
      Groups := 0;
      Command := #0;
      Previous := #0;
      LastCubic := TPointF.Zero;
      LastQuadratic := TPointF.Zero;
      First := True;
      SkipSpace;
      while Pos <= Length(Text) do
      begin
        HasCommand := CharInSet(Text[Pos], ['A'..'Z', 'a'..'z']);
        if HasCommand then
        begin
          Command := Text[Pos];
          Inc(Pos);
        end;
        if First and not CharInSet(Command, ['M', 'm']) then
          Invalid;
        First := False;
        case UpCase(Command) of
          'M', 'L', 'T': Arity := 2;
          'H', 'V': Arity := 1;
          'S', 'Q': Arity := 4;
          'C': Arity := 6;
          'A': Arity := 7;
          'Z': Arity := 0;
        else
          Invalid;
          Arity := 0;
        end;
        Inc(Groups);
        if Groups > MaxGroups then
          raise EConvertError.Create(Translate('Слишком много команд контура.'));
        if Arity = 0 then
        begin
          Candidate.ClosePath;
          Previous := 'Z';
          Command := #0;
        end
        else
        begin
          for var I := 0 to Arity - 1 do
            Numbers[I] := ReadNumber((I > 0) or not HasCommand,
              (UpCase(Command) = 'A') and (I in [3, 4]));
          Origin := Candidate.LastPoint;
          case UpCase(Command) of
            'M': Candidate.MoveTo(ReadPoint(0));
            'L': Candidate.LineTo(ReadPoint(0));
            'H':
              if Command = 'H' then
                Candidate.LineTo(CheckedPoint(Numbers[0], Origin.Y))
              else
                Candidate.LineTo(CheckedPoint(Numbers[0] + Origin.X, Origin.Y));
            'V':
              if Command = 'V' then
                Candidate.LineTo(CheckedPoint(Origin.X, Numbers[0]))
              else
                Candidate.LineTo(CheckedPoint(Origin.X, Numbers[0] + Origin.Y));
            'C':
              begin
                LastCubic := ReadPoint(2);
                Candidate.CurveTo(ReadPoint(0), LastCubic, ReadPoint(4));
              end;
            'S':
              begin
                Control := Origin;
                if CharInSet(Previous, ['C', 'S']) then
                  Control := CheckedPoint(2 * Double(Origin.X) - LastCubic.X,
                    2 * Double(Origin.Y) - LastCubic.Y);
                LastCubic := ReadPoint(0);
                Candidate.CurveTo(Control, LastCubic, ReadPoint(2));
              end;
            'Q':
              begin
                LastQuadratic := ReadPoint(0);
                Candidate.QuadCurveTo(LastQuadratic, ReadPoint(2));
              end;
            'T':
              begin
                Control := Origin;
                if CharInSet(Previous, ['Q', 'T']) then
                  Control := CheckedPoint(2 * Double(Origin.X) - LastQuadratic.X,
                    2 * Double(Origin.Y) - LastQuadratic.Y);
                Finish := ReadPoint(0);
                Candidate.QuadCurveTo(Control, Finish);
                LastQuadratic := Control;
              end;
            'A': AppendSvgArc(Candidate, Numbers[0], Numbers[1], Numbers[2],
              Numbers[3] = 1, Numbers[4] = 1, ReadPoint(5));
          end;
          Previous := UpCase(Command);
          if Command = 'M' then
            Command := 'L'
          else if Command = 'm' then
            Command := 'l';
        end;
        SkipSpace;
      end;
      for var I := 0 to Candidate.Count - 1 do
      begin
        var P := Candidate.Points[I].Point;
        if IsNan(P.X) or IsInfinite(P.X) or IsNan(P.Y) or IsInfinite(P.Y) or
          (Abs(P.X) > 1E12) or (Abs(P.Y) > 1E12) then
          raise EConvertError.Create(Translate('Координаты контура вне допустимого диапазона.'));
      end;
      var Bounds := Candidate.GetBounds;
      if IsNan(Bounds.Width) or IsInfinite(Bounds.Width) or
        IsNan(Bounds.Height) or IsInfinite(Bounds.Height) then
        raise EConvertError.Create(Translate('Координаты контура вне допустимого диапазона.'));
      Destination.Assign(Candidate);
      Result := True;
    except
      on E: Exception do
        Error := E.Message;
    end;
  finally
    Candidate.Free;
  end;
end;

constructor TPathEditorForm.Create(AOwner: TComponent);
begin
  inherited;
  FValue := TPathData.Create;
  if AOwner is TCustomForm then
    StyleBook := TCustomForm(AOwner).StyleBook;
  TranslateForm(Self);
  DataChanged(nil);
end;

constructor TPathEditorForm.CreateEditor(AOwner: TComponent; Source: TPathData);
begin
  Create(AOwner);
  MemoData.Text := Source.Data;
  DataChanged(nil);
end;

destructor TPathEditorForm.Destroy;
begin
  MemoData.OnChangeTracking := nil;
  PaintBoxPreview.OnPaint := nil;
  FreeAndNil(FValue);
  inherited;
end;

procedure TPathEditorForm.DataChanged(Sender: TObject);
var
  Error: string;
begin
  if FValue = nil then
    Exit;
  FValid := TryParsePathData(MemoData.Text, FValue, Error);
  ButtonApply.Enabled := FValid;
  LabelValidation.Text := Error;
  LabelValidation.Visible := not FValid;
  PaintBoxPreview.Repaint;
end;

procedure TPathEditorForm.ApplyClick(Sender: TObject);
begin
  DataChanged(nil);
  if FValid then
    ModalResult := mrOk;
end;

procedure TPathEditorForm.PreviewPaint(Sender: TObject; Canvas: TCanvas);
var
  Preview: TPathData;
  Bounds: TRectF;
  Scale: Single;
begin
  Canvas.Fill.Color := $FFF4F4F4;
  Canvas.FillRect(PaintBoxPreview.LocalRect, 0, 0, [], 1);
  if not FValid or (FValue = nil) or (FValue.Count = 0) or
    (PaintBoxPreview.Width <= 32) or (PaintBoxPreview.Height <= 32) then
    Exit;
  Preview := TPathData.Create;
  try
    try
      Preview.Assign(FValue);
      Bounds := Preview.GetBounds;
      Scale := Min((PaintBoxPreview.Width - 32) / Max(Bounds.Width, 0.001),
        (PaintBoxPreview.Height - 32) / Max(Bounds.Height, 0.001));
      Preview.Translate(-Bounds.Left, -Bounds.Top);
      Preview.Scale(Scale, Scale);
      Preview.Translate((PaintBoxPreview.Width - Bounds.Width * Scale) / 2,
        (PaintBoxPreview.Height - Bounds.Height * Scale) / 2);
      Canvas.Fill.Color := $FF327AC4;
      Canvas.FillPath(Preview, 1);
      Canvas.Stroke.Color := $FF164E87;
      Canvas.Stroke.Thickness := 1;
      Canvas.DrawPath(Preview, 1);
    except
      on E: Exception do
      begin
        FValid := False;
        ButtonApply.Enabled := False;
        LabelValidation.Text := Translate('Не удалось построить превью контура.');
        LabelValidation.Visible := True;
      end;
    end;
  finally
    Preview.Free;
  end;
end;

end.

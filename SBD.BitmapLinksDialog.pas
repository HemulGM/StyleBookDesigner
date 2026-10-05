unit SBD.BitmapLinksDialog;

interface

uses
  System.Classes, System.Types, System.UITypes, System.SysUtils, System.Rtti,
  System.Math, System.Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Layouts, FMX.Objects, FMX.StdCtrls, FMX.ListBox,
  FMX.ComboEdit, FMX.SpinBox, FMX.Controls.Presentation, FMX.Styles.Objects,
  SBD.Dialogs, FMX.EditBox, FMX.Edit;

type
  TBitmapLinksDraft = class
  public
    Path: string;
    Target, Value: TBitmapLinks;
    constructor Create(const APath: string; ATarget: TBitmapLinks);
    destructor Destroy; override;
    function IsChanged: Boolean;
  end;

  TBitmapDrag = (None, CreateRect, MoveRect, Left, Top, Right, Bottom,
    TopLeft, TopRight, BottomLeft, BottomRight, CapLeft, CapTop, CapRight, CapBottom);

  TBitmapLinksEditorForm = class(TAppDialogForm)
    Header, Body, SourceRow, LeftPanel, Workspace, ViewToolbar, GeometryHost: TLayout;
    RightPanel: TVertScrollBox;
    RightContent: TLayout;
    TitleLabel, SourceLabel, ImagesLabel, LinksLabel, ResolutionsLabel, ScaleLabel: TLabel;
    GeometryLabel, InsetsLabel, PreviewLabel, HintLabel, StatusLabel, ErrorLabel: TLabel;
    SourceLookupEdit: TComboEdit;
    ImagesList, LinksList, ResolutionsList: TListBox;
    ResolutionTools: TLayout;
    AddResolutionButton, DeleteResolutionButton, CenterButton: TButton;
    ScaleEdit: TSpinBox;
    ZoomCombo: TComboBox;
    ViewBackground, PreviewBackground: TRectangle;
    View, Preview: TPaintBox;
    Actions: TPanel;
    ApplyButton, CancelButton: TButton;
    procedure ImageSelected(Sender: TObject);
    procedure LinkSelected(Sender: TObject);
    procedure ResolutionSelected(Sender: TObject);
    procedure SourceChanged(Sender: TObject);
    procedure ScaleChanged(Sender: TObject);
    procedure CoordinateChanged(Sender: TObject);
    procedure ResolutionAction(Sender: TObject);
    procedure ZoomChanged(Sender: TObject);
    procedure CenterClick(Sender: TObject);
    procedure ViewPaint(Sender: TObject; Canvas: TCanvas);
    procedure PreviewPaint(Sender: TObject; Canvas: TCanvas);
    procedure ViewResize(Sender: TObject);
    procedure ViewDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ViewMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ViewUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ViewWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure ApplyClick(Sender: TObject);
  private
    FUpdating, FPanning: Boolean;
    FTarget: TFmxObject;
    FSourceOwner: TCustomStyleObject;
    FOriginalSource: string;
    FDrafts: TObjectList<TBitmapLinksDraft>;
    FImages: TList<TImage>;
    FBitmap: TBitmap;
    FBitmapScale: Single;
    FCoordinates: array[0..7] of TSpinBox;
    FZoomPercent, FCustomZoomIndex, FWheelRemainder: Integer;
    FPanOffset, FPanStart, FPanOrigin, FDragStart: TPointF;
    FDrag: TBitmapDrag;
    FDragRect, FDragInsets: TRectF;
    procedure CollectLinks(Instance: TObject; const Prefix: string; Depth: Integer);
    procedure BuildCoordinates;
    procedure RebuildResolutions(Index: Integer);
    procedure LoadCoordinates;
    procedure LoadBitmap;
    procedure RefreshView;
    procedure SetZoom(Percent: Integer);
    function ImageOrigin: TPointF;
    function SelectedSource: TImage;
    function HitHandle(const Point: TPointF): TBitmapDrag;
    procedure EndDrag;
  protected
    procedure DoHide; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEditor(AOwner: TComponent; Target, Root: TFmxObject; Links: TBitmapLinks; const Path: string; Background: TBrush);
    destructor Destroy; override;
    procedure Deactivate; override;
    function CurrentDraft: TBitmapLinksDraft;
    function CurrentLink: TBitmapLink;
    function HasChanges: Boolean;
    function Validate(out Error: string): Boolean;
    procedure Commit;
    procedure GetChangedPaths(Paths: TStrings);
    function ImageToView(const Point: TPointF): TPointF;
    function ViewToImage(const Point: TPointF): TPointF;
    procedure SetSourceRect(const Value: TRectF);
    procedure SetCapInsets(const Value: TRectF);
    procedure ZoomAt(const Anchor: TPointF; WheelDelta: Integer);
    property ZoomPercent: Integer read FZoomPercent;
    property PanOffset: TPointF read FPanOffset;
  end;

function SameBitmapLinks(Left, Right: TBitmapLinks): Boolean;

implementation

uses
  System.TypInfo, FMX.Text, FMX.MultiResBitmap, SBD.Localization,
  SBD.PropertyInspector;

{$R *.fmx}

type
  TControlAccess = class(TControl);

function SameBitmapLinks(Left, Right: TBitmapLinks): Boolean;
begin
  Result := Left.Count = Right.Count;
  if Result then
    for var I := 0 to Left.Count - 1 do
      if (Left.Links[I].Scale <> Right.Links[I].Scale) or
        (Left.Links[I].SourceRect.Rect <> Right.Links[I].SourceRect.Rect) or
        (Left.Links[I].CapInsets.Rect <> Right.Links[I].CapInsets.Rect) then
        Exit(False);
end;

constructor TBitmapLinksDraft.Create(const APath: string; ATarget: TBitmapLinks);
begin
  inherited Create;
  Path := APath;
  Target := ATarget;
  Value := TBitmapLinks.Create;
  Value.Assign(Target);
end;

destructor TBitmapLinksDraft.Destroy;
begin
  Value.Free;
  inherited;
end;

function TBitmapLinksDraft.IsChanged: Boolean;
begin
  Result := not SameBitmapLinks(Target, Value);
end;

constructor TBitmapLinksEditorForm.Create(AOwner: TComponent);
begin
  FUpdating := True;
  inherited;
  FDrafts := TObjectList<TBitmapLinksDraft>.Create(True);
  FImages := TList<TImage>.Create;
  FZoomPercent := 100;
  FCustomZoomIndex := -1;
  if AOwner is TForm then
    StyleBook := TForm(AOwner).StyleBook;
  BuildCoordinates;
  ScaleEdit.ValueType := TNumValueType.Float;
  TranslateForm(Self);
  EnableSmoothScrolling(Self);
  OnMouseWheel := ViewWheel;
  FUpdating := False;
end;

constructor TBitmapLinksEditorForm.CreateEditor(AOwner: TComponent; Target, Root: TFmxObject; Links: TBitmapLinks; const Path: string; Background: TBrush);
begin
  Create(AOwner);
  FUpdating := True;
  try
    FTarget := Target;
    if Target is TCustomStyleObject then
    begin
      FSourceOwner := TCustomStyleObject(Target);
      FOriginalSource := FSourceOwner.SourceLookup;
    end;
    SourceLookupEdit.Enabled := FSourceOwner <> nil;
    SourceLookupEdit.Text := FOriginalSource;
    for var Child in Root.Children do
      if Child is TImage then
      begin
        FImages.Add(TImage(Child));
        ImagesList.Items.Add(Child.StyleName);
        if not Child.StyleName.IsEmpty then
          SourceLookupEdit.Items.Add(Child.StyleName);
      end;
    CollectLinks(Target, '', 0);
    var Index := -1;
    for var I := 0 to FDrafts.Count - 1 do
      if FDrafts[I].Target = Links then
        Index := I;
    if Index < 0 then
    begin
      Index := FDrafts.Count;
      FDrafts.Add(TBitmapLinksDraft.Create(Path, Links));
    end;
    for var Draft in FDrafts do
      LinksList.Items.Add(Draft.Path);
    LinksList.ItemIndex := Index;
    if Background <> nil then
    begin
      ViewBackground.Fill.Assign(Background);
      PreviewBackground.Fill.Assign(Background);
    end;
  finally
    FUpdating := False;
  end;
  LinkSelected(nil);
end;

destructor TBitmapLinksEditorForm.Destroy;
begin
  FUpdating := True;
  EndDrag;
  OnMouseWheel := nil;
  FBitmap := nil;
  FreeAndNil(FDrafts);
  FreeAndNil(FImages);
  inherited;
end;

procedure TBitmapLinksEditorForm.CollectLinks(Instance: TObject; const Prefix: string; Depth: Integer);
begin
  if (Instance = nil) or (Depth > 4) then
    Exit;
  var Context := TRttiContext.Create;
  try
    var Properties := Context.GetType(Instance.ClassType).GetProperties;
    for var Prop in Properties do
      if (Prop.Visibility = mvPublished) and Prop.IsReadable and (Prop.PropertyType.TypeKind = tkClass) then
      begin
        var Obj := Prop.GetValue(Instance).AsObject;
        var Path := Prefix + Prop.Name;
        if Obj is TBitmapLinks then
          FDrafts.Add(TBitmapLinksDraft.Create(Path, TBitmapLinks(Obj)));
      end;
    for var Prop in Properties do
      if (Prop.Visibility = mvPublished) and Prop.IsReadable and (Prop.PropertyType.TypeKind = tkClass) then
      begin
        var Obj := Prop.GetValue(Instance).AsObject;
        if (Obj is TPersistent) and not (Obj is TComponent) and not (Obj is TCollection) then
          CollectLinks(Obj, Prefix + Prop.Name + '.', Depth + 1);
      end;
  finally
    Context.Free;
  end;
end;

procedure TBitmapLinksEditorForm.BuildCoordinates;
const
  Names: array[0..3] of string = ('Left', 'Top', 'Right', 'Bottom');
begin
  for var I := 0 to 7 do
  begin
    var LabelControl := TLabel.Create(Self);
    LabelControl.Parent := GeometryHost;
    LabelControl.SetBounds((I mod 2) * 132, (I div 2) * 68 + 4 + (I div 4) * 36, 124, 24);
    LabelControl.Text := Names[I mod 4];
    var Edit := TSpinBox.Create(Self);
    Edit.Parent := GeometryHost;
    Edit.SetBounds((I mod 2) * 132, LabelControl.Position.Y + 24, 124, 32);
    Edit.Min := 0;
    Edit.Max := 1000000;
    Edit.ValueType := TNumValueType.Integer;
    Edit.Increment := 1;
    Edit.Tag := I;
    Edit.OnChange := CoordinateChanged;
    FCoordinates[I] := Edit;
  end;
end;

function TBitmapLinksEditorForm.CurrentDraft: TBitmapLinksDraft;
begin
  Result := nil;
  if (FDrafts = nil) or (LinksList = nil) then
    Exit;
  if (LinksList.ItemIndex >= 0) and (LinksList.ItemIndex < FDrafts.Count) then
    Result := FDrafts[LinksList.ItemIndex];
end;

function TBitmapLinksEditorForm.CurrentLink: TBitmapLink;
begin
  Result := nil;
  var Draft := CurrentDraft;
  if (Draft <> nil) and (ResolutionsList.ItemIndex >= 0) and (ResolutionsList.ItemIndex < Draft.Value.Count) then
    Result := Draft.Value.Links[ResolutionsList.ItemIndex];
end;

function TBitmapLinksEditorForm.SelectedSource: TImage;
begin
  Result := nil;
  if SourceLookupEdit.Text.IsEmpty then
    Exit;
  for var Image in FImages do
    if SameText(Image.StyleName, SourceLookupEdit.Text) then
      Exit(Image);
end;

procedure TBitmapLinksEditorForm.ImageSelected(Sender: TObject);
begin
  if FUpdating or not SourceLookupEdit.Enabled then
    Exit;
  if ImagesList.ItemIndex >= 0 then
  begin
    SourceLookupEdit.Text := FImages[ImagesList.ItemIndex].StyleName;
    SourceChanged(nil);
  end;
end;

procedure TBitmapLinksEditorForm.SourceChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  EndDrag;
  FUpdating := True;
  try
    ImagesList.ItemIndex := FImages.IndexOf(SelectedSource);
  finally
    FUpdating := False;
  end;
  FPanOffset := TPointF.Zero;
  LoadBitmap;
  RefreshView;
end;

procedure TBitmapLinksEditorForm.LinkSelected(Sender: TObject);
begin
  if FUpdating then
    Exit;
  EndDrag;
  if LinksList.Selected <> nil then
    LinksList.ScrollToItem(LinksList.Selected);
  RebuildResolutions(0);
end;

procedure TBitmapLinksEditorForm.RebuildResolutions(Index: Integer);
begin
  FUpdating := True;
  try
    ResolutionsList.Clear;
    if CurrentDraft <> nil then
      for var I := 0 to CurrentDraft.Value.Count - 1 do
        ResolutionsList.Items.Add(Format('Scale %s×', [FloatToStr(CurrentDraft.Value.Links[I].Scale)]));
    ResolutionsList.ItemIndex := Min(Index, ResolutionsList.Count - 1);
  finally
    FUpdating := False;
  end;
  ResolutionSelected(nil);
end;

procedure TBitmapLinksEditorForm.ResolutionSelected(Sender: TObject);
begin
  if FUpdating then
    Exit;
  EndDrag;
  FPanOffset := TPointF.Zero;
  LoadBitmap;
  LoadCoordinates;
end;

procedure TBitmapLinksEditorForm.LoadBitmap;
begin
  FBitmap := nil;
  FBitmapScale := 1;
  var Image := SelectedSource;
  if Image <> nil then
  begin
    var Scale: Single := 1;
    if CurrentLink <> nil then
      Scale := CurrentLink.Scale;
    var Item := Image.MultiResBitmap.ItemByScale(Scale, False, False);
    if Item <> nil then
    begin
      FBitmap := Item.Bitmap;
      FBitmapScale := Item.Scale;
    end;
  end;
  FUpdating := True;
  try
    ImagesList.ItemIndex := FImages.IndexOf(Image);
  finally
    FUpdating := False;
  end;
end;

procedure TBitmapLinksEditorForm.LoadCoordinates;
begin
  FUpdating := True;
  try
    var Link := CurrentLink;
    ScaleEdit.Enabled := Link <> nil;
    DeleteResolutionButton.Enabled := Link <> nil;
    for var Edit in FCoordinates do
      Edit.Enabled := Link <> nil;
    if Link <> nil then
    begin
      ScaleEdit.Value := Link.Scale;
      var R := Link.SourceRect.Rect;
      var C := Link.CapInsets.Rect;
      FCoordinates[0].Value := R.Left;
      FCoordinates[1].Value := R.Top;
      FCoordinates[2].Value := R.Right;
      FCoordinates[3].Value := R.Bottom;
      FCoordinates[4].Value := C.Left;
      FCoordinates[5].Value := C.Top;
      FCoordinates[6].Value := C.Right;
      FCoordinates[7].Value := C.Bottom;
    end;
  finally
    FUpdating := False;
  end;
  RefreshView;
end;

procedure TBitmapLinksEditorForm.ScaleChanged(Sender: TObject);
begin
  if FUpdating or (CurrentLink = nil) then
    Exit;
  CurrentLink.Scale := ScaleEdit.Value;
  RebuildResolutions(ResolutionsList.ItemIndex);
end;

procedure TBitmapLinksEditorForm.CoordinateChanged(Sender: TObject);
begin
  if FUpdating or (CurrentLink = nil) then
    Exit;
  CurrentLink.SourceRect.Rect := RectF(Round(FCoordinates[0].Value), Round(FCoordinates[1].Value),
    Round(FCoordinates[2].Value), Round(FCoordinates[3].Value));
  CurrentLink.CapInsets.Rect := RectF(Round(FCoordinates[4].Value), Round(FCoordinates[5].Value),
    Round(FCoordinates[6].Value), Round(FCoordinates[7].Value));
  RefreshView;
end;

procedure TBitmapLinksEditorForm.ResolutionAction(Sender: TObject);
begin
  EndDrag;
  var Draft := CurrentDraft;
  if Draft = nil then
    Exit;
  var Index := ResolutionsList.ItemIndex;
  if Sender = DeleteResolutionButton then
  begin
    if Index >= 0 then
      Draft.Value.Delete(Index);
  end
  else
  begin
    var Scale: Single := 1;
    var Image := SelectedSource;
    if Image <> nil then
      for var I := 0 to Image.MultiResBitmap.Count - 1 do
        if Draft.Value.LinkByScale(Image.MultiResBitmap[I].Scale, True) = nil then
        begin
          Scale := Image.MultiResBitmap[I].Scale;
          Break;
        end;
    while Draft.Value.LinkByScale(Scale, True) <> nil do
      Scale := Scale + 0.5;
    var Previous := CurrentLink;
    var Link := TBitmapLink(Draft.Value.Add);
    if Previous <> nil then
    begin
      Link.Assign(Previous);
      var Ratio := Scale / Previous.Scale;
      var R := Previous.SourceRect.Rect;
      var C := Previous.CapInsets.Rect;
      Link.SourceRect.Rect := RectF(Round(R.Left * Ratio), Round(R.Top * Ratio), Round(R.Right * Ratio), Round(R.Bottom * Ratio));
      Link.CapInsets.Rect := RectF(Round(C.Left * Ratio), Round(C.Top * Ratio), Round(C.Right * Ratio), Round(C.Bottom * Ratio));
    end
    else if FBitmap <> nil then
      Link.SourceRect.Rect := FBitmap.BoundsF;
    Link.Scale := Scale;
    Index := Link.Index;
  end;
  RebuildResolutions(Index);
end;

function TBitmapLinksEditorForm.ImageOrigin: TPointF;
begin
  Result := View.LocalRect.CenterPoint + FPanOffset;
  if FBitmap <> nil then
    Result := Result - PointF(FBitmap.Width, FBitmap.Height) * (FZoomPercent / 200);
end;

function TBitmapLinksEditorForm.ImageToView(const Point: TPointF): TPointF;
begin
  Result := ImageOrigin + Point * (FZoomPercent / 100);
end;

function TBitmapLinksEditorForm.ViewToImage(const Point: TPointF): TPointF;
begin
  Result := (Point - ImageOrigin) / (FZoomPercent / 100);
end;

procedure TBitmapLinksEditorForm.SetZoom(Percent: Integer);
begin
  FZoomPercent := EnsureRange(Percent, 50, 2000);
  FUpdating := True;
  try
    var Text := FZoomPercent.ToString + '%';
    var Index := ZoomCombo.Items.IndexOf(Text);
    if Index < 0 then
    begin
      if FCustomZoomIndex >= 0 then
        ZoomCombo.Items[FCustomZoomIndex] := Text
      else
        FCustomZoomIndex := ZoomCombo.Items.Add(Text);
      Index := FCustomZoomIndex;
    end;
    ZoomCombo.ItemIndex := Index;
  finally
    FUpdating := False;
  end;
  View.Repaint;
end;

procedure TBitmapLinksEditorForm.ZoomChanged(Sender: TObject);
begin
  if FUpdating or (ZoomCombo.ItemIndex < 0) then
    Exit;
  var Percent: Integer;
  if TryStrToInt(ZoomCombo.Items[ZoomCombo.ItemIndex].Replace('%', ''), Percent) then
    SetZoom(Percent);
end;

procedure TBitmapLinksEditorForm.ZoomAt(const Anchor: TPointF; WheelDelta: Integer);
begin
  if FPanning or (FDrag <> TBitmapDrag.None) then
    Exit;
  Inc(FWheelRemainder, WheelDelta);
  var Steps := FWheelRemainder div 120;
  FWheelRemainder := FWheelRemainder mod 120;
  if Steps = 0 then
    Exit;
  var Point := ViewToImage(Anchor);
  SetZoom(Round(FZoomPercent * Power(1.1, Steps)));
  FPanOffset := FPanOffset + Anchor - ImageToView(Point);
  View.Repaint;
end;

procedure TBitmapLinksEditorForm.ViewWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  var Anchor := View.ScreenToLocal(Screen.MousePos);
  if View.LocalRect.Contains(Anchor) then
  begin
    Handled := True;
    ZoomAt(Anchor, WheelDelta);
  end;
end;

procedure TBitmapLinksEditorForm.CenterClick(Sender: TObject);
begin
  EndDrag;
  FPanOffset := TPointF.Zero;
  View.Repaint;
end;

procedure TBitmapLinksEditorForm.ViewResize(Sender: TObject);
begin
  if not FUpdating then
    View.Repaint;
end;

procedure TBitmapLinksEditorForm.ViewPaint(Sender: TObject; Canvas: TCanvas);

  procedure Handle(const Point: TPointF; Color: TAlphaColor);
  begin
    var P := ImageToView(Point);
    Canvas.Fill.Color := Color;
    Canvas.Stroke.Color := $FFFFFFFF;
    Canvas.FillRect(RectF(P.X - 4, P.Y - 4, P.X + 4, P.Y + 4), 1, 1, AllCorners, 1);
    Canvas.DrawRect(RectF(P.X - 4, P.Y - 4, P.X + 4, P.Y + 4), 1, 1, AllCorners, 1);
  end;

begin
  if FBitmap = nil then
    Exit;
  var Origin := ImageOrigin;
  Canvas.DrawBitmap(FBitmap, FBitmap.BoundsF, RectF(Origin.X, Origin.Y,
      Origin.X + FBitmap.Width * FZoomPercent / 100, Origin.Y + FBitmap.Height * FZoomPercent / 100), 1, True);
  var Link := CurrentLink;
  if (Link = nil) or Link.SourceRect.Rect.IsEmpty then
    Exit;
  var R := Link.SourceRect.Rect;
  var C := Link.CapInsets.Rect;
  var TopLeft := ImageToView(R.TopLeft);
  var BottomRight := ImageToView(R.BottomRight);
  var Outer := RectF(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := $180078D4;
  Canvas.FillRect(Outer, 0, 0, AllCorners, 1);
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := $FF0078D4;
  Canvas.Stroke.Thickness := 1.5;
  Canvas.DrawRect(Outer, 0, 0, AllCorners, 1);
  var Inner := RectF(R.Left + C.Left, R.Top + C.Top, R.Right - C.Right, R.Bottom - C.Bottom);
  Canvas.Stroke.Color := $FF00A9A5;
  Canvas.Stroke.Dash := TStrokeDash.Dash;
  for var X in [Inner.Left, Inner.Right] do
    Canvas.DrawLine(ImageToView(PointF(X, R.Top)), ImageToView(PointF(X, R.Bottom)), 1);
  for var Y in [Inner.Top, Inner.Bottom] do
    Canvas.DrawLine(ImageToView(PointF(R.Left, Y)), ImageToView(PointF(R.Right, Y)), 1);
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  Handle(R.TopLeft, $FF0078D4);
  Handle(PointF(R.Right, R.Top), $FF0078D4);
  Handle(PointF(R.Left, R.Bottom), $FF0078D4);
  Handle(R.BottomRight, $FF0078D4);
  Handle(PointF(R.CenterPoint.X, R.Top), $FF0078D4);
  Handle(PointF(R.CenterPoint.X, R.Bottom), $FF0078D4);
  Handle(PointF(R.Left, R.CenterPoint.Y), $FF0078D4);
  Handle(PointF(R.Right, R.CenterPoint.Y), $FF0078D4);
  Handle(PointF(Inner.Left, R.CenterPoint.Y), $FF00A9A5);
  Handle(PointF(Inner.Right, R.CenterPoint.Y), $FF00A9A5);
  Handle(PointF(R.CenterPoint.X, Inner.Top), $FF00A9A5);
  Handle(PointF(R.CenterPoint.X, Inner.Bottom), $FF00A9A5);
end;

procedure TBitmapLinksEditorForm.PreviewPaint(Sender: TObject; Canvas: TCanvas);
var
  SX, SY, DX, DY: array[0..3] of Single;
begin
  var Link := CurrentLink;
  if (Link = nil) or (FBitmap = nil) or (Link.Scale <= 0) or Link.SourceRect.Rect.IsEmpty then
    Exit;
  var R := Link.SourceRect.Rect;
  var C := Link.CapInsets.Rect;
  if (C.Left + C.Right > R.Width) or (C.Top + C.Bottom > R.Height) then
    Exit;
  var D := Preview.LocalRect;
  D.Inflate(-16, -16);
  if D.IsEmpty then
    Exit;
  SX[0] := R.Left;
  SX[1] := R.Left + C.Left;
  SX[2] := R.Right - C.Right;
  SX[3] := R.Right;
  SY[0] := R.Top;
  SY[1] := R.Top + C.Top;
  SY[2] := R.Bottom - C.Bottom;
  SY[3] := R.Bottom;
  var RatioX := Min(1, D.Width / Max(1, (C.Left + C.Right) / Link.Scale));
  var RatioY := Min(1, D.Height / Max(1, (C.Top + C.Bottom) / Link.Scale));
  DX[0] := D.Left;
  DX[1] := D.Left + C.Left / Link.Scale * RatioX;
  DX[2] := D.Right - C.Right / Link.Scale * RatioX;
  DX[3] := D.Right;
  DY[0] := D.Top;
  DY[1] := D.Top + C.Top / Link.Scale * RatioY;
  DY[2] := D.Bottom - C.Bottom / Link.Scale * RatioY;
  DY[3] := D.Bottom;
  for var Y := 0 to 2 do
    for var X := 0 to 2 do
      if (SX[X + 1] > SX[X]) and (SY[Y + 1] > SY[Y]) then
        Canvas.DrawBitmap(FBitmap, RectF(SX[X], SY[Y], SX[X + 1], SY[Y + 1]),
          RectF(DX[X], DY[Y], DX[X + 1], DY[Y + 1]), 1, True);
end;

function TBitmapLinksEditorForm.HitHandle(const Point: TPointF): TBitmapDrag;
const
  Kinds: array[0..7] of TBitmapDrag = (TBitmapDrag.TopLeft, TBitmapDrag.TopRight,
    TBitmapDrag.BottomLeft, TBitmapDrag.BottomRight, TBitmapDrag.Top, TBitmapDrag.Bottom,
    TBitmapDrag.Left, TBitmapDrag.Right);
begin
  Result := TBitmapDrag.None;
  var Link := CurrentLink;
  if (Link = nil) or Link.SourceRect.Rect.IsEmpty then
    Exit;
  var R := Link.SourceRect.Rect;
  var C := Link.CapInsets.Rect;
  var Points: array[0..7] of TPointF;
  Points[0] := R.TopLeft;
  Points[1] := PointF(R.Right, R.Top);
  Points[2] := PointF(R.Left, R.Bottom);
  Points[3] := R.BottomRight;
  Points[4] := PointF(R.CenterPoint.X, R.Top);
  Points[5] := PointF(R.CenterPoint.X, R.Bottom);
  Points[6] := PointF(R.Left, R.CenterPoint.Y);
  Points[7] := PointF(R.Right, R.CenterPoint.Y);
  for var I := 0 to 3 do
    if ImageToView(Points[I]).Distance(Point) <= 6 then
      Exit(Kinds[I]);
  // Insets with value zero share an edge with SourceRect. Prefer their side
  // handles; the four outer corner handles remain available for resizing.
  var Caps: array[0..3] of TPointF;
  Caps[0] := PointF(R.Left + C.Left, R.CenterPoint.Y);
  Caps[1] := PointF(R.CenterPoint.X, R.Top + C.Top);
  Caps[2] := PointF(R.Right - C.Right, R.CenterPoint.Y);
  Caps[3] := PointF(R.CenterPoint.X, R.Bottom - C.Bottom);
  for var I := 0 to 3 do
    if ImageToView(Caps[I]).Distance(Point) <= 6 then
      Exit(TBitmapDrag(Ord(TBitmapDrag.CapLeft) + I));
  for var I := 4 to 7 do
    if ImageToView(Points[I]).Distance(Point) <= 6 then
      Exit(Kinds[I]);
  var P := ViewToImage(Point);
  var Tolerance := 5 / (FZoomPercent / 100);
  if R.Contains(P) then
  begin
    if Abs(P.X - (R.Left + C.Left)) < Tolerance then
      Exit(TBitmapDrag.CapLeft);
    if Abs(P.X - (R.Right - C.Right)) < Tolerance then
      Exit(TBitmapDrag.CapRight);
    if Abs(P.Y - (R.Top + C.Top)) < Tolerance then
      Exit(TBitmapDrag.CapTop);
    if Abs(P.Y - (R.Bottom - C.Bottom)) < Tolerance then
      Exit(TBitmapDrag.CapBottom);
    Result := TBitmapDrag.MoveRect;
  end;
end;

procedure TBitmapLinksEditorForm.ViewDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FUpdating then
    Exit;
  if Button = TMouseButton.mbMiddle then
  begin
    FPanning := True;
    FPanStart := PointF(X, Y);
    FPanOrigin := FPanOffset;
    View.Cursor := crSizeAll;
    TControlAccess(View).Capture;
  end
  else if (Button = TMouseButton.mbLeft) and not FPanning and (CurrentLink <> nil) and (FBitmap <> nil) then
  begin
    FDrag := HitHandle(PointF(X, Y));
    FDragStart := ViewToImage(PointF(X, Y));
    FDragRect := CurrentLink.SourceRect.Rect;
    FDragInsets := CurrentLink.CapInsets.Rect;
    if FDrag = TBitmapDrag.None then
      FDrag := TBitmapDrag.CreateRect;
    TControlAccess(View).Capture;
  end;
end;

procedure TBitmapLinksEditorForm.SetSourceRect(const Value: TRectF);
begin
  if CurrentLink = nil then
    Exit;
  var Width: Single := 1000000;
  var Height: Single := 1000000;
  if FBitmap <> nil then
  begin
    Width := FBitmap.Width;
    Height := FBitmap.Height;
  end;
  var R := RectF(EnsureRange(Round(Value.Left), 0, Max(0, Width - 1)),
    EnsureRange(Round(Value.Top), 0, Max(0, Height - 1)), 0, 0);
  R.Right := EnsureRange(Round(Value.Right), R.Left + 1, Width);
  R.Bottom := EnsureRange(Round(Value.Bottom), R.Top + 1, Height);
  CurrentLink.SourceRect.Rect := R;
  SetCapInsets(CurrentLink.CapInsets.Rect);
end;

procedure TBitmapLinksEditorForm.SetCapInsets(const Value: TRectF);
begin
  if CurrentLink = nil then
    Exit;
  var R := CurrentLink.SourceRect.Rect;
  var C := RectF(EnsureRange(Round(Value.Left), 0, Floor(R.Width)), EnsureRange(Round(Value.Top), 0, Floor(R.Height)), 0, 0);
  C.Right := EnsureRange(Round(Value.Right), 0, Floor(R.Width) - C.Left);
  C.Bottom := EnsureRange(Round(Value.Bottom), 0, Floor(R.Height) - C.Top);
  CurrentLink.CapInsets.Rect := C;
  LoadCoordinates;
end;

procedure TBitmapLinksEditorForm.ViewMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if FPanning then
  begin
    FPanOffset := FPanOrigin + PointF(X, Y) - FPanStart;
    View.Repaint;
    Exit;
  end;
  if (FDrag = TBitmapDrag.None) or (CurrentLink = nil) then
    Exit;
  var P := ViewToImage(PointF(X, Y));
  var Delta := PointF(Round(P.X - FDragStart.X), Round(P.Y - FDragStart.Y));
  var R := FDragRect;
  var C := FDragInsets;
  case FDrag of
    TBitmapDrag.CreateRect:
      R := RectF(Min(FDragStart.X, P.X), Min(FDragStart.Y, P.Y), Max(FDragStart.X, P.X), Max(FDragStart.Y, P.Y));
    TBitmapDrag.MoveRect:
      begin
        Delta.X := EnsureRange(Delta.X, -R.Left, FBitmap.Width - R.Right);
        Delta.Y := EnsureRange(Delta.Y, -R.Top, FBitmap.Height - R.Bottom);
        R.Offset(Delta);
      end;
    TBitmapDrag.CapLeft:
      C.Left := EnsureRange(C.Left + Delta.X, 0, R.Width - C.Right);
    TBitmapDrag.CapTop:
      C.Top := EnsureRange(C.Top + Delta.Y, 0, R.Height - C.Bottom);
    TBitmapDrag.CapRight:
      C.Right := EnsureRange(C.Right - Delta.X, 0, R.Width - C.Left);
    TBitmapDrag.CapBottom:
      C.Bottom := EnsureRange(C.Bottom - Delta.Y, 0, R.Height - C.Top);
  else
    begin
      if FDrag in [TBitmapDrag.Left, TBitmapDrag.TopLeft, TBitmapDrag.BottomLeft] then
        R.Left := Min(R.Right - 1, R.Left + Delta.X);
      if FDrag in [TBitmapDrag.Top, TBitmapDrag.TopLeft, TBitmapDrag.TopRight] then
        R.Top := Min(R.Bottom - 1, R.Top + Delta.Y);
      if FDrag in [TBitmapDrag.Right, TBitmapDrag.TopRight, TBitmapDrag.BottomRight] then
        R.Right := Max(R.Left + 1, R.Right + Delta.X);
      if FDrag in [TBitmapDrag.Bottom, TBitmapDrag.BottomLeft, TBitmapDrag.BottomRight] then
        R.Bottom := Max(R.Top + 1, R.Bottom + Delta.Y);
    end;
  end;
  if FDrag in [TBitmapDrag.CapLeft, TBitmapDrag.CapTop, TBitmapDrag.CapRight, TBitmapDrag.CapBottom] then
    SetCapInsets(C)
  else
    SetSourceRect(R);
end;

procedure TBitmapLinksEditorForm.ViewUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if ((Button = TMouseButton.mbMiddle) and FPanning) or
    ((Button = TMouseButton.mbLeft) and (FDrag <> TBitmapDrag.None)) then
    EndDrag;
end;

procedure TBitmapLinksEditorForm.EndDrag;
begin
  if FPanning or (FDrag <> TBitmapDrag.None) then
    TControlAccess(View).ReleaseCapture;
  FPanning := False;
  FDrag := TBitmapDrag.None;
  if View <> nil then
    View.Cursor := crDefault;
end;

procedure TBitmapLinksEditorForm.Deactivate;
begin
  EndDrag;
  inherited;
end;

procedure TBitmapLinksEditorForm.DoHide;
begin
  EndDrag;
  inherited;
end;

function TBitmapLinksEditorForm.Validate(out Error: string): Boolean;
begin
  Error := '';
  var Source := SelectedSource;
  for var Draft in FDrafts do
    for var I := 0 to Draft.Value.Count - 1 do
    begin
      var Link := Draft.Value.Links[I];
      var R := Link.SourceRect.Rect;
      var C := Link.CapInsets.Rect;
      if (Link.Scale <= 0) or IsNan(Link.Scale) or IsInfinite(Link.Scale) then
        Error := Translate('Scale должен быть больше нуля.');
      for var J := 0 to I - 1 do
        if SameValue(Link.Scale, Draft.Value.Links[J].Scale, 0.00001) then
          Error := Translate('Разрешения одной ссылки должны иметь разные Scale.');
      if (R.Left < 0) or (R.Top < 0) or (R.Right < R.Left) or (R.Bottom < R.Top) then
        Error := Translate('SourceRect должен задавать область внутри изображения.');
      if (C.Left < 0) or (C.Top < 0) or (C.Right < 0) or (C.Bottom < 0) or
        (not R.IsEmpty and ((C.Left + C.Right > R.Width) or (C.Top + C.Bottom > R.Height))) then
        Error := Translate('CapInsets не должны пересекаться или выходить за SourceRect.');
      if Source <> nil then
      begin
        var Item := Source.MultiResBitmap.ItemByScale(Link.Scale, True, False);
        if (Item <> nil) and ((R.Right > Item.Bitmap.Width) or (R.Bottom > Item.Bitmap.Height)) then
          Error := Translate('SourceRect должен задавать область внутри изображения.');
      end;
      if not Error.IsEmpty then
      begin
        Error := Draft.Path + ' / Scale ' + FloatToStr(Link.Scale) + ': ' + Error;
        Exit(False);
      end;
    end;
  Result := True;
end;

procedure TBitmapLinksEditorForm.RefreshView;
begin
  var Error: string;
  ApplyButton.Enabled := Validate(Error);
  ErrorLabel.Text := Error;
  if FBitmap = nil then
    StatusLabel.Text := Translate('Выберите TImage из корня книги стилей или введите SourceLookup.')
  else
    StatusLabel.Text := Format('%d × %d px · bitmap Scale %s×', [FBitmap.Width, FBitmap.Height, FloatToStr(FBitmapScale)]);
  View.Repaint;
  Preview.Repaint;
end;

function TBitmapLinksEditorForm.HasChanges: Boolean;
begin
  Result := (FSourceOwner <> nil) and (SourceLookupEdit.Text <> FOriginalSource);
  if not Result then
    for var Draft in FDrafts do
      if Draft.IsChanged then
        Exit(True);
end;

procedure TBitmapLinksEditorForm.GetChangedPaths(Paths: TStrings);
begin
  if (FSourceOwner <> nil) and (SourceLookupEdit.Text <> FOriginalSource) then
    Paths.Add('SourceLookup');
  for var Draft in FDrafts do
    if Draft.IsChanged then
      Paths.Add(Draft.Path);
end;

procedure TBitmapLinksEditorForm.Commit;
begin
  var Error: string;
  if not Validate(Error) then
    raise EArgumentException.Create(Error);
  for var Draft in FDrafts do
    if Draft.IsChanged then
      Draft.Target.Assign(Draft.Value);
  if FSourceOwner <> nil then
    FSourceOwner.SourceLookup := SourceLookupEdit.Text;
end;

procedure TBitmapLinksEditorForm.ApplyClick(Sender: TObject);
begin
  var Error: string;
  if Validate(Error) then
    ModalResult := mrOk
  else
    ErrorLabel.Text := Error;
end;

end.


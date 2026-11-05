unit SBD.Preview;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Math, System.TypInfo, System.Generics.Collections, FMX.Types,
  FMX.Controls, FMX.Forms, SBD.Dialogs, FMX.Layouts, FMX.StdCtrls, FMX.ListBox,
  FMX.Edit, FMX.Objects, FMX.Graphics, FMX.Controls.Presentation, FMX.Grid,
  SBD.PropertyInspector, SBD.EditorTypes;

type
  TPreviewForm = class(TAppDialogForm)
    PreviewHeader: TLayout;
    PreviewTitle, ResourceLabel: TLabel;
    AssignClassButton, AutoClassButton: TButton;
    Body, ClassesPanel, WorkspacePanel, InspectorPanel: TLayout;
    ClassesLabel, ControlLabel, InspectorLabel: TLabel;
    ClassSearch, PropertySearch: TEdit;
    ClassList: TListBox;
    LeftSplitter, RightSplitter: TSplitter;
    WorkspaceBackground: TRectangle;
    ViewToolbar: TLayout;
    ViewZoom: TComboBox;
    CenterViewButton: TButton;
    SelectedControlHost, InspectorHost: TLayout;
    HelpLabel: TLabel;
    PreviewBook: TStyleBook;
    procedure FilterClasses(Sender: TObject);
    procedure PreviewChanged(Sender: TObject);
    procedure FilterProperties(Sender: TObject);
    procedure AssignClassClick(Sender: TObject);
    procedure ControlChanged(Sender: TObject);
    procedure ViewZoomChanged(Sender: TObject);
    procedure CenterViewClick(Sender: TObject);
    procedure ViewResize(Sender: TObject);
  private
    FClasses: TDictionary<string, TFmxObjectClass>;
    FNames: TStringList;
    FUpdating: Boolean;
    FControl: TStyledControl;
    FInspector: TSBDPropertyInspector;
    FPreviewScene: IScene;
    FOnPreviewChange, FOnAssignClass: TNotifyEvent;
    FZoomPercent, FWheelRemainder, FCustomZoomIndex: Integer;
    FZoomUpdating, FCentering, FPanning: Boolean;
    FZoomEffects: TZoomEffects;
    FPanOffset, FPanStart, FPanOrigin: TPointF;
    FGridValues: TArray<TArray<TValue>>;
    FGridBitmaps: TObjectList<TBitmap>;
    procedure InitializeGrid(Grid: TCustomGrid);
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure StringGridDrawCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    function GetSelectedClass: string;
    procedure CenterControl;
    procedure SetViewZoom(Percent: Integer);
    procedure EndViewPan;
    procedure InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
  protected
    procedure PaintRects(const UpdateRects: array of TRectF); override;
    procedure DoShow; override;
    procedure DoHide; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; AFormX, AFormY: Single); override;
    procedure MouseMove(Shift: TShiftState; AFormX, AFormY: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; AFormX, AFormY: Single; DoClick: Boolean = True); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure Deactivate; override;
    procedure ResetView;
    procedure ZoomAt(const Anchor: TPointF; WheelDelta: Integer);
    procedure ConfigureClasses(Classes: TDictionary<string, TFmxObjectClass>; Names: TStrings);
    procedure SelectClass(const ClassName: string);
    procedure ClearControl;
    procedure CreateControl(const StyleName: string);
    procedure SetResource(const StyleName, AssignedClass: string; CanAssign: Boolean);
    procedure RefreshLanguage;
    property SelectedClass: string read GetSelectedClass;
    property PreviewControl: TStyledControl read FControl;
    property Inspector: TSBDPropertyInspector read FInspector;
    property ZoomPercent: Integer read FZoomPercent;
    property OnPreviewChange: TNotifyEvent read FOnPreviewChange write FOnPreviewChange;
    property OnAssignClass: TNotifyEvent read FOnAssignClass write FOnAssignClass;
  end;

implementation

uses
  FMX.Consts, FMX.Memo, FMX.TreeView, FMX.TabControl, FMX.Header, FMX.Grid.Style,
  FMX.ImgList, FMX.ScrollBox, SBD.Localization;

{$R *.fmx}

const
  MinPreviewZoom = 50;
  MaxPreviewZoom = 2000;

type
  TControlAccess = class(TControl);
  // Route the tested control and its descendants to the edited book while
  // the class list and inspector retain the editor's own interface style.

  TPreviewScene = class(TInterfacedObject, IScene)
  private
    FScene: IScene;
    FBook: TStyleBook;
  public
    constructor Create(const Scene: IScene; Book: TStyleBook);
    function GetStyleBook: TStyleBook;
    procedure SetStyleBook(const Value: TStyleBook);
    procedure AddUpdateRect(const R: TRectF);
    function GetUpdateRectsCount: Integer;
    function GetUpdateRect(const Index: Integer): TRectF;
    function GetObject: TFmxObject;
    function GetCanvas: TCanvas;
    function GetSceneScale: Single;
    function LocalToScreen(const Point: TPointF): TPointF;
    function ScreenToLocal(const Point: TPointF): TPointF;
    procedure ChangeScrollingState(const Control: TControl; const Active: Boolean);
    procedure DisableUpdating;
    procedure EnableUpdating;
  end;

constructor TPreviewScene.Create(const Scene: IScene; Book: TStyleBook);
begin
  inherited Create;
  FScene := Scene;
  FBook := Book;
end;

function TPreviewScene.GetStyleBook: TStyleBook;
begin
  Result := FBook;
end;

procedure TPreviewScene.SetStyleBook(const Value: TStyleBook);
begin
  FBook := Value;
end;

procedure TPreviewScene.AddUpdateRect(const R: TRectF);
begin
  FScene.AddUpdateRect(R);
end;

function TPreviewScene.GetUpdateRectsCount: Integer;
begin
  Result := FScene.GetUpdateRectsCount;
end;

function TPreviewScene.GetUpdateRect(const Index: Integer): TRectF;
begin
  Result := FScene.GetUpdateRect(Index);
end;

function TPreviewScene.GetObject: TFmxObject;
begin
  Result := FScene.GetObject;
end;

function TPreviewScene.GetCanvas: TCanvas;
begin
  Result := FScene.GetCanvas;
end;

function TPreviewScene.GetSceneScale: Single;
begin
  Result := FScene.GetSceneScale;
end;

function TPreviewScene.LocalToScreen(const Point: TPointF): TPointF;
begin
  Result := FScene.LocalToScreen(Point);
end;

function TPreviewScene.ScreenToLocal(const Point: TPointF): TPointF;
begin
  Result := FScene.ScreenToLocal(Point);
end;

procedure TPreviewScene.ChangeScrollingState(const Control: TControl; const Active: Boolean);
begin
  FScene.ChangeScrollingState(Control, Active);
end;

procedure TPreviewScene.DisableUpdating;
begin
  FScene.DisableUpdating;
end;

procedure TPreviewScene.EnableUpdating;
begin
  FScene.EnableUpdating;
end;

constructor TPreviewForm.Create(AOwner: TComponent);
begin
  inherited;
  FZoomPercent := 100;
  FZoomEffects := TZoomEffects.Create(Self);
  FCustomZoomIndex := -1;
  FClasses := TDictionary<string, TFmxObjectClass>.Create;
  FNames := TStringList.Create;
  FGridBitmaps := TObjectList<TBitmap>.Create(True);
  Randomize;
  FInspector := TSBDPropertyInspector.Create(Self);
  FInspector.Parent := InspectorHost;
  FInspector.Align := TAlignLayout.Client;
  FInspector.ReuseStructure := True;
  FInspector.VirtualEditors := True;
  FInspector.OnFilterProperty := InspectorFilter;
  FPreviewScene := TPreviewScene.Create(IScene(Self), PreviewBook);
  if AOwner is TForm then
    StyleBook := TForm(AOwner).StyleBook;
  TranslateForm(Self);
  EnableSmoothScrolling(Self);
end;

destructor TPreviewForm.Destroy;
begin
  FUpdating := True;
  FOnPreviewChange := nil;
  FOnAssignClass := nil;
  ClearControl;
  FreeAndNil(FZoomEffects);
  FGridBitmaps.Free;
  FreeAndNil(FInspector);
  FPreviewScene := nil;
  FClasses.Free;
  FNames.Free;
  inherited;
end;

procedure TPreviewForm.ConfigureClasses(Classes: TDictionary<string, TFmxObjectClass>; Names: TStrings);
begin
  FClasses.Clear;
  FNames.Clear;
  for var Name in Names do
    if Classes[Name].InheritsFrom(TStyledControl) and not Name.StartsWith('TCustom') then
    begin
      FClasses.Add(Name, Classes[Name]);
      FNames.Add(Name);
    end;
  FilterClasses(nil);
end;

function TPreviewForm.GetSelectedClass: string;
begin
  Result := '';
  if ClassList.Selected <> nil then
    Result := ClassList.Selected.Text;
end;

procedure TPreviewForm.FilterClasses(Sender: TObject);
begin
  if FUpdating or (FNames = nil) then
    Exit;
  var Previous := SelectedClass;
  FUpdating := True;
  ClassList.BeginUpdate;
  try
    ClassList.Clear;
    for var Name in FNames do
      if ClassSearch.Text.Trim.IsEmpty or Name.ToLower.Contains(ClassSearch.Text.Trim.ToLower) then
        ClassList.Items.Add(Name);
    ClassList.ItemIndex := ClassList.Items.IndexOf(Previous);
    if (ClassList.ItemIndex < 0) and (ClassList.Count > 0) then
      ClassList.ItemIndex := 0;
  finally
    ClassList.EndUpdate;
    FUpdating := False;
  end;
  PreviewChanged(Sender);
end;

procedure TPreviewForm.SelectClass(const ClassName: string);
begin
  FUpdating := True;
  try
    ClassSearch.Text := '';
    ClassList.Clear;
    ClassList.Items.Assign(FNames);
    ClassList.ItemIndex := ClassList.Items.IndexOf(ClassName);
    if ClassList.ItemIndex < 0 then
      ClassList.ItemIndex := ClassList.Items.IndexOf('TButton');
  finally
    FUpdating := False;
  end;
end;

procedure TPreviewForm.PreviewChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if Assigned(FOnPreviewChange) then
    FOnPreviewChange(Sender);
end;

procedure TPreviewForm.FilterProperties(Sender: TObject);
begin
  if FInspector <> nil then
    FInspector.FilterText := PropertySearch.Text;
end;

procedure TPreviewForm.InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
begin
  Accept := (Prop.Visibility = mvPublished) and Prop.IsReadable and not Prop.Name.StartsWith('On') and
    (Prop.Name <> 'Name') and (Prop.Name <> 'Parent') and (Prop.Name <> 'StyleBook') and
    (Prop.Name <> 'PopupMenu') and (Prop.Name <> 'Action') and (Prop.Name <> 'Stored') and
    (Prop.Name <> 'StyleLookup');
end;

procedure TPreviewForm.AssignClassClick(Sender: TObject);
begin
  if Assigned(FOnAssignClass) then
    FOnAssignClass(Sender);
end;

procedure TPreviewForm.ClearControl;
begin
  EndViewPan;
  if FInspector <> nil then
    FInspector.Clear;
  FControl := nil;
  if SelectedControlHost <> nil then
    SelectedControlHost.DeleteChildren;
  FGridValues := nil;
  if FGridBitmaps <> nil then
    FGridBitmaps.Clear;
end;

procedure TPreviewForm.InitializeGrid(Grid: TCustomGrid);
const
  ColumnClasses: array[0..11] of TComponentClass = (TStringColumn, TCheckColumn,
    TIntegerColumn, TFloatColumn, TCurrencyColumn, TDateColumn, TTimeColumn,
    TDateTimeColumn, TProgressColumn, TPopupColumn, TImageColumn, TGlyphColumn);
  SampleRows = 20;
begin
  Grid.BeginUpdate;
  try
    // Keep bitmaps alive until the grid and its cached cell previews are destroyed.
    for var I := 0 to 5 do
    begin
      var Bitmap := TBitmap.Create(32, 32);
      FGridBitmaps.Add(Bitmap);
      if Bitmap.Canvas.BeginScene then
      try
        Bitmap.Canvas.Clear(TAlphaColorRec.Null);
        Bitmap.Canvas.Fill.Color := $FF000000 or Cardinal(Random($1000000));
        if I mod 2 = 0 then
          Bitmap.Canvas.FillEllipse(RectF(3, 3, 29, 29), 1)
        else
          Bitmap.Canvas.FillRect(RectF(3, 3, 29, 29), 5, 5, AllCorners, 1);
        Bitmap.Canvas.Fill.Color := TAlphaColorRec.White;
        Bitmap.Canvas.FillEllipse(RectF(11, 11, 21, 21), 1);
      finally
        Bitmap.Canvas.EndScene;
      end;
    end;
    var Images := TImageList.Create(Grid);
    for var I := 0 to FGridBitmaps.Count - 1 do
    begin
      var Source := Images.Source.Add;
      Source.Name := 'sample' + I.ToString;
      var Item := Source.MultiResBitmap.Add;
      Item.Scale := 1;
      Item.Bitmap.Assign(FGridBitmaps[I]);
      var Layer := Images.Destination.Add.Layers.Add;
      Layer.Name := Source.Name;
      Layer.SourceRect.Rect := FGridBitmaps[I].BoundsF;
    end;
    Grid.Images := Images;
    Grid.RowHeight := 40;
    Grid.RowCount := SampleRows;
    SetLength(FGridValues, Length(ColumnClasses));
    for var Col := 0 to High(ColumnClasses) do
    begin
      var Column := TColumn(ColumnClasses[Col].Create(Grid));
      Column.Header := Column.ClassName.Substring(1);
      Column.Width := 136;
      if Column is TDateTimeColumn then
        Column.Width := 180;
      if (Column is TImageColumn) or (Column is TGlyphColumn) then
      begin
        Column.ReadOnly := True;
        Column.Width := 112;
      end;
      if Column is TPopupColumn then
        TPopupColumn(Column).Items.AddStrings(['Alpha', 'Beta', 'Gamma', 'Delta']);
      Column.Parent := Grid;
      SetLength(FGridValues[Col], SampleRows);
      for var Row := 0 to SampleRows - 1 do
      begin
        var Cell: TValue;
        case Col of
          0:
            Cell := Format('Item %d · %s', [Random(10000), Chr(Ord('A') + Random(26))]);
          1:
            Cell := Random(2) = 1;
          2:
            Cell := Random(20001) - 10000;
          3:
            Cell := (Random(2000001) - 1000000) / 1000;
          4:
            Cell := TValue.From<Currency>(Random(1000000) / 100);
          5:
            Cell := TValue.From<TDateTime>(Date + Random(731) - 365);
          6:
            Cell := TValue.From<TDateTime>(Random(86400) / 86400);
          7:
            Cell := TValue.From<TDateTime>(Date + Random(731) - 365 + Random(86400) / 86400);
          8:
            Cell := Random(101);
          9:
            Cell := TPopupColumn(Column).Items[Random(TPopupColumn(Column).Items.Count)];
          10:
            Cell := TValue.From<TBitmap>(FGridBitmaps[Random(FGridBitmaps.Count)]);
          11:
            Cell := Random(Images.Count);
        end;
        FGridValues[Col][Row] := Cell;
        if Grid is TStringGrid then
          if Column is TImageColumn then
            TStringGrid(Grid).Cells[Col, Row] := 'Image ' + Row.ToString
          else
            TStringGrid(Grid).Cells[Col, Row] := Column.ValueToString(Cell);
      end;
    end;
    if Grid is TGrid then
    begin
      TGrid(Grid).OnGetValue := GridGetValue;
      TGrid(Grid).OnSetValue := GridSetValue;
    end
    else if Grid is TStringGrid then
      TStringGrid(Grid).OnDrawColumnCell := StringGridDrawCell;
  finally
    Grid.EndUpdate;
  end;
end;

procedure TPreviewForm.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  var OriginalCol := TCustomGrid(Sender).Columns[ACol].OriginalIndex;
  if (OriginalCol >= 0) and (OriginalCol < Length(FGridValues)) and
    (ARow >= 0) and (ARow < Length(FGridValues[OriginalCol])) then
    Value := FGridValues[OriginalCol][ARow];
end;

procedure TPreviewForm.GridSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
begin
  var OriginalCol := TCustomGrid(Sender).Columns[ACol].OriginalIndex;
  if (OriginalCol >= 0) and (OriginalCol < Length(FGridValues)) and
    (ARow >= 0) and (ARow < Length(FGridValues[OriginalCol])) then
    FGridValues[OriginalCol][ARow] := Value;
end;

procedure TPreviewForm.StringGridDrawCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  // TStringGrid.Cells stores strings, so ImageColumn samples use owned bitmaps.
  if Column is TImageColumn then
  begin
    var Cell := TValue.Empty;
    GridGetValue(Sender, TCustomGrid(Sender).Model.IndexOfColumn(Column), Row, Cell);
    if Cell.IsType<TBitmap>then
    begin
      var Bitmap := Cell.AsType<TBitmap>;
      var Area := Bounds;
      Area.Inflate(-4, -4);
      if not Area.IsEmpty then
        Canvas.DrawBitmap(Bitmap, Bitmap.BoundsF, Bitmap.BoundsF.PlaceInto(Area), Column.AbsoluteOpacity);
    end;
  end;
end;

procedure TPreviewForm.CreateControl(const StyleName: string);
begin
  ClearControl;
  var ClassName := SelectedClass;
  AssignClassButton.Enabled := not ResourceLabel.TagString.IsEmpty and not ClassName.IsEmpty;
  ControlLabel.Text := ClassName;
  var C: TFmxObjectClass;
  if not FClasses.TryGetValue(ClassName, C) then
    Exit;
  var Control := TStyledControl(C.Create(nil));
  try
    var Width := Control.Width;
    var Height := Control.Height;
    var Style := PreviewBook.Style.FindStyleResource(StyleName);
    if Style is TControl then
    begin
      Width := Max(Width, TControl(Style).Width);
      Height := Max(Height, TControl(Style).Height);
    end;
    if Width <= 0 then
      Width := 180;
    if Height <= 0 then
      Height := 32;
    Width := Min(Width, 380);
    Height := Min(Height, 400);
    Control.SetBounds(0, 0, Width, Height);
    Control.HitTest := True;
    Control.Parent := SelectedControlHost;
    TControlAccess(Control).SetNewScene(FPreviewScene);
    Control.StyleLookup := StyleName;
    Control.AutoTranslate := False;
    if Control is TTextControl then
      TTextControl(Control).Text := Translate('Выбранный ресурс');
    if Control is TPresentedTextControl then
      TPresentedTextControl(Control).Text := Translate('Выбранный ресурс');
    if Control is TEdit then
      TEdit(Control).Text := Translate('Текст для проверки');
    if Control is TMemo then
      TMemo(Control).Lines.Text := Translate('Текст для проверки');
    if Control is TListBox then
      TListBox(Control).Items.Add(Translate('Первая строка'));
    if Control is TComboBox then
    begin
      TComboBox(Control).Items.Add(Translate('Первый вариант'));
      TComboBox(Control).Items.Add(Translate('Второй вариант'));
      TComboBox(Control).ItemIndex := 0;
    end;
    if Control is TTreeView then
    begin
      var Item := TTreeViewItem.Create(Control);
      Item.Text := Translate('Первая строка');
      Item.Parent := Control;
    end;
    if Control is TTabControl then
    begin
      var Tab := TTabItem.Create(Control);
      Tab.Text := Translate('Первая строка');
      Tab.Parent := Control;
      TTabControl(Control).TabIndex := 0;
    end;
    if Control is THeader then
    begin
      var Item := THeaderItem.Create(Control);
      Item.Text := Translate('Первая строка');
      Item.Parent := Control;
    end;
    if (Control is TGrid) or (Control is TStringGrid) then
    begin
      Control.Width := Max(Control.Width, Min(760, Max(380, SelectedControlHost.Width - 32)));
      Control.Height := Max(Control.Height, 340);
      InitializeGrid(TCustomGrid(Control));
    end;
    Control.ApplyStyleLookup;
    EnableSmoothScrolling(Control);
    FControl := Control;
    ResetView;
    if Control is TEdit then
      TEdit(Control).OnChangeTracking := ControlChanged;
    if Control is TCheckBox then
      TCheckBox(Control).OnChange := ControlChanged;
    if Control is TRadioButton then
      TRadioButton(Control).OnChange := ControlChanged;
    if Control is TSwitch then
      TSwitch(Control).OnSwitch := ControlChanged;
    if Control is TTrackBar then
      TTrackBar(Control).OnChange := ControlChanged;
    FInspector.Inspect(Control);
  except
    FControl := nil;
    Control.Free;
    raise;
  end;
end;

procedure TPreviewForm.CenterControl;
begin
  if FCentering or (FControl = nil) then
    Exit;
  FCentering := True;
  try
    var Bounds := TRectF.Empty;
    var Corners: array[0..3] of TPointF;
    Corners[0] := TPointF.Zero;
    Corners[1] := PointF(FControl.Width, 0);
    Corners[2] := PointF(FControl.Width, FControl.Height);
    Corners[3] := PointF(0, FControl.Height);
    for var I := 0 to High(Corners) do
    begin
      var P := SelectedControlHost.AbsoluteToLocal(FControl.LocalToAbsolute(Corners[I]));
      if I = 0 then
        Bounds := RectF(P.X, P.Y, P.X, P.Y)
      else
      begin
        Bounds.Left := Min(Bounds.Left, P.X);
        Bounds.Top := Min(Bounds.Top, P.Y);
        Bounds.Right := Max(Bounds.Right, P.X);
        Bounds.Bottom := Max(Bounds.Bottom, P.Y);
      end;
    end;
    FControl.Position.Point := FControl.Position.Point +
      SelectedControlHost.LocalRect.CenterPoint + FPanOffset - Bounds.CenterPoint;
  finally
    FCentering := False;
  end;
end;

procedure TPreviewForm.SetViewZoom(Percent: Integer);
begin
  if FZoomUpdating then
    Exit;
  FZoomUpdating := True;
  try
    FZoomPercent := EnsureRange(Percent, MinPreviewZoom, MaxPreviewZoom);
    var Text := FZoomPercent.ToString + '%';
    var Index := ViewZoom.Items.IndexOf(Text);
    if Index < 0 then
    begin
      if (FCustomZoomIndex >= 0) and (FCustomZoomIndex < ViewZoom.Items.Count) then
        ViewZoom.Items[FCustomZoomIndex] := Text
      else
        FCustomZoomIndex := ViewZoom.Items.Add(Text);
      Index := FCustomZoomIndex;
    end;
    ViewZoom.ItemIndex := Index;
    FZoomEffects.Apply(FControl, FZoomPercent);
    if FControl <> nil then
      TControlAccess(FControl).Scale.Point := PointF(FZoomPercent / 100, FZoomPercent / 100);
    CenterControl;
  finally
    FZoomUpdating := False;
  end;
end;

procedure TPreviewForm.ViewZoomChanged(Sender: TObject);
begin
  var Percent: Integer;
  if not FZoomUpdating and (ViewZoom.ItemIndex >= 0) and
    TryStrToInt(ViewZoom.Items[ViewZoom.ItemIndex].Replace('%', ''), Percent) then
    SetViewZoom(Percent);
end;

procedure TPreviewForm.CenterViewClick(Sender: TObject);
begin
  EndViewPan;
  FPanOffset := TPointF.Zero;
  CenterControl;
end;

procedure TPreviewForm.ViewResize(Sender: TObject);
begin
  CenterControl;
end;

procedure TPreviewForm.ResetView;
begin
  EndViewPan;
  FWheelRemainder := 0;
  FPanOffset := TPointF.Zero;
  SetViewZoom(100);
end;

procedure TPreviewForm.ZoomAt(const Anchor: TPointF; WheelDelta: Integer);
begin
  if FPanning or (FControl = nil) then
    Exit;
  Inc(FWheelRemainder, WheelDelta);
  var Steps := FWheelRemainder div 120;
  FWheelRemainder := FWheelRemainder mod 120;
  if Steps = 0 then
    Exit;
  var LocalAnchor := FControl.AbsoluteToLocal(SelectedControlHost.LocalToAbsolute(Anchor));
  SetViewZoom(Round(FZoomPercent * Power(1.1, Steps)));
  var AfterAnchor := SelectedControlHost.AbsoluteToLocal(FControl.LocalToAbsolute(LocalAnchor));
  FPanOffset := FPanOffset + Anchor - AfterAnchor;
  CenterControl;
end;

procedure TPreviewForm.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  var Anchor := SelectedControlHost.ScreenToLocal(Screen.MousePos);
  if SelectedControlHost.LocalRect.Contains(Anchor) then
  begin
    Handled := True;
    ZoomAt(Anchor, WheelDelta);
  end
  else
    inherited;
end;

procedure TPreviewForm.MouseDown(Button: TMouseButton; Shift: TShiftState; AFormX, AFormY: Single);
begin
  var P := SelectedControlHost.AbsoluteToLocal(PointF(AFormX, AFormY));
  // Intercept navigation before dispatching to the interactive preview control.
  if (Button = TMouseButton.mbMiddle) and SelectedControlHost.LocalRect.Contains(P) then
  begin
    FPanning := True;
    FPanStart := P;
    FPanOrigin := FPanOffset;
    MouseCapture;
    Cursor := crSizeAll;
    Exit;
  end;
  inherited;
end;

procedure TPreviewForm.MouseMove(Shift: TShiftState; AFormX, AFormY: Single);
begin
  if FPanning then
  begin
    FPanOffset := FPanOrigin +
      SelectedControlHost.AbsoluteToLocal(PointF(AFormX, AFormY)) - FPanStart;
    CenterControl;
    Exit;
  end;
  inherited;
end;

procedure TPreviewForm.MouseUp(Button: TMouseButton; Shift: TShiftState; AFormX, AFormY: Single; DoClick: Boolean);
begin
  if FPanning then
  begin
    if Button = TMouseButton.mbMiddle then
      EndViewPan;
    Exit;
  end;
  inherited;
end;

procedure TPreviewForm.EndViewPan;
begin
  if not FPanning then
    Exit;
  FPanning := False;
  ReleaseCapture;
  Cursor := crDefault;
end;

procedure TPreviewForm.Deactivate;
begin
  EndViewPan;
  inherited;
end;

procedure TPreviewForm.PaintRects(const UpdateRects: array of TRectF);
begin
  // Styles may create new descendants after zooming (for example, list or grid cells).
  if (FZoomEffects <> nil) and (FZoomPercent > MaxEffectsZoom) then
    FZoomEffects.Apply(FControl, FZoomPercent);
  inherited;
end;

procedure TPreviewForm.DoShow;
begin
  inherited;
  ResetView;
end;

procedure TPreviewForm.DoHide;
begin
  EndViewPan;
  inherited;
end;

procedure TPreviewForm.ControlChanged(Sender: TObject);
begin
  if FInspector <> nil then
    FInspector.RefreshValues;
end;

procedure TPreviewForm.SetResource(const StyleName, AssignedClass: string; CanAssign: Boolean);
begin
  ResourceLabel.TagString := StyleName;
  ResourceLabel.Text := StyleName;
  if not AssignedClass.IsEmpty then
    ResourceLabel.Text := StyleName + ' → ' + AssignedClass;
  AssignClassButton.Enabled := CanAssign and not SelectedClass.IsEmpty;
  AutoClassButton.Enabled := CanAssign and not AssignedClass.IsEmpty;
end;

procedure TPreviewForm.RefreshLanguage;
begin
  TranslateForm(Self);
  FInspector.RefreshLanguage;
end;

end.


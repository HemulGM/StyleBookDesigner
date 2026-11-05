unit HGM.FormDesigner;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Filter.Effects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Edit, FMX.ListBox, FMX.TreeView, FMX.Menus,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.TabControl,
  SBD.PropertyInspector, HGM.FormDocument;

type
  TDesignerHitSurface = class(TRectangle)
  public
    ContentRoot: TControl;
    function PointInObjectLocal(X, Y: Single): Boolean; override;
  end;

  TDesignerSelection = class(TSelection)
  public
    PassThroughInterior: Boolean;
    function PointInObjectLocal(X, Y: Single): Boolean; override;
  end;

  TFormDesigner = class(TForm)
    StyleBookWinUI3: TStyleBook;
  private
    FDocument: TFormDocument;
    FUndo, FRedo: TStringList;
    FSaved, FFileName, FSelected, FPendingKind, FDragBefore: string;
    FUpdating, FGrid: Boolean;
    FTree, FProjectTree: TTreeView;
    FPalette: TListBox;
    FPaletteSearch, FPropertySearch: TEdit;
    FInspector: TSBDPropertyInspector;
    FObjectTitle, FStatus, FDocumentTitle: TLabel;
    FWorkArea: TScrollBox;
    FSurface: TRectangle;
    FGridPaint: TPaintBox;
    FSelection: TDesignerSelection;
    FCopies: TDictionary<string, TControl>;
    FTabs: TTabControl;
    FDesignTab, FCodeTab, FResourceTab: TTabItem;
    FCode, FResource: TMemo;
    FZoom: TComboBox;
    FGridCheck: TCheckBox;
    FUndoButton, FRedoButton: TButton;
    FOpenDialog: TOpenDialog;
    FSaveDialog, FExportDialog: TSaveDialog;
    FRefreshTimer: TTimer;
    FPreview: TForm;
    function NewLayout(Parent: TFmxObject; Align: TAlignLayout; Size: Single = 0): TLayout;
    function Card(Parent: TFmxObject; Align: TAlignLayout; Size: Single = 0): TRectangle;
    function LabelText(Parent: TFmxObject; const Text: string; Align: TAlignLayout;
      Size: Single = 14): TLabel;
    function CommandButton(Parent: TFmxObject; const Text, Hint: string;
      Command: Integer; Width: Single; Accent: Boolean = False): TButton;
    procedure BuildUI;
    procedure BuildMenus;
    procedure BuildPalette;
    procedure RebuildTree;
    procedure RebuildCanvas;
    procedure RefreshDocument;
    procedure SelectNode(const Name: string);
    procedure UpdateSelection;
    procedure UpdateStatus;
    procedure RecordChange(const Before: string);
    procedure AddComponent(const Kind: string; Parent: TFmxObject; X, Y: Single);
    function ConfirmDiscard: Boolean;
    function SaveDocument(SaveAs: Boolean): Boolean;
    procedure ExportDocument;
    procedure ShowPreview;
    procedure PreviewClosed(Sender: TObject; var Action: TCloseAction);
    procedure CommandClick(Sender: TObject);
    procedure ExecuteCommand(Command: Integer);
    procedure TreeChange(Sender: TObject);
    procedure PaletteClick(Sender: TObject);
    procedure PaletteDoubleClick(Sender: TObject);
    procedure PaletteSearchChange(Sender: TObject);
    procedure PropertySearchChange(Sender: TObject);
    procedure SurfaceDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ComponentDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure SelectionDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure SelectionChanged(Sender: TObject);
    procedure SelectionTracking(Sender: TObject);
    procedure PaintGrid(Sender: TObject; Canvas: TCanvas);
    procedure ZoomChanged(Sender: TObject);
    procedure GridChanged(Sender: TObject);
    procedure InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
    procedure InspectorWrite(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
    procedure InspectorEdit(Sender: TObject; PropertyInfo: TInspectorProperty);
    procedure RefreshTimer(Sender: TObject);
    procedure FormKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
    procedure CreateHandle; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF DESIGNER_TEST}
    procedure RunSmokeTests(const OutputPath: string);
    {$ENDIF}
  end;

var FormDesigner: TFormDesigner;

implementation

uses System.Math, System.IOUtils, System.StrUtils, System.TypInfo,
  FMX.DialogService.Sync, SBD.Localization, DelphiWindowStyle.FMX;

{$R *.fmx}

const
  AccentColor = $FF60CDFF;
  ShellColor = $FF202020;
  CardColor = $FF292929;
  BorderColor = $FF3C3C3C;
  TextColor = $FFF3F3F3;
  MutedColor = $FFAAAAAA;
  cmdNew = 1; cmdOpen = 2; cmdSave = 3; cmdSaveAs = 4; cmdExport = 5;
  cmdUndo = 6; cmdRedo = 7; cmdDelete = 8; cmdDuplicate = 9;
  cmdPreview = 10; cmdExit = 11; cmdSelectForm = 12;

function TDesignerSelection.PointInObjectLocal(X, Y: Single): Boolean;
begin
  Result := inherited;
  if PassThroughInterior then
    Result := Result and ((X < 8) or (Y < 8) or (X > Width - 8) or (Y > Height - 8));
end;

function TDesignerHitSurface.PointInObjectLocal(X, Y: Single): Boolean;
var P: TPointF;
  function OverChild(Obj: TFmxObject): Boolean;
  var I: Integer; C: TControl; Local: TPointF;
  begin
    Result := False;
    for I := 0 to Obj.ChildrenCount - 1 do
    begin
      if Obj.Children[I] is TControl then
      begin
        C := TControl(Obj.Children[I]);
        if C.TagString.StartsWith(#1) and C.Visible then
        begin
          Local := C.AbsoluteToLocal(P);
          if RectF(0, 0, C.Width, C.Height).Contains(Local) then Exit(True);
        end;
      end;
      if OverChild(Obj.Children[I]) then Exit(True);
    end;
  end;
begin
  Result := inherited;
  if Result and (ContentRoot <> nil) then
  begin
    P := LocalToAbsolute(PointF(X, Y));
    Result := not OverChild(ContentRoot);
  end;
end;

constructor TFormDesigner.Create(AOwner: TComponent);
begin
  inherited;
  FDocument := TFormDocument.Create;
  FUndo := TStringList.Create;
  FRedo := TStringList.Create;
  FCopies := TDictionary<string, TControl>.Create;
  FGrid := True;
  Width := 1440;
  Height := 920;
  Constraints.MinWidth := 1120;
  Constraints.MinHeight := 700;
  Position := TFormPosition.ScreenCenter;
  Fill.Color := ShellColor;
  OnKeyDown := FormKeys;
  OnCloseQuery := FormCloseQuery;
  BuildUI;
  FSaved := FDocument.Snapshot;
  RefreshDocument;
end;

procedure TFormDesigner.CreateHandle;
begin
  inherited;
  SetWindowColorMode(True);
  SetWindowCaptionColor($00202020);
end;

destructor TFormDesigner.Destroy;
begin
  if FRefreshTimer <> nil then FRefreshTimer.Enabled := False;
  if FInspector <> nil then FInspector.Clear;
  if FPreview <> nil then
  begin
    FPreview.OnClose := nil;
    FPreview.Free;
  end;
  FCopies.Free;
  FUndo.Free;
  FRedo.Free;
  FDocument.Free;
  inherited;
end;

function TFormDesigner.NewLayout(Parent: TFmxObject; Align: TAlignLayout; Size: Single): TLayout;
begin
  Result := TLayout.Create(Self);
  Result.Parent := Parent;
  Result.Position.Point := PointF(Parent.ChildrenCount * 1000, Parent.ChildrenCount * 1000);
  Result.Align := Align;
  if Align in [TAlignLayout.Top, TAlignLayout.Bottom] then Result.Height := Size
  else if Align in [TAlignLayout.Left, TAlignLayout.Right] then Result.Width := Size;
end;

function TFormDesigner.Card(Parent: TFmxObject; Align: TAlignLayout; Size: Single): TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := Parent;
  Result.Position.Point := PointF(Parent.ChildrenCount * 1000, Parent.ChildrenCount * 1000);
  Result.Align := Align;
  if Align in [TAlignLayout.Top, TAlignLayout.Bottom] then Result.Height := Size
  else if Align in [TAlignLayout.Left, TAlignLayout.Right] then Result.Width := Size;
  Result.Fill.Color := CardColor;
  Result.Stroke.Color := BorderColor;
  Result.XRadius := 8;
  Result.YRadius := 8;
  Result.HitTest := False;
end;

function TFormDesigner.LabelText(Parent: TFmxObject; const Text: string;
  Align: TAlignLayout; Size: Single): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := Parent;
  Result.Position.Point := PointF(Parent.ChildrenCount * 1000, Parent.ChildrenCount * 1000);
  Result.Align := Align;
  Result.Text := Text;
  Result.StyledSettings := [];
  Result.TextSettings.Font.Family := 'Segoe UI';
  Result.TextSettings.Font.Size := Size;
  Result.TextSettings.FontColor := TextColor;
  Result.TextSettings.VertAlign := TTextAlign.Center;
  Result.TextSettings.Trimming := TTextTrimming.Character;
  Result.HitTest := False;
  Result.Margins.Left := 12;
  Result.Margins.Right := 8;
end;

function TFormDesigner.CommandButton(Parent: TFmxObject; const Text, Hint: string;
  Command: Integer; Width: Single; Accent: Boolean): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := Parent;
  Result.Position.X := Parent.ChildrenCount * 1000;
  Result.Align := TAlignLayout.Left;
  Result.Width := Width;
  Result.Margins.Rect := RectF(0, 6, 4, 6);
  Result.Text := Text;
  Result.Hint := Hint;
  Result.ShowHint := True;
  Result.Tag := Command;
  Result.OnClick := CommandClick;
  Result.StyleLookup := 'buttonstyle_subtle';
  if Accent then Result.StyleLookup := 'buttonstyle_accent';
end;

procedure TFormDesigner.BuildMenus;
var Bar: TMenuBar; Root, Item: TMenuItem;
  procedure Add(const Text: string; Command: Integer);
  begin
    Item := TMenuItem.Create(Self);
    Item.Parent := Root;
    Item.Text := Text;
    Item.Tag := Command;
    Item.OnClick := CommandClick;
  end;
  procedure Menu(const Text: string);
  begin
    Root := TMenuItem.Create(Self);
    Root.Parent := Bar;
    Root.Text := Text;
  end;
begin
  Bar := TMenuBar.Create(Self);
  Bar.Parent := Self;
  Bar.Align := TAlignLayout.Top;
  Bar.Height := 32;
  Menu('Файл');
  Add('Новая форма    Ctrl+N', cmdNew);
  Add('Открыть…    Ctrl+O', cmdOpen);
  Add('Сохранить    Ctrl+S', cmdSave);
  Add('Сохранить как…    Ctrl+Shift+S', cmdSaveAs);
  Add('Экспорт Delphi (.pas + .fmx)…', cmdExport);
  Add('Выход', cmdExit);
  Menu('Правка');
  Add('Отменить    Ctrl+Z', cmdUndo);
  Add('Повторить    Ctrl+Y', cmdRedo);
  Add('Дублировать    Ctrl+D', cmdDuplicate);
  Add('Удалить    Del', cmdDelete);
  Menu('Вид');
  Add('Выбрать форму', cmdSelectForm);
  Add('Предпросмотр    F9', cmdPreview);
end;

procedure TFormDesigner.BuildUI;
var
  Commands, Body, LeftSide, RightSide, Header, Center, Bar: TLayout;
  C: TRectangle;
  Split: TSplitter;
  L: TLabel;
  Item, Child: TTreeViewItem;
  procedure HeaderTitle(Parent: TFmxObject; const Title: string);
  begin
    Header := NewLayout(Parent, TAlignLayout.Top, 44);
    L := LabelText(Header, Title, TAlignLayout.Client);
    L.TextSettings.Font.Style := [TFontStyle.fsBold];
  end;
  procedure Splitter(Parent: TFmxObject; Align: TAlignLayout; Size, Min: Single);
  begin
    Split := TSplitter.Create(Self);
    Split.Parent := Parent;
    Split.Align := Align;
    if Align in [TAlignLayout.Left, TAlignLayout.Right] then Split.Width := Size
    else Split.Height := Size;
    Split.MinSize := Min;
  end;
begin
  FRefreshTimer := TTimer.Create(Self);
  FRefreshTimer.Enabled := False;
  FRefreshTimer.Interval := 30;
  FRefreshTimer.OnTimer := RefreshTimer;
  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter := 'Формы FireMonkey (*.fmx)|*.fmx';
  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Filter := FOpenDialog.Filter;
  FSaveDialog.DefaultExt := 'fmx';
  FSaveDialog.Options := FSaveDialog.Options + [TOpenOption.ofOverwritePrompt];
  FExportDialog := TSaveDialog.Create(Self);
  FExportDialog.Filter := 'Модуль Delphi (*.pas)|*.pas';
  FExportDialog.DefaultExt := 'pas';
  BuildMenus;
  Commands := NewLayout(Self, TAlignLayout.Top, 52);
  Commands.Padding.Left := 12;
  CommandButton(Commands, '＋  Создать', 'Новая форма (Ctrl+N)', cmdNew, 112);
  CommandButton(Commands, 'Открыть', 'Открыть форму (Ctrl+O)', cmdOpen, 88);
  CommandButton(Commands, 'Сохранить', 'Сохранить форму (Ctrl+S)', cmdSave, 100);
  FUndoButton := CommandButton(Commands, '↶', 'Отменить (Ctrl+Z)', cmdUndo, 40);
  FRedoButton := CommandButton(Commands, '↷', 'Повторить (Ctrl+Y)', cmdRedo, 40);
  CommandButton(Commands, 'Экспорт Delphi', 'Сохранить .pas и .fmx', cmdExport, 132);
  CommandButton(Commands, '▷  Предпросмотр', 'Интерактивная форма (F9)', cmdPreview, 156, True);
  L := LabelText(Commands, 'FMX  /  Windows', TAlignLayout.Right, 12);
  L.Width := 156;
  L.TextSettings.FontColor := MutedColor;
  Bar := NewLayout(Self, TAlignLayout.Bottom, 30);
  FStatus := LabelText(Bar, '', TAlignLayout.Client, 12);
  FStatus.TextSettings.FontColor := MutedColor;
  Body := NewLayout(Self, TAlignLayout.Client);
  Body.Padding.Rect := RectF(12, 0, 12, 0);
  LeftSide := NewLayout(Body, TAlignLayout.Left, 300);
  Splitter(Body, TAlignLayout.Left, 8, 230);
  RightSide := NewLayout(Body, TAlignLayout.Right, 264);
  Splitter(Body, TAlignLayout.Right, 8, 220);
  Center := NewLayout(Body, TAlignLayout.Client);
  C := Card(LeftSide, TAlignLayout.Top, 270);
  HeaderTitle(C, 'Структура');
  FTree := TTreeView.Create(Self);
  FTree.Parent := C;
  FTree.Align := TAlignLayout.Client;
  FTree.Margins.Rect := RectF(4, 0, 4, 8);
  FTree.OnChange := TreeChange;
  Splitter(LeftSide, TAlignLayout.Top, 8, 160);
  C := Card(LeftSide, TAlignLayout.Client);
  HeaderTitle(C, 'Инспектор объектов');
  FObjectTitle := LabelText(C, '', TAlignLayout.Top, 12);
  FObjectTitle.Height := 30;
  FObjectTitle.TextSettings.FontColor := AccentColor;
  FPropertySearch := TEdit.Create(Self);
  FPropertySearch.Parent := C;
  FPropertySearch.Position.Y := 3000;
  FPropertySearch.Align := TAlignLayout.Top;
  FPropertySearch.Height := 32;
  FPropertySearch.Margins.Rect := RectF(12, 0, 12, 8);
  FPropertySearch.TextPrompt := 'Поиск свойств';
  FPropertySearch.StyleLookup := 'editstyle_clear';
  FPropertySearch.OnChangeTracking := PropertySearchChange;
  FInspector := TSBDPropertyInspector.Create(Self);
  FInspector.Parent := C;
  FInspector.Align := TAlignLayout.Client;
  FInspector.Margins.Rect := RectF(4, 0, 4, 8);
  FInspector.ReuseStructure := True;
  FInspector.VirtualEditors := True;
  FInspector.OnFilterProperty := InspectorFilter;
  FInspector.OnWriteProperty := InspectorWrite;
  FInspector.OnEditProperty := InspectorEdit;
  C := Card(RightSide, TAlignLayout.Top, 244);
  HeaderTitle(C, 'Проект');
  FProjectTree := TTreeView.Create(Self);
  FProjectTree.Parent := C;
  FProjectTree.Align := TAlignLayout.Client;
  FProjectTree.Margins.Rect := RectF(4, 0, 4, 8);
  Item := TTreeViewItem.Create(Self);
  Item.Parent := FProjectTree;
  Item.Text := 'FormDesign';
  Child := TTreeViewItem.Create(Self);
  Child.Parent := Item;
  Child.Text := 'Windows · FireMonkey';
  Child := TTreeViewItem.Create(Self);
  Child.Parent := Item;
  Child.Text := 'MainForm.pas';
  Child := TTreeViewItem.Create(Self);
  Child.Parent := Item;
  Child.Text := 'MainForm.fmx';
  Item.IsExpanded := True;
  Splitter(RightSide, TAlignLayout.Top, 8, 130);
  C := Card(RightSide, TAlignLayout.Client);
  HeaderTitle(C, 'Палитра компонентов');
  FPaletteSearch := TEdit.Create(Self);
  FPaletteSearch.Parent := C;
  FPaletteSearch.Position.Y := 3000;
  FPaletteSearch.Align := TAlignLayout.Top;
  FPaletteSearch.Height := 32;
  FPaletteSearch.Margins.Rect := RectF(12, 0, 12, 8);
  FPaletteSearch.TextPrompt := 'Найти компонент';
  FPaletteSearch.StyleLookup := 'editstyle_clear';
  FPaletteSearch.OnChangeTracking := PaletteSearchChange;
  L := LabelText(C, 'Двойной щелчок — добавить', TAlignLayout.Bottom, 12);
  L.Height := 36;
  L.TextSettings.FontColor := MutedColor;
  FPalette := TListBox.Create(Self);
  FPalette.Parent := C;
  FPalette.Align := TAlignLayout.Client;
  FPalette.Margins.Rect := RectF(4, 0, 4, 0);
  FPalette.OnClick := PaletteClick;
  FPalette.OnDblClick := PaletteDoubleClick;
  BuildPalette;
  C := Card(Center, TAlignLayout.Client);
  Header := NewLayout(C, TAlignLayout.Top, 44);
  FDocumentTitle := LabelText(Header, '', TAlignLayout.Client);
  FDocumentTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
  FTabs := TTabControl.Create(Self);
  FTabs.Parent := C;
  FTabs.Align := TAlignLayout.Client;
  FTabs.Margins.Rect := RectF(1, 0, 1, 1);
  FTabs.TabPosition := TTabPosition.Bottom;
  FDesignTab := TTabItem.Create(Self);
  FDesignTab.Parent := FTabs;
  FDesignTab.Text := 'Дизайн';
  FCodeTab := TTabItem.Create(Self);
  FCodeTab.Parent := FTabs;
  FCodeTab.Text := 'Код Delphi';
  FResourceTab := TTabItem.Create(Self);
  FResourceTab.Parent := FTabs;
  FResourceTab.Text := 'FMX';
  Bar := NewLayout(FDesignTab, TAlignLayout.Top, 44);
  FGridCheck := TCheckBox.Create(Self);
  FGridCheck.Parent := Bar;
  FGridCheck.Align := TAlignLayout.Left;
  FGridCheck.Width := 100;
  FGridCheck.Margins.Left := 12;
  FGridCheck.Text := 'Сетка';
  FGridCheck.IsChecked := True;
  FGridCheck.OnChange := GridChanged;
  FZoom := TComboBox.Create(Self);
  FZoom.Parent := Bar;
  FZoom.Align := TAlignLayout.Right;
  FZoom.Width := 96;
  FZoom.Margins.Rect := RectF(4, 6, 12, 6);
  FZoom.Items.AddStrings(['50%', '75%', '100%', '125%', '150%']);
  FZoom.ItemIndex := 2;
  FZoom.OnChange := ZoomChanged;
  L := LabelText(Bar, 'Масштаб', TAlignLayout.Right, 12);
  L.Width := 72;
  L.TextSettings.FontColor := MutedColor;
  FWorkArea := TScrollBox.Create(Self);
  FWorkArea.Parent := FDesignTab;
  FWorkArea.Align := TAlignLayout.Client;
  FWorkArea.Padding.Rect := RectF(24, 24, 24, 24);
  FCode := TMemo.Create(Self);
  FCode.Parent := FCodeTab;
  FCode.Align := TAlignLayout.Client;
  FCode.ReadOnly := True;
  FCode.StyledSettings := [TStyledSetting.FontColor];
  FCode.TextSettings.Font.Family := 'Consolas';
  FCode.TextSettings.Font.Size := 13;
  FResource := TMemo.Create(Self);
  FResource.Parent := FResourceTab;
  FResource.Align := TAlignLayout.Client;
  FResource.ReadOnly := True;
  FResource.StyledSettings := [TStyledSetting.FontColor];
  FResource.TextSettings.Font.Family := 'Consolas';
  FResource.TextSettings.Font.Size := 13;
  FTabs.TabIndex := 0;
  EnableSmoothScrolling(Body);
end;

procedure TFormDesigner.BuildPalette;
const
  Kinds: array[0..12] of string = ('TButton', 'TLabel', 'TEdit', 'TCheckBox',
    'TRadioButton', 'TSwitch', 'TComboBox', 'TMemo', 'TListBox', 'TProgressBar',
    'TPanel', 'TLayout', 'TRectangle');
var I: Integer; Item: TListBoxItem; Query: string;
begin
  FPalette.Clear;
  Query := Trim(FPaletteSearch.Text);
  for I := Low(Kinds) to High(Kinds) do
    if (Query = '') or ContainsText(Kinds[I], Query) then
    begin
      Item := TListBoxItem.Create(Self);
      Item.Parent := FPalette;
      Item.Height := 36;
      Item.Text := Kinds[I];
      Item.TagString := Kinds[I];
    end;
end;

procedure TFormDesigner.RebuildTree;
  procedure AddChildren(Obj: TFmxObject; Parent: TFmxObject);
  var I: Integer; Item: TTreeViewItem;
  begin
    for I := 0 to Obj.ChildrenCount - 1 do
      if (Obj.Children[I] is TControl) and (Obj.Children[I].Name <> '') then
      begin
        Item := TTreeViewItem.Create(Self);
        Item.Parent := Parent;
        Item.Text := Obj.Children[I].Name;
        Item.TagString := Obj.Children[I].Name;
        Item.Height := 28;
        AddChildren(Obj.Children[I], Item);
        Item.IsExpanded := True;
        if Item.TagString = FSelected then FTree.Selected := Item;
      end;
  end;
var Root: TTreeViewItem;
begin
  FTree.Clear;
  Root := TTreeViewItem.Create(Self);
  Root.Parent := FTree;
  Root.Text := FDocument.Root.Name;
  Root.TagString := '';
  AddChildren(FDocument.Root, Root);
  Root.IsExpanded := True;
  if FSelected = '' then FTree.Selected := Root;
end;

procedure TFormDesigner.RebuildCanvas;
  procedure PrepareCopy(Model, Obj: TFmxObject);
  var I, J: Integer;
  begin
    if Obj is TControl then
    begin
      TControl(Obj).HitTest := False;
      if (Model.Name <> '') and (FDocument.Find(Model.Name) <> nil) then
      begin
        FCopies.AddOrSetValue(Model.Name, TControl(Obj));
        Obj.TagString := #1 + Model.Name;
        TControl(Obj).Visible := True;
        TControl(Obj).Enabled := True;
        if not TControl(Model).Visible then TControl(Obj).Opacity := 0.35
        else if not TControl(Model).Enabled then TControl(Obj).Opacity := 0.55;
      end;
    end;
    J := 0;
    for I := 0 to Model.ChildrenCount - 1 do
      if Model.Children[I].Stored then
      begin
        while (J < Obj.ChildrenCount) and not Obj.Children[J].Stored do Inc(J);
        if J < Obj.ChildrenCount then PrepareCopy(Model.Children[I], Obj.Children[J]);
        Inc(J);
      end;
  end;
var
  I: Integer;
  Obj: TFmxObject;
  C: TControl;
  Hit: TDesignerHitSurface;
  Pair: TPair<string, TControl>;
begin
  FSelection := nil;
  FCopies.Clear;
  FreeAndNil(FSurface);
  FSurface := TRectangle.Create(Self);
  FSurface.Parent := FWorkArea;
  FSurface.Position.Point := PointF(24, 24);
  FSurface.Size.Size := TSizeF.Create(FDocument.Root.ClientWidth, FDocument.Root.ClientHeight);
  FSurface.Fill.Assign(FDocument.Root.Fill);
  FSurface.Stroke.Color := $FF808080;
  FSurface.OnMouseDown := SurfaceDown;
  FGridPaint := TPaintBox.Create(Self);
  FGridPaint.Parent := FSurface;
  FGridPaint.Align := TAlignLayout.Contents;
  FGridPaint.HitTest := False;
  FGridPaint.OnPaint := PaintGrid;
  for I := 0 to FDocument.Root.ChildrenCount - 1 do
    if FDocument.Root.Children[I] is TControl then
    begin
      Obj := FDocument.Root.Children[I].Clone(nil);
      Obj.Parent := FSurface;
      PrepareCopy(FDocument.Root.Children[I], Obj);
    end;
  for Pair in FCopies do
  begin
    C := Pair.Value;
    Hit := TDesignerHitSurface.Create(Self);
    Hit.Parent := C;
    Hit.Align := TAlignLayout.Contents;
    Hit.Fill.Kind := TBrushKind.None;
    Hit.Stroke.Kind := TBrushKind.None;
    if C is TLayout then
    begin
      Hit.Stroke.Kind := TBrushKind.Solid;
      Hit.Stroke.Color := $FF808080;
      Hit.Stroke.Dash := TStrokeDash.Dash;
    end;
    Hit.TagString := Pair.Key;
    if (C is TLayout) or (C is TPanel) then Hit.ContentRoot := C;
    Hit.OnMouseDown := ComponentDown;
    if (C is TLayout) or (C is TPanel) then Hit.SendToBack
    else Hit.BringToFront;
  end;
  FSelection := TDesignerSelection.Create(Self);
  FSelection.Parent := FSurface;
  FSelection.Color := AccentColor;
  FSelection.GripSize := 5;
  FSelection.MinSize := 16;
  FSelection.OnMouseDown := SelectionDown;
  FSelection.OnChange := SelectionChanged;
  FSelection.OnTrack := SelectionTracking;
  ZoomChanged(nil);
  UpdateSelection;
end;

procedure TFormDesigner.UpdateStatus;
var Dirty: Boolean;
begin
  Dirty := FDocument.Snapshot <> FSaved;
  FDocumentTitle.Text := FDocument.Root.Name + '.fmx';
  if Dirty then FDocumentTitle.Text := FDocumentTitle.Text + '  •';
  Caption := 'FMX Form Designer — ' + FDocument.Root.Name;
  if Dirty then Caption := Caption + ' *';
  FUndoButton.Enabled := FUndo.Count > 0;
  FRedoButton.Enabled := FRedo.Count > 0;
  if FPendingKind <> '' then
    FStatus.Text := 'Щёлкните на форме, чтобы добавить ' + FPendingKind + ' · Esc — отменить'
  else FStatus.Text := Format('%s  ·  %d компонентов  ·  %d × %d  ·  %s',
    [IfThen(FFileName = '', 'Новая форма', ExtractFileName(FFileName)),
     FDocument.ComponentCount, FDocument.Root.ClientWidth, FDocument.Root.ClientHeight,
     IfThen(FGrid, 'Привязка: 8 px', 'Свободное размещение')]);
end;

procedure TFormDesigner.RefreshDocument;
var Obj: TObject;
begin
  FRefreshTimer.Enabled := False;
  FUpdating := True;
  try
    if FDocument.Find(FSelected) = nil then FSelected := '';
    RebuildTree;
    RebuildCanvas;
    FCode.Text := FDocument.PascalText(FDocument.Root.Name);
    FResource.Text := FDocument.FMXText;
    FProjectTree.Items[0].Items[1].Text := FDocument.Root.Name + '.pas';
    FProjectTree.Items[0].Items[2].Text := FDocument.Root.Name + '.fmx';
    Obj := FDocument.Find(FSelected);
    if Obj = nil then Obj := FDocument.Root;
    FInspector.Inspect(Obj);
    FObjectTitle.Text := TComponent(Obj).Name + ' · ' + Obj.ClassName;
  finally FUpdating := False end;
  UpdateStatus;
end;

procedure TFormDesigner.SelectNode(const Name: string);
var Obj: TObject;
begin
  FSelected := Name;
  Obj := FDocument.Find(Name);
  if Obj = nil then
  begin
    FSelected := '';
    Obj := FDocument.Root;
  end;
  FUpdating := True;
  try RebuildTree finally FUpdating := False end;
  UpdateSelection;
  FInspector.Inspect(Obj);
  FObjectTitle.Text := TComponent(Obj).Name + ' · ' + Obj.ClassName;
end;

procedure TFormDesigner.UpdateSelection;
var C: TControl;
begin
  if FSelection = nil then Exit;
  FSelection.Visible := FCopies.TryGetValue(FSelected, C);
  if FSelection.Visible then
  begin
    FSelection.Parent := C.Parent;
    FSelection.PassThroughInterior := (C is TLayout) or (C is TPanel);
    FSelection.SetBounds(C.Position.X, C.Position.Y, C.Width, C.Height);
    FSelection.BringToFront;
  end;
end;

procedure TFormDesigner.RecordChange(const Before: string);
begin
  if Before = FDocument.Snapshot then Exit;
  FUndo.Add(Before);
  if FUndo.Count > 100 then FUndo.Delete(0);
  FRedo.Clear;
end;

procedure TFormDesigner.AddComponent(const Kind: string; Parent: TFmxObject; X, Y: Single);
var Before: string; C: TControl;
begin
  Before := FDocument.Snapshot;
  if FGrid then
  begin
    X := Round(X / 8) * 8;
    Y := Round(Y / 8) * 8;
  end;
  C := FDocument.Add(Kind, Parent, Max(0, X), Max(0, Y));
  FSelected := C.Name;
  FPendingKind := '';
  RecordChange(Before);
  RefreshDocument;
end;

procedure TFormDesigner.CommandClick(Sender: TObject);
begin
  ExecuteCommand(TFmxObject(Sender).Tag);
end;

procedure TFormDesigner.ExecuteCommand(Command: Integer);
var
  I: Integer;
  Before: string;
  C, CopyControl: TControl;
  Test: TFormDocument;
  procedure RenameCopy(Obj: TFmxObject);
  var J: Integer;
  begin
    if Obj is TControl then
    begin
      Obj.Name := FDocument.UniqueName(Obj.ClassName);
      if Obj.Owner <> FDocument.Root then
      begin
        if Obj.Owner <> nil then Obj.Owner.RemoveComponent(Obj);
        FDocument.Root.InsertComponent(Obj);
      end;
    end;
    for J := 0 to Obj.ChildrenCount - 1 do
      if Obj.Children[J].Stored then RenameCopy(Obj.Children[J]);
  end;
begin
  try
    case Command of
      cmdNew: if ConfirmDiscard then
        begin
          FInspector.Clear;
          FDocument.Clear;
          FFileName := '';
          FSelected := '';
          FPendingKind := '';
          FUndo.Clear;
          FRedo.Clear;
          FSaved := FDocument.Snapshot;
          RefreshDocument;
        end;
      cmdOpen: if FOpenDialog.Execute then
        begin
          Test := TFormDocument.Create;
          try Test.Load(TFile.ReadAllText(FOpenDialog.FileName, TEncoding.UTF8));
          finally Test.Free end;
          if ConfirmDiscard then
          begin
            FInspector.Clear;
            FDocument.Load(TFile.ReadAllText(FOpenDialog.FileName, TEncoding.UTF8));
            FFileName := FOpenDialog.FileName;
            FSelected := '';
            FPendingKind := '';
            FUndo.Clear;
            FRedo.Clear;
            FSaved := FDocument.Snapshot;
            RefreshDocument;
          end;
        end;
      cmdSave: SaveDocument(False);
      cmdSaveAs: SaveDocument(True);
      cmdExport: ExportDocument;
      cmdUndo, cmdRedo:
        begin
          if ((Command = cmdUndo) and (FUndo.Count = 0)) or
             ((Command = cmdRedo) and (FRedo.Count = 0)) then Exit;
          FInspector.Clear;
          if Command = cmdUndo then
          begin
            FRedo.Add(FDocument.Snapshot);
            I := FUndo.Count - 1;
            FDocument.Load(FUndo[I]);
            FUndo.Delete(I);
          end
          else
          begin
            FUndo.Add(FDocument.Snapshot);
            I := FRedo.Count - 1;
            FDocument.Load(FRedo[I]);
            FRedo.Delete(I);
          end;
          RefreshDocument;
        end;
      cmdDelete:
        begin
          C := FDocument.Find(FSelected);
          if C = nil then Exit;
          Before := FDocument.Snapshot;
          FInspector.Clear;
          C.Free;
          FSelected := '';
          RecordChange(Before);
          RefreshDocument;
        end;
      cmdDuplicate:
        begin
          C := FDocument.Find(FSelected);
          if C = nil then Exit;
          Before := FDocument.Snapshot;
          CopyControl := TControl(C.Clone(nil));
          RenameCopy(CopyControl);
          CopyControl.Parent := C.Parent;
          CopyControl.Position.Point := C.Position.Point + PointF(16, 16);
          FSelected := CopyControl.Name;
          RecordChange(Before);
          RefreshDocument;
        end;
      cmdPreview: ShowPreview;
      cmdExit: Close;
      cmdSelectForm: SelectNode('');
    end;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

function TFormDesigner.ConfirmDiscard: Boolean;
var Answer: TModalResult;
begin
  Result := True;
  if FDocument.Snapshot = FSaved then Exit;
  Answer := TDialogServiceSync.MessageDialog('Сохранить изменения в форме?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel],
    TMsgDlgBtn.mbYes, 0);
  case Answer of
    mrYes: Result := SaveDocument(False);
    mrNo: Result := True;
  else Result := False;
  end;
end;

function TFormDesigner.SaveDocument(SaveAs: Boolean): Boolean;
var Target: string;
begin
  Result := False;
  Target := FFileName;
  if SaveAs or (Target = '') then
  begin
    FSaveDialog.FileName := IfThen(Target = '', FDocument.Root.Name + '.fmx', Target);
    if not FSaveDialog.Execute then Exit;
    Target := FSaveDialog.FileName;
    if ExtractFileExt(Target) = '' then Target := Target + '.fmx';
  end;
  TFile.WriteAllText(Target, FDocument.FMXText, TEncoding.UTF8);
  FFileName := Target;
  FSaved := FDocument.Snapshot;
  UpdateStatus;
  Result := True;
end;

procedure TFormDesigner.ExportDocument;
var PasPath, FmxPath, UnitName: string;
begin
  FExportDialog.FileName := FDocument.Root.Name + '.pas';
  if not FExportDialog.Execute then Exit;
  PasPath := ChangeFileExt(FExportDialog.FileName, '.pas');
  FmxPath := ChangeFileExt(PasPath, '.fmx');
  UnitName := ChangeFileExt(ExtractFileName(PasPath), '');
  TFormDocument.CheckIdentifier(UnitName);
  if (TFile.Exists(PasPath) or TFile.Exists(FmxPath)) and
    (TDialogServiceSync.MessageDialog('Заменить существующие файлы .pas и .fmx?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0) <> mrYes) then Exit;
  TFile.WriteAllText(PasPath, FDocument.PascalText(UnitName), TEncoding.UTF8);
  TFile.WriteAllText(FmxPath, FDocument.FMXText, TEncoding.UTF8);
  FStatus.Text := 'Экспортировано: ' + PasPath + ' и ' + ExtractFileName(FmxPath);
end;

procedure TFormDesigner.ShowPreview;
var I: Integer;
begin
  if FPreview <> nil then
  begin
    FPreview.OnClose := nil;
    FreeAndNil(FPreview);
  end;
  FPreview := TForm.CreateNew(Self);
  FPreview.Caption := FDocument.Root.Caption + ' — Предпросмотр';
  FPreview.ClientWidth := FDocument.Root.ClientWidth;
  FPreview.ClientHeight := FDocument.Root.ClientHeight;
  FPreview.Position := TFormPosition.ScreenCenter;
  FPreview.StyleBook := StyleBookWinUI3;
  FPreview.Fill.Assign(FDocument.Root.Fill);
  FPreview.OnClose := PreviewClosed;
  for I := 0 to FDocument.Root.ChildrenCount - 1 do
    if FDocument.Root.Children[I] is TControl then
      FDocument.Root.Children[I].Clone(FPreview).Parent := FPreview;
  FPreview.Show;
end;

procedure TFormDesigner.PreviewClosed(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FPreview := nil;
end;

procedure TFormDesigner.TreeChange(Sender: TObject);
begin
  if not FUpdating and (FTree.Selected <> nil) then SelectNode(FTree.Selected.TagString);
end;

procedure TFormDesigner.PaletteClick(Sender: TObject);
begin
  if FPalette.Selected = nil then Exit;
  FPendingKind := FPalette.Selected.TagString;
  UpdateStatus;
end;

procedure TFormDesigner.PaletteDoubleClick(Sender: TObject);
var C: TControl; Parent: TFmxObject;
begin
  if FPalette.Selected = nil then Exit;
  C := FDocument.Find(FSelected);
  Parent := FDocument.Root;
  if (C is TLayout) or (C is TPanel) then Parent := C;
  AddComponent(FPalette.Selected.TagString, Parent, 32, 32);
end;

procedure TFormDesigner.PaletteSearchChange(Sender: TObject);
begin
  BuildPalette;
end;

procedure TFormDesigner.PropertySearchChange(Sender: TObject);
begin
  FInspector.FilterText := FPropertySearch.Text;
end;

procedure TFormDesigner.SurfaceDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then Exit;
  Focused := nil;
  if FPendingKind <> '' then AddComponent(FPendingKind, FDocument.Root, X, Y)
  else SelectNode('');
end;

procedure TFormDesigner.ComponentDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var C: TControl;
begin
  if Button <> TMouseButton.mbLeft then Exit;
  Focused := nil;
  C := FDocument.Find(TFmxObject(Sender).TagString);
  if ((C is TLayout) or (C is TPanel)) and (FPendingKind <> '') then
    AddComponent(FPendingKind, C, X, Y)
  else SelectNode(TFmxObject(Sender).TagString);
end;

procedure TFormDesigner.SelectionDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Focused := nil;
  if Button = TMouseButton.mbLeft then FDragBefore := FDocument.Snapshot;
end;

procedure TFormDesigner.SelectionChanged(Sender: TObject);
var C: TControl; X, Y, W, H: Single;
begin
  if FUpdating then Exit;
  C := FDocument.Find(FSelected);
  if C = nil then Exit;
  if C.Align <> TAlignLayout.None then
  begin
    UpdateSelection;
    FStatus.Text := 'Положение задаёт Align. Для свободного перемещения выберите None.';
    Exit;
  end;
  X := EnsureRange(FSelection.Position.X, 0, 10000);
  Y := EnsureRange(FSelection.Position.Y, 0, 10000);
  W := EnsureRange(FSelection.Width, 16, 10000);
  H := EnsureRange(FSelection.Height, 16, 10000);
  if FGrid then
  begin
    X := Round(X / 8) * 8;
    Y := Round(Y / 8) * 8;
    W := Max(16, Round(W / 8) * 8);
    H := Max(16, Round(H / 8) * 8);
  end;
  C.SetBounds(X, Y, W, H);
  if FDragBefore <> '' then RecordChange(FDragBefore);
  FDragBefore := '';
  FRefreshTimer.Enabled := True;
end;

procedure TFormDesigner.SelectionTracking(Sender: TObject);
var C: TControl;
begin
  if FCopies.TryGetValue(FSelected, C) and (C.Align = TAlignLayout.None) then
    C.SetBounds(FSelection.Position.X, FSelection.Position.Y, FSelection.Width, FSelection.Height);
end;

procedure TFormDesigner.PaintGrid(Sender: TObject; Canvas: TCanvas);
var X, Y: Integer;
begin
  if not FGrid then Exit;
  Canvas.Fill.Color := $44808080;
  Y := 8;
  while Y < FDocument.Root.ClientHeight do
  begin
    X := 8;
    while X < FDocument.Root.ClientWidth do
    begin
      Canvas.FillRect(RectF(X, Y, X + 1, Y + 1), 0, 0, [], 1);
      Inc(X, 8);
    end;
    Inc(Y, 8);
  end;
end;

procedure TFormDesigner.ZoomChanged(Sender: TObject);
const Scales: array[0..4] of Single = (0.5, 0.75, 1, 1.25, 1.5);
begin
  if (FSurface = nil) or (FZoom.ItemIndex < 0) then Exit;
  FSurface.Scale.Point := PointF(Scales[FZoom.ItemIndex], Scales[FZoom.ItemIndex]);
end;

procedure TFormDesigner.GridChanged(Sender: TObject);
begin
  FGrid := FGridCheck.IsChecked;
  if FGridPaint <> nil then FGridPaint.Repaint;
  UpdateStatus;
end;

procedure TFormDesigner.InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
begin
  Accept := (Prop.Visibility = mvPublished) and Prop.IsReadable and
    (Prop.PropertyType.TypeKind <> tkMethod) and not
    MatchText(Prop.Name, ['Parent', 'Owner', 'Root', 'Scene', 'Action', 'StyleBook',
      'Stored', 'Locked', 'DesignInfo', 'Observers', 'FormFactor', 'DesignerMasterStyle']);
  if Instance = FDocument.Root then
    Accept := Accept and not MatchText(Prop.Name, ['Visible', 'WindowState', 'Position']);
end;

procedure TFormDesigner.InspectorWrite(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
var Before: string;
begin
  Before := FDocument.Snapshot;
  if PropertyInfo.Prop.Name = 'Name' then
  begin
    TFormDocument.CheckIdentifier(Text);
    if ((PropertyInfo.Instance <> FDocument.Root) and SameText(Text, FDocument.Root.Name)) or
       ((FDocument.Root.FindComponent(Text) <> nil) and
         (FDocument.Root.FindComponent(Text) <> PropertyInfo.Instance)) then
      raise EConvertError.Create('Имя уже используется в этой форме.');
  end;
  FInspector.OnWriteProperty := nil;
  try
    FInspector.WriteProperty(PropertyInfo.Path, Text);
  finally FInspector.OnWriteProperty := InspectorWrite end;
  if FInspector.InspectedObject is TControl then
    FSelected := TControl(FInspector.InspectedObject).Name;
  RecordChange(Before);
  FRefreshTimer.Enabled := True;
end;

procedure TFormDesigner.InspectorEdit(Sender: TObject; PropertyInfo: TInspectorProperty);
var Before, Path: string;
begin
  Before := FDocument.Snapshot;
  Path := PropertyInfo.Path;
  FInspector.EditValue(Path, False);
  RecordChange(Before);
  FRefreshTimer.Enabled := True;
end;

procedure TFormDesigner.RefreshTimer(Sender: TObject);
begin
  FRefreshTimer.Enabled := False;
  RefreshDocument;
end;

procedure TFormDesigner.FormKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var Command: Integer;
begin
  Command := 0;
  if Key = vkEscape then
  begin
    FPendingKind := '';
    UpdateStatus;
    Exit;
  end;
  if Key = vkF9 then Command := cmdPreview;
  if ssCtrl in Shift then
    case Key of
      vkN: Command := cmdNew;
      vkO: Command := cmdOpen;
      vkS: if ssShift in Shift then Command := cmdSaveAs else Command := cmdSave;
    end;
  if not ((Focused is TCustomEdit) or (Focused is TCustomMemo)) then
  begin
    if Key = vkDelete then Command := cmdDelete;
    if ssCtrl in Shift then
      case Key of
        vkZ: Command := cmdUndo;
        vkY: Command := cmdRedo;
        vkD: Command := cmdDuplicate;
      end;
  end;
  if Command = 0 then Exit;
  ExecuteCommand(Command);
  Key := 0;
  KeyChar := #0;
end;

procedure TFormDesigner.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try CanClose := ConfirmDiscard;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      CanClose := False;
    end;
  end;
end;

{$IFDEF DESIGNER_TEST}
{$I Tests/DesignerSmokeTests.inc}
{$ENDIF}

end.

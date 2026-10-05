unit SBD.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Rtti, System.TypInfo, System.Math, System.Math.Vectors,
  System.Generics.Collections, System.Generics.Defaults, System.IOUtils,
  System.JSON, System.Diagnostics, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls, FMX.Edit, FMX.ListBox,
  FMX.TreeView, FMX.Objects, FMX.Grid, FMX.Grid.Style, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.Styles, FMX.Styles.Objects, FMX.Styles.Switch,
  FMX.Ani, FMX.Effects, FMX.Filter.Effects, FMX.TabControl, FMX.Colors,
  FMX.NumberBox, FMX.SpinBox, FMX.ComboEdit, FMX.ComboTrackBar, FMX.Calendar,
  FMX.CalendarEdit, FMX.DateTimeCtrls, FMX.ExtCtrls, FMX.Menus, FMX.Header,
  FMX.ListView, FMX.MultiView, FMX.SearchBox, FMX.MaskEdit, FMX.BufferedLayout,
  FMX.MagnifierGlass, FMX.Media, FMX.Controls3D, FMX.Objects3D, FMX.Layers3D,
  FMX.Viewport3D, FMX.MaterialSources, FMX.WebBrowser, FMX.Maps, FMX.Skia,
  FMX.ImgList, FMX.Consts, FMX.BehaviorManager, WinUI3.Form, FMX.Platform,
  SBD.PropertyInspector, SBD.StyleCatalog, SBD.BitmapLinksDialog,
  System.ImageList, System.IniFiles;

type
  TResourceTheme = (rtLight, rtDark);

  TNamedStyleValue = class
  private
    FLightValue, FDarkValue: string;
    FInitialized: Boolean;
    function GetValue: string;
    procedure SetValue(const Text: string);
    procedure SetLightValue(const Text: string);
    procedure SetDarkValue(const Text: string);
  public
    Name, Kind: string;
    Theme: TResourceTheme;
    function ValueFor(ATheme: TResourceTheme): string;
    property LightValue: string read FLightValue write SetLightValue;
    property DarkValue: string read FDarkValue write SetDarkValue;
    property Value: string read GetValue write SetValue;
  end;

  TStyleValueBinding = class
    TargetName, PropertyPath, ResourceName: string;
  end;

  TStyleGroup = class
    ID, Title, ParentID: string;
  end;

  TPropertyEntry = class
    Instance: TObject;
    Prop: TRttiProperty;
    Path: string;
  end;

  TFormMain = class(TWinUIForm)
    FLayout: TLayout;
    MainBackground: TRectangle;
    AppHeader: TLayout;
    AppTitle: TLabel;
    DocumentLabel: TLabel;
    LanguageBox: TComboBox;
    Language: TLang;
    Toolbar: TLayout;
    FileButton: TButton;
    SaveButton: TButton;
    UndoButton: TButton;
    RedoButton: TButton;
    MoreButton: TButton;
    PreviewButton: TButton;
    ValuesButton: TButton;
    FStatus: TLabel;
    EditorBody: TLayout;
    TreePanel: TLayout;
    TreeCard: TRectangle;
    TreeHeading: TLabel;
    TreeActions: TLayout;
    AddResourceButton: TButton;
    ObjectMoreButton: TButton;
    TreeHint: TLabel;
    FTree: TTreeView;
    TreeSplitter: TSplitter;
    InspectorPanel: TLayout;
    InspectorCard: TRectangle;
    ToolsTabs: TTabControl;
    InspectorTab: TTabItem;
    InspectorContent: TLayout;
    InspectorHeading: TLabel;
    FPropertySearch: TEdit;
    BindingActions: TLayout;
    BindingHeading: TLabel;
    BindingControls: TLayout;
    FValueReference: TComboBox;
    BindButton: TButton;
    UnbindButton: TButton;
    InspectorPropertyHost: TLayout;
    PaletteTab: TTabItem;
    PaletteContent: TLayout;
    PaletteHeading: TLabel;
    FSearch: TEdit;
    FCategory: TComboBox;
    PaletteActions: TLayout;
    AddComponentButton: TButton;
    CatalogPaletteButton: TButton;
    FPalette: TListBox;
    ComponentIcons: TImageList;
    InspectorSplitter: TSplitter;
    WorkspacePanel: TLayout;
    WorkspaceCard: TRectangle;
    WorkspaceToolbar: TLayout;
    WorkspaceHeading: TLabel;
    FSelectionLabel: TLabel;
    FCanvas: TLayout;
    FSurface: TLayout;
    FWorkBackground: TPaintBox;
    FDesignViewport: TViewport3D;
    FOutline: TRectangle;
    FHoverOutline: TRectangle;
    FResizeHandle: TRectangle;
    FResizeNW, FResizeNE, FResizeSW: TRectangle;
    FRootOutline: TRectangle;
    FGuides: TPaintBox;
    FSizeBox, FRootSizeBox: TRectangle;
    FSizeLabel, FRootSizeLabel: TLabel;
    CanvasOverlay: TPanel;
    OverlayOptions: TLayout;
    WorkspaceSettingsButton, CloseWorkspaceSettings: TButton;
    WorkspaceSettingsTitle: TLabel;
    ShowFrame, ShowGuides, ShowDimensions: TCheckBox;
    CenterView: TButton;
    WorkspaceOptions: TLayout;
    FBackgroundMode: TComboBox;
    ResourceThemeBox: TComboBox;
    FZoom: TComboBox;
    FileMenu: TPopupMenu;
    NewButton: TMenuItem;
    OpenButton: TMenuItem;
    SaveAsButton: TMenuItem;
    SystemStyleButton: TMenuItem;
    PasteStyleBookButton: TMenuItem;
    CopyStyleBookButton: TMenuItem;
    MoreMenu: TPopupMenu;
    CatalogMenuButton, CatalogMenuSeparator: TMenuItem;
    ValidateButton: TMenuItem;
    ObjectMenu: TPopupMenu;
    NewGroupButton: TMenuItem;
    RenameGroupButton: TMenuItem;
    MoveToGroupButton: TMenuItem;
    UngroupButton: TMenuItem;
    DuplicateButton: TMenuItem;
    DeleteButton: TMenuItem;
    UpButton: TMenuItem;
    DownButton: TMenuItem;
    IndentButton: TMenuItem;
    OutdentButton: TMenuItem;
    FrontButton: TMenuItem;
    BackButton: TMenuItem;
    CopyObjectButton: TMenuItem;
    PasteObjectButton: TMenuItem;
    SortStylesButton: TMenuItem;
    StyleClassButton, AutoStyleClassButton, ObjectClassSeparator: TMenuItem;
    UsedInButton: TMenuItem;
    DependenciesButton: TMenuItem;
    FileSaveSeparator, FileImportSeparator, FileClipboardSeparator: TMenuItem;
    ObjectEditSeparator, ObjectReferencesSeparator, ObjectGroupsSeparator: TMenuItem;
    ObjectSortSeparator, ObjectOrderSeparator, ObjectHierarchySeparator: TMenuItem;
    FRefreshTimer: TTimer;
    FPreviewRefreshTimer: TTimer;
    FOpenStyleDialog: TOpenDialog;
    FSaveStyleDialog: TSaveDialog;
    FImageDialog: TOpenDialog;
    StyleBookWinUI3: TStyleBook;
    ComboBoxTheme: TComboBox;
    StyleBookWinUI3Light: TStyleBook;
    procedure ShowCommandMenu(Sender: TObject);
    procedure FilterPalette(Sender: TObject);
    procedure ActionClick(Sender: TObject);
    procedure TreeChange(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure InspectorWrite(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
    procedure InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
    procedure InspectorBinding(Sender: TObject; const Path: string; var ResourceName: string);
    procedure InspectorEdit(Sender: TObject; PropertyInfo: TInspectorProperty);
    procedure PropertyFilter(Sender: TObject);
    procedure DeferredRefresh(Sender: TObject);
    procedure PaletteDblClick(Sender: TObject);
    procedure DesignDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DesignMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure DesignUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ZoomChanged(Sender: TObject);
    procedure BackgroundChanged(Sender: TObject);
    procedure ResourceThemeChanged(Sender: TObject);
    procedure PaintWorkBackground(Sender: TObject; Canvas: TCanvas);
    procedure CanvasResized(Sender: TObject);
    procedure DisplayOptionsChanged(Sender: TObject);
    procedure CenterViewClick(Sender: TObject);
    procedure PaintGuides(Sender: TObject; Canvas: TCanvas);
    procedure FormClosing(Sender: TObject; var CanClose: Boolean);
    procedure FormKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure PropertySelectionChanged(Sender: TObject);
    procedure RefreshPreview(Sender: TObject);
    procedure ComboBoxThemeChange(Sender: TObject);
    procedure WorkspaceSettingsClick(Sender: TObject);
    procedure WorkspaceFocusChanged(Sender: TObject);
    procedure WorkspaceOutsideDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    FPreferencesFile: string;
    procedure LoadApplicationTheme;
    procedure SaveApplicationTheme;
    procedure PositionWorkspaceSettings;
  private
    FProperties: TSBDPropertyInspector;
    FGroups: TObjectList<TStyleGroup>;
    FAssignments: TDictionary<string, string>;
    FStyleClasses: TDictionary<string, string>;
    FPreviewSource: TFmxObject;
    FSelectedGroup: TStyleGroup;
    FPendingProjectView: string;
    FTreeModelRoot: TFmxObject;
    FTreeItems: TDictionary<Pointer, TTreeViewItem>;
    FTreeRefreshPending: Boolean;
    FTreeViewportRestorePending: Boolean;
    FTreeRestoreViewport: TPointF;
    FTreeStableBounds: TRectF;
    FLastTreeMS, FLastInspectorMS, FLastDesignMS: Int64;
    FTreeCreatedCount: Integer;
    FLastTreePhases, FLastLoadPhases: string;
    FTreeReorderedCount, FTreeReparentedCount: Integer;
    FPreviewDirty, FDesignDirty, FSavedStatePending: Boolean;
    FRoot, FSelected, FDesignRoot, FResource: TFmxObject;
    FEntries: TObjectList<TPropertyEntry>;
    FValues: TObjectList<TNamedStyleValue>;
    FResourceTheme: TResourceTheme;
    FBindings: TObjectList<TStyleValueBinding>;
    FClasses: TDictionary<string, TFmxObjectClass>;
    FNames: TStringList;
    FUndo, FRedo: TList<TBytes>;
    FSavedState: TBytes;
    FCheckerBitmap: TBitmap;
    FCentering: Boolean;
    FPanning: Boolean;
    FPanOffset, FPanStart, FPanOrigin: TPointF;
    FWheelRemainder: Integer;
    FResizeCopy: TControl;
    FResizing: Boolean;
    FResizeSize, FDragCopyPosition: TPointF;
    FResizeCorner: Integer;
    FDragInverse: TMatrix;
    FResizeAnchor: TPointF;
    FZoomUpdating: Boolean;
    FZoomPercent: Integer;
    FCustomZoomIndex: Integer;
    FPreviewClass: TListBox;
    FPreview: TForm;
    FPreviewBook: TStyleBook;
    FPreviewHost: TLayout;
    FDragObject: TFmxObject;
    FDragStart, FDragPosition: TPointF;
    FDragSnapshot: TBytes;
    FDragging, FBuilding, FDirty: Boolean;
    FFileName: string;
    procedure WorkspaceWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure WorkspaceZoomAt(const Anchor: TPointF; WheelDelta: Integer);
    procedure SetWorkspaceZoom(Percent: Integer);
    procedure WorkspaceDeactivate(Sender: TObject);
    procedure EndWorkspacePan;
    procedure UpdateDesignHover(const FormPoint: TPointF);
    function DesignControl: TControl;
    function DesignerLayout(CreateIfMissing: Boolean): TLayout;
    function DesignerJSON: string;
    procedure UpdateDesignerMetadata(IncludeView: Boolean = False);
    procedure SetResourceTheme(Value: TResourceTheme);
    procedure SyncResourceThemeView;
    function FindGroup(const ID: string): TStyleGroup;
    function GroupOf(Resource: TFmxObject): string;
    function CreateStyleGroup(const Title, ParentID: string): TStyleGroup;
    procedure AssignToGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string);
    procedure AssignSelectionToGroup(const ParentID: string);
    function CanAssignGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string): Boolean;
    procedure GroupAction(Action: Integer);
    procedure ObjectMenuOpening(Sender: TObject);
    function FindStyleRoot(const StyleName: string): TFmxObject;
    procedure CollectStyleDependencies(Resource: TFmxObject; Names: TStrings; const UsedStyle: string = ''; Classes: TStrings = nil);
    procedure UpdateStyleReferenceMenus;
    procedure StyleReferenceClick(Sender: TObject);
    function ChooseGroup(out ID: string): Boolean;
    procedure BuildGroupedTree(const ParentID: string; Parent: TFmxObject);
    function CanDrop(SourceItem, DestItem: TTreeViewItem): Boolean;
    function DropItems(SourceItem: TTreeViewItem): TArray<TTreeViewItem>;
    function CanDropItem(SourceItem, DestItem: TTreeViewItem; AllowUnchanged: Boolean = False): Boolean;
    procedure TreeDragChange(SourceItem, DestItem: TTreeViewItem; var Allow: Boolean);
    procedure TreeCalcBounds(Sender: TObject; var Bounds: TRectF);
    procedure TreeDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure ApplyProjectView;
    function StyleResourceCount: Integer;
    procedure InitializeWorkspace;
    function SelectedPropertyIndex: Integer;
    procedure UpdateInterfaceColors;
    procedure RegisterPaletteClass(AClass: TPersistentClass);
    procedure BuildComponentIcons;
    function ComponentIcon(C: TClass): Integer;
    procedure BuildPalette;
    function AcquireTreeItem(Model: TObject; Parent: TFmxObject; Index: Integer): TTreeViewItem;
    procedure AddTree(AObject: TFmxObject; AParent: TFmxObject; AIndex: Integer = -1);
    procedure MirrorDesignProperty(PropertyInfo: TInspectorProperty);
    procedure RebuildTree;
    procedure SelectObject(AObject: TFmxObject);
    procedure SelectTreeItem(AParent: TFmxObject; AObject: TFmxObject);
    procedure BuildProperties;
    procedure RefreshDesign(Force: Boolean = False);
    procedure BindDesign(ACopy, AOriginal: TFmxObject);
    procedure ApplyTextPlaceholders(Obj: TFmxObject);
    procedure PrepareDesignGlyph(Glyph: TGlyph);
    procedure PaintGlyphPlaceholder(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure WriteStyleStream(Stream: TStream; Format: TStyleFormat);
    procedure UpdateOutline;
    procedure CenterDesign;
    procedure Remember;
    procedure Changed(ARebuild: Boolean = True; CompareSaved: Boolean = False);
    procedure UpdateCaption;
    procedure ClearHistory;
    function ConfirmDiscard: Boolean;
    procedure NewDocument;
    procedure OpenDocument;
    function SaveDocument(ASaveAs: Boolean): Boolean;
    procedure LoadDocument(const AFileName: string);
    procedure ReplaceDocument(Root: TFmxObject; const AFileName: string; ReadMilliseconds: Int64 = 0);
    function StyleBookText: string;
    procedure CopyStyleBook;
    procedure PasteStyleBook;
    function ObjectText: string;
    procedure CopyObject;
    procedure PasteObject;
    procedure PasteObjectText(const Text: string);
    procedure CreateClipboardComponent(Reader: TReader; ComponentClass: TComponentClass; var Component: TComponent);
    function ClipboardFocus: Boolean;
    procedure SaveStyle(const AFileName: string; AFormat: TStyleFormat);
    procedure AddObject(const AClassName: string);
    procedure DeleteObject;
    procedure RemoveObjectBindings(Obj: TFmxObject);
    procedure DuplicateObject;
    procedure MoveObject(AAction: Integer);
    procedure SortStyles;
    function SelectedTreeModels: TArray<TObject>;
    procedure DeleteSelection;
    procedure Undo(ARedo: Boolean);
    procedure ImportDefault;
    function SelectedStyleRoot: TFmxObject;
    function AssignedStyleClass(Resource: TFmxObject): string;
    function DetectStyleClass(Resource: TFmxObject): string;
    function IsPreviewClass(const ClassName: string): Boolean;
    procedure StoreStyleClass(Resource: TFmxObject; const ClassName: string);
    procedure AssignStyleClass(Resource: TFmxObject; const ClassName: string);
    procedure PreviewAssignClass(Sender: TObject);
    procedure ShowPreview;
    procedure ConfigureWorkspaceBackground(Brush: TBrush);
    procedure UpdateWorkspaceBackground;
    procedure RenameStyleResources(AObject: TFmxObject);
    function UniqueStyleName(const ABase: string): string;
    procedure ValidateStyle;
    procedure EditCollection(ACollection: TCollection; const APath: string);
    procedure EditBitmapLinks(Links: TBitmapLinks; const Path: string);
    procedure EditGradient(Gradient: TGradient; Brush: TBrush; const Path: string);
    function ApplyGradient(Gradient, Draft: TGradient; Brush: TBrush; const Path: string): Boolean;
    procedure EditStrings(AStrings: TStrings);
    function MetadataJSON(IncludeView: Boolean = False): string;
    procedure LoadMetadata(const Text: string);
    function FindNamedObject(const Name: string): TFmxObject;
    function ResolveProperty(Obj: TFmxObject; const Path: string): TPropertyEntry;
    procedure BindSelectedProperty;
    procedure UnbindSelectedProperty;
    procedure EditNamedValues;
    procedure ShowStyleCatalog;
    procedure CreateStyleTemplate(Catalog: TStyleCatalog; Definition: TStyleDefinition);
  protected
    procedure DoOnSettingChange; override;
  public
    function IsStyleProperty(Instance: TObject; Prop: TRttiProperty): Boolean;
    procedure DetachPropertyBinding(Obj: TFmxObject; const Path: string);
    procedure AddProperties(AInstance: TObject; const APrefix: string; ADepth: Integer; AFilter: Boolean = True);
    function PropertyText(AEntry: TPropertyEntry): string;
    procedure SetPropertyText(AEntry: TPropertyEntry; const AText: string);
    function Snapshot: TBytes;
    procedure Restore(const AState: TBytes);
    function FindValue(const Name: string): TNamedStyleValue;
    procedure ApplyBindings;
    procedure UpdateValueReferences;
    procedure ValidateNamedValue(Value: TNamedStyleValue);
    procedure ValidateBinding(Value: TNamedStyleValue; Binding: TStyleValueBinding);
    property SelectedObject: TFmxObject read FSelected;
    property PropertyEntries: TObjectList<TPropertyEntry> read FEntries;
    property NamedValues: TObjectList<TNamedStyleValue> read FValues;
    property ResourceTheme: TResourceTheme read FResourceTheme write SetResourceTheme;
    property ValueBindings: TObjectList<TStyleValueBinding> read FBindings;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseMove(Shift: TShiftState; AFormX, AFormY: Single); override;
    procedure MouseLeave; override;
    procedure SelfTest;
    procedure PerformanceTest(const FileName: string);
    function ApplyBitmapLinks(Dialog: TBitmapLinksEditorForm): Boolean;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Messaging, SBD.PropertyInspector.Tests, SBD.Localization, SBD.Preview,
  WinUI3.Style, SBD.CollectionDialog, SBD.ValuesDialog, SBD.TextDialog,
  SBD.GradientDialog, SBD.ColorDialog, SBD.StyleCatalogDialog, SBD.Dialogs,
  WinUI3.Dialogs;

{$R *.fmx}

type
  TControlAccess = class(TControl);

  TComponentAccess = class(TComponent);

  TFmxObjectAccess = class(TFmxObject);

  TStyleTreeView = class(TTreeView)
  private
    FSelecting: Boolean;
    FRangeAnchor: TTreeViewItem;
    procedure SetRangeAnchor(Value: TTreeViewItem);
  protected
    procedure DoChange; override;
    procedure SetSelected(const Value: TTreeViewItem); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function SelectedItems: TArray<TTreeViewItem>;
    procedure ChooseItem(Item: TTreeViewItem; Shift: TShiftState; RightClick: Boolean = False);
    procedure RefreshOrder;
  end;

  TClipboardStyleBook = class(TStyleBook)
  protected
    procedure Loaded; override;
  end;

  TEditorChildren = class(TList<TFmxObject>)
    procedure Collect(Child: TComponent);
  end;

  TRejectingStyleStream = class(TMemoryStream)
  public
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

const
  MinWorkspaceZoom = 50;
  MaxWorkspaceZoom = 2000;
  acNew = 1;
  acOpen = 2;
  acSave = 3;
  acSaveAs = 4;
  acDefault = 5;
  acUndo = 6;
  acRedo = 7;
  acAdd = 8;
  acDelete = 9;
  acDuplicate = 10;
  acUp = 11;
  acDown = 12;
  acIndent = 13;
  acOutdent = 14;
  acPreview = 15;
  acValidate = 16;
  acNewResource = 17;
  acValues = 18;
  acBind = 19;
  acUnbind = 20;
  acNewGroup = 21;
  acRenameGroup = 22;
  acMoveToGroup = 23;
  acUngroup = 24;
  acFront = 25;
  acBack = 26;
  acPasteStyleBook = 27;
  acCopyStyleBook = 28;
  acCopyObject = 29;
  acPasteObject = 30;
  acSortStyles = 31;
  acStyleCatalog = 32;
  acAssignStyleClass = 33;
  acAutoStyleClass = 34;

procedure UnpackStyleBinaries(Root: TFmxObject); forward;

function TreeItems(Tree: TTreeView): TArray<TTreeViewItem>; forward;

function TNamedStyleValue.ValueFor(ATheme: TResourceTheme): string;
begin
  if ATheme = rtDark then
    Result := FDarkValue
  else
    Result := FLightValue;
end;

function TNamedStyleValue.GetValue: string;
begin
  Result := ValueFor(Theme);
end;

procedure TNamedStyleValue.SetValue(const Text: string);
begin
  // Initial values and legacy callers start both themes from the same value.
  if not FInitialized then
  begin
    FLightValue := Text;
    FDarkValue := Text;
    FInitialized := True;
  end
  else if Theme = rtDark then
    FDarkValue := Text
  else
    FLightValue := Text;
end;

procedure TNamedStyleValue.SetLightValue(const Text: string);
begin
  FLightValue := Text;
  FInitialized := True;
end;

procedure TNamedStyleValue.SetDarkValue(const Text: string);
begin
  FDarkValue := Text;
  FInitialized := True;
end;

function TStyleTreeView.SelectedItems: TArray<TTreeViewItem>;
var
  Items: TList<TTreeViewItem>;
begin
  Items := TList<TTreeViewItem>.Create;
  try
    for var Item in TreeItems(Self) do
      if Item.IsSelected then
        Items.Add(Item);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

procedure TStyleTreeView.DoChange;
begin
  if not FSelecting then
    inherited;
end;

procedure TStyleTreeView.SetRangeAnchor(Value: TTreeViewItem);
begin
  if FRangeAnchor = Value then
    Exit;
  if FRangeAnchor <> nil then
    FRangeAnchor.RemoveFreeNotification(Self);
  FRangeAnchor := Value;
  if FRangeAnchor <> nil then
    FRangeAnchor.FreeNotification(Self);
end;

procedure TStyleTreeView.SetSelected(const Value: TTreeViewItem);
begin
  if FSelecting then
  begin
    inherited;
    Exit;
  end;
  FSelecting := True;
  try
    for var Item in SelectedItems do
      if Item <> Value then
        Item.IsSelected := False;
    inherited;
    SetRangeAnchor(Value);
  finally
    FSelecting := False;
  end;
  DoChange;
end;

procedure TStyleTreeView.ChooseItem(Item: TTreeViewItem; Shift: TShiftState; RightClick: Boolean);
var
  Keep, Active: TTreeViewItem;
  ToggleOff: Boolean;
  First, Last: Integer;
begin
  if Item = nil then
    Exit;
  FSelecting := True;
  try
    Active := Item;
    if (ssShift in Shift) and not RightClick and (FRangeAnchor <> nil) and
      (FRangeAnchor.Level = Item.Level) then
    begin
      First := Min(FRangeAnchor.GlobalIndex, Item.GlobalIndex);
      Last := Max(FRangeAnchor.GlobalIndex, Item.GlobalIndex);
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var I := First to Last do
      begin
        var Node := ItemByGlobalIndex(I);
        if Node.Level = Item.Level then
          Node.IsSelected := True;
      end;
    end
    else if ((ssCtrl in Shift) and not RightClick) or (RightClick and Item.IsSelected) then
    begin
      ToggleOff := (ssCtrl in Shift) and not RightClick and Item.IsSelected;
      for Keep in SelectedItems do
        if Keep.Level <> Item.Level then
          Keep.IsSelected := False;
      Item.IsSelected := not ToggleOff;
      if ToggleOff then
      begin
        Active := nil;
        for Keep in SelectedItems do
          Active := Keep;
      end;
      SetRangeAnchor(Active);
    end
    else
    begin
      for Keep in SelectedItems do
        Keep.IsSelected := False;
      Item.IsSelected := True;
      SetRangeAnchor(Item);
    end;
    inherited SetSelected(Active);
  finally
    FSelecting := False;
  end;
  DoChange;
end;

procedure TStyleTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Item, Anchor: TTreeViewItem;
  Previous: TArray<TTreeViewItem>;
  DragAllowed, KeepSelection: Boolean;
begin
  Item := ItemByPoint(X, Y);
  KeepSelection := (Item <> nil) and Item.IsSelected and
    (Button = TMouseButton.mbLeft) and ([ssCtrl, ssShift] * Shift = []);
  Previous := SelectedItems;
  Anchor := FRangeAnchor;
  DragAllowed := AllowDrag;
  FSelecting := True;
  MultiSelect := False;
  if [ssCtrl, ssShift] * Shift <> [] then
    AllowDrag := False;
  try
    inherited;
  finally
    AllowDrag := DragAllowed;
    MultiSelect := True;
    FSelecting := False;
  end;
  if (Item <> nil) and (Button in [TMouseButton.mbLeft, TMouseButton.mbRight]) then
  begin
    FSelecting := True;
    try
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var Node in Previous do
        Node.IsSelected := True;
      SetRangeAnchor(Anchor);
    finally
      FSelecting := False;
    end;
    ChooseItem(Item, Shift, (Button = TMouseButton.mbRight) or KeepSelection);
  end;
end;

procedure TStyleTreeView.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  Target: TTreeViewItem;
  Index, Direction: Integer;
begin
  if (Key = Ord('A')) and (ssCtrl in Shift) and (Selected <> nil) then
  begin
    FSelecting := True;
    try
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var I := 0 to GlobalCount - 1 do
      begin
        var Node := ItemByGlobalIndex(I);
        Node.IsSelected := (Node.Level = Selected.Level) and Node.IsVisible;
      end;
    finally
      FSelecting := False;
    end;
    Key := 0;
    DoChange;
    Exit;
  end;
  if (Selected <> nil) and (Key in [vkUp, vkDown, vkHome, vkEnd]) then
  begin
    Index := Selected.GlobalIndex;
    Direction := 1;
    if Key in [vkUp, vkHome] then
      Direction := -1;
    if Key = vkHome then
    begin
      Index := -1;
      Direction := 1;
    end
    else if Key = vkEnd then
    begin
      Index := GlobalCount;
      Direction := -1;
    end;
    Target := Selected;
    repeat
      Inc(Index, Direction);
      if (Index < 0) or (Index >= GlobalCount) then
        Break;
      var Node := ItemByGlobalIndex(Index);
      if Node.IsVisible and (not (ssShift in Shift) or (Node.Level = Selected.Level)) then
      begin
        Target := Node;
        Break;
      end;
    until False;
    ChooseItem(Target, Shift - [ssCtrl]);
    Key := 0;
    Exit;
  end;
  inherited;
end;

procedure TStyleTreeView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FRangeAnchor) then
    FRangeAnchor := nil;
  inherited;
end;

procedure TStyleTreeView.RefreshOrder;
begin
  // FMX skips global-index invalidation when row Index changes during a batch.
  // Notify the content once, before EndUpdate calculates geometry and hit tests.
  if Count > 0 then
    ContentInsertObject(0, Items[0]);
end;

function ComponentText(Component: TComponent): string;
var
  Binary: TMemoryStream;
  Text: TStringStream;
begin
  Binary := TMemoryStream.Create;
  Text := TStringStream.Create('', TEncoding.UTF8);
  try
    Binary.WriteComponent(Component);
    Binary.Position := 0;
    ObjectBinaryToText(Binary, Text);
    Result := Text.DataString;
  finally
    Text.Free;
    Binary.Free;
  end;
end;

function ClipboardService: IFMXClipboardService;
begin
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Result) then
    raise Exception.Create(Translate('Буфер обмена недоступен.'));
end;

function ClipboardText: string;
begin
  var Value := ClipboardService.GetClipboard;
  if not Value.TryAsType<string>(Result) or Result.Trim.IsEmpty then
    raise Exception.Create(Translate('Буфер обмена не содержит текст DFM/FMX.'));
end;

procedure TClipboardStyleBook.Loaded;
begin
  // This temporary component only supplies embedded styles. Do not load its
  // FileName, apply UseStyleManager or broadcast style changes to the editor.
  ChooseStyleIndex;
end;

function ReadStyleBookText(const Text: string): TFmxObject;
var
  Source: TStringStream;
  Binary: TMemoryStream;
  Reader: TReader;
  Book: TClipboardStyleBook;
  Flags: TFilerFlags;
  ChildPosition: Integer;
begin
  if Text.Trim.IsEmpty then
    raise Exception.Create(Translate('Буфер обмена не содержит текст TStyleBook.'));
  Source := TStringStream.Create(Text.Trim, TEncoding.UTF8);
  Binary := TMemoryStream.Create;
  Book := TClipboardStyleBook.Create(nil);
  try
    ObjectTextToBinary(Source, Binary);
    Binary.Position := 0;
    Reader := TReader.Create(Binary, 4096);
    try
      Reader.ReadSignature;
      Reader.ReadPrefix(Flags, ChildPosition);
      if not SameText(Reader.ReadStr, 'TStyleBook') then
        raise Exception.Create(Translate('Скопируйте компонент TStyleBook из дизайнера Delphi.'));
    finally
      Reader.Free;
    end;
    Binary.Position := 0;
    // Design-time loading also accepts styles targeting another platform.
    TComponentAccess(Book).SetDesigning(True, False);
    Reader := TReader.Create(Binary, 4096);
    try
      Reader.ReadRootComponent(Book);
    finally
      Reader.Free;
    end;
    UnpackStyleBinaries(Book.Style);
    if Book.CurrentItem.UnsupportedPlatform then
      raise Exception.Create(Translate('Не удалось загрузить встроенные данные TStyleBook.'));
    Result := Book.Style.Clone(nil);
  finally
    TComponentAccess(Book).SetDesigning(False, False);
    Book.Free;
    Binary.Free;
    Source.Free;
  end;
end;

function TRejectingStyleStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise EWriteError.Create('Deliberate serialization failure for verification');
end;

procedure UnpackStyleBinaries(Root: TFmxObject);
var
  Container: IBinaryStyleContainer;
begin
  // FMX components are freed manually. Release the interface before the caller
  // can free Root; an inline interface cast can survive until its routine exits.
  if (Root is TStyleContainer) and Supports(Root, IBinaryStyleContainer, Container) then
    Container.UnpackAllBinaries;
end;

function ChildrenOf(Obj: TFmxObject): TArray<TFmxObject>;
begin
  SetLength(Result, Obj.ChildrenCount);
  for var I := 0 to Obj.ChildrenCount - 1 do
    Result[I] := Obj.Children[I];
end;

procedure TEditorChildren.Collect(Child: TComponent);
begin
  if (Child is TFmxObject) then
    Add(TFmxObject(Child));
end;

function EditableChildren(Obj: TFmxObject): TArray<TFmxObject>;
var
  Items: TEditorChildren;
begin
  // Use the same logical hierarchy as FMX streaming. IContent containers are
  // transparent; constructor-created and style-generated objects are omitted.
  Items := TEditorChildren.Create;
  try
    TFmxObjectAccess(Obj).GetChildren(Items.Collect, nil);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

function EditableObject(Obj: TFmxObject): TFmxObject;
begin
  Result := Obj;
  while (Result <> nil) and not Result.Stored do
    Result := Result.Parent;
end;

function EditableParent(Obj: TFmxObject): TFmxObject;
begin
  Result := EditableObject(Obj.Parent);
end;

function TreeItems(Tree: TTreeView): TArray<TTreeViewItem>;
var
  Items: TList<TTreeViewItem>;

  procedure Visit(Item: TTreeViewItem);
  begin
    Items.Add(Item);
    for var I := 0 to Item.Count - 1 do
      Visit(Item.Items[I]);
  end;

begin
  Items := TList<TTreeViewItem>.Create;
  try
    for var I := 0 to Tree.Count - 1 do
      Visit(Tree.Items[I]);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

procedure SetModelDesigning(Obj: TFmxObject);
begin
  TComponentAccess(Obj).SetDesigning(True, False);
  for var Child in ChildrenOf(Obj) do
    SetModelDesigning(Child);
end;

procedure VisitStyleText(Root: TFmxObject; const Visit: TProc<TObject, TRttiProperty>);
var
  Context: TRttiContext;
  Visited: TDictionary<TObject, Boolean>;

  procedure Walk(Obj: TObject);
  begin
    if (Obj = nil) or Visited.ContainsKey(Obj) then
      Exit;
    Visited.Add(Obj, True);
    for var Prop in Context.GetType(Obj.ClassType).GetProperties do
    begin
      if (Prop.Visibility <> mvPublished) or not Prop.IsReadable then
        Continue;
      if (Prop.Name = 'Text') and Prop.IsWritable and
        (Prop.PropertyType.TypeKind in [tkString, tkLString, tkWString, tkUString]) then
        Visit(Obj, Prop);
      if Prop.PropertyType.TypeKind = tkClass then
      begin
        var Nested := Prop.GetValue(Obj).AsObject;
        // Parent, scene, style books and other components belong to separate graphs.
        if (Nested is TPersistent) and not (Nested is TComponent) then
          Walk(Nested);
      end;
    end;
    if Obj is TCollection then
      for var I := 0 to TCollection(Obj).Count - 1 do
        Walk(TCollection(Obj).Items[I]);
    if Obj is TFmxObject then
      for var I := 0 to TFmxObject(Obj).ChildrenCount - 1 do
        Walk(TFmxObject(Obj).Children[I]);
  end;

begin
  Context := TRttiContext.Create;
  Visited := TDictionary<TObject, Boolean>.Create;
  try
    Walk(Root);
  finally
    Visited.Free;
    Context.Free;
  end;
end;

function AcceptStylePlatform(const PlatformTarget: string): Boolean;
begin
  Result := True;
end;

constructor TFormMain.Create(AOwner: TComponent);
var
  Finder: TClassFinder;
begin
  FBuilding := True;
  FCustomZoomIndex := -1;
  FZoomPercent := 100;
  inherited;
  ConfigureLanguages(Language);
  TranslateForm(Self);
  if FindCmdLineSwitch('self-test') or FindCmdLineSwitch('perf-test') then
    FPreferencesFile := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-preferences.ini')
  else
    FPreferencesFile := System.IOUtils.TPath.Combine(
      System.IOUtils.TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'StyleBookDesigner'), 'preferences.ini');
  LoadApplicationTheme;
  DocumentLabel.AutoTranslate := False;
  FEntries := TObjectList<TPropertyEntry>.Create;
  FValues := TObjectList<TNamedStyleValue>.Create;
  FBindings := TObjectList<TStyleValueBinding>.Create;
  FGroups := TObjectList<TStyleGroup>.Create;
  FAssignments := TDictionary<string, string>.Create;
  FStyleClasses := TDictionary<string, string>.Create;
  FTreeItems := TDictionary<Pointer, TTreeViewItem>.Create;
  // Keep a standard TTreeView in the FMX designer; use constrained selection
  // and batched-order handling in the running editor.
  var TemplateTree := FTree;
  var StyleTree := TStyleTreeView.Create(Self);
  StyleTree.SetBounds(TemplateTree.Position.X, TemplateTree.Position.Y, TemplateTree.Width, TemplateTree.Height);
  StyleTree.Align := TemplateTree.Align;
  StyleTree.Padding.Assign(TemplateTree.Padding);
  StyleTree.Margins.Assign(TemplateTree.Margins);
  StyleTree.ItemHeight := TemplateTree.ItemHeight;
  StyleTree.StyleLookup := TemplateTree.StyleLookup;
  StyleTree.PopupMenu := TemplateTree.PopupMenu;
  StyleTree.TabOrder := TemplateTree.TabOrder;
  StyleTree.Parent := TemplateTree.Parent;
  TemplateTree.Name := '';
  TemplateTree.Free;
  StyleTree.Name := 'FTree';
  FTree := StyleTree;
  FTree.MultiSelect := True;
  FTree.OnChange := TreeChange;
  FTree.AllowDrag := True;
  FTree.ScrollAnimation := TBehaviorBoolean.True;
  FTree.OnDragChange := TreeDragChange;
  FTree.OnDragOver := TreeDragOver;
  FTree.OnCalcContentBounds := TreeCalcBounds;
  ObjectMenu.OnPopup := ObjectMenuOpening;
  FClasses := TDictionary<string, TFmxObjectClass>.Create;
  FNames := TStringList.Create;
  FNames.Sorted := True;
  FNames.Duplicates := dupIgnore;
  FUndo := TList<TBytes>.Create;
  FRedo := TList<TBytes>.Create;
  InitializeWorkspace;
  FProperties := TSBDPropertyInspector.Create(Self);
  FProperties.EmptyTextPlaceholder := 'Text';
  FProperties.ReuseStructure := True;
  FProperties.VirtualEditors := True;
  FProperties.Parent := InspectorPropertyHost;
  FProperties.Align := TAlignLayout.Client;
  FProperties.OnFilterProperty := InspectorFilter;
  FProperties.OnWriteProperty := InspectorWrite;
  FProperties.OnEditProperty := InspectorEdit;
  FProperties.OnBindingName := InspectorBinding;
  FProperties.OnSelectionChange := PropertySelectionChanged;
  FBuilding := False;
  UpdateInterfaceColors;
  Finder := TClassFinder.Create(TFmxObject, True);
  try
    Finder.GetClasses(RegisterPaletteClass);
  finally
    Finder.Free;
  end;
  EnableSmoothScrolling(Self);
  BuildComponentIcons;
  BuildPalette;
  NewDocument;
end;

destructor TFormMain.Destroy;
begin
  FBuilding := True;
  if FPreviewRefreshTimer <> nil then
    FPreviewRefreshTimer.Enabled := False;
  OnCloseQuery := nil;
  OnKeyDown := nil;
  OnFocusChanged := nil;
  ObjectMenu.OnPopup := nil;
  if FTree <> nil then
    FTree.OnChange := nil;
  if FSearch <> nil then
    FSearch.OnChangeTracking := nil;
  if FPropertySearch <> nil then
    FPropertySearch.OnChangeTracking := nil;
  if FCategory <> nil then
    FCategory.OnChange := nil;
  FreeAndNil(FProperties);
  if FZoom <> nil then
    FZoom.OnChange := nil;
  if FBackgroundMode <> nil then
    FBackgroundMode.OnChange := nil;
  if FCanvas <> nil then
    FCanvas.OnResize := nil;
  EndWorkspacePan;
  OnMouseWheel := nil;
  OnDeactivate := nil;
  if FWorkBackground <> nil then
    FWorkBackground.OnPaint := nil;
  if FPreviewClass <> nil then
    FPreviewClass.OnChange := nil;
  if FRefreshTimer <> nil then
    FRefreshTimer.Enabled := False;
  FreeAndNil(FPreview);
  FreeAndNil(FDesignRoot);
  if FDesignViewport <> nil then
    FDesignViewport.Visible := False;
  FTreeModelRoot := nil;
  FRoot.Free;
  FCheckerBitmap.Free;
  FEntries.Free;
  FValues.Free;
  FBindings.Free;
  FGroups.Free;
  FAssignments.Free;
  FStyleClasses.Free;
  FTreeItems.Free;
  FClasses.Free;
  FNames.Free;
  FUndo.Free;
  FRedo.Free;
  inherited;
end;

procedure TFormMain.InitializeWorkspace;
begin
  FCanvas.ClipChildren := True;
  FCanvas.PopupMenu := ObjectMenu;
  FCanvas.OnMouseDown := DesignDown;
  FSurface.PopupMenu := ObjectMenu;
  TControlAccess(FSurface).CanFocus := True;
  FDesignViewport.PopupMenu := ObjectMenu;
  FSurface.HitTest := True;
  FSurface.OnMouseDown := DesignDown;
  FSurface.OnMouseMove := DesignMove;
  FSurface.OnMouseUp := DesignUp;
  FDesignViewport.OnMouseDown := DesignDown;
  FDesignViewport.OnMouseMove := DesignMove;
  FDesignViewport.OnMouseUp := DesignUp;
  OnMouseWheel := WorkspaceWheel;
  OnDeactivate := WorkspaceDeactivate;
  OnFocusChanged := WorkspaceFocusChanged;
  for var Control in [FLayout, AppHeader, Toolbar, TreePanel, InspectorPanel, WorkspaceToolbar, WorkspaceOptions] do
    Control.OnMouseDown := WorkspaceOutsideDown;
  FCheckerBitmap := TBitmap.Create(24, 24);
  FCheckerBitmap.Clear($FFF2F2F2);
  if FCheckerBitmap.Canvas.BeginScene then
  try
    FCheckerBitmap.Canvas.Fill.Color := $FFCBCBCB;
    FCheckerBitmap.Canvas.FillRect(RectF(0, 0, 12, 12), 0, 0, [], 1);
    FCheckerBitmap.Canvas.FillRect(RectF(12, 12, 24, 24), 0, 0, [], 1);
  finally
    FCheckerBitmap.Canvas.EndScene;
  end;
end;

procedure TFormMain.LanguageChanged(Sender: TObject);
const
  Categories: array[0..4] of string = ('Все', 'Визуальные', 'Анимации', 'Эффекты', 'Ресурсы');
  Backgrounds: array[0..2] of string = ('Светлый фон', 'Тёмный фон', 'Прозрачность');
  Themes: array[0..1] of string = ('Светлая тема', 'Тёмная тема');
begin
  if FBuilding then
    Exit;
  FBuilding := True;
  try
    if LanguageBox.ItemIndex = 1 then
      Language.Lang := 'en-US'
    else
      Language.Lang := 'ru';
    TranslateForm(Self);
    for var I := 0 to High(Categories) do
      FCategory.Items[I] := Translate(Categories[I]);
    for var I := 0 to High(Backgrounds) do
      FBackgroundMode.Items[I] := Translate(Backgrounds[I]);
    for var I := 0 to High(Themes) do
      ResourceThemeBox.Items[I] := Translate(Themes[I]);
    FOpenStyleDialog.Filter := Translate('Стили FireMonkey|*.style|Все файлы|*.*');
    FSaveStyleDialog.Filter := Translate('Стиль FireMonkey (*.style)|*.style|Текстовый стиль (*.style)|*.style');
    FImageDialog.Filter := Translate('Изображения|*.png;*.jpg;*.jpeg;*.bmp');
    if FPreview <> nil then
      TPreviewForm(FPreview).RefreshLanguage;
  finally
    FBuilding := False;
  end;
  FProperties.RefreshLanguage;
  RebuildTree;
  UpdateCaption;
end;

procedure TFormMain.UpdateInterfaceColors;
var
  Foreground: TAlphaColorRec;
  Surface, Border: TAlphaColor;
begin
  AppTitle.ApplyStyleLookup;
  Foreground := TAlphaColorRec(AppTitle.ResultingTextSettings.FontColor);
  if (Integer(Foreground.R) + Foreground.G + Foreground.B) > 384 then
  begin
    MainBackground.Fill.Color := $FF202020;
    Surface := $FF2B2B2B;
    Border := $FF3D3D3D;
  end
  else
  begin
    MainBackground.Fill.Color := $FFF3F3F3;
    Surface := $FFFFFFFF;
    Border := $FFE5E5E5;
  end;
  MainBackground.Visible := True;
  for var Card in [TreeCard, WorkspaceCard, InspectorCard] do
  begin
    Card.Fill.Color := Surface;
    Card.Stroke.Color := Border;
  end;
end;

procedure TFormMain.RegisterPaletteClass(AClass: TPersistentClass);
var
  N: string;
begin
  N := AClass.ClassName;
  if N.StartsWith('TAbstract') or (N = 'TAnimation') or (N = 'TEffect') or
    (N = 'TFilterEffect') or (N = 'TMaterialSource') or N.StartsWith('TCustom') or (N = 'TControl') or (N = 'TStyledControl') or
    N.StartsWith('TSBD') or (N = 'TControl3D') or (N = 'TStyleContainer') or (N = 'TStyleBook') or
    (N = 'TContent') or (N = 'TPopup') or (N = 'TForm') then
    Exit;
  if AClass.InheritsFrom(TControl) or AClass.InheritsFrom(TControl3D) or
    AClass.InheritsFrom(TAnimation) or AClass.InheritsFrom(TEffect) or
    AClass.InheritsFrom(TBrushObject) or AClass.InheritsFrom(TFontObject) or
    AClass.InheritsFrom(TPathObject) or AClass.InheritsFrom(TBitmapObject) or
    AClass.InheritsFrom(TColorObject) or AClass.InheritsFrom(TStyleDescription) or
    AClass.InheritsFrom(TStyleTag) then
  begin
    FClasses.AddOrSetValue(N, TFmxObjectClass(AClass));
    FNames.Add(N);
  end;
end;

procedure TFormMain.ComboBoxThemeChange(Sender: TObject);
begin
  if FBuilding or (ComboBoxTheme.ItemIndex < 0) then
    Exit;
  DoOnSettingChange;
  try
    SaveApplicationTheme;
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

procedure TFormMain.LoadApplicationTheme;
var
  Settings: TMemIniFile;
  Index: Integer;
begin
  Settings := TMemIniFile.Create(FPreferencesFile, TEncoding.UTF8);
  try
    if not TryStrToInt(Settings.ReadString('Appearance', 'Theme', '0'), Index) or
      (Index < 0) or (Index > 2) then
      Index := 0;
    ComboBoxTheme.ItemIndex := Index;
  finally
    Settings.Free;
  end;
end;

procedure TFormMain.SaveApplicationTheme;
var
  Settings: TMemIniFile;
begin
  ForceDirectories(ExtractFilePath(FPreferencesFile));
  Settings := TMemIniFile.Create(FPreferencesFile, TEncoding.UTF8);
  try
    Settings.WriteInteger('Appearance', 'Theme', ComboBoxTheme.ItemIndex);
    Settings.UpdateFile;
  finally
    Settings.Free;
  end;
end;

procedure TFormMain.WorkspaceSettingsClick(Sender: TObject);
begin
  if Sender = CloseWorkspaceSettings then
    CanvasOverlay.Visible := False
  else
    CanvasOverlay.Visible := not CanvasOverlay.Visible;
  if CanvasOverlay.Visible then
  begin
    PositionWorkspaceSettings;
    CanvasOverlay.BringToFront;
    ShowFrame.SetFocus;
  end
  else
    WorkspaceSettingsButton.SetFocus;
end;

procedure TFormMain.WorkspaceFocusChanged(Sender: TObject);
var
  Obj: TFmxObject;
begin
  if not CanvasOverlay.Visible or (Focused = nil) then
    Exit;
  Obj := Focused.GetObject as TFmxObject;
  while Obj <> nil do
  begin
    if (Obj = CanvasOverlay) or (Obj = WorkspaceSettingsButton) then
      Exit;
    Obj := Obj.Parent;
  end;
  CanvasOverlay.Visible := False;
end;

procedure TFormMain.WorkspaceOutsideDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  CanvasOverlay.Visible := False;
end;

function TFormMain.ComponentIcon(C: TClass): Integer;
begin
  if C.InheritsFrom(TAnimation) then
    Exit(1);
  if C.InheritsFrom(TEffect) then
    Exit(2);
  if C.InheritsFrom(TStyleTag) then
    Exit(3);
  if C.InheritsFrom(TButton) or C.InheritsFrom(TSpeedButton) or C.InheritsFrom(TButtonStyleObject) then
    Exit(4);
  if C.InheritsFrom(TLabel) or C.InheritsFrom(TText) then
    Exit(5);
  if C.InheritsFrom(TMemo) then
    Exit(7);
  if C.InheritsFrom(TCustomEdit) then
    Exit(6);
  if C.InheritsFrom(TCheckBox) then
    Exit(8);
  if C.InheritsFrom(TRadioButton) then
    Exit(9);
  if C.InheritsFrom(TSwitch) then
    Exit(10);
  if C.InheritsFrom(TTrackBar) then
    Exit(11);
  if C.InheritsFrom(TProgressBar) then
    Exit(12);
  if C.InheritsFrom(TScrollBar) then
    Exit(13);
  if C.InheritsFrom(TTreeView) then
    Exit(14);
  if C.InheritsFrom(TCustomGrid) then
    Exit(15);
  if C.InheritsFrom(TCustomComboBox) then
    Exit(16);
  if C.InheritsFrom(TCustomListBox) then
    Exit(17);
  if C.InheritsFrom(TListView) then
    Exit(18);
  if C.InheritsFrom(TTabControl) or C.InheritsFrom(TTabItem) then
    Exit(19);
  if C.InheritsFrom(TImage) or C.InheritsFrom(TBitmapObject) then
    Exit(20);
  if C.InheritsFrom(TPath) or C.InheritsFrom(TPathObject) then
    Exit(21);
  if C.InheritsFrom(TCircle) or C.InheritsFrom(TEllipse) then
    Exit(22);
  if C.InheritsFrom(TLine) then
    Exit(23);
  if C.InheritsFrom(TRectangle) then
    Exit(24);
  if C.InheritsFrom(TLayout) or C.InheritsFrom(TCustomScrollBox) then
    Exit(25);
  if C.InheritsFrom(TControl3D) then
    Exit(26);
  if C.InheritsFrom(TColorObject) or C.InheritsFrom(TBrushObject) then
    Exit(27);
  if C.InheritsFrom(TFontObject) then
    Exit(28);
  if C.InheritsFrom(TStyleDescription) then
    Exit(29);
  Result := 30;
end;

procedure TFormMain.BuildComponentIcons;
var
  Bitmap: TBitmap;
  Canvas: TCanvas;

  procedure Line(X1, Y1, X2, Y2: Single);
  begin
    Canvas.DrawLine(PointF(X1, Y1), PointF(X2, Y2), 1);
  end;

  procedure Box(X, Y, W, H: Single; Radius: Single = 2);
  begin
    Canvas.DrawRect(RectF(X, Y, X + W, Y + H), Radius, Radius, AllCorners, 1);
  end;

  procedure Dot(X, Y, R: Single);
  begin
    Canvas.FillEllipse(RectF(X - R, Y - R, X + R, Y + R), 1);
  end;

begin
  Bitmap := TBitmap.Create(32, 32);
  try
    ComponentIcons.Source.BeginUpdate;
    ComponentIcons.Destination.BeginUpdate;
    try
      for var I := 0 to 30 do
      begin
        Bitmap.Clear(0);
        Canvas := Bitmap.Canvas;
        if Canvas.BeginScene then
        try
          Canvas.Stroke.Color := $FF219DEB;
          Canvas.Stroke.Thickness := 2;
          Canvas.Fill.Color := $FF219DEB;
          if I in [1, 2, 3, 27, 28, 29] then
          begin
            Canvas.Stroke.Color := $FFA878E8;
            Canvas.Fill.Color := $FFA878E8;
          end;
          case I of
            0:
              begin
                Box(3, 10, 26, 17);
                Box(3, 6, 12, 6);
              end;
            1:
              begin
                Canvas.DrawEllipse(RectF(5, 5, 27, 27), 1);
                Line(16, 8, 16, 16);
                Line(16, 16, 23, 19);
              end;
            2:
              begin
                Line(5, 27, 23, 9);
                Line(17, 5, 27, 15);
                Dot(7, 7, 2);
                Dot(27, 24, 2);
              end;
            3:
              begin
                Box(3, 8, 21, 16);
                Line(24, 8, 29, 16);
                Line(29, 16, 24, 24);
                Dot(8, 16, 2);
              end;
            4:
              begin
                Box(3, 8, 26, 16, 5);
                Line(10, 16, 22, 16);
              end;
            5, 28:
              begin
                Line(5, 7, 27, 7);
                Line(16, 7, 16, 26);
                Line(11, 26, 21, 26);
              end;
            6:
              begin
                Box(3, 8, 26, 17);
                Line(9, 12, 9, 21);
                Line(12, 21, 22, 21);
              end;
            7:
              begin
                Box(3, 4, 26, 24);
                Line(8, 10, 24, 10);
                Line(8, 16, 24, 16);
                Line(8, 22, 19, 22);
              end;
            8:
              begin
                Box(5, 5, 22, 22);
                Line(9, 16, 14, 21);
                Line(14, 21, 24, 10);
              end;
            9:
              begin
                Canvas.DrawEllipse(RectF(5, 5, 27, 27), 1);
                Dot(16, 16, 5);
              end;
            10:
              begin
                Box(3, 8, 26, 16, 8);
                Dot(11, 16, 5);
              end;
            11:
              begin
                Line(3, 16, 29, 16);
                Box(11, 8, 7, 16);
              end;
            12:
              begin
                Box(3, 11, 26, 10);
                Canvas.FillRect(RectF(6, 14, 18, 18), 0, 0, [], 1);
              end;
            13:
              begin
                Box(10, 3, 12, 26);
                Box(13, 11, 6, 10);
              end;
            14:
              begin
                Line(7, 6, 7, 25);
                Line(7, 13, 15, 13);
                Line(7, 25, 15, 25);
                Box(15, 9, 13, 8);
                Box(15, 21, 13, 8);
              end;
            15:
              begin
                Box(3, 5, 26, 22);
                Line(3, 12, 29, 12);
                Line(3, 20, 29, 20);
                Line(12, 5, 12, 27);
                Line(21, 5, 21, 27);
              end;
            16:
              begin
                Box(3, 8, 26, 16);
                Line(21, 13, 25, 17);
                Line(25, 17, 29, 13);
                Line(7, 16, 15, 16);
              end;
            17:
              begin
                Box(3, 4, 26, 24);
                for var Y in [10, 16, 22] do
                begin
                  Dot(8, Y, 1);
                  Line(12, Y, 25, Y);
                end;
              end;
            18:
              begin
                for var Y in [5, 17] do
                begin
                  Box(3, Y, 8, 9);
                  Line(15, Y + 2, 29, Y + 2);
                  Line(15, Y + 7, 25, Y + 7);
                end;
              end;
            19:
              begin
                Box(3, 10, 26, 18);
                Box(3, 4, 11, 6);
                Line(17, 5, 28, 5);
              end;
            20:
              begin
                Box(3, 5, 26, 23);
                Dot(10, 11, 2);
                Line(4, 26, 13, 17);
                Line(13, 17, 20, 24);
                Line(20, 24, 25, 19);
              end;
            21:
              begin
                Line(5, 25, 12, 7);
                Line(12, 7, 26, 24);
                Box(2, 22, 6, 6);
                Box(9, 4, 6, 6);
                Box(23, 21, 6, 6);
              end;
            22:
              Canvas.DrawEllipse(RectF(4, 4, 28, 28), 1);
            23:
              begin
                Line(4, 26, 28, 6);
                Dot(4, 26, 2);
                Dot(28, 6, 2);
              end;
            24:
              Box(4, 6, 24, 20, 0);
            25:
              begin
                Box(3, 3, 26, 26, 0);
                Line(12, 3, 12, 29);
                Line(12, 14, 29, 14);
              end;
            26:
              begin
                Line(16, 3, 28, 10);
                Line(28, 10, 28, 24);
                Line(28, 24, 16, 30);
                Line(16, 30, 4, 24);
                Line(4, 24, 4, 10);
                Line(4, 10, 16, 3);
                Line(4, 10, 16, 17);
                Line(16, 17, 28, 10);
                Line(16, 17, 16, 30);
              end;
            27:
              begin
                Canvas.FillEllipse(RectF(4, 4, 28, 28), 1);
                Canvas.Fill.Color := $FFFFFFFF;
                Dot(11, 11, 3);
                Dot(22, 15, 2);
              end;
            29:
              begin
                Box(5, 3, 22, 26);
                Line(10, 10, 22, 10);
                Line(10, 16, 22, 16);
                Line(10, 22, 19, 22);
              end;
          else
            begin
              Box(6, 6, 20, 20);
              Box(11, 11, 10, 10);
            end;
          end;
        finally
          Canvas.EndScene;
        end;
        var Source := ComponentIcons.Source.Add;
        Source.Name := 'component' + I.ToString;
        var Image := Source.MultiResBitmap.Add;
        Image.Scale := 1;
        Image.Bitmap.Assign(Bitmap);
        var Destination := ComponentIcons.Destination.Add;
        var Layer := Destination.Layers.Add;
        Layer.Name := Source.Name;
        Layer.SourceRect.Rect := RectF(0, 0, 32, 32);
      end;
    finally
      ComponentIcons.Destination.EndUpdate;
      ComponentIcons.Source.EndUpdate;
    end;
  finally
    Bitmap.Free;
  end;
  FTree.Images := ComponentIcons;
  FPalette.Images := ComponentIcons;
end;

procedure TFormMain.DoOnSettingChange;
begin
  if FBuilding or (ComboBoxTheme = nil) then
    Exit;
  var OverAccentColor := SystemAccentColor;

  // Override theme color
  case ComboBoxTheme.ItemIndex of
    0:
      ThemeKind := TSystemThemeKind.Unspecified;
    1:
      ThemeKind := TSystemThemeKind.Light;
    2:
      ThemeKind := TSystemThemeKind.Dark;
  end;

  // Set stylebook and color for theme
  if IsDark then
  begin
    // Set accent color for stylebook
    ChangeStyleBookColor(StyleBookWinUI3, OverAccentColor);
    StyleBook := StyleBookWinUI3;
  end
  else
  begin
    // Set accent color for stylebook
    ChangeStyleBookColor(StyleBookWinUI3Light, OverAccentColor);
    StyleBook := StyleBookWinUI3Light;
  end;

  inherited;

  // Set window type
  SystemBackdropType := TWindowBackdropType.Mica;
  Fill.Kind := TBrushKind.None;

  UpdateSystemBackdropType;
  UpdateInterfaceColors;

  TMessageManager.DefaultManager.SendMessage(Self, TStyleChangedMessage.Create(StyleBook, Self), True);
  TMessageManager.DefaultManager.SendMessage(Self, TInternalSettingChangedMessage.Create(StyleBook, Self), True);
end;

procedure TFormMain.BuildPalette;
var
  N: string;
  C: TFmxObjectClass;
  Category: Integer;
begin
  FPalette.BeginUpdate;
  try
    FPalette.Clear;
    Category := FCategory.ItemIndex;
    for N in FNames do
    begin
      C := FClasses[N];
      if not FSearch.Text.IsEmpty and not N.ToLower.Contains(FSearch.Text.ToLower) then
        Continue;
      if (Category = 1) and not (C.InheritsFrom(TControl) or C.InheritsFrom(TControl3D)) then
        Continue;
      if (Category = 2) and not C.InheritsFrom(TAnimation) then
        Continue;
      if (Category = 3) and not C.InheritsFrom(TEffect) then
        Continue;
      if (Category = 4) and (C.InheritsFrom(TControl) or C.InheritsFrom(TControl3D) or
        C.InheritsFrom(TAnimation) or C.InheritsFrom(TEffect)) then
        Continue;
      var Item := TListBoxItem.Create(FPalette);
      Item.Text := N;
      Item.ImageIndex := ComponentIcon(C);
      Item.Parent := FPalette;
    end;
  finally
    FPalette.EndUpdate;
  end;
end;

procedure TFormMain.FilterPalette(Sender: TObject);
begin
  if FBuilding then
    Exit;
  BuildPalette;
end;

procedure TFormMain.ShowCommandMenu(Sender: TObject);
var
  Control: TControl;
  Location: TPointF;
  Menu: TPopupMenu;
begin
  if FBuilding then
    Exit;
  Control := TControl(Sender);
  if Sender = FileButton then
    Menu := FileMenu
  else if Sender = ObjectMoreButton then
    Menu := ObjectMenu
  else
    Menu := MoreMenu;
  Location := ClientToScreen(Control.LocalToAbsolute(PointF(0, Control.Height)));
  Menu.Popup(Location.X, Location.Y);
end;

procedure TFormMain.ActionClick(Sender: TObject);
begin
  if FBuilding then
    Exit;
  try
    case TComponent(Sender).Tag of
      acNew:
        if ConfirmDiscard then
          NewDocument;
      acOpen:
        OpenDocument;
      acSave:
        SaveDocument(False);
      acSaveAs:
        SaveDocument(True);
      acDefault:
        ImportDefault;
      acPasteStyleBook:
        PasteStyleBook;
      acCopyStyleBook:
        CopyStyleBook;
      acCopyObject:
        CopyObject;
      acPasteObject:
        PasteObject;
      acSortStyles:
        SortStyles;
      acUndo:
        Undo(False);
      acRedo:
        Undo(True);
      acAdd:
        PaletteDblClick(Sender);
      acDelete:
        DeleteSelection;
      acDuplicate:
        DuplicateObject;
      acUp, acDown, acIndent, acOutdent, acFront, acBack:
        if FSelectedGroup <> nil then
          GroupAction(TComponent(Sender).Tag)
        else
          MoveObject(TComponent(Sender).Tag);
      acPreview:
        ShowPreview;
      acValidate:
        ValidateStyle;
      acValues:
        EditNamedValues;
      acStyleCatalog:
        ShowStyleCatalog;
      acAssignStyleClass:
        begin
          if (FSelected = nil) or (FSelected.Parent <> FRoot) then
            Exit;
          ShowPreview;
          TPreviewForm(FPreview).ClassSearch.SetFocus;
        end;
      acAutoStyleClass:
        AssignStyleClass(FSelected, '');
      acBind:
        BindSelectedProperty;
      acUnbind:
        UnbindSelectedProperty;
      acNewGroup, acRenameGroup, acMoveToGroup, acUngroup:
        GroupAction(TComponent(Sender).Tag);
      acNewResource:
        begin
          FSelected := FRoot;
          AddObject('TLayout');
        end;
    end;
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

function TFormMain.DesignerLayout(CreateIfMissing: Boolean): TLayout;
begin
  Result := nil;
  if FRoot = nil then
    Exit;
  for var Child in ChildrenOf(FRoot) do
    if SameText(Child.StyleName, '#designer') then
    begin
      if not (Child is TLayout) then
        raise Exception.Create(Translate('Ресурс #designer должен быть TLayout.'));
      if Result <> nil then
        raise Exception.Create(Translate('Повтор служебного ресурса #designer.'));
      Result := TLayout(Child);
    end;
  if (Result = nil) and CreateIfMissing then
  begin
    Result := TLayout.Create(nil);
    Result.StyleName := '#designer';
    Result.Visible := False;
    Result.HitTest := False;
    Result.Width := 0;
    Result.Height := 0;
    Result.Parent := FRoot;
    SetModelDesigning(Result);
  end;
end;

function TFormMain.DesignerJSON: string;
begin
  Result := '';
  var Layout := DesignerLayout(False);
  if Layout = nil then
    Exit;
  for var Child in ChildrenOf(Layout) do
    if (Child is TStyleTag) and SameText(Child.StyleName, 'project') then
    begin
      Result := Child.TagString;
      if Result.IsEmpty then
        raise Exception.Create(Translate('Пустые данные проекта #designer.'));
      Exit;
    end;
  raise Exception.Create(Translate('В #designer отсутствует TStyleTag project.'));
end;

procedure TFormMain.UpdateDesignerMetadata(IncludeView: Boolean);
var
  Tag: TStyleTag;
begin
  var Layout := DesignerLayout(True);
  // Always keep the hidden service resource last; resource indices remain stable.
  Layout.Index := FRoot.ChildrenCount - 1;
  for var Key in FAssignments.Keys.ToArray do
  begin
    var Obj := FindNamedObject(Key);
    if (Obj = nil) or (Obj.Parent <> FRoot) or (FindGroup(FAssignments[Key]) = nil) then
      FAssignments.Remove(Key);
  end;
  Tag := nil;
  for var Child in ChildrenOf(Layout) do
    if (Child is TStyleTag) and SameText(Child.StyleName, 'project') then
      Tag := TStyleTag(Child);
  if Tag = nil then
  begin
    Tag := TStyleTag.Create(nil);
    Tag.StyleName := 'project';
    Tag.Parent := Layout;
    SetModelDesigning(Tag);
  end;
  for var Key in FStyleClasses.Keys.ToArray do
  begin
    var Resource := FindNamedObject(Key);
    if (Resource = nil) or (Resource.Parent <> FRoot) or SameText(Resource.StyleName, '#designer') then
      FStyleClasses.Remove(Key);
  end;
  Tag.TagString := MetadataJSON(IncludeView);
end;

function TFormMain.StyleResourceCount: Integer;
begin
  Result := 0;
  for var Child in ChildrenOf(FRoot) do
    if not SameText(Child.StyleName, '#designer') then
      Inc(Result);
end;

function TFormMain.FindGroup(const ID: string): TStyleGroup;
begin
  Result := nil;
  for var StyleGroup in FGroups do
    if StyleGroup.ID = ID then
      Exit(StyleGroup);
end;

function TFormMain.GroupOf(Resource: TFmxObject): string;
begin
  Result := '';
  if Resource <> nil then
    FAssignments.TryGetValue(Resource.Name, Result);
end;

function TFormMain.CreateStyleGroup(const Title, ParentID: string): TStyleGroup;
begin
  if Trim(Title).IsEmpty then
    raise Exception.Create(Translate('Задайте название группы.'));
  if not ParentID.IsEmpty and (FindGroup(ParentID) = nil) then
    raise Exception.Create(Translate('Группа не найдена.'));
  Remember;
  Result := TStyleGroup.Create;
  Result.ID := TGUID.NewGuid.ToString;
  Result.Title := Trim(Title);
  Result.ParentID := ParentID;
  FGroups.Add(Result);
  FSelected := nil;
  FSelectedGroup := Result;
  Changed;
end;

function TFormMain.CanAssignGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string): Boolean;
begin
  Result := False;
  if not ParentID.IsEmpty and (FindGroup(ParentID) = nil) then
    Exit;
  if StyleGroup <> nil then
  begin
    var ID := ParentID;
    while not ID.IsEmpty do
    begin
      if ID = StyleGroup.ID then
        Exit;
      var Parent := FindGroup(ID);
      if Parent = nil then
        Exit;
      ID := Parent.ParentID;
    end;
    Result := StyleGroup.ParentID <> ParentID;
  end
  else
    Result := (Obj <> nil) and (Obj.Parent = FRoot) and
      not SameText(Obj.StyleName, '#designer') and (GroupOf(Obj) <> ParentID);
end;

procedure TFormMain.AssignToGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string);
begin
  if not CanAssignGroup(Obj, StyleGroup, ParentID) then
    Exit;
  Remember;
  if StyleGroup <> nil then
    StyleGroup.ParentID := ParentID
  else if ParentID.IsEmpty then
    FAssignments.Remove(Obj.Name)
  else
  begin
    if (Obj.Name = '') then
      Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
    FAssignments.AddOrSetValue(Obj.Name, ParentID);
  end;
  FSelected := FRoot;
  FSelectedGroup := nil;
  Changed(False);
  FTreeRefreshPending := True;
  // A drop callback still holds tree nodes. Rebuild after it returns.
  FRefreshTimer.Enabled := True;
end;

procedure TFormMain.AssignSelectionToGroup(const ParentID: string);
var
  DestItem: TTreeViewItem;
  Allow: Boolean;
begin
  // The menu groups resources and groups; promotion of nested objects is a drop operation.
  for var Model in SelectedTreeModels do
    if not (Model is TStyleGroup) and
      (not (Model is TFmxObject) or (TFmxObject(Model).Parent <> FRoot)) then
      Exit;
  DestItem := nil;
  if not ParentID.IsEmpty then
    if not FTreeItems.TryGetValue(Pointer(FindGroup(ParentID)), DestItem) then
      Exit;
  Allow := False;
  TreeDragChange(FTree.Selected, DestItem, Allow);
end;

procedure TFormMain.BuildGroupedTree(const ParentID: string; Parent: TFmxObject);
begin
  var Index := 0;
  for var StyleGroup in FGroups do
    if StyleGroup.ParentID = ParentID then
    begin
      var IsNew := not FTreeItems.ContainsKey(Pointer(StyleGroup));
      var Item := AcquireTreeItem(StyleGroup, Parent, Index);
      Inc(Index);
      var Text := StyleGroup.Title + Translate(' (группа)');
      if Item.Text <> Text then
        Item.Text := Text;
      Item.TagObject := StyleGroup;
      Item.ImageIndex := 0;
      Item.TagString := '$group/' + StyleGroup.ID;
      if IsNew then
        Item.IsExpanded := True;
      BuildGroupedTree(StyleGroup.ID, Item);
    end;
  for var Child in ChildrenOf(FRoot) do
    if not SameText(Child.StyleName, '#designer') and (GroupOf(Child) = ParentID) then
    begin
      AddTree(Child, Parent, Index);
      Inc(Index);
    end;
end;

procedure TFormMain.TreeCalcBounds(Sender: TObject; var Bounds: TRectF);
begin
  // Native TreeView reports empty bounds while BeginUpdate holds its rows.
  // Keep the previous scroll limits until the final layout is calculated.
  if TControlAccess(FTree).IsUpdating then
    Bounds := FTreeStableBounds;
end;

function TFormMain.DropItems(SourceItem: TTreeViewItem): TArray<TTreeViewItem>;
begin
  Result := nil;
  if SourceItem = nil then
    Exit;
  if SourceItem.IsSelected then
    Result := TStyleTreeView(FTree).SelectedItems
  else
    Result := [SourceItem];
end;

function TFormMain.CanDrop(SourceItem, DestItem: TTreeViewItem): Boolean;
var
  Changes: Boolean;
begin
  Result := False;
  Changes := False;
  for var Item in DropItems(SourceItem) do
  begin
    if not CanDropItem(Item, DestItem, True) then
      Exit;
    Changes := Changes or CanDropItem(Item, DestItem);
  end;
  Result := Changes;
end;

function TFormMain.CanDropItem(SourceItem, DestItem: TTreeViewItem; AllowUnchanged: Boolean): Boolean;
var
  Obj, Target, Ancestor: TFmxObject;
  ParentID: string;
begin
  Result := False;
  if (SourceItem = nil) or (SourceItem = DestItem) then
    Exit;
  ParentID := '';
  if (DestItem = nil) or (DestItem.TagObject is TStyleGroup) then
  begin
    if DestItem <> nil then
      ParentID := TStyleGroup(DestItem.TagObject).ID;
    if SourceItem.TagObject is TStyleGroup then
      Exit(CanAssignGroup(nil, TStyleGroup(SourceItem.TagObject), ParentID) or
        (AllowUnchanged and (TStyleGroup(SourceItem.TagObject).ParentID = ParentID)));
    if not (SourceItem.TagObject is TFmxObject) then
      Exit;
    Obj := TFmxObject(SourceItem.TagObject);
    if Obj.Parent = FRoot then
      Exit(CanAssignGroup(Obj, nil, ParentID) or
        (AllowUnchanged and not SameText(Obj.StyleName, '#designer') and (GroupOf(Obj) = ParentID)));
    Exit((Obj <> FRoot) and ((Obj is TControl) or (Obj is TControl3D)));
  end;
  if not (SourceItem.TagObject is TFmxObject) or not (DestItem.TagObject is TFmxObject) then
    Exit;
  Obj := TFmxObject(SourceItem.TagObject);
  Target := TFmxObject(DestItem.TagObject);
  if (Obj = FRoot) or SameText(Obj.StyleName, '#designer') or SameText(Target.StyleName, '#designer') then
    Exit;
  if not ((Target is TControl) or (Target is TControl3D)) then
    Exit;
  if ((Obj is TControl3D) and not (Target is TControl3D)) or
    ((Obj is TControl) and (Target is TControl3D)) then
    Exit;
  Ancestor := Target;
  while Ancestor <> nil do
  begin
    if Ancestor = Obj then
      Exit;
    Ancestor := Ancestor.Parent;
  end;
  Result := AllowUnchanged or (EditableParent(Obj) <> Target);
end;

procedure TFormMain.TreeDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.None;
  if (Data.Source is TTreeViewItem) and
    CanDrop(TTreeViewItem(Data.Source), FTree.ItemByPoint(Point.X, Point.Y)) then
    Operation := TDragOperation.Move;
end;

procedure TFormMain.TreeDragChange(SourceItem, DestItem: TTreeViewItem; var Allow: Boolean);
var
  Obj, Target: TFmxObject;
  ParentID: string;
  Items: TArray<TTreeViewItem>;
begin
  // The model owns parenting; update rows after native DragDrop releases them.
  Allow := False;
  if not CanDrop(SourceItem, DestItem) then
    Exit;
  Items := DropItems(SourceItem);
  ParentID := '';
  if (DestItem = nil) or (DestItem.TagObject is TStyleGroup) then
  begin
    if DestItem <> nil then
      ParentID := TStyleGroup(DestItem.TagObject).ID;
    Target := FRoot;
  end
  else
  begin
    Target := TFmxObject(DestItem.TagObject);
  end;
  Remember;
  for var Item in Items do
  begin
    if not CanDropItem(Item, DestItem) then
      Continue;
    if Item.TagObject is TStyleGroup then
    begin
      TStyleGroup(Item.TagObject).ParentID := ParentID;
      Continue;
    end;
    Obj := TFmxObject(Item.TagObject);
    if EditableParent(Obj) <> Target then
    begin
      if Target = FRoot then
      begin
        var Name := Obj.StyleName;
        if Name.IsEmpty then
          Name := Copy(Obj.ClassName, 2, MaxInt).ToLower + 'style';
        Obj.StyleName := UniqueStyleName(Name);
      end;
      Obj.Parent := Target;
      FDesignDirty := True;
    end;
    FAssignments.Remove(Obj.Name);
    if (Target = FRoot) and not ParentID.IsEmpty then
    begin
      if Obj.Name = '' then
        Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
      FAssignments.AddOrSetValue(Obj.Name, ParentID);
    end;
  end;
  // Reselecting a moved row would make FMX expand the destination group.
  FSelected := FRoot;
  FSelectedGroup := nil;
  Changed(False);
  FTreeRefreshPending := True;
  FRefreshTimer.Enabled := True;
end;

function TFormMain.ChooseGroup(out ID: string): Boolean;
var
  Dialog: TFrame;
  Combo: TComboBox;
  IDs: TList<string>;

  function GroupPath(StyleGroup: TStyleGroup): string;
  begin
    Result := StyleGroup.Title;
    while not StyleGroup.ParentID.IsEmpty do
    begin
      StyleGroup := FindGroup(StyleGroup.ParentID);
      Result := StyleGroup.Title + ' / ' + Result;
    end;
  end;

begin
  Result := False;
  IDs := TList<string>.Create;
  Dialog := TFrame.Create(nil);
  try
    Dialog.Width := 432;
    Dialog.Height := 40;
    Combo := TComboBox.Create(Dialog);
    Combo.ListBox.ScrollAnimation := TBehaviorBoolean.True;
    Combo.Parent := Dialog;
    Combo.Align := TAlignLayout.Client;
    Combo.ItemHeight := Combo.Height;
    Combo.ItemHeight := Combo.Height;
    Combo.Items.Add(Translate('Без группы'));
    IDs.Add('');
    for var StyleGroup in FGroups do
      if CanAssignGroup(FSelected, FSelectedGroup, StyleGroup.ID) then
      begin
        Combo.Items.Add(GroupPath(StyleGroup));
        IDs.Add(StyleGroup.ID);
      end;
    Combo.ItemIndex := 0;
    if (TWinUIDialog.Show(Self, Translate('Переместить в группу'), Dialog,
      [Translate('Переместить'), Translate('Отмена')], 0, 0, True) = 0) and
      (Combo.ItemIndex >= 0) then
    begin
      ID := IDs[Combo.ItemIndex];
      Result := True;
    end;
  finally
    Dialog.Free;
    IDs.Free;
  end;
end;

function TFormMain.FindStyleRoot(const StyleName: string): TFmxObject;
begin
  Result := nil;
  if (FRoot = nil) or StyleName.IsEmpty or SameText(StyleName, '#designer') then
    Exit;
  for var Resource in ChildrenOf(FRoot) do
    if SameText(Resource.StyleName, StyleName) then
      Exit(Resource);
end;

procedure TFormMain.CollectStyleDependencies(Resource: TFmxObject; Names: TStrings; const UsedStyle: string; Classes: TStrings);

  procedure AddUse(const Name, ClassName: string);
  begin
    if Name.IsEmpty then
      Exit;
    if Names.IndexOf(Name) < 0 then
      Names.Add(Name);
    if (Classes <> nil) and SameText(Name, UsedStyle) and
      (Classes.IndexOf(ClassName) < 0) then
      Classes.Add(ClassName);
  end;

  procedure Visit(Obj: TFmxObject);
  begin
    if Obj is TStyledControl then
    begin
      var Control := TStyledControl(Obj);
      var Lookup := Control.StyleLookup;
      if Lookup.IsEmpty then
        Lookup := Control.DefaultStyleLookupName;
      AddUse(Lookup, Obj.ClassName);
    end;
    // Bitmap style objects resolve their source image by name at runtime.
    if Obj is TCustomStyleObject then
      AddUse(TCustomStyleObject(Obj).SourceLookup, Obj.ClassName);
    // Masked images expose the lookup of their internal (unstored) style object.
    if Obj is TMaskedImage then
      AddUse(TMaskedImage(Obj).SourceLookup, Obj.ClassName);
    // FMX creates list items at runtime. Their styles live in the list settings,
    // even when no item has been serialized in the book (calendar days, for example).
    if Obj is TCustomListBox then
    begin
      var Defaults := TCustomListBox(Obj).DefaultItemStyles;
      AddUse(Defaults.ItemStyle, 'TListBoxItem');
      AddUse(Defaults.GroupHeaderStyle, 'TListBoxGroupHeader');
      AddUse(Defaults.GroupFooterStyle, 'TListBoxGroupFooter');
      if (Classes <> nil) and SameText(Defaults.ItemStyle, UsedStyle) and
        SameText(Obj.StyleName, 'days') and SameText(DetectStyleClass(Resource), 'TCalendar') then
        AddUse(Defaults.ItemStyle, 'TDayItem');
    end;
    if Obj is TColumn then
      AddUse(TColumn(Obj).HeaderSettings.StyleLookup, 'TGridHeaderItem');
    if Obj is TCustomMultiView then
      AddUse(TCustomMultiView(Obj).PopoverOptions.StyleLookup, 'TCustomPopover');
    for var Child in EditableChildren(Obj) do
      Visit(Child);
  end;

begin
  Names.Clear;
  if Resource <> nil then
    Visit(Resource);
end;

procedure TFormMain.UpdateStyleReferenceMenus;
var
  Dependencies, Users, Names, Classes, OwnerClasses: TStringList;
  Catalog: TStyleCatalog;

  procedure AddOwnerClasses(Resource: TFmxObject);
  begin
    var AssignedClass := AssignedStyleClass(Resource);
    if not AssignedClass.IsEmpty and (Classes.IndexOf(AssignedClass) < 0) then
      Classes.Add(AssignedClass);
    // Indexed and named variants of standard resources retain their owner class.
    var Name := Resource.StyleName.ToLower;
    for var Definition in Catalog.Definitions do
      if not Definition.DefaultStyleName.IsEmpty and not Definition.ClassName.StartsWith('@') then
      begin
        var Base := Definition.DefaultStyleName.ToLower;
        if SameText(Name, Base) or Name.StartsWith(Base + '_') or
          (Name.StartsWith(Base) and (Name.Length > Base.Length) and
          CharInSet(Name[Base.Length + 1], ['0'..'9'])) then
          if Classes.IndexOf(Definition.ClassName) < 0 then
            Classes.Add(Definition.ClassName);
      end;
    Catalog.ControlsUsingStyle(Resource.StyleName, OwnerClasses, False);
    for var ClassName in OwnerClasses do
      if Classes.IndexOf(ClassName) < 0 then
        Classes.Add(ClassName);
  end;

  procedure FillMenu(Menu: TMenuItem; Items: TStrings; const EmptyText: string);
  begin
    for var Name in Items do
    begin
      var Item := TMenuItem.Create(Menu);
      Item.Parent := Menu;
      Item.TagString := Name;
      var Resource := FindStyleRoot(Name);
      Item.Enabled := Resource <> nil;
      if Resource <> nil then
        Item.Text := Resource.StyleName
      else
        Item.Text := Name + Translate(' (стиль отсутствует в книге)');
      Item.OnClick := StyleReferenceClick;
    end;
    if Items.Count = 0 then
    begin
      var Item := TMenuItem.Create(Menu);
      Item.Parent := Menu;
      Item.Text := Translate(EmptyText);
      Item.Enabled := False;
    end;
  end;

begin
  UsedInButton.Clear;
  DependenciesButton.Clear;
  var Available := (FSelectedGroup = nil) and (FSelected <> nil) and
    (FSelected <> FRoot) and (FSelected.Parent = FRoot) and
    not SameText(FSelected.StyleName, '#designer') and (Length(SelectedTreeModels) <= 1);
  UsedInButton.Enabled := Available and not FSelected.StyleName.IsEmpty;
  DependenciesButton.Enabled := Available;
  if not Available then
    Exit;
  Dependencies := TStringList.Create;
  Users := TStringList.Create;
  Names := TStringList.Create;
  Classes := TStringList.Create;
  OwnerClasses := TStringList.Create;
  Catalog := TStyleCatalog.Create;
  try
    Dependencies.CaseSensitive := False;
    Dependencies.Sorted := True;
    Users.CaseSensitive := False;
    Users.Sorted := True;
    Names.CaseSensitive := False;
    Classes.CaseSensitive := False;
    Classes.Sorted := True;
    Classes.Duplicates := dupIgnore;
    Catalog.ControlsUsingStyle(FSelected.StyleName, Classes);
    CollectStyleDependencies(FSelected, Dependencies);
    if UsedInButton.Enabled then
      for var Resource in ChildrenOf(FRoot) do
        if not SameText(Resource.StyleName, '#designer') then
        begin
          CollectStyleDependencies(Resource, Names, FSelected.StyleName, Classes);
          if (Names.IndexOf(FSelected.StyleName) >= 0) and (Users.IndexOf(Resource.StyleName) < 0) then
          begin
            Users.Add(Resource.StyleName);
            AddOwnerClasses(Resource);
          end;
        end;
    FillMenu(UsedInButton, Users, 'Нет использующих стилей');
    var Separator := TMenuItem.Create(UsedInButton);
    Separator.Parent := UsedInButton;
    Separator.Text := '-';
    for var ClassName in Classes do
    begin
      var Item := TMenuItem.Create(UsedInButton);
      Item.Parent := UsedInButton;
      Item.Text := ClassName;
      Item.Enabled := False;
    end;
    if Classes.Count = 0 then
    begin
      var Item := TMenuItem.Create(UsedInButton);
      Item.Parent := UsedInButton;
      Item.Text := Translate('Нет известных классов контролов');
      Item.Enabled := False;
    end;
    FillMenu(DependenciesButton, Dependencies, 'Нет зависимостей');
  finally
    Catalog.Free;
    OwnerClasses.Free;
    Classes.Free;
    Names.Free;
    Users.Free;
    Dependencies.Free;
  end;
end;

procedure TFormMain.StyleReferenceClick(Sender: TObject);
begin
  // Resolve by name at click time: undo or document replacement can free roots.
  var Resource := FindStyleRoot(TMenuItem(Sender).TagString);
  if Resource <> nil then
    SelectObject(Resource);
end;

procedure TFormMain.ObjectMenuOpening(Sender: TObject);
begin
  UpdateStyleReferenceMenus;
  var Multiple := Length(SelectedTreeModels) > 1;
  var IsGroup := FSelectedGroup <> nil;
  var IsResource := (FSelected <> nil) and (FSelected.Parent = FRoot);
  StyleClassButton.Enabled := IsResource and not IsGroup and not Multiple and
    not SameText(FSelected.StyleName, '#designer');
  AutoStyleClassButton.Enabled := StyleClassButton.Enabled and not AssignedStyleClass(FSelected).IsEmpty;
  StyleClassButton.Text := Translate('Класс контрола…');
  if StyleClassButton.Enabled and not AssignedStyleClass(FSelected).IsEmpty then
    StyleClassButton.Text := StyleClassButton.Text + ' (' + AssignedStyleClass(FSelected) + ')';
  RenameGroupButton.Enabled := IsGroup and not Multiple;
  MoveToGroupButton.Enabled := IsGroup or IsResource;
  UngroupButton.Enabled := (IsGroup and not FSelectedGroup.ParentID.IsEmpty) or
    (IsResource and not GroupOf(FSelected).IsEmpty);
  DuplicateButton.Enabled := (FSelected <> nil) and (FSelected <> FRoot);
  CopyObjectButton.Enabled := DuplicateButton.Enabled;
  PasteObjectButton.Enabled := (FSelected = nil) or (FSelected = FRoot) or
    (FSelected is TControl) or (FSelected is TControl3D);
  SortStylesButton.Enabled := StyleResourceCount > 1;
  FrontButton.Enabled := DuplicateButton.Enabled;
  BackButton.Enabled := DuplicateButton.Enabled;
  DeleteButton.Enabled := IsGroup or DuplicateButton.Enabled;
  IndentButton.Enabled := not IsGroup and DuplicateButton.Enabled;
  OutdentButton.Enabled := IsGroup or DuplicateButton.Enabled;
  if Multiple then
  begin
    MoveToGroupButton.Enabled := True;
    UngroupButton.Enabled := False;
    for var Model in SelectedTreeModels do
      if Model is TStyleGroup then
        UngroupButton.Enabled := UngroupButton.Enabled or not TStyleGroup(Model).ParentID.IsEmpty
      else if (Model is TFmxObject) and (TFmxObject(Model).Parent = FRoot) then
        UngroupButton.Enabled := UngroupButton.Enabled or not GroupOf(TFmxObject(Model)).IsEmpty
      else
        MoveToGroupButton.Enabled := False;
    UngroupButton.Enabled := UngroupButton.Enabled and MoveToGroupButton.Enabled;
    UpButton.Enabled := False;
    DownButton.Enabled := False;
    FrontButton.Enabled := False;
    BackButton.Enabled := False;
    IndentButton.Enabled := False;
    OutdentButton.Enabled := False;
    DeleteButton.Enabled := True;
    CopyObjectButton.Enabled := True;
    for var Model in SelectedTreeModels do
      if not (Model is TFmxObject) then
        CopyObjectButton.Enabled := False;
    DuplicateButton.Enabled := CopyObjectButton.Enabled;
  end
  else
  begin
    UpButton.Enabled := True;
    DownButton.Enabled := True;
  end;
  if IsGroup then
    DeleteButton.Text := Translate('Удалить группу, сохранив стили')
  else
    DeleteButton.Text := Translate('Удалить');
end;

procedure TFormMain.GroupAction(Action: Integer);
var
  ID, Title: string;
  Index, Other: Integer;
  Titles: array[0..0] of string;
begin
  case Action of
    acNewGroup:
      begin
        ID := '';
        if FSelectedGroup <> nil then
          ID := FSelectedGroup.ID
        else if FSelected <> nil then
        begin
          var Resource := FSelected;
          while (Resource.Parent <> nil) and (Resource.Parent <> FRoot) do
            Resource := Resource.Parent;
          ID := GroupOf(Resource);
        end;
        Title := Translate('Новая группа');
        Titles[0] := Title;
        if AskAppText(Self, Translate('Группа стилей'), Translate('Название'), Titles[0]) then
          CreateStyleGroup(Titles[0], ID);
      end;
    acRenameGroup:
      if FSelectedGroup <> nil then
      begin
        Title := FSelectedGroup.Title;
        Titles[0] := Title;
        if AskAppText(Self, Translate('Название группы'), Translate('Название'), Titles[0]) and not Trim(Titles[0]).IsEmpty and
          (Trim(Titles[0]) <> FSelectedGroup.Title) then
        begin
          Remember;
          FSelectedGroup.Title := Trim(Titles[0]);
          Changed;
        end;
      end;
    acMoveToGroup:
      if (FSelectedGroup <> nil) or ((FSelected <> nil) and (FSelected.Parent = FRoot)) then
        if ChooseGroup(ID) then
          AssignSelectionToGroup(ID);
    acUngroup:
      AssignSelectionToGroup('');
    acOutdent:
      if FSelectedGroup <> nil then
      begin
        var Parent := FindGroup(FSelectedGroup.ParentID);
        if Parent <> nil then
          AssignToGroup(nil, FSelectedGroup, Parent.ParentID);
      end;
    acDelete:
      if FSelectedGroup <> nil then
      begin
        Remember;
        ID := FSelectedGroup.ID;
        var ParentID := FSelectedGroup.ParentID;
        for var StyleGroup in FGroups do
          if StyleGroup.ParentID = ID then
            StyleGroup.ParentID := ParentID;
        for var Key in FAssignments.Keys.ToArray do
          if FAssignments[Key] = ID then
            if ParentID.IsEmpty then
              FAssignments.Remove(Key)
            else
              FAssignments.AddOrSetValue(Key, ParentID);
        var StyleGroup := FSelectedGroup;
        FSelectedGroup := nil;
        FSelected := FRoot;
        FGroups.Remove(StyleGroup);
        Changed;
      end;
    acUp, acDown:
      if FSelectedGroup <> nil then
      begin
        Index := FGroups.IndexOf(FSelectedGroup);
        Other := Index;
        repeat
          if Action = acUp then
            Dec(Other)
          else
            Inc(Other);
        until (Other < 0) or (Other >= FGroups.Count) or (FGroups[Other].ParentID = FSelectedGroup.ParentID);
        if (Other >= 0) and (Other < FGroups.Count) then
        begin
          Remember;
          FGroups.Exchange(Index, Other);
          Changed;
        end;
      end;
  end;
end;

procedure TFormMain.ApplyProjectView;
var
  JSON: TJSONObject;
begin
  if FPendingProjectView.IsEmpty then
    Exit;
  FTreeViewportRestorePending := False;
  JSON := TJSONObject.ParseJSONValue(FPendingProjectView) as TJSONObject;
  FPendingProjectView := '';
  try
    TreePanel.Width := EnsureRange(JSON.GetValue<Double>('treeWidth', TreePanel.Width), 180, 600);
    InspectorPanel.Width := EnsureRange(JSON.GetValue<Double>('inspectorWidth', InspectorPanel.Width), 280, 650);
    ToolsTabs.TabIndex := EnsureRange(JSON.GetValue<Integer>('tab', 0), 0, ToolsTabs.TabCount - 1);
    FPropertySearch.Text := JSON.GetValue<string>('propertyFilter', '');
    FSearch.Text := JSON.GetValue<string>('paletteFilter', '');
    FCategory.ItemIndex := EnsureRange(JSON.GetValue<Integer>('paletteCategory', 0), 0, FCategory.Items.Count - 1);
    FBackgroundMode.ItemIndex := EnsureRange(JSON.GetValue<Integer>('background', 0), 0, FBackgroundMode.Items.Count - 1);
    ShowFrame.IsChecked := JSON.GetValue<Boolean>('showFrame', True);
    ShowGuides.IsChecked := JSON.GetValue<Boolean>('showGuides', True);
    ShowDimensions.IsChecked := JSON.GetValue<Boolean>('showDimensions', True);
    var Expanded := JSON.GetValue<TJSONArray>('expanded');
    var Selected := JSON.GetValue<string>('selected', '');
    FBuilding := True;
    try
      for var Item in TreeItems(FTree) do
        if Item.TagString = Selected then
          FTree.Selected := Item;
      if FTree.Selected <> nil then
      begin
        if FTree.Selected.TagObject is TStyleGroup then
        begin
          FSelected := nil;
          FSelectedGroup := TStyleGroup(FTree.Selected.TagObject);
        end
        else
        begin
          FSelectedGroup := nil;
          FSelected := TFmxObject(FTree.Selected.TagObject);
        end;
      end;
      if Expanded <> nil then
        for var Item in TreeItems(FTree) do
        begin
          var Open := False;
          for var Key in Expanded do
            if Key.Value = Item.TagString then
              Open := True;
          Item.IsExpanded := Open;
        end;
    finally
      FBuilding := False;
    end;
    BuildProperties;
    RefreshDesign;
    SetWorkspaceZoom(JSON.GetValue<Integer>('zoom', 100));
    FPanOffset := PointF(JSON.GetValue<Double>('panX', 0), JSON.GetValue<Double>('panY', 0));
    CenterDesign;
    FProperties.NameColumnRatio := JSON.GetValue<Double>('columnRatio', 0.46);
    FProperties.SelectPath(JSON.GetValue<string>('property', ''));
    var PropertyExpanded := JSON.GetValue<TJSONArray>('propertyExpanded', nil);
    if PropertyExpanded <> nil then
      for var Node in TreeItems(FProperties.Tree) do
      begin
        var Open := False;
        for var Key in PropertyExpanded do
          if Key.Value = TInspectorProperty(Node.TagObject).Path then
            Open := True;
        Node.IsExpanded := Open;
      end;
    FValueReference.ItemIndex := FValueReference.Items.IndexOf(JSON.GetValue<string>('selectedValue', ''));
    FProperties.Tree.RealignContent;
    FProperties.Tree.ViewportPosition := PointF(0, JSON.GetValue<Double>('propertyY', 0));
    FTree.RealignContent;
    FTree.ViewportPosition := PointF(JSON.GetValue<Double>('treeX', 0), JSON.GetValue<Double>('treeY', 0));
  finally
    JSON.Free;
  end;
end;

function TFormMain.AcquireTreeItem(Model: TObject; Parent: TFmxObject; Index: Integer): TTreeViewItem;
begin
  if not FTreeItems.TryGetValue(Pointer(Model), Result) then
  begin
    Result := TSBDTreeViewItem.Create(Self);
    Result.AutoTranslate := False;
    Inc(FTreeCreatedCount);
    FTreeItems.Add(Pointer(Model), Result);
    Result.TagObject := Model;
    Result.Parent := Parent;
  end
  else if ((Parent is TTreeViewItem) and (Result.ParentItem <> Parent)) or
    ((Parent is TTreeView) and (Result.ParentItem <> nil)) then
  begin
    Inc(FTreeReparentedCount);
    Result.Parent := Parent;
  end;
  if (Index >= 0) and (Result.Index <> Index) then
  begin
    Inc(FTreeReorderedCount);
    Result.Index := Index;
  end;
end;

procedure TFormMain.AddTree(AObject: TFmxObject; AParent: TFmxObject; AIndex: Integer);
var
  Item: TTreeViewItem;
  N: string;
begin
  Item := AcquireTreeItem(AObject, AParent, AIndex);
  N := AObject.StyleName;
  if N.IsEmpty then
    N := AObject.Name;
  if N.IsEmpty then
    N := Translate('(без имени)');
  N := N + ' : ' + AObject.ClassName;
  if Item.Text <> N then
    Item.Text := N;
  Item.TagObject := AObject;
  Item.ImageIndex := ComponentIcon(AObject.ClassType);
  // Keep a stable UI key as well as the model pointer for undo/load replacements.
  begin
    Item.TagString := AObject.ClassName + ':' + AObject.StyleName;
    var Occurrence := 0;
    if AObject.Parent <> nil then
      for var I := 0 to AObject.Index - 1 do
        if (AObject.Parent.Children[I].ClassType = AObject.ClassType) and
          (AObject.Parent.Children[I].StyleName = AObject.StyleName) then
          Inc(Occurrence);
    Item.TagString := Item.TagString + ':' + Occurrence.ToString;
    if (AObject.Parent <> FRoot) and (AParent is TTreeViewItem) then
      Item.TagString := AParent.TagString + '/' + Item.TagString;
  end;
  var Children := EditableChildren(AObject);
  for var I := 0 to High(Children) do
    AddTree(Children[I], Item, I);
end;

procedure TFormMain.RebuildTree;
var
  Viewport: TPointF;
  Watch: TStopwatch;
  Mark: Int64;
  SameModel: Boolean;
  SelectionItem, AncestorItem: TTreeViewItem;
  ExpandedObjects: TDictionary<Pointer, Boolean>;
  ExpandedKeys: TDictionary<string, Boolean>;
  Desired: TDictionary<Pointer, Boolean>;
  SelectedModels: TDictionary<Pointer, Boolean>;

  procedure Stage(const Title: string);
  begin
    FLastTreePhases := FLastTreePhases + Title + '=' + (Watch.ElapsedMilliseconds - Mark).ToString + '; ';
    Mark := Watch.ElapsedMilliseconds;
  end;

  procedure Gather(Obj: TFmxObject);
  begin
    Desired.AddOrSetValue(Pointer(Obj), True);
    for var Child in EditableChildren(Obj) do
      Gather(Child);
  end;

  procedure VisitItems(Parent: TFmxObject; Restore: Boolean);
  var
    Count: Integer;
    Item: TTreeViewItem;
    Expanded: Boolean;
  begin
    if Parent is TTreeView then
      Count := TTreeView(Parent).Count
    else
      Count := TTreeViewItem(Parent).Count;
    for var I := 0 to Count - 1 do
    begin
      if Parent is TTreeView then
        Item := TTreeView(Parent).Items[I]
      else
        Item := TTreeViewItem(Parent).Items[I];
      if Restore then
      begin
        if (SameModel and ExpandedObjects.TryGetValue(Pointer(Item.TagObject), Expanded)) or
          ExpandedKeys.TryGetValue(Item.TagString, Expanded) then
          Item.IsExpanded := Expanded;
      end
      else
      begin
        ExpandedObjects.AddOrSetValue(Pointer(Item.TagObject), Item.IsExpanded);
        ExpandedKeys.AddOrSetValue(Item.TagString, Item.IsExpanded);
      end;
      VisitItems(Item, Restore);
    end;
  end;

begin
  FSelected := EditableObject(FSelected);
  Watch := TStopwatch.StartNew;
  Mark := 0;
  FLastTreePhases := '';
  FTreeReorderedCount := 0;
  FTreeReparentedCount := 0;
  FTreeRefreshPending := False;
  FTreeViewportRestorePending := False;
  Viewport := FTree.ViewportPosition;
  FTreeStableBounds := FTree.ContentBounds;
  SameModel := FTreeModelRoot = FRoot;
  ExpandedObjects := TDictionary<Pointer, Boolean>.Create;
  ExpandedKeys := TDictionary<string, Boolean>.Create;
  Desired := TDictionary<Pointer, Boolean>.Create;
  SelectedModels := TDictionary<Pointer, Boolean>.Create;
  if SameModel and (FTree.Selected <> nil) and
    ((FTree.Selected.TagObject = FSelected) or (FTree.Selected.TagObject = FSelectedGroup)) then
    for var Item in TStyleTreeView(FTree).SelectedItems do
      SelectedModels.AddOrSetValue(Pointer(Item.TagObject), True);
  FBuilding := True;
  try
    VisitItems(FTree, False);
    Stage('save folds');
    FTree.BeginUpdate;
    try
      // Native selection rectangles retain stale global indices while a selected row is reparented.
      FTree.Selected := nil;
      if not SameModel then
      begin
        FTreeItems.Clear;
        FTree.Clear;
      end
      else
      begin
        for var StyleGroup in FGroups do
          Desired.AddOrSetValue(Pointer(StyleGroup), True);
        for var Child in ChildrenOf(FRoot) do
          if not SameText(Child.StyleName, '#designer') then
            Gather(Child);
        var OldItems := TreeItems(FTree);
        Stage('gather');
        // Move surviving descendants out of obsolete parents before freeing
        // those parents (deleting a group must retain its resources).
        BuildGroupedTree('', FTree);
        Stage('reconcile');
        // Delete leaves first. Removed model objects may already be freed;
        // compare their addresses without dereferencing them.
        for var I := High(OldItems) downto 0 do
          if not Desired.ContainsKey(Pointer(OldItems[I].TagObject)) then
          begin
            FTreeItems.Remove(Pointer(OldItems[I].TagObject));
            OldItems[I].Free;
          end;
      end;
      FTreeModelRoot := FRoot;
      if (FRoot <> nil) and not SameModel then
        BuildGroupedTree('', FTree);
      Stage('delete');
      VisitItems(FTree, True);
      Stage('restore folds');
      SelectionItem := nil;
      if FSelectedGroup <> nil then
      begin
        // StyleGroup IDs are stable across undo/load; use the same tree lookup.
        for var Item in TreeItems(FTree) do
          if Item.TagObject = FSelectedGroup then
            SelectionItem := Item;
      end
      else
        FTreeItems.TryGetValue(Pointer(FSelected), SelectionItem);
      if SelectionItem <> nil then
      begin
        AncestorItem := SelectionItem.ParentItem;
        while AncestorItem <> nil do
        begin
          AncestorItem.IsExpanded := True;
          AncestorItem := AncestorItem.ParentItem;
        end;
      end;
    finally
      Stage('select');
      if FTreeReorderedCount > 0 then
        TStyleTreeView(FTree).RefreshOrder;
      FTree.EndUpdate;
      Stage('end update');
    end;
    // Selecting before EndUpdate uses obsolete visible/global row indices after
    // deletion. Expand in the batch, then select after FMX has laid out the rows.
    FTree.Selected := SelectionItem;
    if SelectionItem <> nil then
      for var Item in TreeItems(FTree) do
        if (Item.Level = SelectionItem.Level) and SelectedModels.ContainsKey(Pointer(Item.TagObject)) then
          Item.IsSelected := True;
    // Selection can scroll automatically; restore after selection and final layout.
    // EndUpdate already performs layout. A second RealignContent traverses
    // every styled row again and dominates updates on large books.
    FTree.ViewportPosition := Viewport;
    Stage('layout');
  finally
    FBuilding := False;
    ExpandedKeys.Free;
    ExpandedObjects.Free;
    Desired.Free;
    SelectedModels.Free;
  end;
  FLastTreeMS := Watch.ElapsedMilliseconds;
  Watch := TStopwatch.StartNew;
  BuildProperties;
  FLastInspectorMS := Watch.ElapsedMilliseconds;
  Watch := TStopwatch.StartNew;
  RefreshDesign;
  FLastDesignMS := Watch.ElapsedMilliseconds;
  FTreeRestoreViewport := Viewport;
  FTreeViewportRestorePending := True;
  FRefreshTimer.Enabled := True;
end;

procedure TFormMain.SelectTreeItem(AParent: TFmxObject; AObject: TFmxObject);
var
  Item: TTreeViewItem;
begin
  if (AObject = nil) or not FTreeItems.TryGetValue(Pointer(AObject), Item) then
    Exit;
  if (FTree.Selected = Item) and (Length(TStyleTreeView(FTree).SelectedItems) = 1) then
    Exit;
  FTree.BeginUpdate;
  try
    FTree.Selected := Item;
  finally
    FTree.EndUpdate;
  end;
end;

procedure TFormMain.SelectObject(AObject: TFmxObject);
begin
  FSelected := EditableObject(AObject);
  FSelectedGroup := nil;
  FBuilding := True;
  try
    SelectTreeItem(FTree, FSelected);
  finally
    FBuilding := False;
  end;
  BuildProperties;
  RefreshDesign;
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

procedure TFormMain.TreeChange(Sender: TObject);
begin
  if FBuilding then
    Exit;
  if FTree.Selected = nil then
  begin
    FSelected := FRoot;
    FSelectedGroup := nil;
  end
  else if FTree.Selected.TagObject is TStyleGroup then
  begin
    FSelectedGroup := TStyleGroup(FTree.Selected.TagObject);
    FSelected := nil;
  end
  else
  begin
    FSelectedGroup := nil;
    FSelected := TFmxObject(FTree.Selected.TagObject);
  end;
  BuildProperties;
  RefreshDesign;
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

procedure TFormMain.AddProperties(AInstance: TObject; const APrefix: string; ADepth: Integer; AFilter: Boolean);
var
  Context: TRttiContext;
  Prop: TRttiProperty;
  Entry: TPropertyEntry;
  Value: TValue;
  Obj: TObject;
  Path: string;
  Collection: TCollection;
  I: Integer;
begin
  if (AInstance = nil) or (ADepth > 5) then
    Exit;
  Context := TRttiContext.Create;
  try
    for Prop in Context.GetType(AInstance.ClassType).GetProperties do
    begin
      if not IsStyleProperty(AInstance, Prop) then
        Continue;
      if (Prop.Name = 'Parent') or (Prop.Name = 'StyleBook') or
        Prop.Name.StartsWith('On') then
        Continue;
      Path := APrefix + Prop.Name;
      var DuplicatePath := False;
      for var Existing in FEntries do
        if Existing.Path = Path then
        begin
          DuplicatePath := True;
          Break;
        end;
      if DuplicatePath then
        Continue;
      try
        Value := Prop.GetValue(AInstance);
        if Value.Kind = tkClass then
        begin
          Obj := Value.AsObject;
          if Obj is TCollection then
          begin
            Entry := TPropertyEntry.Create;
            Entry.Instance := AInstance;
            Entry.Prop := Prop;
            Entry.Path := Path;
            FEntries.Add(Entry);
            Collection := TCollection(Obj);
            for I := 0 to Collection.Count - 1 do
              AddProperties(Collection.Items[I], Path + '[' + I.ToString + '].', ADepth + 1, AFilter);
          end
          else if (Obj is TStrings) or (Obj is TBitmap) then
          begin
            Entry := TPropertyEntry.Create;
            Entry.Instance := AInstance;
            Entry.Prop := Prop;
            Entry.Path := Path;
            FEntries.Add(Entry);
          end
          else if (Obj is TPersistent) and not (Obj is TComponent) then
            AddProperties(Obj, Path + '.', ADepth + 1, AFilter);
          Continue;
        end;
        if not Prop.IsWritable then
          Continue;
        if not (Value.Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration,
            tkSet, tkString, tkLString, tkWString, tkUString, tkChar, tkWChar]) then
          Continue;
        if AFilter and not FPropertySearch.Text.IsEmpty and not Path.ToLower.Contains(FPropertySearch.Text.ToLower) then
          Continue;
        Entry := TPropertyEntry.Create;
        Entry.Instance := AInstance;
        Entry.Prop := Prop;
        Entry.Path := Path;
        FEntries.Add(Entry);
      except
        // A component may expose a property which requires a platform service.
        // Do not prevent editing the other properties in that case.
      end;
    end;
  finally
    Context.Free;
  end;
end;

function TFormMain.PropertyText(AEntry: TPropertyEntry): string;
var
  V: TValue;
  Obj: TObject;
begin
  V := AEntry.Prop.GetValue(AEntry.Instance);
  if V.Kind = tkClass then
  begin
    Obj := V.AsObject;
    if Obj is TCollection then
      Exit(Format(Translate('%d элементов (двойной щелчок)'), [TCollection(Obj).Count]));
    if Obj is TStrings then
      Exit(Translate('Текст (двойной щелчок)'));
    if Obj is TBitmap then
      Exit(Translate('Изображение (двойной щелчок)'));
  end;
  if AEntry.Prop.PropertyType.Name = 'TAlphaColor' then
    Exit('#' + IntToHex(V.AsOrdinal, 8));
  case V.Kind of
    tkEnumeration:
      Result := GetEnumName(AEntry.Prop.PropertyType.Handle, V.AsOrdinal);
    tkSet:
      Result := SetToString(AEntry.Prop.PropertyType.Handle, V.GetReferenceToRawData, True);
    tkFloat:
      Result := FloatToStr(V.AsExtended, TFormatSettings.Invariant);
  else
    Result := V.ToString;
  end;
end;

procedure TFormMain.SetPropertyText(AEntry: TPropertyEntry; const AText: string);
var
  V: TValue;
  S: string;
  N: Int64;
  D: Extended;
  Info: PTypeInfo;
  Data: PTypeData;
  SetBytes: TBytes;
begin
  if not AEntry.Prop.IsWritable then
    raise Exception.Create(Translate('Это свойство доступно только для чтения.'));
  Info := AEntry.Prop.PropertyType.Handle;
  S := Trim(AText);
  V := AEntry.Prop.GetValue(AEntry.Instance);
  case V.Kind of
    tkInteger, tkInt64:
      begin
        if S.StartsWith('#') then
          S := '$' + S.Substring(1);
        if not TryStrToInt64(S, N) then
          raise EConvertError.Create(Translate('Ожидается целое число или #AARRGGBB.'));
        Data := GetTypeData(Info);
        if (V.Kind = tkInteger) and (Data.OrdType <> otULong) and
          ((N < Data.MinValue) or (N > Data.MaxValue)) then
          raise EConvertError.Create(Translate('Число выходит за диапазон свойства.'));
        if (V.Kind = tkInteger) and (Data.OrdType = otULong) and
          ((N < 0) or (N > Int64(High(Cardinal)))) then
          raise EConvertError.Create(Translate('Число выходит за диапазон свойства.'));
        V := TValue.FromOrdinal(Info, N);
      end;
    tkFloat:
      begin
        if not TryStrToFloat(S.Replace(',', '.'), D, TFormatSettings.Invariant) or
          IsNan(D) or IsInfinite(D) then
          raise EConvertError.Create(Translate('Ожидается конечное число.'));
        V := TValue.From<Extended>(D).Cast(Info);
      end;
    tkEnumeration:
      begin
        N := GetEnumValue(Info, S);
        if N < 0 then
          raise EConvertError.Create(Translate('Допустимые значения: ') + GetEnumName(Info, GetTypeData(Info).MinValue) + ' … ' + GetEnumName(Info, GetTypeData(Info).MaxValue));
        V := TValue.FromOrdinal(Info, N);
      end;
    tkSet:
      begin
        SetLength(SetBytes, SizeOfSet(Info));
        StringToSet(Info, S, @SetBytes[0]);
        TValue.Make(@SetBytes[0], Info, V);
      end;
    tkString, tkLString, tkWString, tkUString:
      V := TValue.From<string>(AText).Cast(Info);
    tkChar, tkWChar:
      begin
        if Length(AText) <> 1 then
          raise EConvertError.Create(Translate('Ожидается один символ.'));
        V := TValue.FromOrdinal(Info, Ord(AText[1]));
      end;
  else
    raise Exception.Create(Translate('Используйте двойной щелчок для специального редактора.'));
  end;
  if (AEntry.Instance = FSelected) and (AEntry.Prop.Name = 'StyleName') and
    (FSelected.Parent = FRoot) then
  begin
    if Trim(AText).IsEmpty then
      raise Exception.Create(Translate('Корневому ресурсу нужно имя StyleName.'));
    for var Child in ChildrenOf(FRoot) do
      if (Child <> FSelected) and SameText(Child.StyleName, AText) then
        raise Exception.Create(Translate('Ресурс с таким StyleName уже существует.'));
  end;
  if (AEntry.Prop.Name = 'StyleName') and SameText(AText, '#designer') then
    raise Exception.Create(Translate('Имя #designer зарезервировано редактором.'));
  AEntry.Prop.SetValue(AEntry.Instance, V);
end;

procedure TFormMain.BuildProperties;
begin
  FTreeViewportRestorePending := False;
  FRefreshTimer.Enabled := FTreeRefreshPending;
  FBuilding := True;
  try
    FEntries.Clear;
    if FSelected <> FRoot then
    begin
      AddProperties(FSelected, '', 0);
      if FProperties.InspectedObject = FSelected then
        FProperties.RefreshValues
      else
        FProperties.Inspect(FSelected);
    end
    else
      FProperties.Clear;
    FProperties.FilterText := FPropertySearch.Text;
  finally
    FBuilding := False;
  end;
  PropertySelectionChanged(nil);
end;

procedure TFormMain.InspectorFilter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
begin
  Accept := Accept and IsStyleProperty(Instance, Prop);
end;

procedure TFormMain.InspectorBinding(Sender: TObject; const Path: string; var ResourceName: string);
begin
  if FSelected = nil then
    Exit;
  for var Binding in FBindings do
    if (Binding.TargetName = FSelected.Name) and (Binding.PropertyPath = Path) then
    begin
      ResourceName := Binding.ResourceName;
      Exit;
    end;
end;

procedure TFormMain.MirrorDesignProperty(PropertyInfo: TInspectorProperty);

  function FindCopy(Obj: TFmxObject): TFmxObject;
  begin
    Result := nil;
    if Obj = nil then
      Exit;
    if Obj.TagObject = FSelected then
      Exit(Obj);
    for var I := 0 to Obj.ChildrenCount - 1 do
    begin
      Result := FindCopy(Obj.Children[I]);
      if Result <> nil then
        Exit;
    end;
  end;

var
  Entry: TPropertyEntry;
begin
  var Copy := FindCopy(FDesignRoot);
  if Copy = nil then
    Exit;
  Entry := ResolveProperty(Copy, PropertyInfo.WritePath);
  if Entry <> nil then
  try
    Entry.Prop.SetValue(Entry.Instance, PropertyInfo.Prop.GetValue(PropertyInfo.Instance));
    if Entry.Prop.Name = 'Text' then
      ApplyTextPlaceholders(Copy);
    if Copy is TAnimation then
      TAnimation(Copy).Enabled := False;
    if Copy is TGlyph then
      PrepareDesignGlyph(TGlyph(Copy));
    if Copy is TControl then
    begin
      TControl(Copy).HitTest := True;
      TControl(Copy).Locked := False;
      if Copy = FDesignRoot then
      begin
        TControl(Copy).Align := TAlignLayout.None;
        TControlAccess(Copy).Scale.Point := PointF(FZoomPercent / 100, FZoomPercent / 100);
      end;
    end;
    CenterDesign;
  finally
    Entry.Free;
  end;
end;

procedure TFormMain.InspectorWrite(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
var
  Entry: TPropertyEntry;
  Before: TBytes;
begin
  if FBuilding then
    Exit;
  Entry := TPropertyEntry.Create;
  try
    Entry.Instance := PropertyInfo.Instance;
    Entry.Prop := PropertyInfo.Prop;
    Entry.Path := PropertyInfo.WritePath;
    Before := Snapshot;
    SetPropertyText(Entry, Text);
    DetachPropertyBinding(FSelected, Entry.Path);
    FUndo.Add(Before);
    FRedo.Clear;
    Changed(False);
    MirrorDesignProperty(PropertyInfo);
    if (Entry.Instance = FSelected) and (Entry.Prop.Name = 'StyleName') then
    begin
      var Item: TTreeViewItem;
      if FTreeItems.TryGetValue(Pointer(FSelected), Item) then
      begin
        var Parent: TFmxObject := Item.ParentItem;
        if Parent = nil then
          Parent := FTree;
        // Only update keys below this renamed object; saved selection and folds
        // must use its new name even before the deferred editor refresh.
        AddTree(FSelected, Parent, Item.Index);
      end;
    end;
    // Update editor values after the originating event, without rebuilding nodes.
    FRefreshTimer.Enabled := True;
  finally
    Entry.Free;
  end;
end;

function TFormMain.SelectedPropertyIndex: Integer;
begin
  Result := -1;
  if FProperties.SelectedProperty = nil then
    Exit;
  for var I := 0 to FEntries.Count - 1 do
    if FEntries[I].Path = FProperties.SelectedProperty.WritePath then
      Exit(I);
end;

procedure TFormMain.DeferredRefresh(Sender: TObject);
begin
  if FBuilding then
    Exit;
  FRefreshTimer.Enabled := False;
  if FTreeRefreshPending then
    RebuildTree
  else
  begin
    FProperties.RefreshValues;
    PropertySelectionChanged(nil);
    var Item: TTreeViewItem;
    if (FSelected <> nil) and FTreeItems.TryGetValue(Pointer(FSelected), Item) then
    begin
      var Caption := FSelected.StyleName;
      if Caption.IsEmpty then
        Caption := FSelected.Name;
      if Caption.IsEmpty then
        Caption := Translate('(без имени)');
      Item.Text := Caption + ' : ' + FSelected.ClassName;
    end;
  end;
  if FTreeViewportRestorePending then
  begin
    FTreeViewportRestorePending := False;
    FTree.ViewportPosition := FTreeRestoreViewport;
  end;
end;

procedure TFormMain.PropertyFilter(Sender: TObject);
begin
  if FBuilding then
    Exit;
  if not FBuilding then
    BuildProperties;
end;

procedure TFormMain.EditStrings(AStrings: TStrings);
var
  Dialog: TTextEditorForm;
begin
  Dialog := TTextEditorForm.Create(Self);
  Dialog.StyleBook := StyleBook;
  try
    Dialog.TextMemo.Lines.Assign(AStrings);
    if Dialog.ShowModal = mrOk then
    begin
      Remember;
      AStrings.Assign(Dialog.TextMemo.Lines);
      Changed;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TFormMain.EditGradient(Gradient: TGradient; Brush: TBrush; const Path: string);
begin
  var Dialog := TGradientEditorForm.CreateEditor(Self, Gradient);
  try
    if Dialog.ShowModal = mrOk then
      ApplyGradient(Gradient, Dialog.Value, Brush, Path);
  finally
    Dialog.Free;
  end;
end;

function TFormMain.ApplyGradient(Gradient, Draft: TGradient; Brush: TBrush; const Path: string): Boolean;
var
  PointsChanged: Boolean;
  BoundValues: TDictionary<string, string>;
  KindPath: string;
begin
  Result := not SameGradient(Gradient, Draft) or
    ((Brush <> nil) and (Brush.Kind <> TBrushKind.Gradient));
  if not Result then
    Exit;
  PointsChanged := Gradient.Points.Count <> Draft.Points.Count;
  if not PointsChanged then
    for var I := 0 to Gradient.Points.Count - 1 do
      if (Gradient.Points[I].Color <> Draft.Points[I].Color) or
        not SameValue(Gradient.Points[I].Offset, Draft.Points[I].Offset, 0.000001) then
      begin
        PointsChanged := True;
        Break;
      end;
  KindPath := Path.Substring(0, Path.LastIndexOf('.') + 1) + 'Kind';
  BoundValues := TDictionary<string, string>.Create;
  try
    for var Binding in FBindings do
      if (Binding.TargetName = FSelected.Name) and
        (Binding.PropertyPath.StartsWith(Path + '.') or
        ((Brush <> nil) and (Binding.PropertyPath = KindPath))) then
      begin
        var Entry := ResolveProperty(FSelected, Binding.PropertyPath);
        if Entry <> nil then
        try
          BoundValues.AddOrSetValue(Entry.Path, PropertyText(Entry));
        finally
          Entry.Free;
        end;
      end;
    Remember;
    CopyGradient(Gradient, Draft);
    if Brush <> nil then
      Brush.Kind := TBrushKind.Gradient;
    for var Pair in BoundValues do
    begin
      // Stop indices may refer to different colors after sorting or inserting.
      if PointsChanged and Pair.Key.StartsWith(Path + '.Points[') then
        DetachPropertyBinding(FSelected, Pair.Key)
      else
      begin
        var Entry := ResolveProperty(FSelected, Pair.Key);
        try
          if (Entry = nil) or (PropertyText(Entry) <> Pair.Value) then
            DetachPropertyBinding(FSelected, Pair.Key);
        finally
          Entry.Free;
        end;
      end;
    end;
    Changed;
  finally
    BoundValues.Free;
  end;
end;

procedure TFormMain.InspectorEdit(Sender: TObject; PropertyInfo: TInspectorProperty);
var
  Obj: TObject;
  Color: TAlphaColor;
  Dialog: TTextEditorForm;
  PathData: TPathData;
  Path: string;
begin
  if FBuilding or (PropertyInfo.Prop = nil) then
    Exit;
  Path := PropertyInfo.Path;
  if PropertyInfo.Kind = iekColor then
  begin
    Color := TAlphaColor(PropertyInfo.Prop.GetValue(PropertyInfo.Instance).AsOrdinal);
    if ChooseColor(Self, Color) then
      FProperties.WriteProperty(Path, '#' + IntToHex(Color, 8));
    Exit;
  end;
  Obj := PropertyInfo.Prop.GetValue(PropertyInfo.Instance).AsObject;
  if Obj is TGradient then
  begin
    var Brush: TBrush := nil;
    if PropertyInfo.Instance is TBrush then
      Brush := TBrush(PropertyInfo.Instance);
    EditGradient(TGradient(Obj), Brush, Path);
  end
  else if Obj is TCollection then
    EditCollection(TCollection(Obj), Path)
  else if Obj is TStrings then
    EditStrings(TStrings(Obj))
  else if Obj is TBitmap then
  begin
    if FImageDialog.Execute then
    begin
      var Bitmap := TBitmap.Create;
      try
        Bitmap.LoadFromFile(FImageDialog.FileName);
        Remember;
        TBitmap(Obj).Assign(Bitmap);
        Changed;
      finally
        Bitmap.Free;
      end;
    end;
  end
  else if Obj is TFont then
  begin
    var Before := Snapshot;
    var BoundValues := TDictionary<string, string>.Create;
    try
      for var Binding in FBindings do
        if (Binding.TargetName = FSelected.Name) and Binding.PropertyPath.StartsWith(Path + '.') then
        begin
          var Entry := ResolveProperty(FSelected, Binding.PropertyPath);
          if Entry <> nil then
          try
            BoundValues.AddOrSetValue(Entry.Path, PropertyText(Entry));
          finally
            Entry.Free;
          end;
        end;
      FProperties.EditValue(Path, False);
      var After := Snapshot;
      if (Length(Before) <> Length(After)) or
        ((Length(Before) > 0) and not CompareMem(@Before[0], @After[0], Length(Before))) then
      begin
        for var Pair in BoundValues do
        begin
          var Entry := ResolveProperty(FSelected, Pair.Key);
          if Entry <> nil then
          try
            if PropertyText(Entry) <> Pair.Value then
              DetachPropertyBinding(FSelected, Pair.Key);
          finally
            Entry.Free;
          end;
        end;
        FUndo.Add(Before);
        FRedo.Clear;
        Changed;
      end;
    finally
      BoundValues.Free;
    end;
  end
  else if Obj is TPathData then
  begin
    Dialog := TTextEditorForm.Create(Self);
    Dialog.StyleBook := StyleBook;
    PathData := TPathData.Create;
    try
      Dialog.Caption := 'PathData';
      Dialog.TextMemo.Lines.Text := TPathData(Obj).Data;
      if Dialog.ShowModal = mrOk then
      begin
        PathData.Data := Dialog.TextMemo.Lines.Text;
        Remember;
        TPathData(Obj).Assign(PathData);
        DetachPropertyBinding(FSelected, Path + '.Data');
        Changed;
      end;
    finally
      PathData.Free;
      Dialog.Free;
    end;
  end;
end;

procedure TFormMain.PaletteDblClick(Sender: TObject);
begin
  if FBuilding then
    Exit;
  if FPalette.ItemIndex >= 0 then
  try
    AddObject(FPalette.Items[FPalette.ItemIndex]);
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

procedure TFormMain.ApplyTextPlaceholders(Obj: TFmxObject);
begin
  VisitStyleText(Obj,
    procedure(Instance: TObject; Prop: TRttiProperty)
    begin
      if Prop.GetValue(Instance).AsString.IsEmpty then
        Prop.SetValue(Instance, TValue.From<string>('Text').Cast(Prop.PropertyType.Handle));
    end);
end;

procedure TFormMain.WriteStyleStream(Stream: TStream; Format: TStyleFormat);
var
  Placeholders: TList<TPair<TObject, TRttiProperty>>;
begin
  Placeholders := TList<TPair<TObject, TRttiProperty>>.Create;
  try
    try
      VisitStyleText(FRoot,
        procedure(Instance: TObject; Prop: TRttiProperty)
        begin
          if Prop.GetValue(Instance).AsString = 'Text' then
          begin
            Placeholders.Add(TPair<TObject, TRttiProperty>.Create(Instance, Prop));
            Prop.SetValue(Instance, TValue.From<string>('').Cast(Prop.PropertyType.Handle));
          end;
        end);
      TStyleStreaming.SaveToStream(FRoot, Stream, Format);
    finally
      // Keep authored editor values and history intact, also after a failed write.
      for var Pair in Placeholders do
        Pair.Value.SetValue(Pair.Key, TValue.From<string>('Text').Cast(Pair.Value.PropertyType.Handle));
    end;
  finally
    Placeholders.Free;
  end;
end;

procedure TFormMain.PrepareDesignGlyph(Glyph: TGlyph);
begin
  // Empty glyphs hide themselves at runtime. Keep the display copy editable
  // without changing the style's visibility, input or image-list properties.
  Glyph.AutoHide := False;
  Glyph.Visible := True;
  Glyph.Enabled := True;
  Glyph.OnPaint := PaintGlyphPlaceholder;
end;

procedure TFormMain.PaintGlyphPlaceholder(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  var Glyph := TGlyph(Sender);
  if Glyph.BitmapExists then
    Exit;
  var R := ARect;
  R.Left := R.Left + Glyph.Padding.Left;
  R.Top := R.Top + Glyph.Padding.Top;
  R.Right := R.Right - Glyph.Padding.Right;
  R.Bottom := R.Bottom - Glyph.Padding.Bottom;
  var Diameter := Min(R.Width, R.Height) * 0.8;
  if Diameter <= 0 then
    Exit;
  var Center := R.CenterPoint;
  var State := Canvas.SaveState;
  try
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := $FF808080;
    // OnPaint also runs when FMX renders the glyph into an effect's bitmap.
    Canvas.FillEllipse(RectF(Center.X - Diameter / 2, Center.Y - Diameter / 2,
        Center.X + Diameter / 2, Center.Y + Diameter / 2), Glyph.AbsoluteOpacity);
  finally
    Canvas.RestoreState(State);
  end;
end;

procedure TFormMain.BindDesign(ACopy, AOriginal: TFmxObject);
var
  CopyChildren, OriginalChildren: TArray<TFmxObject>;
begin
  ACopy.TagObject := AOriginal;
  if ACopy is TCustomComboBox then
    TCustomComboBox(ACopy).ListBox.ScrollAnimation := TBehaviorBoolean.True;
  if ACopy is TAnimation then
    TAnimation(ACopy).Enabled := False;
  if ACopy is TGlyph then
    PrepareDesignGlyph(TGlyph(ACopy));
  if ACopy is TControl then
  begin
    if ACopy is TStyledControl then
      TStyledControl(ACopy).AutoTranslate := False;
    TControl(ACopy).HitTest := True;
    TControl(ACopy).Locked := False;
    TControl(ACopy).PopupMenu := ObjectMenu;
    TControlAccess(ACopy).CanFocus := False;
    TControl(ACopy).OnMouseDown := DesignDown;
    TControl(ACopy).OnMouseMove := DesignMove;
    TControl(ACopy).OnMouseUp := DesignUp;
  end;
  CopyChildren := EditableChildren(ACopy);
  OriginalChildren := EditableChildren(AOriginal);
  for var I := 0 to Min(Length(CopyChildren), Length(OriginalChildren)) - 1 do
    BindDesign(CopyChildren[I], OriginalChildren[I]);
end;

procedure TFormMain.RefreshDesign(Force: Boolean);

  procedure PrepareCopy(Obj: TFmxObject);
  begin
    // Internal containers must not intercept selection or expose their properties.
    Obj.TagObject := nil;
    if Obj is TControl then
      TControl(Obj).HitTest := False;
    if Obj is TAnimation then
      TAnimation(Obj).Enabled := False;
    for var Child in ChildrenOf(Obj) do
      PrepareCopy(Child);
  end;

var
  R, PreviousResource: TFmxObject;
begin
  FHoverOutline.Visible := False;
  EndWorkspacePan;
  PreviousResource := FResource;
  R := FSelected;
  if R <> nil then
    while (R.Parent <> nil) and (R.Parent <> FRoot) do
      R := R.Parent;
  if not Force and not FDesignDirty and (FDesignRoot <> nil) and (R = FResource) then
  begin
    FSelectionLabel.Text := R.StyleName + ' / ' + FSelected.ClassName;
    UpdateOutline;
    Exit;
  end;
  FDesignDirty := False;
  FOutline.Visible := False;
  for var Handle in [FResizeNW, FResizeNE, FResizeSW, FResizeHandle] do
    Handle.Visible := False;
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  UpdateOutline;
  FResource := nil;
  if (FSelected = nil) or (FSelected = FRoot) then
  begin
    if FSelectedGroup <> nil then
      FSelectionLabel.Text := Translate('Группа: ') + FSelectedGroup.Title
    else
      FSelectionLabel.Text := Translate('Выберите ресурс в дереве или создайте новый');
    FPanOffset := TPointF.Zero;
    CenterDesign;
    Exit;
  end;
  R := FSelected;
  while (R.Parent <> nil) and (R.Parent <> FRoot) do
    R := R.Parent;
  FResource := R;
  if R <> PreviousResource then
    FPanOffset := TPointF.Zero;
  FSelectionLabel.Text := R.StyleName + ' • ' + FSelected.ClassName;
  try
    FDesignRoot := R.Clone(nil);
    ApplyTextPlaceholders(FDesignRoot);
    EnableSmoothScrolling(FDesignRoot);
    PrepareCopy(FDesignRoot);
    BindDesign(FDesignRoot, R);
    if FDesignRoot is TControl3D then
    begin
      FDesignViewport.Visible := True;
      FDesignRoot.Parent := FDesignViewport;
    end
    else
      FDesignRoot.Parent := FSurface;
    if FDesignRoot is TControl then
    begin
      TControl(FDesignRoot).Align := TAlignLayout.None;
      TControl(FDesignRoot).Position.Point := PointF(0, 0);
      TControl(FDesignRoot).Visible := True;
      TControl(FDesignRoot).Opacity := 1;
    end;
    ZoomChanged(nil);
    FOutline.BringToFront;
    UpdateOutline;
  except
    on E: Exception do
      FStatus.Text := Translate('Рабочая область: ') + E.Message;
  end;
end;

procedure TFormMain.UpdateDesignHover(const FormPoint: TPointF);
var
  Hit: IControl;
  C: TControl;
  Bounds: TRectF;
  Corners: array[0..3] of TPointF;
begin
  if FBuilding or (csDestroying in ComponentState) or (FHoverOutline = nil) then
    Exit;
  FHoverOutline.Visible := False;
  if FDragging or FPanning or (FDesignRoot = nil) or
    not FCanvas.LocalRect.Contains(FCanvas.AbsoluteToLocal(FormPoint)) then
    Exit;
  // Use the same hit test as the form's mouse-down dispatch, including z-order
  // and clipping. The outline itself never participates in hit testing.
  Hit := ObjectAtPoint(ClientToScreen(FormPoint));
  if (Hit = nil) or not (Hit.GetObject is TControl) then
    Exit;
  C := TControl(Hit.GetObject);
  if (C = FResizeNW) or (C = FResizeNE) or (C = FResizeSW) or (C = FResizeHandle) then
    C := FResizeCopy;
  if (C = nil) or not FDesignRoot.IsChild(C) or
    (C.TagObject = nil) or (EditableObject(TFmxObject(C.TagObject)) = nil) then
    Exit;
  Corners[0] := TPointF.Zero;
  Corners[1] := PointF(C.Width, 0);
  Corners[2] := PointF(C.Width, C.Height);
  Corners[3] := PointF(0, C.Height);
  for var I := 0 to High(Corners) do
  begin
    var P := FSurface.AbsoluteToLocal(C.LocalToAbsolute(Corners[I]));
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
  FHoverOutline.BoundsRect := Bounds;
  FHoverOutline.Visible := True;
  FHoverOutline.BringToFront;
  for var Handle in [FResizeNW, FResizeNE, FResizeSW, FResizeHandle] do
    Handle.BringToFront;
  CanvasOverlay.BringToFront;
end;

procedure TFormMain.MouseMove(Shift: TShiftState; AFormX, AFormY: Single);
begin
  inherited;
  UpdateDesignHover(PointF(AFormX, AFormY));
end;

procedure TFormMain.MouseLeave;
begin
  inherited;
  if not FBuilding and not (csDestroying in ComponentState) and (FHoverOutline <> nil) then
    FHoverOutline.Visible := False;
end;

procedure TFormMain.UpdateOutline;

  function FindCopy(AObject: TFmxObject): TControl;
  begin
    Result := nil;
    if (AObject.TagObject = FSelected) and (AObject is TControl) then
      Exit(TControl(AObject));
    for var I := 0 to AObject.ChildrenCount - 1 do
    begin
      Result := FindCopy(AObject.Children[I]);
      if Result <> nil then
        Exit;
    end;
  end;

  function Bounds(C: TControl): TRectF;
  begin
    Result := FSurface.AbsoluteToLocal(C.AbsoluteRect);
  end;

  procedure SizeBadge(Box: TRectangle; LabelControl: TLabel; C: TControl; const R: TRectF);
  begin
    LabelControl.Text := Format('%s x %s', [FloatToStrF(C.Width, ffGeneral, 6, 2), FloatToStrF(C.Height, ffGeneral, 6, 2)]);
    var Y := R.Bottom + 8;
    if Box = FRootSizeBox then
      Y := R.Top - 32;
    Box.SetBounds(EnsureRange(R.CenterPoint.X - 55, 0, Max(0, FSurface.Width - 110)),
      EnsureRange(Y, 0, Max(0, FSurface.Height - 24)), 110, 24);
    Box.Visible := ShowDimensions.IsChecked;
    Box.BringToFront;
  end;

var
  C: TControl;
  R: TRectF;
  Corners: array[0..3] of TPointF;
  Handles: array[0..3] of TRectangle;
begin
  FGuides.BringToFront;
  FOutline.Visible := False;
  FRootOutline.Visible := False;
  FSizeBox.Visible := False;
  FRootSizeBox.Visible := False;
  for var Handle in [FResizeNW, FResizeNE, FResizeSW, FResizeHandle] do
    Handle.Visible := False;
  FResizeCopy := nil;
  if FDesignRoot = nil then
    Exit;
  if FDesignRoot is TControl then
  begin
    R := Bounds(TControl(FDesignRoot));
    FRootOutline.BoundsRect := R;
    FRootOutline.Visible := ShowFrame.IsChecked;
    FRootOutline.BringToFront;
    SizeBadge(FRootSizeBox, FRootSizeLabel, TControl(FResource), R);
  end;
  C := FindCopy(FDesignRoot);
  if C = nil then
    Exit;
  R := Bounds(C);
  FOutline.BoundsRect := R;
  FOutline.Visible := (FSelected <> FResource);
  FOutline.BringToFront;
  FResizeCopy := C;
  if FSelected <> FResource then
    SizeBadge(FSizeBox, FSizeLabel, C, R);
  begin
    Corners[0] := FSurface.AbsoluteToLocal(C.LocalToAbsolute(PointF(0, 0)));
    Corners[1] := FSurface.AbsoluteToLocal(C.LocalToAbsolute(PointF(C.Width, 0)));
    Corners[2] := FSurface.AbsoluteToLocal(C.LocalToAbsolute(PointF(0, C.Height)));
    Corners[3] := FSurface.AbsoluteToLocal(C.LocalToAbsolute(PointF(C.Width, C.Height)));
    Handles[0] := FResizeNW;
    Handles[1] := FResizeNE;
    Handles[2] := FResizeSW;
    Handles[3] := FResizeHandle;
    for var I := 0 to 3 do
    begin
      Handles[I].Position.Point := Corners[I] - PointF(4.5, 4.5);
      Handles[I].TagObject := FSelected;
      Handles[I].Visible := True;
      Handles[I].BringToFront;
    end;
  end;
  FGuides.Repaint;
  CanvasOverlay.BringToFront;
end;

procedure TFormMain.DisplayOptionsChanged(Sender: TObject);
begin
  if FBuilding then
    Exit;
  UpdateOutline;
  FGuides.Repaint;
end;

procedure TFormMain.CenterViewClick(Sender: TObject);
begin
  FPanOffset := TPointF.Zero;
  CenterDesign;
end;

procedure TFormMain.PaintGuides(Sender: TObject; Canvas: TCanvas);
var
  SelectedBounds, OtherBounds: TRectF;
  State: TCanvasSaveState;

  procedure CompareBounds(const Other: TRectF);
  begin
    for var X in [Other.Left, Other.CenterPoint.X, Other.Right] do
      if (Abs(X - SelectedBounds.Left) <= 5) or (Abs(X - SelectedBounds.CenterPoint.X) <= 5) or
        (Abs(X - SelectedBounds.Right) <= 5) then
        Canvas.DrawLine(PointF(X, 0), PointF(X, FGuides.Height), 1);
    for var Y in [Other.Top, Other.CenterPoint.Y, Other.Bottom] do
      if (Abs(Y - SelectedBounds.Top) <= 5) or (Abs(Y - SelectedBounds.CenterPoint.Y) <= 5) or
        (Abs(Y - SelectedBounds.Bottom) <= 5) then
        Canvas.DrawLine(PointF(0, Y), PointF(FGuides.Width, Y), 1);
  end;

begin
  if not ShowGuides.IsChecked or not FDragging or (FResizeCopy = nil) then
    Exit;
  State := Canvas.SaveState;
  try
    Canvas.Stroke.Thickness := 1;
    Canvas.Stroke.Dash := TStrokeDash.Dash;
    SelectedBounds := FGuides.AbsoluteToLocal(FResizeCopy.AbsoluteRect);
    // Show the moving/resizing bounds continuously, even between alignments.
    // Coordinates and the five-pixel alignment tolerance are in viewport units.
    Canvas.Stroke.Color := $FF438AC4;
    for var X in [SelectedBounds.Left, SelectedBounds.CenterPoint.X, SelectedBounds.Right] do
      Canvas.DrawLine(PointF(X, 0), PointF(X, FGuides.Height), 0.9);
    for var Y in [SelectedBounds.Top, SelectedBounds.CenterPoint.Y, SelectedBounds.Bottom] do
      Canvas.DrawLine(PointF(0, Y), PointF(FGuides.Width, Y), 0.9);
    Canvas.Stroke.Color := $FFE879F9;
    if (FDesignRoot is TControl) and (FDesignRoot <> FResizeCopy) then
      CompareBounds(FGuides.AbsoluteToLocal(TControl(FDesignRoot).AbsoluteRect));
    var Parent := EditableParent(FResizeCopy);
    if (Parent is TControl) and (Parent.TagObject is TFmxObject) then
    begin
      if Parent <> FDesignRoot then
        CompareBounds(FGuides.AbsoluteToLocal(TControl(Parent).AbsoluteRect));
      for var Sibling in EditableChildren(Parent) do
        if (Sibling is TControl) and TControl(Sibling).Visible and (Sibling <> FResizeCopy) and
          (Sibling.TagObject is TFmxObject) then
        begin
          OtherBounds := FGuides.AbsoluteToLocal(TControl(Sibling).AbsoluteRect);
          CompareBounds(OtherBounds);
        end;
    end;
  finally
    Canvas.RestoreState(State);
  end;
end;

procedure TFormMain.DesignDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  C: TControl;
begin
  if FBuilding then
    Exit;
  FHoverOutline.Visible := False;
  CanvasOverlay.Visible := False;
  if Button in [TMouseButton.mbLeft, TMouseButton.mbRight] then
    FSurface.SetFocus;
  if (Button = TMouseButton.mbMiddle) and not FDragging then
  begin
    FPanning := True;
    FPanStart := TControl(Sender).LocalToAbsolute(PointF(X, Y));
    FPanOrigin := FPanOffset;
    TControlAccess(FSurface).Capture;
    FSurface.Cursor := crSizeAll;
    Exit;
  end;
  if not (Button in [TMouseButton.mbLeft, TMouseButton.mbRight]) or FPanning or
    (Sender = FSurface) or (Sender = FCanvas) or (Sender = FDesignViewport) then
    Exit;
  C := TControl(Sender);
  FResizing := (Sender = FResizeHandle) or (Sender = FResizeNW) or (Sender = FResizeNE) or (Sender = FResizeSW);
  if FResizing then
    FResizeCorner := C.Tag;
  FSelected := EditableObject(TFmxObject(C.TagObject));
  if FSelected = nil then
    Exit;
  FSelectedGroup := nil;
  FBuilding := True;
  try
    SelectTreeItem(FTree, FSelected);
  finally
    FBuilding := False;
  end;
  if FProperties.InspectedObject <> FSelected then
    BuildProperties;
  UpdateOutline;
  if Button = TMouseButton.mbRight then
    Exit;
  if (FSelected is TControl) and (FResizing or (FSelected <> FResource)) and
    (FResizing or (TControl(FSelected).Align = TAlignLayout.None)) then
  begin
    FDragObject := C;
    FDragStart := C.LocalToAbsolute(PointF(X, Y));
    FDragPosition := TControl(FSelected).Position.Point;
    FResizeSize := PointF(TControl(FSelected).Width, TControl(FSelected).Height);
    if FResizing and (FSelected <> FResource) and (TControl(FSelected).Align <> TAlignLayout.None) then
    begin
      FDragPosition := FResizeCopy.Position.Point;
      FResizeSize := PointF(FResizeCopy.Width, FResizeCopy.Height);
    end;
    FDragCopyPosition := FResizeCopy.Position.Point;
    FDragInverse := FResizeCopy.AbsoluteMatrix.Inverse;
    if FResizing then
    begin
      var Opposite := TPointF.Zero;
      if FResizeCorner in [0, 2] then
        Opposite.X := FResizeSize.X;
      if FResizeCorner in [0, 1] then
        Opposite.Y := FResizeSize.Y;
      FResizeAnchor := FResizeCopy.LocalToAbsolute(Opposite);
    end;
    FDragSnapshot := nil;
    FDragging := True;
    FGuides.BringToFront;
    FGuides.Repaint;
    TControlAccess(C).Capture;
  end;
end;

procedure TFormMain.DesignMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  C, Original: TControl;
  P, Delta: TPointF;
  Scale: Single;
begin
  if FBuilding then
    Exit;
  if FPanning then
  begin
    P := TControl(Sender).LocalToAbsolute(PointF(X, Y));
    FPanOffset := FPanOrigin + FSurface.AbsoluteToLocal(P) - FSurface.AbsoluteToLocal(FPanStart);
    CenterDesign;
    Exit;
  end;
  if not FDragging or (Sender <> FDragObject) then
    Exit;
  C := TControl(Sender);
  Original := TControl(C.TagObject);
  P := C.LocalToAbsolute(PointF(X, Y));
  Scale := 1;
  if FDesignRoot is TControl then
    Scale := TControlAccess(FDesignRoot).Scale.X;
  Delta := (P - FDragStart) / Scale;
  if Length(FDragSnapshot) = 0 then
  begin
    if (Abs(P.X - FDragStart.X) < 3) and (Abs(P.Y - FDragStart.Y) < 3) then
      Exit;
    FDragSnapshot := Snapshot;
    if FResizing and (Original.Align <> TAlignLayout.None) and (Original <> FResource) then
    begin
      Original.Align := TAlignLayout.None;
      FResizeCopy.Align := TAlignLayout.None;
      Original.SetBounds(FDragPosition.X, FDragPosition.Y, FResizeSize.X, FResizeSize.Y);
      FResizeCopy.SetBounds(FDragPosition.X, FDragPosition.Y, FResizeSize.X, FResizeSize.Y);
      DetachPropertyBinding(FSelected, 'Align');
    end;
  end;
  if (Original <> FResource) and (FResizeCopy.Parent is TControl) then
    Delta := TControl(FResizeCopy.Parent).AbsoluteToLocal(P) - TControl(FResizeCopy.Parent).AbsoluteToLocal(FDragStart);
  if FResizing then
  begin
    Delta := (P * FDragInverse) - (FDragStart * FDragInverse);
    var LeftEdge := FResizeCorner in [0, 2];
    var TopEdge := FResizeCorner in [0, 1];
    var NewSize := FResizeSize;
    if LeftEdge then
      NewSize.X := Max(1, FResizeSize.X - Delta.X)
    else
      NewSize.X := Max(1, FResizeSize.X + Delta.X);
    if TopEdge then
      NewSize.Y := Max(1, FResizeSize.Y - Delta.Y)
    else
      NewSize.Y := Max(1, FResizeSize.Y + Delta.Y);
    Original.Width := NewSize.X;
    Original.Height := NewSize.Y;
    FResizeCopy.Width := NewSize.X;
    FResizeCopy.Height := NewSize.Y;
    FResizeCopy.Position.Point := FDragCopyPosition;
    var Opposite := TPointF.Zero;
    if LeftEdge then
      Opposite.X := NewSize.X;
    if TopEdge then
      Opposite.Y := NewSize.Y;
    var NewAnchor := FResizeCopy.LocalToAbsolute(Opposite);
    var Offset := TControl(FResizeCopy.Parent).AbsoluteToLocal(FResizeAnchor) -
      TControl(FResizeCopy.Parent).AbsoluteToLocal(NewAnchor);
    FResizeCopy.Position.Point := FDragCopyPosition + Offset;
    if Original = FResource then
      Original.Position.Point := FDragPosition + Offset / Scale
    else
      Original.Position.Point := FDragPosition + Offset;
  end
  else
  begin
    Original.Position.Point := FDragPosition + Delta;
    C.Position.Point := Original.Position.Point;
  end;
  UpdateOutline;
end;

procedure TFormMain.DesignUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FBuilding then
    Exit;
  if FPanning then
  begin
    if Button = TMouseButton.mbMiddle then
      EndWorkspacePan;
    Exit;
  end;
  if (Button <> TMouseButton.mbLeft) or not FDragging then
    Exit;
  FDragging := False;
  TControlAccess(FDragObject).ReleaseCapture;
  if (TControl(FSelected).Position.Point <> FDragPosition) or
    (TControl(FSelected).Width <> FResizeSize.X) or
    (TControl(FSelected).Height <> FResizeSize.Y) then
  begin
    FUndo.Add(FDragSnapshot);
    FRedo.Clear;
    if FResizing then
    begin
      DetachPropertyBinding(FSelected, 'Width');
      DetachPropertyBinding(FSelected, 'Height');
    end
    else
    begin
      DetachPropertyBinding(FSelected, 'Position.X');
      DetachPropertyBinding(FSelected, 'Position.Y');
    end;
    if FResizing and (FResizeCorner <> 3) then
    begin
      DetachPropertyBinding(FSelected, 'Position.X');
      DetachPropertyBinding(FSelected, 'Position.Y');
    end;
    Changed(False);
    if FSelected = FResource then
    begin
      var OldPosition := TControl(FDesignRoot).Position.Point;
      CenterDesign;
      FPanOffset := FPanOffset + OldPosition - TControl(FDesignRoot).Position.Point;
      CenterDesign;
    end;
    FProperties.RefreshValues;
  end;
  FGuides.Repaint;
  FResizing := False;
  FDragObject := nil;
  FDragSnapshot := nil;
end;

procedure TFormMain.SyncResourceThemeView;
var
  WasBuilding: Boolean;
begin
  WasBuilding := FBuilding;
  FBuilding := True;
  try
    ResourceThemeBox.ItemIndex := Ord(FResourceTheme);
    if FBackgroundMode.ItemIndex <> 2 then
      FBackgroundMode.ItemIndex := Ord(FResourceTheme);
  finally
    FBuilding := WasBuilding;
  end;
  UpdateWorkspaceBackground;
end;

procedure TFormMain.SetResourceTheme(Value: TResourceTheme);
var
  State: TBytes;
begin
  if Value = FResourceTheme then
    Exit;
  for var Resource in FValues do
    ValidateNamedValue(Resource);
  for var Binding in FBindings do
  begin
    var Resource := FindValue(Binding.ResourceName);
    if Resource <> nil then
      ValidateBinding(Resource, Binding);
  end;
  State := Snapshot;
  try
    FResourceTheme := Value;
    ApplyBindings;
  except
    Restore(State);
    raise;
  end;
  FUndo.Add(State);
  if FUndo.Count > 100 then
    FUndo.Delete(0);
  FRedo.Clear;
  SyncResourceThemeView;
  Changed(False);
  FProperties.RefreshValues;
  RefreshDesign(True);
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

procedure TFormMain.ResourceThemeChanged(Sender: TObject);
begin
  if FBuilding or (ResourceThemeBox.ItemIndex < 0) then
    Exit;
  try
    SetResourceTheme(TResourceTheme(ResourceThemeBox.ItemIndex));
  except
    on E: Exception do
    begin
      SyncResourceThemeView;
      ShowAppMessage(Self, E.Message);
    end;
  end;
end;

procedure TFormMain.ConfigureWorkspaceBackground(Brush: TBrush);
begin
  Brush.Kind := TBrushKind.Solid;
  case FBackgroundMode.ItemIndex of
    1:
      Brush.Color := $FF000000;
    2:
      begin
        Brush.Bitmap.Bitmap.Assign(FCheckerBitmap);
        Brush.Bitmap.WrapMode := TWrapMode.Tile;
        Brush.Kind := TBrushKind.Bitmap;
      end;
  else
    Brush.Color := $FFFFFFFF;
  end;
end;

procedure TFormMain.UpdateWorkspaceBackground;
begin
  if FWorkBackground <> nil then
    FWorkBackground.Repaint;
  if FPreview <> nil then
    ConfigureWorkspaceBackground(TPreviewForm(FPreview).WorkspaceBackground.Fill);
end;

procedure TFormMain.BackgroundChanged(Sender: TObject);
begin
  if FBuilding then
    Exit;
  UpdateWorkspaceBackground;
end;

procedure TFormMain.PaintWorkBackground(Sender: TObject; Canvas: TCanvas);
var
  State: TCanvasSaveState;
begin
  if FBuilding then
    Exit;
  State := Canvas.SaveState;
  try
    ConfigureWorkspaceBackground(Canvas.Fill);
    Canvas.FillRect(FWorkBackground.LocalRect, 0, 0, [], 1);
  finally
    Canvas.RestoreState(State);
  end;
end;

procedure TFormMain.PositionWorkspaceSettings;
begin
  CanvasOverlay.Width := Min(288, Max(240, FCanvas.Width - 24));
  CanvasOverlay.Position.Point := PointF(Max(12, FCanvas.Width - CanvasOverlay.Width - 12), 12);
end;

procedure TFormMain.CanvasResized(Sender: TObject);
begin
  if FBuilding then
    Exit;
  CanvasOverlay.Visible := False;
  PositionWorkspaceSettings;
  // Preserve readable labels when the workspace is narrowed by its sidebars.
  FBackgroundMode.Align := TAlignLayout.None;
  ResourceThemeBox.Align := TAlignLayout.None;
  FZoom.Align := TAlignLayout.None;
  FBackgroundMode.SetBounds(0, 4, 144, 32);
  ResourceThemeBox.SetBounds(156, 4, 152, 32);
  if WorkspaceOptions.Width < 432 then
  begin
    WorkspaceOptions.Height := 80;
    FZoom.SetBounds(Max(0, WorkspaceOptions.Width - 100), 44, 100, 32);
  end
  else
  begin
    WorkspaceOptions.Height := 40;
    FZoom.SetBounds(WorkspaceOptions.Width - 100, 4, 100, 32);
  end;
  CenterDesign;
end;

function TFormMain.DesignControl: TControl;
begin
  Result := nil;
  if FDesignRoot is TControl then
    Result := TControl(FDesignRoot)
  else if FDesignViewport.Visible then
    Result := FDesignViewport;
end;

procedure TFormMain.CenterDesign;
var
  Control: TControl;
  Bounds: TRectF;
  Corners: array[0..3] of TPointF;
  Point: TPointF;
begin
  if FCentering or (FSurface = nil) or (FCanvas = nil) then
    Exit;
  FCentering := True;
  try
    FHoverOutline.Visible := False;
    // The surface is a fixed viewport. Only the display copy moves, so there
    // are no scroll extents, clamping or changes to document coordinates.
    FSurface.SetBounds(0, 0, Max(1, FCanvas.Width), Max(1, FCanvas.Height));
    Control := DesignControl;
    if Control <> nil then
    begin
      Corners[0] := PointF(0, 0);
      Corners[1] := PointF(Control.Width, 0);
      Corners[2] := PointF(Control.Width, Control.Height);
      Corners[3] := PointF(0, Control.Height);
      Bounds := TRectF.Empty;
      for var I := 0 to High(Corners) do
      begin
        Point := FSurface.AbsoluteToLocal(Control.LocalToAbsolute(Corners[I]));
        if I = 0 then
          Bounds := RectF(Point.X, Point.Y, Point.X, Point.Y)
        else
        begin
          Bounds.Left := Min(Bounds.Left, Point.X);
          Bounds.Top := Min(Bounds.Top, Point.Y);
          Bounds.Right := Max(Bounds.Right, Point.X);
          Bounds.Bottom := Max(Bounds.Bottom, Point.Y);
        end;
      end;
      Control.Position.Point := Control.Position.Point +
        FSurface.LocalRect.CenterPoint + FPanOffset - Bounds.CenterPoint;
    end;
    UpdateOutline;
  finally
    FCentering := False;
  end;
end;

procedure TFormMain.EndWorkspacePan;
begin
  if not FPanning then
    Exit;
  FPanning := False;
  TControlAccess(FSurface).ReleaseCapture;
  FSurface.Cursor := crDefault;
end;

procedure TFormMain.WorkspaceDeactivate(Sender: TObject);
begin
  FHoverOutline.Visible := False;
  CanvasOverlay.Visible := False;
  EndWorkspacePan;
end;

procedure TFormMain.WorkspaceWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Anchor: TPointF;
begin
  Anchor := FCanvas.ScreenToLocal(Screen.MousePos);
  if not FCanvas.LocalRect.Contains(Anchor) then
    Exit;
  Handled := True;
  if CanvasOverlay.Visible and CanvasOverlay.BoundsRect.Contains(Anchor) then
    Exit;
  WorkspaceZoomAt(Anchor, WheelDelta);
end;

procedure TFormMain.WorkspaceZoomAt(const Anchor: TPointF; WheelDelta: Integer);
var
  Control: TControl;
  LocalAnchor, AfterAnchor: TPointF;
  Steps, Percent: Integer;
begin
  if FBuilding or FDragging or FPanning then
    Exit;
  Inc(FWheelRemainder, WheelDelta);
  Steps := FWheelRemainder div 120;
  FWheelRemainder := FWheelRemainder mod 120;
  if Steps = 0 then
    Exit;
  Control := DesignControl;
  if Control <> nil then
    LocalAnchor := Control.AbsoluteToLocal(FCanvas.LocalToAbsolute(Anchor));
  Percent := EnsureRange(Round(FZoomPercent * Power(1.1, Steps)), MinWorkspaceZoom, MaxWorkspaceZoom);
  SetWorkspaceZoom(Percent);
  if Control <> nil then
  begin
    AfterAnchor := FCanvas.AbsoluteToLocal(Control.LocalToAbsolute(LocalAnchor));
    FPanOffset := FPanOffset + Anchor - AfterAnchor;
    CenterDesign;
  end;
end;

procedure TFormMain.ZoomChanged(Sender: TObject);
var
  Percent: Integer;
begin
  if FBuilding or FZoomUpdating or (FZoom.ItemIndex < 0) then
    Exit;
  if TryStrToInt(FZoom.Items[FZoom.ItemIndex].Replace('%', ''), Percent) then
    SetWorkspaceZoom(Percent);
end;

procedure TFormMain.SetWorkspaceZoom(Percent: Integer);
var
  Index: Integer;
  Scale: Single;
  Text: string;
begin
  if FBuilding or FZoomUpdating then
    Exit;
  FZoomUpdating := True;
  try
    FZoomPercent := EnsureRange(Percent, MinWorkspaceZoom, MaxWorkspaceZoom);
    Text := FZoomPercent.ToString + '%';
    Index := FZoom.Items.IndexOf(Text);
    // Keep one custom entry for intermediate wheel values and restored views.
    if Index < 0 then
    begin
      if (FCustomZoomIndex >= 0) and (FCustomZoomIndex < FZoom.Items.Count) then
        FZoom.Items[FCustomZoomIndex] := Text
      else
        FCustomZoomIndex := FZoom.Items.Add(Text);
      Index := FCustomZoomIndex;
    end;
    FZoom.ItemIndex := Index;
    Scale := FZoomPercent / 100;
    if FDesignRoot is TControl then
      TControlAccess(FDesignRoot).Scale.Point := PointF(Scale, Scale)
    else if FDesignViewport.Visible then
      TControlAccess(FDesignViewport).Scale.Point := PointF(Scale, Scale);
    CenterDesign;
  finally
    FZoomUpdating := False;
  end;
end;

function TFormMain.IsStyleProperty(Instance: TObject; Prop: TRttiProperty): Boolean;
const
  Hidden: array[0..13] of string = ('Name', 'Stored', 'Tag', 'TagFloat', 'TagString',
    'Locked', 'Parent', 'Owner', 'Root', 'Scene', 'StyleBook', 'DesignInfo', 'Action', 'Observers');
begin
  Result := (Prop.Visibility = mvPublished) and Prop.IsReadable and not Prop.Name.StartsWith('On');
  if not Result then
    Exit;
  if (Prop.Name = 'Tag') or (Prop.Name = 'TagString') or (Prop.Name = 'TagFloat') then
    if (Instance is TStyleTag) or ((Instance is TFmxObject) and not
      ((Instance is TControl) or (Instance is TControl3D) or (Instance is TAnimation) or (Instance is TEffect))) then
      Exit(True);
  if Instance is TComponent then
    for var Name in Hidden do
      if SameText(Prop.Name, Name) then
        Exit(False);
end;

function TFormMain.MetadataJSON(IncludeView: Boolean): string;
var
  Root, Item: TJSONObject;
  Values, Bindings, Targets, Groups, Assignments, StyleClasses, Expanded: TJSONArray;
  Names: TDictionary<string, Boolean>;
  Obj, Parent: TFmxObject;
  Path: string;
  View: TJSONObject;
begin
  Root := TJSONObject.Create;
  Names := TDictionary<string, Boolean>.Create;
  try
    Root.AddPair('version', TJSONNumber.Create(3));
    if FResourceTheme = rtDark then
      Root.AddPair('theme', 'dark')
    else
      Root.AddPair('theme', 'light');
    Values := TJSONArray.Create;
    Root.AddPair('values', Values);
    for var Value in FValues do
    begin
      Item := TJSONObject.Create;
      Item.AddPair('name', Value.Name);
      Item.AddPair('kind', Value.Kind);
      Item.AddPair('light', Value.LightValue);
      Item.AddPair('dark', Value.DarkValue);
      Values.AddElement(Item);
    end;
    Bindings := TJSONArray.Create;
    Root.AddPair('bindings', Bindings);
    for var Binding in FBindings do
    begin
      Item := TJSONObject.Create;
      Item.AddPair('target', Binding.TargetName);
      Item.AddPair('property', Binding.PropertyPath);
      Item.AddPair('resource', Binding.ResourceName);
      Bindings.AddElement(Item);
    end;
    // The stock style reader can discard component names. Persist the location
    // of bound targets so names and bindings can be restored together.
    Targets := TJSONArray.Create;
    Root.AddPair('targets', Targets);
    for var Binding in FBindings do
      Names.AddOrSetValue(Binding.TargetName, True);
    for var Assignment in FAssignments do
      Names.AddOrSetValue(Assignment.Key, True);
    for var Assignment in FStyleClasses do
      Names.AddOrSetValue(Assignment.Key, True);
    var TargetNames := Names.Keys.ToArray;
    TArray.Sort<string>(TargetNames);
    for var Name in TargetNames do
    begin
      Obj := FindNamedObject(Name);
      if Obj = nil then
        Continue;
      Path := '';
      Parent := Obj;
      while (Parent <> nil) and (Parent <> FRoot) do
      begin
        if Path.IsEmpty then
          Path := Parent.Index.ToString
        else
          Path := Parent.Index.ToString + '/' + Path;
        Parent := Parent.Parent;
      end;
      if Parent <> FRoot then
        Continue;
      Item := TJSONObject.Create;
      Item.AddPair('name', Obj.Name);
      Item.AddPair('path', Path);
      Item.AddPair('class', Obj.ClassName);
      Targets.AddElement(Item);
    end;
    Groups := TJSONArray.Create;
    Root.AddPair('groups', Groups);
    for var StyleGroup in FGroups do
    begin
      Item := TJSONObject.Create;
      Item.AddPair('id', StyleGroup.ID);
      Item.AddPair('title', StyleGroup.Title);
      Item.AddPair('parent', StyleGroup.ParentID);
      Groups.AddElement(Item);
    end;
    Assignments := TJSONArray.Create;
    Root.AddPair('assignments', Assignments);
    var GroupTargets := FAssignments.Keys.ToArray;
    TArray.Sort<string>(GroupTargets);
    for var TargetName in GroupTargets do
    begin
      Item := TJSONObject.Create;
      Item.AddPair('target', TargetName);
      Item.AddPair('group', FAssignments[TargetName]);
      Assignments.AddElement(Item);
    end;
    StyleClasses := TJSONArray.Create;
    Root.AddPair('styleClasses', StyleClasses);
    var ClassTargets := FStyleClasses.Keys.ToArray;
    TArray.Sort<string>(ClassTargets);
    for var TargetName in ClassTargets do
    begin
      Obj := FindNamedObject(TargetName);
      if (Obj = nil) or (Obj.Parent <> FRoot) or SameText(Obj.StyleName, '#designer') then
        Continue;
      Item := TJSONObject.Create;
      Item.AddPair('target', TargetName);
      Item.AddPair('controlClass', FStyleClasses[TargetName]);
      StyleClasses.AddElement(Item);
    end;
    if IncludeView then
    begin
      View := TJSONObject.Create;
      Root.AddPair('view', View);
      View.AddPair('zoom', TJSONNumber.Create(FZoomPercent));
      View.AddPair('panX', TJSONNumber.Create(FPanOffset.X));
      View.AddPair('panY', TJSONNumber.Create(FPanOffset.Y));
      View.AddPair('background', TJSONNumber.Create(FBackgroundMode.ItemIndex));
      View.AddPair('showFrame', TJSONBool.Create(ShowFrame.IsChecked));
      View.AddPair('showGuides', TJSONBool.Create(ShowGuides.IsChecked));
      View.AddPair('showDimensions', TJSONBool.Create(ShowDimensions.IsChecked));
      View.AddPair('treeWidth', TJSONNumber.Create(TreePanel.Width));
      View.AddPair('inspectorWidth', TJSONNumber.Create(InspectorPanel.Width));
      View.AddPair('tab', TJSONNumber.Create(ToolsTabs.TabIndex));
      View.AddPair('treeX', TJSONNumber.Create(FTree.ViewportPosition.X));
      View.AddPair('treeY', TJSONNumber.Create(FTree.ViewportPosition.Y));
      View.AddPair('propertyFilter', FPropertySearch.Text);
      View.AddPair('paletteFilter', FSearch.Text);
      View.AddPair('paletteCategory', TJSONNumber.Create(FCategory.ItemIndex));
      View.AddPair('columnRatio', TJSONNumber.Create(FProperties.NameColumnRatio));
      View.AddPair('propertyY', TJSONNumber.Create(FProperties.Tree.ViewportPosition.Y));
      if FValueReference.ItemIndex >= 0 then
        View.AddPair('selectedValue', FValueReference.Items[FValueReference.ItemIndex]);
      var PropertyExpanded := TJSONArray.Create;
      View.AddPair('propertyExpanded', PropertyExpanded);
      for var Node in TreeItems(FProperties.Tree) do
        if Node.IsExpanded then
          PropertyExpanded.Add(TInspectorProperty(Node.TagObject).Path);
      if FProperties.SelectedProperty <> nil then
        View.AddPair('property', FProperties.SelectedProperty.Path);
      if FTree.Selected <> nil then
        View.AddPair('selected', FTree.Selected.TagString);
      Expanded := TJSONArray.Create;
      View.AddPair('expanded', Expanded);
      for var Node in TreeItems(FTree) do
        if Node.IsExpanded then
          Expanded.Add(Node.TagString);
    end;
    Result := Root.ToJSON;
  finally
    Names.Free;
    Root.Free;
  end;
end;

procedure TFormMain.LoadMetadata(const Text: string);
var
  JSON: TJSONValue;
  Items: TJSONArray;
  Value: TNamedStyleValue;
  Binding: TStyleValueBinding;
  Obj: TFmxObject;
  Index, Version: Integer;
  Path, Name: string;
begin
  FSelectedGroup := nil;
  FGroups.Clear;
  FAssignments.Clear;
  FStyleClasses.Clear;
  FPreviewSource := nil;
  FPendingProjectView := '';
  FResourceTheme := rtLight;
  if Text.IsEmpty then
  begin
    FValues.Clear;
    FBindings.Clear;
    SyncResourceThemeView;
    UpdateValueReferences;
    Exit;
  end;
  JSON := TJSONObject.ParseJSONValue(Text);
  try
    if not (JSON is TJSONObject) then
      raise Exception.Create(Translate('Некорректный файл коллекции ресурсов.'));
    Version := JSON.GetValue<Integer>('version', 0);
    if not (Version in [1, 2, 3]) then
      raise Exception.Create(Translate('Неподдерживаемая версия коллекции ресурсов.'));
    if Version = 3 then
    begin
      var Theme := JSON.GetValue<string>('theme', 'light');
      if Theme = 'dark' then
        FResourceTheme := rtDark
      else if Theme <> 'light' then
        raise Exception.Create(Translate('Некорректный режим ресурсов.'));
    end;
    Items := JSON.GetValue<TJSONArray>('targets', nil);
    if Items <> nil then
      for var Item in Items do
      begin
        Name := Item.GetValue<string>('name');
        Obj := FindNamedObject(Name);
        if Obj <> nil then
          Continue;
        Obj := FRoot;
        Path := Item.GetValue<string>('path');
        if not Path.IsEmpty then
          for var Part in Path.Split(['/']) do
          begin
            if not TryStrToInt(Part, Index) or (Index < 0) or (Index >= Obj.ChildrenCount) then
              raise Exception.Create(Translate('Не найден объект связи: ') + Name);
            Obj := Obj.Children[Index];
          end;
        if Obj.ClassName <> Item.GetValue<string>('class') then
          raise Exception.Create(Translate('Тип объекта связи изменён: ') + Name);
        Obj.Name := Name;
      end;
    FValues.Clear;
    FBindings.Clear;
    Items := JSON.GetValue<TJSONArray>('values');
    if Items = nil then
      raise Exception.Create(Translate('Отсутствует массив values в коллекции ресурсов.'));
    for var Item in Items do
    begin
      Value := TNamedStyleValue.Create;
      try
        Value.Name := Item.GetValue<string>('name');
        Value.Kind := Item.GetValue<string>('kind');
        Value.Theme := FResourceTheme;
        if Version = 3 then
        begin
          Value.LightValue := Item.GetValue<string>('light');
          Value.DarkValue := Item.GetValue<string>('dark');
        end
        else
        begin
          Value.DarkValue := Item.GetValue<string>('value');
          Value.LightValue := Value.DarkValue;
        end;
        ValidateNamedValue(Value);
        if FindValue(Value.Name) <> nil then
          raise Exception.Create(Translate('Повтор ресурса: ') + Value.Name);
        FValues.Add(Value);
        Value := nil;
      finally
        Value.Free;
      end;
    end;
    Items := JSON.GetValue<TJSONArray>('bindings');
    if Items = nil then
      raise Exception.Create(Translate('Отсутствует массив bindings в коллекции ресурсов.'));
    for var Item in Items do
    begin
      Binding := TStyleValueBinding.Create;
      Binding.TargetName := Item.GetValue<string>('target');
      Binding.PropertyPath := Item.GetValue<string>('property');
      Binding.ResourceName := Item.GetValue<string>('resource');
      FBindings.Add(Binding);
    end;
    Items := JSON.GetValue<TJSONArray>('groups', nil);
    if Items <> nil then
      for var Item in Items do
      begin
        var StyleGroup := TStyleGroup.Create;
        try
          StyleGroup.ID := Item.GetValue<string>('id');
          StyleGroup.Title := Item.GetValue<string>('title');
          StyleGroup.ParentID := Item.GetValue<string>('parent');
          if StyleGroup.ID.IsEmpty or Trim(StyleGroup.Title).IsEmpty or (FindGroup(StyleGroup.ID) <> nil) then
            raise Exception.Create(Translate('Некорректная группа стилей.'));
          FGroups.Add(StyleGroup);
          StyleGroup := nil;
        finally
          StyleGroup.Free;
        end;
      end;
    for var StyleGroup in FGroups do
    begin
      var ParentID := StyleGroup.ParentID;
      var Depth := 0;
      while not ParentID.IsEmpty do
      begin
        var ParentGroup := FindGroup(ParentID);
        Inc(Depth);
        if (ParentGroup = nil) or (Depth > FGroups.Count) or (ParentID = StyleGroup.ID) then
          raise Exception.Create(Translate('Некорректная вложенность групп стилей.'));
        ParentID := ParentGroup.ParentID;
      end;
    end;
    Items := JSON.GetValue<TJSONArray>('assignments', nil);
    if Items <> nil then
      for var Item in Items do
      begin
        var TargetName := Item.GetValue<string>('target');
        var GroupID := Item.GetValue<string>('group');
        var Target := FindNamedObject(TargetName);
        if (Target = nil) or (Target.Parent <> FRoot) or (FindGroup(GroupID) = nil) or
          SameText(Target.StyleName, '#designer') or FAssignments.ContainsKey(TargetName) then
          raise Exception.Create(Translate('Некорректная связь ресурса с группой.'));
        FAssignments.Add(TargetName, GroupID);
      end;
    Items := JSON.GetValue<TJSONArray>('styleClasses', nil);
    if Items <> nil then
      for var Item in Items do
      begin
        var TargetName := Item.GetValue<string>('target');
        var ClassName := Item.GetValue<string>('controlClass');
        var Target := FindNamedObject(TargetName);
        if (Target = nil) or (Target.Parent <> FRoot) or SameText(Target.StyleName, '#designer') or
          ClassName.IsEmpty or FStyleClasses.ContainsKey(TargetName) then
          raise Exception.Create(Translate('Некорректное назначение класса стилю.'));
        FStyleClasses.Add(TargetName, ClassName);
      end;
    var View := JSON.GetValue<TJSONObject>('view', nil);
    if View <> nil then
      FPendingProjectView := View.ToJSON;
  finally
    JSON.Free;
  end;
  UpdateValueReferences;
  SyncResourceThemeView;
end;

function TFormMain.FindValue(const Name: string): TNamedStyleValue;
begin
  Result := nil;
  for var Value in FValues do
    if SameText(Value.Name, Name) then
      Exit(Value);
end;

function TFormMain.FindNamedObject(const Name: string): TFmxObject;

  function Find(Obj: TFmxObject): TFmxObject;
  begin
    Result := nil;
    if SameText(Obj.Name, Name) then
      Exit(Obj);
    for var Child in ChildrenOf(Obj) do
    begin
      Result := Find(Child);
      if Result <> nil then
        Exit;
    end;
  end;

begin
  Result := nil;
  if not Name.IsEmpty then
    Result := Find(FRoot);
end;

function TFormMain.ResolveProperty(Obj: TFmxObject; const Path: string): TPropertyEntry;
var
  Context: TRttiContext;
  Target: TObject;
  Prop: TRttiProperty;
  Parts: TArray<string>;
  Part: string;
  I, Index, Bracket: Integer;
begin
  Result := nil;
  if Obj = nil then
    Exit;
  Context := TRttiContext.Create;
  try
    Target := Obj;
    Parts := Path.Split(['.']);
    for I := 0 to High(Parts) do
    begin
      Part := Parts[I];
      Bracket := Part.IndexOf('[');
      Index := -1;
      if Bracket >= 0 then
      begin
        if not Part.EndsWith(']') or not TryStrToInt(Part.Substring(Bracket + 1,
              Part.Length - Bracket - 2), Index) then
          Exit;
        Part := Part.Substring(0, Bracket);
      end;
      Prop := Context.GetType(Target.ClassType).GetProperty(Part);
      if (Prop = nil) or not IsStyleProperty(Target, Prop) then
        Exit;
      if I = High(Parts) then
      begin
        Result := TPropertyEntry.Create;
        Result.Instance := Target;
        Result.Prop := Prop;
        Result.Path := Path;
        Exit;
      end;
      if Prop.PropertyType.TypeKind <> tkClass then
        Exit;
      Target := Prop.GetValue(Target).AsObject;
      if Index >= 0 then
      begin
        if not (Target is TCollection) or (Index >= TCollection(Target).Count) then
          Exit;
        Target := TCollection(Target).Items[Index];
      end;
      if Target = nil then
        Exit;
    end;
  finally
    Context.Free;
  end;
end;

procedure TFormMain.ValidateNamedValue(Value: TNamedStyleValue);
var
  Number: Extended;
  IntegerValue: Int64;
  Color, Text: string;
begin
  if Trim(Value.Name).IsEmpty then
    raise Exception.Create(Translate('Имя ресурса не может быть пустым.'));
  for var Theme := Low(TResourceTheme) to High(TResourceTheme) do
  begin
    Text := Value.ValueFor(Theme);
    if SameText(Value.Kind, 'Цвет') then
    begin
      Color := Trim(Text);
      if Color.StartsWith('#') then
        Color := '$' + Color.Substring(1);
      if not TryStrToInt64(Color, IntegerValue) or (IntegerValue < 0) or
        (IntegerValue > Int64(High(Cardinal))) then
        raise Exception.Create(Translate('Для цвета укажите #AARRGGBB, например #FF247AC4.'));
    end
    else if SameText(Value.Kind, 'Число') then
    begin
      if not TryStrToFloat(Text.Replace(',', '.'), Number, TFormatSettings.Invariant) or
        IsNan(Number) or IsInfinite(Number) then
        raise Exception.Create(Translate('Ожидается конечное число.'));
    end
    else if SameText(Value.Kind, 'Целое') then
    begin
      if not TryStrToInt64(Text, IntegerValue) then
        raise Exception.Create(Translate('Ожидается целое число.'));
    end
    else if SameText(Value.Kind, 'Логическое') then
    begin
      if not SameText(Text, 'True') and not SameText(Text, 'False') then
        raise Exception.Create(Translate('Логическое значение: True или False.'));
    end
    else if not SameText(Value.Kind, 'Текст') then
      raise Exception.Create(Translate('Типы ресурсов: Цвет, Число, Целое, Текст, Логическое.'));
  end;
end;

procedure TFormMain.ValidateBinding(Value: TNamedStyleValue; Binding: TStyleValueBinding);
begin
  var Obj := FindNamedObject(Binding.TargetName);
  if Obj = nil then
    Exit;
  var Entry := ResolveProperty(Obj, Binding.PropertyPath);
  if Entry = nil then
    Exit;
  try
    var Kind := Entry.Prop.PropertyType.TypeKind;
    if SameText(Value.Kind, 'Цвет') and (Entry.Prop.PropertyType.Name <> 'TAlphaColor') then
      raise Exception.Create(Translate('Цвет можно связать только со свойством TAlphaColor.'));
    if SameText(Value.Kind, 'Число') or SameText(Value.Kind, 'Целое') then
    begin
      if not (Kind in [tkInteger, tkInt64, tkFloat]) then
        raise Exception.Create(Translate('Числовой ресурс требует числового свойства.'));
      if Kind in [tkInteger, tkInt64] then
        for var Theme := Low(TResourceTheme) to High(TResourceTheme) do
        begin
          var Number := StrToInt64(Value.ValueFor(Theme));
          if Kind = tkInteger then
          begin
            var Data := GetTypeData(Entry.Prop.PropertyType.Handle);
            if ((Data.OrdType = otULong) and ((Number < 0) or (Number > High(Cardinal)))) or
              ((Data.OrdType <> otULong) and ((Number < Data.MinValue) or (Number > Data.MaxValue))) then
              raise EConvertError.Create(Translate('Число вне диапазона свойства.'));
          end;
        end;
    end;
    if SameText(Value.Kind, 'Текст') and not (Kind in [tkString, tkLString, tkWString, tkUString]) then
      raise Exception.Create(Translate('Текстовый ресурс требует строкового свойства.'));
    if SameText(Value.Kind, 'Логическое') and (Entry.Prop.PropertyType.Handle <> TypeInfo(Boolean)) then
      raise Exception.Create(Translate('Логический ресурс требует свойства Boolean.'));
  finally
    Entry.Free;
  end;
end;

procedure TFormMain.ApplyBindings;
var
  Entry: TPropertyEntry;
  Value: TNamedStyleValue;
  Obj: TFmxObject;
begin
  for var Resource in FValues do
    Resource.Theme := FResourceTheme;
  for var Binding in FBindings do
  begin
    Value := FindValue(Binding.ResourceName);
    Obj := FindNamedObject(Binding.TargetName);
    if (Value = nil) or (Obj = nil) then
      Continue;
    Entry := ResolveProperty(Obj, Binding.PropertyPath);
    if Entry = nil then
      Continue;
    try
      ValidateBinding(Value, Binding);
      SetPropertyText(Entry, Value.Value);
    finally
      Entry.Free;
    end;
  end;
end;

procedure TFormMain.UpdateValueReferences;
begin
  FValueReference.Items.Clear;
  for var Value in FValues do
    FValueReference.Items.Add(Value.Name);
  if FValues.Count > 0 then
    FValueReference.ItemIndex := 0;
end;

procedure TFormMain.PropertySelectionChanged(Sender: TObject);
var
  Index: Integer;
begin
  if FBuilding then
    Exit;
  Index := SelectedPropertyIndex;
  BindButton.Enabled := (FSelected <> nil) and (Index >= 0);
  UnbindButton.Enabled := False;
  if Index < 0 then
    Exit;
  BindButton.Enabled := FEntries[Index].Prop.IsWritable and
    (FEntries[Index].Prop.PropertyType.TypeKind <> tkClass) and
    (FEntries[Index].Prop.Name <> 'StyleName');
  for var Binding in FBindings do
    if (Binding.TargetName = FSelected.Name) and (Binding.PropertyPath = FEntries[Index].Path) then
    begin
      UnbindButton.Enabled := True;
      FValueReference.ItemIndex := FValueReference.Items.IndexOf(Binding.ResourceName);
      Exit;
    end;
end;

procedure TFormMain.BindSelectedProperty;
var
  Binding: TStyleValueBinding;
  Entry: TPropertyEntry;
  State: TBytes;
  ID: string;
begin
  if (FSelected = nil) or (FValueReference.ItemIndex < 0) or
    (SelectedPropertyIndex < 0) or (SelectedPropertyIndex >= FEntries.Count) then
    raise Exception.Create(Translate('Выберите свойство и ресурс значения.'));
  Entry := FEntries[SelectedPropertyIndex];
  if not Entry.Prop.IsWritable or (Entry.Prop.PropertyType.TypeKind = tkClass) then
    raise Exception.Create(Translate('Можно связать только редактируемое простое свойство.'));
  if Entry.Prop.Name = 'StyleName' then
    raise Exception.Create(Translate('Имя части стиля задаётся напрямую, без ссылки на значение.'));
  State := Snapshot;
  try
    if FSelected.Name = '' then
    begin
      ID := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
      FSelected.Name := 'SBD_' + ID;
    end;
    for var I := FBindings.Count - 1 downto 0 do
      if (FBindings[I].TargetName = FSelected.Name) and
        (FBindings[I].PropertyPath = Entry.Path) then
        FBindings.Delete(I);
    Binding := TStyleValueBinding.Create;
    Binding.TargetName := FSelected.Name;
    Binding.PropertyPath := Entry.Path;
    Binding.ResourceName := FValueReference.Items[FValueReference.ItemIndex];
    FBindings.Add(Binding);
    ApplyBindings;
    FUndo.Add(State);
    FRedo.Clear;
    Changed;
  except
    Restore(State);
    raise;
  end;
end;

procedure TFormMain.UnbindSelectedProperty;
var
  Path: string;
begin
  if (FSelected = nil) or (SelectedPropertyIndex < 0) or
    (SelectedPropertyIndex >= FEntries.Count) then
    Exit;
  Path := FEntries[SelectedPropertyIndex].Path;
  for var I := FBindings.Count - 1 downto 0 do
    if (FBindings[I].TargetName = FSelected.Name) and (FBindings[I].PropertyPath = Path) then
    begin
      Remember;
      FBindings.Delete(I);
      Changed;
      Exit;
    end;
end;

function TFormMain.Snapshot: TBytes;
var
  Style, Stream: TMemoryStream;
  Metadata: TBytes;
  Size: Integer;
begin
  Style := TMemoryStream.Create;
  Stream := TMemoryStream.Create;
  try
    UpdateDesignerMetadata;
    TStyleStreaming.SaveToStream(FRoot, Style, TStyleFormat.Binary);
    Size := Style.Size;
    Stream.WriteBuffer(Size, SizeOf(Size));
    Stream.WriteBuffer(Style.Memory^, Size);
    Metadata := TEncoding.UTF8.GetBytes(MetadataJSON);
    if Length(Metadata) > 0 then
      Stream.WriteBuffer(Metadata[0], Length(Metadata));
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then
      Move(Stream.Memory^, Result[0], Stream.Size);
  finally
    Style.Free;
    Stream.Free;
  end;
  if FSavedStatePending then
  begin
    FSavedState := Result;
    FSavedStatePending := False;
  end;
end;

procedure TFormMain.Restore(const AState: TBytes);
var
  Stream: TBytesStream;
  Style: TMemoryStream;
  Root: TFmxObject;
  Size: Integer;
  Metadata: TBytes;
begin
  Stream := TBytesStream.Create(AState);
  Style := TMemoryStream.Create;
  try
    Stream.ReadBuffer(Size, SizeOf(Size));
    if (Size < 0) or (Size > Stream.Size - Stream.Position) then
      raise Exception.Create(Translate('Некорректный снимок истории.'));
    Style.CopyFrom(Stream, Size);
    Style.Position := 0;
    TStyleStreaming.SetSupportedPlatformHook(AcceptStylePlatform);
    try
      Root := TStyleStreaming.LoadFromStream(Style);
    finally
      TStyleStreaming.SetSupportedPlatformHook(nil);
    end;
    UnpackStyleBinaries(Root);
    SetLength(Metadata, Stream.Size - Stream.Position);
    if Length(Metadata) > 0 then
      Stream.ReadBuffer(Metadata[0], Length(Metadata));
  finally
    Stream.Free;
    Style.Free;
  end;
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  FTreeModelRoot := nil;
  FRoot.Free;
  FRoot := Root;
  SetModelDesigning(FRoot);
  FPreviewDirty := True;
  FSelected := FRoot;
  LoadMetadata(TEncoding.UTF8.GetString(Metadata));
  Changed(True, True);
end;

procedure TFormMain.Remember;
begin
  FUndo.Add(Snapshot);
  if FUndo.Count > 100 then
    FUndo.Delete(0);
  FRedo.Clear;
end;

procedure TFormMain.Changed(ARebuild, CompareSaved: Boolean);
begin
  if CompareSaved then
  begin
    var State := Snapshot;
    FDirty := (Length(State) <> Length(FSavedState)) or
      ((Length(State) > 0) and not CompareMem(@State[0], @FSavedState[0], Length(State)));
  end
  else
    FDirty := True;
  UpdateCaption;
  if ARebuild then
  begin
    FDesignDirty := True;
    RebuildTree;
  end;
  FPreviewDirty := True;
  if (FPreview <> nil) and FPreview.Visible then
  begin
    FPreviewRefreshTimer.Enabled := False;
    FPreviewRefreshTimer.Enabled := True;
  end;
end;

procedure TFormMain.UpdateCaption;
var
  N: string;
begin
  N := ExtractFileName(FFileName);
  if N.IsEmpty then
    N := Translate('Без имени');
  if FDirty then
    N := N + ' *';
  Caption := N + ' — StyleBook Designer';
  DocumentLabel.Text := N;
  UndoButton.Enabled := FUndo.Count > 0;
  RedoButton.Enabled := FRedo.Count > 0;
  FStatus.Text := Format(Translate('%d компонентов в палитре • %d ресурсов • Отмена: %d • Повтор: %d'),
    [FNames.Count, StyleResourceCount, FUndo.Count, FRedo.Count]);
end;

procedure TFormMain.ClearHistory;
begin
  FUndo.Clear;
  FRedo.Clear;
  FSavedState := nil;
  FSavedStatePending := True;
  FDirty := False;
  UpdateCaption;
end;

function TFormMain.ConfirmDiscard: Boolean;
var
  Answer: Integer;
begin
  Result := True;
  if not FDirty then
    Exit;
  Answer := TWinUIDialog.Show(Self, Translate('Сохранить изменения текущего стиля?'),
    DocumentLabel.Text, [Translate('Сохранить'), Translate('Не сохранять'), Translate('Отмена')],
    0, 0, True);
  case Answer of
    0:
      Result := SaveDocument(False);
    1:
      Result := True;
  else
    Result := False;
  end;
end;

procedure TFormMain.FormClosing(Sender: TObject; var CanClose: Boolean);
begin
  if FBuilding then
    Exit;
  CanClose := ConfirmDiscard;
end;

function TFormMain.ClipboardFocus: Boolean;
var
  Obj: TFmxObject;
begin
  Result := False;
  if Focused = nil then
    Exit;
  Obj := Focused.GetObject as TFmxObject;
  while Obj <> nil do
  begin
    if (Obj is TCustomEdit) or (Obj is TMemo) then
      Exit;
    if (Obj = FTree) or (Obj = FCanvas) or (Obj = FDesignViewport) then
      Exit(True);
    Obj := Obj.Parent;
  end;
end;

procedure TFormMain.FormKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if FBuilding then
    Exit;
  if (Key = vkEscape) and CanvasOverlay.Visible then
  begin
    WorkspaceSettingsClick(CloseWorkspaceSettings);
    Key := 0;
    Exit;
  end;
  if not (ssCtrl in Shift) then
    Exit;
  // Let a text editor handle its own local undo/copy/delete shortcuts.
  if (Focused <> nil) and ((Focused.GetObject is TCustomEdit) or
    (Focused.GetObject is TMemo)) and (Key in [Ord('Z'), Ord('Y'), Ord('D'), Ord('C'), Ord('V')]) then
    Exit;
  try
    case Key of
      Ord('C'):
        if ssShift in Shift then
          CopyStyleBook
        else if ClipboardFocus then
          CopyObject
        else
          Exit;
      Ord('V'):
        if ssShift in Shift then
          PasteStyleBook
        else if ClipboardFocus then
          PasteObject
        else
          Exit;
      Ord('N'):
        if ConfirmDiscard then
          NewDocument;
      Ord('O'):
        OpenDocument;
      Ord('S'):
        SaveDocument(ssShift in Shift);
      Ord('Z'):
        Undo(False);
      Ord('Y'):
        Undo(True);
      Ord('D'):
        DuplicateObject;
    else
      Exit;
    end;
    Key := 0;
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

procedure TFormMain.NewDocument;
begin
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  FTreeModelRoot := nil;
  FreeAndNil(FRoot);
  FRoot := TStyleContainer.Create(nil);
  SetModelDesigning(FRoot);
  FPreviewDirty := True;
  FSelected := FRoot;
  FFileName := '';
  FSelectedGroup := nil;
  FGroups.Clear;
  FAssignments.Clear;
  FStyleClasses.Clear;
  FPreviewSource := nil;
  FValues.Clear;
  FBindings.Clear;
  FResourceTheme := rtLight;
  SyncResourceThemeView;
  UpdateValueReferences;
  RebuildTree;
  ApplyProjectView;
  ClearHistory;
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

procedure TFormMain.LoadDocument(const AFileName: string);
var
  Root: TFmxObject;
  Watch: TStopwatch;
begin
  Watch := TStopwatch.StartNew;
  TStyleStreaming.SetSupportedPlatformHook(AcceptStylePlatform);
  try
    Root := TStyleStreaming.LoadFromFile(AFileName);
  finally
    TStyleStreaming.SetSupportedPlatformHook(nil);
  end;
  ReplaceDocument(Root, AFileName, Watch.ElapsedMilliseconds);
end;

procedure TFormMain.ReplaceDocument(Root: TFmxObject; const AFileName: string; ReadMilliseconds: Int64);
var
  PreviousRoot, PreviousSelected: TFmxObject;
  PreviousGroupID, PreviousFile, PreviousMetadata: string;
  Watch: TStopwatch;
  Mark: Int64;

  procedure Stage(const Title: string);
  begin
    FLastLoadPhases := FLastLoadPhases + Title + '=' + (Watch.ElapsedMilliseconds - Mark).ToString + ' ms; ';
    Mark := Watch.ElapsedMilliseconds;
  end;

begin
  Watch := TStopwatch.StartNew;
  Mark := 0;
  FLastLoadPhases := 'read=' + ReadMilliseconds.ToString + ' ms; ';
  if Root = nil then
    raise Exception.Create(Translate('Не удалось загрузить стиль.'));
  try
    PreviousMetadata := MetadataJSON(True);
  except
    Root.Free;
    raise;
  end;
  PreviousRoot := FRoot;
  PreviousSelected := FSelected;
  PreviousGroupID := '';
  if FSelectedGroup <> nil then
    PreviousGroupID := FSelectedGroup.ID;
  PreviousFile := FFileName;
  Stage('rollback metadata');
  try
    UnpackStyleBinaries(Root);
  except
    Root.Free;
    raise;
  end;
  Stage('unpack');
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  FTreeModelRoot := nil;
  FRoot := Root;
  SetModelDesigning(FRoot);
  FPreviewDirty := True;
  FSelected := FRoot;
  FFileName := AFileName;
  Stage('replace');
  try
    var Embedded := DesignerJSON;
    if not Embedded.IsEmpty then
      LoadMetadata(Embedded)
    else if not AFileName.IsEmpty and TFile.Exists(AFileName + '.resources.json') then
      LoadMetadata(TFile.ReadAllText(AFileName + '.resources.json', TEncoding.UTF8))
    else
      LoadMetadata('');
    ApplyBindings;
    Stage('metadata');
    RebuildTree;
    Stage('tree');
    ApplyProjectView;
    Stage('view');
  except
    FFileName := PreviousFile;
    FProperties.Clear;
    FEntries.Clear;
    FreeAndNil(FDesignRoot);
    FTreeModelRoot := nil;
    FRoot.Free;
    FRoot := PreviousRoot;
    FSelected := PreviousSelected;
    LoadMetadata(PreviousMetadata);
    FSelectedGroup := FindGroup(PreviousGroupID);
    RebuildTree;
    ApplyProjectView;
    raise;
  end;
  PreviousRoot.Free;
  ClearHistory;
  Stage('history');
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

function TFormMain.StyleBookText: string;
var
  Book: TStyleBook;
  Stream: TMemoryStream;
begin
  ApplyBindings;
  UpdateDesignerMetadata(True);
  Book := TStyleBook.Create(nil);
  Stream := TMemoryStream.Create;
  try
    TComponentAccess(Book).SetDesigning(True, False);
    Book.Name := 'StyleBook1';
    WriteStyleStream(Stream, TStyleFormat.Indexed);
    Stream.Position := 0;
    Book.CurrentItem.LoadFromStream(Stream);
    Result := ComponentText(Book);
  finally
    TComponentAccess(Book).SetDesigning(False, False);
    Book.Free;
    Stream.Free;
  end;
end;

procedure TFormMain.CopyStyleBook;
begin
  ClipboardService.SetClipboard(TValue.From<string>(StyleBookText));
end;

procedure TFormMain.PasteStyleBook;
var
  Root: TFmxObject;
begin
  Root := ReadStyleBookText(ClipboardText);
  try
    if not ConfirmDiscard then
      Exit;
    var ImportedRoot := Root;
    Root := nil;
    ReplaceDocument(ImportedRoot, '');
    Changed(False);
  finally
    Root.Free;
  end;
end;

function TFormMain.ObjectText: string;
var
  Obj: TFmxObject;
begin
  if (FSelected = nil) or (FSelected = FRoot) then
    raise Exception.Create(Translate('Выберите элемент стиля для копирования.'));
  Result := '';
  for var Model in SelectedTreeModels do
  begin
    if not (Model is TFmxObject) then
      raise Exception.Create(Translate('Для копирования выберите элементы стиля.'));
    Obj := TFmxObject(Model).Clone(nil);
    try
      VisitStyleText(Obj,
        procedure(Instance: TObject; Prop: TRttiProperty)
        begin
          if Prop.GetValue(Instance).AsString = 'Text' then
            Prop.SetValue(Instance, TValue.From<string>('').Cast(Prop.PropertyType.Handle));
        end);
      if not Result.IsEmpty then
        Result := Result + sLineBreak;
      Result := Result + ComponentText(Obj);
    finally
      Obj.Free;
    end;
  end;
end;

procedure TFormMain.CopyObject;
begin
  if (FSelected = nil) or (FSelected = FRoot) then
    Exit;
  ClipboardService.SetClipboard(TValue.From<string>(ObjectText));
end;

procedure TFormMain.CreateClipboardComponent(Reader: TReader; ComponentClass: TComponentClass; var Component: TComponent);
begin
  if not ComponentClass.InheritsFrom(TFmxObject) or ComponentClass.InheritsFrom(TStyleBook) or
    ComponentClass.InheritsFrom(TCommonCustomForm) then
    raise Exception.Create(Translate('Буфер обмена должен содержать элементы стиля FMX.'));
  Component := ComponentClass.Create(nil);
  SetModelDesigning(TFmxObject(Component));
end;

procedure TFormMain.PasteObject;
begin
  PasteObjectText(ClipboardText);
end;

procedure TFormMain.PasteObjectText(const Text: string);
var
  Source: TStringStream;
  Binary: TMemoryStream;
  Reader: TReader;
  Holder: TLayout;
  Objects: TObjectList<TFmxObject>;
  Parent: TFmxObject;
begin
  if Text.Trim.IsEmpty then
    raise Exception.Create(Translate('Буфер обмена не содержит текст DFM/FMX.'));
  Parent := FSelected;
  if Parent = nil then
    Parent := FRoot;
  if not ((Parent = FRoot) or (Parent is TControl) or (Parent is TControl3D)) then
    raise Exception.Create(Translate('Выберите визуальный родительский объект в дереве.'));
  // A temporary parent accepts several sibling objects copied by Delphi.
  Source := TStringStream.Create('object SBDClipboard: TLayout' + sLineBreak + Text.Trim +
    sLineBreak + 'end', TEncoding.UTF8);
  Binary := TMemoryStream.Create;
  Holder := TLayout.Create(nil);
  Objects := TObjectList<TFmxObject>.Create;
  try
    ObjectTextToBinary(Source, Binary);
    Binary.Position := 0;
    SetModelDesigning(Holder);
    Reader := TReader.Create(Binary, 4096);
    try
      Reader.OnCreateComponent := CreateClipboardComponent;
      Reader.ReadRootComponent(Holder);
    finally
      Reader.Free;
    end;
    for var Child in EditableChildren(Holder) do
    begin
      if (Parent = FRoot) and ((Child is TAnimation) or (Child is TEffect)) then
        raise Exception.Create(Translate('Анимацию или эффект нужно добавить в визуальный ресурс.'));
      var Obj := Child.Clone(nil);
      Objects.Add(Obj);
      RenameStyleResources(Obj);
      SetModelDesigning(Obj);
    end;
    if Objects.Count = 0 then
      raise Exception.Create(Translate('Буфер обмена не содержит элементов стиля.'));
    Remember;
    while Objects.Count > 0 do
    begin
      var Obj := Objects[0];
      if Parent = FRoot then
      begin
        var StyleName := Obj.StyleName;
        if StyleName.IsEmpty then
          StyleName := Obj.ClassName.Substring(1) + 'style';
        Obj.StyleName := UniqueStyleName(StyleName);
      end;
      Obj.Parent := Parent;
      Objects.Extract(Obj);
      if (Parent = FRoot) and (FSelectedGroup <> nil) then
      begin
        Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FAssignments.AddOrSetValue(Obj.Name, FSelectedGroup.ID);
      end;
      FSelected := Obj;
    end;
    FSelectedGroup := nil;
    Changed;
  finally
    Objects.Free;
    Holder.Free;
    Binary.Free;
    Source.Free;
  end;
end;

procedure TFormMain.OpenDocument;
var
  Dialog: TOpenDialog;
begin
  if not ConfirmDiscard then
    Exit;
  Dialog := FOpenStyleDialog;
  if Dialog.Execute then
    LoadDocument(Dialog.FileName);
end;

procedure TFormMain.SaveStyle(const AFileName: string; AFormat: TStyleFormat);
var
  Stream: TFileStream;
  Temp, Backup: string;
begin
  ApplyBindings;
  UpdateDesignerMetadata(True);
  Temp := AFileName + '.' + TGUID.NewGuid.ToString + '.tmp';
  Backup := Temp + '.backup';
  try
    Stream := TFileStream.Create(Temp, fmCreate);
    try
      WriteStyleStream(Stream, AFormat);
    finally
      Stream.Free;
    end;
    if TFile.Exists(AFileName) then
      TFile.Replace(Temp, AFileName, Backup)
    else
      TFile.Move(Temp, AFileName);
  finally
    for var Path in [Temp, Backup] do
      if TFile.Exists(Path) then
        TFile.Delete(Path);
  end;
end;

function TFormMain.SaveDocument(ASaveAs: Boolean): Boolean;
var
  Dialog: TSaveDialog;
  Target: string;
  Format: TStyleFormat;
begin
  Result := False;
  Target := FFileName;
  Format := TStyleFormat.Indexed;
  if ASaveAs or Target.IsEmpty then
  begin
    Dialog := FSaveStyleDialog;
    Dialog.FileName := Target;
    if not Dialog.Execute then
      Exit;
    Target := Dialog.FileName;
    if Dialog.FilterIndex = 2 then
      Format := TStyleFormat.Text;
  end;
  ApplyBindings;
  SaveStyle(Target, Format);
  FFileName := Target;
  FSavedState := Snapshot;
  FDirty := False;
  UpdateCaption;
  Result := True;
end;

procedure TFormMain.SortStyles;
var
  Desired: TArray<TFmxObject>;
  Resources: TList<TFmxObject>;
  ResourceIndex: Integer;
  Reordered: Boolean;
begin
  Desired := ChildrenOf(FRoot);
  Resources := TList<TFmxObject>.Create;
  try
    for var Obj in Desired do
      if not SameText(Obj.StyleName, '#designer') then
        Resources.Add(Obj);
    Resources.Sort(TComparer<TFmxObject>.Construct(
      function(const Left, Right: TFmxObject): Integer
      begin
        Result := CompareText(Left.StyleName, Right.StyleName);
        // Preserve the relative order of equal names.
        if Result = 0 then
          Result := Left.Index - Right.Index;
      end));
    ResourceIndex := 0;
    Reordered := False;
    for var I := 0 to High(Desired) do
      if not SameText(Desired[I].StyleName, '#designer') then
      begin
        if Desired[I] <> Resources[ResourceIndex] then
          Reordered := True;
        Inc(ResourceIndex);
      end;
    if not Reordered then
      Exit;
    Remember;
    // Remember keeps the hidden metadata last. Sort only resource siblings;
    // their children retain the authored stacking order.
    for var I := 0 to Resources.Count - 1 do
      Resources[I].Index := I;
    Changed;
  finally
    Resources.Free;
  end;
end;

procedure TFormMain.ShowStyleCatalog;
begin
  var Catalog := TStyleCatalog.Create;
  try
    var InitialClass := 'TButton';
    if FPalette.Selected <> nil then
      InitialClass := FPalette.Selected.Text;
    if FSelected is TStyledControl then
      InitialClass := FSelected.ClassName;
    if Catalog.Find(InitialClass) = nil then
      InitialClass := 'TButton';
    var Dialog := TStyleCatalogDialog.CreateCatalog(Self, Catalog,
      function(Name: string): Boolean
      begin
        Result := FindStyleRoot(Name) <> nil;
      end, InitialClass);
    try
      if (Dialog.ShowModal = mrOk) and (Dialog.Definition <> nil) then
        CreateStyleTemplate(Catalog, Dialog.Definition);
    finally
      Dialog.Free;
    end;
  finally
    Catalog.Free;
  end;
end;

procedure TFormMain.CreateStyleTemplate(Catalog: TStyleCatalog; Definition: TStyleDefinition);
begin
  var Plan := Catalog.BuildTemplate(Definition, UniqueStyleName(Definition.DefaultStyleName),
    function(Name: string): Boolean
    begin
      Result := FindStyleRoot(Name) <> nil;
    end);
  try
    var ParentID := '';
    if FSelectedGroup <> nil then
      ParentID := FSelectedGroup.ID;
    var Before := Snapshot;
    var UndoHistory := FUndo.ToArray;
    var RedoHistory := FRedo.ToArray;
    Remember;
    try
      var GroupID := ParentID;
      if Plan.Composite then
      begin
        var Group := TStyleGroup.Create;
        Group.ID := TGUID.NewGuid.ToString;
        Group.Title := Definition.ClassName + ' (' + Plan.Main.StyleName + ')';
        Group.ParentID := ParentID;
        FGroups.Add(Group);
        GroupID := Group.ID;
      end;
      var Main := Plan.Main;
      while Plan.Resources.Count > 0 do
      begin
        var Obj := Plan.Resources[0];
        SetModelDesigning(Obj);
        Obj.Parent := FRoot;
        Plan.Resources.Extract(Obj);
        if not GroupID.IsEmpty then
        begin
          Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
          FAssignments.AddOrSetValue(Obj.Name, GroupID);
        end;
      end;
      if IsPreviewClass(Definition.ClassName) then
        StoreStyleClass(Main, Definition.ClassName);
      FSelectedGroup := nil;
      FSelected := Main;
      Changed;
    except
      Restore(Before);
      FUndo.Clear;
      FUndo.AddRange(UndoHistory);
      FRedo.Clear;
      FRedo.AddRange(RedoHistory);
      UpdateCaption;
      raise;
    end;
  finally
    Plan.Free;
  end;
end;

function TFormMain.UniqueStyleName(const ABase: string): string;
var
  I: Integer;
  Exists: Boolean;
  Child: TFmxObject;
begin
  Result := ABase.ToLower;
  I := 1;
  repeat
    Exists := False;
    for Child in ChildrenOf(FRoot) do
      if SameText(Child.StyleName, Result) then
      begin
        Exists := True;
        Break;
      end;
    if Exists then
    begin
      Inc(I);
      Result := ABase.ToLower + I.ToString;
    end;
  until not Exists;
end;

procedure TFormMain.AddObject(const AClassName: string);
var
  C: TFmxObjectClass;
  Obj, Parent: TFmxObject;
begin
  if not FClasses.TryGetValue(AClassName, C) then
    raise Exception.Create(Translate('Класс не найден: ') + AClassName);
  Parent := FSelected;
  if Parent = nil then
    Parent := FRoot;
  if not ((Parent = FRoot) or (Parent is TControl) or (Parent is TControl3D)) then
    raise Exception.Create(Translate('Выберите визуальный родительский объект в дереве.'));
  if (Parent = FRoot) and (C.InheritsFrom(TAnimation) or C.InheritsFrom(TEffect)) then
    raise Exception.Create(Translate('Анимацию или эффект нужно добавить в визуальный ресурс.'));
  Obj := C.Create(nil);
  try
    if Parent = FRoot then
      Obj.StyleName := UniqueStyleName(AClassName.Substring(1) + 'style')
    else
      Obj.StyleName := AClassName.Substring(1).ToLower;
    if Obj is TControl then
    begin
      TControl(Obj).SetBounds(10, 10, 160, 40);
      TControl(Obj).HitTest := False;
      if Parent = FRoot then
        TControl(Obj).Position.Point := PointF(0, 0);
    end;
    if Obj is TAnimation then
    begin
      TAnimation(Obj).Enabled := False;
      TAnimation(Obj).Duration := 0.2;
      TAnimation(Obj).Trigger := 'IsMouseOver=true';
    end;
    Remember;
    SetModelDesigning(Obj);
    Obj.Parent := Parent;
    if (Parent = FRoot) and (FSelectedGroup <> nil) then
    begin
      Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
      FAssignments.AddOrSetValue(Obj.Name, FSelectedGroup.ID);
    end;
    FSelectedGroup := nil;
    FSelected := Obj;
    Obj := nil;
  finally
    Obj.Free;
  end;
  Changed;
end;

procedure TFormMain.DetachPropertyBinding(Obj: TFmxObject; const Path: string);
begin
  for var I := FBindings.Count - 1 downto 0 do
    if (FBindings[I].TargetName = Obj.Name) and (FBindings[I].PropertyPath = Path) then
      FBindings.Delete(I);
end;

procedure TFormMain.RemoveObjectBindings(Obj: TFmxObject);
begin
  FStyleClasses.Remove(Obj.Name);
  for var I := FBindings.Count - 1 downto 0 do
    if FBindings[I].TargetName = Obj.Name then
      FBindings.Delete(I);
  for var Child in ChildrenOf(Obj) do
    RemoveObjectBindings(Child);
end;

function TFormMain.SelectedTreeModels: TArray<TObject>;
var
  Models: TList<TObject>;
begin
  Models := TList<TObject>.Create;
  try
    if (FTree.Selected <> nil) and ((FTree.Selected.TagObject = FSelected) or
      (FTree.Selected.TagObject = FSelectedGroup)) then
      for var Item in TStyleTreeView(FTree).SelectedItems do
        Models.Add(Item.TagObject);
    if Models.Count = 0 then
    begin
      if FSelectedGroup <> nil then
        Models.Add(FSelectedGroup)
      else if (FSelected <> nil) and (FSelected <> FRoot) then
        Models.Add(FSelected);
    end;
    Result := Models.ToArray;
  finally
    Models.Free;
  end;
end;

procedure TFormMain.DeleteSelection;
var
  Models: TArray<TObject>;
begin
  Models := SelectedTreeModels;
  if Length(Models) <= 1 then
  begin
    if FSelectedGroup <> nil then
      GroupAction(acDelete)
    else
      DeleteObject;
    Exit;
  end;
  Remember;
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  FSelected := FRoot;
  FSelectedGroup := nil;
  for var Model in Models do
    if Model is TStyleGroup then
    begin
      var Group := TStyleGroup(Model);
      for var Child in FGroups do
        if Child.ParentID = Group.ID then
          Child.ParentID := Group.ParentID;
      for var Key in FAssignments.Keys.ToArray do
        if FAssignments[Key] = Group.ID then
          if Group.ParentID.IsEmpty then
            FAssignments.Remove(Key)
          else
            FAssignments.AddOrSetValue(Key, Group.ParentID);
      FGroups.Remove(Group);
    end
    else if (Model is TFmxObject) and (Model <> FRoot) then
    begin
      RemoveObjectBindings(TFmxObject(Model));
      FAssignments.Remove(TFmxObject(Model).Name);
      Model.Free;
    end;
  Changed;
end;

procedure TFormMain.DeleteObject;
var
  Parent: TFmxObject;
begin
  if (FSelected = nil) or (FSelected = FRoot) then
    Exit;
  Remember;
  Parent := EditableParent(FSelected);
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  RemoveObjectBindings(FSelected);
  FAssignments.Remove(FSelected.Name);
  FSelected.Free;
  FSelected := Parent;
  Changed;
end;

procedure TFormMain.RenameStyleResources(AObject: TFmxObject);
var
  Child: TFmxObject;
begin
  AObject.Name := '';
  for Child in ChildrenOf(AObject) do
    RenameStyleResources(Child);
end;

procedure TFormMain.DuplicateObject;
var
  Models: TArray<TObject>;
  Copies: TObjectList<TFmxObject>;
  Created: TList<TFmxObject>;
begin
  if (FSelected = nil) or (FSelected = FRoot) then
    Exit;
  Models := SelectedTreeModels;
  Copies := TObjectList<TFmxObject>.Create;
  Created := TList<TFmxObject>.Create;
  try
    for var Model in Models do
    begin
      if not (Model is TFmxObject) then
        Exit;
      var Copy := TFmxObject(Model).Clone(nil);
      Copies.Add(Copy);
      RenameStyleResources(Copy);
      SetModelDesigning(Copy);
    end;
    Remember;
    for var Model in Models do
    begin
      var Original := TFmxObject(Model);
      var Copy := Copies[0];
      if Original.Parent = FRoot then
        Copy.StyleName := UniqueStyleName(Original.StyleName + '_copy');
      Copy.Parent := Original.Parent;
      Copy.Index := Original.Index + 1;
      Copies.Extract(Copy);
      Created.Add(Copy);
      var AssignedClass := AssignedStyleClass(Original);
      if not AssignedClass.IsEmpty then
      begin
        Copy.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FStyleClasses.AddOrSetValue(Copy.Name, AssignedClass);
      end;
      var GroupID := GroupOf(Original);
      if not GroupID.IsEmpty then
      begin
        if AssignedClass.IsEmpty then
          Copy.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FAssignments.AddOrSetValue(Copy.Name, GroupID);
      end;
      FSelected := Copy;
    end;
    Changed;
    if Created.Count > 1 then
    begin
      FBuilding := True;
      try
        for var I := 0 to Created.Count - 1 do
          if I = 0 then
            TStyleTreeView(FTree).ChooseItem(FTreeItems[Pointer(Created[I])], [])
          else
            TStyleTreeView(FTree).ChooseItem(FTreeItems[Pointer(Created[I])], [ssCtrl]);
      finally
        FBuilding := False;
      end;
      TreeChange(nil);
    end;
  finally
    Created.Free;
    Copies.Free;
  end;
end;

procedure TFormMain.MoveObject(AAction: Integer);
var
  Parent, Target: TFmxObject;
  Index, MoveIndex: Integer;
begin
  if (FSelected = nil) or (FSelected = FRoot) then
    Exit;
  Parent := FSelected.Parent;
  Target := nil;
  Index := FSelected.Index;
  MoveIndex := Index;
  case AAction of
    acFront, acBack:
      begin
        if AAction = acFront then
          MoveIndex := Parent.ChildrenCount - 1
        else
          MoveIndex := 0;
        if (Parent = FRoot) and SameText(Parent.Children[MoveIndex].StyleName, '#designer') then
          Dec(MoveIndex);
        if MoveIndex = Index then
          Exit;
      end;
    acUp, acDown:
      begin
        repeat
          if AAction = acUp then
            Dec(MoveIndex)
          else
            Inc(MoveIndex);
        until (MoveIndex < 0) or (MoveIndex >= Parent.ChildrenCount) or
              ((Parent <> FRoot) or (not SameText(Parent.Children[MoveIndex].StyleName, '#designer') and
              (GroupOf(Parent.Children[MoveIndex]) = GroupOf(FSelected))));
        if (MoveIndex < 0) or (MoveIndex >= Parent.ChildrenCount) then
          Exit;
      end;
    acIndent:
      begin
        if Index = 0 then
          Exit;
        Target := Parent.Children[Index - 1];
        if SameText(Target.StyleName, '#designer') then
          Exit;
        if not ((Target is TControl) or (Target is TControl3D)) then
          raise Exception.Create(Translate('Предыдущий узел не может содержать визуальные объекты.'));
      end;
    acOutdent:
      begin
        if Parent = FRoot then
        begin
          var StyleGroup := FindGroup(GroupOf(FSelected));
          if StyleGroup <> nil then
            AssignToGroup(FSelected, nil, StyleGroup.ParentID);
          Exit;
        end;
        Parent := EditableParent(FSelected);
        Target := EditableParent(Parent);
        if (Target = FRoot) and not ((FSelected is TControl) or (FSelected is TControl3D)) then
          raise Exception.Create(Translate('Невизуальный объект должен оставаться внутри ресурса.'));
      end;
  end;
  Remember;
  case AAction of
    acUp, acDown, acFront, acBack:
      FSelected.Index := MoveIndex;
    acIndent:
      FSelected.Parent := Target;
    acOutdent:
      begin
        FSelected.Parent := Target;
        FSelected.Index := Parent.Index + 1;
        if Target = FRoot then
          FSelected.StyleName := UniqueStyleName(FSelected.StyleName + 'style');
      end;
  end;
  if FSelected.Parent <> FRoot then
    FAssignments.Remove(FSelected.Name);
  Changed;
end;

procedure TFormMain.Undo(ARedo: Boolean);
var
  Source, Target: TList<TBytes>;
  State: TBytes;
begin
  if ARedo then
  begin
    Source := FRedo;
    Target := FUndo;
  end
  else
  begin
    Source := FUndo;
    Target := FRedo;
  end;
  if Source.Count = 0 then
    Exit;
  State := Source.Last;
  Target.Add(Snapshot);
  Source.Delete(Source.Count - 1);
  Restore(State);
end;

procedure TFormMain.ImportDefault;
var
  Style, Root: TFmxObject;
begin
  if not ConfirmDiscard then
    Exit;
  Style := TStyleManager.ActiveStyle(Self);
  if Style = nil then
    raise Exception.Create(Translate('Системный стиль недоступен.'));
  UnpackStyleBinaries(Style);
  Root := Style.Clone(nil);
  try
    UnpackStyleBinaries(Root);
  except
    Root.Free;
    raise;
  end;
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  FTreeModelRoot := nil;
  FRoot.Free;
  FRoot := Root;
  SetModelDesigning(FRoot);
  FPreviewDirty := True;
  FSelected := FRoot;
  FFileName := '';
  FSelectedGroup := nil;
  FGroups.Clear;
  FAssignments.Clear;
  FStyleClasses.Clear;
  FPreviewSource := nil;
  FValues.Clear;
  FBindings.Clear;
  UpdateValueReferences;
  RebuildTree;
  ClearHistory;
  FSavedState := nil;
  FResourceTheme := rtLight;
  SyncResourceThemeView;
  Changed(False);
end;

function TFormMain.SelectedStyleRoot: TFmxObject;
begin
  Result := FSelected;
  if (Result = nil) or (Result = FRoot) then
    Exit(nil);
  while (Result.Parent <> nil) and (Result.Parent <> FRoot) do
    Result := Result.Parent;
  if (Result.Parent <> FRoot) or SameText(Result.StyleName, '#designer') then
    Result := nil;
end;

function TFormMain.AssignedStyleClass(Resource: TFmxObject): string;
begin
  Result := '';
  if (Resource <> nil) and (Resource.Parent = FRoot) then
    FStyleClasses.TryGetValue(Resource.Name, Result);
end;

function TFormMain.IsPreviewClass(const ClassName: string): Boolean;
begin
  var C: TFmxObjectClass;
  Result := FClasses.TryGetValue(ClassName, C) and C.InheritsFrom(TStyledControl) and
    not ClassName.StartsWith('TCustom');
end;

function TFormMain.DetectStyleClass(Resource: TFmxObject): string;

  function NameMatches(const Name, Base: string): Boolean;
  begin
    Result := SameText(Name, Base) or (Name.StartsWith(Base + '_')) or
      (Name.StartsWith(Base) and (Name.Length > Base.Length) and CharInSet(Name[Base.Length + 1], ['0'..'9']));
  end;

  function HasPart(const Name: string): Boolean;
  begin
    Result := Resource.FindStyleResource(Name) <> nil;
  end;

begin
  Result := AssignedStyleClass(Resource);
  if IsPreviewClass(Result) then
    Exit;
  Result := 'TButton';
  if Resource = nil then
    Exit;
  var Name := Resource.StyleName.ToLower;
  // Prefer the concrete class name before defaults shared by several classes.
  for var ClassName in FNames do
    if IsPreviewClass(ClassName) and NameMatches(Name, ClassName.Substring(1).ToLower + 'style') then
      Exit(ClassName);
  var Catalog := TStyleCatalog.Create;
  try
    for var ClassName in FNames do
    begin
      if not IsPreviewClass(ClassName) then
        Continue;
      var Entry := Catalog.Find(ClassName);
      if (Entry <> nil) and not Entry.DefaultStyleName.IsEmpty and NameMatches(Name, Entry.DefaultStyleName) then
        Exit(ClassName);
    end;
  finally
    Catalog.Free;
  end;
  if Resource is TCustomSwitchObject then
    Result := 'TSwitch'
  else if HasPart('days') and HasPart('months') then
    Result := 'TCalendar'
  else if HasPart('minusbutton') and HasPart('plusbutton') then
    Result := 'TSpinBox'
  else if HasPart('magglass') then
    Result := 'TSearchBox'
  else if (Resource.FindStyleResource('htrack') is TCustomTrack) or
    (Resource.FindStyleResource('vtrack') is TCustomTrack) then
    Result := 'TScrollBar'
  else if HasPart('header') and HasPart('content') then
    Result := 'TGrid'
  else if HasPart('font') and HasPart('content') then
  begin
    if HasPart('vscrollbar') then
      Result := 'TMemo'
    else
      Result := 'TEdit';
  end
  else if HasPart('hthumb') or HasPart('vthumb') or HasPart('thumb') then
    Result := 'TTrackBar'
  else if HasPart('hindicator') or HasPart('vindicator') then
    Result := 'TProgressBar';
  if not IsPreviewClass(Result) then
    Result := 'TButton';
end;

procedure TFormMain.StoreStyleClass(Resource: TFmxObject; const ClassName: string);
begin
  if ClassName.IsEmpty then
    FStyleClasses.Remove(Resource.Name)
  else
  begin
    if Resource.Name = '' then
      Resource.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
    FStyleClasses.AddOrSetValue(Resource.Name, ClassName);
  end;
end;

procedure TFormMain.AssignStyleClass(Resource: TFmxObject; const ClassName: string);
begin
  if (Resource = nil) or (Resource.Parent <> FRoot) or SameText(Resource.StyleName, '#designer') then
    raise Exception.Create(Translate('Класс назначается только корневому стилю.'));
  if not ClassName.IsEmpty and not IsPreviewClass(ClassName) then
    raise Exception.Create(Translate('Класс не найден: ') + ClassName);
  if AssignedStyleClass(Resource) = ClassName then
    Exit;
  Remember;
  StoreStyleClass(Resource, ClassName);
  if FPreview <> nil then
    TPreviewForm(FPreview).SelectClass(DetectStyleClass(Resource));
  Changed(False);
  if (FPreview <> nil) and FPreview.Visible then
    RefreshPreview(nil);
end;

procedure TFormMain.PreviewAssignClass(Sender: TObject);
begin
  if (FPreviewSource = nil) or (FPreviewSource <> SelectedStyleRoot) then
    Exit;
  if TComponent(Sender).Tag = 1 then
    AssignStyleClass(FPreviewSource, '')
  else
    AssignStyleClass(FPreviewSource, TPreviewForm(FPreview).SelectedClass);
end;

procedure TFormMain.ShowPreview;
begin
  if FPreview = nil then
  begin
    var Preview := TPreviewForm.Create(Self);
    FPreview := Preview;
    FPreviewBook := Preview.PreviewBook;
    FPreviewClass := Preview.ClassList;
    FPreviewHost := Preview.SelectedControlHost;
    Preview.ConfigureClasses(FClasses, FNames);
    Preview.OnPreviewChange := RefreshPreview;
    Preview.OnAssignClass := PreviewAssignClass;
  end;
  TPreviewForm(FPreview).SelectClass(DetectStyleClass(SelectedStyleRoot));
  RefreshPreview(nil);
  FPreview.Show;
end;

procedure TFormMain.RefreshPreview(Sender: TObject);
begin
  FPreviewRefreshTimer.Enabled := False;
  if (FPreview = nil) or FBuilding then
    Exit;
  var Preview := TPreviewForm(FPreview);
  ConfigureWorkspaceBackground(Preview.WorkspaceBackground.Fill);
  Preview.ClearControl;
  if FPreviewDirty or (FPreviewBook.Style = nil) then
  begin
    var Stream := TMemoryStream.Create;
    try
      WriteStyleStream(Stream, TStyleFormat.Binary);
      Stream.Position := 0;
      FPreviewBook.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    FPreviewDirty := False;
  end;
  var Resource := SelectedStyleRoot;
  if Resource <> FPreviewSource then
    Preview.SelectClass(DetectStyleClass(Resource));
  FPreviewSource := Resource;
  var StyleName := '';
  if Resource <> nil then
    StyleName := Resource.StyleName;
  Preview.SetResource(StyleName, AssignedStyleClass(Resource), Resource <> nil);
  Preview.CreateControl(StyleName);
end;

procedure TFormMain.ValidateStyle;
var
  Names: TStringList;
  Errors: TStringList;
  Child: TFmxObject;

  procedure CheckObject(Obj: TFmxObject);
  var
    C: TFmxObject;
    Animation: TAnimation;
    Context: TRttiContext;
    Prop: TRttiProperty;
    PropertyName: string;
    Target: TObject;
    Parts: TArray<string>;
  begin
    if Obj is TAnimation then
    begin
      Animation := TAnimation(Obj);
      Context := TRttiContext.Create;
      try
        Prop := Context.GetType(Obj.ClassType).GetProperty('PropertyName');
        if Prop <> nil then
        begin
          PropertyName := Prop.GetValue(Obj).AsString;
          if PropertyName.IsEmpty then
            Errors.Add(Obj.StyleName + Translate(': у анимации не задано PropertyName'))
          else
          begin
            Parts := PropertyName.Split(['.']);
            Target := Obj.Parent;
            for var Part in Parts do
            begin
              if Target = nil then
                Break;
              Prop := Context.GetType(Target.ClassType).GetProperty(Part);
              if Prop = nil then
              begin
                Errors.Add(Obj.StyleName + Translate(': свойство ') + PropertyName + Translate(' не найдено у родителя'));
                Break;
              end;
              if Prop.PropertyType.TypeKind = tkClass then
                Target := Prop.GetValue(Target).AsObject;
            end;
          end;
        end;
        if (Animation.Trigger = '') and not Animation.Enabled then
          Errors.Add(Obj.StyleName + Translate(': анимация выключена и не имеет Trigger'));
      finally
        Context.Free;
      end;
    end;
    for C in ChildrenOf(Obj) do
      CheckObject(C);
  end;

begin
  Names := TStringList.Create;
  Errors := TStringList.Create;
  try
    Names.CaseSensitive := False;
    for Child in ChildrenOf(FRoot) do
    begin
      if SameText(Child.StyleName, '#designer') then
        Continue;
      if Child.StyleName.IsEmpty and not (Child is TStyleDescription) then
        Errors.Add(Child.ClassName + Translate(': отсутствует StyleName'));
      if not Child.StyleName.IsEmpty then
      begin
        if Names.IndexOf(Child.StyleName) >= 0 then
          Errors.Add(Translate('Повторяющееся имя ресурса: ') + Child.StyleName);
        Names.Add(Child.StyleName);
      end;
      CheckObject(Child);
    end;
    if Errors.Count = 0 then
      ShowAppMessage(Self, Translate('Структура стиля проверена. Ошибок имён ресурсов и свойств анимаций не найдено.'))
    else
      ShowAppMessage(Self, Errors.Text);
  finally
    Errors.Free;
    Names.Free;
  end;
end;

procedure TFormMain.EditCollection(ACollection: TCollection; const APath: string);
var
  Dialog: TCollectionDialog;
  State: TBytes;
begin
  if ACollection is TBitmapLinks then
  begin
    EditBitmapLinks(TBitmapLinks(ACollection), APath);
    Exit;
  end;
  FRefreshTimer.Enabled := False;
  State := Snapshot;
  Dialog := TCollectionDialog.CreateEditor(Self, ACollection, APath);
  try
    if Dialog.ShowModal = mrOk then
    begin
      FUndo.Add(State);
      FRedo.Clear;
      Changed;
    end
    else
      Restore(State);
  finally
    Dialog.Free;
    BuildProperties;
  end;
end;

procedure TFormMain.EditBitmapLinks(Links: TBitmapLinks; const Path: string);
begin
  FRefreshTimer.Enabled := False;
  var Background := TBrush.Create(TBrushKind.Solid, $FFFFFFFF);
  try
    ConfigureWorkspaceBackground(Background);
    var Dialog := TBitmapLinksEditorForm.CreateEditor(Self, FSelected, FRoot, Links, Path, Background);
    try
      if Dialog.ShowModal = mrOk then
        ApplyBitmapLinks(Dialog);
    finally
      Dialog.Free;
    end;
  finally
    Background.Free;
  end;
end;

function TFormMain.ApplyBitmapLinks(Dialog: TBitmapLinksEditorForm): Boolean;
begin
  Result := Dialog.HasChanges;
  if not Result then
    Exit;
  var Error: string;
  if not Dialog.Validate(Error) then
    raise EArgumentException.Create(Error);
  var Paths := TStringList.Create;
  try
    Dialog.GetChangedPaths(Paths);
    Remember;
    Dialog.Commit;
    for var Path in Paths do
      for var I := FBindings.Count - 1 downto 0 do
        if (FBindings[I].TargetName = FSelected.Name) and
          ((FBindings[I].PropertyPath = Path) or FBindings[I].PropertyPath.StartsWith(Path + '.') or
          FBindings[I].PropertyPath.StartsWith(Path + '[')) then
          FBindings.Delete(I);
    Changed;
  finally
    Paths.Free;
  end;
end;

procedure TFormMain.EditNamedValues;
var
  Dialog: TNamedValuesDialog;
  State: TBytes;
begin
  Dialog := TNamedValuesDialog.CreateEditor(Self);
  try
    if (Dialog.ShowModal <> mrOk) or not Dialog.IsChanged then
      Exit;
    for var Value in Dialog.Values do
    begin
      ValidateNamedValue(Value);
      for var Binding in Dialog.Bindings do
        if SameText(Binding.ResourceName, Value.Name) then
          ValidateBinding(Value, Binding);
    end;
    State := Snapshot;
    try
      FValues.Clear;
      while Dialog.Values.Count > 0 do
        FValues.Add(Dialog.Values.Extract(Dialog.Values[0]));
      FBindings.Clear;
      while Dialog.Bindings.Count > 0 do
        FBindings.Add(Dialog.Bindings.Extract(Dialog.Bindings[0]));
      ApplyBindings;
    except
      Restore(State);
      raise;
    end;
    FUndo.Add(State);
    FRedo.Clear;
    UpdateValueReferences;
    Changed(False);
    RefreshDesign(True);
    FProperties.RefreshValues;
    PropertySelectionChanged(nil);
  finally
    Dialog.Free;
  end;
end;

procedure TFormMain.PerformanceTest(const FileName: string);
var
  Log: TStringList;
  Watch: TStopwatch;

  procedure RecordTime(const Operation: string);
  begin
    Watch.Stop;
    Log.Add(Operation + ': ' + Watch.ElapsedMilliseconds.ToString + ' ms');
  end;

begin
  Log := TStringList.Create;
  try
    Log.Add(FileName);
    Watch := TStopwatch.StartNew;
    LoadDocument(FileName);
    Show;
    Application.ProcessMessages;
    RecordTime('Load');
    Log.Add(FLastLoadPhases);
    Watch := TStopwatch.StartNew;
    LoadDocument(FileName);
    Application.ProcessMessages;
    RecordTime('Open file in shown editor');
    Log.Add(FLastLoadPhases);
    Log.Add('Resources: ' + StyleResourceCount.ToString + '; tree nodes: ' + Length(TreeItems(FTree)).ToString);
    var Resource: TFmxObject := nil;
    for var Child in ChildrenOf(FRoot) do
      if SameText(Child.StyleName, 'buttonstyle') and (Child is TControl) then
        Resource := Child;
    if Resource = nil then
      for var Child in ChildrenOf(FRoot) do
        if (Child is TControl) and not SameText(Child.StyleName, '#designer') then
        begin
          Resource := Child;
          Break;
        end;
    if Resource = nil then
      raise Exception.Create('No visual resource for performance test');
    Watch := TStopwatch.StartNew;
    SelectObject(Resource);
    Application.ProcessMessages;
    RecordTime('Select resource');
    if Resource.ChildrenCount > 0 then
    begin
      Watch := TStopwatch.StartNew;
      for var I := 1 to 10 do
        SelectObject(Resource.Children[0]);
      Application.ProcessMessages;
      RecordTime('10 selections inside resource');
      Watch := TStopwatch.StartNew;
      for var I := 0 to Resource.ChildrenCount - 1 do
        SelectObject(Resource.Children[I]);
      Application.ProcessMessages;
      RecordTime('Select all different resource children');
    end;
    SelectObject(Resource);
    Application.ProcessMessages;
    Watch := TStopwatch.StartNew;
    Snapshot;
    RecordTime('Snapshot');
    var ClickUndo := FUndo.Count;
    Watch := TStopwatch.StartNew;
    DesignDown(FResizeHandle, TMouseButton.mbLeft, [], 4, 4);
    DesignUp(FResizeHandle, TMouseButton.mbLeft, [], 4, 4);
    RecordTime('Canvas click without movement');
    if (FUndo.Count <> ClickUndo) or (Length(FDragSnapshot) <> 0) then
      raise Exception.Create('Click recorded history');
    Watch := TStopwatch.StartNew;
    RebuildTree;
    Application.ProcessMessages;
    RecordTime('Rebuild tree');
    Log.Add(Format('Tree %d; inspector %d; design %d ms', [FLastTreeMS, FLastInspectorMS, FLastDesignMS]));
    Log.Add(FLastTreePhases + Format('reorders=%d; reparents=%d', [FTreeReorderedCount, FTreeReparentedCount]));
    var BeforeCreated := FTreeCreatedCount;
    var TreeItem := FTree.Selected;
    var InspectorEditor := FProperties.FindProperty('Opacity').Editor;
    var DisplayCopy := FDesignRoot;
    Watch := TStopwatch.StartNew;
    FProperties.WriteProperty('Opacity', '0.9');
    DeferredRefresh(nil);
    Application.ProcessMessages;
    RecordTime('Property edit with refresh');
    if (BeforeCreated <> FTreeCreatedCount) or (FTree.Selected <> TreeItem) or
      (FProperties.FindProperty('Opacity').Editor <> InspectorEditor) or (FDesignRoot <> DisplayCopy) then
      raise Exception.Create('Property edit rebuilt existing controls');
    if Abs(TControl(FDesignRoot).Opacity - 0.9) > 0.001 then
      raise Exception.Create('Display copy not updated');
    Log.Add('Property edit preserves tree, inspector and display control instances');
    BeforeCreated := FTreeCreatedCount;
    Watch := TStopwatch.StartNew;
    DuplicateObject;
    Application.ProcessMessages;
    RecordTime('Duplicate resource');
    if (FTreeCreatedCount - BeforeCreated) >= 100 then
      raise Exception.Create('Duplicate rebuilt unrelated branches');
    Log.Add('Created tree nodes: ' + (FTreeCreatedCount - BeforeCreated).ToString);
    var Destination := FSelected;
    if Resource.ChildrenCount > 0 then
    begin
      var Source := Resource.Children[0];
      var SourceItem := FTreeItems[Pointer(Source)];
      var DestItem := FTreeItems[Pointer(Destination)];
      if CanDrop(SourceItem, DestItem) then
      begin
        Watch := TStopwatch.StartNew;
        var Allow := True;
        TreeDragChange(SourceItem, DestItem, Allow);
        DeferredRefresh(nil);
        Application.ProcessMessages;
        RecordTime('Tree drop between resources with history');
        if (Source.Parent <> Destination) or (FTreeItems[Pointer(Source)] <> SourceItem) then
          raise Exception.Create('Tree drop did not retain moved row');
        SelectObject(Destination);
      end;
    end;
    Log.Add(Format('Tree %d; inspector %d; design %d ms', [FLastTreeMS, FLastInspectorMS, FLastDesignMS]));
    Log.Add(FLastTreePhases + Format('reorders=%d; reparents=%d', [FTreeReorderedCount, FTreeReparentedCount]));
    var BeforeCancelRoot := FRoot;
    TreeItem := FTree.Selected;
    InspectorEditor := FProperties.FindProperty('Opacity').Editor;
    DisplayCopy := FDesignRoot;
    var BeforeCancelUndo := FUndo.Count;
    Watch := TStopwatch.StartNew;
    TThread.ForceQueue(nil,
      procedure
      begin
        for var I := 0 to Screen.FormCount - 1 do
          if Screen.Forms[I] is TNamedValuesDialog then
          begin
            var Dialog := TNamedValuesDialog(Screen.Forms[I]);
            Dialog.ResourceAction(Dialog.AddButton);
            Dialog.ModalResult := mrCancel;
          end;
      end);
    EditNamedValues;
    RecordTime('Cancel changed resource draft');
    if (FRoot <> BeforeCancelRoot) or (FTree.Selected <> TreeItem) or
      (FProperties.FindProperty('Opacity').Editor <> InspectorEditor) or
      (FDesignRoot <> DisplayCopy) or (FUndo.Count <> BeforeCancelUndo) then
      raise Exception.Create('Cancel resource dialog changed document controls');
    Log.Add('Cancel preserves model, tree, inspector, display and undo history');
    FDirty := False;
  finally
    Log.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'performance-result.txt'), TEncoding.UTF8);
    Log.Free;
  end;
end;

procedure TFormMain.SelfTest;
var
  State: TBytes;
  FileName, TraceFile: string;
  Book: TStyleBook;
  Stream: TBytesStream;
  Picture: TBitmap;
  Resource: TFmxObject;
  ValuesDialog: TNamedValuesDialog;

  procedure Check(Condition: Boolean; const Description: string);
  begin
    TFile.AppendAllText(TraceFile, Description + sLineBreak, TEncoding.UTF8);
    if not Condition then
      raise Exception.Create('SELFTEST: ' + Description);
  end;

  procedure CheckTreeOrder;
  var
    Index: Integer;

    procedure Visit(Item: TTreeViewItem);
    begin
      Check((Item.GlobalIndex = Index) and (FTree.ItemByGlobalIndex(Index) = Item),
        'tree global index matches displayed order ' + Index.ToString);
      if Item.IsVisible then
      begin
        var Point := FTree.AbsoluteToLocal(Item.LocalToAbsolute(PointF(Item.Width - 8, Item.Height / 2)));
        Check(FTree.ItemByPoint(Point.X, Point.Y) = Item, 'tree hit test matches row after sort ' + Index.ToString);
      end;
      Inc(Index);
      if Item.IsExpanded then
        for var I := 0 to Item.Count - 1 do
          Visit(Item.Items[I]);
    end;

  begin
    Index := 0;
    for var I := 0 to FTree.Count - 1 do
      Visit(FTree.Items[I]);
    Check(Index = FTree.GlobalCount, 'tree visible row count matches sorted hierarchy');
  end;

  function MenuReference(Menu: TMenuItem; const Name: string): TMenuItem;
  begin
    Result := nil;
    for var I := 0 to Menu.ItemsCount - 1 do
      if SameText(Menu.Items[I].TagString, Name) then
        Exit(Menu.Items[I]);
  end;

  function MenuClass(const ClassName: string): TMenuItem;
  begin
    Result := nil;
    for var I := 0 to UsedInButton.ItemsCount - 1 do
      if SameText(UsedInButton.Items[I].Text, ClassName) then
        Exit(UsedInButton.Items[I]);
  end;

  function SameSnapshot(const Before, After: TBytes): Boolean;
  begin
    Result := (Length(Before) = Length(After)) and
      ((Length(Before) = 0) or CompareMem(@Before[0], @After[0], Length(Before)));
  end;

  function HitDesignObject(const FormPoint: TPointF): TFmxObject;
  var
    Hit: IControl;
  begin
    Result := nil;
    Hit := ObjectAtPoint(ClientToScreen(FormPoint));
    if Hit <> nil then
      Result := Hit.GetObject;
  end;

  function FindDesignObject(Copy: TFmxObject; Model: TObject): TFmxObject;
  begin
    Result := nil;
    if Copy = nil then
      Exit;
    if Copy.TagObject = Model then
      Exit(Copy);
    for var Child in ChildrenOf(Copy) do
    begin
      Result := FindDesignObject(Child, Model);
      if Result <> nil then
        Exit;
    end;
  end;

  function GuidePixels(HighlightOnly: Boolean = False): Integer;
  var
    Bitmap: TBitmap;
    Data: TBitmapData;
  begin
    Result := 0;
    Bitmap := TBitmap.Create(Ceil(FGuides.Width), Ceil(FGuides.Height));
    try
      Bitmap.Clear(0);
      Check(Bitmap.Canvas.BeginScene, 'guide bitmap canvas available');
      try
        PaintGuides(FGuides, Bitmap.Canvas);
      finally
        Bitmap.Canvas.EndScene;
      end;
      Check(Bitmap.Map(TMapAccess.Read, Data), 'guide bitmap readable');
      try
        for var Y := 0 to Bitmap.Height - 1 do
          for var X := 0 to Bitmap.Width - 1 do
          begin
            var Pixel := TAlphaColorRec(Data.GetPixel(X, Y));
            if (Pixel.A > 0) and (not HighlightOnly or ((Pixel.R > Pixel.G) and (Pixel.B > Pixel.G))) then
              Inc(Result);
          end;
      finally
        Bitmap.Unmap(Data);
      end;
    finally
      Bitmap.Free;
    end;
  end;

  procedure SetTestProperty(const Path, Text: string);
  begin
    var Entry := ResolveProperty(FSelected, Path);
    Check(Entry <> nil, 'resolve ' + Path);
    try
      SetPropertyText(Entry, Text);
    finally
      Entry.Free;
    end;
  end;

  procedure CaptureDialog(Dialog: TForm; const ImageName: string);
  var
    Bitmap: TBitmap;
  begin
    Dialog.StyleBook := StyleBook;
    Dialog.Show;
    for var I := 1 to 5 do
    begin
      Application.ProcessMessages;
      Sleep(20);
    end;
    Bitmap := TBitmap.Create(Round(Dialog.ClientWidth), Round(Dialog.ClientHeight));
    try
      Bitmap.Clear($FF202020);
      if Bitmap.Canvas.BeginScene then
      try
        Dialog.PaintTo(Bitmap.Canvas);
      finally
        Bitmap.Canvas.EndScene;
      end;
      Bitmap.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), ImageName));
    finally
      Bitmap.Free;
      Dialog.Hide;
    end;
  end;

  procedure AddTestValue(const Name, Kind, Text, Path: string);
  var
    Value: TNamedStyleValue;
    Row: Integer;
  begin
    Value := TNamedStyleValue.Create;
    Value.Name := Name;
    Value.Kind := Kind;
    Value.Value := Text;
    ValidateNamedValue(Value);
    FValues.Add(Value);
    UpdateValueReferences;
    FValueReference.ItemIndex := FValueReference.Items.IndexOf(Name);
    BuildProperties;
    Row := -1;
    for var I := 0 to FEntries.Count - 1 do
      if FEntries[I].Path = Path then
        Row := I;
    Check(Row >= 0, 'binding property visible: ' + Path);
    FProperties.SelectPath(Path);
    FValueReference.ItemIndex := FValueReference.Items.IndexOf(Name);
    BindSelectedProperty;
  end;

begin
  TraceFile := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-trace.txt');
  TFile.WriteAllText(TraceFile, '', TEncoding.UTF8);
  ToolsTabs.ActiveTab := InspectorTab;
  var InspectorReport := TStringList.Create;
  try
    RunPropertyInspectorTests(InspectorReport);
    RunWinUIDialogTests(Self, InspectorReport);
    RunGradientDialogTests(Self, InspectorReport);
    for var Message in InspectorReport do
      Check(True, Message);
  finally
    InspectorReport.Free;
  end;

  Check(FClasses.ContainsKey('TButton'), 'button registered');
  Check(FClasses.ContainsKey('TColorAnimation'), 'color animation registered');
  Check(FClasses.ContainsKey('TGlowEffect'), 'effect registered');
  Check(FClasses.ContainsKey('TStyleObject'), 'bitmap style object registered');
  AddObject('TLayout');
  FSelected.StyleName := 'buttonstyle';
  AddObject('TRectangle');
  SetTestProperty('Width', '215.5');
  Check(Abs(TRectangle(FSelected).Width - 215.5) < 0.01, 'floating property conversion');
  SetTestProperty('Fill.Color', '#FF247AC4');
  var CollectionEditor := TCollectionDialog.CreateEditor(Self, TRectangle(FSelected).Fill.Gradient.Points, 'Fill.Gradient.Points');
  try
    Check((CollectionEditor.FList <> nil) and (CollectionEditor.Inspector.FindProperty('Color') <> nil), 'collection dialog loaded from FMX');
    Check(Assigned(CollectionEditor.AddButton.OnClick), 'collection action loaded from FMX');
    Check(CollectionEditor.StyleBook = StyleBook, 'collection inherits WinUI StyleBook');
    CollectionEditor.Inspector.WriteProperty('Offset', '0.125');
    Check(Abs(TRectangle(FSelected).Fill.Gradient.Points[0].Offset - 0.125) < 0.001, 'collection inspector writes typed values');
    CollectionEditor.Inspector.WriteProperty('Offset', '0');
    CaptureDialog(CollectionEditor, 'selftest-collection.png');
    Check(CollectionEditor.Inspector.FindProperty('Color').Editor.Width > 120, 'collection inspector aligns columns after resize');
  finally
    CollectionEditor.Free;
    BuildProperties;
  end;
  var BeforeGradientTest := Snapshot;
  var GradientHistory := FUndo.Count;
  var GradientSource := TRectangle(FSelected).Fill.Gradient;
  var GradientDraft := TGradientEditorForm.CreateEditor(Self, GradientSource);
  try
    Check(FProperties.FindProperty('Fill.Gradient').Kind = iekGradient, 'main inspector offers the gradient wizard');
    GradientDraft.AngleDial.Value := -45;
    GradientDraft.AddPoint(0.5).Color := $7F3399FF;
    Check(SameSnapshot(BeforeGradientTest, Snapshot) and (FUndo.Count = GradientHistory),
      'gradient draft does not modify the document or undo history');
    ApplyGradient(GradientSource, GradientDraft.Value, TRectangle(FSelected).Fill, 'Fill.Gradient');
    Check((FUndo.Count = GradientHistory + 1) and
      (TRectangle(FSelected).Fill.Kind = TBrushKind.Gradient) and
      (TRectangle(FSelected).Fill.Gradient.Points.Count = 3), 'gradient is applied as one undo operation');
    var AppliedGradient := Snapshot;
    Check(not ApplyGradient(TRectangle(FSelected).Fill.Gradient, GradientDraft.Value,
        TRectangle(FSelected).Fill, 'Fill.Gradient') and (FUndo.Count = GradientHistory + 1),
      'applying an unchanged gradient creates no history entry');
    Undo(False);
    Check(SameSnapshot(BeforeGradientTest, Snapshot), 'undo restores the original gradient and solid brush');
    Undo(True);
    Check(SameSnapshot(AppliedGradient, Snapshot), 'redo restores gradient points, direction and brush kind');
    Undo(False);
    FRedo.Clear;
    SelectObject(FRoot.Children[0].Children[0]);
  finally
    GradientDraft.Free;
  end;
  FSelected.Name := 'SBD_GradientBindingTest';
  var GradientColorValue := TNamedStyleValue.Create;
  GradientColorValue.Name := 'GradientStopTest';
  GradientColorValue.Kind := 'Цвет';
  GradientColorValue.Value := '#FF003355';
  FValues.Add(GradientColorValue);
  var GradientBinding := TStyleValueBinding.Create;
  GradientBinding.TargetName := FSelected.Name;
  GradientBinding.PropertyPath := 'Fill.Gradient.Points[0].Color';
  GradientBinding.ResourceName := GradientColorValue.Name;
  FBindings.Add(GradientBinding);
  ApplyBindings;
  Changed;
  var BoundGradientState := Snapshot;
  GradientDraft := TGradientEditorForm.CreateEditor(Self, TRectangle(FSelected).Fill.Gradient);
  try
    GradientDraft.AngleDial.Value := 30;
    ApplyGradient(TRectangle(FSelected).Fill.Gradient, GradientDraft.Value,
      TRectangle(FSelected).Fill, 'Fill.Gradient');
    Check((FBindings.Count = 1) and
      (FProperties.FindProperty('Fill.Gradient.Points[0].Color').BindingName = 'GradientStopTest'),
      'changing only gradient direction preserves color value bindings');
    Undo(False);
    Check(SameSnapshot(BoundGradientState, Snapshot), 'undo restores a bound gradient');
    SelectObject(FRoot.Children[0].Children[0]);
  finally
    GradientDraft.Free;
  end;
  GradientDraft := TGradientEditorForm.CreateEditor(Self, TRectangle(FSelected).Fill.Gradient);
  try
    GradientDraft.AddPoint(0.25).Color := $803399FF;
    ApplyGradient(TRectangle(FSelected).Fill.Gradient, GradientDraft.Value,
      TRectangle(FSelected).Fill, 'Fill.Gradient');
    Check(FBindings.Count = 0, 'changing color stops detaches index-based bindings');
    Undo(False);
    Check(SameSnapshot(BoundGradientState, Snapshot) and (FBindings.Count = 1),
      'undo restores color stop bindings together with the gradient');
    Undo(True);
    Check((FBindings.Count = 0) and (FUndo.Count = GradientHistory + 1),
      'redo restores the gradient and binding changes as one operation');
    Undo(False);
    Restore(BeforeGradientTest);
    FRedo.Clear;
    SelectObject(FRoot.Children[0].Children[0]);
  finally
    GradientDraft.Free;
  end;
  var TextEditor := TTextEditorForm.Create(Self);
  try
    Check((TextEditor.TextMemo <> nil) and (TextEditor.ApplyButton.ModalResult = mrOk), 'text dialog loaded from FMX');
    TextEditor.TextMemo.Lines.Text := StringOfChar('x', 160) + sLineBreak + 'second line';
    var OriginalText := TextEditor.TextMemo.Lines.Text;
    Check(not TextEditor.TextMemo.WordWrap, 'text editor starts without wrapping');
    TextEditor.WordWrapCheck.IsChecked := True;
    Check(TextEditor.TextMemo.WordWrap and (TextEditor.TextMemo.Lines.Text = OriginalText),
      'word wrap preserves text and logical line breaks');
    TextEditor.WordWrapCheck.IsChecked := False;
    Check(not TextEditor.TextMemo.WordWrap and (TextEditor.TextMemo.Lines.Text = OriginalText),
      'disabling word wrap preserves text');
    CaptureDialog(TextEditor, 'selftest-text.png');
  finally
    TextEditor.Free;
  end;
  var ColorEditor := TColorEditorForm.Create(Self);
  try
    Check((ColorEditor.ColorPanel <> nil) and ColorEditor.ColorPanel.UseAlpha, 'color dialog loaded from FMX');
    CaptureDialog(ColorEditor, 'selftest-color.png');
  finally
    ColorEditor.Free;
  end;
  Check(TRectangle(FSelected).Fill.Color = $FF247AC4, 'color property conversion');
  for var Entry in FEntries do
    Check((Entry.Path <> 'Name') and (Entry.Path <> 'Tag') and
      (Entry.Path <> 'TagFloat') and (Entry.Path <> 'TagString'), 'visual service property hidden: ' + Entry.Path);
  Check(FProperties.FindProperty('Name') = nil, 'custom inspector hides visual Name');
  Check(FProperties.FindProperty('Tag') = nil, 'custom inspector hides visual Tag');
  Check(FProperties.FindProperty('Fill.Color').Kind = iekColor, 'main inspector uses color editor');
  var InlineUndoCount := FUndo.Count;
  var InlineItem := FTree.Selected;
  var InlineEditor := FProperties.FindProperty('Width').Editor;
  var InlineCopy := FDesignRoot;
  FProperties.WriteProperty('Width', '216.5');
  DeferredRefresh(nil);
  Check((FTree.Selected = InlineItem) and (FProperties.FindProperty('Width').Editor = InlineEditor) and
    (FDesignRoot = InlineCopy), 'property edit reuses tree, inspector and design controls');
  Check((Abs(TRectangle(FSelected).Width - 216.5) < 0.001) and
    (FUndo.Count = InlineUndoCount + 1), 'inline inspector edit records history');
  Undo(False);
  Resource := FRoot.Children[0];
  SelectObject(Resource.Children[0]);
  Check(Abs(TRectangle(FSelected).Width - 215.5) < 0.001, 'inline edit undo restores property');
  AddTestValue('Accent', 'Цвет', '#FF247AC4', 'Fill.Color');
  AddTestValue('OutlineWidth', 'Число', '1.5', 'Stroke.Thickness');
  AddTestValue('PointerInput', 'Логическое', 'False', 'HitTest');
  Check(FProperties.FindProperty('Fill.Color').BindingName = 'Accent', 'binding badge in custom inspector');
  FProperties.WriteProperty('Fill.Color', '#FF102030');
  Check(TRectangle(FSelected).Fill.Color = $FF102030, 'inline edit changes a bound property');
  var AccentDetached := True;
  for var Binding in FBindings do
    if Binding.PropertyPath = 'Fill.Color' then
      AccentDetached := False;
  Check(AccentDetached, 'inline edit detaches resource binding');
  Undo(False);
  Resource := FRoot.Children[0];
  SelectObject(Resource.Children[0]);
  Check(FProperties.FindProperty('Fill.Color').BindingName = 'Accent', 'inline undo restores binding');

  TRectangle(FSelected).Align := TAlignLayout.Contents;
  TRectangle(FSelected).Fill.Color := $FF247AC4;
  SelectObject(Resource);
  AddObject('TText');
  AddTestValue('CaptionText', 'Текст', 'Кнопка', 'Text');
  TText(FSelected).Align := TAlignLayout.Client;
  SelectObject(Resource);
  AddObject('TFloatAnimation');
  TFloatAnimation(FSelected).PropertyName := 'Opacity';
  SetTestProperty('Trigger', 'IsMouseOver=true');
  Remember;
  FindValue('Accent').Value := '#FFCC4422';
  ApplyBindings;
  Changed;
  Check(TRectangle(Resource.Children[0]).Fill.Color = $FFCC4422, 'named color propagates');
  Undo(False);
  Resource := FRoot.Children[0];
  Check(TRectangle(Resource.Children[0]).Fill.Color = $FF247AC4, 'undo restores named color');
  Check(FindValue('Accent').Value = '#FF247AC4', 'undo restores catalog');
  SelectObject(Resource.Children[2]);
  State := Snapshot;
  DuplicateObject;
  Check(Resource.ChildrenCount = 4, 'duplicate animation');
  Undo(False);
  Check(FRoot.Children[0].ChildrenCount = 3, 'undo duplicate');
  Undo(True);
  Check(FRoot.Children[0].ChildrenCount = 4, 'redo duplicate');
  Restore(State);
  Check(FRoot.Children[0].StyleName = 'buttonstyle', 'resource name after restore');
  FileName := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest.style');
  FFileName := FileName;
  SaveDocument(False);
  LoadDocument(FileName);
  Check(FValues.Count = 4, 'named values persisted');
  Check(FBindings.Count = 4, 'property bindings persisted');
  Check(StyleResourceCount = 1, 'indexed resource count');
  Check(FRoot.Children[0].ChildrenCount = 3, 'indexed child count');
  SaveStyle(FileName, TStyleFormat.Text);
  LoadDocument(FileName);
  Check(FRoot.Children[0].ChildrenCount = 3, 'text style roundtrip');
  var StyleStream := TMemoryStream.Create;
  try
    WriteStyleStream(StyleStream, TStyleFormat.Binary);
    var Bytes: TBytes;
    SetLength(Bytes, StyleStream.Size);
    if Length(Bytes) > 0 then
      Move(StyleStream.Memory^, Bytes[0], Length(Bytes));
    Stream := TBytesStream.Create(Bytes);
  finally
    StyleStream.Free;
  end;
  Book := TStyleBook.Create(nil);
  try
    Book.LoadFromStream(Stream);
    Check(Book.Style.FindStyleResource('buttonstyle') <> nil, 'TStyleBook lookup');
  finally
    Book.Free;
    Stream.Free;
  end;
  SelectObject(FRoot.Children[0]);
  Show;
  ShowPreview;
  FPreviewClass.ItemIndex := FPreviewClass.Items.IndexOf('TEdit');
  Check((FPreviewHost.ChildrenCount = 1) and (FPreviewHost.Children[0] is TEdit) and
    (TPreviewForm(FPreview).Inspector.InspectedObject = FPreviewHost.Children[0]),
    'preview contains one interactive control and its inspector');
  FPreviewClass.ItemIndex := FPreviewClass.Items.IndexOf('TButton');
  for var I := 1 to 15 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  Check(FTree.Count = 1, 'tree resource count without root: ' + FTree.Count.ToString);
  Check(FTree.Items[0].TagObject = FRoot.Children[0], 'tree starts directly with resources');
  Check(FPalette.Count > 100, 'palette populated: ' + FPalette.Count.ToString);
  Check(FEntries.Count > 10, 'inspector populated: ' + FEntries.Count.ToString);
  Picture := TBitmap.Create(Round(FPreview.ClientWidth), Round(FPreview.ClientHeight));
  try
    Picture.Clear($FFF1F3F6);
    if Picture.Canvas.BeginScene then
    try
      FPreview.PaintTo(Picture.Canvas);
    finally
      Picture.Canvas.EndScene;
    end;
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-preview.png'));
  finally
    Picture.Free;
  end;
  Picture := FLayout.MakeScreenshot;
  try
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-editor.png'));
  finally
    Picture.Free;
  end;
  SelectObject(FRoot.Children[0].Children[0]);
  Check(FProperties.FindProperty('Fill.Color').BindingName = 'Accent', 'saved binding targets restored');
  FProperties.SelectPath('Fill.Color');
  for var I := 1 to 5 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  FProperties.Tree.RealignContent;
  FProperties.Tree.ViewportPosition := PointF(0, 240);
  var InspectorView := FProperties.Tree.ViewportPosition;
  Check(InspectorView.Y > 0, 'inspector has scrollable properties');
  FProperties.Refresh;
  Check(Abs(FProperties.Tree.ViewportPosition.Y - InspectorView.Y) < 1, 'inspector refresh preserves viewport');
  FProperties.SelectPath('Fill.Color');
  for var I := 1 to 5 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  Picture := FLayout.MakeScreenshot;
  try
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-inspector.png'));
  finally
    Picture.Free;
  end;
  SelectObject(FRoot.Children[0]);
  Check(((IsDark and (StyleBook = StyleBookWinUI3)) or
    (not IsDark and (StyleBook = StyleBookWinUI3Light))) and
    (ToolsTabs.ActiveTab = InspectorTab), 'WinUI shell follows selected theme and inspector tab');
  var PreviousAppTheme := ComboBoxTheme.ItemIndex;
  var BeforeAppTheme := Snapshot;
  var AppThemeHistory := FUndo.Count;
  try
    for var ThemeIndex := 0 to 2 do
    begin
      ComboBoxTheme.ItemIndex := ThemeIndex;
      SaveApplicationTheme;
      FBuilding := True;
      try
        ComboBoxTheme.ItemIndex := (ThemeIndex + 1) mod 3;
        LoadApplicationTheme;
      finally
        FBuilding := False;
      end;
      DoOnSettingChange;
      Check(ComboBoxTheme.ItemIndex = ThemeIndex, 'application theme survives preference reload ' + ThemeIndex.ToString);
      if ThemeIndex = 1 then
        Check(not IsDark and (StyleBook = StyleBookWinUI3Light) and
          (MainBackground.Fill.Color = $FFF3F3F3), 'explicit light theme uses light surfaces')
      else if ThemeIndex = 2 then
        Check(IsDark and (StyleBook = StyleBookWinUI3) and
          (MainBackground.Fill.Color = $FF202020), 'explicit dark theme uses dark surfaces');
      DoOnSettingChange;
      Check(ComboBoxTheme.ItemIndex = ThemeIndex, 'system appearance refresh retains explicit theme selection');
      if ThemeIndex > 0 then
      begin
        WorkspaceSettingsClick(WorkspaceSettingsButton);
        if ThemeIndex = 1 then
          CaptureDialog(Self, 'selftest-app-light.png')
        else
        begin
          CaptureDialog(Self, 'selftest-app-dark.png');
          var DarkDialogReport := TStringList.Create;
          try
            RunWinUIDialogTests(Self, DarkDialogReport, '-dark');
            RunGradientDialogTests(Self, DarkDialogReport, '-dark');
            for var Message in DarkDialogReport do
              Check(True, Message);
          finally
            DarkDialogReport.Free;
          end;
        end;
        WorkspaceSettingsClick(CloseWorkspaceSettings);
      end;
    end;
    TFile.WriteAllText(FPreferencesFile, '[Appearance]' + sLineBreak + 'Theme=invalid', TEncoding.UTF8);
    FBuilding := True;
    try
      LoadApplicationTheme;
    finally
      FBuilding := False;
    end;
    Check(ComboBoxTheme.ItemIndex = 0, 'invalid preference falls back to system theme');
    Check(SameSnapshot(BeforeAppTheme, Snapshot) and (FUndo.Count = AppThemeHistory),
      'application theme does not change the document or history');
  finally
    ComboBoxTheme.ItemIndex := PreviousAppTheme;
    DoOnSettingChange;
    TFile.Delete(FPreferencesFile);
  end;
  Show;
  Application.ProcessMessages;
  Check((NewButton.Tag = acNew) and Assigned(NewButton.OnClick) and
    (DuplicateButton.Tag = acDuplicate) and Assigned(DuplicateButton.OnClick), 'menu commands retain actions');
  ToolsTabs.ActiveTab := PaletteTab;
  FSearch.Text := 'TButton';
  FilterPalette(nil);
  Check(FPalette.Items.IndexOf('TButton') >= 0, 'palette search on component tab');
  for var I := 1 to 10 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  Picture := FLayout.MakeScreenshot;
  try
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-palette.png'));
  finally
    Picture.Free;
  end;
  FSearch.Text := '';
  FilterPalette(nil);
  ToolsTabs.ActiveTab := InspectorTab;
  for var I := 1 to 10 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  var FullSize := PointF(Width, Height);
  Width := Round(Constraints.MinWidth);
  Height := Round(Constraints.MinHeight);
  Application.ProcessMessages;
  Check((FZoom.Width >= 100) and (FCanvas.Width > 280) and (FProperties.Width > 250), 'minimum window layout remains usable');
  Check((FZoom.Position.Y >= ResourceThemeBox.Position.Y + ResourceThemeBox.Height) or
    (ResourceThemeBox.Position.X + ResourceThemeBox.Width <= FZoom.Position.X),
    'workspace theme and zoom selectors do not overlap at minimum size');
  Picture := FLayout.MakeScreenshot;
  try
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-compact.png'));
  finally
    Picture.Free;
  end;
  Width := Round(FullSize.X);
  Height := Round(FullSize.Y);
  Application.ProcessMessages;
  var BeforeViewChange := Snapshot;
  for var Mode := 1 to 2 do
  begin
    FBackgroundMode.ItemIndex := Mode;
    Application.ProcessMessages;
    Picture := FLayout.MakeScreenshot;
    try
      var ImageName := 'selftest-editor-dark.png';
      if Mode = 2 then
        ImageName := 'selftest-editor-transparent.png';
      Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), ImageName));
    finally
      Picture.Free;
    end;
    if Mode = 1 then
      CaptureDialog(FPreview, 'selftest-preview-dark.png')
    else
      CaptureDialog(FPreview, 'selftest-preview-transparent.png');
  end;
  FZoom.ItemIndex := 3;
  Check(FZoomPercent = 200, 'zoom preset updates workspace');
  Check(FindComponent('FZoomTrack') = nil, 'zoom trackbar removed from form');
  FZoom.ItemIndex := FZoom.Items.IndexOf('2000%');
  Check((FZoomPercent = 2000) and
    (Abs(TControlAccess(FDesignRoot).Scale.X - 20) < 0.001), '2000 percent zoom');
  SetWorkspaceZoom(777);
  Check((FZoom.Items[FZoom.ItemIndex] = '777%') and
    (Abs(TControlAccess(FDesignRoot).Scale.X - 7.77) < 0.001), 'intermediate zoom updates menu and design scale');
  RefreshDesign;
  Check(Abs(TControlAccess(FDesignRoot).Scale.X - 7.77) < 0.001, 'custom zoom preserved after design refresh');
  FZoom.ItemIndex := FZoom.Items.IndexOf('500%');
  Check(FZoomPercent = 500, 'zoom remains synchronized after custom value');
  FZoom.ItemIndex := 3;
  var Center := FSurface.AbsoluteToLocal(TControl(FDesignRoot).LocalToAbsolute(
      PointF(TControl(FDesignRoot).Width / 2, TControl(FDesignRoot).Height / 2)));
  Check(Abs(Center.X - FCanvas.LocalRect.CenterPoint.X) < 2, 'zoomed resource centered horizontally');
  Check(Abs(Center.Y - FCanvas.LocalRect.CenterPoint.Y) < 2, 'zoomed resource centered vertically');
  var PreviousWidth := Width;
  Width := Width + 160;
  Application.ProcessMessages;
  Center := FSurface.AbsoluteToLocal(TControl(FDesignRoot).LocalToAbsolute(
      PointF(TControl(FDesignRoot).Width / 2, TControl(FDesignRoot).Height / 2)));
  Check(Abs(Center.X - FCanvas.LocalRect.CenterPoint.X) < 2, 'resource centered after window resize');
  Width := PreviousWidth;
  Application.ProcessMessages;
  var PanSelection := FSelected;
  var HistoryBeforePan := FUndo.Count;
  DesignDown(FSurface, TMouseButton.mbMiddle, [ssMiddle], 50, 50);
  DesignMove(FSurface, [ssMiddle], 1250, -850);
  Check(FPanning and (Abs(FPanOffset.X - 1200) < 0.01) and
    (Abs(FPanOffset.Y + 900) < 0.01), 'middle mouse pans beyond viewport in both directions');
  DesignMove(FSurface, [ssMiddle], -1450, 2050);
  DesignUp(FSurface, TMouseButton.mbMiddle, [], -1450, 2050);
  Check(not FPanning and (Abs(FPanOffset.X + 1500) < 0.01) and
    (Abs(FPanOffset.Y - 2000) < 0.01), 'pan is unrestricted and releases capture');
  Check((FSelected = PanSelection) and (FUndo.Count = HistoryBeforePan), 'pan preserves selection and history');
  RefreshDesign;
  Check((Abs(FPanOffset.X + 1500) < 0.01) and
    (Abs(FPanOffset.Y - 2000) < 0.01), 'pan survives design refresh');
  FPanOffset := PointF(75, -35);
  CenterDesign;
  var ZoomAnchor := PointF(FCanvas.Width * 0.3, FCanvas.Height * 0.4);
  var AnchorInResource := TControl(FDesignRoot).AbsoluteToLocal(FCanvas.LocalToAbsolute(ZoomAnchor));
  var WheelZoomBefore := FZoomPercent;
  WorkspaceZoomAt(ZoomAnchor, 60);
  Check(FZoomPercent = WheelZoomBefore, 'partial wheel delta is accumulated');
  WorkspaceZoomAt(ZoomAnchor, 60);
  Check(FZoomPercent > WheelZoomBefore, 'mouse wheel zooms in');
  var AnchorAfterZoom := FCanvas.AbsoluteToLocal(TControl(FDesignRoot).LocalToAbsolute(AnchorInResource));
  Check((Abs(AnchorAfterZoom.X - ZoomAnchor.X) < 0.1) and
    (Abs(AnchorAfterZoom.Y - ZoomAnchor.Y) < 0.1), 'wheel zoom preserves point under cursor');
  WorkspaceZoomAt(ZoomAnchor, -120);
  Check(FZoomPercent < Round(WheelZoomBefore * 1.1), 'mouse wheel zooms out');
  SetWorkspaceZoom(MaxWorkspaceZoom);
  WorkspaceZoomAt(ZoomAnchor, 120);
  Check(FZoomPercent = MaxWorkspaceZoom, 'wheel respects maximum zoom');
  SetWorkspaceZoom(MinWorkspaceZoom);
  WorkspaceZoomAt(ZoomAnchor, -120);
  Check(FZoomPercent = MinWorkspaceZoom, 'wheel respects minimum zoom');
  DesignDown(FSurface, TMouseButton.mbMiddle, [ssMiddle], 50, 50);
  WorkspaceDeactivate(nil);
  Check(not FPanning, 'pan ends when window deactivates');
  FPanOffset := TPointF.Zero;
  CenterDesign;
  FZoom.ItemIndex := 1;
  FBackgroundMode.ItemIndex := 0;
  var AfterViewChange := Snapshot;
  Check((Length(BeforeViewChange) = Length(AfterViewChange)) and
    CompareMem(@BeforeViewChange[0], @AfterViewChange[0], Length(BeforeViewChange)), 'workspace settings preserve style data');
  ValuesDialog := TNamedValuesDialog.CreateEditor(Self);
  try
    ValuesDialog.Show;
    for var I := 1 to 8 do
    begin
      Application.ProcessMessages;
      Sleep(20);
    end;
    Picture := TBitmap.Create(Round(ValuesDialog.ClientWidth), Round(ValuesDialog.ClientHeight));
    try
      Picture.Clear($FFF1F3F6);
      if Picture.Canvas.BeginScene then
      try
        ValuesDialog.PaintTo(Picture.Canvas);
      finally
        Picture.Canvas.EndScene;
      end;
      Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-resources.png'));
    finally
      Picture.Free;
    end;
  finally
    ValuesDialog.Free;
  end;
  var BeforeDraftRoot := FRoot;
  var BeforeDraftItem := FTree.Selected;
  var BeforeDraftCopy := FDesignRoot;
  var BeforeDraftInspector := FProperties.FindProperty('Width').Editor;
  var BeforeDraftUndo := FUndo.Count;
  var BeforeDraftMetadata := MetadataJSON;
  TThread.ForceQueue(nil,
    procedure
    begin
      for var I := 0 to Screen.FormCount - 1 do
        if Screen.Forms[I] is TNamedValuesDialog then
        begin
          var Dialog := TNamedValuesDialog(Screen.Forms[I]);
          Dialog.EditValue(Dialog, 0, 0, TValue.From<string>('DraftAccent'));
          Dialog.ResourceAction(Dialog.AddButton);
          Dialog.ModalResult := mrCancel;
        end;
    end);
  EditNamedValues;
  Check((FRoot = BeforeDraftRoot) and (FTree.Selected = BeforeDraftItem) and
    (FDesignRoot = BeforeDraftCopy) and (FProperties.FindProperty('Width').Editor = BeforeDraftInspector) and
    (FUndo.Count = BeforeDraftUndo) and (MetadataJSON = BeforeDraftMetadata), 'cancel changed resources draft preserves document and all controls');
  TThread.ForceQueue(nil,
    procedure
    begin
      for var I := 0 to Screen.FormCount - 1 do
        if Screen.Forms[I] is TNamedValuesDialog then
          Screen.Forms[I].ModalResult := mrOk;
    end);
  EditNamedValues;
  Check((FRoot = BeforeDraftRoot) and (FTree.Selected = BeforeDraftItem) and
    (FUndo.Count = BeforeDraftUndo) and (FDesignRoot = BeforeDraftCopy), 'apply unchanged resources avoids document updates');
  TThread.ForceQueue(nil,
    procedure
    begin
      for var I := 0 to Screen.FormCount - 1 do
        if Screen.Forms[I] is TNamedValuesDialog then
        begin
          var Dialog := TNamedValuesDialog(Screen.Forms[I]);
          Dialog.EditValue(Dialog, 0, 0, TValue.From<string>('RenamedAccent'));
          Dialog.EditValue(Dialog, 2, 0, TValue.From<string>('#FFAB1234'));
          Dialog.ModalResult := mrOk;
        end;
    end);
  EditNamedValues;
  Check((FindValue('RenamedAccent') <> nil) and (FindValue('Accent') = nil) and
    (FBindings[0].ResourceName = 'RenamedAccent') and
    (TRectangle(FRoot.Children[0].Children[0]).Fill.Color = $FFAB1234), 'apply resource draft commits rename and propagates value');
  Check((FTree.Selected = BeforeDraftItem) and (FRoot = BeforeDraftRoot) and
    (FUndo.Count = BeforeDraftUndo + 1), 'resource apply retains tree and creates one undo operation');
  Undo(False);
  Check((FindValue('Accent') <> nil) and (FindValue('RenamedAccent') = nil), 'undo resource draft restores names and bindings');
  var BeforeInvalidLoad := Snapshot;
  var InvalidFile := FileName + '.invalid.style';
  SaveStyle(InvalidFile, TStyleFormat.Indexed);
  var InvalidRoot := FRoot.Clone(nil);
  try
    for var Child in ChildrenOf(InvalidRoot) do
      if SameText(Child.StyleName, '#designer') then
        Child.Children[0].TagString := '{invalid json';
    var InvalidStream := TFileStream.Create(InvalidFile, fmCreate);
    try
      TStyleStreaming.SaveToStream(InvalidRoot, InvalidStream, TStyleFormat.Indexed);
    finally
      InvalidStream.Free;
    end;
  finally
    InvalidRoot.Free;
  end;
  var Rejected := False;
  try
    LoadDocument(InvalidFile);
  except
    on E: Exception do
      Rejected := True;
  end;
  Check(Rejected, 'invalid embedded project JSON rejected');
  var AfterInvalidLoad := Snapshot;
  Check((Length(BeforeInvalidLoad) = Length(AfterInvalidLoad)) and
    CompareMem(@BeforeInvalidLoad[0], @AfterInvalidLoad[0], Length(BeforeInvalidLoad)), 'failed load preserves document');
  TFile.Delete(InvalidFile);
  if TFile.Exists(InvalidFile + '.resources.json') then
    TFile.Delete(InvalidFile + '.resources.json');
  SelectObject(FRoot.Children[0]);
  AddObject('TStyleTag');
  var TagsVisible := 0;
  for var Entry in FEntries do
    if (Entry.Path = 'Tag') or (Entry.Path = 'TagFloat') or (Entry.Path = 'TagString') then
      Inc(TagsVisible);
  Check(TagsVisible = 3, 'TStyleTag tag properties available: ' + TagsVisible.ToString + ' on ' + FSelected.ClassName);
  SetTestProperty('Tag', '17');
  SetTestProperty('TagFloat', '2.5');
  SetTestProperty('TagString', 'Style metadata');
  Check(FSelected.Tag = 17, 'style tag integer');
  Check(Abs(FSelected.TagFloat - 2.5) < 0.001, 'style tag float');
  Check(FSelected.TagString = 'Style metadata', 'style tag string');
  Check((FProperties.FindProperty('Tag') <> nil) and (FProperties.FindProperty('TagFloat') <> nil) and
    (FProperties.FindProperty('TagString') <> nil), 'custom inspector exposes TStyleTag fields');
  FPreview.Hide;
  FDirty := False;
  ImportDefault;
  Check(FRoot.ChildrenCount > 50, 'system style unpacked: ' + FRoot.ChildrenCount.ToString);
  SaveStyle(FileName, TStyleFormat.Indexed);
  var ResourceCount := FRoot.ChildrenCount;
  LoadDocument(FileName);
  Check(FRoot.ChildrenCount = ResourceCount, 'full system style roundtrip');
  SelectObject(FRoot.Children[100]);
  FTree.Items[1].IsExpanded := True;
  FTree.RealignContent;
  FTree.ViewportPosition := PointF(0, 440);
  var TreeViewport := FTree.ViewportPosition;
  Check(TreeViewport.Y > 0, 'tree regression has scrollable content');
  DuplicateObject;
  for var I := 1 to 5 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  Check(Abs(FTree.ViewportPosition.Y - TreeViewport.Y) < 1, 'tree viewport preserved after duplicate: ' + TreeViewport.Y.ToString + ' -> ' + FTree.ViewportPosition.Y.ToString + ' wanted=' + FTreeRestoreViewport.Y.ToString + ' pending=' + BoolToStr(FTreeViewportRestorePending, True));
  Check(FTree.Items[1].IsExpanded, 'tree expanded branches preserved');
  Undo(False);
  for var I := 1 to 5 do
  begin
    Application.ProcessMessages;
    Sleep(20);
  end;
  Check(Abs(FTree.ViewportPosition.Y - TreeViewport.Y) < 1, 'tree viewport preserved after undo');
  Check(FTree.Items[1].IsExpanded, 'tree expanded branches preserved after undo');
  // Virtual groups never change FMX parentage or resource lookup.
  NewDocument;
  FSelected := FRoot;
  AddObject('TLayout');
  SetTestProperty('StyleName', 'gridstyle');
  var GridResource := FSelected;
  FSelected := FRoot;
  AddObject('TRectangle');
  SetTestProperty('StyleName', 'textcellstyle');
  var CellResource := FSelected;
  AddTestValue('GridAccent', 'Цвет', '#FF247AC4', 'Fill.Color');
  var GridGroup := CreateStyleGroup('Grid / TStringGrid', '');
  var GridGroupID := GridGroup.ID;
  var CellsGroup := CreateStyleGroup('Ячейки', GridGroup.ID);
  var CellsGroupID := CellsGroup.ID;
  AssignToGroup(GridResource, nil, GridGroupID);
  DeferredRefresh(nil);
  AssignToGroup(CellResource, nil, CellsGroupID);
  DeferredRefresh(nil);
  Check((GridResource.Parent = FRoot) and (CellResource.Parent = FRoot), 'grouping preserves top-level style resources');
  Check((FTree.Count = 1) and (FTree.Items[0].TagObject = GridGroup), 'rootless tree displays group');
  Check(not CanAssignGroup(nil, GridGroup, CellsGroupID), 'cyclic group move rejected');
  Check(DesignerLayout(False) <> nil, 'designer metadata layout created automatically');
  Check((DesignerLayout(False).Children[0] is TStyleTag) and
    (DesignerLayout(False).Index = FRoot.ChildrenCount - 1), 'designer JSON uses TStyleTag at end of book');
  for var Item in TreeItems(FTree) do
    Check((Item.TagObject <> FRoot) and (Item.TagObject <> DesignerLayout(False)), 'root and metadata hidden in tree');
  SelectObject(GridResource);
  var DragSource := FTree.Selected;
  var DragTarget: TTreeViewItem := nil;
  for var Item in TreeItems(FTree) do
    if Item.TagObject = CellsGroup then
      DragTarget := Item;
  var AllowDrop := True;
  TreeDragChange(DragSource, DragTarget, AllowDrop);
  DeferredRefresh(nil);
  Check(not AllowDrop and (GroupOf(GridResource) = CellsGroupID) and
    (GridResource.Parent = FRoot), 'drag groups styles without FMX reparenting');
  AssignToGroup(GridResource, nil, GridGroupID);
  DeferredRefresh(nil);
  FSelected := nil;
  FSelectedGroup := GridGroup;
  GroupAction(acDelete);
  Check((FGroups.Count = 1) and (FindGroup(CellsGroupID).ParentID = '') and
    (StyleResourceCount = 2), 'delete group preserves styles and releases nested groups');
  Undo(False);
  Check((FGroups.Count = 2) and (FindGroup(CellsGroupID).ParentID = GridGroupID), 'undo restores nested groups');
  Undo(True);
  Check((FGroups.Count = 1) and (StyleResourceCount = 2), 'redo group deletion');
  Undo(False);
  CellResource := FRoot.Children[1];
  SelectObject(CellResource);
  DuplicateObject;
  Check(GroupOf(FSelected) = CellsGroupID, 'duplicate resource remains in group');
  MoveObject(acUp);
  Check(FSelected.Index = 1, 'resource reorders among siblings of same group');
  var OutdentedResource := FSelected;
  MoveObject(acOutdent);
  DeferredRefresh(nil);
  Check((GroupOf(OutdentedResource) = GridGroupID) and (OutdentedResource.Parent = FRoot), 'outdent resource moves to parent group');
  SelectObject(OutdentedResource);
  GroupAction(acUngroup);
  DeferredRefresh(nil);
  Check(GroupOf(OutdentedResource).IsEmpty, 'ungroup resource keeps it in stylebook');
  Undo(False);
  Undo(False);
  Undo(False);
  Undo(False);
  CellResource := FRoot.Children[1];
  SelectObject(CellResource);
  FProperties.WriteProperty('StyleName', 'textcellstyle2');
  Check(FTree.Selected.TagString.Contains('textcellstyle2'), 'renamed resource updates persistent tree key without rebuilding');
  FProperties.WriteProperty('StyleName', 'textcellstyle');
  DeferredRefresh(nil);
  SetWorkspaceZoom(1733);
  FPanOffset := PointF(1234, -5678);
  FBackgroundMode.ItemIndex := 2;
  FProperties.SelectPath('Fill.Color');
  CenterDesign;
  var GroupFile := FileName + '.groups.style';
  if TFile.Exists(GroupFile + '.resources.json') then
    TFile.Delete(GroupFile + '.resources.json');
  SaveStyle(GroupFile, TStyleFormat.Indexed);
  Check(not TFile.Exists(GroupFile + '.resources.json'), 'project saved inside one style file');
  TFile.WriteAllText(GroupFile + '.resources.json', '{stale companion', TEncoding.UTF8);
  LoadDocument(GroupFile);
  TFile.Delete(GroupFile + '.resources.json');
  Check((FGroups.Count = 2) and (FindGroup(CellsGroupID).ParentID = GridGroupID) and
    (FindGroup(CellsGroupID).Title = 'Ячейки'), 'embedded nested groups roundtrip and override stale companion');
  Check((FValues.Count = 1) and (FBindings.Count = 1) and
    (FProperties.FindProperty('Fill.Color').BindingName = 'GridAccent'), 'embedded resources and bindings roundtrip');
  Check((FZoomPercent = 1733) and (FBackgroundMode.ItemIndex = 2) and
    (Abs(FPanOffset.X - 1234) < 0.01) and (Abs(FPanOffset.Y + 5678) < 0.01), 'embedded workspace parameters roundtrip');
  Check((GroupOf(FRoot.Children[0]) = GridGroupID) and
    (GroupOf(FRoot.Children[1]) = CellsGroupID), 'resource group memberships roundtrip');
  var GroupBook := TStyleBook.Create(nil);
  try
    GroupBook.LoadFromFile(GroupFile);
    Check((GroupBook.Style.FindStyleResource('gridstyle') <> nil) and
      (GroupBook.Style.FindStyleResource('textcellstyle') <> nil), 'ordinary TStyleBook resolves grouped resources');
    var EmbeddedLayout := GroupBook.Style.FindStyleResource('#designer');
    Check((EmbeddedLayout is TLayout) and (EmbeddedLayout.Children[0] is TStyleTag) and
      TStyleTag(EmbeddedLayout.Children[0]).TagString.Contains('GridAccent'), 'ordinary stylebook retains embedded JSON');
  finally
    GroupBook.Free;
  end;
  SelectObject(FRoot.Children[1]);
  FPanOffset := TPointF.Zero;
  SetWorkspaceZoom(100);
  CenterDesign;
  SaveStyle(GroupFile, TStyleFormat.Text);
  LoadDocument(GroupFile);
  Check((FGroups.Count = 2) and (FBindings.Count = 1), 'text style embedded metadata roundtrip');
  FindValue('GridAccent').Value := '#FFCC4422';
  ApplyBindings;
  Changed;
  Check(TRectangle(FRoot.Children[1]).Fill.Color = $FFCC4422, 'embedded binding applies after reload');
  Application.ProcessMessages;
  var GroupPicture := TBitmap.Create(Round(Width), Round(Height));
  try
    if GroupPicture.Canvas.BeginScene then
    begin
      PaintTo(GroupPicture.Canvas);
      GroupPicture.Canvas.EndScene;
    end;
    GroupPicture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-groups.png'));
  finally
    GroupPicture.Free;
  end;
  // Migrate the previous v1 companion format on the next save.
  var LegacyMetadata := TJSONObject.ParseJSONValue(MetadataJSON) as TJSONObject;
  try
    LegacyMetadata.RemovePair('version').Free;
    LegacyMetadata.AddPair('version', TJSONNumber.Create(1));
    LegacyMetadata.RemovePair('theme').Free;
    for var Item in LegacyMetadata.GetValue<TJSONArray>('values') do
    begin
      TJSONObject(Item).AddPair('value', Item.GetValue<string>('light'));
      TJSONObject(Item).RemovePair('light').Free;
      TJSONObject(Item).RemovePair('dark').Free;
    end;
    LegacyMetadata.RemovePair('groups').Free;
    LegacyMetadata.RemovePair('assignments').Free;
    var LegacyRoot := FRoot.Clone(nil);
    try
      for var Child in ChildrenOf(LegacyRoot) do
        if SameText(Child.StyleName, '#designer') then
          Child.Free;
      var LegacyStream := TFileStream.Create(GroupFile, fmCreate);
      try
        TStyleStreaming.SaveToStream(LegacyRoot, LegacyStream, TStyleFormat.Indexed);
      finally
        LegacyStream.Free;
      end;
    finally
      LegacyRoot.Free;
    end;
    TFile.WriteAllText(GroupFile + '.resources.json', LegacyMetadata.ToJSON, TEncoding.UTF8);
  finally
    LegacyMetadata.Free;
  end;
  LoadDocument(GroupFile);
  Check((FGroups.Count = 0) and (FBindings.Count = 1) and
    (FValues.Count = 1), 'legacy companion imported');
  SaveStyle(GroupFile, TStyleFormat.Indexed);
  TFile.Delete(GroupFile + '.resources.json');
  LoadDocument(GroupFile);
  Check((FBindings.Count = 1) and (FValues.Count = 1), 'legacy metadata migrated into book');
  TFile.Delete(GroupFile);
  NewDocument;
  AddObject('TLayout');
  var FirstStyle := FSelected;
  FirstStyle.StyleName := 'firststyle';
  AddObject('TRectangle');
  var Moving := TRectangle(FSelected);
  Moving.Name := 'BoundMoving';
  var AccentValue := TNamedStyleValue.Create;
  AccentValue.Name := 'MoveAccent';
  AccentValue.Kind := 'Цвет';
  AccentValue.Value := '#FF219DEB';
  FValues.Add(AccentValue);
  var MovingBinding := TStyleValueBinding.Create;
  MovingBinding.TargetName := Moving.Name;
  MovingBinding.PropertyPath := 'Fill.Color';
  MovingBinding.ResourceName := AccentValue.Name;
  FBindings.Add(MovingBinding);
  SelectObject(FRoot);
  AddObject('TLayout');
  var SecondStyle := FSelected;
  SecondStyle.StyleName := 'secondstyle';
  RebuildTree;
  var MovingRow := FTreeItems[Pointer(Moving)];
  var DropAllowed := True;
  Check(CanDrop(MovingRow, FTreeItems[Pointer(SecondStyle)]), 'drop between styles allowed');
  TreeDragChange(MovingRow, FTreeItems[Pointer(SecondStyle)], DropAllowed);
  DeferredRefresh(nil);
  Check(not DropAllowed and (Moving.Parent = SecondStyle) and (FTreeItems[Pointer(Moving)] = MovingRow),
    'drop changes model parent and reuses tree row');
  Check((FBindings.Count = 1) and (FindNamedObject(MovingBinding.TargetName) = Moving), 'drop retains resource binding');
  Check(not CanDrop(FTreeItems[Pointer(SecondStyle)], MovingRow), 'drop rejects ancestor cycle');
  SelectObject(Moving);
  AddObject('TText');
  var NestedText := FSelected;
  TreeDragChange(FTreeItems[Pointer(NestedText)], FTreeItems[Pointer(FirstStyle)], DropAllowed);
  DeferredRefresh(nil);
  Check(NestedText.Parent = FirstStyle, 'nested object can move into another style');
  SelectObject(Moving);
  AddObject('TFloatAnimation');
  var AnimationObject := FSelected;
  Check(not CanDrop(FTreeItems[Pointer(AnimationObject)], nil), 'nonvisual object cannot become root resource');
  SelectObject(Moving);
  AddObject('TText');
  var FrontText := FSelected;
  SelectObject(AnimationObject);
  MoveObject(acFront);
  Check(AnimationObject.Index = AnimationObject.Parent.ChildrenCount - 1, 'BringToFront works for nonvisual objects');
  MoveObject(acBack);
  Check(AnimationObject.Index = 0, 'SendToBack works for nonvisual objects');
  SelectObject(FrontText);
  MoveObject(acBack);
  Check(FrontText.Index = 0, 'SendToBack works for visual objects');
  MoveObject(acFront);
  Check(FrontText.Index = FrontText.Parent.ChildrenCount - 1, 'BringToFront works for visual objects');
  SelectObject(Moving);
  var Display := FDesignRoot;
  SelectObject(FrontText);
  Check(FDesignRoot = Display, 'selection inside style preserves display clone');
  SelectObject(Moving);
  Check((FTree.ScrollAnimation = TBehaviorBoolean.True) and (FPalette.ScrollAnimation = TBehaviorBoolean.True) and
    (FProperties.Tree.ScrollAnimation = TBehaviorBoolean.True) and (FZoom.ListBox.ScrollAnimation = TBehaviorBoolean.True),
    'smooth scrolling enabled in tree palette inspector and dropdown');
  Check((ComponentIcon(TButton) <> ComponentIcon(TRectangle)) and (ComponentIcon(TRectangle) <> ComponentIcon(TCircle)) and
    (ComponentIcon(TFloatAnimation) = ComponentIcon(TColorAnimation)) and (FTree.Selected.ImageIndex >= 0),
    'basic icons distinct and specialized classes share family icons');
  SetWorkspaceZoom(100);
  ShowFrame.IsChecked := False;
  Check(not FRootOutline.Visible, 'overlay hides root frame');
  ShowFrame.IsChecked := True;
  ShowDimensions.IsChecked := False;
  Check(not FSizeBox.Visible and not FRootSizeBox.Visible, 'overlay hides dimension badges');
  ShowDimensions.IsChecked := True;
  CenterViewClick(nil);
  Check((FPanOffset = TPointF.Zero) and FRootOutline.Visible and FSizeBox.Visible and FRootSizeBox.Visible,
    'overlay centers view and displays root and selection dimensions');
  Moving.Align := TAlignLayout.None;
  Moving.SetBounds(23, 17, 117, 63);
  TControl(FrontText).SetBounds(12, 10, 40, 20);
  RefreshDesign(True);
  ShowGuides.IsChecked := True;
  Check(GuidePixels = 0, 'guides absent outside gesture');
  var MoveCopy := FResizeCopy;
  Show;
  Application.ProcessMessages;
  var HoverCopy := TControl(FindDesignObject(FDesignRoot, FrontText));
  var HoverSelection := FSelected;
  var HoverHistory := FUndo.Count;
  var HoverState := Snapshot;
  for var HoverZoom in [100, 175] do
  begin
    SetWorkspaceZoom(HoverZoom);
    var HoverPoint := HoverCopy.LocalToAbsolute(HoverCopy.LocalRect.CenterPoint);
    var HoverHit := HitDesignObject(HoverPoint);
    UpdateDesignHover(HoverPoint);
    Check((HoverHit = HoverCopy) and FHoverOutline.Visible and
      (FHoverOutline.Position.Point.Distance(FSurface.AbsoluteToLocal(HoverCopy.LocalToAbsolute(TPointF.Zero))) < 0.1) and
      (Abs(FHoverOutline.Width - HoverCopy.Width * HoverZoom / 100) < 0.1),
      'hover outline follows frontmost nested element at zoom ' + HoverZoom.ToString);
    Check(not FHoverOutline.HitTest and (FHoverOutline.Stroke.Color shr 24 = $80) and
      (HitDesignObject(HoverPoint) = HoverCopy), 'translucent hover outline does not intercept click');
  end;
  Check((FSelected = HoverSelection) and (FUndo.Count = HoverHistory) and SameSnapshot(HoverState, Snapshot),
    'hover preserves selection, document and history');
  SetWorkspaceZoom(100);
  var HoverPoint := HoverCopy.LocalToAbsolute(HoverCopy.LocalRect.CenterPoint);
  UpdateDesignHover(HoverPoint);
  Picture := TBitmap.Create(Ceil(ClientWidth), Ceil(ClientHeight));
  try
    if Picture.Canvas.BeginScene then
    try
      PaintTo(Picture.Canvas);
    finally
      Picture.Canvas.EndScene;
    end;
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-hover.png'));
  finally
    Picture.Free;
  end;
  DesignDown(HoverCopy, TMouseButton.mbRight, [], HoverCopy.Width / 2, HoverCopy.Height / 2);
  Check((FSelected = FrontText) and not FHoverOutline.Visible, 'click selects hovered element and clears hover outline');
  SelectObject(Moving);
  MoveCopy := FResizeCopy;
  UpdateDesignHover(HoverPoint);
  MouseLeave;
  Check(not FHoverOutline.Visible, 'hover outline clears on mouse leave');
  UpdateDesignHover(HoverPoint);
  DesignDown(FSurface, TMouseButton.mbMiddle, [ssMiddle], 20, 20);
  UpdateDesignHover(HoverPoint);
  Check(not FHoverOutline.Visible, 'hover outline remains hidden while panning');
  DesignUp(FSurface, TMouseButton.mbMiddle, [], 20, 20);
  UpdateDesignHover(HoverPoint);
  WorkspaceDeactivate(nil);
  Check(not FHoverOutline.Visible, 'hover outline clears on deactivation');
  DesignDown(MoveCopy, TMouseButton.mbLeft, [], 5, 5);
  Check(GuidePixels > 200, 'guides render at gesture start without alignment');
  DesignMove(MoveCopy, [ssLeft], 19, 18);
  Check(GuidePixels > 200, 'guides render between alignments during movement');
  Picture := TBitmap.Create(Ceil(ClientWidth), Ceil(ClientHeight));
  try
    Picture.Clear($FF202020);
    if Picture.Canvas.BeginScene then
    try
      PaintTo(Picture.Canvas);
    finally
      Picture.Canvas.EndScene;
    end;
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-guides.png'));
  finally
    Picture.Free;
  end;
  ShowGuides.IsChecked := False;
  Check(GuidePixels = 0, 'overlay disables guides during gesture');
  ShowGuides.IsChecked := True;
  DesignUp(MoveCopy, TMouseButton.mbLeft, [], 5, 5);
  Check(GuidePixels = 0, 'guides clear after movement');
  Moving.SetBounds(0, 0, 120, 60);
  RefreshDesign(True);
  DesignDown(FResizeCopy, TMouseButton.mbLeft, [], 5, 5);
  Check(GuidePixels(True) > 100, 'aligned guides use highlighted color');
  DesignUp(FDragObject, TMouseButton.mbLeft, [], 5, 5);
  SelectObject(SecondStyle);
  for var TestZoom in [50, 175, 2000] do
  begin
    SetWorkspaceZoom(TestZoom);
    FPanOffset := PointF(15, -10);
    CenterDesign;
    DesignDown(FResizeNW, TMouseButton.mbLeft, [], 4.5, 4.5);
    Check(GuidePixels > 200, 'root resize guides at zoom ' + TestZoom.ToString);
    DesignUp(FResizeNW, TMouseButton.mbLeft, [], 4.5, 4.5);
    Check(GuidePixels = 0, 'root guides clear at zoom ' + TestZoom.ToString);
  end;
  SetWorkspaceZoom(100);
  CenterViewClick(nil);
  SelectObject(Moving);
  var ResizeHandles: array[0..3] of TRectangle;
  ResizeHandles[0] := FResizeNW;
  ResizeHandles[1] := FResizeNE;
  ResizeHandles[2] := FResizeSW;
  ResizeHandles[3] := FResizeHandle;
  for var Corner := 0 to 3 do
  begin
    Moving.Align := TAlignLayout.None;
    Moving.SetBounds(10, 10, 120, 60);
    RefreshDesign(True);
    var Handle := ResizeHandles[Corner];
    var HistoryCount := FUndo.Count;
    DesignDown(Handle, TMouseButton.mbLeft, [], 4.5, 4.5);
    Check(GuidePixels > 200, 'guides render for every resize corner');
    Check((Length(FDragSnapshot) = 0) and (FUndo.Count = HistoryCount), 'resize click defers snapshot');
    DesignMove(Handle, [ssLeft], 16.5, 12.5);
    var ExpectedWidth: Single := 132;
    var ExpectedHeight: Single := 68;
    if Corner in [0, 2] then
      ExpectedWidth := 108;
    if Corner in [0, 1] then
      ExpectedHeight := 52;
    Check(SameValue(Moving.Width, ExpectedWidth, 0.01) and SameValue(Moving.Height, ExpectedHeight, 0.01),
      'corner resize updates dimensions ' + Corner.ToString);
    DesignUp(Handle, TMouseButton.mbLeft, [], 4.5, 4.5);
    Check(FUndo.Count = HistoryCount + 1, 'resize stores one history entry');
  end;
  Moving.RotationAngle := 30;
  Moving.Scale.Point := PointF(1.5, 1.25);
  Moving.SetBounds(10, 10, 120, 60);
  RefreshDesign(True);
  var OppositeAnchor := FResizeCopy.LocalToAbsolute(PointF(0, 0));
  var ResizeMouse := FResizeHandle.LocalToAbsolute(PointF(4.5, 4.5));
  var WorldDelta := PointF(12, 8) * FResizeCopy.AbsoluteMatrix - TPointF.Zero * FResizeCopy.AbsoluteMatrix;
  DesignDown(FResizeHandle, TMouseButton.mbLeft, [], 4.5, 4.5);
  var HandlePoint := FResizeHandle.AbsoluteToLocal(ResizeMouse + WorldDelta);
  DesignMove(FResizeHandle, [ssLeft], HandlePoint.X, HandlePoint.Y);
  DesignUp(FResizeHandle, TMouseButton.mbLeft, [], 4.5, 4.5);
  Check(SameValue(Moving.Width, 132, 0.01) and SameValue(Moving.Height, 68, 0.01) and
    (FResizeCopy.LocalToAbsolute(PointF(0, 0)).Distance(OppositeAnchor) < 0.1),
    'rotated scaled resize preserves opposite corner');
  Moving.RotationAngle := 0;
  Moving.Scale.Point := PointF(1, 1);
  Moving.Align := TAlignLayout.Client;
  RefreshDesign(True);
  Check(FResizeNW.Visible and FResizeNE.Visible and FResizeSW.Visible and FResizeHandle.Visible,
    'all corners available for aligned controls');
  DesignDown(FResizeHandle, TMouseButton.mbLeft, [], 4.5, 4.5);
  DesignMove(FResizeHandle, [ssLeft], 16.5, 12.5);
  DesignUp(FResizeHandle, TMouseButton.mbLeft, [], 4.5, 4.5);
  Check(Moving.Align = TAlignLayout.None, 'aligned resize switches to explicit geometry');
  Undo(False);
  Moving := TRectangle(FindNamedObject('BoundMoving'));
  Check((Moving <> nil) and (Moving.Align = TAlignLayout.Client), 'undo restores alignment and binding target');
  SelectObject(Moving);
  ShowFrame.IsChecked := False;
  ShowGuides.IsChecked := False;
  ShowDimensions.IsChecked := False;
  SaveStyle(GroupFile, TStyleFormat.Indexed);
  LoadDocument(GroupFile);
  Check(not ShowFrame.IsChecked and not ShowGuides.IsChecked and not ShowDimensions.IsChecked,
    'overlay settings persist in designer metadata');
  ShowFrame.IsChecked := True;
  ShowGuides.IsChecked := True;
  ShowDimensions.IsChecked := True;
  SelectObject(FindNamedObject('BoundMoving'));
  Snapshot;
  TFile.Delete(GroupFile);
  Moving := TRectangle(FSelected);
  Moving.Align := TAlignLayout.None;
  Moving.SetBounds(30, 25, 90, 40);
  var Container := TControl(Moving.Parent);
  Container.Width := 210;
  Container.Height := 110;
  RefreshDesign(True);
  var GroupForDrop := CreateStyleGroup('Composite', '');
  var PromotionID := GroupForDrop.ID;
  Moving.StyleName := 'firststyle';
  RebuildTree;
  TreeDragChange(FTreeItems[Pointer(Moving)], FTreeItems[Pointer(GroupForDrop)], DropAllowed);
  DeferredRefresh(nil);
  Check((Moving.Parent = FRoot) and (GroupOf(Moving) = PromotionID) and (Moving.StyleName <> 'firststyle'),
    'nested visual drop into group promotes unique style resource');
  Undo(False);
  Moving := TRectangle(FindNamedObject('BoundMoving'));
  Check((Moving <> nil) and (Moving.Parent <> FRoot) and (FBindings.Count = 1), 'undo promotion restores hierarchy and binding');
  SelectObject(Moving);
  ClearHistory;
  WorkspaceSettingsClick(WorkspaceSettingsButton);
  Check(CanvasOverlay.Visible and (ShowFrame.Width > 200) and (CenterView.Height >= 32),
    'workspace settings opens with full-width options and standard button height');
  CaptureDialog(Self, 'selftest-workspace-tools.png');
  var EscapeKey: Word := vkEscape;
  var EscapeChar: WideChar := #0;
  FormKeys(Self, EscapeKey, EscapeChar, []);
  Check(not CanvasOverlay.Visible and (EscapeKey = 0), 'Escape dismisses workspace settings');
  WorkspaceSettingsClick(WorkspaceSettingsButton);
  DesignDown(FCanvas, TMouseButton.mbLeft, [], 0, 0);
  Check(not CanvasOverlay.Visible, 'clicking the workspace dismisses view settings');
  Show;
  WorkspaceSettingsClick(WorkspaceSettingsButton);
  FPropertySearch.SetFocus;
  Check(not CanvasOverlay.Visible, 'moving keyboard focus outside dismisses view settings');
  NewDocument;
  AddObject('TImage');
  var LinkAtlas := TImage(FSelected);
  LinkAtlas.StyleName := 'atlas.bmp';
  LinkAtlas.Bitmap.SetSize(96, 96);
  LinkAtlas.Bitmap.Clear($FFEEEEEE);
  Check(LinkAtlas.Bitmap.Canvas.BeginScene, 'bitmap links atlas canvas available');
  try
    LinkAtlas.Bitmap.Canvas.Fill.Color := $FF0078D4;
    LinkAtlas.Bitmap.Canvas.FillRect(RectF(8, 8, 88, 88), 0, 0, AllCorners, 1);
    LinkAtlas.Bitmap.Canvas.Fill.Color := $FFFFFFFF;
    LinkAtlas.Bitmap.Canvas.FillRect(RectF(16, 16, 80, 80), 0, 0, AllCorners, 1);
  finally
    LinkAtlas.Bitmap.Canvas.EndScene;
  end;
  var LinkAtlas2 := LinkAtlas.MultiResBitmap.Add;
  LinkAtlas2.Scale := 2;
  LinkAtlas2.Bitmap.Assign(LinkAtlas.Bitmap);
  LinkAtlas2.Bitmap.Resize(192, 192);
  SelectObject(FRoot);
  AddObject('TTintedButtonStyleObject');
  var BitmapStyle := TButtonStyleObject(FSelected);
  BitmapStyle.Name := 'BitmapLinkSubject';
  BitmapStyle.StyleName := 'bitmaplinkstyle';
  BitmapStyle.SourceLookup := LinkAtlas.StyleName;
  var AtlasLink := TBitmapLink(BitmapStyle.NormalLink.Add);
  AtlasLink.SourceRect.Rect := RectF(8, 8, 88, 88);
  AtlasLink.CapInsets.Rect := RectF(8, 8, 8, 8);
  BitmapStyle.HotLink.Assign(BitmapStyle.NormalLink);
  var NestedAtlas := TImage.Create(nil);
  NestedAtlas.StyleName := 'nested.bmp';
  NestedAtlas.Parent := BitmapStyle;
  SetModelDesigning(FRoot);
  Changed;
  ClearHistory;
  var LinkBackground := TBrush.Create(TBrushKind.Solid, $FFFFFFFF);
  ConfigureWorkspaceBackground(LinkBackground);
  var LinksDialog := TBitmapLinksEditorForm.CreateEditor(Self, BitmapStyle, FRoot,
    BitmapStyle.NormalLink, 'NormalLink', LinkBackground);
  try
    Check((LinksDialog.ImagesList.Count = 1) and (LinksDialog.ImagesList.Items[0] = 'atlas.bmp') and
      (LinksDialog.SourceLookupEdit.Items.IndexOf('atlas.bmp') >= 0) and
      (LinksDialog.SourceLookupEdit.Items.IndexOf('nested.bmp') < 0), 'bitmap links images and combo list only root TImage');
    Check((LinksDialog.LinksList.Items.IndexOf('NormalLink') >= 0) and
      (LinksDialog.LinksList.Items.IndexOf('HotLink') >= 0) and
      (LinksDialog.LinksList.Items.IndexOf('NormalTint.Mask') >= 0), 'bitmap links collects state and nested tint links');
    Check((LinksDialog.CurrentLink.SourceRect.Rect = AtlasLink.SourceRect.Rect) and
      (LinksDialog.ZoomPercent = 100) and (LinksDialog.PanOffset = TPointF.Zero) and
      (LinksDialog.ViewBackground.Fill.Kind = LinkBackground.Kind), 'bitmap links loads draft and workspace defaults');
    Check(not ApplyBitmapLinks(LinksDialog) and (FUndo.Count = 0), 'unchanged bitmap links dialog creates no undo');
    var LinkAnchor := PointF(LinksDialog.View.Width * 0.3, LinksDialog.View.Height * 0.4);
    var LinkAnchorPixel := LinksDialog.ViewToImage(LinkAnchor);
    LinksDialog.ZoomAt(LinkAnchor, 60);
    Check(LinksDialog.ZoomPercent = 100, 'bitmap links wheel accumulates partial delta');
    LinksDialog.ZoomAt(LinkAnchor, 60);
    Check((LinksDialog.ZoomPercent = 110) and (LinksDialog.ImageToView(LinkAnchorPixel).Distance(LinkAnchor) < 0.1),
      'bitmap links wheel zoom preserves pixel under cursor');
    LinksDialog.ViewDown(LinksDialog.View, TMouseButton.mbMiddle, [ssMiddle], 20, 20);
    LinksDialog.ViewMove(LinksDialog.View, [ssMiddle], 1220, -880);
    LinksDialog.ViewUp(LinksDialog.View, TMouseButton.mbMiddle, [], 1220, -880);
    Check((LinksDialog.PanOffset.X > 1100) and (LinksDialog.PanOffset.Y < -800), 'bitmap links middle mouse pans beyond viewport');
    LinksDialog.CenterClick(nil);
    LinksDialog.ZoomCombo.ItemIndex := LinksDialog.ZoomCombo.Items.IndexOf('400%');
    var LinkDragStart := LinksDialog.ImageToView(PointF(16, 48));
    LinksDialog.ViewDown(LinksDialog.View, TMouseButton.mbLeft, [ssLeft], LinkDragStart.X, LinkDragStart.Y);
    LinksDialog.ViewMove(LinksDialog.View, [ssLeft], LinkDragStart.X + 5.2, LinkDragStart.Y);
    LinksDialog.ViewUp(LinksDialog.View, TMouseButton.mbLeft, [], LinkDragStart.X + 5.2, LinkDragStart.Y);
    Check((LinksDialog.CurrentLink.CapInsets.Left = 9) and (AtlasLink.CapInsets.Left = 8),
      'bitmap links cap drag snaps to one source pixel and leaves original untouched');
    LinkDragStart := LinksDialog.ImageToView(PointF(88, 88));
    LinksDialog.ViewDown(LinksDialog.View, TMouseButton.mbLeft, [ssLeft], LinkDragStart.X, LinkDragStart.Y);
    LinksDialog.ViewMove(LinksDialog.View, [ssLeft], LinkDragStart.X + 9.2, LinkDragStart.Y + 5.2);
    LinksDialog.ViewUp(LinksDialog.View, TMouseButton.mbLeft, [], LinkDragStart.X + 9.2, LinkDragStart.Y + 5.2);
    Check((LinksDialog.CurrentLink.SourceRect.Right = 90) and (LinksDialog.CurrentLink.SourceRect.Bottom = 89),
      'bitmap links outer drag snaps to one source pixel');
    LinksDialog.ResolutionAction(LinksDialog.AddResolutionButton);
    Check((LinksDialog.CurrentLink.Scale = 2) and (LinksDialog.CurrentDraft.Value.Count = 2) and
      (LinksDialog.CurrentLink.SourceRect.Right = 180), 'bitmap links adds matching image scale and scales coordinates');
    var LinkError: string;
    LinksDialog.CurrentLink.Scale := 1;
    Check(not LinksDialog.Validate(LinkError), 'bitmap links rejects duplicate resolution scales');
    LinksDialog.CurrentLink.Scale := 2;
    LinksDialog.SetCapInsets(RectF(200, 200, 200, 200));
    Check((LinksDialog.CurrentLink.CapInsets.Left + LinksDialog.CurrentLink.CapInsets.Right <= LinksDialog.CurrentLink.SourceRect.Rect.Width) and
      (LinksDialog.CurrentLink.CapInsets.Top + LinksDialog.CurrentLink.CapInsets.Bottom <= LinksDialog.CurrentLink.SourceRect.Rect.Height),
      'bitmap links constrains crossing cap insets');
    LinksDialog.ResolutionAction(LinksDialog.DeleteResolutionButton);
    Check(LinksDialog.CurrentDraft.Value.Count = 1, 'bitmap links deletes resolution in draft');
    LinksDialog.ResolutionAction(LinksDialog.AddResolutionButton);
    LinksDialog.ResolutionsList.ItemIndex := 0;
    LinksDialog.LinksList.ItemIndex := LinksDialog.LinksList.Items.IndexOf('HotLink');
    LinksDialog.SetSourceRect(RectF(10, 10, 86, 86));
    LinksDialog.LinksList.ItemIndex := LinksDialog.LinksList.Items.IndexOf('NormalLink');
    Check((LinksDialog.CurrentLink.SourceRect.Right = 90) and
      (BitmapStyle.HotLink.Links[0].SourceRect.Left = 8), 'bitmap links switching states preserves independent drafts');
    LinksDialog.SourceLookupEdit.Text := 'future-atlas.bmp';
    Check(LinksDialog.SourceLookupEdit.Text = 'future-atlas.bmp', 'bitmap links combo allows custom SourceLookup');
    LinksDialog.SourceLookupEdit.Text := 'atlas.bmp';
    LinksDialog.ZoomCombo.ItemIndex := LinksDialog.ZoomCombo.Items.IndexOf('400%');
    LinksDialog.CenterClick(nil);
    CaptureDialog(LinksDialog, 'selftest-bitmaplinks.png');
    Check((LinksDialog.ApplyButton.Position.X < LinksDialog.CancelButton.Position.X) and
      (LinksDialog.View.Width > 300) and (LinksDialog.ScaleEdit.Width > 200), 'bitmap links WinUI layout keeps actions and workspace usable');
    Check(ApplyBitmapLinks(LinksDialog) and (FUndo.Count = 1) and (BitmapStyle.NormalLink.Count = 2) and
      (BitmapStyle.NormalLink.Links[1].Scale = 2) and (BitmapStyle.NormalLink.Links[0].SourceRect.Right = 90) and
      (BitmapStyle.HotLink.Links[0].SourceRect.Left = 10), 'bitmap links applies all drafts as one undo operation');
  finally
    LinksDialog.Free;
    LinkBackground.Free;
  end;
  Undo(False);
  BitmapStyle := TButtonStyleObject(FindStyleRoot('bitmaplinkstyle'));
  Check((BitmapStyle.NormalLink.Count = 1) and (BitmapStyle.NormalLink.Links[0].SourceRect.Right = 88) and (BitmapStyle.HotLink.Links[0].SourceRect.Left = 8),
    'undo restores bitmap link geometry across states');
  Undo(True);
  BitmapStyle := TButtonStyleObject(FindStyleRoot('bitmaplinkstyle'));
  Check((BitmapStyle.NormalLink.Count = 2) and (BitmapStyle.NormalLink.Links[0].SourceRect.Right = 90) and (BitmapStyle.HotLink.Links[0].SourceRect.Left = 10),
    'redo restores bitmap link geometry across states');
  SelectObject(BitmapStyle);
  var CancelLinkState := Snapshot;
  var CancelLinkHistory := FUndo.Count;
  LinksDialog := TBitmapLinksEditorForm.CreateEditor(Self, BitmapStyle, FRoot, BitmapStyle.NormalLink, 'NormalLink', nil);
  LinksDialog.SetSourceRect(RectF(0, 0, 32, 32));
  LinksDialog.SourceLookupEdit.Text := 'unused.bmp';
  LinksDialog.Free;
  Check(SameSnapshot(CancelLinkState, Snapshot) and (FUndo.Count = CancelLinkHistory), 'bitmap links cancel preserves complete document and history');
  LinksDialog := TBitmapLinksEditorForm.CreateEditor(Self, BitmapStyle, FRoot, BitmapStyle.NormalLink, 'NormalLink', nil);
  try
    LinksDialog.SourceLookupEdit.Text := 'future-atlas.bmp';
    Check(ApplyBitmapLinks(LinksDialog) and (BitmapStyle.SourceLookup = 'future-atlas.bmp') and
      (FUndo.Count = CancelLinkHistory + 1), 'bitmap links commits custom SourceLookup as one undo');
  finally
    LinksDialog.Free;
  end;
  Undo(False);
  BitmapStyle := TButtonStyleObject(FindStyleRoot('bitmaplinkstyle'));
  Check((BitmapStyle.SourceLookup = 'atlas.bmp') and (BitmapStyle.NormalLink.Count = 2), 'bitmap links undo restores SourceLookup and preserves resolutions');
  NewDocument;
  AddObject('TLayout');
  var GlyphResource := FSelected;
  TControl(GlyphResource).SetBounds(0, 0, 160, 100);
  var EmptyGlyph := TGlyph.Create(nil);
  EmptyGlyph.StyleName := 'glyph';
  EmptyGlyph.SetBounds(40, 20, 64, 48);
  EmptyGlyph.Padding.Rect := RectF(8, 4, 12, 6);
  EmptyGlyph.Parent := GlyphResource;
  var GlyphFill := TFillRGBEffect.Create(nil);
  GlyphFill.StyleName := 'glyphfill';
  GlyphFill.Color := $FFFF0000;
  GlyphFill.Enabled := False;
  GlyphFill.Parent := EmptyGlyph;
  SetModelDesigning(GlyphResource);
  Changed;
  SelectObject(GlyphResource);
  Show;
  Application.ProcessMessages;
  var GlyphCopy := TGlyph(FindDesignObject(FDesignRoot, EmptyGlyph));
  Check((GlyphCopy <> nil) and GlyphCopy.Visible and GlyphCopy.HitTest and not GlyphCopy.AutoHide and
    not GlyphCopy.BitmapExists and Assigned(GlyphCopy.OnPaint) and (GlyphCopy.ChildrenCount = 1),
    'empty glyph has visible selectable workspace placeholder without extra children');
  var GlyphState := Snapshot;
  var GlyphHistory := FUndo.Count;
  var GlyphPoint := GlyphCopy.LocalToAbsolute(PointF(30, 23));
  UpdateDesignHover(GlyphPoint);
  Check(FHoverOutline.Visible and (Abs(FHoverOutline.Width - GlyphCopy.Width) < 0.1), 'empty glyph exposes hover outline');
  MouseMove([], GlyphPoint.X, GlyphPoint.Y);
  MouseDown(TMouseButton.mbLeft, [], GlyphPoint.X, GlyphPoint.Y);
  MouseUp(TMouseButton.mbLeft, [], GlyphPoint.X, GlyphPoint.Y);
  Check((FSelected = EmptyGlyph) and (FResizeCopy = GlyphCopy) and (FProperties.InspectedObject = EmptyGlyph),
    'native workspace click selects empty glyph and inspects model');
  Check(SameSnapshot(GlyphState, Snapshot) and (FUndo.Count = GlyphHistory) and
    EmptyGlyph.AutoHide and not EmptyGlyph.HitTest and (EmptyGlyph.Images = nil) and (EmptyGlyph.ImageIndex = -1),
    'glyph placeholder and selection preserve document properties and history');
  var GlyphPixels: TBitmapData;
  Picture := GlyphCopy.MakeScreenshot;
  try
    Check(Picture.Map(TMapAccess.Read, GlyphPixels), 'glyph placeholder bitmap readable');
    try
      var CirclePixel := TAlphaColorRec(GlyphPixels.GetPixel(30, 23));
      Check((CirclePixel.A > 220) and (Abs(Integer(CirclePixel.R) - $80) < 3) and
        (TAlphaColorRec(GlyphPixels.GetPixel(4, 4)).A = 0), 'glyph placeholder is padded circle on transparent background');
    finally
      Picture.Unmap(GlyphPixels);
    end;
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-glyph-circle.png'));
  finally
    Picture.Free;
  end;
  var GlyphFillCopy := TFillRGBEffect(FindDesignObject(FDesignRoot, GlyphFill));
  GlyphFillCopy.Enabled := True;
  Picture := GlyphCopy.MakeScreenshot;
  try
    Check(Picture.Map(TMapAccess.Read, GlyphPixels), 'glyph effect bitmap readable');
    try
      var EffectPixel := TAlphaColorRec(GlyphPixels.GetPixel(30, 23));
      Check((EffectPixel.A > 220) and (EffectPixel.R > 220) and (EffectPixel.G < 30) and (EffectPixel.B < 30) and
        (TAlphaColorRec(GlyphPixels.GetPixel(4, 4)).A = 0), 'glyph effects process placeholder and preserve circle alpha');
    finally
      Picture.Unmap(GlyphPixels);
    end;
    Picture.SaveToFile(System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-glyph-effect.png'));
  finally
    Picture.Free;
  end;
  FProperties.WriteProperty('AutoHide', 'False');
  FProperties.WriteProperty('Visible', 'False');
  FProperties.WriteProperty('HitTest', 'False');
  FProperties.WriteProperty('Enabled', 'False');
  GlyphCopy := TGlyph(FindDesignObject(FDesignRoot, EmptyGlyph));
  Check(not EmptyGlyph.AutoHide and not EmptyGlyph.Visible and not EmptyGlyph.HitTest and not EmptyGlyph.Enabled and
    GlyphCopy.Visible and GlyphCopy.HitTest and GlyphCopy.Enabled and not GlyphCopy.AutoHide,
    'glyph property edits preserve editor visibility and hit testing without overriding model');
  FProperties.WriteProperty('AutoHide', 'True');
  RefreshDesign(True);
  GlyphCopy := TGlyph(FindDesignObject(FDesignRoot, EmptyGlyph));
  SelectObject(GlyphResource);
  GlyphPoint := GlyphCopy.LocalToAbsolute(PointF(30, 23));
  MouseMove([], GlyphPoint.X, GlyphPoint.Y);
  MouseDown(TMouseButton.mbLeft, [], GlyphPoint.X, GlyphPoint.Y);
  MouseUp(TMouseButton.mbLeft, [], GlyphPoint.X, GlyphPoint.Y);
  Check((FSelected = EmptyGlyph) and EmptyGlyph.AutoHide and not EmptyGlyph.Enabled,
    'glyph remains selectable after rebuild with AutoHide and disabled model');
  NewDocument;
  AddObject('TLayout');
  FSelected.StyleName := 'textplaceholderstyle';
  var TextResource := FSelected;
  var EmptyStyleText := TText.Create(nil);
  EmptyStyleText.StyleName := 'emptytext';
  EmptyStyleText.Text := '';
  EmptyStyleText.Hint := '';
  EmptyStyleText.Parent := TextResource;
  var DefaultStyleText := TText.Create(nil);
  DefaultStyleText.StyleName := 'defaulttext';
  DefaultStyleText.Text := 'Text';
  DefaultStyleText.Parent := TextResource;
  var AuthoredStyleText := TText.Create(nil);
  AuthoredStyleText.StyleName := 'authoredtext';
  AuthoredStyleText.Text := 'Custom user text';
  AuthoredStyleText.Parent := TextResource;
  var LowerStyleText := TText.Create(nil);
  LowerStyleText.StyleName := 'lowertext';
  LowerStyleText.Text := 'text';
  LowerStyleText.Parent := TextResource;
  var SpaceStyleText := TText.Create(nil);
  SpaceStyleText.StyleName := 'spacetext';
  SpaceStyleText.Text := 'Text ';
  SpaceStyleText.Parent := TextResource;
  var TextTag := TStyleTag.Create(nil);
  TextTag.StyleName := 'texttag';
  TextTag.TagString := 'Text';
  TextTag.Parent := TextResource;
  var EditText := TEdit.Create(nil);
  EditText.StyleName := 'edittext';
  EditText.Text := '';
  EditText.TextPrompt := '';
  EditText.Parent := TextResource;
  var LiteralValue := TNamedStyleValue.Create;
  LiteralValue.Name := 'LiteralTextResource';
  LiteralValue.Kind := 'Текст';
  LiteralValue.Value := 'Text';
  FValues.Add(LiteralValue);
  SetModelDesigning(TextResource);
  FSelected := EmptyStyleText;
  Changed;
  var TextNode := FProperties.FindProperty('Text');
  Check((FProperties.ValueText(TextNode) = 'Text') and (TEdit(TextNode.Editor).Text = 'Text') and
    (TText(FResizeCopy).Text = 'Text') and EmptyStyleText.Text.IsEmpty, 'empty Text has editor-only placeholder');
  var TextUndoCount := FUndo.Count;
  TEdit(TextNode.Editor).OnExit(TextNode.Editor);
  Check(FUndo.Count = TextUndoCount, 'leaving default Text untouched creates no history');
  FProperties.WriteProperty('Text', 'Changed caption');
  DeferredRefresh(nil);
  Check((EmptyStyleText.Text = 'Changed caption') and (TText(FResizeCopy).Text = 'Changed caption'),
    'authored Text mirrors into workspace');
  Undo(False);
  TextResource := FRoot.Children[0];
  EmptyStyleText := TText(TextResource.FindStyleResource('emptytext'));
  SelectObject(EmptyStyleText);
  Check(EmptyStyleText.Text.IsEmpty and (TText(FResizeCopy).Text = 'Text'), 'undo restores empty Text with placeholder');
  FProperties.WriteProperty('Text', 'Changed caption');
  FProperties.WriteProperty('Text', '');
  DeferredRefresh(nil);
  Check(EmptyStyleText.Text.IsEmpty and (TText(FResizeCopy).Text = 'Text') and
    (FProperties.ValueText(FProperties.FindProperty('Text')) = 'Text'), 'clearing Text restores placeholder without rebuilding');
  SelectObject(TextResource.FindStyleResource('edittext'));
  Check((FProperties.ValueText(FProperties.FindProperty('Text')) = 'Text') and
    FProperties.ValueText(FProperties.FindProperty('TextPrompt')).IsEmpty and
    TEdit(FSelected).TextPrompt.IsEmpty, 'other text properties stay empty');
  TEdit(FSelected).TextPrompt := 'Text';
  RefreshDesign(True);
  var TextFile := FileName + '.placeholder.style';
  DefaultStyleText := TText(TextResource.FindStyleResource('defaulttext'));
  for var TextFormat in [TStyleFormat.Text, TStyleFormat.Binary, TStyleFormat.Indexed] do
  begin
    var BeforeTextSave := Snapshot;
    var BeforeTextHistory := FUndo.Count;
    var BeforeTextDisplay := FDesignRoot;
    SaveStyle(TextFile, TextFormat);
    var AfterTextSave := Snapshot;
    Check((Length(BeforeTextSave) = Length(AfterTextSave)) and
      CompareMem(@BeforeTextSave[0], @AfterTextSave[0], Length(BeforeTextSave)) and
      (FUndo.Count = BeforeTextHistory) and (FDesignRoot = BeforeTextDisplay) and (DefaultStyleText.Text = 'Text'),
      'save preserves editor values and history ' + Ord(TextFormat).ToString);
    var SavedTextRoot := TStyleStreaming.LoadFromFile(TextFile);
    try
      UnpackStyleBinaries(SavedTextRoot);
      var SavedResource := SavedTextRoot.FindStyleResource('textplaceholderstyle');
      Check(TText(SavedResource.FindStyleResource('emptytext')).Text.IsEmpty and
        TText(SavedResource.FindStyleResource('defaulttext')).Text.IsEmpty and
        TEdit(SavedResource.FindStyleResource('edittext')).Text.IsEmpty,
        'empty and default Text excluded from style file ' + Ord(TextFormat).ToString);
      Check((TText(SavedResource.FindStyleResource('authoredtext')).Text = 'Custom user text') and
        (TText(SavedResource.FindStyleResource('lowertext')).Text = 'text') and
        (TText(SavedResource.FindStyleResource('spacetext')).Text = 'Text ') and
        (TStyleTag(SavedResource.FindStyleResource('texttag')).TagString = 'Text') and
        (TEdit(SavedResource.FindStyleResource('edittext')).TextPrompt = 'Text'),
        'other text values survive style file ' + Ord(TextFormat).ToString);
      var Designer := SavedTextRoot.FindStyleResource('#designer');
      var TextJSON := TJSONObject.ParseJSONValue(Designer.FindStyleResource('project').TagString);
      try
        Check((TextJSON.GetValue<TJSONArray>('values').Items[0].GetValue<string>('light') = 'Text') and
          (TextJSON.GetValue<TJSONArray>('values').Items[0].GetValue<string>('dark') = 'Text'),
          'named text resources remain unchanged');
      finally
        TextJSON.Free;
      end;
    finally
      SavedTextRoot.Free;
    end;
  end;
  var RejectedStream := TRejectingStyleStream.Create;
  var RejectedWrite := False;
  try
    try
      WriteStyleStream(RejectedStream, TStyleFormat.Binary);
    except
      on E: EWriteError do
        RejectedWrite := True;
    end;
  finally
    RejectedStream.Free;
  end;
  Check(RejectedWrite and (DefaultStyleText.Text = 'Text'), 'failed serialization restores editor placeholder values');
  LoadDocument(TextFile);
  TextResource := FRoot.Children[0];
  SelectObject(TextResource.FindStyleResource('defaulttext'));
  Check((TText(FSelected).Text = '') and (TText(FResizeCopy).Text = 'Text') and
    (FProperties.ValueText(FProperties.FindProperty('Text')) = 'Text'), 'reopened style displays omitted Text placeholder');
  TFile.Delete(TextFile);
  NewDocument;
  AddObject('TMenuBar');
  AddObject('TMenuItem');
  var MenuRoot := TMenuItem(FSelected);
  MenuRoot.StyleName := 'menutest';
  var MenuContent := MenuRoot.Children[0];
  Check(not MenuContent.Stored and not FTreeItems.ContainsKey(Pointer(MenuContent)) and
    (FTreeItems[Pointer(MenuRoot)].Count = 0), 'empty menu internal Content hidden');
  SelectObject(MenuContent);
  Check((FSelected = MenuRoot) and (FProperties.InspectedObject = MenuRoot), 'internal object cannot be inspected');
  AddObject('TMenuItem');
  var MenuChild := TMenuItem(FSelected);
  MenuChild.StyleName := 'childmenu';
  Check((MenuChild.Parent = MenuContent) and (FTreeItems[Pointer(MenuChild)].ParentItem = FTreeItems[Pointer(MenuRoot)]),
    'real menu child visible directly under menu');
  var MenuRootCopy := EditableChildren(FDesignRoot)[0];
  Check((EditableChildren(MenuRootCopy)[0].TagObject = MenuChild) and
    (MenuRootCopy.Children[0].TagObject = nil) and not TControl(MenuRootCopy.Children[0]).HitTest,
    'workspace binds real menu child and excludes internal container');
  Check(not CanDrop(FTreeItems[Pointer(MenuChild)], FTreeItems[Pointer(MenuRoot)]), 'drop onto logical current parent is no-op');
  AddObject('TMenuItem');
  var MenuGrandchild := FSelected;
  MenuGrandchild.StyleName := 'grandchild';
  MoveObject(acOutdent);
  Check((EditableParent(MenuGrandchild) = MenuRoot) and
    (FTreeItems[Pointer(MenuGrandchild)].ParentItem = FTreeItems[Pointer(MenuRoot)]), 'outdent skips internal Content');
  DeleteObject;
  Check(FSelected = MenuRoot, 'deletion selects editable parent instead of Content');
  State := Snapshot;
  Restore(State);
  MenuRoot := TMenuItem(EditableChildren(FRoot.Children[0])[0]);
  MenuChild := TMenuItem(EditableChildren(MenuRoot)[0]);
  Check((MenuRoot.ChildrenCount = 1) and (MenuRoot.ItemsCount = 1) and
    (FTreeItems[Pointer(MenuRoot)].Count = 1) and
    not FTreeItems.ContainsKey(Pointer(MenuRoot.Children[0])), 'menu serialization restores one internal container and real child');
  SelectObject(MenuRoot);
  RebuildTree;
  Check(FTreeItems[Pointer(MenuChild)].ParentItem = FTreeItems[Pointer(MenuRoot)], 'reconciliation preserves logical menu hierarchy');
  NewDocument;
  AddObject('TVertScrollBox');
  var ScrollRoot := FSelected;
  AddObject('TRectangle');
  var ScrollChild := FSelected;
  Check((EditableParent(ScrollChild) = ScrollRoot) and
    (FTreeItems[Pointer(ScrollChild)].ParentItem = FTreeItems[Pointer(ScrollRoot)]), 'scroll content flattened without losing authored child');
  Check(EditableChildren(FDesignRoot)[0].TagObject = ScrollChild, 'scroll child workspace binding matches model');
  DeleteObject;
  Check(FSelected = ScrollRoot, 'scroll child deletion selects scroll box');

  NewDocument;
  AddObject('TLayout');
  var ClipboardResource := FSelected;
  ClipboardResource.StyleName := 'clipboardstyle';
  AddObject('TRectangle');
  var ClipboardRectangle := FSelected;
  ClipboardRectangle.StyleName := 'background';
  AddObject('TText');
  TText(FSelected).Text := 'Текст из Delphi: ''цитата''' + sLineBreak + '第二行';
  var ClipboardCaption := TText(FSelected).Text;
  SelectObject(ClipboardRectangle);
  var ElementText := ObjectText;
  Check(ElementText.StartsWith('object') and ElementText.Contains('TRectangle') and
    ElementText.Contains('TText') and not ElementText.Contains('SBDClipboard'), 'element uses native FMX object text');
  SelectObject(ClipboardResource);
  var BeforePasteUndo := FUndo.Count;
  PasteObjectText(ElementText + sLineBreak + ElementText);
  Check((ClipboardResource.ChildrenCount = 3) and (FUndo.Count = BeforePasteUndo + 1) and
    (TText(FSelected.Children[0]).Text = ClipboardCaption), 'multiple sibling FMX objects paste with Unicode, children and one undo');
  Undo(False);
  Check(FRoot.Children[0].ChildrenCount = 1, 'undo removes entire multi-object paste');
  Undo(True);
  Check(FRoot.Children[0].ChildrenCount = 3, 'redo restores entire multi-object paste');
  SelectObject(FRoot.Children[0]);
  var ResourceText := ObjectText;
  SelectObject(FRoot);
  PasteObjectText(ResourceText);
  Check((StyleResourceCount = 2) and (FSelected.StyleName <> 'clipboardstyle') and
    (FSelected.ChildrenCount = 3), 'root paste retains subtree and gives resource a unique StyleName');
  var ClipboardGroup := CreateStyleGroup('Вставленные стили', '');
  FSelectedGroup := ClipboardGroup;
  FSelected := nil;
  PasteObjectText(ResourceText);
  Check(GroupOf(FSelected) = ClipboardGroup.ID, 'paste into selected group assigns new root resource');
  var ClipboardModel := FRoot;
  var ClipboardUndo := FUndo.Count;
  var InvalidPasteRejected := False;
  try
    PasteObjectText(ElementText + sLineBreak + 'object Broken: TUnknownClipboardClass' + sLineBreak + 'end');
  except
    on E: Exception do
      InvalidPasteRejected := True;
  end;
  Check(InvalidPasteRejected and (FRoot = ClipboardModel) and (FUndo.Count = ClipboardUndo) and
    (FSelected.ChildrenCount = 3), 'invalid second pasted object leaves model and history intact');
  InvalidPasteRejected := False;
  SelectObject(FRoot);
  try
    PasteObjectText('object Animation: TFloatAnimation' + sLineBreak + 'end');
  except
    on E: Exception do
      InvalidPasteRejected := True;
  end;
  Check(InvalidPasteRejected and (FUndo.Count = ClipboardUndo), 'root paste rejects animation before changing history');

  var BeforeCopyDirty := FDirty;
  var BookText := StyleBookText;
  Check(BookText.StartsWith('object StyleBook1: TStyleBook') and BookText.Contains('Styles = <') and
    BookText.Contains('ResourcesBin = {'), 'whole book uses Delphi component text with embedded style binary');
  Check((FRoot = ClipboardModel) and (FUndo.Count = ClipboardUndo) and (FDirty = BeforeCopyDirty),
    'copy book preserves model, history and modified flag');
  var ComponentSource := TStringStream.Create(BookText, TEncoding.UTF8);
  var ComponentBinary := TMemoryStream.Create;
  Book := TStyleBook.Create(nil);
  try
    ObjectTextToBinary(ComponentSource, ComponentBinary);
    ComponentBinary.Position := 0;
    TComponentAccess(Book).SetDesigning(True, False);
    ComponentBinary.ReadComponent(Book);
    Check(Book.Style.FindStyleResource('clipboardstyle') <> nil, 'standard Delphi component reader accepts exported book');
  finally
    TComponentAccess(Book).SetDesigning(False, False);
    Book.Free;
    ComponentBinary.Free;
    ComponentSource.Free;
  end;
  var ImportedClipboardRoot := ReadStyleBookText(BookText);
  ReplaceDocument(ImportedClipboardRoot, '');
  Changed(False);
  Check((StyleResourceCount = 3) and (FGroups.Count = 1) and (FUndo.Count = 0) and
    FFileName.IsEmpty and FDirty, 'imported book restores embedded groups as an unsaved new document');
  ClipboardModel := FRoot;
  InvalidPasteRejected := False;
  try
    ImportedClipboardRoot := ReadStyleBookText(ElementText);
    ImportedClipboardRoot.Free;
  except
    on E: Exception do
      InvalidPasteRejected := True;
  end;
  Check(InvalidPasteRejected and (FRoot = ClipboardModel), 'book import rejects a different component without replacing document');
  var ClipboardActiveStyle := TStyleManager.ActiveStyle(Self);
  ImportedClipboardRoot := ReadStyleBookText(BookText.Replace('  Styles = <',
      '  FileName = ''missing-clipboard-style.style''' + sLineBreak + '  UseStyleManager = True' +
      sLineBreak + '  Styles = <'));
  try
    Check((ImportedClipboardRoot.FindStyleResource('clipboardstyle') <> nil) and
      (TStyleManager.ActiveStyle(Self) = ClipboardActiveStyle), 'book import uses embedded styles without applying FileName or UseStyleManager');
  finally
    ImportedClipboardRoot.Free;
  end;
  var LegacyStyleStream := TMemoryStream.Create;
  try
    WriteStyleStream(LegacyStyleStream, TStyleFormat.Indexed);
    var LegacyHex := TStringBuilder.Create;
    try
      for var I := 0 to Integer(LegacyStyleStream.Size) - 1 do
      begin
        if (I mod 32) = 0 then
          LegacyHex.Append(sLineBreak);
        LegacyHex.Append(IntToHex(PByte(LegacyStyleStream.Memory)[I], 2));
      end;
      ImportedClipboardRoot := ReadStyleBookText('object StyleBook1: TStyleBook' + sLineBreak +
        '  ResourcesBin = {' + LegacyHex.ToString + '}' + sLineBreak + 'end');
      try
        Check(ImportedClipboardRoot.FindStyleResource('clipboardstyle') <> nil, 'legacy root ResourcesBin clipboard format supported');
      finally
        ImportedClipboardRoot.Free;
      end;
    finally
      LegacyHex.Free;
    end;
  finally
    LegacyStyleStream.Free;
  end;

  var RollbackClipboardRoot := ReadStyleBookText(BookText);
  TStyleTag(RollbackClipboardRoot.FindStyleResource('#designer').FindStyleResource('project')).TagString := '{broken';
  InvalidPasteRejected := False;
  var RollbackClipboardUndo := FUndo.Count;
  try
    ReplaceDocument(RollbackClipboardRoot, '');
  except
    on E: Exception do
      InvalidPasteRejected := True;
  end;
  Check(InvalidPasteRejected and (FRoot = ClipboardModel) and (FUndo.Count = RollbackClipboardUndo) and
    (FGroups.Count = 1), 'invalid embedded clipboard metadata restores previous document and history');

  SelectObject(FRoot.Children[0].Children[0]);
  FTree.SetFocus;
  Check(ClipboardFocus, 'tree focus enables element clipboard shortcuts');
  ToolsTabs.ActiveTab := PaletteTab;
  FSearch.SetFocus;
  Check(not ClipboardFocus, 'text field focus preserves native clipboard shortcuts');
  FSurface.SetFocus;
  Check(ClipboardFocus and (FSurface.PopupMenu = ObjectMenu) and (FCanvas.PopupMenu = ObjectMenu) and
    (TControl(FDesignRoot).PopupMenu = ObjectMenu), 'workspace focus and context menus support element clipboard');
  var RightClickCopy := TControl(EditableChildren(FDesignRoot)[0]);
  FSelectedGroup := FGroups[0];
  DesignDown(RightClickCopy, TMouseButton.mbRight, [], 1, 1);
  Check((FSelected = RightClickCopy.TagObject) and (FSelectedGroup = nil) and not FDragging,
    'right click selects workspace object without dragging or stale group context');
  ObjectMenuOpening(nil);
  Check(CopyObjectButton.Enabled and PasteObjectButton.Enabled, 'workspace context menu enables copy and paste for selected control');

  var MenuPopup := TPopup.Create(nil);
  try
    MenuPopup.Parent := RightClickCopy;
    MenuPopup.UseParentScale := ObjectMenu.UseParentScale;
    TControlAccess(RightClickCopy).Scale.Point := PointF(2, 3);
    for var TestZoom in [50, 400, 2000] do
    begin
      SetWorkspaceZoom(TestZoom);
      Check((Abs(MenuPopup.AbsoluteScale.X - 1) < 0.001) and
        (Abs(MenuPopup.AbsoluteScale.Y - 1) < 0.001), 'context popup ignores object scale and workspace zoom ' + TestZoom.ToString);
    end;
  finally
    MenuPopup.Free;
  end;

  NewDocument;
  var ReferenceTarget := TLayout.Create(nil);
  ReferenceTarget.StyleName := 'referenceTarget';
  ReferenceTarget.Parent := FRoot;
  var ReferenceUser := TLayout.Create(nil);
  ReferenceUser.StyleName := 'referenceUser';
  ReferenceUser.Parent := FRoot;
  var ReferenceContainer := TLayout.Create(nil);
  ReferenceContainer.Parent := ReferenceUser;
  var ReferenceButton := TButton.Create(nil);
  ReferenceButton.StyleLookup := 'REFERENCETARGET';
  ReferenceButton.Parent := ReferenceContainer;
  var DuplicateReference := TButton.Create(nil);
  DuplicateReference.StyleLookup := 'referenceTarget';
  DuplicateReference.Parent := ReferenceUser;
  var MissingReference := TButton.Create(nil);
  MissingReference.StyleLookup := 'missingReferenceStyle';
  MissingReference.Parent := ReferenceUser;
  var DefaultReference := TButton.Create(nil);
  DefaultReference.Parent := ReferenceUser;
  var DefaultReferenceRoot := TLayout.Create(nil);
  DefaultReferenceRoot.StyleName := DefaultReference.DefaultStyleLookupName;
  DefaultReferenceRoot.Parent := FRoot;
  var HiddenReference := TButton.Create(nil);
  HiddenReference.StyleLookup := 'hiddenReferenceStyle';
  HiddenReference.Stored := False;
  HiddenReference.Parent := ReferenceUser;
  var MetadataReference := TButton.Create(nil);
  MetadataReference.StyleLookup := 'referenceTarget';
  MetadataReference.Parent := DesignerLayout(True);
  SetModelDesigning(FRoot);
  RebuildTree;
  SelectObject(ReferenceUser);
  ClearHistory;
  var BeforeReferenceMenu := Snapshot;
  ObjectMenuOpening(nil);
  Check(UsedInButton.Enabled and DependenciesButton.Enabled and (DependenciesButton.ItemsCount = 3),
    'reference menu collects nested, distinct and default control styles, excluding unstored controls');
  Check((MenuReference(DependenciesButton, 'referenceTarget') <> nil) and
    MenuReference(DependenciesButton, 'referenceTarget').Enabled and
    not MenuReference(DependenciesButton, 'missingReferenceStyle').Enabled,
    'dependencies resolve case insensitive roots and mark missing styles');
  Check(CompareText(DependenciesButton.Items[0].TagString, DependenciesButton.Items[1].TagString) < 0,
    'reference menu sorts names without regard to case');
  Check(SameSnapshot(BeforeReferenceMenu, Snapshot) and (FUndo.Count = 0) and not FDirty,
    'opening reference menus does not change document or history');
  StyleReferenceClick(MenuReference(DependenciesButton, 'referenceTarget'));
  Check(FSelected = ReferenceTarget, 'dependency menu navigates to root style');
  ObjectMenuOpening(nil);
  Check((UsedInButton.ItemsCount = 3) and (MenuReference(UsedInButton, 'referenceUser') <> nil) and
    UsedInButton.Items[1].IsSeparator and (MenuClass('TButton') <> nil) and
    not MenuClass('TButton').Enabled and not Assigned(MenuClass('TButton').OnClick),
    'used in menu excludes metadata and lists each containing style once');
  StyleReferenceClick(MenuReference(UsedInButton, 'referenceUser'));
  Check(FSelected = ReferenceUser, 'used in menu navigates to containing style');
  SelectObject(DefaultReferenceRoot);
  ObjectMenuOpening(nil);
  Check(MenuReference(UsedInButton, 'referenceUser') <> nil,
    'used in menu includes controls using their default StyleLookup');
  SelectObject(ReferenceUser);
  ReferenceButton.StyleLookup := 'referenceUser';
  ObjectMenuOpening(nil);
  Check((MenuReference(UsedInButton, 'referenceUser') <> nil) and
    (MenuReference(DependenciesButton, 'referenceUser') <> nil),
    'self references are listed without recursive style expansion');
  ReferenceButton.StyleLookup := 'changedReferenceStyle';
  ObjectMenuOpening(nil);
  Check((MenuReference(DependenciesButton, 'referenceUser') = nil) and
    (MenuReference(DependenciesButton, 'changedReferenceStyle') <> nil),
    'reference menus rebuild after StyleLookup edits');
  SelectObject(ReferenceTarget);
  ObjectMenuOpening(nil);
  Check((DependenciesButton.ItemsCount = 1) and not DependenciesButton.Items[0].Enabled,
    'empty dependencies have a disabled explanatory item');
  SelectObject(ReferenceButton);
  ObjectMenuOpening(nil);
  Check(not UsedInButton.Enabled and not DependenciesButton.Enabled and
    (DependenciesButton.ItemsCount = 0), 'reference commands are disabled for nested objects');
  SelectObject(FRoot);
  ObjectMenuOpening(nil);
  Check(not UsedInButton.Enabled and not DependenciesButton.Enabled, 'reference commands are disabled without a style');
  SelectObject(ReferenceUser);
  TStyleTreeView(FTree).ChooseItem(FTreeItems[Pointer(ReferenceTarget)], [ssCtrl]);
  ObjectMenuOpening(nil);
  Check(not UsedInButton.Enabled and not DependenciesButton.Enabled,
    'reference commands are disabled for multiple selected styles');
  var ReferenceGroup := CreateStyleGroup('Reference group', '');
  FTree.Selected := FTreeItems[Pointer(ReferenceGroup)];
  ObjectMenuOpening(nil);
  Check(not UsedInButton.Enabled and not DependenciesButton.Enabled,
    'reference commands are disabled for groups');
  Check(ObjectEditSeparator.IsSeparator and ObjectReferencesSeparator.IsSeparator and
    ObjectGroupsSeparator.IsSeparator and ObjectSortSeparator.IsSeparator and
    ObjectOrderSeparator.IsSeparator and ObjectHierarchySeparator.IsSeparator and
    FileSaveSeparator.IsSeparator and FileImportSeparator.IsSeparator and FileClipboardSeparator.IsSeparator,
    'command groups use ordinary menu items with separator text');

  var CalendarReference := TLayout.Create(nil);
  CalendarReference.StyleName := 'calendarstyle_sized';
  CalendarReference.Parent := FRoot;
  var CalendarDays := TListBox.Create(nil);
  CalendarDays.StyleName := 'days';
  CalendarDays.DefaultItemStyles.ItemStyle := 'DAYS_ITEMS';
  CalendarDays.DefaultItemStyles.GroupHeaderStyle := 'days_header';
  CalendarDays.DefaultItemStyles.GroupFooterStyle := 'days_footer';
  CalendarDays.Parent := CalendarReference;
  var DaysResource := TLayout.Create(nil);
  DaysResource.StyleName := 'days_items';
  DaysResource.Parent := FRoot;
  SetModelDesigning(FRoot);
  RebuildTree;
  SelectObject(DaysResource);
  ClearHistory;
  var BeforeDynamicMenu := Snapshot;
  ObjectMenuOpening(nil);
  Check((CalendarDays.Count = 0) and (MenuReference(UsedInButton, 'calendarstyle_sized') <> nil) and
    (MenuClass('TCalendar') <> nil) and (MenuClass('TDayItem') <> nil) and
    (MenuClass('TListBoxItem') <> nil),
    'runtime calendar days styles resolve through DefaultItemStyles without serialized day controls');
  Check(UsedInButton.Items[1].IsSeparator and SameSnapshot(BeforeDynamicMenu, Snapshot) and
    (FUndo.Count = 0) and not FDirty,
    'dynamic class menu is separated and does not instantiate controls or change the document');
  for var I := 3 to UsedInButton.ItemsCount - 1 do
    Check(CompareText(UsedInButton.Items[I - 1].Text, UsedInButton.Items[I].Text) < 0,
      'control classes are sorted and deduplicated');
  CalendarDays.DefaultItemStyles.ItemStyle := 'changed_days_items';
  ObjectMenuOpening(nil);
  Check((MenuReference(UsedInButton, 'calendarstyle_sized') = nil) and
    (MenuClass('TCalendar') = nil) and (UsedInButton.ItemsCount = 3),
    'dynamic style links rebuild after settings change and explain unknown consumers');
  SelectObject(CalendarReference);
  ObjectMenuOpening(nil);
  Check((MenuReference(DependenciesButton, 'changed_days_items') <> nil) and
    (MenuReference(DependenciesButton, 'days_header') <> nil) and
    (MenuReference(DependenciesButton, 'days_footer') <> nil),
    'dependencies include runtime list item, header and footer styles');

  var SourceAtlas := TImage.Create(nil);
  SourceAtlas.StyleName := 'referenceAtlas.bmp';
  SourceAtlas.Parent := FRoot;
  var SourceUser := TLayout.Create(nil);
  SourceUser.StyleName := 'sourceUser';
  SourceUser.Parent := FRoot;
  var SourceContainer := TLayout.Create(nil);
  SourceContainer.Parent := SourceUser;
  var SourceObject := TStyleObject.Create(nil);
  SourceObject.SourceLookup := 'REFERENCEATLAS.BMP';
  SourceObject.Parent := SourceContainer;
  var DuplicateSource := TStyleObject.Create(nil);
  DuplicateSource.SourceLookup := SourceAtlas.StyleName;
  DuplicateSource.Parent := SourceUser;
  var MaskedSource := TMaskedImage.Create(nil);
  MaskedSource.SourceLookup := SourceAtlas.StyleName;
  MaskedSource.Parent := SourceContainer;
  var MissingSource := TStyleObject.Create(nil);
  MissingSource.SourceLookup := 'missingAtlas.bmp';
  MissingSource.Parent := SourceUser;
  var HiddenSource := TStyleObject.Create(nil);
  HiddenSource.SourceLookup := 'hiddenAtlas.bmp';
  HiddenSource.Stored := False;
  HiddenSource.Parent := SourceUser;
  var MetadataSource := TStyleObject.Create(nil);
  MetadataSource.SourceLookup := SourceAtlas.StyleName;
  MetadataSource.Parent := DesignerLayout(True);
  var RootSource := TButtonStyleObject.Create(nil);
  RootSource.StyleName := 'sourceButtonStyle';
  RootSource.SourceLookup := SourceAtlas.StyleName;
  RootSource.Parent := FRoot;
  SetModelDesigning(FRoot);
  RebuildTree;
  SelectObject(SourceAtlas);
  ClearHistory;
  var BeforeSourceMenu := Snapshot;
  ObjectMenuOpening(nil);
  Check((UsedInButton.ItemsCount = 6) and (MenuReference(UsedInButton, 'sourceUser') <> nil) and
    (MenuReference(UsedInButton, 'sourceButtonStyle') <> nil) and UsedInButton.Items[2].IsSeparator and
    (MenuClass('TStyleObject') <> nil) and (MenuClass('TButtonStyleObject') <> nil) and
    (MenuClass('TMaskedImage') <> nil),
    'SourceLookup finds distinct root and nested bitmap consumers, including masked image wrappers');
  Check(SameSnapshot(BeforeSourceMenu, Snapshot) and (FUndo.Count = 0) and not FDirty,
    'SourceLookup inspection preserves source images, document and history');
  StyleReferenceClick(MenuReference(UsedInButton, 'sourceUser'));
  Check(FSelected = SourceUser, 'SourceLookup used in menu navigates to the consuming resource');
  ObjectMenuOpening(nil);
  Check((DependenciesButton.ItemsCount = 2) and
    MenuReference(DependenciesButton, 'referenceAtlas.bmp').Enabled and
    not MenuReference(DependenciesButton, 'missingAtlas.bmp').Enabled and
    (MenuReference(DependenciesButton, 'hiddenAtlas.bmp') = nil),
    'SourceLookup dependencies resolve images without case sensitivity, flag missing images and skip unstored objects');
  StyleReferenceClick(MenuReference(DependenciesButton, 'referenceAtlas.bmp'));
  Check(FSelected = SourceAtlas, 'SourceLookup dependency menu navigates to the source image');
  SourceObject.SourceLookup := '';
  DuplicateSource.SourceLookup := 'changedAtlas.bmp';
  MaskedSource.SourceLookup := 'changedAtlas.bmp';
  ObjectMenuOpening(nil);
  Check((MenuReference(UsedInButton, 'sourceUser') = nil) and
    (MenuReference(UsedInButton, 'sourceButtonStyle') <> nil) and
    (MenuClass('TStyleObject') = nil) and (MenuClass('TMaskedImage') = nil),
    'SourceLookup usage rebuilds after changing or clearing source names');

  NewDocument;
  AddObject('TLayout');
  var SortZeta := FSelected;
  SortZeta.StyleName := 'Zeta';
  AddObject('TRectangle');
  FSelected.StyleName := 'zchild';
  SelectObject(SortZeta);
  AddObject('TText');
  FSelected.StyleName := 'achild';
  var SortSelection := FSelected;
  SelectObject(FRoot);
  AddObject('TLayout');
  var SortAlpha := FSelected;
  SortAlpha.StyleName := 'alpha';
  SelectObject(FRoot);
  AddObject('TLayout');
  FSelected.StyleName := 'beta';
  var SortGroup := CreateStyleGroup('Сортировка', '');
  SortZeta.Name := 'SortZeta';
  SortAlpha.Name := 'SortAlpha';
  FAssignments.AddOrSetValue(SortZeta.Name, SortGroup.ID);
  FAssignments.AddOrSetValue(SortAlpha.Name, SortGroup.ID);
  var SortMetadata := DesignerLayout(True);
  SortMetadata.Index := FRoot.ChildrenCount - 1;
  SelectObject(SortSelection);
  ClearHistory;
  FTree.ExpandAll;
  Check(FTree.GlobalCount > FTree.Count, 'prime expanded tree index before sorting');
  SortStyles;
  CheckTreeOrder;
  Check((FRoot.Children[0] = SortAlpha) and (FRoot.Children[3] = SortMetadata) and
    (FRoot.Children[1].StyleName = 'beta') and (FRoot.Children[2] = SortZeta),
    'resource sort ignores name case and retains metadata position');
  Check((FSelected = SortSelection) and (SortZeta.Children[0].StyleName = 'zchild') and
    (SortZeta.Children[1].StyleName = 'achild'), 'resource sort preserves selection and child stacking order');
  var SortGroupItem := FTreeItems[Pointer(SortGroup)];
  Check((SortGroupItem.Items[0].TagObject = SortAlpha) and (SortGroupItem.Items[1].TagObject = SortZeta) and
    (GroupOf(SortZeta) = SortGroup.ID), 'tree displays sorted styles within their original group');
  Check(FDirty and (FUndo.Count = 1), 'resource sort is one document change');
  SortStyles;
  Check(FUndo.Count = 1, 'already sorted resources do not add history');
  Undo(False);
  Check((FRoot.Children[0].StyleName = 'Zeta') and (FRoot.Children[3].StyleName = '#designer') and
    (FRoot.Children[1].StyleName = 'alpha'), 'undo restores resource order and metadata position');
  Undo(True);
  Check((FRoot.Children[0].StyleName = 'alpha') and (FRoot.Children[2].StyleName = 'Zeta'),
    'redo reapplies resource sort');
  var SortedStyleFile := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-sorted.style');
  SaveStyle(SortedStyleFile, TStyleFormat.Indexed);
  LoadDocument(SortedStyleFile);
  Check((FRoot.Children[0].StyleName = 'alpha') and (FRoot.Children[2].StyleName = 'Zeta') and
    (FGroups.Count = 1), 'sorted order and groups persist in style file');
  TFile.Delete(SortedStyleFile);

  NewDocument;
  AddObject('TLayout');
  FSelected.StyleName := 'multiAlpha';
  var MultiAlpha := FSelected;
  AddObject('TRectangle');
  FSelected.StyleName := 'multiOne';
  var MultiOne := FSelected;
  SelectObject(MultiAlpha);
  AddObject('TText');
  FSelected.StyleName := 'multiTwo';
  TText(FSelected).Text := 'Файл';
  var MultiTwo := FSelected;
  SelectObject(FRoot);
  AddObject('TLayout');
  FSelected.StyleName := 'multiBeta';
  var MultiBeta := FSelected;
  AddObject('TRectangle');
  FSelected.StyleName := 'multiThree';
  var MultiThree := FSelected;
  FTree.ExpandAll;
  var MultiTree := TStyleTreeView(FTree);
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiThree)], [ssCtrl]);
  Check((Length(SelectedTreeModels) = 2) and (FSelected = MultiThree), 'Ctrl selects same-level objects under different parents');
  var MultiText := ObjectText;
  Check(MultiText.Contains('multiOne') and MultiText.Contains('multiThree') and not MultiText.Contains('multiTwo'),
    'multi-selection exports only selected FMX objects');
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], [], True);
  Check(Length(SelectedTreeModels) = 2, 'right click retains multi-selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], [ssCtrl]);
  Check((Length(SelectedTreeModels) = 1) and (FSelected = MultiThree), 'Ctrl toggles off primary and retains active object');
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiAlpha)], [ssCtrl]);
  Check((Length(SelectedTreeModels) = 1) and (FSelected = MultiAlpha), 'Ctrl across levels resets selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiThree)], [ssShift]);
  Check(Length(SelectedTreeModels) = 3, 'Shift range skips intervening rows at another level');
  for var Item in MultiTree.SelectedItems do
    Check(Item.Level = FTreeItems[Pointer(MultiThree)].Level, 'range contains only one depth');
  RebuildTree;
  Check(Length(SelectedTreeModels) = 3, 'tree refresh retains multi-selection');
  MultiBeta.Index := 0;
  RebuildTree;
  Check(FTree.GlobalCount > FTree.Count, 'prime tree index before sorting with multi-selection');
  SortStyles;
  Check((Length(SelectedTreeModels) = 3) and (FRoot.Children[0] = MultiAlpha),
    'sort preserves all same-level selected objects');
  CheckTreeOrder;
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiAlpha)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiThree)], [ssShift]);
  Check((Length(SelectedTreeModels) = 1) and (FSelected = MultiThree), 'Shift across levels resets selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], []);
  var MultiKey: Word := vkDown;
  var MultiChar: WideChar := #0;
  MultiTree.KeyDown(MultiKey, MultiChar, [ssShift]);
  Check((MultiKey = 0) and (Length(SelectedTreeModels) = 2) and (FSelected = MultiTwo), 'Shift+Down extends keyboard selection');
  MultiKey := Ord('A');
  MultiTree.KeyDown(MultiKey, MultiChar, [ssCtrl]);
  Check(Length(SelectedTreeModels) = 3, 'Ctrl+A selects visible objects at the active level');
  FTreeItems[Pointer(MultiBeta)].IsExpanded := False;
  MultiKey := Ord('A');
  MultiTree.KeyDown(MultiKey, MultiChar, [ssCtrl]);
  Check(Length(SelectedTreeModels) = 2, 'Ctrl+A excludes collapsed descendants');
  FTreeItems[Pointer(MultiBeta)].IsExpanded := True;
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiOne)], []);
  FTree.ViewportPosition := PointF(0, 0);
  var MultiPoint := FTree.AbsoluteToLocal(FTreeItems[Pointer(MultiTwo)].LocalToAbsolute(PointF(180, 12)));
  FTree.AllowDrag := False;
  try
    MultiTree.MouseDown(TMouseButton.mbLeft, [ssCtrl], MultiPoint.X, MultiPoint.Y);
  finally
    FTree.AllowDrag := True;
  end;
  Check((Length(SelectedTreeModels) = 2) and (FSelected = MultiTwo), 'native Ctrl-click preserves earlier selected row');
  ObjectMenuOpening(nil);
  Check(CopyObjectButton.Enabled and DuplicateButton.Enabled and DeleteButton.Enabled and not IndentButton.Enabled,
    'multi-selection menu enables batch actions');
  ClearHistory;
  DuplicateObject;
  Check((MultiAlpha.ChildrenCount = 4) and (Length(SelectedTreeModels) = 2) and (FUndo.Count = 1),
    'duplicate processes all selected objects as one undo step');
  DeleteSelection;
  Check((MultiAlpha.ChildrenCount = 2) and (FUndo.Count = 2), 'delete processes the duplicated selection as one undo step');
  Undo(False);
  Check(FRoot.FindStyleResource('multiAlpha').ChildrenCount = 4, 'undo restores deleted objects');
  Undo(False);
  Check(FRoot.FindStyleResource('multiAlpha').ChildrenCount = 2, 'undo restores original objects before batch duplicate');
  MultiAlpha := FRoot.FindStyleResource('multiAlpha');
  MultiTwo := MultiAlpha.FindStyleResource('multiTwo');
  SelectObject(MultiAlpha);
  ClearHistory;
  PasteObjectText(MultiText);
  Check((MultiAlpha.ChildrenCount = 4) and (FUndo.Count = 1), 'copied multi-selection pastes as standard sibling FMX objects');
  Undo(False);
  MultiAlpha := FRoot.FindStyleResource('multiAlpha');
  MultiTwo := MultiAlpha.FindStyleResource('multiTwo');
  SelectObject(MultiAlpha);
  AddObject('TButton');
  FSelected.StyleName := 'authoredButton';
  TButton(FSelected).Text := 'Файл';
  var AuthoredButton := TButton(FSelected);
  SelectObject(MultiTwo);
  RefreshDesign(True);
  var LanguageState := Snapshot;
  var LanguageUndo := FUndo.Count;
  var LanguageDirty := FDirty;
  LanguageBox.ItemIndex := 1;
  Check(Language.Lang = 'en-US', 'TLang selected language: ' + Language.Lang);
  var ThemeIndexBeforeLanguage := ComboBoxTheme.ItemIndex;
  var EnglishDialogReport := TStringList.Create;
  try
    RunWinUIDialogTests(Self, EnglishDialogReport, '-english');
    RunGradientDialogTests(Self, EnglishDialogReport, '-english');
    for var Message in EnglishDialogReport do
      Check(True, Message);
  finally
    EnglishDialogReport.Free;
  end;
  Check((ComboBoxTheme.Items[0] = 'Use system parameters') and
    (ComboBoxTheme.Items[1] = 'Light') and (ComboBoxTheme.Items[2] = 'Dark') and
    (ComboBoxTheme.Hint = 'App theme'), 'English application theme options and hint');
  Check(FileButton.Text = 'File', 'English toolbar: ' + FileButton.Text);
  Check(CopyObjectButton.Text = 'Copy (Ctrl+C)', 'English menu: ' + CopyObjectButton.Text);
  Check((UsedInButton.Text = 'Used in ...') and (DependenciesButton.Text = 'Dependencies'),
    'style reference menu captions switch to English');
  Check(FCategory.Items[0] = 'All', 'English category: ' + FCategory.Items[0]);
  Check(FBackgroundMode.Items[0] = 'Light background', 'English background: ' + FBackgroundMode.Items[0]);
  Check((TText(MultiTwo).Text = 'Файл') and (TText(FDesignRoot.FindStyleResource('multiTwo')).Text = 'Файл'),
    'language switching preserves authored style text and workspace copy');
  var AuthoredButtonCopy := FindDesignObject(FDesignRoot, AuthoredButton);
  Check(AuthoredButton.Text = 'Файл', 'language preserves authored button model text: ' + AuthoredButton.Text);
  Check(AuthoredButtonCopy is TButton, 'authored styled control has a workspace copy');
  Check(TButton(AuthoredButtonCopy).Text = 'Файл', 'language preserves authored button workspace text: ' + TButton(AuthoredButtonCopy).Text);
  Check(SameSnapshot(LanguageState, Snapshot) and (FUndo.Count = LanguageUndo) and (FDirty = LanguageDirty),
    'language switching does not modify document or history');
  ValuesDialog := TNamedValuesDialog.CreateEditor(Self);
  try
    Check((ValuesDialog.Caption = 'Named values') and (ValuesDialog.NameColumn.Header = 'Name') and
      (ValuesDialog.FKind.Items[0] = 'Color'), 'English named values dialog translates headers and types');
    ValuesDialog.ResourceAction(ValuesDialog.AddButton);
    Check(ValuesDialog.Values[0].Kind = 'Цвет', 'English resource picker retains canonical stored kind');
    ValuesDialog.EditValue(nil, 1, 0, TValue.From<string>('Integer'));
    Check((ValuesDialog.Values[0].Kind = 'Целое') and (ValuesDialog.FGrid.Cells[1, 0] = 'Integer'),
      'English grid type editing round-trips canonical kind');
    var BeforeInvalidValue := ValuesDialog.Values[0].LightValue;
    ValuesDialog.EditValue(nil, 2, 0, TValue.From<string>('invalid'));
    Check(ValuesDialog.ValidationError.Visible and not ValuesDialog.ValidationError.Text.IsEmpty and
      (ValuesDialog.Values[0].LightValue = BeforeInvalidValue),
      'invalid value shows contextual feedback and preserves the draft');
    ValuesDialog.EditValue(nil, 2, 0, TValue.From<string>('2'));
    Check(not ValuesDialog.ValidationError.Visible and (ValuesDialog.Values[0].LightValue = '2'),
      'valid value clears contextual feedback');
    CaptureDialog(ValuesDialog, 'selftest-values-english.png');
  finally
    ValuesDialog.Free;
  end;
  var EnglishTextDialog := TTextEditorForm.Create(Self);
  try
    Check(EnglishTextDialog.Caption = 'Text editor', 'new English text dialog caption: ' + EnglishTextDialog.Caption);
    Check(EnglishTextDialog.ApplyButton.Text = 'Apply', 'new English text dialog button: ' + EnglishTextDialog.ApplyButton.Text);
    Check(EnglishTextDialog.WordWrapCheck.Text = 'Word wrap', 'English word wrap option');
  finally
    EnglishTextDialog.Free;
  end;
  CaptureDialog(Self, 'selftest-english.png');
  LanguageBox.ItemIndex := 0;
  Check((ComboBoxTheme.Items[0] = 'Как в системе') and
    (ComboBoxTheme.Items[1] = 'Светлая') and (ComboBoxTheme.Items[2] = 'Тёмная') and
    (ComboBoxTheme.ItemIndex = ThemeIndexBeforeLanguage), 'Russian application theme options preserve selection');
  Check((FileButton.Text = 'Файл') and (FCategory.Items[0] = 'Все') and
    (FBackgroundMode.Items[0] = 'Светлый фон') and (CopyObjectButton.Text = 'Копировать (Ctrl+C)'),
    'TLang switches translated UI back to Russian');
  Check(SameSnapshot(LanguageState, Snapshot) and (TText(MultiTwo).Text = 'Файл'), 'Russian switch leaves document unchanged');
  Check((UsedInButton.Text = 'Используется в ...') and (DependenciesButton.Text = 'Зависимости'),
    'style reference menu captions switch back to Russian');
  var LanguageColorDialog := TColorEditorForm.Create(Self);
  try
    LanguageBox.ItemIndex := 1;
    TranslateForm(LanguageColorDialog);
    Check((LanguageColorDialog.Caption = 'Resource color') and (LanguageColorDialog.ApplyButton.Text = 'Apply'),
      'English color dialog captions');
    LanguageBox.ItemIndex := 0;
    TranslateForm(LanguageColorDialog);
    Check((LanguageColorDialog.Caption = 'Цвет ресурса') and (LanguageColorDialog.ApplyButton.Text = 'Применить'),
      'dialog captions switch back to Russian');
  finally
    LanguageColorDialog.Free;
  end;
  // CaptureDialog(Self) hides the form; native hit testing needs visible rows.
  Show;
  NewDocument;
  AddObject('TLayout');
  FSelected.StyleName := 'dragAlpha';
  var DragAlpha := FSelected;
  AddObject('TRectangle');
  FSelected.StyleName := 'dragOne';
  var DragOne := FSelected;
  SelectObject(FRoot);
  AddObject('TLayout');
  FSelected.StyleName := 'dragBeta';
  var DragBeta := FSelected;
  AddObject('TText');
  FSelected.StyleName := 'dragTwo';
  var DragTwo := FSelected;
  SelectObject(FRoot);
  AddObject('TLayout');
  FSelected.StyleName := 'dragTarget';
  var DragContainer := FSelected;
  FTree.ExpandAll;
  FTree.ViewportPosition := PointF(0, 0);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  Application.ProcessMessages;
  FTree.RealignContent;
  FTree.ViewportPosition := PointF(0, 0);
  var DragPoint := FTree.AbsoluteToLocal(FTreeItems[Pointer(DragOne)].LocalToAbsolute(PointF(180, 12)));
  Check(FTree.ItemByPoint(DragPoint.X, DragPoint.Y) = FTreeItems[Pointer(DragOne)],
    'batch mouse test hits source row');
  MultiTree.MouseDown(TMouseButton.mbLeft, [], DragPoint.X, DragPoint.Y);
  Check((Length(SelectedTreeModels) = 2) and (FSelected = DragOne) and FTree.AllowDrag,
    'native mouse down on selected row retains all drag sources');
  MultiTree.MouseUp(TMouseButton.mbLeft, [], DragPoint.X, DragPoint.Y);
  ClearHistory;
  Check(CanDrop(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragAlpha)]),
    'batch drop allows a source already in the target parent');
  TreeDragChange(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragAlpha)], DropAllowed);
  DeferredRefresh(nil);
  Check((DragOne.Parent = DragAlpha) and (DragTwo.Parent = DragAlpha) and
    (DragBeta.ChildrenCount = 0) and (Length(SelectedTreeModels) = 0) and
    (FTree.Selected = nil) and (Length(MultiTree.SelectedItems) = 0) and (FUndo.Count = 1),
    'batch drop moves other source and clears the entire selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  TreeDragChange(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragContainer)], DropAllowed);
  DeferredRefresh(nil);
  Check(not DropAllowed and (DragOne.Parent = DragContainer) and (DragTwo.Parent = DragContainer) and
    (DragContainer.Children[0] = DragOne) and (DragContainer.Children[1] = DragTwo) and
    (Length(SelectedTreeModels) = 0) and (FUndo.Count = 2),
    'batch drop moves all objects in tree order with one undo and clears selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  Check(not CanDrop(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragContainer)]),
    'batch drop onto the current parent is a no-op');
  Check(not CanDrop(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragTwo)]),
    'batch drop rejects a target contained in the selection');
  Undo(False);
  Check((FRoot.FindStyleResource('dragAlpha').ChildrenCount = 2) and
    (FRoot.FindStyleResource('dragTarget').ChildrenCount = 0), 'undo restores the whole batch drop');
  Undo(True);
  DragAlpha := FRoot.FindStyleResource('dragAlpha');
  DragContainer := FRoot.FindStyleResource('dragTarget');
  DragOne := DragContainer.FindStyleResource('dragOne');
  DragTwo := DragContainer.FindStyleResource('dragTwo');
  Check((DragAlpha.ChildrenCount = 0) and (DragContainer.ChildrenCount = 2), 'redo restores the whole batch drop');
  SelectObject(DragOne);
  AddObject('TText');
  var DragDescendant := FSelected;
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  Check(not CanDrop(FTreeItems[Pointer(DragTwo)], FTreeItems[Pointer(DragDescendant)]),
    'batch drop checks ancestor cycles for every selected object');
  SelectObject(DragContainer);
  AddObject('TFloatAnimation');
  var DragAnimation := FSelected;
  var DragGroup := CreateStyleGroup('Batch destination', '');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragAnimation)], [ssCtrl]);
  ClearHistory;
  Check(not CanDrop(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragGroup)]),
    'batch promotion rejects a selected nonvisual object');
  TreeDragChange(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragGroup)], DropAllowed);
  Check((DragOne.Parent = DragContainer) and (DragAnimation.Parent = DragContainer) and
    (Length(SelectedTreeModels) = 2) and (FUndo.Count = 0),
    'invalid batch drop leaves all parents, selection and history intact');
  DragOne.StyleName := 'shared';
  DragTwo.StyleName := 'shared';
  DragAlpha.StyleName := 'shared';
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  FTreeItems[Pointer(DragGroup)].IsExpanded := False;
  TreeDragChange(FTreeItems[Pointer(DragOne)], FTreeItems[Pointer(DragGroup)], DropAllowed);
  DeferredRefresh(nil);
  Check((DragOne.Parent = FRoot) and (DragTwo.Parent = FRoot) and
    (GroupOf(DragOne) = DragGroup.ID) and (GroupOf(DragTwo) = DragGroup.ID) and
    not SameText(DragOne.StyleName, DragTwo.StyleName) and not SameText(DragOne.StyleName, DragAlpha.StyleName) and
    not SameText(DragTwo.StyleName, DragAlpha.StyleName) and (Length(SelectedTreeModels) = 0) and (FUndo.Count = 1),
    'batch promotion creates unique root resources in a group and clears selection');
  Check(not FTreeItems[Pointer(DragGroup)].IsExpanded,
    'batch drop into a collapsed group preserves its fold');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  FTreeItems[Pointer(DragGroup)].IsExpanded := False;
  ObjectMenuOpening(nil);
  Check(MoveToGroupButton.Enabled and UngroupButton.Enabled, 'resource selection enables batch grouping menu actions');
  GroupAction(acUngroup);
  DeferredRefresh(nil);
  Check(GroupOf(DragOne).IsEmpty and GroupOf(DragTwo).IsEmpty and
    (Length(SelectedTreeModels) = 0) and (FUndo.Count = 2), 'ungroup menu processes the whole selection with one undo and clears selection');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragOne)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragTwo)], [ssCtrl]);
  AssignSelectionToGroup(DragGroup.ID);
  DeferredRefresh(nil);
  Check((GroupOf(DragOne) = DragGroup.ID) and (GroupOf(DragTwo) = DragGroup.ID) and
    (Length(SelectedTreeModels) = 0) and (FUndo.Count = 3), 'group menu processes the whole selection with one undo and clears selection');
  Check(not FTreeItems[Pointer(DragGroup)].IsExpanded,
    'batch group menu preserves a collapsed destination');
  var DragOuterGroup := CreateStyleGroup('Outer destination', '');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragGroup)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragAlpha)], [ssCtrl]);
  ClearHistory;
  ObjectMenuOpening(nil);
  Check(MoveToGroupButton.Enabled, 'mixed group and root resource selection enables batch grouping');
  FTreeItems[Pointer(DragOuterGroup)].IsExpanded := False;
  AssignSelectionToGroup(DragOuterGroup.ID);
  DeferredRefresh(nil);
  Check((DragGroup.ParentID = DragOuterGroup.ID) and (GroupOf(DragAlpha) = DragOuterGroup.ID) and
    (DragAlpha.Parent = FRoot) and (Length(SelectedTreeModels) = 0) and (FUndo.Count = 1),
    'batch grouping moves a group and resource without FMX reparenting');
  Check(not FTreeItems[Pointer(DragOuterGroup)].IsExpanded and not FTreeItems[Pointer(DragGroup)].IsExpanded,
    'moving a group and resource retains destination and moved group folds');
  MultiTree.ChooseItem(FTreeItems[Pointer(DragGroup)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(DragAlpha)], [ssCtrl]);
  FTreeItems[Pointer(DragOuterGroup)].IsExpanded := False;
  GroupAction(acUngroup);
  DeferredRefresh(nil);
  Check(DragGroup.ParentID.IsEmpty and GroupOf(DragAlpha).IsEmpty and
    (Length(SelectedTreeModels) = 0) and (FUndo.Count = 2), 'mixed selection ungroups as one operation and clears selection');
  var FoldNestedGroup := CreateStyleGroup('Nested destination', DragOuterGroup.ID);
  SelectObject(DragAlpha);
  FTreeItems[Pointer(DragOuterGroup)].IsExpanded := False;
  FTreeItems[Pointer(FoldNestedGroup)].IsExpanded := False;
  AssignToGroup(DragAlpha, nil, FoldNestedGroup.ID);
  DeferredRefresh(nil);
  Check((GroupOf(DragAlpha) = FoldNestedGroup.ID) and (Length(SelectedTreeModels) = 0) and
    not FTreeItems[Pointer(DragOuterGroup)].IsExpanded and not FTreeItems[Pointer(FoldNestedGroup)].IsExpanded,
    'single resource move preserves collapsed destination and ancestor groups');
  FTreeItems[Pointer(DragOuterGroup)].IsExpanded := True;
  FTreeItems[Pointer(FoldNestedGroup)].IsExpanded := True;
  AssignToGroup(DragAlpha, nil, '');
  DeferredRefresh(nil);
  AssignToGroup(DragAlpha, nil, FoldNestedGroup.ID);
  DeferredRefresh(nil);
  Check(FTreeItems[Pointer(DragOuterGroup)].IsExpanded and FTreeItems[Pointer(FoldNestedGroup)].IsExpanded,
    'single resource move preserves expanded destination and ancestor groups');

  NewDocument;
  AddObject('TLayout');
  var GroupResource := FSelected;
  GroupResource.Name := 'GroupResource';
  var MultiGroupA := CreateStyleGroup('A', '');
  var MultiGroupB := CreateStyleGroup('B', '');
  FAssignments.AddOrSetValue(GroupResource.Name, MultiGroupA.ID);
  RebuildTree;
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiGroupA)], []);
  MultiTree.ChooseItem(FTreeItems[Pointer(MultiGroupB)], [ssCtrl]);
  ObjectMenuOpening(nil);
  Check((Length(SelectedTreeModels) = 2) and DeleteButton.Enabled and not CopyObjectButton.Enabled,
    'multiple groups support deletion without exporting editor metadata as components');
  ClearHistory;
  DeleteSelection;
  Check((FGroups.Count = 0) and (StyleResourceCount = 1) and (FAssignments.Count = 0) and (FUndo.Count = 1),
    'batch group deletion preserves resources and clears assignments');
  Undo(False);
  Check((FGroups.Count = 2) and (StyleResourceCount = 1) and (FAssignments.Count = 1),
    'undo restores deleted groups and resource membership');

  NewDocument;
  Check((ResourceTheme = rtLight) and (ResourceThemeBox.ItemIndex = 0), 'new document defaults to light resource theme');
  AddObject('TRectangle');
  FSelected.Name := 'ThemeTestRectangle';
  FSelected.StyleName := 'themeteststyle';
  var ThemeRectangle := TRectangle(FSelected);
  AddTestValue('ThemeColor', 'Цвет', '#FFF0F0F0', 'Fill.Color');
  FindValue('ThemeColor').DarkValue := '#FF202020';
  AddTestValue('ThemeOpacity', 'Число', '0.9', 'Opacity');
  FindValue('ThemeOpacity').DarkValue := '0.45';
  AddTestValue('ThemeEnabled', 'Логическое', 'True', 'Enabled');
  FindValue('ThemeEnabled').DarkValue := 'False';
  AddObject('TText');
  FSelected.Name := 'ThemeTestText';
  var ThemeText := TText(FSelected);
  AddTestValue('ThemeCaption', 'Текст', 'Light caption', 'Text');
  FindValue('ThemeCaption').DarkValue := 'Dark caption';
  var ThemeInteger := TNamedStyleValue.Create;
  ThemeInteger.Name := 'ThemeInteger';
  ThemeInteger.Kind := 'Целое';
  ThemeInteger.LightValue := '10';
  ThemeInteger.DarkValue := '20';
  FValues.Add(ThemeInteger);
  ClearHistory;
  FBackgroundMode.ItemIndex := 0;
  ResourceThemeBox.ItemIndex := 1;
  Check((ResourceTheme = rtDark) and (ThemeRectangle.Fill.Color = $FF202020) and
    (Abs(ThemeRectangle.Opacity - 0.45) < 0.001) and not ThemeRectangle.Enabled and
    (ThemeText.Text = 'Dark caption') and (ThemeInteger.Value = '20') and (FBackgroundMode.ItemIndex = 1) and
    (FBindings.Count = 4) and (FUndo.Count = 1), 'theme selector switches every resource kind and background as one undo');
  Undo(False);
  ThemeRectangle := TRectangle(FindNamedObject('ThemeTestRectangle'));
  ThemeText := TText(FindNamedObject('ThemeTestText'));
  Check((ResourceTheme = rtLight) and (ResourceThemeBox.ItemIndex = 0) and
    (ThemeRectangle.Fill.Color = $FFF0F0F0) and (ThemeText.Text = 'Light caption') and (FBackgroundMode.ItemIndex = 0),
    'undo restores light resource values and theme selector');
  Undo(True);
  ThemeRectangle := TRectangle(FindNamedObject('ThemeTestRectangle'));
  ThemeText := TText(FindNamedObject('ThemeTestText'));
  Check((ResourceTheme = rtDark) and (ThemeRectangle.Fill.Color = $FF202020) and (ThemeText.Text = 'Dark caption'),
    'redo restores dark resource values');
  FBackgroundMode.ItemIndex := 2;
  ResourceTheme := rtLight;
  Check((FBackgroundMode.ItemIndex = 2) and (ThemeRectangle.Fill.Color = $FFF0F0F0),
    'theme switching preserves checkerboard background');
  ResourceTheme := rtDark;
  Check(FBackgroundMode.ItemIndex = 2, 'checkerboard remains selected in both resource themes');
  FBackgroundMode.ItemIndex := 1;
  ResourceTheme := rtLight;
  Check(FBackgroundMode.ItemIndex = 0, 'light theme automatically selects light solid background');
  SelectObject(ThemeRectangle);
  ShowPreview;
  ResourceTheme := rtDark;
  Check(TRectangle(FPreviewBook.Style.FindStyleResource('themeteststyle')).Fill.Color = $FF202020,
    'visible preview immediately switches to dark resource values');
  CaptureDialog(Self, 'selftest-theme-dark.png');
  ResourceTheme := rtLight;
  Check(TRectangle(FPreviewBook.Style.FindStyleResource('themeteststyle')).Fill.Color = $FFF0F0F0,
    'visible preview immediately switches back to light resource values');
  CaptureDialog(Self, 'selftest-theme-light.png');
  FPreview.Hide;
  var ThemeHistoryCount := FUndo.Count;
  ResourceTheme := rtLight;
  Check(FUndo.Count = ThemeHistoryCount, 'selecting the current resource theme creates no history');
  var ThemeCandidate := TNamedStyleValue.Create;
  try
    ThemeCandidate.Name := 'InvalidDark';
    ThemeCandidate.Kind := 'Цвет';
    ThemeCandidate.LightValue := '#FFFFFFFF';
    ThemeCandidate.DarkValue := 'not a color';
    var InvalidDarkRejected := False;
    try
      ValidateNamedValue(ThemeCandidate);
    except
      on E: Exception do
        InvalidDarkRejected := True;
    end;
    Check(InvalidDarkRejected, 'inactive theme values are validated before saving or applying');
  finally
    ThemeCandidate.Free;
  end;
  ValuesDialog := TNamedValuesDialog.CreateEditor(Self);
  try
    Check((ValuesDialog.FGrid.Cells[2, 0] = '#FFF0F0F0') and (ValuesDialog.FGrid.Cells[3, 0] = '#FF202020'),
      'resource dialog displays both theme values');
    ValuesDialog.EditValue(nil, 2, 0, TValue.From<string>('#FFEEDDCC'));
    ValuesDialog.EditValue(nil, 3, 0, TValue.From<string>('#FF111213'));
    Check(ValuesDialog.IsChanged and (ValuesDialog.Values[0].LightValue = '#FFEEDDCC') and
      (ValuesDialog.Values[0].DarkValue = '#FF111213') and (FindValue('ThemeColor').LightValue = '#FFF0F0F0') and
      (FindValue('ThemeColor').DarkValue = '#FF202020'), 'editing both theme columns only changes the resource draft');
    CaptureDialog(ValuesDialog, 'selftest-themed-values.png');
  finally
    ValuesDialog.Free;
  end;
  TThread.ForceQueue(nil,
    procedure
    begin
      for var I := 0 to Screen.FormCount - 1 do
        if Screen.Forms[I] is TNamedValuesDialog then
        begin
          var Dialog := TNamedValuesDialog(Screen.Forms[I]);
          Dialog.EditValue(nil, 2, 0, TValue.From<string>('#FFEEDDCC'));
          Dialog.EditValue(nil, 3, 0, TValue.From<string>('#FF111213'));
          Dialog.ModalResult := mrOk;
        end;
    end);
  ClearHistory;
  EditNamedValues;
  Check((FindValue('ThemeColor').LightValue = '#FFEEDDCC') and (FindValue('ThemeColor').DarkValue = '#FF111213') and
    (ThemeRectangle.Fill.Color = $FFEEDDCC) and (FUndo.Count = 1), 'apply saves both theme values and applies the selected theme');
  Undo(False);
  Check((FindValue('ThemeColor').LightValue = '#FFF0F0F0') and (FindValue('ThemeColor').DarkValue = '#FF202020'),
    'undo restores both edited theme values together');
  ResourceTheme := rtDark;
  var ThemeFile := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-themes.style');
  for var Format in [TStyleFormat.Indexed, TStyleFormat.Text] do
  begin
    SaveStyle(ThemeFile, Format);
    LoadDocument(ThemeFile);
    Check((ResourceTheme = rtDark) and (FindValue('ThemeColor').LightValue = '#FFF0F0F0') and
      (FindValue('ThemeColor').DarkValue = '#FF202020') and (FindValue('ThemeCaption').DarkValue = 'Dark caption') and
      (TRectangle(FindNamedObject('ThemeTestRectangle')).Fill.Color = $FF202020),
      'both resource themes and active mode roundtrip: ' + Ord(Format).ToString);
    ResourceTheme := rtLight;
    Check(TText(FindNamedObject('ThemeTestText')).Text = 'Light caption', 'reloaded style can switch to the inactive saved theme');
    ResourceTheme := rtDark;
  end;
  var InvalidThemeJSON := TJSONObject.ParseJSONValue(MetadataJSON) as TJSONObject;
  try
    InvalidThemeJSON.RemovePair('theme').Free;
    InvalidThemeJSON.AddPair('theme', 'invalid');
    TStyleTag(DesignerLayout(False).FindStyleResource('project')).TagString := InvalidThemeJSON.ToJSON;
    var InvalidThemeStream := TFileStream.Create(ThemeFile, fmCreate);
    try
      TStyleStreaming.SaveToStream(FRoot, InvalidThemeStream, TStyleFormat.Indexed);
    finally
      InvalidThemeStream.Free;
    end;
  finally
    InvalidThemeJSON.Free;
  end;
  var InvalidThemeHistory := FUndo.Count;
  var InvalidThemeRejected := False;
  try
    LoadDocument(ThemeFile);
  except
    on E: Exception do
      InvalidThemeRejected := True;
  end;
  Check(InvalidThemeRejected and (ResourceTheme = rtDark) and (ResourceThemeBox.ItemIndex = 1) and
    (FindValue('ThemeColor').LightValue = '#FFF0F0F0') and (FindValue('ThemeColor').DarkValue = '#FF202020') and
    (TRectangle(FindNamedObject('ThemeTestRectangle')).Fill.Color = $FF202020) and (FUndo.Count = InvalidThemeHistory),
    'invalid saved theme restores the previous document, resource values and history');
  var ThemeLegacyJSON := TJSONObject.ParseJSONValue(MetadataJSON) as TJSONObject;
  try
    ThemeLegacyJSON.RemovePair('version').Free;
    ThemeLegacyJSON.AddPair('version', TJSONNumber.Create(2));
    ThemeLegacyJSON.RemovePair('theme').Free;
    for var Item in ThemeLegacyJSON.GetValue<TJSONArray>('values') do
    begin
      TJSONObject(Item).AddPair('value', Item.GetValue<string>('dark'));
      TJSONObject(Item).RemovePair('light').Free;
      TJSONObject(Item).RemovePair('dark').Free;
    end;
    TStyleTag(DesignerLayout(False).FindStyleResource('project')).TagString := ThemeLegacyJSON.ToJSON;
    var ThemeLegacyStream := TFileStream.Create(ThemeFile, fmCreate);
    try
      TStyleStreaming.SaveToStream(FRoot, ThemeLegacyStream, TStyleFormat.Indexed);
    finally
      ThemeLegacyStream.Free;
    end;
  finally
    ThemeLegacyJSON.Free;
  end;
  LoadDocument(ThemeFile);
  Check((ResourceTheme = rtLight) and (FindValue('ThemeColor').DarkValue = '#FF202020') and
    (FindValue('ThemeColor').LightValue = '#FF202020') and (FindValue('ThemeCaption').DarkValue = 'Dark caption') and
    (FindValue('ThemeCaption').LightValue = 'Dark caption'),
    'version 2 migration stores old values in dark theme and copies them to default light theme');
  SaveStyle(ThemeFile, TStyleFormat.Indexed);
  LoadDocument(ThemeFile);
  Check((FindValue('ThemeInteger').LightValue = '20') and (FindValue('ThemeInteger').DarkValue = '20'),
    'migrated theme values persist in version 3 metadata');
  TFile.Delete(ThemeFile);
  NewDocument;
  AddObject('TLayout');
  var ClassResource := FSelected;
  ClassResource.StyleName := 'editstyle2';
  AddObject('TText');
  var ClassElement := FSelected;
  ClassElement.StyleName := 'text';
  Check(DetectStyleClass(ClassResource) = 'TEdit', 'preview detects class from indexed default style name');
  SelectObject(ClassElement);
  ObjectMenuOpening(nil);
  Check(not StyleClassButton.Enabled and not AutoStyleClassButton.Enabled, 'class assignment menu excludes nested style elements');
  var ClassScopeRejected := False;
  var BeforeScopeUndo := FUndo.Count;
  try
    AssignStyleClass(ClassElement, 'TEdit');
  except
    on E: Exception do
      ClassScopeRejected := True;
  end;
  Check(ClassScopeRejected and (FUndo.Count = BeforeScopeUndo), 'class assignment rejects nested elements without history');
  SelectObject(ClassResource);
  ClearHistory;
  AssignStyleClass(ClassResource, 'TCheckBox');
  Check((AssignedStyleClass(ClassResource) = 'TCheckBox') and (FUndo.Count = 1), 'style class assignment records one undo');
  Undo(False);
  ClassResource := FindStyleRoot('editstyle2');
  Check(AssignedStyleClass(ClassResource).IsEmpty, 'undo removes style class assignment');
  Undo(True);
  ClassResource := FindStyleRoot('editstyle2');
  Check(AssignedStyleClass(ClassResource) = 'TCheckBox', 'redo restores style class assignment');
  ClassResource.StyleName := 'unrelatedstyle';
  Check(DetectStyleClass(ClassResource) = 'TCheckBox', 'explicit class takes priority over resource name and survives rename');
  SelectObject(ClassResource);
  ObjectMenuOpening(nil);
  Check(StyleClassButton.Enabled and AutoStyleClassButton.Enabled, 'root resource exposes assignment and automatic mode');
  ShowPreview;
  var InteractivePreview := TPreviewForm(FPreview);
  Check((InteractivePreview.PreviewControl is TCheckBox) and
    (InteractivePreview.Inspector.InspectedObject = InteractivePreview.PreviewControl), 'assigned class selected when preview opens');
  Check((FPreview.StyleBook = StyleBook) and
    (InteractivePreview.PreviewControl.Scene.StyleBook = FPreviewBook), 'preview isolates edited styles from its class list and inspector');
  var BeforePreviewProperties := Snapshot;
  var BeforePreviewUndo := FUndo.Count;
  var PreviewViewport := InteractivePreview.SelectedControlHost;
  var PreviewCenter := PreviewViewport.AbsoluteToLocal(
    InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint));
  Check((InteractivePreview.ZoomPercent = 100) and
    (PreviewCenter.Distance(PreviewViewport.LocalRect.CenterPoint) < 0.1), 'preview defaults to 100 percent and centered');
  var PreviewAnchor := PointF(PreviewViewport.Width * 0.3, PreviewViewport.Height * 0.4);
  var PreviewLocalAnchor := InteractivePreview.PreviewControl.AbsoluteToLocal(PreviewViewport.LocalToAbsolute(PreviewAnchor));
  InteractivePreview.ZoomAt(PreviewAnchor, 60);
  Check(InteractivePreview.ZoomPercent = 100, 'preview accumulates partial wheel delta');
  InteractivePreview.ZoomAt(PreviewAnchor, 60);
  var PreviewAnchorAfter := PreviewViewport.AbsoluteToLocal(InteractivePreview.PreviewControl.LocalToAbsolute(PreviewLocalAnchor));
  Check((InteractivePreview.ZoomPercent = 110) and (PreviewAnchorAfter.Distance(PreviewAnchor) < 0.1),
    'preview wheel zoom preserves point under cursor');
  InteractivePreview.ViewZoom.ItemIndex := InteractivePreview.ViewZoom.Items.IndexOf('2000%');
  InteractivePreview.ZoomAt(PreviewAnchor, 120);
  Check(InteractivePreview.ZoomPercent = 2000, 'preview limits maximum zoom');
  InteractivePreview.ViewZoom.ItemIndex := InteractivePreview.ViewZoom.Items.IndexOf('50%');
  InteractivePreview.ZoomAt(PreviewAnchor, -120);
  Check(InteractivePreview.ZoomPercent = 50, 'preview limits minimum zoom');
  InteractivePreview.ResetView;
  // Start over the tested control, so navigation must precede control input.
  var PreviewPanStart := InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint);
  InteractivePreview.MouseDown(TMouseButton.mbMiddle, [ssMiddle], PreviewPanStart.X, PreviewPanStart.Y);
  InteractivePreview.MouseMove([ssMiddle], PreviewPanStart.X + 1200, PreviewPanStart.Y - 900);
  InteractivePreview.MouseUp(TMouseButton.mbMiddle, [], PreviewPanStart.X + 1200, PreviewPanStart.Y - 900);
  var PreviewPannedCenter := PreviewViewport.AbsoluteToLocal(
    InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint));
  Check((PreviewPannedCenter.Distance(PreviewCenter + PointF(1200, -900)) < 0.1) and
    not TCheckBox(InteractivePreview.PreviewControl).IsChecked and (InteractivePreview.Cursor = crDefault),
    'preview middle mouse pans outside viewport without activating control');
  InteractivePreview.CenterViewClick(nil);
  PreviewCenter := PreviewViewport.AbsoluteToLocal(
    InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint));
  Check(PreviewCenter.Distance(PreviewViewport.LocalRect.CenterPoint) < 0.1, 'preview center button resets pan');
  var PreviewWidth := InteractivePreview.ClientWidth;
  InteractivePreview.ClientWidth := PreviewWidth + 80;
  Application.ProcessMessages;
  PreviewCenter := PreviewViewport.AbsoluteToLocal(
    InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint));
  Check(PreviewCenter.Distance(PreviewViewport.LocalRect.CenterPoint) < 0.1, 'preview remains centered after resize');
  InteractivePreview.ClientWidth := PreviewWidth;
  InteractivePreview.ViewZoom.ItemIndex := InteractivePreview.ViewZoom.Items.IndexOf('200%');
  InteractivePreview.Hide;
  InteractivePreview.Show;
  PreviewCenter := PreviewViewport.AbsoluteToLocal(
    InteractivePreview.PreviewControl.LocalToAbsolute(InteractivePreview.PreviewControl.LocalRect.CenterPoint));
  Check((InteractivePreview.ZoomPercent = 100) and
    (PreviewCenter.Distance(PreviewViewport.LocalRect.CenterPoint) < 0.1), 'preview reopening resets zoom and center');
  InteractivePreview.MouseDown(TMouseButton.mbMiddle, [ssMiddle], PreviewPanStart.X, PreviewPanStart.Y);
  InteractivePreview.Deactivate;
  var PreviewPosition := InteractivePreview.PreviewControl.Position.Point;
  InteractivePreview.MouseMove([ssMiddle], PreviewPanStart.X + 40, PreviewPanStart.Y + 20);
  Check((InteractivePreview.Cursor = crDefault) and (InteractivePreview.PreviewControl.Position.Point = PreviewPosition),
    'preview deactivation ends pan');
  Check(SameSnapshot(BeforePreviewProperties, Snapshot) and (FUndo.Count = BeforePreviewUndo),
    'preview navigation preserves document and history');
  InteractivePreview.Inspector.WriteProperty('IsChecked', 'True');
  Check(TCheckBox(InteractivePreview.PreviewControl).IsChecked, 'preview inspector changes live control state');
  Check(SameSnapshot(BeforePreviewProperties, Snapshot) and (FUndo.Count = BeforePreviewUndo),
    'preview property changes do not modify style or document history');
  InteractivePreview.SelectClass('TEdit');
  RefreshPreview(nil);
  Check((InteractivePreview.PreviewControl is TEdit) and (AssignedStyleClass(ClassResource) = 'TCheckBox'),
    'temporary preview class selection retains saved assignment');
  InteractivePreview.Inspector.WriteProperty('Text', 'Preview edit');
  Check(TEdit(InteractivePreview.PreviewControl).Text = 'Preview edit', 'preview inspector edits input text');
  InteractivePreview.PreviewControl.Enabled := False;
  InteractivePreview.ControlChanged(InteractivePreview.PreviewControl);
  Check(InteractivePreview.Inspector.ValueText(InteractivePreview.Inspector.FindProperty('Enabled')) = 'False',
    'preview inspector refreshes control state');
  for var GridClass in ['TGrid', 'TStringGrid'] do
  begin
    InteractivePreview.SelectClass(GridClass);
    InteractivePreview.CreateControl('');
    var SampleGrid := TCustomGrid(InteractivePreview.PreviewControl);
    Check((SampleGrid.ColumnCount = 12) and (SampleGrid.RowCount = 20) and
      (SampleGrid.Images.Count = 6), GridClass + ' preview initializes all concrete column types and icons');
    Check((SampleGrid.Columns[0] is TStringColumn) and (SampleGrid.Columns[1] is TCheckColumn) and
      (SampleGrid.Columns[2] is TIntegerColumn) and (SampleGrid.Columns[3] is TFloatColumn) and
      (SampleGrid.Columns[4] is TCurrencyColumn) and (SampleGrid.Columns[5] is TDateColumn) and
      (SampleGrid.Columns[6] is TTimeColumn) and (SampleGrid.Columns[7] is TDateTimeColumn) and
      (SampleGrid.Columns[8] is TProgressColumn) and (SampleGrid.Columns[9] is TPopupColumn) and
      (SampleGrid.Columns[10] is TImageColumn) and (SampleGrid.Columns[11] is TGlyphColumn),
      GridClass + ' preview includes date-time, numeric, image and glyph columns');
    var SampleText := SampleGrid.Model.GetValue(0, 0, False);
    Check(not SampleText.IsEmpty and (SampleGrid.Model.GetValue(0, 0, True).AsString = SampleText.AsString),
      GridClass + ' random samples remain stable across redraws');
    for var SampleRow := 0 to SampleGrid.RowCount - 1 do
    begin
      Check(not SampleGrid.Model.GetValue(9, SampleRow, False).IsEmpty and
        (TPopupColumn(SampleGrid.Columns[9]).Items.IndexOf(SampleGrid.Model.GetValue(9, SampleRow, False).AsString) >= 0),
        GridClass + ' popup sample belongs to its choices');
      var IconIndex := TGlyphColumn(SampleGrid.Columns[11]).GetImageIndex(SampleGrid.Model.GetValue(11, SampleRow, False));
      Check((IconIndex >= 0) and (IconIndex < SampleGrid.Images.Count) and SampleGrid.Images.BitmapExists(IconIndex),
        GridClass + ' glyph sample points to a real bitmap');
    end;
    if SampleGrid is TGrid then
    begin
      Check(SampleGrid.Model.GetValue(1, 0, False).IsType<Boolean> and
        SampleGrid.Model.GetValue(2, 0, False).IsType<Integer> and
        SampleGrid.Model.GetValue(4, 0, False).IsType<Currency> and
        SampleGrid.Model.GetValue(5, 0, False).IsType<TDateTime> and
        SampleGrid.Model.GetValue(10, 0, False).IsType<TBitmap>, 'grid samples retain native value types');
      TGrid(SampleGrid).OnSetValue(SampleGrid, 0, 0, 'Edited sample');
      Check(SampleGrid.Model.GetValue(0, 0, True).AsString = 'Edited sample',
        'grid retains edited cell values after cache invalidation');
      CaptureDialog(FPreview, 'selftest-preview-grid.png');
    end
    else
    begin
      TStringGrid(SampleGrid).Cells[0, 0] := 'Edited sample';
      Check(SampleGrid.Model.GetValue(0, 0, False).AsString = 'Edited sample', 'string grid uses editable Cells storage');
      SampleGrid.LeftColumn := 10;
      CaptureDialog(FPreview, 'selftest-preview-stringgrid-images.png');
    end;
    Check((InteractivePreview.ZoomPercent = 100) and SameSnapshot(BeforePreviewProperties, Snapshot) and
      (FUndo.Count = BeforePreviewUndo), GridClass + ' samples preserve the document and default preview zoom');
  end;
  InteractivePreview.ClassSearch.Text := 'tcustom';
  Check((InteractivePreview.ClassList.Count = 0) and (InteractivePreview.PreviewControl = nil) and
    (InteractivePreview.Inspector.InspectedObject = nil), 'preview search excludes custom bases and clears empty inspector');
  InteractivePreview.ClassSearch.Text := 'tcheckb';
  Check((InteractivePreview.ClassList.Count = 1) and (InteractivePreview.PreviewControl is TCheckBox),
    'preview class search is case insensitive');
  InteractivePreview.SelectClass('TEdit');
  RefreshPreview(nil);
  InteractivePreview.AssignClassClick(InteractivePreview.AssignClassButton);
  Check(AssignedStyleClass(ClassResource) = 'TEdit', 'preview assign button saves selected class');
  FPreview.Hide;
  for var Format in [TStyleFormat.Binary, TStyleFormat.Indexed] do
  begin
    var ClassFile := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-class-assignment.style');
    SaveStyle(ClassFile, Format);
    LoadDocument(ClassFile);
    ClassResource := FindStyleRoot('unrelatedstyle');
    Check(AssignedStyleClass(ClassResource) = 'TEdit', 'assigned class persists in style format ' + Ord(Format).ToString);
    TFile.Delete(ClassFile);
  end;
  SelectObject(ClassResource);
  DuplicateObject;
  Check((AssignedStyleClass(FSelected) = 'TEdit') and (FSelected.Name <> ClassResource.Name),
    'duplicate resource retains class with separate metadata target');
  DeleteSelection;
  Check(AssignedStyleClass(ClassResource) = 'TEdit', 'deleting duplicate preserves original class assignment');
  Undo(False);
  Check(AssignedStyleClass(FindStyleRoot('unrelatedstyle_copy')) = 'TEdit', 'undo deletion restores class assignment');
  ClassResource := FindStyleRoot('unrelatedstyle');
  SelectObject(ClassResource);
  AssignStyleClass(ClassResource, '');
  Check(AssignedStyleClass(ClassResource).IsEmpty, 'automatic mode clears explicit assignment');
  ShowPreview;
  Check(InteractivePreview.SelectedClass = DetectStyleClass(ClassResource), 'opening unassigned style chooses detected class');
  CaptureDialog(FPreview, 'selftest-preview-inspector.png');
  FPreview.Hide;
  NewDocument;
  Check(FStyleClasses.Count = 0, 'new document clears assigned style classes');
  var Catalog := TStyleCatalog.Create;
  try
    Check(Catalog.Definitions.Count = 168, 'style reference contains all documented controls and color item contract');
    Check(Catalog.Find(' tbutton ') = Catalog.Find('TButton'), 'catalogue class lookup ignores case and whitespace');
    var ButtonDefinition := Catalog.Find('TButton');
    var HasButtonText := False;
    var HasButtonGlyph := False;
    for var Part in ButtonDefinition.Parts do
    begin
      if SameText(Part.Name, 'text') then
        HasButtonText := Part.Examples.Contains('TText') and Part.DeclaredIn.Contains('TPresentedTextControl');
      if SameText(Part.Name, 'glyphstyle') then
        HasButtonGlyph := Part.Examples.Contains('TGlyph');
    end;
    Check(HasButtonText and HasButtonGlyph, 'reference includes inherited button text and glyph class contracts');
    Check(Catalog.Find('TComboTrackBar').DefaultStyleName = 'comboeditstyle', 'combotrackbar default style override');
    Check(Catalog.Find('TCalendarEdit').DefaultNote.Contains('InputSupport'), 'conditional default style names documented');
    var StyleUsers := TStringList.Create;
    try
      for var StyleName in ['dayitemstyle', 'calendarlabelstyle'] do
      begin
        Catalog.ControlsUsingStyle(StyleName.ToUpper, StyleUsers);
        Check((StyleUsers.IndexOf('TCalendar') >= 0) and (StyleUsers.IndexOf('TStyledCalendar') >= 0),
          'code-created calendar dependencies include their owner ' + StyleName);
      end;
      Catalog.ControlsUsingStyle('spinleftbutton', StyleUsers);
      Check(StyleUsers.IndexOf('TTabControl') >= 0, 'runtime array names identify tab scrolling controls');
      Catalog.ControlsUsingStyle('listitemdeletebutton', StyleUsers);
      Check((StyleUsers.IndexOf('TListView') >= 0) and (StyleUsers.IndexOf('TListViewBase') >= 0),
        'runtime references are inherited by public controls');
      Catalog.ControlsUsingStyle('comboeditstyle', StyleUsers);
      Check(StyleUsers.IndexOf('TCalendarEdit') >= 0, 'conditional InputSupport style identifies CalendarEdit');
      Catalog.ControlsUsingStyle('menuseparatorstyle', StyleUsers);
      Check(StyleUsers.IndexOf('TMenuItem') >= 0, 'conditional separator style identifies MenuItem');
      Catalog.ControlsUsingStyle('pushpanel', StyleUsers);
      Check(StyleUsers.IndexOf('TMultiView') >= 0, 'runtime presentation style identifies MultiView');
      Catalog.ControlsUsingStyle('', StyleUsers);
      Check(StyleUsers.Count = 0, 'empty style names do not match presentations without defaults');
      Catalog.ControlsUsingStyle('unknown_custom_style', StyleUsers);
      Check(StyleUsers.Count = 0, 'unknown styles do not infer arbitrary framework classes');
    finally
      StyleUsers.Free;
    end;
    for var ClassName in ['TButton', 'TEdit', 'TComboTrackBar', 'TCalendarEdit', 'TMaskEdit', 'TGrid', 'TColorListBox', 'THueTrackBar', 'TSkLabel', 'TVertScrollBox'] do
    begin
      var Control := TStyledControl(FClasses[ClassName].Create(nil));
      try
        SetModelDesigning(Control);
        Check(SameText(Control.DefaultStyleLookupName, Catalog.Find(ClassName).DefaultStyleName),
          'catalogue default agrees with FMX ' + ClassName);
      finally
        Control.Free;
      end;
    end;
    for var Entry in Catalog.Definitions do
    begin
      if Entry.DefaultStyleName.IsEmpty then
        Continue;
      var Plan := Catalog.BuildTemplate(Entry, Entry.DefaultStyleName, nil);
      var Required := TStringList.Create;
      try
        Required.CaseSensitive := False;
        Catalog.RequiredStyles(Entry, Required);
        Check(Plan.Resources.Count = Required.Count, 'template covers transitive dependencies for ' + Entry.ClassName);
        var Found := TStringList.Create;
        try
          Found.CaseSensitive := False;
          for var Obj in Plan.Resources do
          begin
            Check(Found.IndexOf(Obj.StyleName) < 0, 'no duplicated planned style ' + Entry.ClassName + '/' + Obj.StyleName);
            Found.Add(Obj.StyleName);
          end;
          for var Name in Required do
            Check(Found.IndexOf(Name) >= 0, 'required template resource exists ' + Entry.ClassName + '/' + Name);
        finally
          Found.Free;
        end;
      finally
        Required.Free;
        Plan.Free;
      end;
    end;
    NewDocument;
    ClearHistory;
    var Existing := TLayout.Create(nil);
    Existing.StyleName := 'BUTTONSTYLE';
    Existing.Parent := FRoot;
    Changed;
    ClearHistory;
    var BeforeTemplate := Snapshot;
    CreateStyleTemplate(Catalog, Catalog.Find('TCalendar'));
    Check(FindStyleRoot('buttonstyle') = Existing, 'template reuses existing dependency without replacement');
    Check((FindStyleRoot('calendarstyle') = FSelected) and (FGroups.Count = 1), 'calendar template creates main style and group');
    Check(GroupOf(Existing).IsEmpty, 'existing dependencies retain original group');
    var CalendarGroup := GroupOf(FSelected);
    Check(not CalendarGroup.IsEmpty, 'main template assigned to composite group');
    for var Obj in ChildrenOf(FRoot) do
      if (Obj <> Existing) and not SameText(Obj.StyleName, '#designer') then
        Check(GroupOf(Obj) = CalendarGroup, 'new dependent style belongs to template group');
    Check(FUndo.Count = 1, 'whole template is one undo action');
    UpdateDesignerMetadata;
    var TemplateMetadata := MetadataJSON;
    var TemplateCount := StyleResourceCount;
    Undo(False);
    Check(SameSnapshot(BeforeTemplate, Snapshot), 'undo restores complete book before template including metadata');
    Undo(True);
    Check(TemplateMetadata = MetadataJSON, 'redo restores group metadata');
    Check(TemplateCount = StyleResourceCount, 'redo restores resource count');
    Check(FindStyleRoot('calendarstyle').FindStyleResource('days') is TListBox,
      'redo restores typed calendar parts');
    CreateStyleTemplate(Catalog, Catalog.Find('TCalendar'));
    Check(FindStyleRoot('calendarstyle2') = FSelected, 'main style is always created with numeric suffix on collision');
    var ButtonCount := 0;
    for var Obj in ChildrenOf(FRoot) do
      if SameText(Obj.StyleName, 'buttonstyle') then
        Inc(ButtonCount);
    Check(ButtonCount = 1, 'shared dependencies are not duplicated by repeated templates');
    var Dialog := TStyleCatalogDialog.CreateCatalog(Self, Catalog,
      function(Name: string): Boolean
      begin
        Result := FindStyleRoot(Name) <> nil;
      end, 'TEdit');
    try
      Check((Dialog.Definition = Catalog.Find('TEdit')) and Dialog.CreateButton.Enabled,
        'catalogue dialog loads from FMX and selects initial class');
      Check(Dialog.InfoMemo.Text.Contains('editstyle'), 'reference displays default style name');
      Dialog.SearchEdit.Text := 'tcombOtrack';
      Dialog.FilterClasses(nil);
      Check((Dialog.ClassList.Count = 1) and (Dialog.Definition = Catalog.Find('TComboTrackBar')),
        'class search filters case insensitively');
      Dialog.SearchEdit.Text := 'no_such_fmx_class';
      Dialog.FilterClasses(nil);
      Check((Dialog.ClassList.Count = 0) and not Dialog.CreateButton.Enabled and (Dialog.PartsGrid.RowCount = 0),
        'empty reference search clears details and disables template creation');
      Dialog.SearchEdit.Text := 'TCalendar';
      Dialog.FilterClasses(nil);
      Dialog.ClassList.ItemIndex := 0;
      Dialog.SelectClass(nil);
      CaptureDialog(Dialog, 'selftest-style-catalog.png');
      Check(Dialog.PartsGrid.Height > 120, 'style reference keeps parts table visible');
      Check(Dialog.CreateButton.Position.X < Dialog.CloseButton.Position.X,
        'style reference places the safe close action at the right');
    finally
      Dialog.Free;
    end;
  finally
    Catalog.Free;
  end;
  for var Theme in ['Dark', 'Light'] do
  begin
    var UsageStyleFile := System.IOUtils.TPath.Combine(GetCurrentDir, 'DelphiWinUI3\Style\WinUI3_' + Theme + '.style');
    if not TFile.Exists(UsageStyleFile) then
      Continue;
    LoadDocument(UsageStyleFile);
    var RealDaysStyle := FindStyleRoot('days_itemstyle');
    Check(RealDaysStyle <> nil, 'WinUI3 ' + Theme + ' contains the runtime calendar day style');
    SelectObject(RealDaysStyle);
    ClearHistory;
    var BeforeRealUsageMenu := Snapshot;
    ObjectMenuOpening(nil);
    Check((MenuReference(UsedInButton, 'calendarstyle') <> nil) and
      (MenuReference(UsedInButton, 'calendarstyle_sized') <> nil) and
      (MenuClass('TCalendar') <> nil) and (MenuClass('TDayItem') <> nil),
      'WinUI3 ' + Theme + ' runtime day style identifies both calendar resources and Calendar class');
    Check(SameSnapshot(BeforeRealUsageMenu, Snapshot) and (FUndo.Count = 0) and not FDirty,
      'WinUI3 ' + Theme + ' usage inspection preserves the book');
  end;
  NewDocument;
  Check((ResourceTheme = rtLight) and (ResourceThemeBox.ItemIndex = 0), 'new document resets resource theme after dark-mode editing');
  FDirty := False;
end;

end.


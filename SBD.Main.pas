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
  SBD.EditorTypes, SBD.StyleDocument, SBD.PropertyInspector, SBD.StyleCatalog,
  SBD.BitmapLinksDialog, System.ImageList, System.IniFiles;

type
  TPaletteGroup = (pgButtons, pgInput, pgLists, pgNavigation, pgLayout, pgShapes,
    pgMedia, pgDateTime, pgColors, pgIndicators, pg3D, pgAnimations, pgEffects,
    pgStyleObjects, pgResources, pgOther);

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
    AddObjectMenuButton, AddPrimitivesMenuButton, AddAnimationsMenuButton: TMenuItem;
    GroupsMenuButton, ZOrderMenuButton, StyleInfoMenuButton: TMenuItem;
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
    procedure PaletteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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
  protected
    FPreferencesFile: string;
    procedure LoadApplicationTheme;
    procedure SaveApplicationTheme;
    procedure PositionWorkspaceSettings;
  protected
    // Internal editor operations are available to derived test fixtures.
    FProperties: TSBDPropertyInspector;
    FPreviewSource: TFmxObject;
    FSelectedGroup: TStyleGroup;
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
    FDocument: TStyleDocument;
    FSelected, FDesignRoot, FResource: TFmxObject;
    FEntries: TObjectList<TPropertyEntry>;
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
    FZoomEffects: TZoomEffects;
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
    function PaletteGroup(C: TClass): TPaletteGroup;
    procedure BuildPalette;
    procedure BuildAddMenu;
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
    function ProjectViewJSON: string;
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
    function GetNamedValues: TObjectList<TNamedStyleValue>;
    function GetValueBindings: TObjectList<TStyleValueBinding>;
    function GetResourceTheme: TResourceTheme;
    property NamedValues: TObjectList<TNamedStyleValue> read GetNamedValues;
    property ResourceTheme: TResourceTheme read GetResourceTheme write SetResourceTheme;
    property ValueBindings: TObjectList<TStyleValueBinding> read GetValueBindings;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseMove(Shift: TShiftState; AFormX, AFormY: Single); override;
    procedure MouseLeave; override;
    function ApplyBitmapLinks(Dialog: TBitmapLinksEditorForm): Boolean;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Messaging, SBD.Localization, SBD.Preview, WinUI3.Style,
  SBD.CollectionDialog, SBD.ValuesDialog, SBD.TextDialog, SBD.GradientDialog,
  SBD.ColorDialog, SBD.StyleCatalogDialog, SBD.Dialogs, WinUI3.Dialogs,
  SBD.StyleTree, SBD.StyleIO, SBD.StyleProperties;

{$R *.fmx}

type
  TControlAccess = class(TControl);

  TComponentAccess = class(TComponent);

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
  if FPreferencesFile.IsEmpty then
    FPreferencesFile := System.IOUtils.TPath.Combine(
      System.IOUtils.TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'StyleBookDesigner'), 'preferences.ini');
  LoadApplicationTheme;
  DocumentLabel.AutoTranslate := False;
  FDocument := TStyleDocument.Create;
  FZoomEffects := TZoomEffects.Create(Self);
  FEntries := TObjectList<TPropertyEntry>.Create;
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
  FPalette.OnMouseDown := PaletteMouseDown;
  BuildPalette;
  BuildAddMenu;
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
  FreeAndNil(FZoomEffects);
  if FDesignViewport <> nil then
    FDesignViewport.Visible := False;
  FTreeModelRoot := nil;
  FDocument.Free;
  FCheckerBitmap.Free;
  FEntries.Free;
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
  BuildPalette;
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

function TFormMain.PaletteGroup(C: TClass): TPaletteGroup;

  function InUnit(const UnitName: string): Boolean;
  var
    Ancestor: TClass;
  begin
    Ancestor := C;
    while Ancestor <> nil do
    begin
      if SameText(Ancestor.UnitName, UnitName) then
        Exit(True);
      Ancestor := Ancestor.ClassParent;
    end;
    Result := False;
  end;

begin
  if C.InheritsFrom(TAnimation) then
    Exit(pgAnimations);
  if C.InheritsFrom(TEffect) then
    Exit(pgEffects);
  if not (C.InheritsFrom(TControl) or C.InheritsFrom(TControl3D)) then
    Exit(pgResources);
  if C.InheritsFrom(TControl3D) or C.InheritsFrom(TViewport3D) then
    Exit(pg3D);
  // Classify specialized families before their generic visual ancestors.
  if InUnit('FMX.Styles.Objects') or InUnit('FMX.Styles.Switch') then
    Exit(pgStyleObjects);
  if InUnit('FMX.Calendar') or InUnit('FMX.CalendarEdit') or InUnit('FMX.DateTimeCtrls') then
    Exit(pgDateTime);
  if InUnit('FMX.Colors') then
    Exit(pgColors);
  if InUnit('FMX.TabControl') or InUnit('FMX.Menus') or InUnit('FMX.Header') then
    Exit(pgNavigation);
  if InUnit('FMX.ListBox') or InUnit('FMX.ListView') or InUnit('FMX.Grid') or
    InUnit('FMX.Grid.Style') or InUnit('FMX.TreeView') or InUnit('FMX.ComboEdit') then
    Exit(pgLists);
  if C.InheritsFrom(TImage) or C.InheritsFrom(TImageControl) or C.InheritsFrom(TGlyph) or
    C.InheritsFrom(TImageViewer) or InUnit('FMX.Media') or InUnit('FMX.WebBrowser') or
    InUnit('FMX.Maps') or InUnit('FMX.MagnifierGlass') or InUnit('FMX.Skia') then
    Exit(pgMedia);
  if C.InheritsFrom(TCustomButton) or C.InheritsFrom(TCheckBox) or
    C.InheritsFrom(TRadioButton) or C.InheritsFrom(TSwitch) then
    Exit(pgButtons);
  if C.InheritsFrom(TCustomEdit) or C.InheritsFrom(TMemo) or C.InheritsFrom(TText) or
    C.InheritsFrom(TLabel) or C.InheritsFrom(TPathLabel) then
    Exit(pgInput);
  if C.InheritsFrom(TTrackBar) or C.InheritsFrom(TScrollBar) or
    C.InheritsFrom(TProgressBar) or C.InheritsFrom(TAniIndicator) or InUnit('FMX.ComboTrackBar') then
    Exit(pgIndicators);
  if InUnit('FMX.Layouts') or InUnit('FMX.BufferedLayout') or InUnit('FMX.MultiView') or
    C.InheritsFrom(TPanel) or C.InheritsFrom(TGroupBox) or C.InheritsFrom(TExpander) or
    C.InheritsFrom(TSplitter) or C.InheritsFrom(TToolBar) or C.InheritsFrom(TStatusBar) then
    Exit(pgLayout);
  if C.InheritsFrom(TShape) or C.InheritsFrom(TPaintBox) or C.InheritsFrom(TPlotGrid) or
    C.InheritsFrom(TSelection) or C.InheritsFrom(TSelectionPoint) then
    Exit(pgShapes);
  Result := pgOther;
end;

procedure TFormMain.BuildPalette;
const
  GroupNames: array[TPaletteGroup] of string = ('Кнопки и переключатели', 'Текст и ввод',
    'Списки и таблицы', 'Вкладки и меню', 'Контейнеры и компоновка', 'Фигуры и рисование',
    'Изображения и мультимедиа', 'Дата и время', 'Выбор цвета', 'Ползунки и индикаторы',
    '3D-компоненты', 'Анимации', 'Эффекты', 'Объекты оформления стиля', 'Ресурсы', 'Прочие компоненты');
var
  C: TFmxObjectClass;
  Category: Integer;
  Query, SelectedClass: string;
  Groups: array[TPaletteGroup] of TStringList;
  Group: TPaletteGroup;
begin
  SelectedClass := '';
  if (FPalette.Selected <> nil) and FPalette.Selected.Selectable then
    SelectedClass := FPalette.Selected.Text;
  Query := FSearch.Text.ToLower;
  Category := FCategory.ItemIndex;
  for Group := Low(TPaletteGroup) to High(TPaletteGroup) do
    Groups[Group] := nil;
  FPalette.BeginUpdate;
  try
    FPalette.Clear;
    for var N in FNames do
    begin
      C := FClasses[N];
      if not Query.IsEmpty and not N.ToLower.Contains(Query) then
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
      Group := PaletteGroup(C);
      if Groups[Group] = nil then
        Groups[Group] := TStringList.Create;
      Groups[Group].Add(N);
    end;
    for Group := Low(TPaletteGroup) to High(TPaletteGroup) do
    begin
      if Groups[Group] = nil then
        Continue;
      var Header := TListBoxGroupHeader.Create(FPalette);
      Header.Text := Translate(GroupNames[Group]);
      Header.Selectable := False;
      Header.CanFocus := False;
      Header.ImageIndex := -1;
      Header.StyledSettings := Header.StyledSettings - [TStyledSetting.Style];
      Header.TextSettings.Font.Style := [TFontStyle.fsBold];
      Header.Parent := FPalette;
      for var N in Groups[Group] do
      begin
        var Item := TListBoxItem.Create(FPalette);
        Item.Text := N;
        Item.ImageIndex := ComponentIcon(FClasses[N]);
        Item.Parent := FPalette;
        if N = SelectedClass then
          FPalette.ItemIndex := Item.Index;
      end;
    end;
  finally
    for Group := Low(TPaletteGroup) to High(TPaletteGroup) do
      Groups[Group].Free;
    FPalette.EndUpdate;
  end;
end;

procedure TFormMain.FilterPalette(Sender: TObject);
begin
  if FBuilding then
    Exit;
  BuildPalette;
end;

procedure TFormMain.BuildAddMenu;
const
  Primitives: array[0..11] of string = ('TRectangle', 'TRoundRect', 'TCalloutRectangle',
    'TCircle', 'TEllipse', 'TLine', 'TArc', 'TPie', 'TPath', 'TText', 'TImage', 'TLayout');

  procedure AddClass(Menu: TMenuItem; const ClassName: string);
  begin
    if not FClasses.ContainsKey(ClassName) then
      Exit;
    var Item := TMenuItem.Create(Menu);
    Item.AutoTranslate := False;
    Item.Text := ClassName;
    Item.TagString := ClassName;
    Item.Tag := acAdd;
    Item.OnClick := ActionClick;
    Item.Parent := Menu;
  end;

begin
  AddPrimitivesMenuButton.Clear;
  AddAnimationsMenuButton.Clear;
  for var ClassName in Primitives do
    AddClass(AddPrimitivesMenuButton, ClassName);
  for var ClassName in FNames do
    if FClasses[ClassName].InheritsFrom(TAnimation) then
      AddClass(AddAnimationsMenuButton, ClassName);
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
        if (Sender is TMenuItem) and not TMenuItem(Sender).TagString.IsEmpty then
          AddObject(TMenuItem(Sender).TagString)
        else
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
          if (FSelected = nil) or (FSelected.Parent <> FDocument.Root) then
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
          FSelected := FDocument.Root;
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
  Result := FDocument.DesignerLayout(CreateIfMissing);
end;

function TFormMain.DesignerJSON: string;
begin
  Result := FDocument.DesignerJSON;
end;

procedure TFormMain.UpdateDesignerMetadata(IncludeView: Boolean);
begin
  if IncludeView then
    FDocument.UpdateDesignerMetadata(ProjectViewJSON)
  else
    FDocument.UpdateDesignerMetadata;
end;

function TFormMain.StyleResourceCount: Integer;
begin
  Result := FDocument.StyleResourceCount;
end;

function TFormMain.FindGroup(const ID: string): TStyleGroup;
begin
  Result := FDocument.FindGroup(ID);
end;

function TFormMain.GroupOf(Resource: TFmxObject): string;
begin
  Result := FDocument.GroupOf(Resource);
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
  FDocument.Groups.Add(Result);
  FSelected := nil;
  FSelectedGroup := Result;
  Changed;
end;

function TFormMain.CanAssignGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string): Boolean;
begin
  Result := FDocument.CanAssignGroup(Obj, StyleGroup, ParentID);
end;

procedure TFormMain.AssignToGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string);
begin
  if not CanAssignGroup(Obj, StyleGroup, ParentID) then
    Exit;
  Remember;
  if StyleGroup <> nil then
    StyleGroup.ParentID := ParentID
  else if ParentID.IsEmpty then
    FDocument.Assignments.Remove(Obj.Name)
  else
  begin
    if (Obj.Name = '') then
      Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
    FDocument.Assignments.AddOrSetValue(Obj.Name, ParentID);
  end;
  FSelected := FDocument.Root;
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
      (not (Model is TFmxObject) or (TFmxObject(Model).Parent <> FDocument.Root)) then
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
  for var StyleGroup in FDocument.Groups do
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
  for var Child in ChildrenOf(FDocument.Root) do
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
    if Obj.Parent = FDocument.Root then
      Exit(CanAssignGroup(Obj, nil, ParentID) or
        (AllowUnchanged and not SameText(Obj.StyleName, '#designer') and (GroupOf(Obj) = ParentID)));
    Exit((Obj <> FDocument.Root) and ((Obj is TControl) or (Obj is TControl3D)));
  end;
  if not (SourceItem.TagObject is TFmxObject) or not (DestItem.TagObject is TFmxObject) then
    Exit;
  Obj := TFmxObject(SourceItem.TagObject);
  Target := TFmxObject(DestItem.TagObject);
  if (Obj = FDocument.Root) or SameText(Obj.StyleName, '#designer') or SameText(Target.StyleName, '#designer') then
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
    Target := FDocument.Root;
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
      if Target = FDocument.Root then
      begin
        var Name := Obj.StyleName;
        if Name.IsEmpty then
          Name := Copy(Obj.ClassName, 2, MaxInt).ToLower + 'style';
        Obj.StyleName := UniqueStyleName(Name);
      end;
      Obj.Parent := Target;
      FDesignDirty := True;
    end;
    FDocument.Assignments.Remove(Obj.Name);
    if (Target = FDocument.Root) and not ParentID.IsEmpty then
    begin
      if Obj.Name = '' then
        Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
      FDocument.Assignments.AddOrSetValue(Obj.Name, ParentID);
    end;
  end;
  // Reselecting a moved row would make FMX expand the destination group.
  FSelected := FDocument.Root;
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
    for var StyleGroup in FDocument.Groups do
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
  if (FDocument.Root = nil) or StyleName.IsEmpty or SameText(StyleName, '#designer') then
    Exit;
  for var Resource in ChildrenOf(FDocument.Root) do
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
    (FSelected <> FDocument.Root) and (FSelected.Parent = FDocument.Root) and
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
      for var Resource in ChildrenOf(FDocument.Root) do
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
  var IsResource := (FSelected <> nil) and (FSelected.Parent = FDocument.Root);
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
  DuplicateButton.Enabled := (FSelected <> nil) and (FSelected <> FDocument.Root);
  CopyObjectButton.Enabled := DuplicateButton.Enabled;
  PasteObjectButton.Enabled := (FSelected = nil) or (FSelected = FDocument.Root) or
    (FSelected is TControl) or (FSelected is TControl3D);
  AddObjectMenuButton.Enabled := not Multiple and PasteObjectButton.Enabled;
  AddAnimationsMenuButton.Enabled := AddObjectMenuButton.Enabled and
    (FSelected <> nil) and (FSelected <> FDocument.Root);
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
      else if (Model is TFmxObject) and (TFmxObject(Model).Parent = FDocument.Root) then
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
          while (Resource.Parent <> nil) and (Resource.Parent <> FDocument.Root) do
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
      if (FSelectedGroup <> nil) or ((FSelected <> nil) and (FSelected.Parent = FDocument.Root)) then
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
        for var StyleGroup in FDocument.Groups do
          if StyleGroup.ParentID = ID then
            StyleGroup.ParentID := ParentID;
        for var Key in FDocument.Assignments.Keys.ToArray do
          if FDocument.Assignments[Key] = ID then
            if ParentID.IsEmpty then
              FDocument.Assignments.Remove(Key)
            else
              FDocument.Assignments.AddOrSetValue(Key, ParentID);
        var StyleGroup := FSelectedGroup;
        FSelectedGroup := nil;
        FSelected := FDocument.Root;
        FDocument.Groups.Remove(StyleGroup);
        Changed;
      end;
    acUp, acDown:
      if FSelectedGroup <> nil then
      begin
        Index := FDocument.Groups.IndexOf(FSelectedGroup);
        Other := Index;
        repeat
          if Action = acUp then
            Dec(Other)
          else
            Inc(Other);
        until (Other < 0) or (Other >= FDocument.Groups.Count) or (FDocument.Groups[Other].ParentID = FSelectedGroup.ParentID);
        if (Other >= 0) and (Other < FDocument.Groups.Count) then
        begin
          Remember;
          FDocument.Groups.Exchange(Index, Other);
          Changed;
        end;
      end;
  end;
end;

procedure TFormMain.ApplyProjectView;
var
  JSON: TJSONObject;
begin
  if FDocument.PendingView.IsEmpty then
    Exit;
  FTreeViewportRestorePending := False;
  JSON := TJSONObject.ParseJSONValue(FDocument.PendingView) as TJSONObject;
  FDocument.PendingView := '';
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
    if (AObject.Parent <> FDocument.Root) and (AParent is TTreeViewItem) then
      Item.TagString := AParent.TagString + '/' + Item.TagString;
  end;
  var Children := EditableChildren(AObject);
  // Streaming overrides can enumerate children in a different order. The tree
  // must follow the model Index, which also determines FMX Z-order.
  if Length(Children) > 1 then
    TArray.Sort<TFmxObject>(Children, TComparer<TFmxObject>.Construct(
      function(const Left, Right: TFmxObject): Integer
      begin
        Result := CompareValue(Left.Index, Right.Index);
      end));
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
  SameModel := FTreeModelRoot = FDocument.Root;
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
        for var StyleGroup in FDocument.Groups do
          Desired.AddOrSetValue(Pointer(StyleGroup), True);
        for var Child in ChildrenOf(FDocument.Root) do
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
      FTreeModelRoot := FDocument.Root;
      if (FDocument.Root <> nil) and not SameModel then
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
    FSelected := FDocument.Root;
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
begin
  if AFilter then
    CollectStyleProperties(FEntries, AInstance, APrefix, ADepth, FPropertySearch.Text)
  else
    CollectStyleProperties(FEntries, AInstance, APrefix, ADepth);
end;

function TFormMain.PropertyText(AEntry: TPropertyEntry): string;
begin
  Result := StylePropertyText(AEntry);
end;

procedure TFormMain.SetPropertyText(AEntry: TPropertyEntry; const AText: string);
begin
  SetStylePropertyText(FDocument.Root, FSelected, AEntry, AText);
end;

procedure TFormMain.BuildProperties;
begin
  FTreeViewportRestorePending := False;
  FRefreshTimer.Enabled := FTreeRefreshPending;
  FBuilding := True;
  try
    FEntries.Clear;
    if FSelected <> FDocument.Root then
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
  for var Binding in FDocument.ValueBindings do
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
    if not ((Copy is TEffect) and (FZoomPercent > MaxEffectsZoom) and
      ((Entry.Prop.Name = 'Enabled') or (Entry.Prop.Name = 'Trigger'))) then
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
    FZoomEffects.Apply(FDesignRoot, FZoomPercent, True);
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
    for var Binding in FDocument.ValueBindings do
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
      for var Binding in FDocument.ValueBindings do
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

procedure TFormMain.PaletteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;
  var Item := FPalette.ItemByPoint(X, Y);
  // A heading must not activate a component left selected by a previous click.
  if (Item = nil) or not Item.Selectable then
    FPalette.ItemIndex := -1;
end;

procedure TFormMain.PaletteDblClick(Sender: TObject);
begin
  if FBuilding then
    Exit;
  if (FPalette.Selected <> nil) and FPalette.Selected.Selectable then
  try
    AddObject(FPalette.Items[FPalette.ItemIndex]);
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

procedure TFormMain.ApplyTextPlaceholders(Obj: TFmxObject);
begin
  SBD.StyleIO.ApplyTextPlaceholders(Obj);
end;

procedure TFormMain.WriteStyleStream(Stream: TStream; Format: TStyleFormat);
begin
  SBD.StyleIO.WriteStyleStream(FDocument.Root, Stream, Format);
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
    while (R.Parent <> nil) and (R.Parent <> FDocument.Root) do
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
  if (FSelected = nil) or (FSelected = FDocument.Root) then
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
  while (R.Parent <> nil) and (R.Parent <> FDocument.Root) do
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
    FZoomEffects.Apply(FDesignRoot, FZoomPercent, True);
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
    ResourceThemeBox.ItemIndex := Ord(FDocument.ResourceTheme);
    if FBackgroundMode.ItemIndex <> 2 then
      FBackgroundMode.ItemIndex := Ord(FDocument.ResourceTheme);
  finally
    FBuilding := WasBuilding;
  end;
  UpdateWorkspaceBackground;
end;

procedure TFormMain.SetResourceTheme(Value: TResourceTheme);
var
  State: TBytes;
begin
  if Value = FDocument.ResourceTheme then
    Exit;
  for var Resource in FDocument.NamedValues do
    ValidateNamedValue(Resource);
  for var Binding in FDocument.ValueBindings do
  begin
    var Resource := FindValue(Binding.ResourceName);
    if Resource <> nil then
      ValidateBinding(Resource, Binding);
  end;
  State := Snapshot;
  try
    FDocument.ResourceTheme := Value;
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
    FZoomEffects.Apply(FDesignRoot, FZoomPercent, True);
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
begin
  Result := SBD.StyleProperties.IsStyleProperty(Instance, Prop);
end;

function TFormMain.ProjectViewJSON: string;
var
  View: TJSONObject;
  Expanded: TJSONArray;
begin
  View := TJSONObject.Create;
  try
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
    Result := View.ToJSON;
  finally
    View.Free;
  end;
end;

function TFormMain.MetadataJSON(IncludeView: Boolean): string;
begin
  if IncludeView then
    Result := FDocument.MetadataJSON(ProjectViewJSON)
  else
    Result := FDocument.MetadataJSON;
end;

procedure TFormMain.LoadMetadata(const Text: string);
begin
  FSelectedGroup := nil;
  FPreviewSource := nil;
  FDocument.LoadMetadata(Text);
  UpdateValueReferences;
  SyncResourceThemeView;
end;

function TFormMain.GetNamedValues: TObjectList<TNamedStyleValue>;
begin
  Result := FDocument.NamedValues;
end;

function TFormMain.GetValueBindings: TObjectList<TStyleValueBinding>;
begin
  Result := FDocument.ValueBindings;
end;

function TFormMain.GetResourceTheme: TResourceTheme;
begin
  Result := FDocument.ResourceTheme;
end;

function TFormMain.FindValue(const Name: string): TNamedStyleValue;
begin
  Result := FDocument.FindValue(Name);
end;

function TFormMain.FindNamedObject(const Name: string): TFmxObject;
begin
  Result := FDocument.FindNamedObject(Name);
end;

function TFormMain.ResolveProperty(Obj: TFmxObject; const Path: string): TPropertyEntry;
begin
  Result := ResolveStyleProperty(Obj, Path);
end;

procedure TFormMain.ValidateNamedValue(Value: TNamedStyleValue);
begin
  FDocument.ValidateNamedValue(Value);
end;

procedure TFormMain.ValidateBinding(Value: TNamedStyleValue; Binding: TStyleValueBinding);
begin
  FDocument.ValidateBinding(Value, Binding);
end;

procedure TFormMain.ApplyBindings;
begin
  FDocument.ApplyBindings(FSelected);
end;

procedure TFormMain.UpdateValueReferences;
begin
  FValueReference.Items.Clear;
  for var Value in FDocument.NamedValues do
    FValueReference.Items.Add(Value.Name);
  if FDocument.NamedValues.Count > 0 then
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
  for var Binding in FDocument.ValueBindings do
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
    for var I := FDocument.ValueBindings.Count - 1 downto 0 do
      if (FDocument.ValueBindings[I].TargetName = FSelected.Name) and
        (FDocument.ValueBindings[I].PropertyPath = Entry.Path) then
        FDocument.ValueBindings.Delete(I);
    Binding := TStyleValueBinding.Create;
    Binding.TargetName := FSelected.Name;
    Binding.PropertyPath := Entry.Path;
    Binding.ResourceName := FValueReference.Items[FValueReference.ItemIndex];
    FDocument.ValueBindings.Add(Binding);
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
  for var I := FDocument.ValueBindings.Count - 1 downto 0 do
    if (FDocument.ValueBindings[I].TargetName = FSelected.Name) and (FDocument.ValueBindings[I].PropertyPath = Path) then
    begin
      Remember;
      FDocument.ValueBindings.Delete(I);
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
    TStyleStreaming.SaveToStream(FDocument.Root, Style, TStyleFormat.Binary);
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
  FDocument.Root.Free;
  FDocument.Root := Root;
  SetModelDesigning(FDocument.Root);
  FPreviewDirty := True;
  FSelected := FDocument.Root;
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
  Caption := N + ' - StyleBook Designer';
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
  FreeAndNil(FDocument.Root);
  FDocument.Root := TStyleContainer.Create(nil);
  SetModelDesigning(FDocument.Root);
  FPreviewDirty := True;
  FSelected := FDocument.Root;
  FFileName := '';
  FSelectedGroup := nil;
  FDocument.Groups.Clear;
  FDocument.Assignments.Clear;
  FDocument.StyleClasses.Clear;
  FPreviewSource := nil;
  FDocument.NamedValues.Clear;
  FDocument.ValueBindings.Clear;
  FDocument.ResourceTheme := rtLight;
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
  PreviousRoot := FDocument.Root;
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
  FDocument.Root := Root;
  SetModelDesigning(FDocument.Root);
  FPreviewDirty := True;
  FSelected := FDocument.Root;
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
    FDocument.Root.Free;
    FDocument.Root := PreviousRoot;
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
  if (FSelected = nil) or (FSelected = FDocument.Root) then
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
  if (FSelected = nil) or (FSelected = FDocument.Root) then
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
    Parent := FDocument.Root;
  if not ((Parent = FDocument.Root) or (Parent is TControl) or (Parent is TControl3D)) then
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
      if (Parent = FDocument.Root) and ((Child is TAnimation) or (Child is TEffect)) then
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
      if Parent = FDocument.Root then
      begin
        var StyleName := Obj.StyleName;
        if StyleName.IsEmpty then
          StyleName := Obj.ClassName.Substring(1) + 'style';
        Obj.StyleName := UniqueStyleName(StyleName);
      end;
      Obj.Parent := Parent;
      Objects.Extract(Obj);
      if (Parent = FDocument.Root) and (FSelectedGroup <> nil) then
      begin
        Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FDocument.Assignments.AddOrSetValue(Obj.Name, FSelectedGroup.ID);
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
  Desired := ChildrenOf(FDocument.Root);
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
        FDocument.Groups.Add(Group);
        GroupID := Group.ID;
      end;
      var Main := Plan.Main;
      while Plan.Resources.Count > 0 do
      begin
        var Obj := Plan.Resources[0];
        SetModelDesigning(Obj);
        Obj.Parent := FDocument.Root;
        Plan.Resources.Extract(Obj);
        if not GroupID.IsEmpty then
        begin
          Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
          FDocument.Assignments.AddOrSetValue(Obj.Name, GroupID);
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
    for Child in ChildrenOf(FDocument.Root) do
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
    Parent := FDocument.Root;
  if not ((Parent = FDocument.Root) or (Parent is TControl) or (Parent is TControl3D)) then
    raise Exception.Create(Translate('Выберите визуальный родительский объект в дереве.'));
  if (Parent = FDocument.Root) and (C.InheritsFrom(TAnimation) or C.InheritsFrom(TEffect)) then
    raise Exception.Create(Translate('Анимацию или эффект нужно добавить в визуальный ресурс.'));
  Obj := C.Create(nil);
  try
    if Parent = FDocument.Root then
      Obj.StyleName := UniqueStyleName(AClassName.Substring(1) + 'style')
    else
      Obj.StyleName := AClassName.Substring(1).ToLower;
    if Obj is TControl then
    begin
      TControl(Obj).SetBounds(10, 10, 160, 40);
      TControl(Obj).HitTest := False;
      if Parent = FDocument.Root then
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
    if (Parent = FDocument.Root) and (FSelectedGroup <> nil) then
    begin
      Obj.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
      FDocument.Assignments.AddOrSetValue(Obj.Name, FSelectedGroup.ID);
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
  for var I := FDocument.ValueBindings.Count - 1 downto 0 do
    if (FDocument.ValueBindings[I].TargetName = Obj.Name) and (FDocument.ValueBindings[I].PropertyPath = Path) then
      FDocument.ValueBindings.Delete(I);
end;

procedure TFormMain.RemoveObjectBindings(Obj: TFmxObject);
begin
  FDocument.StyleClasses.Remove(Obj.Name);
  for var I := FDocument.ValueBindings.Count - 1 downto 0 do
    if FDocument.ValueBindings[I].TargetName = Obj.Name then
      FDocument.ValueBindings.Delete(I);
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
      else if (FSelected <> nil) and (FSelected <> FDocument.Root) then
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
  FSelected := FDocument.Root;
  FSelectedGroup := nil;
  for var Model in Models do
    if Model is TStyleGroup then
    begin
      var Group := TStyleGroup(Model);
      for var Child in FDocument.Groups do
        if Child.ParentID = Group.ID then
          Child.ParentID := Group.ParentID;
      for var Key in FDocument.Assignments.Keys.ToArray do
        if FDocument.Assignments[Key] = Group.ID then
          if Group.ParentID.IsEmpty then
            FDocument.Assignments.Remove(Key)
          else
            FDocument.Assignments.AddOrSetValue(Key, Group.ParentID);
      FDocument.Groups.Remove(Group);
    end
    else if (Model is TFmxObject) and (Model <> FDocument.Root) then
    begin
      RemoveObjectBindings(TFmxObject(Model));
      FDocument.Assignments.Remove(TFmxObject(Model).Name);
      Model.Free;
    end;
  Changed;
end;

procedure TFormMain.DeleteObject;
var
  Parent: TFmxObject;
begin
  if (FSelected = nil) or (FSelected = FDocument.Root) then
    Exit;
  Remember;
  Parent := EditableParent(FSelected);
  FreeAndNil(FDesignRoot);
  FDesignViewport.Visible := False;
  FProperties.Clear;
  FEntries.Clear;
  RemoveObjectBindings(FSelected);
  FDocument.Assignments.Remove(FSelected.Name);
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
  if (FSelected = nil) or (FSelected = FDocument.Root) then
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
      if Original.Parent = FDocument.Root then
        Copy.StyleName := UniqueStyleName(Original.StyleName + '_copy');
      Copy.Parent := Original.Parent;
      Copy.Index := Original.Index + 1;
      Copies.Extract(Copy);
      Created.Add(Copy);
      var AssignedClass := AssignedStyleClass(Original);
      if not AssignedClass.IsEmpty then
      begin
        Copy.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FDocument.StyleClasses.AddOrSetValue(Copy.Name, AssignedClass);
      end;
      var GroupID := GroupOf(Original);
      if not GroupID.IsEmpty then
      begin
        if AssignedClass.IsEmpty then
          Copy.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
        FDocument.Assignments.AddOrSetValue(Copy.Name, GroupID);
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
  if (FSelected = nil) or (FSelected = FDocument.Root) then
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
        if (Parent = FDocument.Root) and SameText(Parent.Children[MoveIndex].StyleName, '#designer') then
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
              ((Parent <> FDocument.Root) or (not SameText(Parent.Children[MoveIndex].StyleName, '#designer') and
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
        if Parent = FDocument.Root then
        begin
          var StyleGroup := FindGroup(GroupOf(FSelected));
          if StyleGroup <> nil then
            AssignToGroup(FSelected, nil, StyleGroup.ParentID);
          Exit;
        end;
        Parent := EditableParent(FSelected);
        Target := EditableParent(Parent);
        if (Target = FDocument.Root) and not ((FSelected is TControl) or (FSelected is TControl3D)) then
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
        if Target = FDocument.Root then
          FSelected.StyleName := UniqueStyleName(FSelected.StyleName + 'style');
      end;
  end;
  if FSelected.Parent <> FDocument.Root then
    FDocument.Assignments.Remove(FSelected.Name);
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
  FDocument.Root.Free;
  FDocument.Root := Root;
  SetModelDesigning(FDocument.Root);
  FPreviewDirty := True;
  FSelected := FDocument.Root;
  FFileName := '';
  FSelectedGroup := nil;
  FDocument.Groups.Clear;
  FDocument.Assignments.Clear;
  FDocument.StyleClasses.Clear;
  FPreviewSource := nil;
  FDocument.NamedValues.Clear;
  FDocument.ValueBindings.Clear;
  UpdateValueReferences;
  RebuildTree;
  ClearHistory;
  FSavedState := nil;
  FDocument.ResourceTheme := rtLight;
  SyncResourceThemeView;
  Changed(False);
end;

function TFormMain.SelectedStyleRoot: TFmxObject;
begin
  Result := FSelected;
  if (Result = nil) or (Result = FDocument.Root) then
    Exit(nil);
  while (Result.Parent <> nil) and (Result.Parent <> FDocument.Root) do
    Result := Result.Parent;
  if (Result.Parent <> FDocument.Root) or SameText(Result.StyleName, '#designer') then
    Result := nil;
end;

function TFormMain.AssignedStyleClass(Resource: TFmxObject): string;
begin
  Result := '';
  if (Resource <> nil) and (Resource.Parent = FDocument.Root) then
    FDocument.StyleClasses.TryGetValue(Resource.Name, Result);
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
    FDocument.StyleClasses.Remove(Resource.Name)
  else
  begin
    if Resource.Name = '' then
      Resource.Name := 'SBD_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '_');
    FDocument.StyleClasses.AddOrSetValue(Resource.Name, ClassName);
  end;
end;

procedure TFormMain.AssignStyleClass(Resource: TFmxObject; const ClassName: string);
begin
  if (Resource = nil) or (Resource.Parent <> FDocument.Root) or SameText(Resource.StyleName, '#designer') then
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
    for Child in ChildrenOf(FDocument.Root) do
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
    var Dialog := TBitmapLinksEditorForm.CreateEditor(Self, FSelected, FDocument.Root, Links, Path, Background);
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
      for var I := FDocument.ValueBindings.Count - 1 downto 0 do
        if (FDocument.ValueBindings[I].TargetName = FSelected.Name) and
          ((FDocument.ValueBindings[I].PropertyPath = Path) or FDocument.ValueBindings[I].PropertyPath.StartsWith(Path + '.') or
          FDocument.ValueBindings[I].PropertyPath.StartsWith(Path + '[')) then
          FDocument.ValueBindings.Delete(I);
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
  Dialog := TNamedValuesDialog.CreateEditor(Self, FDocument);
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
      FDocument.NamedValues.Clear;
      while Dialog.Values.Count > 0 do
        FDocument.NamedValues.Add(Dialog.Values.Extract(Dialog.Values[0]));
      FDocument.ValueBindings.Clear;
      while Dialog.Bindings.Count > 0 do
        FDocument.ValueBindings.Add(Dialog.Bindings.Extract(Dialog.Bindings[0]));
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

end.


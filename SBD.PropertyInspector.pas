unit SBD.PropertyInspector;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Rtti,
  System.TypInfo, System.Math, System.Generics.Collections,
  System.Generics.Defaults, FMX.Types, FMX.Controls, FMX.Layouts, FMX.TreeView,
  FMX.StdCtrls, FMX.Edit, FMX.ListBox, FMX.Objects, FMX.Graphics,
  FMX.Controls.Presentation, FMX.ComboEdit, FMX.BehaviorManager, FMX.ScrollBox;

type
  TSBDTreeViewItem = class(TTreeViewItem)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Inflate; override;
  end;

  TInspectorEditorKind = (iekGroup, iekText, iekNumber, iekBoolean, iekEnumeration,
    iekSet, iekSetMember, iekColor, iekStrings, iekBitmap, iekCollection, iekFont,
    iekPath, iekFontFamily, iekGradient);

  TInspectorProperty = class
  public
    Instance: TObject;
    Prop: TRttiProperty;
    Path, WritePath, Caption, BindingName: string;
    Kind: TInspectorEditorKind;
    MemberOrdinal: Integer;
    ReadOnly: Boolean;
    Item: TTreeViewItem;
    Editor: TControl;
    Swatch: TRectangle;
    Choices: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

  TInspectorFilterEvent = procedure(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean) of object;

  TInspectorWriteEvent = procedure(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string) of object;

  TInspectorEditEvent = procedure(Sender: TObject; PropertyInfo: TInspectorProperty) of object;

  TInspectorBindingEvent = procedure(Sender: TObject; const Path: string; var ResourceName: string) of object;

  TSBDPropertyInspector = class(TLayout)
  private
    FTree: TTreeView;
    FHeader: TLayout;
    FNameHeader, FValueHeader, FError: TLabel;
    FColumnSplitter: TSplitter;
    FNodes: TObjectList<TInspectorProperty>;
    FExpanded: TDictionary<string, Boolean>;
    FInstance: TObject;
    FFilterText, FEmptyTextPlaceholder: string;
    FUpdating, FSkipSaveView, FReuseStructure, FVirtualEditors: Boolean;
    FNameColumnRatio: Single;
    FContext: TRttiContext;
    FOnFilter: TInspectorFilterEvent;
    FOnWrite: TInspectorWriteEvent;
    FOnEdit: TInspectorEditEvent;
    FOnSelectionChange: TNotifyEvent;
    FOnBinding: TInspectorBindingEvent;
    procedure AddInstance(Instance: TObject; Parent: TFmxObject; const Prefix: string; Depth: Integer; Ancestors: TList<TObject>);
    function AddNode(Instance: TObject; Prop: TRttiProperty; Parent: TFmxObject; const Path, Caption: string; Kind: TInspectorEditorKind): TInspectorProperty;
    procedure CreateEditor(Node: TInspectorProperty);
    procedure EditorEnter(Sender: TObject);
    procedure TextExit(Sender: TObject);
    procedure EditKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure ChoiceChange(Sender: TObject);
    procedure ComboResize(Sender: TObject);
    procedure CheckChange(Sender: TObject);
    procedure WizardClick(Sender: TObject);
    procedure TreeChange(Sender: TObject);
    procedure LayoutEditors(Sender: TObject);
    procedure PropertyItemStyleApplied(Sender: TObject);
    procedure SetFilterText(const Value: string);
    procedure SetEmptyTextPlaceholder(const Value: string);
    procedure SetNameColumnRatio(const Value: Single);
    function GetSelectedProperty: TInspectorProperty;
    function MatchFilter(Item: TTreeViewItem): Boolean;
    procedure SaveViewState;
    procedure ColumnDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    function DialogOwner: TComponent;
    function KindOf(Instance: TObject; Prop: TRttiProperty): TInspectorEditorKind;
    procedure SetDefaultValue(Node: TInspectorProperty; const Text: string);
    procedure ResetEditor(Node: TInspectorProperty);
    function Rebind(Instance: TObject): Boolean;
    function FindNode(const Path: string): TInspectorProperty;
    procedure NodePainting(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Inspect(Instance: TObject);
    procedure Clear;
    procedure Refresh;
    procedure RefreshValues;
    procedure RefreshLanguage;
    function FindProperty(const Path: string): TInspectorProperty;
    procedure SelectPath(const Path: string);
    procedure WriteProperty(const Path, Text: string);
    procedure EditValue(const Path: string; UseHostEditor: Boolean = True);
    function ValueText(Node: TInspectorProperty): string;
    property VirtualEditors: Boolean read FVirtualEditors write FVirtualEditors;
    property ReuseStructure: Boolean read FReuseStructure write FReuseStructure;
    property InspectedObject: TObject read FInstance;
    property SelectedProperty: TInspectorProperty read GetSelectedProperty;
    property Tree: TTreeView read FTree;
    property EmptyTextPlaceholder: string read FEmptyTextPlaceholder write SetEmptyTextPlaceholder;
    property FilterText: string read FFilterText write SetFilterText;
    property NameColumnRatio: Single read FNameColumnRatio write SetNameColumnRatio;
    property OnFilterProperty: TInspectorFilterEvent read FOnFilter write FOnFilter;
    property OnWriteProperty: TInspectorWriteEvent read FOnWrite write FOnWrite;
    property OnEditProperty: TInspectorEditEvent read FOnEdit write FOnEdit;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnBindingName: TInspectorBindingEvent read FOnBinding write FOnBinding;
  end;

procedure EnableSmoothScrolling(Obj: TFmxObject);

implementation

uses
  FMX.Forms, FMX.Dialogs, SBD.Dialogs, SBD.ColorDialog, SBD.TextDialog,
  SBD.GradientDialog;

type
  TSmoothScrollAccess = class(TCustomPresentedScrollBox);

constructor TSBDTreeViewItem.Create(AOwner: TComponent);
begin
  inherited;
  AutoTranslate := False;
  StyleLookup := 'treeviewitemstyle';
  CustomChildrenOffset := 20;
end;

procedure TSBDTreeViewItem.Inflate;
begin
  if not IsNeedStyleLookup then
    Exit;
  var Tree := TreeView;
  // FMX requests inflation for every expanded row on every layout. Fixed row
  // heights let offscreen rows wait until Painting applies their native style.
  if (Tree <> nil) and (Tree.ItemHeight > 0) then
  begin
    var Y := GlobalIndex * Tree.ItemHeight - Tree.ViewportPosition.Y;
    if (Y + Tree.ItemHeight < -Tree.ItemHeight) or (Y > Tree.Height + Tree.ItemHeight) then
      Exit;
  end;
  inherited;
end;

procedure EnableSmoothScrolling(Obj: TFmxObject);
begin
  if Obj is TCustomTreeView then
    TTreeView(Obj).ScrollAnimation := TBehaviorBoolean.True;
  if Obj is TCustomListBox then
    TListBox(Obj).ScrollAnimation := TBehaviorBoolean.True;
  if Obj is TCustomComboBox then
    TCustomComboBox(Obj).ListBox.ScrollAnimation := TBehaviorBoolean.True;
  if Obj is TCustomPresentedScrollBox then
    TSmoothScrollAccess(Obj).ScrollAnimation := TBehaviorBoolean.True;
  if Obj is TScrollBox then
    TScrollBox(Obj).ScrollAnimation := TBehaviorBoolean.True;
  for var I := 0 to Obj.ChildrenCount - 1 do
    EnableSmoothScrolling(Obj.Children[I]);
end;

type
  TInspectorCollectionEditor = class(TAppDialogForm)
  private
    FValue: TCollection;
    FList: TListBox;
    FInspector: TSBDPropertyInspector;
    FLoading: Boolean;
    procedure SelectionChange(Sender: TObject);
    procedure CollectionAction(Sender: TObject);
    procedure UpdateItems;
  public
    constructor CreateEditor(AOwner: TComponent; Source: TCollection; const EmptyTextPlaceholder: string = '');
    destructor Destroy; override;
    property Value: TCollection read FValue;
  end;

procedure DialogChrome(Dialog: TForm; const Title: string);
var
  Bar: TPanel;
  Button: TButton;
  LabelControl: TLabel;
begin
  Dialog.Width := 800;
  Dialog.Height := 600;
  Dialog.Position := TFormPosition.OwnerFormCenter;
  Dialog.Caption := Title;
  if Dialog.Owner is TForm then
    Dialog.StyleBook := TForm(Dialog.Owner).StyleBook;
  LabelControl := TLabel.Create(Dialog);
  LabelControl.Parent := Dialog;
  LabelControl.Align := TAlignLayout.Top;
  LabelControl.Height := 64;
  LabelControl.Margins.Left := 24;
  LabelControl.Text := Title;
  LabelControl.StyledSettings := [TStyledSetting.FontColor];
  LabelControl.TextSettings.Font.Size := 20;
  LabelControl.TextSettings.Font.Style := [TFontStyle.fsBold];
  Bar := TPanel.Create(Dialog);
  Bar.StyleLookup := 'panelstyle_fill_strong_dialog';
  Bar.Parent := Dialog;
  Bar.Align := TAlignLayout.Bottom;
  Bar.Height := 88;
  Bar.Padding.Rect := RectF(24, 24, 24, 24);
  Button := TButton.Create(Dialog);
  Button.Parent := Bar;
  Button.Align := TAlignLayout.Right;
  Button.Width := 112;
  Button.Text := Translate('Отмена');
  Button.Cancel := True;
  Button.ModalResult := mrCancel;
  Button := TButton.Create(Dialog);
  Button.Parent := Bar;
  Button.Align := TAlignLayout.Right;
  Button.Width := 120;
  Button.Margins.Right := 8;
  Button.Text := Translate('Применить');
  Button.StyleLookup := 'buttonstyle_accent';
  Button.ModalResult := mrOk;
  Button.Default := True;
end;

constructor TInspectorCollectionEditor.CreateEditor(AOwner: TComponent; Source: TCollection; const EmptyTextPlaceholder: string);
var
  Bar: TLayout;
  Button: TButton;
begin
  inherited CreateNew(AOwner);
  FLoading := True;
  FValue := TCollection.Create(Source.ItemClass);
  FValue.Assign(Source);
  DialogChrome(Self, Translate('Коллекция'));
  Bar := TLayout.Create(Self);
  Bar.Parent := Self;
  Bar.Align := TAlignLayout.Top;
  Bar.Position.Y := 64;
  Bar.Height := 48;
  Bar.Padding.Left := 24;
  for var I := 1 to 2 do
  begin
    Button := TButton.Create(Self);
    Button.Parent := Bar;
    Button.Align := TAlignLayout.Left;
    Button.Position.X := I * 120;
    Button.Width := 104;
    Button.Margins.Rect := RectF(0, 8, 8, 8);
    if I = 1 then
      Button.Text := Translate('Добавить')
    else
      Button.Text := Translate('Удалить');
    Button.Tag := I;
    Button.OnClick := CollectionAction;
  end;
  FList := TListBox.Create(Self);
  FList.ScrollAnimation := TBehaviorBoolean.True;
  FList.Parent := Self;
  FList.Align := TAlignLayout.Left;
  FList.Width := 220;
  FList.Margins.Left := 24;
  FList.OnChange := SelectionChange;
  FInspector := TSBDPropertyInspector.Create(Self);
  FInspector.EmptyTextPlaceholder := EmptyTextPlaceholder;
  FInspector.Parent := Self;
  FInspector.Align := TAlignLayout.Client;
  FInspector.Margins.Right := 24;
  FLoading := False;
  UpdateItems;
end;

destructor TInspectorCollectionEditor.Destroy;
begin
  FLoading := True;
  if FList <> nil then
    FList.OnChange := nil;
  FreeAndNil(FInspector);
  FValue.Free;
  inherited;
end;

procedure TInspectorCollectionEditor.UpdateItems;
var
  Index: Integer;
begin
  Index := FList.ItemIndex;
  FLoading := True;
  try
    FList.Items.Clear;
    for var I := 0 to FValue.Count - 1 do
      FList.Items.Add(I.ToString + ': ' + FValue.Items[I].DisplayName);
    if FValue.Count > 0 then
      FList.ItemIndex := EnsureRange(Index, 0, FValue.Count - 1);
  finally
    FLoading := False;
  end;
  SelectionChange(nil);
end;

procedure TInspectorCollectionEditor.SelectionChange(Sender: TObject);
begin
  if FLoading then
    Exit;
  if FList.ItemIndex >= 0 then
    FInspector.Inspect(FValue.Items[FList.ItemIndex])
  else
    FInspector.Clear;
end;

procedure TInspectorCollectionEditor.CollectionAction(Sender: TObject);
begin
  FInspector.Clear;
  if TComponent(Sender).Tag = 1 then
    FValue.Add
  else if FList.ItemIndex >= 0 then
    FValue.Items[FList.ItemIndex].Free;
  UpdateItems;
end;

constructor TInspectorProperty.Create;
begin
  inherited;
  Choices := TStringList.Create;
end;

destructor TInspectorProperty.Destroy;
begin
  Choices.Free;
  inherited;
end;

constructor TSBDPropertyInspector.Create(AOwner: TComponent);
begin
  inherited;
  FContext := TRttiContext.Create;
  FNodes := TObjectList<TInspectorProperty>.Create;
  FExpanded := TDictionary<string, Boolean>.Create;
  FNameColumnRatio := 0.46;
  FHeader := TLayout.Create(Self);
  FHeader.Parent := Self;
  FHeader.Align := TAlignLayout.Top;
  FHeader.Height := 32;
  FNameHeader := TLabel.Create(Self);
  FNameHeader.Parent := FHeader;
  FNameHeader.Align := TAlignLayout.Left;
  FNameHeader.Margins.Left := 8;
  FNameHeader.Text := Translate('Свойство');
  FNameHeader.StyledSettings := FNameHeader.StyledSettings - [TStyledSetting.Other];
  FNameHeader.TextSettings.Trimming := TTextTrimming.Character;
  FColumnSplitter := TSplitter.Create(Self);
  FColumnSplitter.ShowGrip := False;
  FColumnSplitter.Parent := FHeader;
  FColumnSplitter.Align := TAlignLayout.Left;
  FColumnSplitter.Position.X := 10000;
  FColumnSplitter.Width := 4;
  FColumnSplitter.OnMouseUp := ColumnDrag;
  FValueHeader := TLabel.Create(Self);
  FValueHeader.Parent := FHeader;
  FValueHeader.Align := TAlignLayout.Client;
  FValueHeader.Text := Translate('Значение');
  FError := TLabel.Create(Self);
  FError.Parent := Self;
  FError.Align := TAlignLayout.Bottom;
  FError.Height := 48;
  FError.WordWrap := True;
  FError.Visible := False;
  FTree := TTreeView.Create(Self);
  FTree.Parent := Self;
  FTree.Align := TAlignLayout.Client;
  FTree.ItemHeight := 36;
  FTree.ScrollAnimation := TBehaviorBoolean.True;
  FTree.OnChange := TreeChange;
  FTree.OnResize := LayoutEditors;
  OnResize := LayoutEditors;
end;

destructor TSBDPropertyInspector.Destroy;
begin
  FUpdating := True;
  OnResize := nil;
  FTree.OnChange := nil;
  FTree.OnResize := nil;
  FreeAndNil(FTree);
  FNodes.Free;
  FExpanded.Free;
  FContext.Free;
  inherited;
end;

function TSBDPropertyInspector.KindOf(Instance: TObject; Prop: TRttiProperty): TInspectorEditorKind;
var
  Obj: TObject;
begin
  Result := iekText;
  if Prop.PropertyType.Name = 'TAlphaColor' then
    Exit(iekColor);
  case Prop.PropertyType.TypeKind of
    tkEnumeration:
      if Prop.PropertyType.Handle = TypeInfo(Boolean) then
        Exit(iekBoolean)
      else
        Exit(iekEnumeration);
    tkSet:
      Exit(iekSet);
    tkInteger, tkInt64, tkFloat:
      Exit(iekNumber);
    tkClass:
      begin
        Obj := Prop.GetValue(Instance).AsObject;
        if Obj is TCollection then
          Exit(iekCollection);
        if Obj is TStrings then
          Exit(iekStrings);
        if Obj is TBitmap then
          Exit(iekBitmap);
        if Obj is TFont then
          Exit(iekFont);
        if Obj is TPathData then
          Exit(iekPath);
        if Obj is TGradient then
          Exit(iekGradient);
        Exit(iekGroup);
      end;
  end;
  if (Instance is TFont) and SameText(Prop.Name, 'Family') then
    Result := iekFontFamily;
end;

function TSBDPropertyInspector.AddNode(Instance: TObject; Prop: TRttiProperty; Parent: TFmxObject; const Path, Caption: string; Kind: TInspectorEditorKind): TInspectorProperty;
begin
  Result := TInspectorProperty.Create;
  Result.Instance := Instance;
  Result.Prop := Prop;
  Result.Path := Path;
  Result.WritePath := Path;
  Result.Caption := Caption;
  Result.Kind := Kind;
  Result.ReadOnly := (Prop = nil) or not Prop.IsWritable;
  if Assigned(FOnBinding) then
    FOnBinding(Self, Path, Result.BindingName);
  FNodes.Add(Result);
  Result.Item := TSBDTreeViewItem.Create(Self);
  Result.Item.StyledSettings := Result.Item.StyledSettings - [TStyledSetting.Other];
  Result.Item.TextSettings.Trimming := TTextTrimming.Character;
  Result.Item.TextSettings.WordWrap := False;
  Result.Item.OnApplyStyleLookup := PropertyItemStyleApplied;
  Result.Item.OnPainting := NodePainting;
  Result.Item.Parent := Parent;
  Result.Item.Height := 36;
  Result.Item.Text := Caption;
  Result.Item.TagObject := Result;
  Result.Item.Hint := Path;
  if Result.BindingName <> '' then
  begin
    Result.Item.Text := Caption + ' ↔';
    Result.Item.Hint := Path + ' ↔ ' + Result.BindingName;
  end;
  Result.Item.ShowHint := True;
end;

procedure TSBDPropertyInspector.AddInstance(Instance: TObject; Parent: TFmxObject; const Prefix: string; Depth: Integer; Ancestors: TList<TObject>);
var
  Props: TArray<TRttiProperty>;
  Accept, Expanded: Boolean;
  Node, Child: TInspectorProperty;
  Obj: TObject;
  EnumInfo: PTypeInfo;
  EnumData: PTypeData;
  Path: string;
begin
  if (Instance = nil) or (Depth > 8) or Ancestors.Contains(Instance) then
    Exit;
  Ancestors.Add(Instance);
  try
    Props := FContext.GetType(Instance.ClassType).GetProperties;
    TArray.Sort<TRttiProperty>(Props, TComparer<TRttiProperty>.Construct(
      function(const L, R: TRttiProperty): Integer
      begin
        Result := CompareText(L.Name, R.Name);
      end));
    for var Prop in Props do
    begin
      Accept := (Prop.Visibility = mvPublished) and Prop.IsReadable and not Prop.Name.StartsWith('On');
      if Assigned(FOnFilter) then
        FOnFilter(Self, Instance, Prop, Accept)
      else
        Accept := Accept and (Prop.Name <> 'Name') and (Prop.Name <> 'Parent') and
          (Prop.Name <> 'Owner') and (Prop.Name <> 'StyleBook');
      if not Accept then
        Continue;
      if not (Prop.PropertyType.TypeKind in [tkInteger, tkInt64, tkFloat, tkEnumeration,
          tkSet, tkString, tkLString, tkWString, tkUString, tkChar, tkWChar, tkClass]) then
        Continue;
      Path := Prefix + Prop.Name;
      if FindNode(Path) <> nil then
        Continue;
      try
        if Prop.PropertyType.TypeKind = tkClass then
        begin
          Obj := Prop.GetValue(Instance).AsObject;
          if not (Obj is TPersistent) or (Obj is TComponent) then
            Continue;
        end
        else
          Obj := nil;
        Node := AddNode(Instance, Prop, Parent, Path, Prop.Name, KindOf(Instance, Prop));
        if not FVirtualEditors then
          CreateEditor(Node);
        case Node.Kind of
          iekGroup, iekFont, iekGradient:
            AddInstance(Obj, Node.Item, Path + '.', Depth + 1, Ancestors);
          iekCollection:
            for var I := 0 to TCollection(Obj).Count - 1 do
            begin
              Child := AddNode(TCollection(Obj).Items[I], nil, Node.Item,
                Path + '[' + I.ToString + ']', '[' + I.ToString + '] ' + TCollection(Obj).Items[I].DisplayName, iekGroup);
              if not FVirtualEditors then
                CreateEditor(Child);
              AddInstance(Child.Instance, Child.Item, Child.Path + '.', Depth + 1, Ancestors);
            end;
          iekSet:
            begin
              EnumInfo := GetTypeData(Prop.PropertyType.Handle).CompType^;
              EnumData := GetTypeData(EnumInfo);
              for var I := EnumData.MinValue to EnumData.MaxValue do
              begin
                Child := AddNode(Instance, Prop, Node.Item, Path + '.' + GetEnumName(EnumInfo, I), GetEnumName(EnumInfo, I), iekSetMember);
                Child.WritePath := Path;
                Child.MemberOrdinal := I;
                if not FVirtualEditors then
                  CreateEditor(Child);
              end;
            end;
        end;
        Expanded := (Depth = 0) and ((Prop.Name = 'Fill') or (Prop.Name = 'Position'));
        FExpanded.TryGetValue(Path, Expanded);
        Node.Item.IsExpanded := Expanded;
      except
        on E: Exception do
        begin
          FError.Text := Path + ': ' + E.Message;
          FError.Visible := True;
        end;
      end;
    end;
  finally
    Ancestors.Delete(Ancestors.Count - 1);
  end;
end;

function TSBDPropertyInspector.ValueText(Node: TInspectorProperty): string;
var
  V: TValue;
  Obj: TObject;
  BitIndex: Integer;
begin
  if Node.Prop = nil then
    Exit(Node.Instance.ClassName);
  V := Node.Prop.GetValue(Node.Instance);
  if Node.Kind = iekSetMember then
  begin
    BitIndex := Node.MemberOrdinal - ByteOffsetOfSet(Node.Prop.PropertyType.Handle) * 8;
    Exit(BoolToStr((PByte(NativeUInt(V.GetReferenceToRawData) + NativeUInt(BitIndex div 8))^ and (1 shl (BitIndex mod 8))) <> 0, True));
  end;
  if Node.Kind = iekColor then
    Exit('#' + IntToHex(V.AsOrdinal, 8));
  if V.Kind = tkClass then
  begin
    Obj := V.AsObject;
    if Obj is TCollection then
      Exit(TCollection(Obj).Count.ToString + Translate(' элементов'));
    if Obj is TStrings then
      Exit(TStrings(Obj).Count.ToString + Translate(' строк'));
    if Obj is TBitmap then
      Exit(Format('%d × %d', [TBitmap(Obj).Width, TBitmap(Obj).Height]));
    if Obj is TFont then
      Exit(TFont(Obj).Family + ', ' + FloatToStr(TFont(Obj).Size));
    if Obj is TPathData then
      Exit(TPathData(Obj).Data);
    if Obj is TGradient then
      Exit(TGradient(Obj).Points.Count.ToString + ' · ' +
        Translate('Мастер градиента'));
    Exit('(' + Obj.ClassName + ')');
  end;
  case V.Kind of
    tkEnumeration:
      Result := GetEnumName(Node.Prop.PropertyType.Handle, V.AsOrdinal);
    tkSet:
      Result := SetToString(Node.Prop.PropertyType.Handle, V.GetReferenceToRawData, True);
    tkFloat:
      Result := FloatToStr(V.AsExtended, TFormatSettings.Invariant);
  else
    Result := V.ToString;
  end;
  if (Node.Prop.Name = 'Text') and (V.Kind in [tkString, tkLString, tkWString, tkUString]) and Result.IsEmpty then
    Result := FEmptyTextPlaceholder;
end;

procedure TSBDPropertyInspector.CreateEditor(Node: TInspectorProperty);
var
  Host: TLayout;
  Edit: TEdit;
  Choice: TComboBox;
  Check: TCheckBox;
  Wizard: TButton;
  LabelControl: TLabel;
  Swatch: TRectangle;
  Info: PTypeInfo;
  Data: PTypeData;
  FontChoice: TComboEdit;
begin
  Host := TLayout.Create(Self);
  Host.Parent := Node.Item;
  Host.Align := TAlignLayout.Right;
  Host.Margins.Rect := RectF(4, 2, 4, 2);
  Host.Width := Max(100, FTree.Width * (1 - FNameColumnRatio) - 28);
  Host.Tag := 731;
  Host.TagObject := Node;
  if Node.Kind in [iekBoolean, iekSetMember] then
  begin
    Check := TCheckBox.Create(Self);
    Check.Parent := Host;
    Check.Align := TAlignLayout.Client;
    Check.Text := '';
    Check.IsChecked := SameText(ValueText(Node), 'True');
    Check.Enabled := not Node.ReadOnly;
    Check.OnChange := CheckChange;
    Node.Editor := Check;
  end
  else if Node.Kind = iekEnumeration then
  begin
    Choice := TComboBox.Create(Self);
    Choice.OnResize := ComboResize;
    Choice.ListBox.ScrollAnimation := TBehaviorBoolean.True;
    Choice.Parent := Host;
    Choice.Align := TAlignLayout.Client;
    ComboResize(Choice);
    Info := Node.Prop.PropertyType.Handle;
    Data := GetTypeData(Info);
    for var I := Data.MinValue to Data.MaxValue do
      Node.Choices.Add(GetEnumName(Info, I));
    Choice.Items.Assign(Node.Choices);
    Choice.ItemIndex := Choice.Items.IndexOf(ValueText(Node));
    Choice.Enabled := not Node.ReadOnly;
    Choice.OnChange := ChoiceChange;
    Node.Editor := Choice;
  end
  else if Node.Kind = iekFontFamily then
  begin
    FontChoice := TComboEdit.Create(Self);
    FontChoice.OnResize := ComboResize;
    FontChoice.Parent := Host;
    FontChoice.Align := TAlignLayout.Client;
    ComboResize(FontChoice);
    for var Family in ['Segoe UI', 'Arial', 'Calibri', 'Consolas', 'Tahoma', 'Times New Roman', 'Verdana'] do
      FontChoice.Items.Add(Family);
    FontChoice.Text := ValueText(Node);
    FontChoice.ReadOnly := Node.ReadOnly;
    FontChoice.OnExit := TextExit;
    FontChoice.OnKeyDown := EditKeys;
    Node.Editor := FontChoice;
  end
  else if Node.Kind in [iekGroup, iekStrings, iekBitmap, iekCollection, iekFont, iekPath, iekGradient] then
  begin
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := Host;
    LabelControl.Align := TAlignLayout.Client;
    LabelControl.TextSettings.Trimming := TTextTrimming.Character;
    LabelControl.Text := ValueText(Node);
    Node.Editor := LabelControl;
  end
  else
  begin
    Edit := TEdit.Create(Self);
    Edit.Parent := Host;
    Edit.Align := TAlignLayout.Client;
    Edit.Text := ValueText(Node);
    Edit.ReadOnly := Node.ReadOnly;
    if Node.Kind = iekColor then
    begin
      Edit.StyledSettings := Edit.StyledSettings - [TStyledSetting.Size];
      Edit.TextSettings.Font.Size := 12;
    end;
    // Set summaries are edited through their individual Boolean children.
    if Node.Kind = iekSet then
      Edit.ReadOnly := True;
    Edit.OnExit := TextExit;
    Edit.OnKeyDown := EditKeys;
    Node.Editor := Edit;
  end;
  Node.Editor.TagObject := Node;
  Node.Editor.OnEnter := EditorEnter;
  Node.Editor.Hint := Node.Path + ': ' + ValueText(Node);
  Node.Editor.ShowHint := True;
  if Node.Kind in [iekColor, iekStrings, iekBitmap, iekCollection, iekFont, iekPath, iekGradient] then
  begin
    Wizard := TButton.Create(Self);
    Wizard.Parent := Host;
    Wizard.Align := TAlignLayout.Right;
    Wizard.Position.X := 10000;
    Wizard.Width := 28;
    Wizard.Margins.Left := 4;
    Wizard.Text := '…';
    Wizard.Enabled := not Node.ReadOnly or (Node.Prop.PropertyType.TypeKind = tkClass);
    Wizard.TagObject := Node;
    Wizard.Hint := Translate('Открыть редактор: ') + Node.Path;
    Wizard.ShowHint := True;
    Wizard.OnClick := WizardClick;
  end;
  if Node.Kind = iekColor then
  begin
    Swatch := TRectangle.Create(Self);
    Swatch.Parent := Host;
    Swatch.Align := TAlignLayout.Left;
    Swatch.Width := 16;
    Swatch.Margins.Rect := RectF(0, 8, 4, 8);
    Swatch.Fill.Color := TAlphaColor(Node.Prop.GetValue(Node.Instance).AsOrdinal);
    Swatch.Stroke.Color := $FF888888;
    Swatch.HitTest := False;
    Node.Swatch := Swatch;
  end;
end;

procedure TSBDPropertyInspector.SaveViewState;
begin
  for var Node in FNodes do
    if Node.Item.Count > 0 then
      FExpanded.AddOrSetValue(Node.Path, Node.Item.IsExpanded);
end;

procedure TSBDPropertyInspector.Clear;
begin
  if FFilterText.IsEmpty then
    SaveViewState;
  FUpdating := True;
  try
    FInstance := nil;
    FTree.Clear;
    FNodes.Clear;
  finally
    FUpdating := False;
  end;
end;

function TSBDPropertyInspector.Rebind(Instance: TObject): Boolean;
var
  Targets: TArray<TObject>;

  function Resolve(const Path: string): TObject;
  begin
    Result := Instance;
    if Path.IsEmpty then
      Exit;
    for var Part in Path.Split(['.']) do
    begin
      var Name := Part;
      var Index := -1;
      var Bracket := Name.IndexOf('[');
      if Bracket >= 0 then
      begin
        if not TryStrToInt(Name.Substring(Bracket + 1, Name.Length - Bracket - 2), Index) then
          Exit(nil);
        Name := Name.Substring(0, Bracket);
      end;
      var Prop := FContext.GetType(Result.ClassType).GetProperty(Name);
      if (Prop = nil) or (Prop.PropertyType.TypeKind <> tkClass) then
        Exit(nil);
      Result := Prop.GetValue(Result).AsObject;
      if Index >= 0 then
      begin
        if not (Result is TCollection) or (Index >= TCollection(Result).Count) then
          Exit(nil);
        Result := TCollection(Result).Items[Index];
      end;
      if Result = nil then
        Exit;
    end;
  end;

begin
  Result := False;
  if (Instance = nil) or (FInstance = nil) or (FInstance.ClassType <> Instance.ClassType) then
    Exit;
  SetLength(Targets, FNodes.Count);
  for var I := 0 to FNodes.Count - 1 do
  begin
    var Node := FNodes[I];
    var Path := Node.WritePath;
    if Node.Prop <> nil then
    begin
      var Dot := Path.LastIndexOf('.');
      if Dot < 0 then
        Path := ''
      else
        Path := Path.Substring(0, Dot);
    end;
    Targets[I] := Resolve(Path);
    if (Targets[I] = nil) or (Targets[I].ClassType <> Node.Instance.ClassType) then
      Exit;
    if Node.Prop <> nil then
    begin
      if (Node.Kind <> iekSetMember) and (KindOf(Targets[I], Node.Prop) <> Node.Kind) then
        Exit;
      if Node.Prop.PropertyType.TypeKind = tkClass then
      begin
        var OldObject := Node.Prop.GetValue(Node.Instance).AsObject;
        var NewObject := Node.Prop.GetValue(Targets[I]).AsObject;
        if (OldObject = nil) or (NewObject = nil) or (OldObject.ClassType <> NewObject.ClassType) then
          Exit;
        if (OldObject is TCollection) and (TCollection(OldObject).Count <> TCollection(NewObject).Count) then
          Exit;
      end;
    end;
  end;
  FUpdating := True;
  try
    for var I := 0 to FNodes.Count - 1 do
      FNodes[I].Instance := Targets[I];
    FInstance := Instance;
  finally
    FUpdating := False;
  end;
  RefreshValues;
  Result := True;
end;

procedure TSBDPropertyInspector.Inspect(Instance: TObject);
begin
  if FReuseStructure and (Instance <> FInstance) and Rebind(Instance) then
    Exit;
  FInstance := Instance;
  Refresh;
end;

procedure TSBDPropertyInspector.RefreshValues;
begin
  if FUpdating then
    Exit;
  for var Node in FNodes do
  begin
    ResetEditor(Node);
    Node.BindingName := '';
    if Assigned(FOnBinding) then
      FOnBinding(Self, Node.WritePath, Node.BindingName);
    var Caption := Node.Caption;
    Node.Item.Hint := Node.Path;
    if not Node.BindingName.IsEmpty then
    begin
      Caption := Caption + ' ↔';
      Node.Item.Hint := Node.Path + ' ↔ ' + Node.BindingName;
    end;
    if Node.Item.Text <> Caption then
      Node.Item.Text := Caption;
  end;
end;

procedure TSBDPropertyInspector.RefreshLanguage;
begin
  FNameHeader.Text := Translate('Свойство');
  FValueHeader.Text := Translate('Значение');
  Refresh;
end;

procedure TSBDPropertyInspector.Refresh;
var
  SelectedPath: string;
  View: TPointF;
  Ancestors: TList<TObject>;
  Expanded: Boolean;
begin
  if FUpdating then
    Exit;
  SelectedPath := '';
  if SelectedProperty <> nil then
    SelectedPath := SelectedProperty.Path;
  View := FTree.ViewportPosition;
  if not FSkipSaveView and FFilterText.IsEmpty then
    SaveViewState;
  FUpdating := True;
  FTree.BeginUpdate;
  Ancestors := TList<TObject>.Create;
  try
    FTree.Clear;
    FNodes.Clear;
    FError.Visible := False;
    AddInstance(FInstance, FTree, '', 0, Ancestors);
    for var I := 0 to FTree.Count - 1 do
      MatchFilter(FTree.Items[I]);
    LayoutEditors(nil);
    if SelectedPath <> '' then
      SelectPath(SelectedPath);
    // TTreeView.Selected opens its ancestors; restore explicit fold state last.
    if FFilterText.IsEmpty then
      for var Node in FNodes do
        if (Node.Item.Count > 0) and FExpanded.TryGetValue(Node.Path, Expanded) then
          Node.Item.IsExpanded := Expanded;
  finally
    Ancestors.Free;
    FTree.EndUpdate;
    FUpdating := False;
  end;
  FTree.RealignContent;
  FTree.ViewportPosition := View;
end;

function TSBDPropertyInspector.MatchFilter(Item: TTreeViewItem): Boolean;
var
  Node: TInspectorProperty;
  ChildrenMatch: Boolean;
begin
  Node := TInspectorProperty(Item.TagObject);
  Result := FFilterText.IsEmpty or Node.Path.ToLower.Contains(FFilterText.ToLower);
  ChildrenMatch := False;
  for var I := 0 to Item.Count - 1 do
    ChildrenMatch := MatchFilter(Item.Items[I]) or ChildrenMatch;
  Result := Result or ChildrenMatch;
  Item.Visible := Result;
  if not FFilterText.IsEmpty and ChildrenMatch then
    Item.IsExpanded := True;
end;

function TSBDPropertyInspector.FindNode(const Path: string): TInspectorProperty;
begin
  Result := nil;
  for var Node in FNodes do
    if SameText(Node.Path, Path) then
      Exit(Node);
end;

function TSBDPropertyInspector.FindProperty(const Path: string): TInspectorProperty;
begin
  Result := FindNode(Path);
  if (Result <> nil) and (Result.Editor = nil) then
    CreateEditor(Result);
end;

procedure TSBDPropertyInspector.NodePainting(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  if FUpdating or not FVirtualEditors then
    Exit;
  var Node := TInspectorProperty(TTreeViewItem(Sender).TagObject);
  if (Node = nil) or (Node.Editor <> nil) then
    Exit;
  FUpdating := True;
  try
    CreateEditor(Node);
  finally
    FUpdating := False;
  end;
end;

function TSBDPropertyInspector.GetSelectedProperty: TInspectorProperty;
begin
  Result := nil;
  if (FTree <> nil) and (FTree.Selected <> nil) then
    Result := TInspectorProperty(FTree.Selected.TagObject);
end;

procedure TSBDPropertyInspector.SelectPath(const Path: string);
var
  Node: TInspectorProperty;
  Parent: TFmxObject;
begin
  Node := FindProperty(Path);
  if Node = nil then
    Exit;
  Parent := Node.Item.Parent;
  while (Parent <> nil) and (Parent <> FTree) do
  begin
    if Parent is TTreeViewItem then
      TTreeViewItem(Parent).IsExpanded := True;
    Parent := Parent.Parent;
  end;
  FTree.Selected := Node.Item;
end;

procedure TSBDPropertyInspector.SetEmptyTextPlaceholder(const Value: string);
begin
  if FEmptyTextPlaceholder = Value then
    Exit;
  FEmptyTextPlaceholder := Value;
  RefreshValues;
end;

procedure TSBDPropertyInspector.SetFilterText(const Value: string);
begin
  if FFilterText = Value then
    Exit;
  if FFilterText.IsEmpty then
    SaveViewState;
  FFilterText := Value;
  FSkipSaveView := True;
  try
    Refresh;
  finally
    FSkipSaveView := False;
  end;
end;

procedure TSBDPropertyInspector.SetNameColumnRatio(const Value: Single);
begin
  FNameColumnRatio := EnsureRange(Value, 0.25, 0.7);
  LayoutEditors(nil);
end;

procedure TSBDPropertyInspector.ComboResize(Sender: TObject);
begin
  if Sender is TComboBox then
    TComboBox(Sender).ItemHeight := TComboBox(Sender).Height
  else if Sender is TComboEdit then
    TComboEdit(Sender).ItemHeight := TComboEdit(Sender).Height;
end;

procedure TSBDPropertyInspector.LayoutEditors(Sender: TObject);
begin
  if FTree = nil then
    Exit;
  FNameHeader.Width := Max(60, FTree.Width * FNameColumnRatio - 8);
  for var Node in FNodes do
  begin
    if Node.Editor <> nil then
      TControl(Node.Editor.Parent).Width := Max(100, FTree.Width * (1 - FNameColumnRatio) - 28);
    PropertyItemStyleApplied(Node.Item);
  end;
end;

procedure TSBDPropertyInspector.PropertyItemStyleApplied(Sender: TObject);
var
  Caption: TFmxObject;
begin
  Caption := TTreeViewItem(Sender).FindStyleResource('text');
  // Reserve the value column even before a virtual editor is created.
  if Caption is TControl then
    TControl(Caption).Margins.Right := Max(100, FTree.Width * (1 - FNameColumnRatio) - 28) + 4;
end;

procedure TSBDPropertyInspector.ColumnDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FTree.Width > 0 then
    NameColumnRatio := (FNameHeader.Width + 8) / FTree.Width;
end;

function TSBDPropertyInspector.DialogOwner: TComponent;
begin
  Result := Self;
  if (Root <> nil) and (Root.GetObject is TComponent) then
    Result := TComponent(Root.GetObject);
end;

procedure TSBDPropertyInspector.TreeChange(Sender: TObject);
begin
  if not FUpdating and Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

procedure TSBDPropertyInspector.EditorEnter(Sender: TObject);
begin
  if not FUpdating then
    FTree.Selected := TInspectorProperty(TControl(Sender).TagObject).Item;
end;

procedure TSBDPropertyInspector.EditKeys(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if FUpdating then
    Exit;
  if Key = vkReturn then
  begin
    TextExit(Sender);
    Key := 0;
    KeyChar := #0;
  end
  else if Key = vkEscape then
  begin
    ResetEditor(TInspectorProperty(TControl(Sender).TagObject));
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TSBDPropertyInspector.TextExit(Sender: TObject);
var
  Node: TInspectorProperty;
  Text: string;
begin
  if FUpdating then
    Exit;
  Node := TInspectorProperty(TControl(Sender).TagObject);
  if Node.ReadOnly or (Node.Kind = iekSet) then
    Exit;
  if Sender is TComboEdit then
    Text := TComboEdit(Sender).Text
  else
    Text := TEdit(Sender).Text;
  if Text = ValueText(Node) then
    Exit;
  try
    WriteProperty(Node.Path, Text);
  except
    on E: Exception do
    begin
      FError.Text := E.Message;
      FError.Visible := True;
      ResetEditor(Node);
    end;
  end;
end;

procedure TSBDPropertyInspector.ChoiceChange(Sender: TObject);
var
  Node: TInspectorProperty;
  Choice: TComboBox;
begin
  if FUpdating then
    Exit;
  Node := TInspectorProperty(TControl(Sender).TagObject);
  Choice := TComboBox(Sender);
  if Choice.ItemIndex < 0 then
    Exit;
  try
    WriteProperty(Node.Path, Choice.Items[Choice.ItemIndex]);
  except
    on E: Exception do
    begin
      FError.Text := E.Message;
      FError.Visible := True;
      ResetEditor(Node);
    end;
  end;
end;

procedure TSBDPropertyInspector.CheckChange(Sender: TObject);
var
  Node: TInspectorProperty;
begin
  if FUpdating then
    Exit;
  Node := TInspectorProperty(TControl(Sender).TagObject);
  try
    WriteProperty(Node.Path, BoolToStr(TCheckBox(Sender).IsChecked, True));
  except
    on E: Exception do
    begin
      FError.Text := E.Message;
      FError.Visible := True;
      ResetEditor(Node);
    end;
  end;
end;

procedure TSBDPropertyInspector.ResetEditor(Node: TInspectorProperty);
begin
  FUpdating := True;
  try
    if Node.Editor is TComboBox then
      TComboBox(Node.Editor).ItemIndex := TComboBox(Node.Editor).Items.IndexOf(ValueText(Node))
    else if Node.Editor is TCheckBox then
      TCheckBox(Node.Editor).IsChecked := SameText(ValueText(Node), 'True')
    else if Node.Editor is TComboEdit then
      TComboEdit(Node.Editor).Text := ValueText(Node)
    else if Node.Editor is TEdit then
      TEdit(Node.Editor).Text := ValueText(Node)
    else if Node.Editor is TLabel then
      TLabel(Node.Editor).Text := ValueText(Node);
    if Node.Swatch <> nil then
      Node.Swatch.Fill.Color := TAlphaColor(Node.Prop.GetValue(Node.Instance).AsOrdinal);
  finally
    FUpdating := False;
  end;
end;

procedure TSBDPropertyInspector.SetDefaultValue(Node: TInspectorProperty; const Text: string);
var
  V: TValue;
  Info: PTypeInfo;
  N: Int64;
  D: Extended;
  S: string;
  SetBytes: TBytes;
begin
  Info := Node.Prop.PropertyType.Handle;
  S := Trim(Text);
  V := Node.Prop.GetValue(Node.Instance);
  case V.Kind of
    tkInteger, tkInt64:
      begin
        if S.StartsWith('#') then
          S := '$' + S.Substring(1);
        N := StrToInt64(S);
        if (V.Kind = tkInteger) and (GetTypeData(Info).OrdType <> otULong) and
          ((N < GetTypeData(Info).MinValue) or (N > GetTypeData(Info).MaxValue)) then
          raise EConvertError.Create(Translate('Число вне диапазона свойства'));
        if (V.Kind = tkInteger) and (GetTypeData(Info).OrdType = otULong) and ((N < 0) or (N > High(Cardinal))) then
          raise EConvertError.Create(Translate('Число вне диапазона свойства'));
        V := TValue.FromOrdinal(Info, N);
      end;
    tkFloat:
      begin
        D := StrToFloat(S.Replace(',', '.'), TFormatSettings.Invariant);
        if IsNan(D) or IsInfinite(D) then
          raise EConvertError.Create(Translate('Ожидается конечное число'));
        V := TValue.From<Extended>(D).Cast(Info);
      end;
    tkEnumeration:
      begin
        N := GetEnumValue(Info, S);
        if N < 0 then
          raise EConvertError.Create(Translate('Неизвестное значение перечисления'));
        V := TValue.FromOrdinal(Info, N);
      end;
    tkSet:
      begin
        SetLength(SetBytes, SizeOfSet(Info));
        StringToSet(Info, S, @SetBytes[0]);
        TValue.Make(@SetBytes[0], Info, V);
      end;
    tkString, tkLString, tkWString, tkUString:
      V := TValue.From<string>(Text).Cast(Info);
    tkChar, tkWChar:
      begin
        if Length(Text) <> 1 then
          raise EConvertError.Create(Translate('Ожидается один символ'));
        V := TValue.FromOrdinal(Info, Ord(Text[1]));
      end;
  else
    raise EConvertError.Create(Translate('Для этого свойства нужен специальный редактор'));
  end;
  Node.Prop.SetValue(Node.Instance, V);
end;

procedure TSBDPropertyInspector.WriteProperty(const Path, Text: string);
var
  Node: TInspectorProperty;
  NewText: string;
  SetBytes: TBytes;
  BitIndex: Integer;
  V: TValue;
begin
  Node := FindProperty(Path);
  if (Node = nil) or Node.ReadOnly then
    raise EConvertError.Create(Translate('Свойство доступно только для чтения: ') + Path);
  NewText := Text;
  if Node.Kind = iekSetMember then
  begin
    V := Node.Prop.GetValue(Node.Instance);
    SetLength(SetBytes, V.DataSize);
    System.Move(V.GetReferenceToRawData^, SetBytes[0], V.DataSize);
    BitIndex := Node.MemberOrdinal - ByteOffsetOfSet(Node.Prop.PropertyType.Handle) * 8;
    if SameText(Text, 'True') then
      SetBytes[BitIndex div 8] := SetBytes[BitIndex div 8] or (1 shl (BitIndex mod 8))
    else if SameText(Text, 'False') then
      SetBytes[BitIndex div 8] := SetBytes[BitIndex div 8] and not (1 shl (BitIndex mod 8))
    else
      raise EConvertError.Create(Translate('Ожидается True или False'));
    NewText := SetToString(Node.Prop.PropertyType.Handle, @SetBytes[0], True);
  end;
  if Assigned(FOnWrite) then
    FOnWrite(Self, Node, NewText)
  else
  begin
    SetDefaultValue(Node, NewText);
    for var Other in FNodes do
      if (Other.Instance = Node.Instance) and (Other.Prop = Node.Prop) then
        ResetEditor(Other);
  end;
  FError.Visible := False;
end;

procedure TSBDPropertyInspector.EditValue(const Path: string; UseHostEditor: Boolean);
var
  Node: TInspectorProperty;
  Handler: TInspectorEditEvent;
begin
  Node := FindProperty(Path);
  if (Node = nil) or (Node.Editor = nil) then
    Exit;
  Handler := FOnEdit;
  if not UseHostEditor then
    FOnEdit := nil;
  try
    WizardClick(Node.Editor);
  finally
    FOnEdit := Handler;
  end;
end;

procedure TSBDPropertyInspector.WizardClick(Sender: TObject);
var
  Node: TInspectorProperty;
  Color: TAlphaColor;
  Obj: TObject;
  TextDialog: TTextEditorForm;
  CollectionDialog: TInspectorCollectionEditor;
  OpenDialog: TOpenDialog;
  Font: TFont;
  Bitmap: TBitmap;
  PathData: TPathData;
begin
  if FUpdating then
    Exit;
  Node := TInspectorProperty(TControl(Sender).TagObject);
  FTree.Selected := Node.Item;
  try
    if Assigned(FOnEdit) then
    begin
      // The host can replace its model during a wizard; never reuse Node afterward.
      FOnEdit(Self, Node);
      Exit;
    end;
    if Node.Kind = iekColor then
    begin
      Color := TAlphaColor(Node.Prop.GetValue(Node.Instance).AsOrdinal);
      if ChooseColor(DialogOwner, Color) then
        WriteProperty(Node.Path, '#' + IntToHex(Color, 8));
      ResetEditor(Node);
      Exit;
    end;
    Obj := Node.Prop.GetValue(Node.Instance).AsObject;
    if Obj is TGradient then
    begin
      var GradientDialog := TGradientEditorForm.CreateEditor(DialogOwner, TGradient(Obj));
      try
        if GradientDialog.ShowModal = mrOk then
        begin
          CopyGradient(TGradient(Obj), GradientDialog.Value);
          if Node.Instance is TBrush then
            TBrush(Node.Instance).Kind := TBrushKind.Gradient;
        end;
      finally
        GradientDialog.Free;
      end;
    end
    else if (Obj is TStrings) or (Obj is TPathData) then
    begin
      TextDialog := TTextEditorForm.Create(DialogOwner);
      if DialogOwner is TForm then
        TextDialog.StyleBook := TForm(DialogOwner).StyleBook;
      try
        if Obj is TStrings then
          TextDialog.TextMemo.Lines.Assign(TStrings(Obj))
        else
          TextDialog.TextMemo.Lines.Text := TPathData(Obj).Data;
        if TextDialog.ShowModal = mrOk then
          if Obj is TStrings then
            TStrings(Obj).Assign(TextDialog.TextMemo.Lines)
          else
          begin
            PathData := TPathData.Create;
            try
              PathData.Data := TextDialog.TextMemo.Lines.Text;
              TPathData(Obj).Assign(PathData);
            finally
              PathData.Free;
            end;
          end;
      finally
        TextDialog.Free;
      end;
    end
    else if Obj is TBitmap then
    begin
      OpenDialog := TOpenDialog.Create(DialogOwner);
      Bitmap := TBitmap.Create;
      try
        OpenDialog.Filter := Translate('Изображения|*.png;*.jpg;*.jpeg;*.bmp');
        if OpenDialog.Execute then
        begin
          Bitmap.LoadFromFile(OpenDialog.FileName);
          TBitmap(Obj).Assign(Bitmap);
        end;
      finally
        Bitmap.Free;
        OpenDialog.Free;
      end;
    end
    else if Obj is TCollection then
    begin
      CollectionDialog := TInspectorCollectionEditor.CreateEditor(DialogOwner, TCollection(Obj), FEmptyTextPlaceholder);
      try
        if CollectionDialog.ShowModal = mrOk then
          TCollection(Obj).Assign(CollectionDialog.Value);
      finally
        CollectionDialog.Free;
      end;
    end
    else if Obj is TFont then
    begin
      Font := TFont.Create;
      try
        Font.Assign(TFont(Obj));
        if ChooseAppFont(DialogOwner as TCustomForm, Font) then
          TFont(Obj).Assign(Font);
      finally
        Font.Free;
      end;
    end;
    Refresh;
  except
    on E: Exception do
    begin
      FError.Text := E.Message;
      FError.Visible := True;
    end;
  end;
end;

initialization
  RegisterFmxClasses([TSBDPropertyInspector]);

end.


unit SBD.StyleCatalogDialog;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Forms, SBD.Dialogs,
  FMX.Controls, FMX.Layouts, FMX.StdCtrls, FMX.ListBox, FMX.Edit, FMX.Memo,
  FMX.ScrollBox, FMX.Grid, FMX.Grid.Style, FMX.Controls.Presentation,
  SBD.StyleCatalog, FMX.Memo.Types, System.Rtti;

type
  TStyleCatalogDialog = class(TAppDialogForm)
    Header: TLayout;
    TitleLabel: TLabel;
    HelpLabel: TLabel;
    Actions: TPanel;
    CloseButton: TButton;
    CreateButton: TButton;
    Body: TLayout;
    ClassPanel: TLayout;
    SearchEdit: TEdit;
    ClassList: TListBox;
    Splitter: TSplitter;
    ReferencePanel: TLayout;
    InfoMemo: TMemo;
    DependenciesMemo: TMemo;
    DetailsMemo: TMemo;
    PartsGrid: TStringGrid;
    PartNameColumn: TStringColumn;
    TypeColumn: TStringColumn;
    ScopeColumn: TStringColumn;
    OwnerColumn: TStringColumn;
    procedure FilterClasses(Sender: TObject);
    procedure SelectClass(Sender: TObject);
    procedure SelectPart(Sender: TObject);
  private
    FCatalog: TStyleCatalog;
    FExists: TFunc<string, Boolean>;
    FUpdating: Boolean;
    function GetDefinition: TStyleDefinition;
  public
    constructor CreateCatalog(AOwner: TComponent; Catalog: TStyleCatalog; const Exists: TFunc<string, Boolean>; const InitialClass: string);
    property Definition: TStyleDefinition read GetDefinition;
  end;

implementation

uses
  SBD.Main, FMX.Consts, SBD.Localization, SBD.PropertyInspector;

{$R *.fmx}

constructor TStyleCatalogDialog.CreateCatalog(AOwner: TComponent; Catalog: TStyleCatalog; const Exists: TFunc<string, Boolean>; const InitialClass: string);
begin
  inherited Create(AOwner);
  FCatalog := Catalog;
  FExists := Exists;
  TranslateForm(Self);
  EnableSmoothScrolling(Self);
  if AOwner is TForm then
    StyleBook := TForm(AOwner).StyleBook;
  FilterClasses(nil);
  for var I := 0 to ClassList.Count - 1 do
    if SameText(ClassList.ListItems[I].Text, InitialClass) then
    begin
      ClassList.ItemIndex := I;
      Break;
    end;
  SelectClass(nil);
end;

function TStyleCatalogDialog.GetDefinition: TStyleDefinition;
begin
  Result := nil;
  if ClassList.Selected <> nil then
    Result := TStyleDefinition(ClassList.Selected.TagObject);
end;

procedure TStyleCatalogDialog.FilterClasses(Sender: TObject);
begin
  if FCatalog = nil then
    Exit;
  var Previous := Definition;
  var Names := TStringList.Create;
  FUpdating := True;
  ClassList.BeginUpdate;
  try
    Names.Sorted := True;
    for var Entry in FCatalog.Definitions do
      if not Entry.ClassName.StartsWith('@') and not Entry.ClassName.StartsWith('TCustom') and
        (SearchEdit.Text.IsEmpty or Entry.ClassName.ToLower.Contains(SearchEdit.Text.Trim.ToLower)) then
        Names.AddObject(Entry.ClassName, Entry);
    ClassList.Clear;
    for var I := 0 to Names.Count - 1 do
    begin
      var Item := TListBoxItem.Create(ClassList);
      Item.Text := Names[I];
      Item.TagObject := Names.Objects[I];
      Item.Parent := ClassList;
    end;
    ClassList.ItemIndex := -1;
    for var I := 0 to ClassList.Count - 1 do
      if ClassList.ListItems[I].TagObject = Previous then
        ClassList.ItemIndex := I;
    if (ClassList.ItemIndex < 0) and (ClassList.Count > 0) then
      ClassList.ItemIndex := 0;
  finally
    ClassList.EndUpdate;
    FUpdating := False;
    Names.Free;
  end;
  SelectClass(nil);
end;

procedure TStyleCatalogDialog.SelectClass(Sender: TObject);
begin
  if FUpdating then
    Exit;
  FUpdating := True;
  try
    PartsGrid.RowCount := 0;
    InfoMemo.Lines.Clear;
    DependenciesMemo.Lines.Clear;
    DetailsMemo.Lines.Clear;
    var Entry := Definition;
    CreateButton.Enabled := (Entry <> nil) and not Entry.DefaultStyleName.IsEmpty;
    if Entry = nil then
    begin
      InfoMemo.Lines.Add(Translate('Классы не найдены.'));
      Exit;
    end;
    InfoMemo.Lines.Add(Entry.ClassName + ' → ' + Entry.BaseClass);
    InfoMemo.Lines.Add(Entry.Description);
    InfoMemo.Lines.Add('DefaultStyleName: ' + Entry.DefaultStyleName);
    if not Entry.DefaultNote.IsEmpty then
      InfoMemo.Lines.Add(Entry.DefaultNote);
    PartsGrid.RowCount := Entry.Parts.Count;
    for var I := 0 to Entry.Parts.Count - 1 do
    begin
      var Part := Entry.Parts[I];
      PartsGrid.Cells[0, I] := Part.Name;
      PartsGrid.Cells[1, I] := Part.RequiredType;
      PartsGrid.Cells[2, I] := Part.Scope;
      PartsGrid.Cells[3, I] := Part.DeclaredIn;
    end;
    if Entry.Parts.Count = 0 then
      DetailsMemo.Lines.Add(Translate('Именованные элементы не запрашиваются.'));
    if Entry.DefaultStyleName.IsEmpty then
      Exit;
    var Names := TStringList.Create;
    try
      Names.CaseSensitive := False;
      FCatalog.RequiredStyles(Entry, Names);
      DependenciesMemo.Lines.Add(Translate('Основной стиль создаётся всегда; совпадение имени добавляет индекс.'));
      for var I := 1 to Names.Count - 1 do
      begin
        var Status := Translate('создать');
        if Assigned(FExists) and FExists(Names[I]) then
          Status := Translate('уже в дереве');
        DependenciesMemo.Lines.Add(Names[I] + ' — ' + Status);
      end;
      if Names.Count = 1 then
        DependenciesMemo.Lines.Add(Translate('Нет зависимостей'));
    finally
      Names.Free;
    end;
    if Entry.Parts.Count > 0 then
      PartsGrid.Row := 0;
  finally
    FUpdating := False;
  end;
  SelectPart(nil);
end;

procedure TStyleCatalogDialog.SelectPart(Sender: TObject);
begin
  if FUpdating or (Definition = nil) or (PartsGrid.Row < 0) or
    (PartsGrid.Row >= Definition.Parts.Count) then
    Exit;
  var Part := Definition.Parts[PartsGrid.Row];
  DetailsMemo.Lines.Clear;
  DetailsMemo.Lines.Add(Part.Name + ': ' + Part.RequiredType);
  DetailsMemo.Lines.Add(Translate('Возможные классы: ') + Part.Examples);
  DetailsMemo.Lines.Add(Part.Scope + ' — ' + Part.Description);
  DetailsMemo.Lines.Add(Translate('Источник: ') + Part.Source);
end;

end.


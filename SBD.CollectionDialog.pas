unit SBD.CollectionDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Math, FMX.Types, FMX.Controls, FMX.Forms, SBD.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.ListBox, FMX.Grid, FMX.Grid.Style, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Consts, SBD.Main, SBD.EditorTypes, FMX.ScrollBox,
  SBD.PropertyInspector;

type
  TCollectionDialog = class(TAppDialogForm)
  published
    DialogHeader: TLayout;
    DialogTitle: TLabel;
    HelpLabel: TLabel;
    Actions: TPanel;
    CollectionTools: TLayout;
    AddButton: TButton;
    DeleteButton: TButton;
    CancelButton: TButton;
    ApplyButton: TButton;
    DialogBody: TLayout;
    FList: TListBox;
    PropertyHost: TLayout;
    procedure SelectionChanged(Sender: TObject);
    procedure CollectionAction(Sender: TObject);
  private
    FEditor: TFormMain;
    FCollection: TCollection;
    FTargetName, FPropertyPath: string;
    FUpdating: Boolean;
    FInspector: TSBDPropertyInspector;
    procedure EditValue(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
    procedure EditObject(Sender: TObject; PropertyInfo: TInspectorProperty);
    procedure FilterProperty(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
    procedure UpdateList;
  public
    property Inspector: TSBDPropertyInspector read FInspector;
    constructor CreateEditor(Editor: TFormMain; Collection: TCollection; const Path: string);
    destructor Destroy; override;
  end;

implementation

uses
  SBD.Localization;

{$R *.fmx}

constructor TCollectionDialog.CreateEditor(Editor: TFormMain; Collection: TCollection; const Path: string);
begin
  FUpdating := True;
  inherited Create(Editor);
  TranslateForm(Self);
  EnableSmoothScrolling(Self);
  FEditor := Editor;
  StyleBook := Editor.StyleBook;
  FInspector := TSBDPropertyInspector.Create(Self);
  FInspector.EmptyTextPlaceholder := 'Text';
  FInspector.Parent := PropertyHost;
  FInspector.Align := TAlignLayout.Client;
  FInspector.OnWriteProperty := EditValue;
  FInspector.OnEditProperty := EditObject;
  FInspector.OnFilterProperty := FilterProperty;
  FCollection := Collection;
  FTargetName := Editor.SelectedObject.Name;
  FPropertyPath := Path;
  Caption := Translate('Редактор коллекции ') + Collection.ClassName;
  UpdateList;
end;

destructor TCollectionDialog.Destroy;
begin
  if FList <> nil then
    FList.OnChange := nil;
  FreeAndNil(FInspector);
  inherited;
end;

procedure TCollectionDialog.UpdateList;
var
  I, Index: Integer;
begin
  Index := FList.ItemIndex;
  FUpdating := True;
  try
    FList.Clear;
    for I := 0 to FCollection.Count - 1 do
      FList.Items.Add(I.ToString + ': ' + FCollection.Items[I].DisplayName);
    FList.ItemIndex := EnsureRange(Index, 0, FCollection.Count - 1);
  finally
    FUpdating := False;
  end;
  SelectionChanged(nil);
end;

procedure TCollectionDialog.SelectionChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if FList.ItemIndex >= 0 then
    FInspector.Inspect(FCollection.Items[FList.ItemIndex])
  else
    FInspector.Clear;
end;

procedure TCollectionDialog.FilterProperty(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
begin
  Accept := Accept and FEditor.IsStyleProperty(Instance, Prop);
end;

procedure TCollectionDialog.EditValue(Sender: TObject; PropertyInfo: TInspectorProperty; const Text: string);
var
  Entry: TPropertyEntry;
begin
  if FUpdating then
    Exit;
  Entry := TPropertyEntry.Create;
  try
    Entry.Instance := PropertyInfo.Instance;
    Entry.Prop := PropertyInfo.Prop;
    Entry.Path := PropertyInfo.WritePath;
    FEditor.SetPropertyText(Entry, Text);
    FEditor.DetachPropertyBinding(FEditor.SelectedObject,
      FPropertyPath + '[' + FList.ItemIndex.ToString + '].' + Entry.Path);
  finally
    Entry.Free;
  end;
end;

procedure TCollectionDialog.EditObject(Sender: TObject; PropertyInfo: TInspectorProperty);
var
  Path: string;
  Before, After: TBytes;
begin
  Path := FPropertyPath + '[' + FList.ItemIndex.ToString + '].' + PropertyInfo.Path;
  Before := FEditor.Snapshot;
  FInspector.EditValue(PropertyInfo.Path, False);
  After := FEditor.Snapshot;
  if (Length(Before) = Length(After)) and
    ((Length(Before) = 0) or CompareMem(@Before[0], @After[0], Length(Before))) then
    Exit;
  // Replacing a complex value authors that whole value; stale nested references
  // must not overwrite it or refer to removed collection items on the next save.
  for var I := FEditor.ValueBindings.Count - 1 downto 0 do
    if (FEditor.ValueBindings[I].TargetName = FTargetName) and
      ((FEditor.ValueBindings[I].PropertyPath = Path) or
      FEditor.ValueBindings[I].PropertyPath.StartsWith(Path + '.') or
      FEditor.ValueBindings[I].PropertyPath.StartsWith(Path + '[')) then
      FEditor.ValueBindings.Delete(I);
end;

procedure TCollectionDialog.CollectionAction(Sender: TObject);
var
  Prefix, Path: string;
  Bracket, Index: Integer;
begin
  try
    FInspector.Clear;
    case TComponent(Sender).Tag of
      1:
        FCollection.Add;
      2:
        if FList.ItemIndex >= 0 then
        begin
          Prefix := FPropertyPath + '[';
          for var I := FEditor.ValueBindings.Count - 1 downto 0 do
          begin
            Path := FEditor.ValueBindings[I].PropertyPath;
            if (FEditor.ValueBindings[I].TargetName <> FTargetName) or not Path.StartsWith(Prefix) then
              Continue;
            Bracket := Path.IndexOf(']', Prefix.Length);
            if (Bracket < 0) or not TryStrToInt(Path.Substring(Prefix.Length, Bracket - Prefix.Length), Index) then
              Continue;
            if Index = FList.ItemIndex then
              FEditor.ValueBindings.Delete(I)
            else if Index > FList.ItemIndex then
              FEditor.ValueBindings[I].PropertyPath := Prefix + (Index - 1).ToString + Path.Substring(Bracket);
          end;
          FCollection.Items[FList.ItemIndex].Free;
        end;
    end;
    UpdateList;
  except
    on E: Exception do
      ShowAppMessage(Self, E.Message);
  end;
end;

end.


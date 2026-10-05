unit SBD.StyleIO;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, FMX.Controls, FMX.Types,
  FMX.Platform, FMX.Styles;

function ComponentText(Component: TComponent): string;

function ClipboardService: IFMXClipboardService;

function ClipboardText: string;

function ReadStyleBookText(const Text: string): TFmxObject;

procedure UnpackStyleBinaries(Root: TFmxObject);

function ChildrenOf(Obj: TFmxObject): TArray<TFmxObject>;

function EditableChildren(Obj: TFmxObject): TArray<TFmxObject>;

function EditableObject(Obj: TFmxObject): TFmxObject;

function EditableParent(Obj: TFmxObject): TFmxObject;

procedure SetModelDesigning(Obj: TFmxObject);

procedure VisitStyleText(Root: TFmxObject; const Visit: TProc<TObject, TRttiProperty>);

function AcceptStylePlatform(const PlatformTarget: string): Boolean;

procedure ApplyTextPlaceholders(Obj: TFmxObject);

procedure WriteStyleStream(Root: TFmxObject; Stream: TStream; Format: TStyleFormat);

implementation

uses
  System.TypInfo, System.Generics.Collections, FMX.Forms, FMX.Styles.Objects,
  SBD.Localization;

type
  TComponentAccess = class(TComponent);

  TFmxObjectAccess = class(TFmxObject);

  TClipboardStyleBook = class(TStyleBook)
  protected
    procedure Loaded; override;
  end;

  TEditorChildren = class(TList<TFmxObject>)
    procedure Collect(Child: TComponent);
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

procedure ApplyTextPlaceholders(Obj: TFmxObject);
begin
  VisitStyleText(Obj,
    procedure(Instance: TObject; Prop: TRttiProperty)
    begin
      if Prop.GetValue(Instance).AsString.IsEmpty then
        Prop.SetValue(Instance, TValue.From<string>('Text').Cast(Prop.PropertyType.Handle));
    end);
end;

procedure WriteStyleStream(Root: TFmxObject; Stream: TStream; Format: TStyleFormat);
var
  Placeholders: TList<TPair<TObject, TRttiProperty>>;
begin
  Placeholders := TList<TPair<TObject, TRttiProperty>>.Create;
  try
    try
      VisitStyleText(Root,
        procedure(Instance: TObject; Prop: TRttiProperty)
        begin
          if Prop.GetValue(Instance).AsString = 'Text' then
          begin
            Placeholders.Add(TPair<TObject, TRttiProperty>.Create(Instance, Prop));
            Prop.SetValue(Instance, TValue.From<string>('').Cast(Prop.PropertyType.Handle));
          end;
        end);
      TStyleStreaming.SaveToStream(Root, Stream, Format);
    finally
      // Keep authored editor values and history intact, also after a failed write.
      for var Pair in Placeholders do
        Pair.Value.SetValue(Pair.Key, TValue.From<string>('Text').Cast(Pair.Value.PropertyType.Handle));
    end;
  finally
    Placeholders.Free;
  end;
end;

end.


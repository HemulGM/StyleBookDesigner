unit SBD.StyleDocument;

interface

uses
  System.Classes, System.Generics.Collections, FMX.Types, FMX.Layouts,
  SBD.EditorTypes;

type
  TStyleDocument = class
  private
    FValues: TObjectList<TNamedStyleValue>;
    FBindings: TObjectList<TStyleValueBinding>;
    FGroups: TObjectList<TStyleGroup>;
    FAssignments, FStyleClasses: TDictionary<string, string>;
  public
    // Root is owned here. Replacements stay explicit so loading can roll back.
    Root: TFmxObject;
    ResourceTheme: TResourceTheme;
    PendingView: string;
    constructor Create;
    destructor Destroy; override;
    function FindGroup(const ID: string): TStyleGroup;
    function GroupOf(Resource: TFmxObject): string;
    function CanAssignGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string): Boolean;
    function FindValue(const Name: string): TNamedStyleValue;
    function FindNamedObject(const Name: string): TFmxObject;
    procedure ValidateNamedValue(Value: TNamedStyleValue);
    procedure ValidateBinding(Value: TNamedStyleValue; Binding: TStyleValueBinding);
    procedure ApplyBindings(Selected: TFmxObject = nil);
    function DesignerLayout(CreateIfMissing: Boolean): TLayout;
    function DesignerJSON: string;
    procedure UpdateDesignerMetadata(const ViewJSON: string = '');
    function MetadataJSON(const ViewJSON: string = ''): string;
    procedure LoadMetadata(const Text: string);
    function StyleResourceCount: Integer;
    property NamedValues: TObjectList<TNamedStyleValue> read FValues;
    property ValueBindings: TObjectList<TStyleValueBinding> read FBindings;
    property Groups: TObjectList<TStyleGroup> read FGroups;
    property Assignments: TDictionary<string, string> read FAssignments;
    property StyleClasses: TDictionary<string, string> read FStyleClasses;
  end;

implementation

uses
  System.SysUtils, System.Rtti, System.TypInfo, System.Math, System.JSON,
  FMX.Styles, FMX.Styles.Objects, SBD.StyleIO, SBD.StyleProperties,
  SBD.Localization;

constructor TStyleDocument.Create;
begin
  inherited;
  FValues := TObjectList<TNamedStyleValue>.Create;
  FBindings := TObjectList<TStyleValueBinding>.Create;
  FGroups := TObjectList<TStyleGroup>.Create;
  FAssignments := TDictionary<string, string>.Create;
  FStyleClasses := TDictionary<string, string>.Create;
end;

destructor TStyleDocument.Destroy;
begin
  Root.Free;
  FValues.Free;
  FBindings.Free;
  FGroups.Free;
  FAssignments.Free;
  FStyleClasses.Free;
  inherited;
end;

function TStyleDocument.FindGroup(const ID: string): TStyleGroup;
begin
  Result := nil;
  for var StyleGroup in FGroups do
    if StyleGroup.ID = ID then
      Exit(StyleGroup);
end;

function TStyleDocument.GroupOf(Resource: TFmxObject): string;
begin
  Result := '';
  if Resource <> nil then
    FAssignments.TryGetValue(Resource.Name, Result);
end;

function TStyleDocument.CanAssignGroup(Obj: TFmxObject; StyleGroup: TStyleGroup; const ParentID: string): Boolean;
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
    Result := (Obj <> nil) and (Obj.Parent = Root) and
      not SameText(Obj.StyleName, '#designer') and (GroupOf(Obj) <> ParentID);
end;

function TStyleDocument.FindValue(const Name: string): TNamedStyleValue;
begin
  Result := nil;
  for var Value in FValues do
    if SameText(Value.Name, Name) then
      Exit(Value);
end;

function TStyleDocument.FindNamedObject(const Name: string): TFmxObject;

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
  if (Root <> nil) and not Name.IsEmpty then
    Result := Find(Root);
end;

procedure TStyleDocument.ValidateNamedValue(Value: TNamedStyleValue);
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

procedure TStyleDocument.ValidateBinding(Value: TNamedStyleValue; Binding: TStyleValueBinding);
begin
  var Obj := FindNamedObject(Binding.TargetName);
  if Obj = nil then
    Exit;
  var Entry := ResolveStyleProperty(Obj, Binding.PropertyPath);
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

procedure TStyleDocument.ApplyBindings(Selected: TFmxObject);
var
  Entry: TPropertyEntry;
  Value: TNamedStyleValue;
  Obj: TFmxObject;
begin
  for var Resource in FValues do
    Resource.Theme := ResourceTheme;
  for var Binding in FBindings do
  begin
    Value := FindValue(Binding.ResourceName);
    Obj := FindNamedObject(Binding.TargetName);
    if (Value = nil) or (Obj = nil) then
      Continue;
    Entry := ResolveStyleProperty(Obj, Binding.PropertyPath);
    if Entry = nil then
      Continue;
    try
      ValidateBinding(Value, Binding);
      SetStylePropertyText(Root, Selected, Entry, Value.Value);
    finally
      Entry.Free;
    end;
  end;
end;

function TStyleDocument.DesignerLayout(CreateIfMissing: Boolean): TLayout;
begin
  Result := nil;
  if Root = nil then
    Exit;
  for var Child in ChildrenOf(Root) do
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
    Result.Parent := Root;
    SetModelDesigning(Result);
  end;
end;

function TStyleDocument.DesignerJSON: string;
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

procedure TStyleDocument.UpdateDesignerMetadata(const ViewJSON: string);
var
  Tag: TStyleTag;
begin
  var Layout := DesignerLayout(True);
  // Always keep the hidden service resource last; resource indices remain stable.
  Layout.Index := Root.ChildrenCount - 1;
  for var Key in FAssignments.Keys.ToArray do
  begin
    var Obj := FindNamedObject(Key);
    if (Obj = nil) or (Obj.Parent <> Root) or (FindGroup(FAssignments[Key]) = nil) then
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
    if (Resource = nil) or (Resource.Parent <> Root) or SameText(Resource.StyleName, '#designer') then
      FStyleClasses.Remove(Key);
  end;
  Tag.TagString := MetadataJSON(ViewJSON);
end;

function TStyleDocument.MetadataJSON(const ViewJSON: string): string;
var
  JSON, Item: TJSONObject;
  Values, Bindings, Targets, Groups, Assignments, StyleClasses: TJSONArray;
  Names: TDictionary<string, Boolean>;
  Obj, Parent: TFmxObject;
  Path: string;
  View: TJSONObject;
begin
  JSON := TJSONObject.Create;
  Names := TDictionary<string, Boolean>.Create;
  try
    JSON.AddPair('version', TJSONNumber.Create(3));
    if ResourceTheme = rtDark then
      JSON.AddPair('theme', 'dark')
    else
      JSON.AddPair('theme', 'light');
    Values := TJSONArray.Create;
    JSON.AddPair('values', Values);
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
    JSON.AddPair('bindings', Bindings);
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
    JSON.AddPair('targets', Targets);
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
      while (Parent <> nil) and (Parent <> Root) do
      begin
        if Path.IsEmpty then
          Path := Parent.Index.ToString
        else
          Path := Parent.Index.ToString + '/' + Path;
        Parent := Parent.Parent;
      end;
      if Parent <> Root then
        Continue;
      Item := TJSONObject.Create;
      Item.AddPair('name', Obj.Name);
      Item.AddPair('path', Path);
      Item.AddPair('class', Obj.ClassName);
      Targets.AddElement(Item);
    end;
    Groups := TJSONArray.Create;
    JSON.AddPair('groups', Groups);
    for var StyleGroup in FGroups do
    begin
      Item := TJSONObject.Create;
      Item.AddPair('id', StyleGroup.ID);
      Item.AddPair('title', StyleGroup.Title);
      Item.AddPair('parent', StyleGroup.ParentID);
      Groups.AddElement(Item);
    end;
    Assignments := TJSONArray.Create;
    JSON.AddPair('assignments', Assignments);
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
    JSON.AddPair('styleClasses', StyleClasses);
    var ClassTargets := FStyleClasses.Keys.ToArray;
    TArray.Sort<string>(ClassTargets);
    for var TargetName in ClassTargets do
    begin
      Obj := FindNamedObject(TargetName);
      if (Obj = nil) or (Obj.Parent <> Root) or SameText(Obj.StyleName, '#designer') then
        Continue;
      Item := TJSONObject.Create;
      Item.AddPair('target', TargetName);
      Item.AddPair('controlClass', FStyleClasses[TargetName]);
      StyleClasses.AddElement(Item);
    end;
    if not ViewJSON.IsEmpty then
    begin
      View := TJSONObject.ParseJSONValue(ViewJSON) as TJSONObject;
      JSON.AddPair('view', View);
    end;
    Result := JSON.ToJSON;
  finally
    Names.Free;
    JSON.Free;
  end;
end;

procedure TStyleDocument.LoadMetadata(const Text: string);
var
  JSON: TJSONValue;
  Items: TJSONArray;
  Value: TNamedStyleValue;
  Binding: TStyleValueBinding;
  Obj: TFmxObject;
  Index, Version: Integer;
  Path, Name: string;
begin
  FGroups.Clear;
  FAssignments.Clear;
  FStyleClasses.Clear;
  PendingView := '';
  ResourceTheme := rtLight;
  if Text.IsEmpty then
  begin
    FValues.Clear;
    FBindings.Clear;
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
        ResourceTheme := rtDark
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
        Obj := Root;
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
        Value.Theme := ResourceTheme;
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
        if (Target = nil) or (Target.Parent <> Root) or (FindGroup(GroupID) = nil) or
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
        if (Target = nil) or (Target.Parent <> Root) or SameText(Target.StyleName, '#designer') or
          ClassName.IsEmpty or FStyleClasses.ContainsKey(TargetName) then
          raise Exception.Create(Translate('Некорректное назначение класса стилю.'));
        FStyleClasses.Add(TargetName, ClassName);
      end;
    var View := JSON.GetValue<TJSONObject>('view', nil);
    if View <> nil then
      PendingView := View.ToJSON;
  finally
    JSON.Free;
  end;
end;

function TStyleDocument.StyleResourceCount: Integer;
begin
  Result := 0;
  for var Child in ChildrenOf(Root) do
    if not SameText(Child.StyleName, '#designer') then
      Inc(Result);
end;

end.


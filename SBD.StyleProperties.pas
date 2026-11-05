unit SBD.StyleProperties;

interface

uses
  System.Classes, System.Rtti, System.Generics.Collections, FMX.Types, SBD.EditorTypes;

function IsStyleProperty(Instance: TObject; Prop: TRttiProperty): Boolean;

function ResolveStyleProperty(Obj: TFmxObject; const Path: string): TPropertyEntry;

function StylePropertyText(AEntry: TPropertyEntry): string;

procedure SetStylePropertyText(Root, Selected: TFmxObject; AEntry: TPropertyEntry; const AText: string);

procedure CollectStyleProperties(Entries: TObjectList<TPropertyEntry>; AInstance: TObject; const APrefix: string; ADepth: Integer; const FilterText: string = '');

procedure GetCursorNames(Names: TStrings);

function CursorPropertyText(Value: Int64): string;

function ParseCursorProperty(const Text: string): Integer;

implementation

uses
  System.SysUtils, System.UITypes, System.TypInfo, System.Math, FMX.Controls,
  FMX.Controls3D, FMX.Ani, FMX.Effects, FMX.Graphics, FMX.Styles,
  FMX.Styles.Objects, SBD.StyleIO, SBD.Localization;

const
  CursorNames: array[0..22] of string = ('crDefault', 'crNone', 'crArrow',
    'crCross', 'crIBeam', 'crSizeNESW', 'crSizeNS', 'crSizeNWSE', 'crSizeWE',
    'crUpArrow', 'crHourGlass', 'crDrag', 'crNoDrop', 'crHSplit', 'crVSplit',
    'crMultiDrag', 'crSQLWait', 'crNo', 'crAppStart', 'crHelp', 'crHandPoint',
    'crSizeAll', 'crSize');
  CursorValues: array[0..22] of Integer = (0, -1, -2, -3, -4, -6, -7, -8, -9,
    -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -22);

procedure GetCursorNames(Names: TStrings);
begin
  Names.Clear;
  for var Name in CursorNames do
    Names.Add(Name);
end;

function CursorPropertyText(Value: Int64): string;
begin
  for var I := Low(CursorValues) to High(CursorValues) do
    if CursorValues[I] = Value then
      Exit(CursorNames[I]);
  Result := IntToStr(Value);
end;

function ParseCursorProperty(const Text: string): Integer;
begin
  for var I := Low(CursorNames) to High(CursorNames) do
    if SameText(Trim(Text), CursorNames[I]) then
      Exit(CursorValues[I]);
  if not TryStrToInt(Trim(Text), Result) or (Result < -32768) or (Result > 32767) then
    raise EConvertError.Create(Translate('Неизвестный курсор. Выберите имя или введите число от -32768 до 32767.'));
end;

function IsStyleProperty(Instance: TObject; Prop: TRttiProperty): Boolean;
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

function ResolveStyleProperty(Obj: TFmxObject; const Path: string): TPropertyEntry;
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

function StylePropertyText(AEntry: TPropertyEntry): string;
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
  if AEntry.Prop.PropertyType.Handle = TypeInfo(TCursor) then
    Exit(CursorPropertyText(V.AsOrdinal));
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

procedure SetStylePropertyText(Root, Selected: TFmxObject; AEntry: TPropertyEntry; const AText: string);
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
  if Info = TypeInfo(TCursor) then
    S := IntToStr(ParseCursorProperty(S));
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
  if (AEntry.Instance = Selected) and (AEntry.Prop.Name = 'StyleName') and
    (Selected.Parent = Root) then
  begin
    if Trim(AText).IsEmpty then
      raise Exception.Create(Translate('Корневому ресурсу нужно имя StyleName.'));
    for var Child in ChildrenOf(Root) do
      if (Child <> Selected) and SameText(Child.StyleName, AText) then
        raise Exception.Create(Translate('Ресурс с таким StyleName уже существует.'));
  end;
  if (AEntry.Prop.Name = 'StyleName') and SameText(AText, '#designer') then
    raise Exception.Create(Translate('Имя #designer зарезервировано редактором.'));
  AEntry.Prop.SetValue(AEntry.Instance, V);
end;

procedure CollectStyleProperties(Entries: TObjectList<TPropertyEntry>; AInstance: TObject; const APrefix: string; ADepth: Integer; const FilterText: string);
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
      for var Existing in Entries do
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
            Entries.Add(Entry);
            Collection := TCollection(Obj);
            for I := 0 to Collection.Count - 1 do
              CollectStyleProperties(Entries, Collection.Items[I], Path + '[' + I.ToString + '].', ADepth + 1, FilterText);
          end
          else if (Obj is TStrings) or (Obj is TBitmap) then
          begin
            Entry := TPropertyEntry.Create;
            Entry.Instance := AInstance;
            Entry.Prop := Prop;
            Entry.Path := Path;
            Entries.Add(Entry);
          end
          else if (Obj is TPersistent) and not (Obj is TComponent) then
            CollectStyleProperties(Entries, Obj, Path + '.', ADepth + 1, FilterText);
          Continue;
        end;
        if not Prop.IsWritable then
          Continue;
        if not (Value.Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration,
            tkSet, tkString, tkLString, tkWString, tkUString, tkChar, tkWChar]) then
          Continue;
        if not FilterText.IsEmpty and not Path.ToLower.Contains(FilterText.ToLower) then
          Continue;
        Entry := TPropertyEntry.Create;
        Entry.Instance := AInstance;
        Entry.Prop := Prop;
        Entry.Path := Path;
        Entries.Add(Entry);
      except
        // A component may expose a property which requires a platform service.
        // Do not prevent editing the other properties in that case.
      end;
    end;
  finally
    Context.Free;
  end;
end;

end.


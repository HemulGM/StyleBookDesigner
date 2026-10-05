unit SBD.StyleCatalog;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, FMX.Types;

type
  TStylePart = record
    Name, RequiredType, Examples, Scope, DeclaredIn, Source, Description: string;
    TemplatePaths, TemplateClass: string;
  end;

  TStyleDependency = record
    StyleName, ControlClass: string;
  end;

  TStyleDefinition = class
  public
    ClassName, BaseClass, Description, DefaultStyleName, DefaultNote, RootClass: string;
    Parts: TList<TStylePart>;
    Dependencies: TList<TStyleDependency>;
    constructor Create;
    destructor Destroy; override;
  end;

  TStyleTemplatePlan = class
  public
    Resources: TObjectList<TFmxObject>;
    Main: TFmxObject;
    Composite: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TStyleCatalog = class
  private
    FDefinitions: TObjectList<TStyleDefinition>;
    FUsages: TList<TStyleDependency>;
    procedure AddControl(const ClassName, BaseClass, Description, DefaultName, DefaultNote, RootClass: string);
    procedure AddPart(const ClassName, Name, RequiredType, Examples, Scope, DeclaredIn, Source, Description, Paths, PartClass: string);
    procedure AddDependency(const ClassName, StyleName, ControlClass: string);
    procedure AddUsage(const ClassName, StyleName: string);
    procedure LoadData;
    function PartDependency(const Part: TStylePart): TStyleDefinition;
  public
    constructor Create;
    destructor Destroy; override;
    function Find(const ClassName: string): TStyleDefinition;
    procedure ControlsUsingStyle(const StyleName: string; Classes: TStrings; const IncludeDependencies: Boolean = True);
    procedure RequiredStyles(Definition: TStyleDefinition; Names: TStrings);
    function BuildTemplate(Definition: TStyleDefinition; const MainName: string; const Exists: TFunc<string, Boolean>): TStyleTemplatePlan;
    property Definitions: TObjectList<TStyleDefinition> read FDefinitions;
  end;

implementation

uses
  FMX.Controls, FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Graphics, FMX.Styles,
  FMX.Styles.Objects;

type
  TFmxObjectAccess = class(TFmxObject);

constructor TStyleDefinition.Create;
begin
  inherited;
  Parts := TList<TStylePart>.Create;
  Dependencies := TList<TStyleDependency>.Create;
end;

destructor TStyleDefinition.Destroy;
begin
  Parts.Free;
  Dependencies.Free;
  inherited;
end;

constructor TStyleTemplatePlan.Create;
begin
  inherited;
  Resources := TObjectList<TFmxObject>.Create;
end;

destructor TStyleTemplatePlan.Destroy;
begin
  Resources.Free;
  inherited;
end;

constructor TStyleCatalog.Create;
begin
  inherited;
  FDefinitions := TObjectList<TStyleDefinition>.Create;
  FUsages := TList<TStyleDependency>.Create;
  LoadData;
end;

destructor TStyleCatalog.Destroy;
begin
  FUsages.Free;
  FDefinitions.Free;
  inherited;
end;

function TStyleCatalog.Find(const ClassName: string): TStyleDefinition;
begin
  Result := nil;
  for var Definition in FDefinitions do
    if SameText(Definition.ClassName, Trim(ClassName)) then
      Exit(Definition);
end;

procedure TStyleCatalog.AddControl(const ClassName, BaseClass, Description, DefaultName, DefaultNote, RootClass: string);
begin
  var Definition := TStyleDefinition.Create;
  Definition.ClassName := ClassName;
  Definition.BaseClass := BaseClass;
  Definition.Description := Description;
  Definition.DefaultStyleName := DefaultName;
  Definition.DefaultNote := DefaultNote;
  Definition.RootClass := RootClass;
  FDefinitions.Add(Definition);
end;

procedure TStyleCatalog.AddPart(const ClassName, Name, RequiredType, Examples, Scope, DeclaredIn, Source, Description, Paths, PartClass: string);
begin
  var Part: TStylePart;
  Part.Name := Name;
  Part.RequiredType := RequiredType;
  Part.Examples := Examples;
  Part.Scope := Scope;
  Part.DeclaredIn := DeclaredIn;
  Part.Source := Source;
  Part.Description := Description;
  Part.TemplatePaths := Paths;
  Part.TemplateClass := PartClass;
  Find(ClassName).Parts.Add(Part);
end;

procedure TStyleCatalog.AddDependency(const ClassName, StyleName, ControlClass: string);
begin
  var Dependency: TStyleDependency;
  Dependency.StyleName := StyleName;
  Dependency.ControlClass := ControlClass;
  Find(ClassName).Dependencies.Add(Dependency);
end;

procedure TStyleCatalog.AddUsage(const ClassName, StyleName: string);
begin
  var Usage: TStyleDependency;
  Usage.ControlClass := ClassName;
  Usage.StyleName := StyleName;
  FUsages.Add(Usage);
end;

procedure TStyleCatalog.ControlsUsingStyle(const StyleName: string; Classes: TStrings; const IncludeDependencies: Boolean);

  function UsesStyle(Definition: TStyleDefinition): Boolean;
  begin
    Result := SameText(Definition.DefaultStyleName, StyleName);
    if Result then
      Exit;
    // Only explicit code references are inherited; default names can be overridden.
    var Current := Definition;
    var Depth := 0;
    while (Current <> nil) and (Depth < FDefinitions.Count) do
    begin
      for var Usage in FUsages do
        if SameText(Usage.ControlClass, Current.ClassName) and SameText(Usage.StyleName, StyleName) then
          Exit(True);
      if IncludeDependencies then
        for var Dependency in Current.Dependencies do
          if SameText(Dependency.StyleName, StyleName) then
            Exit(True);
      Current := Find(Current.BaseClass);
      Inc(Depth);
    end;
  end;

begin
  Classes.Clear;
  if StyleName.IsEmpty then
    Exit;
  var Matches := TStringList.Create;
  try
    Matches.CaseSensitive := False;
    Matches.Sorted := True;
    Matches.Duplicates := dupIgnore;
    for var Usage in FUsages do
      if SameText(Usage.StyleName, StyleName) then
        Matches.Add(Usage.ControlClass);
    for var Definition in FDefinitions do
      if not Definition.ClassName.StartsWith('@') and UsesStyle(Definition) then
        Matches.Add(Definition.ClassName);
    Classes.Assign(Matches);
  finally
    Matches.Free;
  end;
end;

function TStyleCatalog.PartDependency(const Part: TStylePart): TStyleDefinition;
begin
  Result := nil;
  if not Part.TemplatePaths.IsEmpty then
    Result := Find(Part.TemplateClass);
  if (Result <> nil) and Result.DefaultStyleName.IsEmpty then
    Result := nil;
end;

procedure TStyleCatalog.RequiredStyles(Definition: TStyleDefinition; Names: TStrings);

  procedure Visit(Definition: TStyleDefinition);

    procedure Add(const Name: string; Child: TStyleDefinition);
    begin
      if Names.IndexOf(Name) >= 0 then
        Exit;
      Names.Add(Name);
      if Child <> nil then
        Visit(Child);
    end;

  begin
    for var Dependency in Definition.Dependencies do
      Add(Dependency.StyleName, Find(Dependency.ControlClass));
    for var Part in Definition.Parts do
    begin
      var Child := PartDependency(Part);
      if Child <> nil then
        Add(Child.DefaultStyleName, Child);
    end;
  end;

begin
  Names.Clear;
  if Definition = nil then
    Exit;
  Names.Add(Definition.DefaultStyleName);
  Visit(Definition);
end;

function TStyleCatalog.BuildTemplate(Definition: TStyleDefinition; const MainName: string; const Exists: TFunc<string, Boolean>): TStyleTemplatePlan;
var
  Plan: TStyleTemplatePlan;
  Visited: TDictionary<string, string>;

  function NewObject(const ClassName, StyleName: string): TFmxObject;
  begin
    var C := GetClass(ClassName);
    if (C = nil) or not C.InheritsFrom(TFmxObject) then
      raise Exception.Create('Unknown FMX style part class: ' + ClassName);
    Result := TFmxObjectClass(C).Create(nil);
    try
      TFmxObjectAccess(Result).SetDesigning(True);
      Result.StyleName := StyleName;
      if Result is TControl then
      begin
        TControl(Result).SetBounds(0, 0, 160, 32);
        TControl(Result).HitTest := False;
      end;
      if Result is TText then
        TText(Result).Text := 'Text';
      if Result is TBrushObject then
        TBrushObject(Result).Brush.Color := $FF247AC4;
      if Result is TColorObject then
        TColorObject(Result).Color := $FF247AC4;
      if Result is TStyleTag then
        TStyleTag(Result).TagFloat := 16;
    except
      Result.Free;
      raise;
    end;
  end;

  function Build(Definition: TStyleDefinition; const Lookup, ResourceName: string; Primary: Boolean): string;
  var
    Root: TFmxObject;
    Objects: TDictionary<string, TFmxObject>;

    function EnsurePath(const Path, ClassName: string): TFmxObject;
    begin
      if Objects.TryGetValue(Path.ToLower, Result) then
        Exit;
      var Split := Path.LastIndexOf('/');
      var Parent := Root;
      var Name := Path;
      if Split >= 0 then
      begin
        Parent := EnsurePath(Path.Substring(0, Split), 'TLayout');
        Name := Path.Substring(Split + 1);
      end;
      Result := NewObject(ClassName, Name);
      try
        Result.Parent := Parent;
      except
        Result.Free;
        raise;
      end;
      Objects.Add(Path.ToLower, Result);
    end;

  begin
    if not Primary then
    begin
      Plan.Composite := True;
      if Visited.TryGetValue(Lookup.ToLower, Result) then
        Exit;
      if Assigned(Exists) and Exists(Lookup) then
      begin
        Visited.Add(Lookup.ToLower, Lookup);
        Exit(Lookup);
      end;
    end;
    Result := ResourceName;
    Visited.AddOrSetValue(Lookup.ToLower, ResourceName);
    Root := NewObject(Definition.RootClass, ResourceName);
    Plan.Resources.Add(Root);
    if Primary then
      Plan.Main := Root;
    Objects := TDictionary<string, TFmxObject>.Create;
    try
      // Containers are authored first, so a nested path retains its required class.
      for var Part in Definition.Parts do
        for var Path in Part.TemplatePaths.Split([';'], TStringSplitOptions.ExcludeEmpty) do
          EnsurePath(Path, Part.TemplateClass);
      for var Part in Definition.Parts do
      begin
        var Child := PartDependency(Part);
        if Child = nil then
          Continue;
        var ChildLookup := Build(Child, Child.DefaultStyleName, Child.DefaultStyleName, False);
        for var Path in Part.TemplatePaths.Split([';'], TStringSplitOptions.ExcludeEmpty) do
        begin
          var Obj := Objects[Path.ToLower];
          if Obj is TStyledControl then
            TStyledControl(Obj).StyleLookup := ChildLookup;
        end;
      end;
      for var Dependency in Definition.Dependencies do
      begin
        var Child := Find(Dependency.ControlClass);
        if Child = nil then
          raise Exception.Create('Unknown style dependency: ' + Dependency.ControlClass);
        Build(Child, Dependency.StyleName, Dependency.StyleName, False);
      end;
    finally
      Objects.Free;
    end;
  end;

begin
  if (Definition = nil) or Definition.DefaultStyleName.IsEmpty or Definition.RootClass.IsEmpty then
    raise Exception.Create('This entry describes a presentation; select its control class.');
  Plan := TStyleTemplatePlan.Create;
  Visited := TDictionary<string, string>.Create;
  try
    try
      Build(Definition, Definition.DefaultStyleName, MainName, True);
      Result := Plan;
    except
      Plan.Free;
      raise;
    end;
  finally
    Visited.Free;
  end;
end;

procedure TStyleCatalog.LoadData;
begin
  {$I SBD.StyleCatalog.Data.inc}
end;

end.


unit SBD.EditorTypes;

interface

uses
  System.Rtti;

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

implementation

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

end.


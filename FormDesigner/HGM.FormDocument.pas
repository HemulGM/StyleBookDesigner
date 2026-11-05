unit HGM.FormDocument;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms;

type
  TFormDocument = class
  private
    FRoot: TForm;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Find(const Name: string): TControl;
    function Add(const Kind: string; Parent: TFmxObject; X, Y: Single): TControl;
    function UniqueName(const Kind: string): string;
    function Snapshot: string;
    procedure Load(const Text: string);
    function FMXText: string;
    function PascalText(const UnitName: string): string;
    function ComponentCount: Integer;
    property Root: TForm read FRoot;
    class procedure CheckIdentifier(const Value: string); static;
  end;

implementation

uses
  System.StrUtils, System.RegularExpressions, FMX.StdCtrls, FMX.Edit,
  FMX.ListBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation;

constructor TFormDocument.Create;
begin
  inherited;
  Clear;
end;

destructor TFormDocument.Destroy;
begin
  FRoot.Free;
  inherited;
end;

procedure TFormDocument.Clear;
begin
  FreeAndNil(FRoot);
  FRoot := TForm.CreateNew(nil);
  FRoot.Name := 'MainForm';
  FRoot.Position := TFormPosition.Designed;
  FRoot.Left := 0;
  FRoot.Top := 0;
  FRoot.FormFactor.Devices := [TDeviceKind.Desktop];
  FRoot.Caption := 'Новая форма';
  FRoot.ClientWidth := 640;
  FRoot.ClientHeight := 480;
end;

class procedure TFormDocument.CheckIdentifier(const Value: string);
begin
  if not TRegEx.IsMatch(Value, '^[A-Za-z_][A-Za-z0-9_]{0,62}$') or
    MatchText(Value, ['unit', 'type', 'var', 'begin', 'end', 'class', 'object',
      'interface', 'implementation', 'uses', 'program', 'nil', 'property',
      'private', 'public', 'protected', 'published', 'procedure', 'function',
      'constructor', 'destructor', 'string', 'record', 'if', 'then', 'else',
      'for', 'while', 'do', 'repeat', 'until', 'case', 'of', 'const', 'array',
      'try', 'except', 'finally', 'in', 'is', 'as', 'and', 'or', 'not',
      'asm', 'div', 'downto', 'exports', 'file', 'finalization', 'goto',
      'inherited', 'initialization', 'inline', 'label', 'library', 'mod',
      'out', 'packed', 'raise', 'resourcestring', 'set', 'shl', 'shr',
      'threadvar', 'to', 'with', 'xor']) then
    raise EConvertError.Create('Введите допустимое имя Delphi: латинские буквы, цифры и подчёркивание.');
end;

function TFormDocument.Find(const Name: string): TControl;
begin
  Result := nil;
  if (Name <> '') and (FRoot.FindComponent(Name) is TControl) then
    Result := TControl(FRoot.FindComponent(Name));
end;

function TFormDocument.UniqueName(const Kind: string): string;
var I: Integer;
begin
  I := 1;
  repeat
    Result := Copy(Kind, 2, MaxInt) + IntToStr(I);
    Inc(I);
  until (FRoot.FindComponent(Result) = nil) and not SameText(Result, FRoot.Name);
end;

function TFormDocument.Add(const Kind: string; Parent: TFmxObject; X, Y: Single): TControl;
type TDesignControlClass = class of TControl;
var C: TPersistentClass;
begin
  C := GetClass(Kind);
  if (C = nil) or not C.InheritsFrom(TControl) then
    raise EConvertError.Create('Неизвестный класс компонента: ' + Kind);
  Result := TDesignControlClass(C).Create(FRoot);
  Result.Name := UniqueName(Kind);
  Result.Parent := Parent;
  Result.SetBounds(X, Y, 160, 32);
  if Result is TTextControl then TTextControl(Result).Text := Result.Name;
  if Result is TEdit then TEdit(Result).Text := '';
  if (Result is TLayout) or (Result is TPanel) or (Result is TMemo) or
    (Result is TListBox) or (Result is TRectangle) then
    Result.Size.Size := TSizeF.Create(240, 160);
  if Result is TSwitch then Result.Width := 64;
end;

function TFormDocument.Snapshot: string;
var B, T: TMemoryStream; Bytes: TBytes;
begin
  B := TMemoryStream.Create;
  T := TMemoryStream.Create;
  try
    B.WriteComponent(FRoot);
    B.Position := 0;
    ObjectBinaryToText(B, T);
    SetLength(Bytes, T.Size);
    T.Position := 0;
    T.ReadBuffer(Bytes, Length(Bytes));
    Result := TEncoding.UTF8.GetString(Bytes);
  finally T.Free; B.Free end;
end;

procedure TFormDocument.Load(const Text: string);
var
  T: TStringStream;
  B: TMemoryStream;
  NewRoot: TForm;
  Normalized, OriginalName: string;
  I: Integer;
begin
  if Length(Text) > 16 * 1024 * 1024 then
    raise EConvertError.Create('Форма превышает допустимый размер 16 МБ.');
  // Read into a fresh instance; a malformed form never destroys current work.
  Normalized := TRegEx.Replace(Text.TrimLeft, '^(object|inherited)\s+(\w+)\s*:\s*\w+', 'object $2: TForm');
  if not Normalized.StartsWith('object ') then
    raise EConvertError.Create('Ожидается текстовая форма FMX.');
  OriginalName := TRegEx.Match(Normalized, '^object\s+(\w+)').Groups[1].Value;
  CheckIdentifier(OriginalName);
  T := TStringStream.Create(Normalized, TEncoding.UTF8);
  B := TMemoryStream.Create;
  NewRoot := TForm.CreateNew(nil);
  NewRoot.Position := TFormPosition.Designed;
  NewRoot.Left := 0;
  NewRoot.Top := 0;
  try
    ObjectTextToBinary(T, B);
    B.Position := 0;
    B.ReadComponent(NewRoot);
    CheckIdentifier(NewRoot.Name);
    if (NewRoot.ClientWidth < 64) or (NewRoot.ClientWidth > 10000) or
       (NewRoot.ClientHeight < 64) or (NewRoot.ClientHeight > 10000) then
      raise EConvertError.Create('Размер формы должен быть от 64 до 10000.');
    for I := 0 to NewRoot.ComponentCount - 1 do
      if NewRoot.Components[I].Name <> '' then CheckIdentifier(NewRoot.Components[I].Name);
    FRoot.Free;
    FRoot := NewRoot;
    NewRoot := nil;
    // The reader may suffix a root name while the old form is still alive.
    FRoot.Name := OriginalName;
  finally NewRoot.Free; B.Free; T.Free end;
end;

function TFormDocument.FMXText: string;
begin
  Result := TRegEx.Replace(Snapshot, '^object\s+\w+\s*:\s*TForm',
    'object ' + FRoot.Name + ': T' + FRoot.Name);
end;

function TFormDocument.PascalText(const UnitName: string): string;
var L: TStringList; I: Integer; C: TComponent;
begin
  CheckIdentifier(UnitName);
  L := TStringList.Create;
  try
    L.Add('unit ' + UnitName + ';');
    L.Add('');
    L.Add('interface');
    L.Add('');
    L.Add('uses');
    L.Add('  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Forms,');
    L.Add('  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListBox,');
    L.Add('  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts, FMX.Objects;');
    L.Add('');
    L.Add('type');
    L.Add('  T' + FRoot.Name + ' = class(TForm)');
    for I := 0 to FRoot.ComponentCount - 1 do
    begin
      C := FRoot.Components[I];
      if C.Name <> '' then L.Add('    ' + C.Name + ': ' + C.ClassName + ';');
    end;
    L.Add('  end;');
    L.Add('');
    L.Add('var');
    if SameText(UnitName, FRoot.Name) then
      L.Add('  ' + FRoot.Name + 'Instance: T' + FRoot.Name + ';')
    else L.Add('  ' + FRoot.Name + ': T' + FRoot.Name + ';');
    L.Add('');
    L.Add('implementation');
    L.Add('');
    L.Add('{$R *.fmx}');
    L.Add('');
    L.Add('end.');
    Result := L.Text;
  finally L.Free end;
end;

function TFormDocument.ComponentCount: Integer;
begin
  Result := FRoot.ComponentCount;
end;

initialization
  if GetClass('TForm') = nil then RegisterClass(TForm);

end.

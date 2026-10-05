unit SBD.PropertyInspector.Tests;

interface

uses
  System.Classes, FMX.Forms;

procedure RunPropertyInspectorTests(Report: TStrings);

procedure RunWinUIDialogTests(Owner: TCustomForm; Report: TStrings; const Suffix: string = '');

procedure RunGradientDialogTests(Owner: TCustomForm; Report: TStrings; const Suffix: string = '');

implementation

uses
  System.SysUtils, System.TypInfo, System.Rtti, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Edit, FMX.ListBox, FMX.StdCtrls, FMX.Objects,
  FMX.Graphics, SBD.PropertyInspector, SBD.Dialogs, SBD.ColorDialog,
  SBD.GradientDialog, WinUI3.Form.Dialog, WinUI3.Frame.Dialog.Input,
  WinUI3.Frame.Dialog.ColorPicker, WinUI3.Frame.Dialog.Font;

type
  TTestFlag = (flag0, flag1, flag2, flag3, flag4, flag5, flag6, flag7, flag8, flag9, flag10, flag11, flag12, flag13, flag14, flag15, flag16, flag17, flag18, flag19, flag20, flag21, flag22, flag23, flag24, flag25, flag26, flag27, flag28, flag29, flag30, flag31, flag32, flag33, flag34, flag35, flag36, flag37, flag38, flag39, flag40, flag41, flag42, flag43, flag44, flag45, flag46, flag47, flag48, flag49, flag50, flag51, flag52, flag53, flag54, flag55, flag56, flag57, flag58, flag59, flag60, flag61, flag62, flag63, flag64, flag65, flag66, flag67, flag68, flag69, flag70);

  TTestFlags = set of TTestFlag;

  TOffsetElement = flag64..flag70;

  TOffsetFlags = set of TOffsetElement;

{$RTTI EXPLICIT PROPERTIES([vcPublic, vcPublished]) METHODS([]) FIELDS([])}
  TInspectorSubject = class(TPersistent)
  private
    FEnabled: Boolean;
    FCount: Integer;
    FMode: TBrushKind;
    FFlags: TTestFlags;
    FOffsetFlags: TOffsetFlags;
    FNext: TPersistent;
  public
    property Flags: TTestFlags read FFlags write FFlags;
    property OffsetFlags: TOffsetFlags read FOffsetFlags write FOffsetFlags;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property Count: Integer read FCount write FCount;
    property Mode: TBrushKind read FMode write FMode;
    property ReadOnlyCount: Integer read FCount;
    property Next: TPersistent read FNext;
  end;

type
  TInspectorTestFilter = class
    EditCount: Integer;
    EditPath: string;
    procedure Edit(Sender: TObject; PropertyInfo: TInspectorProperty);
    procedure Filter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
  end;

procedure TInspectorTestFilter.Edit(Sender: TObject; PropertyInfo: TInspectorProperty);
begin
  Inc(EditCount);
  EditPath := PropertyInfo.Path;
end;

procedure TInspectorTestFilter.Filter(Sender: TObject; Instance: TObject; Prop: TRttiProperty; var Accept: Boolean);
begin
  if (Instance is TInspectorSubject) and ((Prop.Name = 'Flags') or (Prop.Name = 'OffsetFlags')) then
    Accept := True;
end;

procedure RunPropertyInspectorTests(Report: TStrings);
var
  Inspector: TSBDPropertyInspector;
  Subject: TInspectorSubject;
  Filter: TInspectorTestFilter;
  Rectangle: TRectangle;
  Text: TText;
  Node: TInspectorProperty;
  Rejected: Boolean;

  procedure Check(Condition: Boolean; const Message: string);
  begin
    if not Condition then
      raise Exception.Create('INSPECTOR TEST: ' + Message);
    Report.Add(Message);
  end;

begin
  Inspector := TSBDPropertyInspector.Create(nil);
  Subject := TInspectorSubject.Create;
  Filter := TInspectorTestFilter.Create;
  Inspector.OnFilterProperty := Filter.Filter;
  Inspector.OnEditProperty := Filter.Edit;
  Rectangle := TRectangle.Create(nil);
  Text := TText.Create(nil);
  try
    Inspector.Width := 400;
    Inspector.Height := 600;
    Subject.FCount := 17;
    Subject.FNext := Subject;
    Inspector.Inspect(Subject);
    Check(Inspector.FindProperty('Count').Kind = iekNumber, 'standalone numeric editor');
    Check(Inspector.FindProperty('Enabled').Editor is TCheckBox, 'standalone Boolean checkbox');
    Node := Inspector.FindProperty('Mode');
    Check((Node.Editor is TComboBox) and (Node.Choices.Count > 1), 'enumeration dropdown populated');
    Inspector.WriteProperty('Mode', 'Gradient');
    Check(Subject.Mode = TBrushKind.Gradient, 'standalone enumeration write');
    Inspector.WriteProperty('Enabled', 'True');
    Check(Subject.Enabled, 'standalone Boolean write');
    Inspector.WriteProperty('Count', '23');
    Check(Subject.Count = 23, 'standalone integer write');
    Rejected := False;
    try
      Inspector.WriteProperty('Count', 'invalid');
    except
      on E: EConvertError do
        Rejected := True;
    end;
    Check(Rejected and (Subject.Count = 23), 'invalid number preserves property');
    Check(Inspector.FindProperty('ReadOnlyCount').ReadOnly, 'read-only property identified');
    Rejected := False;
    try
      Inspector.WriteProperty('ReadOnlyCount', '99');
    except
      on E: EConvertError do
        Rejected := True;
    end;
    Check(Rejected and (Subject.Count = 23), 'read-only property cannot be written');
    Check(Inspector.FindProperty('Next.Next') = nil, 'cyclic persistent object stops recursion');
    Inspector.WriteProperty('Flags.flag65', 'True');
    Check(flag65 in Subject.Flags, 'large set member above bit 63');
    Inspector.WriteProperty('Flags.flag65', 'False');
    Check(not (flag65 in Subject.Flags), 'large set member can be cleared');
    Check(Inspector.FindProperty('OffsetFlags') <> nil, 'offset set parent exists');
    Check(Inspector.FindProperty('OffsetFlags.flag70') <> nil, 'offset set child exists');
    Inspector.WriteProperty('OffsetFlags.flag70', 'True');
    Check(flag70 in Subject.OffsetFlags, 'set member with nonzero storage offset');
    Inspector.WriteProperty('Flags', '[flag1,flag70]');
    Check((flag1 in Subject.Flags) and (flag70 in Subject.Flags), 'full-size set conversion');
    Inspector.Inspect(Rectangle);
    Check(Inspector.FindProperty('Fill.Color').Kind = iekColor, 'nested color editor');
    Inspector.EditValue('Fill.Color');
    Check((Filter.EditCount = 1) and (Filter.EditPath = 'Fill.Color'), 'color wizard dispatch');
    Check((Inspector.FindProperty('Fill').Kind = iekGroup) and
      (Inspector.FindProperty('Fill.Color').Item.Parent.Parent = Inspector.FindProperty('Fill').Item), 'persistent properties use nested tree items');
    Inspector.WriteProperty('Fill.Color', '#7F123456');
    Check(Rectangle.Fill.Color = $7F123456, 'color alpha channel retained');
    Inspector.WriteProperty('Width', '215.5');
    Check(Abs(Rectangle.Width - 215.5) < 0.001, 'floating point property conversion');
    Rejected := False;
    try
      Inspector.WriteProperty('Width', 'NaN');
    except
      on E: EConvertError do
        Rejected := True;
    end;
    Check(Rejected and (Abs(Rectangle.Width - 215.5) < 0.001), 'non-finite number rejected');
    Node := Inspector.FindProperty('Fill.Gradient.Points');
    Check((Node.Kind = iekCollection) and (Inspector.FindProperty('Fill.Gradient.Points[0].Color') <> nil), 'collection item properties are nested');
    Check(Inspector.FindProperty('Fill.Gradient').Kind = iekGradient, 'gradient has a dedicated wizard');
    Check(Inspector.FindProperty('Stroke.Gradient').Kind = iekGradient, 'stroke gradient uses the same wizard');
    Inspector.EditValue('Fill.Gradient');
    Check(Filter.EditPath = 'Fill.Gradient', 'gradient wizard dispatch');
    Inspector.FindProperty('Fill').Item.IsExpanded := False;
    Inspector.FilterText := 'Fill.Color';
    Check(Inspector.FindProperty('Fill').Item.IsExpanded and Inspector.FindProperty('Fill.Color').Item.Visible,
      'filter exposes matching child and ancestors');
    Check(not Inspector.FindProperty('Align').Item.Visible, 'filter hides unrelated properties');
    Inspector.FilterText := '';
    Check(not Inspector.FindProperty('Fill').Item.IsExpanded, 'clearing filter restores expansion state');
    Inspector.FindProperty('Fill').Item.IsExpanded := True;
    Inspector.SelectPath('Fill.Color');
    Inspector.Refresh;
    Check((Inspector.SelectedProperty.Path = 'Fill.Color') and Inspector.FindProperty('Fill').Item.IsExpanded,
      'refresh preserves selection and expanded groups');
    Inspector.Inspect(Text);
    Check(Inspector.FindProperty('TextSettings.Font.Family').Kind = iekFontFamily, 'font family editable dropdown');
    Check(Inspector.FindProperty('TextSettings.Font').Kind = iekFont, 'font wizard entry');
    Inspector.EditValue('TextSettings.Font');
    Check(Filter.EditPath = 'TextSettings.Font', 'font wizard dispatch');
    Inspector.WriteProperty('TextSettings.Font.Style.fsBold', 'True');
    Check(TFontStyle.fsBold in Text.TextSettings.Font.Style, 'font style flags');
    Inspector.Clear;
    Check((Inspector.SelectedProperty = nil) and (Inspector.Tree.Count = 0), 'clear removes target and nodes');
  finally
    Inspector.Free;
    Text.Free;
    Rectangle.Free;
    Subject.Free;
    Filter.Free;
  end;
end;

type
  TGradientModalDriver = class
    Timer: TTimer;
    Action: TProc<TGradientEditorForm>;
    Error: string;
    ResultCode: TModalResult;
    constructor Create;
    destructor Destroy; override;
    procedure Respond(Sender: TObject);
  end;

constructor TGradientModalDriver.Create;
begin
  inherited;
  Timer := TTimer.Create(nil);
  Timer.Enabled := False;
  Timer.Interval := 150;
  Timer.OnTimer := Respond;
end;

destructor TGradientModalDriver.Destroy;
begin
  Timer.Free;
  inherited;
end;

procedure TGradientModalDriver.Respond(Sender: TObject);
begin
  for var I := Screen.FormCount - 1 downto 0 do
    if (Screen.Forms[I] is TGradientEditorForm) and Screen.Forms[I].Visible then
    begin
      Timer.Enabled := False;
      var Dialog := TGradientEditorForm(Screen.Forms[I]);
      try
        Action(Dialog);
        Dialog.ModalResult := ResultCode;
      except
        on E: Exception do
        begin
          Error := E.Message;
          Dialog.ModalResult := mrCancel;
        end;
      end;
      Exit;
    end;
end;

procedure CaptureGradientDialog(Dialog: TGradientEditorForm; const Name: string);
begin
  var Bitmap := TBitmap.Create(Round(Dialog.ClientWidth), Round(Dialog.ClientHeight));
  try
    Bitmap.Clear(TAlphaColors.White);
    if Bitmap.Canvas.BeginScene then
    try
      Dialog.PaintTo(Bitmap.Canvas);
    finally
      Bitmap.Canvas.EndScene;
    end;
    Bitmap.SaveToFile(ExtractFilePath(ParamStr(0)) + Name);
  finally
    Bitmap.Free;
  end;
end;

procedure RunGradientDialogTests(Owner: TCustomForm; Report: TStrings; const Suffix: string);
var
  Rectangle: TRectangle;
  Inspector: TSBDPropertyInspector;
  Original: TGradient;
  Driver: TGradientModalDriver;
  Check: TProc<Boolean, string>;
begin
  Check :=
    procedure(Condition: Boolean; Description: string)
    begin
      if not Condition then
        raise Exception.Create('GRADIENT: ' + Description + Suffix);
      Report.Add(Description + Suffix);
    end;
  Rectangle := TRectangle.Create(nil);
  Inspector := TSBDPropertyInspector.Create(Owner);
  Original := TGradient.Create;
  Driver := TGradientModalDriver.Create;
  try
    var Invalid := TGradient.Create;
    try
      Invalid.Points.Clear;
      Invalid.StopPosition.Point := Invalid.StartPosition.Point;
      var Repair := TGradientEditorForm.CreateEditor(Owner, Invalid);
      try
        Check(not Repair.ApplyButton.Enabled, 'empty gradients cannot be applied');
        Repair.AddPoint(0);
        Repair.AddPoint(1);
        Check(not Repair.ApplyButton.Enabled, 'zero-length direction cannot be applied');
        Repair.AngleEdit.Value := 45;
        Check(Repair.ApplyButton.Enabled and (Invalid.Points.Count = 0),
          'empty and zero-length gradients can be repaired without changing the source');
      finally
        Repair.Free;
      end;
    finally
      Invalid.Free;
    end;
    Inspector.Parent := Owner;
    Inspector.Visible := False;
    Rectangle.Fill.Gradient.StartPosition.Point := PointF(0.2, 0.1);
    Rectangle.Fill.Gradient.StopPosition.Point := PointF(0.8, 0.9);
    Rectangle.Fill.Gradient.RadialTransform.Scale.Point := PointF(0.8, 1.2);
    Rectangle.Fill.Gradient.RadialTransform.RotationAngle := 27;
    CopyGradient(Original, Rectangle.Fill.Gradient);
    Inspector.Inspect(Rectangle);
    Driver.ResultCode := mrCancel;
    Driver.Action :=
      procedure(Dialog: TGradientEditorForm)
      begin
        Check(SameGradient(Dialog.Value, Original), 'opening preserves custom linear and radial geometry');
        Check(Dialog.StyleBook = Owner.StyleBook, 'gradient wizard inherits the owner theme');
        Check(Dialog.TypeCombo.Items[0] = Translate('Линейный'), 'gradient type is localized');
        Dialog.AngleDial.Value := 45;
        Check((Abs(Dialog.AngleEdit.Value - 45) < 0.001) and
          (Abs(Dialog.Value.StartPosition.X) < 0.001) and
          (Abs(Dialog.Value.StopPosition.Y) < 0.001), 'ArcDial updates angle and diagonal gradient');
        Dialog.AngleEdit.Value := -90;
        Check((Abs(Dialog.AngleDial.Value + 90) < 0.001) and
          (Abs(Dialog.Value.StartPosition.Y) < 0.001) and
          (Abs(Dialog.Value.StopPosition.Y - 1) < 0.001), 'numeric angle updates ArcDial and vertical gradient');
        var Stop := Dialog.AddPoint(0.4);
        Stop.Color := $803399FF;
        Dialog.OffsetEdit.Value := 90;
        Check((Dialog.PointList.Selected.TagObject = Stop) and
          (Abs(Stop.Offset - 0.9) < 0.001), 'offset sorting preserves the selected color stop');
        Dialog.ReversePoints;
        Check((Abs(Stop.Offset - 0.1) < 0.001) and (Stop.Color = $803399FF),
          'reverse mirrors positions and preserves alpha');
        Dialog.DeletePoint;
        Check(Dialog.Value.Points.Count = 2, 'selected color stop can be removed');
        Dialog.DeletePoint;
        Check(Dialog.Value.Points.Count = 2, 'at least two color stops remain');
        Check(SameGradient(Rectangle.Fill.Gradient, Original), 'editing the draft leaves the source untouched');
        Dialog.TypeCombo.ItemIndex := 1;
        Dialog.CenterXEdit.Value := 35;
        Dialog.CenterYEdit.Value := 65;
        Check(not Dialog.AngleDial.Enabled and Dialog.CenterXEdit.Enabled and
          (Abs(Dialog.Value.RadialTransform.RotationCenter.X - 0.35) < 0.001), 'radial mode exposes center controls');
        Dialog.TypeCombo.ItemIndex := 0;
        Dialog.AngleDial.Value := -35;
        Stop := Dialog.AddPoint(0.55);
        Stop.Color := $803399FF;
        Dialog.ReversePoints;
        var OriginalWindowSize := PointF(Dialog.Width, Dialog.Height);
        Dialog.Width := Round(Dialog.Constraints.MinWidth);
        Dialog.Height := Round(Dialog.Constraints.MinHeight);
        for var I := 1 to 5 do
        begin
          Application.ProcessMessages;
          Sleep(20);
        end;
        Dialog.DialogBody.RealignContent;
        Dialog.DialogBody.ViewportPosition := PointF(0, 200);
        for var I := 1 to 5 do
        begin
          Application.ProcessMessages;
          Sleep(20);
        end;
        CaptureGradientDialog(Dialog, 'selftest-gradient-compact' + Suffix + '.png');
        Check(Dialog.AddButton.AbsoluteRect.Bottom <= Dialog.Actions.AbsoluteRect.Top,
          Format('compact gradient wizard scrolls above footer: %.0f <= %.0f, viewport %.0f',
            [Dialog.AddButton.AbsoluteRect.Bottom, Dialog.Actions.AbsoluteRect.Top,
              Dialog.DialogBody.ViewportPosition.Y]));
        Check(Dialog.CenterYEdit.AbsoluteRect.Right <= Dialog.BodyContent.AbsoluteRect.Right + 1,
          'compact gradient wizard keeps geometry controls inside the viewport');
        Dialog.Width := Round(OriginalWindowSize.X);
        Dialog.Height := Round(OriginalWindowSize.Y);
        Dialog.DialogBody.ViewportPosition := PointF(0, 0);
        Dialog.DialogBody.RealignContent;
        for var I := 1 to 5 do
        begin
          Application.ProcessMessages;
          Sleep(20);
        end;
        Check(Dialog.AngleDial.AbsoluteRect.Top >= Dialog.DialogHeader.AbsoluteRect.Bottom,
          'expanding the gradient wizard restores the visible direction controls');
        Check(Dialog.PointList.Width >= 300, 'gradient layout leaves room for color stop labels');
        CaptureGradientDialog(Dialog, 'selftest-gradient' + Suffix + '.png');
      end;
    Driver.Timer.Enabled := True;
    Inspector.EditValue('Fill.Gradient');
    Check(Driver.Error.IsEmpty, 'gradient cancel modal interaction: ' + Driver.Error);
    Check(SameGradient(Rectangle.Fill.Gradient, Original) and (Rectangle.Fill.Kind = TBrushKind.Solid),
      'cancel preserves gradient and brush kind');
    Driver.ResultCode := mrOk;
    Driver.Action :=
      procedure(Dialog: TGradientEditorForm)
      begin
        // Exercise the actual dial pointer event path, including live tracking.
        Dialog.AngleDial.MouseDown(TMouseButton.mbLeft, [], 104, 52);
        Dialog.AngleDial.MouseMove([ssLeft], 52, 104);
        Dialog.AngleDial.MouseUp(TMouseButton.mbLeft, [], 52, 104);
        Check(Abs(Dialog.AngleEdit.Value + 90) < 0.001, 'dragging ArcDial continuously updates the angle');
        Dialog.TypeCombo.ItemIndex := 1;
        Dialog.CenterXEdit.Value := 25;
        Dialog.AddPoint(0.5).Color := $403399FF;
      end;
    Driver.Timer.Enabled := True;
    Inspector.EditValue('Fill.Gradient');
    Check(Driver.Error.IsEmpty, 'gradient apply modal interaction: ' + Driver.Error);
    Check((Rectangle.Fill.Kind = TBrushKind.Gradient) and
      (Rectangle.Fill.Gradient.Style = TGradientStyle.Radial) and
      (Rectangle.Fill.Gradient.Points.Count = 3) and
      (Rectangle.Fill.Gradient.Points[1].Color = $403399FF) and
      (Abs(Rectangle.Fill.Gradient.RadialTransform.RotationAngle - 27) < 0.001),
      'apply preserves radial transform, color alpha and activates gradient');
    Check(Inspector.FindProperty('Fill.Gradient.Points[2].Color') <> nil,
      'inspector rebuilds nested stop properties after applying');
  finally
    Driver.Free;
    Original.Free;
    Inspector.Free;
    Rectangle.Free;
  end;
end;

type
  TDialogTestDriver = class
    Timer: TTimer;
    Action: TProc<TFormDialogs>;
    Error: string;
    ButtonIndex: Integer;
    procedure Respond(Sender: TObject);
    constructor Create;
    destructor Destroy; override;
    procedure Arm(Index: Integer; Inspect: TProc<TFormDialogs> = nil);
  end;

constructor TDialogTestDriver.Create;
begin
  inherited;
  Timer := TTimer.Create(nil);
  Timer.Enabled := False;
  Timer.Interval := 150;
  Timer.OnTimer := Respond;
end;

destructor TDialogTestDriver.Destroy;
begin
  Timer.Free;
  inherited;
end;

procedure TDialogTestDriver.Arm(Index: Integer; Inspect: TProc<TFormDialogs>);
begin
  ButtonIndex := Index;
  Action := Inspect;
  Error := '';
  Timer.Enabled := True;
end;

procedure TDialogTestDriver.Respond(Sender: TObject);
begin
  for var I := Screen.FormCount - 1 downto 0 do
    if (Screen.Forms[I] is TFormDialogs) and Screen.Forms[I].Visible then
    begin
      var Dialog := TFormDialogs(Screen.Forms[I]);
      Timer.Enabled := False;
      try
        if Assigned(Action) then
          Action(Dialog);
      except
        on E: Exception do
          Error := E.Message;
      end;
      if (ButtonIndex < 0) or not Error.IsEmpty then
        Dialog.ActionClose.Execute
      else
        for var J := 0 to Dialog.FrameDialog.FlowLayoutButtons.ControlsCount - 1 do
        begin
          var Button := Dialog.FrameDialog.FlowLayoutButtons.Controls[J] as TButton;
          if Button.Tag = ButtonIndex then
          begin
            Button.OnClick(Button);
            Exit;
          end;
        end;
      Exit;
    end;
end;

procedure CaptureWinUIDialog(Dialog: TFormDialogs; const Name: string);
begin
  var Bitmap := TBitmap.Create(Round(Dialog.ClientWidth), Round(Dialog.ClientHeight));
  try
    Bitmap.Clear($FF202020);
    if Bitmap.Canvas.BeginScene then
    try
      Dialog.PaintTo(Bitmap.Canvas);
    finally
      Bitmap.Canvas.EndScene;
    end;
    Bitmap.SaveToFile(ExtractFilePath(ParamStr(0)) + Name);
  finally
    Bitmap.Free;
  end;
end;

procedure RunWinUIDialogTests(Owner: TCustomForm; Report: TStrings; const Suffix: string);
var
  Driver: TDialogTestDriver;
  Font: TFont;
  Color: TAlphaColor;
  Text: string;

  procedure Check(Condition: Boolean; const Message: string);
  begin
    if not Driver.Error.IsEmpty then
      raise Exception.Create('WINUI DIALOG TEST: ' + Driver.Error);
    if not Condition then
      raise Exception.Create('WINUI DIALOG TEST: ' + Message);
    Report.Add(Message);
  end;

begin
  Driver := TDialogTestDriver.Create;
  Font := TFont.Create;
  try
    Driver.Arm(0,
      procedure(Dialog: TFormDialogs)
      begin
        if Dialog.StyleBook <> Owner.StyleBook then
          raise Exception.Create('message dialog must inherit application theme');
        CaptureWinUIDialog(Dialog, 'selftest-winui-message' + Suffix + '.png');
      end);
    ShowAppMessage(Owner, Translate('Структура стиля проверена. Ошибок имён ресурсов и свойств анимаций не найдено.'));
    Check(True, 'message dialog uses DelphiWinUI3 and application theme');
    Text := 'original';
    Driver.Arm(0,
      procedure(Dialog: TFormDialogs)
      begin
        for var I := 0 to Dialog.FrameDialog.VertScrollBoxBody.Content.ChildrenCount - 1 do
          if Dialog.FrameDialog.VertScrollBoxBody.Content.Children[I] is TFrameDialogInput then
            TFrameDialogInput(Dialog.FrameDialog.VertScrollBoxBody.Content.Children[I]).EditInput.Text := 'accepted';
        CaptureWinUIDialog(Dialog, 'selftest-winui-input' + Suffix + '.png');
      end);
    Check(AskAppText(Owner, Translate('Название группы'), Translate('Название'), Text) and
      (Text = 'accepted'), 'WinUI input applies edited text on primary action');
    Driver.Arm(-1);
    Check(not AskAppText(Owner, Translate('Название группы'), Translate('Название'), Text) and
      (Text = 'accepted'), 'closing WinUI input preserves original value');
    Color := $80247AC4;
    Driver.Arm(1,
      procedure(Dialog: TFormDialogs)
      begin
        CaptureWinUIDialog(Dialog, 'selftest-winui-color' + Suffix + '.png');
      end);
    Check(not ChooseColor(Owner, Color) and (Color = $80247AC4),
      'WinUI color cancel preserves alpha and original value');
    Driver.Arm(0);
    Check(ChooseColor(Owner, Color) and (Color = $80247AC4), 'WinUI color apply preserves alpha');
    Font.Family := 'Segoe UI';
    Font.Size := 17;
    Font.Style := [TFontStyle.fsBold];
    Driver.Arm(1,
      procedure(Dialog: TFormDialogs)
      begin
        CaptureWinUIDialog(Dialog, 'selftest-winui-font' + Suffix + '.png');
      end);
    Check(not ChooseAppFont(Owner, Font) and (Font.Size = 17) and (Font.Family = 'Segoe UI'),
      'WinUI font cancel preserves original font');
    Driver.Arm(0);
    Check(ChooseAppFont(Owner, Font) and (Font.Size = 17) and
      (Font.Family = 'Segoe UI') and (TFontStyle.fsBold in Font.Style),
      'WinUI font apply preserves family, size and style: ' + Font.Family + '/' +
      Font.Size.ToString + '/' + BoolToStr(TFontStyle.fsBold in Font.Style, True));
    Driver.Arm(0,
      procedure(Dialog: TFormDialogs)
      begin
        for var I := 0 to Dialog.FrameDialog.VertScrollBoxBody.Content.ChildrenCount - 1 do
          if Dialog.FrameDialog.VertScrollBoxBody.Content.Children[I] is TFrameDialogFont then
          begin
            var Body := TFrameDialogFont(Dialog.FrameDialog.VertScrollBoxBody.Content.Children[I]);
            Body.SpinBoxFontSize.Value := 23;
            Body.CheckBoxItalic.IsChecked := True;
          end;
      end);
    Check(ChooseAppFont(Owner, Font) and (Font.Size = 23) and
      (TFontStyle.fsBold in Font.Style) and (TFontStyle.fsItalic in Font.Style),
      'WinUI font editor applies size and italic changes');
  finally
    Font.Free;
    Driver.Free;
  end;
end;

end.


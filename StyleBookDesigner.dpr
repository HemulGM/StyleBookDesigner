program StyleBookDesigner;

uses
  System.StartUpCopy,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  FMX.Forms,
  SBD.Localization in 'SBD.Localization.pas',
  SBD.Dialogs in 'SBD.Dialogs.pas',
  SBD.BitmapLinksDialog in 'SBD.BitmapLinksDialog.pas' {BitmapLinksEditorForm},
  SBD.StyleCatalog in 'SBD.StyleCatalog.pas',
  SBD.StyleCatalogDialog in 'SBD.StyleCatalogDialog.pas' {StyleCatalogDialog},
  SBD.Main in 'SBD.Main.pas' {FormMain},
  SBD.Preview in 'SBD.Preview.pas' {PreviewForm},
  SBD.CollectionDialog in 'SBD.CollectionDialog.pas' {CollectionDialog},
  SBD.ValuesDialog in 'SBD.ValuesDialog.pas' {NamedValuesDialog},
  SBD.TextDialog in 'SBD.TextDialog.pas' {TextEditorForm},
  SBD.ColorDialog in 'SBD.ColorDialog.pas' {ColorEditorForm},
  SBD.GradientDialog in 'SBD.GradientDialog.pas' {GradientEditorForm},
  SBD.PropertyInspector in 'SBD.PropertyInspector.pas',
  SBD.PropertyInspector.Tests in 'SBD.PropertyInspector.Tests.pas',
  FMX.Menus in 'DelphiWinUI3\Fixes\D13\FMX.Menus.pas',
  FMX.Platform.Win in 'DelphiWinUI3\Fixes\D13\FMX.Platform.Win.pas',
  FMX.StyledContextMenu in 'DelphiWinUI3\Fixes\D13\FMX.StyledContextMenu.pas',
  HGM.ColorUtils in 'DelphiWinUI3\Sources\HGM.ColorUtils.pas',
  WinUI3.Dialogs.DataTransferManager in 'DelphiWinUI3\Sources\WinUI3.Dialogs.DataTransferManager.pas',
  WinUI3.Dialogs in 'DelphiWinUI3\Sources\WinUI3.Dialogs.pas',
  WinUI3.Form.Dialog in 'DelphiWinUI3\Sources\WinUI3.Form.Dialog.pas' {FormDialogs},
  WinUI3.Form in 'DelphiWinUI3\Sources\WinUI3.Form.pas',
  WinUI3.Frame.Dialog.ColorPicker in 'DelphiWinUI3\Sources\WinUI3.Frame.Dialog.ColorPicker.pas' {FrameDialogColorPicker: TFrame},
  WinUI3.Frame.Dialog.Font in 'DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Font.pas' {FrameDialogFont: TFrame},
  WinUI3.Frame.Dialog.Input in 'DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Input.pas' {FrameDialogInput: TFrame},
  WinUI3.Frame.Dialog in 'DelphiWinUI3\Sources\WinUI3.Frame.Dialog.pas' {FrameDialog: TFrame},
  WinUI3.Frame.Dialog.Text in 'DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Text.pas' {FrameDialogText: TFrame},
  WinUI3.Frame.Inner.Dialog in 'DelphiWinUI3\Sources\WinUI3.Frame.Inner.Dialog.pas' {FrameInnerDialog: TFrame},
  WinUI3.Frame.Inner.InfoBar in 'DelphiWinUI3\Sources\WinUI3.Frame.Inner.InfoBar.pas' {FrameInnerInfoBar: TFrame},
  WinUI3.Style in 'DelphiWinUI3\Sources\WinUI3.Style.pas',
  WinUI3.Utils in 'DelphiWinUI3\Sources\WinUI3.Utils.pas',
  DelphiWindowStyle.Core.Win in 'DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.Core.Win.pas',
  DelphiWindowStyle.FMX in 'DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.FMX.pas',
  DelphiWindowStyle.Types in 'DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.Types.pas',
  FMX.Windows.Dispatch in 'DelphiWinUI3\FMXWindowsDispatch\FMX.Windows.Dispatch.pas',
  FMX.Windows.Hints in 'DelphiWinUI3\FMXWindowsHint\FMX.Windows.Hints.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'StyleBook Designer';
  Application.CreateForm(TFormMain, FormMain);
  if FindCmdLineSwitch('self-test') or FindCmdLineSwitch('-self-test') or FindCmdLineSwitch('perf-test') then
  begin
    try
      try
        Application.RealCreateForms;
        if FindCmdLineSwitch('perf-test') then FormMain.PerformanceTest(ParamStr(2))
        else FormMain.SelfTest;
      finally
        FreeAndNil(FormMain);
      end;
      TFile.WriteAllText(TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-result.txt'), 'PASS', TEncoding.UTF8);
    except
      on E: Exception do
      begin
        TFile.WriteAllText(TPath.Combine(ExtractFilePath(ParamStr(0)), 'selftest-result.txt'),
          E.ClassName + ': ' + E.Message, TEncoding.UTF8);
        ExitCode := 1;
      end;
    end;
  end
  else
  begin
    try
      Application.Run;
    finally
      FreeAndNil(FormMain);
    end;
  end;
end.
